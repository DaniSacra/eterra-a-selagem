#!/usr/bin/env python3
"""Resume o registro de partidas (runs.jsonl) em Markdown pt-BR.
Uso: python3 -I tools/runs_report.py [runs.jsonl] [--since=2026-11-23T18:00] [--until=...] [--source=human|bot|all] [--min-time=30] [--by=room] [--out=arquivo.md]
Sem arquivo: usa o runs.jsonl do Windows (AppData/Roaming/EterraASelagem). Só biblioteca padrão."""
import json, sys, os, collections

DEFAULT = "/mnt/c/Users/danie/AppData/Roaming/EterraASelagem/runs.jsonl"
HEROES = {"warrior": "Guerreiro", "mage": "Maga", "maga": "Maga"}


def fmt_t(s):
    s = int(s or 0)
    return "%d:%02d" % (s // 60, s % 60)


def avg(v):
    return sum(v) / len(v) if v else 0.0


def table(head, rows):
    out = ["| " + " | ".join(head) + " |", "|" + "---|" * len(head)]
    out += ["| " + " | ".join(str(c) for c in r) + " |" for r in rows]
    return "\n".join(out) + "\n"


def dealt(x, *keys):
    d = x.get("dealt_by") or {}
    return sum(d.get(k, 0) for k in keys)


def used(x):
    """Uso por tecla, o que o registro permite saber: o jogo não grava teclas, só efeitos."""
    ult = (x.get("ult") or {}).get("uses", 0)
    u = x.get("uses")
    if u:
        # since log version 7 the game counts the presses themselves
        return {"Espaço (esquiva)": u.get("space", 0), "Q (vezes)": u.get("q", 0), "E (vezes)": u.get("e", 0),
                "Shift (vezes)": u.get("shift", 0), "Ômega": x.get("omegas", 0),
                "Golpes levados sem carga de esquiva": u.get("dry_hits", 0)}
    return {
        "Espaço (esquiva)": x.get("dodges", 0),
        "Q (Brado)": dealt(x, "shout"),
        "E (arrancada)": dealt(x, "dash"),
        "Shift (final)": ult or dealt(x, "ultimate"),
        "Ômega": x.get("omegas", 0),
        "Especial (golpe forte)": dealt(x, "special", "omega_special"),
    }


HAZARDS = {"runes", "plates", "chain", "roots", "slit", "trap", "crystal", "rocks", "urn", "oil", "niche", "plant", "sag", "spikes", "spikeplate"}


def strikes(hz):
    if not hz:
        return 0
    return hz.get("strikes", 0) + strikes(hz.get("also")) + sum(strikes(m) for m in hz.get("more", []))


def by_room(real):
    """Por sala (BL-11, CF-08, RD-04): entradas, mortes e causa, vida ao entrar, dano por fonte, golpes de perigo e golpes sem carga de esquiva
    (hurt_ctx com dash_ready falso; só os 60 primeiros golpes de cada partida). Lê linhas antigas: o que falta vira 0."""
    rooms = collections.defaultdict(lambda: {"in": 0, "deaths": 0, "cause": collections.Counter(), "hp": [], "dmg": collections.Counter(),
                                              "hits": 0, "hz_hero": 0, "hz_enemy": 0, "ctx": 0, "dry": 0})
    for x in real:
        for r in x.get("rooms") or []:
            a = rooms[r.get("depth", 0)]
            a["in"] += 1
            hp = r.get("hp_enter", r.get("hp_in"))
            if hp is not None:
                a["hp"].append(hp)
            for k, v in (r.get("hurt_by") or {}).items():
                a["dmg"][k] += v
            hb = r.get("hits_by") or {}
            a["hits"] += sum(hb.values())
            a["hz_hero"] += r["hazard_hits_hero"] if "hazard_hits_hero" in r else sum(v for k, v in hb.items() if k in HAZARDS)
            a["hz_enemy"] += r["hazard_hits_enemy"] if "hazard_hits_enemy" in r else strikes(r.get("hazard"))
        for h in x.get("hurt_ctx") or []:
            a = rooms[h.get("room", 0)]
            a["ctx"] += 1
            a["dry"] += 0 if h.get("dash_ready") else 1
        if x.get("outcome") == "death":
            a = rooms[x.get("room", 0)]
            a["deaths"] += 1
            a["cause"][x.get("cause") or (x.get("last_hurt") or {}).get("attack") or (x.get("last_hurt") or {}).get("enemy") or "?"] += 1
    rows = []
    for d, a in sorted(rooms.items()):
        total = sum(a["dmg"].values()) or 1
        top = a["dmg"].most_common(1)
        rows.append([d, a["in"], a["deaths"], ", ".join("%s %d" % kv for kv in a["cause"].most_common(3)) or "-",
                     "%.0f" % avg(a["hp"]) if a["hp"] else "-", "%s %d%%" % (top[0][0], 100 * top[0][1] / total) if top else "-",
                     "%d / %d" % (a["hz_hero"], a["hz_enemy"]),
                     "%d de %d (%d%%)" % (a["dry"], a["ctx"], 100 * a["dry"] / a["ctx"]) if a["ctx"] else "-"])
    return table(["Sala", "Entradas", "Mortes", "Causa (top 3)", "Vida ao entrar", "Fonte de mais dano", "Perigo: no herói / nos inimigos",
                  "Golpes sem carga de esquiva"], rows)


def main(argv):
    opts = {a.split("=")[0][2:]: (a.split("=", 1) + ["1"])[1] for a in argv if a.startswith("--")}
    files = [a for a in argv if not a.startswith("--")]
    path = files[0] if files else DEFAULT
    since, until = opts.get("since", ""), opts.get("until", "9999")
    source, min_time = opts.get("source", "human"), float(opts.get("min-time", 30))
    runs, bad = [], 0
    for line in open(path, encoding="utf-8"):
        line = line.strip()
        if not line:
            continue
        try:
            e = json.loads(line)
        except ValueError:
            bad += 1
            continue
        if isinstance(e, dict) and since <= e.get("when", "") <= until and (source == "all" or e.get("source", "human") == source):
            runs.append(e)
    o = ["# Resumo das partidas", ""]
    o.append("Arquivo: `%s`. Filtro: desde `%s`%s, origem `%s`. Linhas danificadas ignoradas: %d." % (
        path, since or "o começo", "" if until == "9999" else " até " + until, source, bad))
    if not runs:
        print("\n".join(o + ["", "Nenhuma partida no filtro."]))
        return
    short = [x for x in runs if x.get("outcome") == "quit" and x.get("time", 0) < min_time]
    real = [x for x in runs if x not in short]
    n = len(real)
    cnt = collections.Counter(x.get("outcome") for x in real)
    o += ["", "## Visão geral", "",
          "- Partidas no filtro: %d. Largadas no começo (quit com menos de %ds, ruído): %d. **Partidas reais: %d**." % (len(runs), min_time, len(short), n),
          "- Vitórias %d, mortes %d, saídas no meio %d." % (cnt["victory"], cnt["death"], cnt["quit"]),
          "- Duração média: %s (mortes: %s, vitórias: %s). Primeira partida: %s, última: %s." % (
              fmt_t(avg([x.get("time", 0) for x in real])), fmt_t(avg([x.get("time", 0) for x in real if x.get("outcome") == "death"])),
              fmt_t(avg([x.get("time", 0) for x in real if x.get("outcome") == "victory"])), runs[0].get("when"), runs[-1].get("when"))]
    if not n:
        print("\n".join(o))
        return
    o += ["", "## Por save e por herói", ""]
    groups = collections.defaultdict(list)
    for x in real:
        groups[("slot %s" % x.get("slot", "?"), HEROES.get(x.get("hero", "warrior"), x.get("hero")))].append(x)
    rows = []
    for (s, h), g in sorted(groups.items()):
        rows.append([s, h, len(g), sum(1 for x in g if x["outcome"] == "victory"), sum(1 for x in g if x["outcome"] == "death"),
                     fmt_t(avg([x.get("time", 0) for x in g])), "%.1f" % avg([x.get("room", 0) for x in g]), "%.0f" % avg([x.get("mastery_level", 0) for x in g])])
    o.append(table(["Save", "Herói", "Partidas", "Vitórias", "Mortes", "Tempo médio", "Sala média", "Maestria média"], rows))
    if opts.get("by") == "room":
        o += ["## Por sala", "", by_room(real),
              "Golpes sem carga de esquiva: golpes levados com 0 cargas, do `hurt_ctx` (até 60 por partida). Perigo: golpes do cenário no herói e golpes do cenário que atingem inimigos (`strikes`). Linhas antigas sem `cause` usam o último golpe.", ""]
    o += ["## Mortes (sala e tempo)", ""]
    deaths = [x for x in real if x.get("outcome") == "death"]
    byroom = collections.Counter(x.get("room", 0) for x in deaths)
    o.append("Por sala: " + (", ".join("sala %d: %d" % (r, c) for r, c in sorted(byroom.items())) or "nenhuma morte") + ".\n")
    if deaths:
        o.append(table(["Quando", "Save", "Herói", "Sala", "Tempo", "Matou", "Último golpe", "Dons"],
                       [[x.get("when", "")[5:16], x.get("slot", "?"), x.get("hero", "warrior"), x.get("room"), fmt_t(x.get("time")),
                         x.get("defeated_by") or "?", (x.get("last_hurt") or {}).get("attack", "") or "", x.get("boons", 0)] for x in deaths]))
    o += ["## O que matou (top 10)", ""]
    kills = collections.Counter(x.get("defeated_by") or "?" for x in deaths)
    o.append(table(["Causa", "Mortes"], kills.most_common(10)) if kills else "Nenhuma morte.\n")
    atk = collections.Counter((x.get("last_hurt") or {}).get("attack") or "?" for x in deaths)
    if atk:
        o.append("Último golpe levado nas mortes: " + ", ".join("%s %d" % kv for kv in atk.most_common(10)) + ".\n")
    o += ["## Guardião e Morvath", ""]
    g_win = sum(1 for x in real if (x.get("xp_by") or {}).get("guardians", 0) > 0 or (x.get("materials", {}).get("memory", {}) or {}).get("guardian", 0) > 0)
    reach = [x for x in real if x.get("boss_at", -1) > 0 or x.get("mode") == "ENDING"]
    o += ["- Guardião derrotado (Memória/XP de guardião): %d de %d partidas. (Chegada ao guardião não é gravada; o número conta quem o venceu.)" % (g_win, n),
          "- Chegaram a Morvath: %d de %d. Venceram: %d (%s das que chegaram)." % (len(reach), n, cnt["victory"], "%d%%" % (100 * cnt["victory"] / len(reach)) if reach else "0%"),
          "- Vida ao chegar em Morvath (média): %s. Dons em Morvath (média): %.1f." % (
              "%.0f" % avg([x.get("hp_at_boss", 0) for x in reach]) if reach else "-", avg([x.get("boons_at_boss", 0) for x in reach]))]
    o += ["", "## Teclas e habilidades usadas", "",
          "O registro não grava teclas; o uso vem dos efeitos (dano por origem, esquivas, Ômegas, usos do final). Q, E e Especial contam dano causado (não vezes); Espaço, Shift e Ômega contam usos. Uma habilidade que não causa dano (Brado sem acertar) pode aparecer como não usada.", ""]
    # two groups: lines of version 7 (counted presses) and older ones (read from the damage)
    counted = [x for x in real if x.get("uses")]
    if counted:
        o += ["Desde a versão 7 do registro o jogo conta as vezes de Q, E, Shift e Espaço e os golpes levados com 0 carga de esquiva (%d partidas):" % len(counted), ""]
        names = list(used(counted[0]).keys())
        o.append(table(["Tecla", "Total", "Média/partida", "Partidas que usaram", "Nunca usaram"],
                       [[k, sum(used(x)[k] for x in counted), "%.1f" % avg([used(x)[k] for x in counted]),
                         sum(1 for x in counted if used(x)[k] > 0), sum(1 for x in counted if used(x)[k] == 0)] for k in names]))
    older = [x for x in real if not x.get("uses")]
    if not older:
        older = []
    names = list(used(older[0]).keys()) if older else []
    tot = {k: [used(x)[k] for x in older] for k in names}
    o.append(table(["Tecla", "Total (dano ou contagem)", "Média/partida", "Partidas que usaram", "Nunca usaram"],
                   [[k, sum(v), "%.1f" % avg(v), sum(1 for a in v if a > 0), sum(1 for a in v if a == 0)] for k, v in tot.items()]))
    o.append("Partidas sem nenhum uso de: " + "; ".join("%s: %s" % (k, ", ".join("%s %s" % (x.get("when", "")[5:16], "s" + str(x.get("slot", "?"))) for x, a in zip(real, v) if a == 0) or "nenhuma") for k, v in tot.items() if 0 < sum(1 for a in v if a == 0) <= 6) + ".\n")
    o += ["## Esquivas", "", "Média %.1f por partida, %.2f por minuto; máximo %d." % (
        avg([x.get("dodges", 0) for x in real]), sum(x.get("dodges", 0) for x in real) / max(1, sum(x.get("time", 0) for x in real) / 60), max(x.get("dodges", 0) for x in real)), ""]
    o += ["## Bênçãos pegas", "", "Média de dons por partida: %.1f. Dons em Morvath: %.1f." % (avg([len(x.get("gifts", [])) for x in real]), avg([x.get("boons_at_boss", 0) for x in reach]) if reach else 0), ""]
    gc = collections.Counter(g.get("id") for x in real for g in x.get("gifts", []))
    o.append(table(["Bênção", "Vezes"], gc.most_common(15)) if gc else "Nenhuma.\n")
    o += ["## Memória, Prata e ouro (custos da Videira)", ""]
    def mat(x, k):
        return ((x.get("materials") or {}).get("total") or {}).get(k, 0)
    rows = []
    for label, grp in [("todas", real), ("vitórias", [x for x in real if x["outcome"] == "victory"]), ("mortes", deaths)]:
        if grp:
            rows.append([label, len(grp), "%.1f" % avg([mat(x, "memory") for x in grp]), max(mat(x, "memory") for x in grp),
                         "%.1f" % avg([mat(x, "silver") for x in grp]), max(mat(x, "silver") for x in grp),
                         "%.1f" % avg([mat(x, "emerald") for x in grp]), "%.0f" % avg([x.get("gold", 0) + (x.get("shop") or {}).get("spent", 0) for x in grp])])
    o.append(table(["Grupo", "Partidas", "Memória média", "Memória máx", "Prata média", "Prata máx", "Esmeralda média", "Ouro (final + gasto na loja) médio"], rows))
    ms = sorted(mat(x, "memory") for x in real)
    o.append("Memória por partida, ordenada: %s. Soma de %d partidas: %d (a Videira inteira custa 105)." % (ms, n, sum(ms)))
    o += ["", "Memória por fonte (soma): " + ", ".join("%s %d" % kv for kv in sorted(sum_src(real, "memory").items())) + ".",
          "Prata por fonte (soma): " + ", ".join("%s %d" % kv for kv in sorted(sum_src(real, "silver").items())) + ".", ""]
    o += ["## Partidas largadas no começo (ruído)", "", "%d partidas `quit` com menos de %ds (tempos: %s)." % (len(short), min_time, ", ".join("%.0fs" % x.get("time", 0) for x in short) or "-"), ""]
    text = "\n".join(o)
    if "out" in opts:
        open(opts["out"], "w", encoding="utf-8").write(text)
    print(text)


def sum_src(runs, k):
    c = collections.Counter()
    for x in runs:
        for s, v in ((x.get("materials") or {}).get(k) or {}).items():
            if s != "total" and isinstance(v, (int, float)):
                c[s] += v
    return c


if __name__ == "__main__":
    main(sys.argv[1:])

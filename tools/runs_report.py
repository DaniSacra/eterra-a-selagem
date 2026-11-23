#!/usr/bin/env python3
"""Resume o registro de partidas (runs.jsonl) em Markdown pt-BR.
Uso: python3 -I tools/runs_report.py [runs.jsonl] [--since=2026-11-23T18:00] [--until=...] [--source=human|bot|all] [--min-time=30] [--out=arquivo.md]
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
    return {
        "Espaço (esquiva)": x.get("dodges", 0),
        "Q (Brado)": dealt(x, "shout"),
        "E (arrancada)": dealt(x, "dash"),
        "Shift (final)": ult or dealt(x, "ultimate"),
        "Ômega": x.get("omegas", 0),
        "Especial (golpe forte)": dealt(x, "special", "omega_special"),
    }


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
    names = list(used(real[0]).keys())
    tot = {k: [used(x)[k] for x in real] for k in names}
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

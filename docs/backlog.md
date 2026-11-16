# Backlog de A Selagem

- **Data**: 2026-11-16 (noite, mais tarde). **Autor**: game-director (sétima revisão: a diretriz "um herói definitivo").
  **Commit lido**: `19af96b` (HEAD de `arpg-3d`); desde a revisão anterior (`71cb8cc`): `1e25f21` (D-42 a D-47 decididas),
  `3fc721b` (GF-14), `6f9bbc7` (A-1, B-1), `aaaacfc`, `4c560eb`, `491c6d4`, `1d06613` (C12d), `2b5647d` (Ravenswatch),
  `efa5cf4` (QA do C12d), `262f99b` (carta nova), `19af96b` (tela cheia, "Sair do jogo").
- **Diretrizes do Daniel**: `docs/design/game_feel_directive.md` (game feel e excelência visual, prioridade máxima) e
  `docs/design/one_hero_directive.md` (nova: um herói só, Maestria, Dons, Bênçãos, Salmos; decisões 1 a 12).
  **Especificação nova**: `docs/design/guardian_spec.md`. **Roteiro**: `docs/design/roadmap_plan.md` seção 00 (manda sobre
  a 0.3).
- **Terminologia nova**: para o jogador, "Bênção" é a carta da descida (no código continua `Boon`) e "Dom" é o talento
  permanente do herói (no código `Talent`, ainda não existe). Nos itens antigos deste backlog, "dom" quer dizer Bênção.
- **Fontes lidas**: `docs/qa/latest_report.md` (QA do C12d, `efa5cf4`), `docs/gallery/boon_cards/ill_1080.jpg` (olhada),
  o código de Bênçãos, save, registro, combos e herói, o cânone (`../dungeon-rpg/docs/mundo/canone.md`, 12/11).
- **Rodado por mim**: `tools/test.sh` no `19af96b`: **541 de 541** (104071 asserções, 112 s). Nada do jogo foi mudado.

## Estado do jogo em 5 linhas

1. **C12d fechado** (QA `efa5cf4`): sonda de game feel 31/31 (antes 4/31), nenhum aperto perdido, hit stop no molde do
   Hades II, latência 14 ms sem vsync e 35 a 42 ms com, 8 descidas com 4 vitórias e ninguém preso. Falta o tempo de quadro
   na placa com o notebook na tomada (M-a).
2. Depois dele: carta de escolha nova (`BoonCard`, três medalhões pintados por IA, declarados em `steam-ia.md`), tela cheia
   por padrão e "Sair do jogo" na pausa. A versão do **T3** está pronta e ainda não foi jogada por gente.
3. **Diretriz nova**: só o Explorador/Guardião até a qualidade desejada; Maestria e Dons permanentes do herói; as cartas
   viram Bênçãos (comum, rara, épica, lendária); Salmos transformam; Compêndio. Nada disso existe no código; a auditoria
   achou um bug latente no save (DT-012) que tem de sair antes.
4. Visual: a mão está boa; a multidão animada aos saltos, as armas do KayKit e Morvath genérico (C12e, C12f) continuam
   sendo o que mais fica abaixo do Ember & Blade.
5. Ordem: **T3, C12e, C12f, T4 (E1)**, depois **E2 Maestria e Dons**, **E3 Bênçãos e combinações** (o C13 antigo, com a
   descida de 10 salas), **E4 Salmos e Compêndio**, **E5 eventos e exploração**, **E6 balanceamento**, C16 Steam.

Legenda: **Esforço** P (horas), M (1 a 2 dias), G (vários dias). **Prioridade** P0 (antes de tudo), P1 (nesta entrega), P2
(próxima), P3 (depois). **Estado**: aberto, em andamento, proposta (espera o Daniel), aprovado, feito. Responsáveis:
`gameplay-engineer`, `environment-artist`, `ui-ux-designer`, `art-director`, `qa-performance`; "Daniel" quando a decisão é dele.

---

## 0. Feito (fechado com evidência)

### C12d "Game feel I: a mão" e o que veio depois (2026-11-16)

| ID | Item | Commit | Prova |
|---|---|---|---|
| GF-14 | Sonda com metas (`FEEL ok/falha`, `FEEL_SUMMARY`) | `3fc721b` | antes 4/31 |
| A-1, B-1 | Colunas da recompensa e da fonte e gemas das portas até 235 na tela (`ScreenTone`, `beam.gdshader` pré-multiplicado) | `6f9bbc7` | `tone_probe`; **sem captura do QA neste ciclo** (o QA do C12d não remediu) |
| VX-11, VX-12, GF-11 (opção) | Nenhum `PALADIN_n` para o jogador; contador menor; opção de vibração | `aaaacfc` | testes; 508 no commit |
| GF-01 a GF-10, GF-13 | Hit stop do Hades II (`HitStop`), esquiva corta a preparação, ataque guardado na esquiva e no golpe sofrido, buffer contado do golpe aberto, controle virtual guarda o toque, seta 18 quadros e 0,7 s com pernas presas 0,71 s (D-44), Ômega acerta ao encher, círculo sem proteção (D-44), virada na hora, tranco 0,087 m (D-43), clarão 0,05 s, sons de disparo, vibração; latência medida | `4c560eb`, QA `efa5cf4` | sonda **31/31**, 0 `LOST` (`docs/gallery/c12d/after/feel_probe.txt`); latência 14 ms sem vsync, 35 a 42 com |
| VX-01 a VX-03, VX-08 a VX-10 | Fio marfim na ponta da Emeth sobre tinta translúcida, brilho do finalizador fraco sobre o herói, avisos com preenchimento só nos últimos 30% e uma vez onde se cruzam, queimadura mantém o violeta, aro do círculo mais fino, lascas alongadas | `491c6d4`, `1d06613` | `docs/gallery/c12d/work/vx01_corte_antes_depois.jpg`; vídeos `comparacao_*_0_25x.mp4` |
| QW-016 | Galeria de game feel antes e depois | `efa5cf4` | `docs/gallery/c12d/after/`, `AFTER.md` |
| Ravenswatch | Terceira referência (só princípios) | `2b5647d` | `benchmark_ravenswatch.md` |
| UI-03 | Carta de escolha nova (`BoonCard`, arte em cima, nome marfim, família ou origens do Elo, ação, nível, raridade, regra de ouro velho, descrição); medalhões pintados de `vapor`, `aurora`, `redemoinho` (`BoonArt`) | `262f99b` | `docs/gallery/boon_cards/` (olhei `ill_1080.jpg`: lê bem; ver BUG-017) |
| UI-04 | Tela cheia por padrão (saves antigos mudam uma vez), "Sair do jogo" na pausa no desktop | `19af96b` | `test_save.gd` |

Aceite do C12d (backlog anterior, seção 6): itens 1 a 4 e 6 passam pelo QA; o 5 passa nas capturas; **o quadro a 1080 sem
piora acima de 0,3 ms segue sem medida válida** (M-a). O plano do C12d está no histórico (`1e25f21:docs/backlog.md`).
### C12c "Qualidade da experiência" (`beb6c27`, medido no QA-02 `71cb8cc`)

| ID | Item | Estado | Prova |
|---|---|---|---|
| GP-01 | Colunas e gemas abaixo do glow; Morvath entra sem coluna | **em parte**: entrada de Morvath passa (corpo 45 aos 0,5 s, sem coluna); gemas com cor de volta mas canal dominante 255; colunas da recompensa e da fonte **255 na tela** (A-1, em correção) | `cycle12c/AFTER.md` GP-01; `after/coluna_recompensa_criptaA.jpg`, `coluna_fonte.jpg`, `morvath_entrada_0_5s.jpg` |
| GP-02 | Registro v2 (`source`, `boons_at_boss`, `shop`, `fountain_used`, `hurt_ctx` com `warn_s`, `dash_ready`, `offscreen`; por sala `variant`, ouro, dons, esquivas, golpes, tiros, `blocked_by`) | feito | QA-02 item 6; `after/descida_run.jsonl` |
| GP-03, GP-04 | `resolve` acha o lugar livre mais perto; cercado nos corredores mais estreitos, 16 de 16 esquivas saem | feito | `beb6c27`; testes |
| GP-05 | Limitador -1 dB no `Master` | feito | pico -2,94 dBFS na descida com som (QA-02 item 5) |
| GP-06 | `--trace-cam`; alvo da câmera a no máximo 24 m/s | feito | maior salto 0,400 m em 46 salas (antes 2,9 m) |
| (QA-01) | Aviso no chão não fere depois da sala vencida | feito | `after/sem_dano_apos_sala_vencida.jpg` |
| UI-01, UI-02 | `DoorSign` (18 px a 1080, contraste 12:1); derrota com sala, arena e dons | feito | `work/ui_after_doors_1080.jpg`, `ui_after_end_1080.jpg`, `tests/test_end_screen_run.gd` |
| ENV-01 | Chão da Cripta na luta 45 a 60 | **em parte**: mediana 30 para 43,5, 4 de 8 recortes no alvo; oeste e norte 19 a 34 (M-1) | `after/crypt_vA_c_recortes.jpg`, `crypt_vB_c_recortes.jpg` |
| ENV-02 | Fraturas da árvore até 200 | feito (máximo 198) | `AFTER.md` ENV-02 |
| ENV-03 | Jardim no Compatibility (sem sombra da lua) | feito pelo `environment-artist`, não remedido pelo QA | `work/env_garden_compat_antes_depois.jpg` |
| ART-R1 | Fendas reconferidas (F-1 a F-3, F-5, F-6, G-1 passam; F-4 dois pontos abaixo) | feito; D-38 sem objeto | `4d281bc` |
| QA-01, QA-02 | Linha de base e medidas depois, vídeo de descida com som a 1080 (DT-004), 11 vídeos de game feel | feito | `c5798a8`, `71cb8cc`; `docs/gallery/cycle12c/`, `docs/gallery/game_feel/` |
| GF-R | Game Feel Review: medidas (`74af372`), revisão visual (`f07549f`), vídeos (`71cb8cc`), revisão oficial | feito | `docs/design/game_feel_review.md` |

Aceite do C12c (roadmap D): itens 1, 2, 4, 5, 6, 7, 8, 9 passam; **3 não passa** (colunas, A-1) e o 3b passa em parte
(M-1). O C12c fecha quando o A-1 entrar com captura na GPU; o M-1 pode fechar por aceite do `art-director` (cantos
escuros de propósito, aceite só no terço central) ou por correção.

### C12b "Fecho das Fendas" (2026-11-16)

| ID | Item | Commit | Prova |
|---|---|---|---|
| F-1 a F-5 | Paredes da fenda escuras com bruma violeta abaixo (`rift_haze.gdshader`), bordas quebradas com pedras caídas, pontes com lajes próprias, meio-fio, parapeito vazado, pilares de canto e pegões, lua como luz principal | `87ba686` | `work/fix_rift_vA_antes_depois_cenario.jpg` (olhado: a fenda lê como rasgo com pontes); medidas de aceite a reconferir pelo `art-director` (ART-R1) |
| F-6 | Inscrições fracas entre a fenda e o buraco | `87ba686` | idem |
| G-1b | Ar do Compatibility nas Fendas | `87ba686` | `work/fix_rift_vA_compat_vs_forward.jpg` |
| D-39 | O Daniel confirmou: mecânicas e números do Hades II fielmente, nomes, personagens, UI e arte de Eterra | conversa de 2026-11-16 | `docs/design/roadmap_plan.md` |

### C12a2 "Medir certo" e C12 "Arenas I" (2026-11-16)

| ID | Item | Commit | Prova |
|---|---|---|---|
| BUG-014 | "Derrotado por" e `boss.hurt_by` com o golpe que matou (`Player.was_hurt` antes de `died`) | `f25ae5f` | `tests/test_killing_blow.gd` |
| QW-011 | `RESULT` e `runs.jsonl` com `rooms` (`depth`, `layout`, `hp_in`, `hurt_by`, `time`, `contact`), `hp_at_boss`, `arena`, `stuck`, `stuck_by`, `shots_blocked` | `f25ae5f` | `core/room_tally.gd`; `METRICAS.md` seção 1 |
| QW-013 | Vida ao entrar no chefe na métrica do robô | `fd72101` | `METRICAS.md` seção 2: `hp_at_boss` 12 a 53, mediana 24, 8 descidas |
| DT-008 | Momento do pico do passo: `--trace-steps`; os picos de 5 a 12 ms caem num sistema diferente a cada vez, fora de custo próprio (interrupção da máquina) | `f25ae5f` | `METRICAS.md` seção 3; o que sobrou virou QA B-1 |
| BUG-015 | Tiros param em pedra acima de 1,25 m, com faísca; ramo rasteiro do sacerdote para em tudo que barra corpo | `f25ae5f` (C12-F4) | testes em `test_arenas.gd`; 1,1 a 1,3 tiros barrados por luta na Cripta |
| BUG-016 | Nascimento por zonas com caminho; limite dos tiros pela sala real | `f25ae5f` (C12-F5) | `test_arenas.gd`; 0 preso em 192 lutas |
| C12-F1 a F9 | `RoomLayout` estendido, `FloorShape.POLY` com buracos, `Arena.sweep`, `NavGrid` e `FlowField`, linha de tiro, nascimento e saídas, `cam_bounds`, robô com caminho, escolha da arena sem repetir, `--arena`, `--variant`, `tools/arena_lab.gd` | `f25ae5f` | 455 testes no commit; QA seções 2 e 3 |
| C12-A0 | Salão das Catacumbas como arena (abertura, fonte, loja; `--arena=hall`) | `f25ae5f` | `METRICAS.md` seção 5 (5,09 ms) |
| C12-A1 | Cripta dos Esquecidos, 2 variantes | `e2297ee`, `95c29c6` | `cycle12_maps/crypt/`; aprovada na `ART_REVIEW.md` |
| C12-A2 | Salão das Fendas, 2 variantes | `e2297ee` | `cycle12_maps/rift/`; arte corrigida no `87ba686` (C12b acima) |
| C12-A3 | Jardim das Raízes Mortas com a árvore petrificada (D-30) | `91cc656`, `95c29c6` | `cycle12_maps/garden/`, `work/garden_grid_a`; aprovado |
| D-27 | Descida de teste de 7 salas (`--short` volta à de 5) | `f25ae5f` | `test_descent.gd` |
| D-28 | Golpe empurra até a borda, ninguém cai | `f25ae5f` | `Arena.sweep`; 0 corpo fora do chão |
| D-33 | Nome da arena por 2 s ao entrar (`Hud.show_place`, chaves `arena_*`) | `f25ae5f` | `vX_b_explorador.jpg` |
| D-34 | Estandartes com o leão no salão e nas arenas (a câmara segue com a espada) | `501f3d8` (spec), `e2297ee` | `ArenaKit.Emblem.LION`, `banner_lion.gdshader` |
| C-1 a C-4 | Tampa do túmulo no valor da pedra sob facho 1,6; capitéis e aduelas; degraus no valor da cantaria; lápides | `95c29c6` | `work/fix_crypt_antes`/`_depois` |
| J-1 a J-4 | Cristais esmeralda corrompido escuro; casca torcida com grão, líquen e fraturas, tronco 1,16 a 1,22 do chão; raízes com dois lombos e pontas abertas; capim | `95c29c6` | `work/fix_garden_arvore_antes_depois` (olhado: os cristais deixaram de competir com a Emeth) |
| G-1 (Cripta e Jardim) | Compensação do Compatibility por sala (`COMPAT_*`) | `95c29c6` | `work/fix_crypt_compat`, `fix_garden_compat`; **as Fendas ficaram de fora** (G-1b abaixo) |
| DT-004 (parte) | Vídeo de travessia por arena (20 s, 1280 x 720, sem som) | `fd72101`, `95c29c6` | `cycle12_maps/*/travessia.mp4`; o vídeo da luta com som segue aberto |

### Antes (histórico)
- C12a da madrugada (BOSS-001 a 003, QW-006 a 008, BUG-010 a 012, DT-007, D-24), atiradores do Hades II (`da35721`,
  `c666f4a`), teste T1 do Daniel: ver `752ceee:docs/backlog.md`.
- C10 e C11 (BUG-001 a 009, QW-001 a 005, ART-001, ART-003 a 009, Câmara do Selo): `fa30024:docs/backlog.md`.

---

---

## 1. Bugs

Nenhum crítico, nenhum alto aberto (QA do C12d). O que pesa agora é um bug latente que só morde quando a progressão
permanente entrar (DT-012, seção 3) e uma cópia errada do Hades II no Elo.

### Médio

| ID | Título | Evidência | Esforço | Responsável | Estado | Pronto quando |
|---|---|---|---|---|---|---|
| M-a | Tempo de quadro do C12d na placa sem medida válida (notebook na bateria; 2º passe dos avisos e shaders novos do corte) | QA `efa5cf4` seção 4 e 6 | P | `qa-performance` | aberto | base `6f9bbc7` e HEAD alternados na tomada, 5 arenas a 1080, diferença até 0,3 ms ou causa apontada |
| BUG-017 | O Elo tem raridade e nível (a carta mostra "Vapor, Novo, Épico"); no Hades II o duplo não sobe com romã e não tem multiplicador de raridade (cópia errada pela D-39) | `docs/gallery/boon_cards/ill_1080.jpg`; `BoonState.take` dá raridade a qualquer Bênção; `hades2_sistemas.md` seção 3 | P | `gameplay-engineer` | aberto, vai para a E3 (muda número: Elos ficam mais fracos) | Elo sempre com o número do nível 1 e sem raridade; carta sem "Novo, Épico" no Elo; teste |
| M-1 | Cantos oeste e norte da Cripta com chão 19 a 34 na luta | QA-02 M-1; `cycle12c/after/crypt_vA_c_recortes.jpg` | P | `environment-artist` ou aceite do `art-director` | aberto (C12e) | recortes com 45 ou mais, ou aceite escrito só para o terço central |
| A-1, B-1 (prova) | O `6f9bbc7` diz que corrigiu as colunas e gemas; nenhuma captura do QA depois | QA `efa5cf4` "abertos de antes" | P | `qa-performance` | aberto | recorte (915, 120, 90 x 330) até 235 na captura da placa |
| QA M-1 (antigo) | Referência `04` em tamanho cheio no histórico | backlog anterior | P | Daniel (D-37) | aberto | D-37 tomada |

### Baixo

| ID | Título | Evidência | Esforço | Responsável | Estado | Pronto quando |
|---|---|---|---|---|---|---|
| B-b | Com vsync a esquiva aparece um quadro composto (7 ms) depois do andar e do golpe | QA `efa5cf4` B-b; `after/latencia/` | P | `gameplay-engineer` | aberto | primeiro quadro da esquiva desenhado no quadro do aperto, ou razão escrita |
| B-c | A linha `RESULT` não é JSON válido (`boss.attacks` com chaves `&"scythe"`) | QA `efa5cf4` B-c | P | `gameplay-engineer` | aberto | `JSON.parse` do `RESULT` de `--start=boss` sem erro; teste |
| B-2 | O robô nunca usa a fonte | QA-02 e QA do C12d (0 de 8) | P | `gameplay-engineer` | aberto (C12f) | `fountain_used: true` em 6 de 8 descidas que entram com menos de 60% |
| B-3 | Limitador no teto em 67 janelas de 0,1 s | QA-02 B-3 | P | `gameplay-engineer` | aberto, mixagem (E6) | pico e LUFS da mixagem |
| B-d | `tools/boon_card_view.gd.uid` fora do commit | `git status` no `19af96b` | P | sessão principal | aberto | no próximo commit |
| B-1 (antigo) | Pico do passo acima de 2 ms em poucos quadros | backlog anterior | P | `gameplay-engineer` | aberto | p99 abaixo de 2 ms |
| BUG-013 | Comando da investida na spec da câmara | backlog anterior | P | `art-director` | aberto | spec com `--bot-kite=1` |

---
## 1a. Game Feel e Excelência Visual (GF, VX)

Estado em `19af96b`: os itens do C12d estão feitos (marcados abaixo, prova na seção 0). Abertos: GF-12, GF-15 e VX-04 a
VX-07, VX-13 a VX-17, todos na E1 (C12e e C12f).

Origem: `docs/design/game_feel_review.md` (área e evidência de cada item), `game_feel_measures.md` (propostas A a L),
`visual_review.md` (V-*). Campos: ID, ciclo, prioridade, descrição, problema, valor para o jogador, aceite, dependências,
responsável, estado, evidência. "Sonda" = `~/tools/godot/godot --headless --path . --fixed-fps 60 -s
tools/feel_probe_run.gd -- --nosave --start=fountain` (`PROBE=_s_x` roda um cenário). Tipo: **cópia** (errada ou que
faltou do Hades II, corrige sem perguntar), **bug**, **arte** (direção já aprovada), **Daniel** (decisão aberta).

### Game feel (GF)

| ID | Ciclo | P | Descrição | Problema | Valor para o jogador | Aceite | Dependências | Responsável | Estado | Evidência |
|---|---|---|---|---|---|---|---|---|---|---|
| GF-14 | C12d | P0 | Sonda com metas: a `feel_probe` imprime uma linha `FEEL <meta> ok/falha` por meta deste ciclo e um `FEEL_SUMMARY n/m` | hoje a sonda imprime quadros, não diz se passou | aceite do ciclo verificável por qualquer agente | rodada no HEAD antes das mudanças mostra as falhas esperadas (GF-01 a GF-08); a mesma rodada no fim mostra todas ok | nenhuma (roda primeiro) | `qa-performance` | **feito** (`3fc721b`) | `tools/feel_probe.gd` |
| GF-02 | C12d | P0 | Esquiva corta a preparação (`ComboRunner.can_cancel` também no WINDUP) e o aperto da esquiva entra no buffer | aperto some (cópia: o Hades corta a carga) | "apertei e esquivou", sempre | `_s_dodge_cancel`: nenhum `LOST`; golpe cortado não dá dano; teste GUT | nenhuma | `gameplay-engineer` | **feito** (`4c560eb`) | medidas tabela 3 e 5, problema 2 |
| GF-03 | C12d | P0 | Ler ataque e especial durante a esquiva e o golpe sofrido; soltar o golpe da esquiva no fim dela; aperto no último quadro vale | ataque some nos quadros 1 a 13 (cópia: `DashAttackQueue`) | ataque e esquiva encadeiam como no Hades | `_s_attack_in_dodge` e `_s_extra`: aperto nos quadros 1 a 13 vira golpe da esquiva no 13 ou 14; `_s_hurt`: aperto guardado sai no 11 | nenhuma | `gameplay-engineer` | **feito** (`4c560eb`) | problema 3, tabela 4 |
| GF-04 | C12d | P0 | Buffer contado do momento em que o golpe pode sair (trava de gatilho), não do aperto | apertos nos quadros 1 a 3 do golpe 1 e nos 32 primeiros do giro somem | combo sem aperto perdido | `_s_buffer`: o 2º aperto vale em qualquer quadro do golpe 1 e do giro; `tests/test_combo.gd` estendido | nenhuma | `gameplay-engineer` | **feito** (`4c560eb`) | tabela 4 |
| GF-01 | C12d | P0 | Hit stop no molde do Hades: por golpe a espera (25, 65, 70, 50 ms), a fração (6%) e a lentidão (10 ms; +40 com abate), volta em 20 ms; em tempo real, por `Engine.time_scale`; dados no `ComboNode` gerados pelo `make_data.gd` | congelamento inteiro a partir do quadro seguinte | o golpe morde sem grudar; o clarão e o empurrão aparecem | `_s_attack_hit`, `_s_combo_on_hit`, `_s_kill`: 0 quadros `stepped=false` por hit stop; 1 a 3 quadros a 6% depois da espera; teste GUT da agenda | nenhuma | `gameplay-engineer` | **feito** (`4c560eb`) | problema 1, tabela 7 |
| GF-05 | C12d | P0 | `Fx.tick` desconta o hit stop em tempo real; a câmera lenta de vários abates só começa quando o hit stop acaba | 0,28 s de tela congelada | a câmera lenta se vê | `_s_kill` (3 abates): no máximo 3 quadros parados, depois `time_scale` 0,2 com `stepped=true` | GF-01 | `gameplay-engineer` | **feito** (`4c560eb`) | problema 5 |
| GF-06 | C12d | P1 | `VirtualPad` guarda os toques até o jogo andar (como o `_latched` do teclado) | o robô e o toque perdem apertos | métricas do robô sem esse viés; toque futuro | `_s_hitstop_buffer`: `pad` sai como `keyboard` | nenhuma | `gameplay-engineer` | **feito** (`4c560eb`) | problema 9 |
| GF-07 | C12d | P1 | Seta: trava de ataque 18 quadros após o disparo, recarga própria 0,7 s, dardo 62,5 m/s (a parada das pernas de 0,71 s espera a D-44) | trava 35 quadros, dardo a 30 m/s | especial deixa de travar o combo | `_s_special`: golpe no quadro 25, especial no 48 | D-44 só para a parada | `gameplay-engineer` | **feito** (`4c560eb`) | problema 7, tabela 5 |
| GF-08 | C12d | P1 | Ômega do ataque acerta ao encher (brilho dentro da carga) | acerta 0,14 s depois | o Ômega sai quando a barra enche | `_s_omegas`: acerto no quadro 48 | nenhuma | `gameplay-engineer` | **feito** (`4c560eb`) | problema 10 |
| GF-09 | C12d | P2 | Pequenos fiéis: direção instantânea e corpo a 1340 graus/s; botões lidos antes de andar (planta no quadro do aperto); proteção da esquiva 19 quadros desde o aperto; Ômega do especial conferido contra `ProjectileStaffBallCharged` | divergências sem razão escrita | virada e golpe mais limpos | `_s_turn`: direção a 180 no quadro 1, corpo em até 8 quadros; `_s_walk_cancel`: `walked 0:0.00`; `_s_dodge`: `inv` até o quadro 18; tabela do Ômega do especial no `game_feel_measures.md` preenchida | nenhuma | `gameplay-engineer` | **feito** (`4c560eb`) | problemas 13, tabela 10 |
| GF-10 | C12d | P1 | Impacto seco: tranco e tremor dos golpes comuns na escala do Hades (0,05 a 0,1 m); clarão do inimigo 0,05 s com o 1º quadro visível; o que fica maior nos finalizadores e no Ômega o `art-director` fixa pelo vídeo | tranco 6 a 11 vezes o do Hades; clarão 0,14 s | golpe legível, avisos não tremem | sonda `_s_attack_hit`: `kick` até 0,1 m no golpe 1, `flash_t` 0,05; vídeo (c) antes e depois aprovado pelo `art-director` | GF-01 | `gameplay-engineer`, `art-director` | **feito** (`4c560eb`) | problemas 8 e 12 |
| GF-11 | C12d | P1 | Som de lâmina no disparo de cada golpe (não só se erra), som de carga no giro e nos Ômegas; vibração por golpe no controle (`Input.start_joy_vibration`), com opção no Conforto | 0,37 s mudos no giro; sem vibração | o golpe se ouve antes de acertar | teste do `Audio`: todo `ComboNode` tem som de disparo; vídeo (b) com som mostra o som no quadro do disparo; opção de vibração salva | nenhuma | `gameplay-engineer` (sons provisórios CC0 ou síntese), `ui-ux-designer` (opção) | **feito** (`4c560eb`, `aaaacfc`) | problema 11 |
| GF-13 | C12d | P1 | Latência de ponta a ponta na placa (vsync ligado e desligado): aperto marcado e quadros até o primeiro pixel mudar | só a lógica foi medida | saber se o vsync atrasa | número em ms por ação (andar, golpe, esquiva) no relatório do QA | nenhuma | `qa-performance` | **feito** (QA `efa5cf4`) | medidas, "Como foi medido" |
| GF-12 | C12f | P1 | Reação ao golpe dos comuns sem armadura no molde do Hades: atordoamento curto, para de andar, interrompe a preparação, por inimigo (`EnemyDef`, imune no próprio ataque como no Hades) | o golpe não muda o comportamento de ninguém | acertar faz diferença; leitura de controle da luta | teste GUT: esqueleto acertado na preparação não ataca; robô 0,25 em 8 descidas antes e depois | **D-42** | `gameplay-engineer` | proposta | tabela 8, problema 6 |
| GF-15 | C12e | P2 | Arranque e parada animados (clipes curtos só no desenho) | sem peso visual ao arrancar e parar | corpo com peso sem atraso | sonda `_s_move` igual (velocidade cheia no quadro 0); vídeo (a) antes e depois | nenhuma | `gameplay-engineer` (`tools/bake_hero.gd`) | aberto | tabela 2 |

### Excelência visual (VX)

| ID | Ciclo | P | Descrição | Problema | Valor para o jogador | Aceite | Dependências | Responsável | Estado | Evidência |
|---|---|---|---|---|---|---|---|---|---|---|
| VX-01 | C12d | P0 | Fita do corte comum presa à lâmina: corpo em tinta escura translúcida (alfa até 0,6), borda de ataque fina marfim-menta, verde pálido (saturação até 0,45); começa na ponta da Emeth no quadro do golpe e varre com ela 2 a 3 quadros | folha verde opaca a 2 ou 3 m da lâmina | o corte lê como luz da espada | `--shot-on=hit --shot-after=0.033`: menos de 15% dos pixels da fita com saturação acima de 0,6; ponta a menos de 0,5 m da ponta da Emeth; vídeo (g) antes e depois | nenhuma | `environment-artist` (`slash.gdshader`, `slash_ink.gdshader`), `gameplay-engineer` (o encaixe na lâmina em `fx.gd`/`combat.gd`) | **feito** (`491c6d4`, `1d06613`) | V-E1; `g_combo_finalizador_0_25x.mp4` 4,5 a 6,5 s |
| VX-02 | C12d | P0 | Brilho do finalizador fora do corpo: anel até 0,6 da altura do herói, centro na ponta da espada, cruz com miolo transparente | o anel cobre o herói 5 a 6 quadros | herói sempre legível | no quadro do brilho, nenhum pixel do anel com alfa acima de 0,5 sobre a caixa do corpo do herói | nenhuma | `environment-artist` (`glint.gdshader`), `gameplay-engineer` (`Fx.GLINT_SIZE` e a posição) | **feito** (`491c6d4`) | V-E2; `g_acertos_reacao_0_25x.mp4` 7,4 a 8,4 s |
| VX-03 | C12d | P0 | Avisos em linha e retângulo: preenchimento até 0,35 que sobe só nos últimos 30% do preparo; sobreposição pelo máximo, não pela soma; borda e divisa como estão; tempo, área e assinatura de Morvath iguais | massa vermelha sob o herói em grupo | escolher a saída dentro de três avisos | três avisos sobrepostos não passam do alfa de um cheio; anel do herói visível dentro deles; `test_storm_wedge.gd` e testes de aviso passando | nenhuma | `environment-artist` (`ground.gdshader`, `ground_look.gd`) | **feito** (`491c6d4`) | V-L1; `d_especial_circulo_omegas.mp4` 0:01 a 0:02 e 0:10 a 0:15 |
| VX-08 | C12d | P1 | Morvath e guardiões mantêm a cor queimando: borda de fogo até 0,25, brasas pela metade | manto violeta vira laranja | o chefe sempre lê como ele | no meio da fase 3 queimando, mediana do manto com matiz 260 a 300 | nenhuma | `environment-artist` (`crowd.gdshader`, só o ramo da queimadura) | **feito** (`491c6d4`) | V-M2; `f1_morvath_despertar.mp4` por volta de 0:07 |
| VX-09 | C12d | P1 | Aro do círculo de luz com alfa até 0,45, metade da espessura, traços finos | lê como marca de interface por cima dos corpos | zona clara sem cobrir os inimigos | esqueleto em pé sobre o aro com os pés legíveis na captura | nenhuma | `environment-artist` (`ground.gdshader` estilo CIRCLE) | **feito** (`491c6d4`) | V-M1 |
| VX-10 | C12d | P2 | Lascas alongadas na direção do corte (2:1 a 4:1), marfim a cinza, vida até 0,25 s | pontos brancos redondos 10 ou mais quadros no ar | impacto sem sujeira | nenhuma lasca visível 8 quadros depois do golpe | nenhuma | `environment-artist` (`impact.gdshader`), `gameplay-engineer` (vida das lascas em `fx.gd`) | **feito** (`1d06613`) | V-E3 |
| VX-11 | C12d | P0 | Sem marcador `PALADIN_n` para o jogador: a linha "dom de X" some até o Daniel dar os nomes (sem inventar nome) | bug visível na carta | texto limpo | teste que monta cada carta e não acha "PALADIN" | nenhuma | `ui-ux-designer` | **feito** (`aaaacfc`) | V-U1 |
| VX-12 | C12d | P2 | Contador de golpes até 48 px a 1080, nome do golpe com alfa 0,7 | compete com a luta | olho na luta | captura a 1080 medida | nenhuma | `ui-ux-designer` | **feito** (`aaaacfc`) | V-U3 |
| VX-04 | C12e | P0 | Multidão e Morvath sem saltos: mais poses (andar 20 a 24, ataque 14 a 16, golpe sofrido 8, parado 12, morte 16) e mistura entre a pose atual e a seguinte no vértice; medir memória e quadro | 10 poses por ciclo sem mistura, stop motion ao lado do herói | inimigos vivos | vídeo a 30 qps: nenhum inimigo andando repete a pose em 2 quadros seguidos; pacote dos assados medido; quadro sem piora acima de 0,3 ms | nenhuma | `environment-artist` (`tools/bake.gd`), `gameplay-engineer` (`crowd_renderer.gd`, `crowd.gdshader`), `qa-performance` | aberto | V-A1; `crowd_renderer.gd:242` |
| VX-05 | C12e | P1 | Passo do andar medido por clipe no assado e guardado no `BakedModel` | `clip_rate` genérico, pé deslizando | pés no chão | pé de apoio desliza menos de 5 cm por passo no `enemy_lab` | VX-04 | `environment-artist`, `gameplay-engineer` | aberto | V-A2 |
| VX-06 | C12e | P1 | Recuo visível: golpe sofrido com 8 poses e deslocamento de 0,15 a 0,3 m que se vê em 3 quadros | recuo invisível | o golpe se vê no corpo | `--shot-on=hit` + 6 quadros: o alvo se desloca e volta | VX-04; GF-12 se a D-42 aprovar | `gameplay-engineer` | aberto | V-A3 |
| VX-07 | C12e | P1 | Armas do KayKit, paliativo no assado: ferro escuro e osso sem listras, cutelo até 0,6 do tronco, gancho de Morvath em ouro velho (matiz 35 a 45, saturação até 0,5) | outro estilo colado em figuras pintadas | inimigos coerentes | `enemy_lab`: nenhuma arma em faixas de duas cores; gancho medido | nenhuma (o final é D-46) | `environment-artist` (`tools/bake.gd` `held`) | aberto | V-P1 |
| VX-13 | C12e | P2 | Metade dos grupos de velas da borda leste e sul do salão apagados | quente por toda a borda | quente como acento | fração de pixels quentes saturados na vitrine pela metade, chão acima de 45 | nenhuma | `environment-artist` | aberto | V-C1 |
| VX-17 | C12e | P2 | Pose final do finalizador como carga (o corpo recua 5 a 10 cm, o brilho cresce desde o começo) | lê como parada | antecipação clara | `g_combo` antes e depois aprovado pelo `art-director` | VX-02, GF-01 | `gameplay-engineer` | aberto | V-A4 |
| VX-14 | C12f | P1 | Clipes de Morvath mais pesados (UAL CC0: golpe de duas mãos para a foice, lançamento para a tempestade) | ataques são golpes genéricos | o chefe tem presença | vídeo por fase antes e depois aprovado pelo `art-director`; `test_boss*.gd` com os mesmos tempos de aviso | VX-04 | `gameplay-engineer` (`tools/bake.gd` bloco de Morvath, tempos) | aberto | V-A5 |
| VX-15 | depois | P3 | Peças próprias de cenário (velas, balaustradas, sarcófagos), ícones de dom por família, retrato do medalhão a partir do Explorador | KayKit ao lado de pintura; ícones genéricos; retrato de outro estilo | identidade | spec do `art-director` por família | D-46 (Meshy), arte 2D | `art-director`, `environment-artist`, `ui-ux-designer` | proposta | V-C2, V-M3, V-U2 |
| VX-16 | depois | P3 | Gema do cajado do mago até 235 | estoura branco | | `enemy_lab` | nenhuma | `environment-artist` | aberto | V-P2 |


## 1b. Itens priorizados do C12c em diante (formato completo)

Campos: ID, ciclo, prioridade (P0 a P3), descrição, problema, valor para o jogador, aceite, dependências, responsável,
estado, evidência. Planejamento e justificativas em `docs/design/roadmap_plan.md`. Nada do C12c muda número de combate.

### C12c "Qualidade da experiência"

Fechado na seção 0 (estado de cada item com a prova do QA-02). Abertos que ficaram: A-1 (em correção), M-1, B-1 a B-3
(seção 1). As hipóteses A, B, D e F seguem pedindo teste humano; o registro v2 (GP-02) já as mede.

### C13 "Progressão e rejogabilidade": **movido inteiro para a E3 "Bênçãos e combinações"** (seção 6; números do Hades II pela D-39; "dom" aqui é Bênção)

| ID | P | Descrição | Problema | Valor | Aceite | Dependências | Responsável | Estado | Evidência |
|---|---|---|---|---|---|---|---|---|---|
| C13-01 | P1 | Descida de 10 salas e Morvath na 11 por padrão; a de 7 e a de 5 por opção; arenas sem repetir seguidas, nenhuma mais de 3 vezes | 3 dons em Morvath | partida de 10 a 13 min com curva | robô 0,25 chega com 5 a 8 dons em 6 de 8; `test_descent.gd` | teste final do C12c | `gameplay-engineer` | aberto | DT-001; `runs_antes_ciclo12.jsonl` |
| C13-02 | P1 | Baralho de recompensas do Hades II no lugar dos pesos | variedade sem repetir | portas mais interessantes | teste do baralho (sem reposição, reabastece) | C13-01 | `gameplay-engineer` | aberto | `hades2_sistemas.md` "achado" |
| C13-03 | P1 | Raridade em sequência; guardião sem heroica | `RARITY_WEIGHT_GUARDIAN` diferente do Hades | fidelidade (D-39) | teste com 10 mil sorteios dentro de 1 ponto das chances | | `gameplay-engineer` | aberto | idem |
| C13-04 | P1 | Ouro por inimigo (70%, teto 10 a 15 + 0,5 por profundidade), recompensa 100, loja em 3 grupos, cura 50 | loja inútil (37 de ouro, mínimo 60) | a loja vira escolha | robô compra na loja em 6 de 8 | C13-01 | `gameplay-engineer`, `ui-ux-designer` (loja) | aberto | vídeo 2:02; `_stage` `shop_prices` |
| C13-05 | P1 | Romã com ganho fixo por nível (`base`, `per_level`), 32 dons migrados | | dons que crescem | testes por dom | | `gameplay-engineer` | aberto | `hades2_sistemas.md` seção 1 |
| C13-06 | P2 | Elo com 12% por carta | | | teste de sorteio | C13-02 | `gameplay-engineer` | aberto | seção 3 |
| C13-07 | P2 | Bônus de sequência de golpes fora (D-10) | não existe no Hades II | fidelidade | `DamageCalc.combo_bonus` desligado e testado | D-10 | `gameplay-engineer` | proposta | comparativo, Dons |
| C13-08 | P1 | Métricas do C13: dons e ouro por sala no registro, 8 descidas longas | | | `METRICAS.md` do ciclo | GP-02 | `qa-performance` | aberto | |

### C15 "Som e polimento" e C14 "Arenas II": C15-03 e C15-05 vão para a E4 (música dos Salmos), C15-01 e C15-04 para a E6, C14 para a E5 (seção 6)

| ID | Ciclo | P | Descrição | Aceite | Responsável | Estado |
|---|---|---|---|---|---|---|
| C15-01 | C15 | P2 | Mixagem por barramentos, ducking nos avisos de Morvath | pico até -1 dBTP; integrado -18 a -14 LUFS | `gameplay-engineer` | aberto |
| C15-02 | C15 | P2 | Som em toda ação, aviso e ataque de Morvath | teste que acusa evento sem som | `gameplay-engineer`, `art-director` | aberto |
| C15-03 | C15 | P2 | Música de combate e de Morvath por fase (CC0, CC-BY ou síntese, D-12b) | nenhum silêncio de 2 s com música ligada | `art-director`, Daniel (fonte) | aberto |
| C15-04 | C15 | P2 | Ambiência por arena | idem | `environment-artist` | aberto |
| C15-05 | C15 | P2 | `audio/LICENSES.md` e créditos | toda fonte listada | `ui-ux-designer` | aberto |
| C14-A4 a A6 | C14 | P2 | Santuário, Ponte, Runas (D-29), cada uma com uma decisão de combate própria | testes do C12 e decisão medida | `environment-artist`, `gameplay-engineer`, `art-director` | aberto |

---


---

## 2. Quickwins

| ID | Título | Evidência | Impacto | Esforço | Responsável | Prioridade | Pronto quando |
|---|---|---|---|---|---|---|---|
| QW-014 | **Entregar o T3 agora** (a versão do C12d com a carta nova e a tela cheia) | QA `efa5cf4`: "pronto para o Daniel testar"; D-45 | o único dado de gente sobre a mão nova antes do C12e | P | sessão principal | P0 | `ASelagem.exe` do `19af96b` (ou do commit desta revisão) em `Downloads\ASelagem-3D` e `ASelagem-teste`; `runs.jsonl` antigo guardado com outro nome; roteiro da seção 5 |
| QW-018 | "Bênção" no texto (opção (a) da D-50): cerca de 15 valores em `text_pt.tres`, gênero das raridades ("Rara, Épica"), sem mexer em chave, classe nem registro | `guardian_spec.md` 1.1; chaves `choice_title`, `choice_hint`, `reward_boon`, `reward_pom`, `end_boons`, `end_gifts`, `pause_boons`, `boons_title`, `boons_none`, `boon_rest_desc`, `boon_aurora_desc`, `boon_chama_viva_desc`, `howto_pause_desc`, `rarity_*` | o Daniel já testa com o termo novo | P | `ui-ux-designer` | P0 se a D-50 vier antes do T3; senão primeira tarefa da E2 | teste que procura " dom"/"Dom" nas chaves de tela e só acha as de Dom; `title_flow_check` ok |
| QW-019 | M-a: remedir o quadro na tomada | QA `efa5cf4` | fecha o aceite do C12d | P | `qa-performance` | P0 | ver M-a |
| QW-020 | B-c: `RESULT` em JSON válido | QA B-c | o QA e o diretor leem por script | P | `gameplay-engineer` | P1 | ver B-c |
| QW-015 | Ler o T3 por roteiro fixo (registro v2) | GP-02 | separar "injusto" de "não reagiu" | P | `qa-performance` | P0 depois do T3 | tabela por sala do T3 ao lado da do robô 0,25 |
| QW-012 | Teste humano dos atiradores | nunca jogado por gente | | P | Daniel | dentro do T3 | 3 partidas no registro |

---

## 3. Dívidas

### DT-012 O save perde dicionários de chaves livres (feito)
- **Evidência**: `scripts/core/save_data.gd` linhas 24 a 31: `merged` só copia as subchaves que existem em `defaults()`.
  Maestria (`heroes.explorer.mastery_xp`) e Compêndio (`codex.boons.<id>`) seriam apagados a cada leitura. O `moves`
  sobrevive porque é lista. **Responsável**: `gameplay-engineer`. **Esforço**: P. **Pronto quando**: `merged` preserva
  dicionários de chaves livres com tipo conferido; `test_save.gd` com arquivos fixos das versões 1, 2 e 3; `VERSION` 3.
   **Feito (E2a, fundação, 2026-11-16, worktree do `gameplay-engineer`)**: `SaveData.VERSION` 3 com `heroes.<id>` (`mastery_xp`, `unlocked`, `equipped`,
  `ultimate`, `firsts`) e `codex` (`boons`, `elos`, `psalms`, `talents`, `enemies`); heróis e entradas do Compêndio com chaves
  livres e tipo conferido; Maestria retroativa uma vez nas versões 1 e 2; `tests/fixtures/save_v1.json` a `save_v3.json`.

### DT-013 O herói é um conjunto de constantes (feito)
- **Evidência**: `player.gd` linhas 19 a 118 (`COMBOS`, `MAX_HP`, `MAGICK_MAX`, `CAST_*`), `combat.gd` 36 a 39
  (`CAST_RADIUS`, `CAST_TIME`, `CAST_BURST`). O próximo herói viraria `if`. **Responsável**: `gameplay-engineer`.
  **Esforço**: M. **Pronto quando**: `HeroDef` gerado por `_hero` no `make_data.gd` com os mesmos números; mesma semente dá
  o mesmo `RESULT` antes e depois (`tools/smoke.sh 300 --seed=5`, `120 --start=boss --boons=25 --seed=5`).
   **Feito (E2a, fundação, 2026-11-16, worktree do `gameplay-engineer`)**: `HeroDef` `warrior` (`data/heroes/warrior.tres`, `_hero`) com vida, proteção,
  esquiva (cargas e recarga, que saíram do `Feel`), Magia, círculo, passiva e ultimates; `Player`, `Combat`, `Game` e a HUD
  leem dele. Os dois `RESULT` iguais aos de antes, fora os campos de tempo (`step_ms*`, `fps`). `Player.RADIUS` ficou
  constante (lido em expressões constantes de vários sistemas).

### DT-014 Raridade e Elo fora do Hades II
- **Evidência**: `boon.gd` (pesos 85/10/5/0, `HEROIC`, guardião 0/90/7/5 com o 5 em heroica), `boon_state.gd`
  (`DUO_WEIGHT` 3, `requires` exato, Elo sobe de nível). **Responsável**: `gameplay-engineer` na E3 (C13-03, C13-05,
  C13-06, BUG-017). **Pronto quando**: os testes de `guardian_spec.md` seção 16 (`test_rarity`, `test_elo`).

### DT-015 Registro sem o herói (feito)
- **Evidência**: `run_log.gd` `FIELDS` (versão 2). **Responsável**: `gameplay-engineer` na E2a. **Pronto quando**:
  versão 3 com `hero`, `mastery_level`, `talents`, `ultimate`, `psalms`, `discoveries`; `gifts` continua (Bênçãos);
  linhas da versão 2 lidas.
   **Feito (E2a, fundação, 2026-11-16, worktree do `gameplay-engineer`)**: `RunLog.VERSION` 3 com `hero`, `xp`, `xp_by`, `mastery_level`, `talents`,
  `ultimate`; linhas antigas lidas por `RunLog.normalized`. `psalms` e `discoveries` entram quando houver Salmos (E4).

### DT-016 Dano feito por fonte não é medido
- **Evidência**: o `RESULT` tem `hurt_by` (o que feriu o herói) e `damage` total, mas não o dano por ação, Bênção, Dom ou
  ultimate. Sem isso não se balanceia a E2 nem a E3. **Responsável**: `gameplay-engineer`. **Esforço**: P. **Pronto
  quando**: `RESULT` e registro com `dealt_by` (ataque, especial, círculo, esquiva, Ômegas, cada Bênção que age sozinha,
  ultimate).

### DT-001 A descida ainda é de teste
- **Evidência**: 7 salas (D-27), Morvath aos 95 a 120 s com 3 a 4 dons pelo robô; Morvath tem 6050 de vida pensados para 6 a
  8 dons. **Responsável**: `gameplay-engineer` na **E3** (C13-01). **Pronto quando**: descida inteira (10 salas e Morvath na 11) com
  as arenas distribuídas; `--short` e a de 7 continuam por opção.

### DT-002 O robô não mede dificuldade
- Melhorou: agora anda pelo campo de fluxo e não fica preso (F7). Continua vencendo com reação 0 e sem usar cobertura de
  propósito; métrica de robô é simulação, não diversão. **Responsável**: `qa-performance`. Fica até o T2 dar números de gente.

### DT-003 Desempenho em máquina fraca nunca medido
- O Compatibility foi medido **na RTX 5060** (3,2 a 5,4 ms); placa fraca e iGPU, nunca. Para a Steam é obrigatório antes do
  C16. **Responsável**: `qa-performance`. **Pronto quando**: salão, Fendas e Jardim medidos a 1280 x 720 numa iGPU (a placa
  integrada do próprio notebook do Daniel, se ele permitir forçar) ou registrado por que não dá.

### DT-004 Vídeo da luta com som (feito)
- Feito no QA-02 (`71cb8cc`): `docs/gallery/cycle12c/after/descida_com_som.mp4` (7 salas e Morvath, 1080, com som) e os
  vídeos de game feel `f1` a `f4`. `tools/movie.sh` grava a 1080.

### DT-010 A sonda de game feel não é teste
- **Evidência**: `tools/feel_probe.gd` mede, mas nada falha quando um aperto volta a sumir. **Responsável**:
  `qa-performance` (GF-14) e depois `gameplay-engineer` (um teste GUT por regra de entrada, ver GF-02 a GF-04). **Pronto
  quando**: as regras de entrada do C12d têm teste GUT que quebra se voltarem.

### DT-011 Vídeos de game feel com roteiro fixo e vida alta
- **Evidência**: `VIDEOS.md`, limitações: roteiro com mira automática, herói com 200 ou 999 de vida, fase 4 curta. Não
  mostram pressão real. **Responsável**: `qa-performance`. **Pronto quando**: o QA do C12d regrava (a) a (g) com os
  mesmos comandos (antes e depois comparáveis) e acrescenta a fase 4 inteira com `--bot-kite`.

### DT-005 "Resources still in use at exit"
- Igual. **Pronto quando**: `tools/test.sh` e `tools/smoke.sh` sem a linha.

### DT-006 Vídeo dirigido do bloqueio de corpo
- O roteiro à mão do QA (`METRICAS.md` seção 4) cobriu a mecânica em números; falta o vídeo. Baixa prioridade.

### DT-009 Medidas de câmera da F6 nunca em número (feito: GP-06, 0,400 m)
- **Evidência**: QA, limitações: o salto do alvo entre quadros (meta abaixo de 0,5 m a 60 FPS) só foi visto nos vídeos.
- **Responsável**: `qa-performance`. **Esforço**: P. **Pronto quando**: `--trace-cam` ou sonda que imprime o maior salto
  do alvo numa travessia de cada arena.

---


---

## 4. Arenas: pendências que ficaram e o que vem

### Correções da revisão de arte que ficaram (depois de F-1 a F-5)

| # | Arena | Pendência | Prioridade depois da D-36 | Responsável |
|---|---|---|---|---|
| F-6 | Fendas | Inscrições de ouro entre a fenda e o buraco não aparecem | P3 (fidelidade) | `environment-artist` |
| G-1b | Fendas | Compatibility (ver quickwins) | P2 | `environment-artist` |
| G-2 | Fendas, Jardim | Marcos da vitrine não medidos contra a spec 6.1 | P3 (fidelidade) | `qa-performance` |
| G-3 | todas | Peças procedurais provisórias (sarcófagos, estátuas, árvore) | P3, ART-010 com Meshy se o Daniel autorizar | Daniel |
| J-5 | Jardim | Opinião minha, na `fix_garden_arvore_antes_depois`: as duas fraturas claras dos galhos quebrados saem quase brancas, o ponto mais claro da árvore; conferir que ficam abaixo do glow e no valor do marfim, não do branco | P3 | `environment-artist` |
| Densidade | Cripta, Jardim | A `05` e a `04` são muito mais cheias; aqui o chão da luta é quase vazio | P3 (fidelidade, depois do T2) | `art-director` |

### Arenas das entregas seguintes (sem mudança)

| ID | Arena | Entrega | Decisão |
|---|---|---|---|
| C14-A4 | Santuário Desmoronado (grande, casa do guardião) | 2 | |
| C14-A5 | Ponte dos Condenados (comprida, plataformas e ponte) | 2 | |
| C14-A6 | Câmara das Runas Instáveis (faixas e ladrilhos, nunca círculo) | 2 | D-29 |
| C16-A7 | Biblioteca Sepultada (estantes destrutíveis) | 3 | D-32 depois do T2 |
| C16-A8 | Reservatório das Almas (água rasa) | 3 | D-31 depois do T2 |

---


---

## 5. T3: teste do Daniel depois do C12d

**Quando**: depois do commit do C12d e do QW-014. **Quanto**: 3 partidas do título ao fim, teclado e mouse ou controle.
Substitui o "teste final do C12c" (o roteiro de 7 perguntas do `roadmap_plan.md` E continua valendo e entra junto).

### Perguntas de game feel (uma linha cada)
1. Alguma vez apertou a esquiva ou o ataque e nada saiu? Onde (no meio do combo, logo depois da esquiva, ao levar golpe)?
2. O golpe pesa? Gruda ou fica fraco? O finalizador (o giro) está no tempo certo?
3. A seta de luz e o Ômega: dá vontade de usar? Algum ficou rígido?
4. No meio de um grupo, os avisos vermelhos deixaram escolher a saída?
5. Os inimigos parecem sentir o golpe? (antes da D-42, a resposta esperada é "não": serve de linha de base)
6. Morvath: alguma coisa da foice ou da tempestade pareceu sem aviso?
7. Qualquer coisa que tenha coberto o herói.
8. A carta nova de escolha lê bem? E o nome: "dom" ou "Bênção" para a carta (D-50)?

### O que mandar
O `%APPDATA%\EterraASelagem\runs.jsonl` inteiro e as respostas. Se puder, o tempo do vídeo ou um print do que escondeu o
herói.

---


---

## 6. Próximas entregas (E1 a E6)

Ordem pela diretriz "um herói definitivo" (`roadmap_plan.md` seção 00): **E1 game feel e visual → E2 Maestria e Dons →
E3 Bênçãos e combinações → E4 Salmos e descobertas → E5 eventos e exploração → E6 balanceamento da região → C16 Steam.**
Cada entrega é uma versão MVP inteira para o Daniel testar de uma vez. A regra 0.1 do roteiro vale em todas: nenhuma
progressão nova entra antes do T4; nenhum conteúdo para esconder falta de acabamento.

### E1 "Game feel e qualidade visual" (T3, C12e, C12f, T4; 4 a 6 dias e dois testes)
- **Objetivo**: inimigos e Morvath que se movem e reagem tão bem quanto o herói, armas no estilo, combate que se ouve.
- **Por que agora**: prioridade 1 e 3 da diretriz; a mão já passou (C12d), o resto do quadro não.
- **T3 primeiro** (QW-014, seção 5). O C12e não espera a resposta do T3 para começar (não mexe na mão); o C12f espera,
  porque o atordoamento (D-42) muda a dificuldade que o T3 mede.

#### C12e "Excelência visual I: movimento e coerência" (2 a 3 dias)
- **Objetivo**: inimigos e Morvath que se movem tão bem quanto o herói e armas no estilo dos modelos.
- **Por que agora**: o maior déficit visual depois da mão (V-A1 alta: stop motion ao lado do herói); sem créditos.
- **Entregas**: VX-04, VX-05, VX-06 (o atordoamento entra no C12f), VX-07, VX-13, VX-17, GF-15, M-1, B-1 (gemas).
- **Aceite**: os de cada item; pacote dos assados medido (hoje cerca de 44 MB) e com teto escrito; quadro sem piora acima
  de 0,3 ms; vídeos (b), (c), (e), (f1) antes e depois aprovados pelo `art-director`.
- **Responsáveis**: `environment-artist` (`tools/bake.gd`), `gameplay-engineer` (`crowd_renderer.gd`, `crowd.gdshader`,
  `bake_hero.gd`), `qa-performance`, `art-director`. **Riscos**: memória e tempo de assado; mistura de pose no vértice no
  Compatibility.

#### C12f "Game feel II: inimigos, Morvath e som do combate" (2 dias)
- **Objetivo**: o golpe mudar o comportamento dos inimigos e o combate se ouvir.
- **Entregas**: GF-12 (D-42 aprovada), VX-06 completo, VX-14 (clipes de Morvath), C15-02 subido (som por ação, aviso e
  inimigo, impacto por material), B-2 (robô usa a fonte), correção do que o GF-13 e o T3 apontarem.
- **Aceite**: teste GUT do atordoamento por inimigo; 8 descidas antes e depois; teste que acusa evento de combate sem som;
  vídeos por fase de Morvath aprovados. **Riscos**: dificuldade cai com o atordoamento; medir antes de mexer em vida.

#### T4, depois do C12f: o Daniel diz se o combate está aprovado para a Fase 1 (critério 1 da definição, `roadmap_plan.md` 0).
Depois do T4: o lote do Meshy para as armas (D-46, orçamento do `art-director` por peça antes de gastar).

### E2 "O Guardião: Maestria e Dons" (depois do T4; 5 a 7 dias em três partes)
- **Objetivo**: o Guardião como herói definitivo, com progressão permanente que se sente (critério 2 da Fase 1) e uma
  arquitetura que o próximo herói reusa.
- **Por que agora**: prioridade 2 da diretriz; muda o kit, então vem antes de balancear as Bênçãos.
- **Especificação**: `docs/design/guardian_spec.md` seções 3 a 8, 12 a 14 e 16.
- **Dependências**: T4 aprovado; DT-012; D-48 (nome), D-50 (texto), D-56 (passiva), D-54 (ultimate), D-57 (Maestria),
  D-58 (Dons). Sem resposta: vale a recomendação de cada uma, com o nome "Explorador" (o do modelo) e os nomes da 1ª opção.

| ID | Parte | P | Descrição | Aceite (medível) | Responsável | Arquivos |
|---|---|---|---|---|---|---|
| E2-01 | E2a | P0 | **feito** DT-012 (save 3) e DT-015 (registro 3) | testes de `guardian_spec.md` 16 (`test_save`, `test_run_log`) | `gameplay-engineer` | `core/save_data.gd`, `core/run_log.gd`, `game.gd` (`run_entry`) |
| E2-02 | E2a | P0 | **feito** DT-013 `HeroDef` do Guerreiro (`warrior`) com os números de hoje | mesma semente, mesmo `RESULT` (smoke 300 e chefe com 25 Bênçãos) | `gameplay-engineer` | `core/hero_def.gd`, `player.gd`, `combat.gd`, `make_data.gd` `_hero` |
| E2-03 | E2a | P0 | QW-018 Bênção no texto (se não entrou no T3) | ver QW-018 | `ui-ux-designer` | `text_pt.tres` |
| E2-04 | E2a | P1 | **regras feitas** (falta a tela de fim, `ui-ux-designer`) Maestria: `MasteryCurve` pura (40 + 10 por nível), XP por fonte (seção 7.2), retroativo uma vez (D-57), XP e nível novo na tela de fim | `test_mastery`; uma partida do robô com `--runlog` grava XP certo; morte guarda XP | `gameplay-engineer` (regras), `ui-ux-designer` (tela de fim) | `core/mastery.gd`, `game.gd`, `end_screen.gd` |
| E2-05 | E2a | P1 | **dados e regras feitos** (árvore da `warrior_spec.md` 4 em `data/talents/warrior/`, 19 Dons; Fio Longo, Reserva e Firmeza já agem; os efeitos dos seis iniciais são outra tarefa) Dons de dado (níveis 1 a 7, 9 e 10 do catálogo), Devoção (5 + nível), um por ação, soma com Bênção em `BoonState.stat` | `test_talents`: custo, um por ação, soma, tags mantidas; partida com Maestria 1 e sem Dom igual à de hoje | `gameplay-engineer` | `core/talent_def.gd`, `core/boon_state.gd`, `make_data.gd` `_talents`, `data/talents/explorer/` |
| E2-06 | E2a | P1 | Tela do herói no título: nível, barra de XP, Dons (destravados, custo, Devoção livre), escolha da ultimate; teclado, mouse e controle | `title_flow_check` passa pela tela; capturas a 720 e 1080 | `ui-ux-designer` | `scripts/ui/hero_screen.gd` (nova), `title_menu.gd`, `boot.gd` |
| E2-07 | E2b | P0 | Passiva (D-56; P-A recomendada: 2 de Magia por finalizador que acerta) | teste; a Magia nunca passa do máximo; robô 0,25 em 8 descidas | `gameplay-engineer` | `combat.gd`, `player.gd`, `make_data.gd` |
| E2-08 | E2b | P0 | Ultimate U-1 (D-54): ação `ultimate` remapeável, carga pela Magia gasta (60), 5º losango com o nível de carga, gesto protegido 0,35 s, área de 6 m, 240 de dano, atordoa 1 s, som e efeito sem clarão branco | `test_ultimate`; sonda com metas novas (sai no quadro do aperto, aperto guardado no hit stop, não cobre o herói: nenhum pixel acima de 235 na caixa do corpo); não atravessa menus nem a vitória | `gameplay-engineer` (regra, entrada), `environment-artist` (efeito), `ui-ux-designer` (losango, remapear), `art-director` (aprovação) | `controls.gd`, `player.gd`, `skills.gd`, `fx.gd`, `action_slot.gd`, `hud.gd`, shaders novos |
| E2-09 | E2c | P1 | Dons de código (níveis 8 e 11 a 20) | um teste por Dom; vídeo de cada Dom de ação | `gameplay-engineer` | `combat.gd`, `player.gd`, `make_data.gd` |
| E2-10 | E2c | P2 | Ultimate U-2 (Maestria 10) | `test_ultimate` estendido; vídeo | `gameplay-engineer`, `environment-artist` | `ground.gd`, `projectiles.gd` |
| E2-11 | E2c | P2 | Compêndio pequeno: Dons e Golpes (a `MovesScreen` vira uma aba) | `test_codex` (parte); captura | `ui-ux-designer` | `scripts/ui/codex_screen.gd` |
| E2-12 | todas | P0 | QA: sonda 31/31 mais as metas novas, 8 descidas com Maestria 1 e com Maestria 20 (mesmas sementes), vídeos da ultimate e do herói, relatório | o aceite acima, com a diferença de vitórias entre Maestria 1 e 20 escrita (meta da E6: até 25 pontos) | `qa-performance` | `docs/qa/`, `docs/gallery/e2/` |

- **Riscos**: a ultimate é a peça que mais pode piorar a leitura (efeito grande no meio do grupo): o `art-director`
  especifica antes; a Maestria deixa o jogo fácil para quem joga muito (meta da E6 e Juramentos depois); a tela do herói é
  a primeira tela de meta do jogo e pede o mesmo nível da carta nova.
- **Evidências**: `docs/gallery/e2/` (tela do herói, tela de fim com XP, ultimate a 1x e 0,25x, Dom de ação antes e
  depois), saída da sonda, `METRICAS.md` com Maestria 1 e 20.

### E3 "Bênçãos e combinações" (o C13 antigo; 4 a 6 dias)
- **Objetivo**: chegar a Morvath com 5 a 8 Bênçãos que combinam, com as regras e os números do Hades II.
- **Por que agora**: prioridade 3; hoje 2 a 3 Bênçãos em Morvath (QA do C12d), quase nenhum Elo se forma.
- **Dependências**: E2 (Dom e Bênção somam na mesma `stat`); D-52, D-53, D-61; D-41 (nomes).
- **Itens**: C13-01 a C13-08 (seção 1b, sem mudança de aceite; C13-03 com as raridades da D-52), BUG-017 (Elo sem nível e
  sem raridade), E3-01 troca com +1 de raridade (10% por carta numa ação ocupada, a lendária), E3-02 `requires_sets` nos
  Elos, E3-03 Compêndio de Bênçãos e Elos, E3-04 aviso "Bênção nova" (`EloBanner`), E3-05 `dealt_by` (DT-016) usado no
  balanço, E3-06 carta com a moldura de cada raridade (a lendária em ouro velho, nunca amarelo vivo).
- **Aceite**: o da seção D do roteiro para o C13 (robô chega com 5 a 8 em 6 de 8, compra na loja em 6 de 8, vence 3 a 6 de
  8; economia com a fonte de cada número), mais `test_rarity` (10 mil sorteios dentro de 1 ponto), `test_elo`, e nenhum
  Elo com raridade na carta.
- **Responsáveis**: `gameplay-engineer`, `ui-ux-designer` (loja, carta, Compêndio), `qa-performance`.
- **Riscos**: a partida dobra de tamanho e muda toda a curva; as arenas repetem (4 salas para 10 lutas). Medir antes de
  mexer em vida.

### E4 "Salmos e descobertas" (4 a 5 dias)
- **Objetivo**: descobertas raras que transformam o jogo de uma partida, registradas no Compêndio, com música própria.
- **Dependências**: E3; D-59 (texto e música), D-60 (temas aprovados).
- **Itens**: E4-01 `PsalmDef` e regras (três grupos com Dom, Bênção ou Elo; 10% por carta; 5% no guardião; um por tema;
  dois por partida), E4-02 os 4 primeiros Salmos aprovados, E4-03 carta e moldura do Salmo (`art-director` especifica),
  E4-04 "Salmo descoberto" sem pausar e entrada no Compêndio com pista, E4-05 Compêndio completo (inimigos, Morvath,
  arenas; só texto de jogo, D-62), E4-06 tema musical por Salmo e a música de combate de base (C15-03, licença pela
  D-12b), E4-07 `audio/LICENSES.md` e créditos (C15-05).
- **Aceite**: `test_psalms`, `test_codex`; nenhum texto bíblico citado e nenhum número de salmo na tela (teste que lê as
  chaves `psalm_*`); cada Salmo com captura e vídeo da transformação aprovados pelo `art-director`; música sem silêncio de
  2 s com ela ligada.
- **Responsáveis**: `gameplay-engineer`, `ui-ux-designer`, `art-director`, `environment-artist`.
- **Riscos**: tom (alegoria respeitosa, sem sermão); fonte da música.

### E5 "Eventos e exploração" (5 a 8 dias)
- **Objetivo**: decisões fora do combate e a sensação de descer por lugares ligados (hipótese A).
- **Dependências**: E3 (baralho de recompensas, economia); D-31, D-32, D-29 (arenas).
- **Itens**: Provação (o Caos do Hades II: porta com custo de vida `teto(10 + 0,5 x profundidade)`, maldição de 3 a 5
  encontros que vira recompensa; `hades2_sistemas.md` seção 7; tema sem dono até o Daniel dizer), salas de evento
  (inscrição, altar, fonte: só com cânone), C14-A4 a A6 (Santuário, Ponte, Runas), portas que mostram o caminho.
- **Aceite**: cada evento com uma decisão própria medida no registro; arenas com os testes do C12; aprovação do
  `art-director`; quadro até 6 ms a 1080.

### E6 "Balanceamento da primeira região" (contínuo, com testes T5 e T6)
- **Objetivo**: a região inteira justa e com curva, para gente, do Maestria 1 ao 20.
- **Itens**: dificuldade por sala e de Morvath pelo registro de gente; curva de Maestria (D-57) pelo tempo real; meta
  D-11; diferença Maestria 1 e 20; Juramentos (D-63); mixagem e ambiência (C15-01, C15-04, B-3); máquina fraca (DT-003).
- **Aceite**: primeira vitória em até 3 tentativas para quem jogou Hades (D-11, pede teste humano); robô 0,25 com Maestria
  20 até 25 pontos acima da Maestria 1; iGPU medida; pico até -1 dBTP e -18 a -14 LUFS.

### Itens de arte que seguem abertos

| ID | Título | Esforço | Responsável | Quando |
|---|---|---|---|---|
| ART-002 | Música (agora com os temas dos Salmos) | G | `art-director`, Daniel (fonte) | E4 |
| ART-010 | Peças definitivas (estátuas, sarcófagos, porta, foice de Morvath, árvore) | M | `art-director`, `environment-artist`; Daniel autoriza créditos | depois do C12f (D-46) |
| ART-011 | Gancho de Morvath e ouro das elites por repintura | P | Daniel | paliativo no VX-07; repintura com D-46 |
| ART-012 | Medalhões pintados das outras 29 Bênçãos e dos Salmos (hoje só 3, feitos por IA) | M | `art-director`, Daniel (fonte e IA, `steam-ia.md`) | E3 e E4 |
| QW-009, QW-010 | Coroa da fachada; medir a `02` contra a planta | P | `art-director` | quando sobrar |

---
## 7. Decisões do Daniel

### Tomadas por ele (2026-11-16, noite): diretriz "um herói definitivo"
Decisões 1 a 12 em `docs/design/one_hero_directive.md`: um herói só (Explorador/Guardião) até a qualidade desejada; os
outros três não agora; game feel e visual primeiro; Maestria por herói; Dons pela Maestria; Bênçãos com quatro raridades;
Salmos transformam; Salmos com temas bíblicos e música e efeitos originais; sem equipamento; Emeth é a arma; Câmara do Selo
e Morvath fecham a região; Fase 2 não agora.

### Abertas desta especificação (D-48 a D-63; detalhes em `docs/design/guardian_spec.md`)

| ID | Pergunta | Opções | Minha recomendação |
|---|---|---|---|
| D-48 | Nome do herói | (a) Explorador (nome do modelo, sem peso de cânone); (b) Guardião (no cânone de 12/11 os guardiões são os quatro Juramentados sem o sangue do leão que seguram o selo, sinal da espada erguida; "os quatro de Valmor" são eles); (c) o nome próprio do `PALADIN_1` quando existir | **(b) se** o herói é um dos quatro de Valmor na história (então o nome diz quem ele é); senão (a). No código fica `explorer` de qualquer jeito |
| D-49 | Se for Guardião: o que vira a sala e os inimigos "Guardião" de hoje (Cavaleiro, Ancião) | (a) Sentinela; (b) Carcereiro; (c) Campeão dos Mortos | **(b) Carcereiro**: diz que eles prendem o caminho, sem disputar sentido com os guardiões do selo (opinião) |
| D-50 | Como renomear "dom" para "Bênção" | (a) só o texto (P); (b) texto e classes (M); (c) tudo, com chaves e registro (G) | **(a)**: nenhum ganho para o jogador em (b) ou (c), e (c) quebra o `runs.jsonl` |
| D-51 | Quem concede as Bênçãos (Chama, Geada, Luz, Vigília) com um herói só | (a) os três companheiros e o voto do próprio herói, como hoje (o texto aparece quando os nomes existirem); (b) a luz de Elun em quatro formas, sem pessoa; (c) outra origem do cânone (as fontes de luz, os guardiões de Valmor) que só você pode dar | **(a)**: mantém a premissa ("quatro paladinos descem"), dá presença aos outros três antes de serem jogáveis e não inventa nada; (b) põe Elun como fonte de geada e fogo, o que pede cuidado teológico |
| D-52 | As quatro raridades | (a) comum 1, rara 1,5, épica 2, **lendária 2,5 só pela troca** (a heroica do Hades II), e o lendário do Hades II vira o Salmo; (b) cinco raridades (comum, rara, épica, heroica e lendária única); (c) lendária no sorteio com 1 ou 2% | **(a)**: os quatro nomes que você pediu, cada regra do Hades II no seu lugar (D-39), e o Salmo ganha a regra do lendário |
| D-53 | Multiplicador da raridade | (a) fixo 1,5, 2, 2,5; (b) faixa sorteada do Hades II (rara 1,3 a 1,5, épica 1,8 a 2, lendária 2,3 a 2,5) | **(a)** agora (KISS e carta mais clara); (b) se você quiser a fidelidade total |
| D-54 | Ultimate: como carrega e qual vem primeiro | carga: (a) Magia gasta, o Hex do Hades II; (b) barra por dano, o Chamado do Hades I (números a confirmar); (c) recarga por tempo. Efeitos: U-1 ofensiva (6 m, 240, atordoa) e U-2 defensiva (anel de 7 m por 5 s) | **(a)**, U-1 na Maestria 2 e U-2 na 10; escolhida antes de descer, uma por partida como o feitiço do Hades II |
| D-55 | Nome da ultimate e se ela fala da luz de Elun | nomes: Lâmina Erguida, Juízo da Emeth, Clarão da Emeth (U-1); Muralha de Luz, Cerco de Luz, Bastião (U-2) | **Juízo da Emeth** e **Muralha de Luz** se o herói não for guardião; **Lâmina Erguida** só se for (é o sinal deles); nenhum nome com Elun ou Yah sem você |
| D-56 | Passiva | P-A Brilho da Emeth (2 de Magia por finalizador que acerta); P-B Postura do Guardião (20% menos dano pela frente parado); P-C Vigília (primeiro golpe da sala anulado) | **P-A**: muda o jeito de jogar sem mexer direto na dificuldade e liga combo, Ômega e ultimate; a P-C repete a Bênção Escudo da Vigília |
| D-57 | Maestria: ritmo, perda e saves antigos | ritmo: 20 níveis em cerca de 25 a 30 partidas (40 + 10 por nível) ou mais rápido/lento; morrer guarda o XP (sim/não); saves antigos ganham 40 por partida e 60 por vitória até o nível 5 (sim/não) | **sim aos três**: um Dom novo por partida no começo, nada se perde ao morrer (como o Hades II), quem já jogou não recomeça |
| D-58 | Dons: o que entra e como se equipa | (a) catálogo de 20 com Devoção (custo de 1 a 5, capacidade 5 + nível, como as Arcana); (b) tudo destravado fica ativo (como o espelho do Hades I, sem escolha); (c) só Dons de ação, sem os de vida e desafio à morte | **(a)** com os Dons de sustento (vida, levantar uma vez): com um herói só eles são dele; quando vier o 2º herói, os genéricos podem virar uma camada comum |
| D-59 | Salmos: texto e música | texto: (a) nome por tema, sem número e sem citar texto bíblico (o cânone diz "ninguém cita versículo"); (b) com número ("Salmo 23"); música: (c) síntese e CC0 ou CC-BY (D-12b); (d) compositor contratado (pago, pede sua autorização) | **(a)** e **(c)** agora; (d) depois, com orçamento |
| D-60 | Quais temas de Salmo aprovar (8 propostos: Sentinela, Abrigo, Pastor, Rocha, Cântico Novo, Purificação, Luz, Árvore junto às águas) e os dois cuidados de cânone | aprovar a lista, cortar, trocar; o "da Árvore" mexe na fonte de luz (sinal do Sopro); nenhum "da Lâmpada" (termo do cânone) | **aprovar Sentinela, Abrigo, Pastor e Rocha para a E4** (os mais ligados ao herói que segura o chão); o da Árvore só com o seu sim |
| D-61 | Descida de 10 salas (C13 antigo) | (a) na E3, junto com as Bênçãos; (b) só na E6, testando combinações com `--boons` | **(a)**: com 2 a 3 Bênçãos em Morvath as combinações não aparecem para quem joga |
| D-62 | Texto do Compêndio | (a) só descrição de jogo até você escrever o resto; (b) o diretor propõe frases a partir do cânone para você aprovar | **(a)** na E2 a E4; (b) quando você quiser |
| D-63 | Juramentos (os votos do Hades II, dificuldade por escolha) | (a) na E6, depois da primeira vitória, como lá; (b) depois da Steam | **(a)**: dá vida longa à região única e equilibra a Maestria |
### Antes desta revisão

#### Novas, tomadas por ele (2026-11-16)

| ID | Decisão | Onde |
|---|---|---|
| D-34 | Estandartes com o leão no salão e nas arenas; a Câmara do Selo segue com a espada | `501f3d8`, `e2297ee` |
| D-35 | Estátuas encapuzadas de mãos vazias; nenhuma porta verde (nem braseiros pedidos na imagem) nas arenas | `501f3d8` |
| D-36 | "Não precisa de fidelidade nesta entrega, o importante é ter as arenas salas diferentes, depois eu testo": fidelidade às imagens conceituais fica para depois, talvez com Meshy que ele autorize | registrado no `CLAUDE.md` (`95c29c6`) |

#### Decidida pelo Daniel nesta tarde

| ID | Decisão | Onde |
|---|---|---|
| D-39 | "Vale copiar do Hades, nomes nossos": mecânicas e números do Hades II fielmente; nomes, personagens, UI e arte de Eterra. Resolve o conflito com a frase "não copiar mecanicamente" do pedido de hoje | `roadmap_plan.md`; C13 planejado com isso |

#### Abertas da Game Feel Review (novas)

| ID | Pergunta | Opções | Minha recomendação |
|---|---|---|---|
| D-42 | Os inimigos comuns sem armadura atordoam ao levar golpe, como no Hades II (param de andar, a preparação é interrompida; elites imunes até a armadura quebrar; alguns imunes só durante o próprio ataque)? Muda muito a dificuldade | (a) copiar o Hades por inimigo; (b) só parar de andar no recuo, sem interromper o ataque; (c) como está | **(a)**, pela D-39 e porque hoje acertar não muda nada; entra no C12f, medido no robô e no T4 antes de mexer em vida **Decidido pelo Daniel em 2026-11-16: segue a recomendação.** |
| D-43 | O que fica nosso no impacto (apresentação, não dificuldade): câmera lenta rara por vários abates (o Hades só tem no último abate e no chefe), tranco de câmera maior só nos finalizadores e no Ômega, clarão morno em vez do vermelho do Hades | (a) manter os três, corrigidos (GF-05, GF-10); (b) tirar e ficar só com o Hades | **(a)**: é a sensação do Ember & Blade, rara e corrigida; o `art-director` fixa os valores pelo vídeo **Decidido pelo Daniel em 2026-11-16: segue a recomendação.** |
| D-44 | Três diferenças que mexem na dificuldade: (1) esquiva sai no quadro 0 (o Hades espera 3 quadros protegido); (2) o círculo dá 0,2 s de proteção e deixa atacar na hora (o Hades não protege e trava 8 quadros); (3) depois da seta o herói anda na hora (o Hades segura as pernas 0,71 s, só a esquiva corta) | para cada uma: copiar o Hades ou manter | **(1) manter** (só ganha resposta); **(2) copiar** (é erro de cópia que facilita); **(3) copiar**, porque o especial é o golpe de maior dano por aperto, mas contraria o "mais dinâmico" do 1º teste: até a resposta, fica como está **Decidido pelo Daniel em 2026-11-16: segue a recomendação.** |
| D-45 | Quando o Daniel testa | (a) a versão do C12c agora; (b) depois do C12d (1 a 2 dias), um teste só | **(b)**: o C12d muda a mão (esquiva, buffer, hit stop); um teste antes mediria a mão que vamos trocar **Decidido pelo Daniel em 2026-11-16: segue a recomendação.** |
| D-46 | Créditos do Meshy (546) para armas próprias dos inimigos e de Morvath (hoje do KayKit) | (a) nada agora, paliativo no assado (VX-07); (b) autorizar um lote depois do C12e, com orçamento do `art-director` por peça antes de gastar | **(b)** depois do paliativo: as armas são o que mais destoa nos modelos, e o custo por peça precisa ser orçado (não sei o preço de geração; a repintura é 10 créditos) **Decidido pelo Daniel em 2026-11-16: segue a recomendação.** |
| D-47 | Nova ordem dos ciclos (seção 6): C12d, T3, C12e, C12f, T4, C13, C15, C14, C16 | (a) a nova; (b) a anterior (C13 logo depois do teste) | **(a)**: é a regra da sua diretriz; o C13 alonga a partida sobre uma mão que ainda perde aperto **Decidido pelo Daniel em 2026-11-16: segue a recomendação.** |

#### Abertas de antes

| ID | Pergunta | Opções | Minha recomendação |
|---|---|---|---|
| D-41 | Nomes de Eterra para romã, raridades e loja no C13 | os nomes provisórios do `hades2_sistemas.md` ou os seus | mandar só os que quiser trocar |
| D-12b | Licença do som e da música (C12f e C15) | (a) só CC0 e síntese; (b) CC0 e CC-BY com créditos | **(b)** **Decidido pelo Daniel em 2026-11-16: segue a recomendação.** |
| D-37 | A referência `04` (feita por IA) em tamanho cheio está no histórico do git e no GitHub (`91cc656`) | (a) deixar; (b) reescrever o histórico (só com ordem expressa); (c) deixar e só proibir de novo | **(a) com (c)** se o repositório for privado; **(b)** numa única vez se for ficar público |
| D-31, D-32 | Água que desacelera; destrutíveis que abrem passagem | decidir depois do T4 | como antes |

Fechadas sem objeto: **D-38** (o ART-R1 aprovou as Fendas, `4d281bc`); **D-40** (o C15 foi partido: sons do combate no
C12f, música no C15; a ordem é a D-47).

#### Tomadas pela sessão na noite de 2026-11-16 (a confirmar; o Daniel ainda não respondeu)

| ID | Decisão tomada | Onde está | Recomendação |
|---|---|---|---|
| D-08 | Quadro P&B só em Ômega acertado e quebra de fase, 1 a cada 10 s, com opção | `dcf6632`, `196f33c` | Confirmar |
| D-14 | Na luta, a porta selada no lugar do portal vermelho | `482eb6f` | Confirmar |
| D-16 | Selo com o leão de pé (patas de trás) | `482eb6f` | Confirmar |
| D-17 | Espada erguida no lugar da cruz | `482eb6f`, `00dd13b` | Confirmar |
| D-18 | Raio de 12,5 m | `boss_arena.md` | Confirmar |
| D-20 | Morvath vai ao centro nas fases 3 e 4 | `6b16045` | Confirmar |
| D-21, D-22 | "A Câmara do Selo"; tela de fim sem nível | `6801e87` | Confirmar |
| C12a | O miolo do selo escurece com as faixas da tempestade | `b7f5f4d` | Confirmar no T3 |

D-15 (salas comuns no salão) e D-06 (descida curta) foram superadas pelas arenas e pela D-27.

#### Decididas pelo Daniel antes (arenas)
D-25 (3 arenas), D-26 (salão como arena), D-27 (7 salas), D-28 (para na borda), D-29 (runas em faixas), D-30 (árvore
petrificada), D-33 (nome por 2 s): todas seguiram a recomendação e estão entregues, menos D-29 (C14).

#### Abertas de antes

| ID | Pergunta | Recomendação |
|---|---|---|
| D-23 | O que é a porta selada e o véu de runas | Pendente na história; sem texto até o cânone ter |
| D-11 | Meta de dificuldade da primeira vitória | Até 3 tentativas para quem jogou Hades, com a descida inteira |
| D-09 | Magia na luta do chefe | Decidir no C13 com o registro |
| D-10 | Bônus de sequência (não existe no Hades II) | Tirar no C13 (C13-07), coerente com a D-39 **Decidido pelo Daniel em 2026-11-16: segue a recomendação.** |
| D-01 | Título de Morvath | "o Rei que Traiu a Luz" ou "o Lich-Rei do Sul" (cânone) |
| D-02, D-04 | Quem sela Morvath; nomes dos paladinos (os marcadores `PALADIN_n` apareciam na carta de dom; o VX-11 esconde a linha até os nomes existirem) | Seguir o cânone de 12/11; nomes depois |
| D-05 | Créditos do Meshy (546) | Nada até você pedir; fidelidade das arenas é candidata (D-36) |
| D-07, D-12, D-13 | Entre partidas; origem do som; executável para testadores | Como antes |
| D-03 | Imagens da Hécate | Desistir |


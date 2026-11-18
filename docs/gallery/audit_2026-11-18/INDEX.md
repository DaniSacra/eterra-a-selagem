# Pacote visual para a auditoria de direção de arte (2026-11-18)

- **Versão**: `arpg-3d`, commit `dd1f5ba` (o exe de teste atual). Ressalva: o espelho da GPU copia a árvore de trabalho; outras frentes trabalhavam ao mesmo tempo, então uma captura pode ter pego mudança local ainda sem commit (nenhuma tocava as telas e cenas capturadas, até onde se viu). Data das capturas: 2026-11-18.
- **Evidência**: só capturas reais da Godot 4.7.2 desta versão, na placa de vídeo do Daniel (RTX 5060, Vulkan,
  **Forward+**, como no PC dele), pela cópia padrão do projeto (`tools/gpu.sh`, `tools/movie.sh`). Nenhuma imagem
  gerada por IA é evidência aqui. A exceção marcada é a pasta `4_cenarios/navegador_compatibility/` (renderizador do
  navegador, Compatibility, para comparação).
- **Resoluções**: 1920 x 1080 (`_1080`) na maior parte, 1280 x 720 (`_720`) nas telas que também precisam ser lidas
  pequenas, 1672 x 941 (`_1672`, o padrão do `tools/gpu.sh`) nas variantes B das arenas feitas hoje pelo
  environment-artist. JPG de qualidade alta (ffmpeg `-q:v 2` a `3`). Vídeos MP4 H.264 a 1280 x 720, 30 qps, com som
  (AAC), gravados pelo Movie Maker da Godot (`tools/movie.sh`, quadro a quadro, sem perda de quadro).
- **Avaliação**: `AUDITORIA.md` nesta pasta (manter, melhorar ou refazer, prioridade, responsável e o prompt para o
  Claude Code).

## Referências e regras de identidade

- **Referências de qualidade**: Hades II (mecânica, números, leitura do combate e interface), Ember & Blade (sensação
  visual do cenário e dos efeitos), Ravenswatch (heróis com kit próprio e talentos por herói, só princípios). Nada é
  copiado: nomes, personagens, interface e arte são de Eterra.
- **Identidade**: fantasia sombria de aventura (não terror). O herói jogável é **o Guerreiro** (cabelo vermelho,
  cachecol azul-petróleo, armadura de couro e metal), com a espada **Emeth** (lâmina de cristal esmeralda com veios de
  ouro, guarda de chifres, punho vermelho). A história é narrada pelo **Livro de Ahk** (grafia do cânone: Ahk).
  Morvath é o chefe da região, selado na Câmara do Selo.
- **Símbolos**: o símbolo do herói é o **leão**; a Câmara do Selo usa a espada erguida. **Sem cruz e sem sol** como
  símbolo. Yah é Deus e Elun é Jesus (alegoria cristã); a luz vem de Elun; não existem outros deuses. Nada de
  "Aliança", "Convênio" nem poder com o nome de Elun.
- **Texto do jogo**: português do Brasil, **sem travessão**, Cinzel (títulos) e Alegreya Sans (corpo), ambas OFL.
- **Paleta de trabalho**: pedra ardósia fria, ouro velho (nunca amarelo vivo), esmeralda da Emeth, petróleo do herói,
  verde espectral frio e violeta de Morvath, vermelho só para perigo e avisos; raridades: comum no metal, rara azul
  `6f9be6`, épica violeta `b07ae6`, lendária ouro velho `d4ad66`.

## Onde está a documentação de direção

- `docs/arte/estetica.md`: guia da estética (análise das referências, paleta, leitura da tela, tempos dos golpes,
  números de cada ciclo).
- `docs/art/art_direction.md`: **ainda não existe** (pedido na auditoria, tarefa 6).
- `docs/art/arena_reference.md` (salão a partir da pintura do Daniel), `docs/art/boss_chamber_spec.md`,
  `docs/art/cycle12_arenas_spec.md`, `docs/art/e5_spec.md`, `docs/art/enemies_phase1.md`, `docs/art/title_screen_spec.md`,
  `docs/art/meshy_asset_plan.md`, `docs/art/visual_review.md`, `docs/art/asset_inventory.md`.
- Relatórios do dia: `docs/reports/2026-11-18/` (art, environment, ui, assets, combat_feel, gameplay, qa).
- **Pranchas do PO e referências aprovadas**: só locais, fora do repositório público (`docs/art/ref/`, ignorada pelo
  git): `docs/art/ref/direcao_2026-11-17/pranchas/01` a `10`, `referencias-aprovadas/`, `warrior_art_bible.png`,
  `inimigos_fase1.png`, `arena_catacumbas_1672.png`. Não vão no ZIP.

## Como foram feitas (comandos)

`tools/gpu.sh shot <saída> [opções]` captura o jogo na GPU (`RES=1920x1080` para 1080). Labs:
`tools/gpu.sh run --rendering-driver vulkan --resolution 1920x1080 -s tools/<lab>.gd -- ...`. Vídeos:
`RES=1280x720 tools/movie.sh C:/.../nome.avi <quadros> [opções]` e
`ffmpeg -ss <início> -t <duração> -i nome.avi -c:v libx264 -crf 27 -pix_fmt yuv420p -c:a aac -b:a 128k nome.mp4`.
Abaixo, "relatório art" = captura do art-director de hoje em `docs/reports/2026-11-18/art/` (comando na tabela do
`art.md`), "relatório ui" = do ui-ux-designer em `docs/reports/2026-11-18/ui/`, "relatório env" = do environment-artist
em `docs/reports/2026-11-18/environment/`; todas de hoje, depois do commit `dd1f5ba`, na GPU.

Legenda de contexto: **definitivo** = arte própria aprovada ou modelo do Meshy aprovado (Guerreiro, Emeth, os nove
inimigos; licença do Meshy ainda a registrar); **provisório** = KayKit (paredes, escadas, barris, peças da masmorra,
armas dos inimigos), primitivos das recompensas, formas próprias simples (estátuas, moldura do portal).

## 1_titulo_livro

| Arquivo | O que mostra | Comando | Contexto |
|---|---|---|---|
| `01_titulo_1080.jpg` | Tela de título com o menu | relatório art: `--title --shot-at=4` | Fundo é a arte de IA aprovada pelo Daniel (título antigo, sem a prancha 08); botões vetoriais reais |
| `01b_titulo_1080_ui.jpg` | Título, outra captura | relatório ui: `--title --shot-at=3` | Igual, para conferir estabilidade |
| `02_titulo_720.jpg` | Título a 1280 x 720 | relatório ui | |
| `03_livro_abertura_1080.jpg` | Livro de Ahk, capítulo Abertura | `tools/book_lab.gd` (etapa 2 do pacote, `docs/gallery/artpack/stage2/after/1080_opening.png`) | Telas 2D sobre o título; o código do Livro não mudou depois da etapa 2 (commit `4fab502`, dentro do HEAD) |
| `04_livro_o_guerreiro_1080.jpg` | Capítulo O Guerreiro | idem, `1080_hero.png` | Retrato pintado recortado da prancha 04 (IA, registrado) |
| `05` a `07_livro_dons_*_1080.jpg` | Árvore de Dons com um Dom em foco (Fúria Plena, Golpe sem Fim, Onda Atravessante) | idem, `1080_gifts_*.png` | Glifos vetoriais (prancha 09 ainda não feita) |
| `08_livro_dons_ultimate_1080.jpg` | Árvore com a ultimate Voragem em foco | idem, `1080_gifts_ult.png` | |
| `livro_*_720.jpg` | As mesmas páginas a 1280 x 720 | relatório ui: `tools/book_lab.gd -- --nosave --lab-out=...` | |

## 2_menus

| Arquivo | O que mostra | Comando | Contexto |
|---|---|---|---|
| `bencao_cartas_1080.jpg`, `_720` | Escolha de Bênção (Elos e Bênção com raridades) | relatório ui: `tools/ui_lab.gd -- --card-only` | Medalhões pintados (IA, registrados) |
| `bencao_troca_raridade_1080.jpg` | Troca que sobe uma raridade (Sai e Entra) | `tools/ui_lab.gd -- --card-only --trade --held=golpe_brasa --held-rarity=2 --offer=golpe_geada,brasas,escudo` | Glifos vetoriais nas Bênçãos sem arte |
| `bencao_texto_longo_1080.jpg` | Carta lendária com texto longo e "Substitui" | `tools/ui_lab.gd -- --card-only --held=toque_geada --offer=flagelo,estilhaco,pesado_firme --rarity=3,0,1` | |
| `elo_carta_1080.jpg`, `_720` | Carta de Elo com a corrente | relatório ui: `tools/ui_lab.gd -- --bot --hold --seed=5` | |
| `elo_formado_1080.jpg`, `_720` | Saudação "Elo formado" na luta | idem | |
| `suas_bencaos_painel_1080.jpg`, `_720` | Painel de Bênçãos aberto da pausa | idem | |
| `salmo_carta_1080.jpg`, `_720` | Carta de Salmo entre duas Bênçãos | `tools/ui_lab.gd -- --bot --hold --seed=5 --psalm-card=sentinela` | Medalhão do Salmo vetorial |
| `salmo_descoberto_1080.jpg`, `_720` | Saudação "Salmo descoberto" | `tools/ui_lab.gd -- --bot --hold --seed=5 --psalm-card=sentinela` (1080); relatório ui (720) | |
| `provacao_cartas_1080.jpg` | As três cartas da Provação | relatório ui: `tools/ui_lab.gd -- --start=trial --trial` | Medalhões vetoriais |
| `provacao_laje_placa_1080.jpg` | Laje da Provação e a placa na sala | relatório ui: `--slab --start=fountain` | |
| `provacao_selo_hud_1080.jpg`, `_720` | Selo da maldição no HUD | relatório ui | |
| `provacao_vencida_1080.jpg`, `_720` | Virada: "Provação vencida" | relatório ui | |
| `altar_trocas_1080.jpg`, `_720` | Tela do Altar Esquecido | `tools/ui_lab.gd -- --start=altar --altar --gold=0 --held=brasas` (1080); relatório ui (720) | Medalhões pintados |
| `pause_*`, `boons_*`, `howto_1080`, `options_tab_*`, `defeat_*`, `victory_*`, `options_*`, `music_*` (`_1080` e `_720`) | Pausa (poucas e muitas Bênçãos), Suas Bênçãos (topo e fim), derrota, vitória (selagem, resumo, fechamento), Configurações (quatro abas), Músicas | `tools/menu_lab.gd -- --nosave --lab-out=... --bot --hold --seed=5` e `-- --title-screens`; 1080 recapturados nesta auditoria (`RES` 1920x1080); 720 do relatório ui | |
| `howto_1080.jpg`, `_720` | Como Jogar | relatório ui: `--title --screen=howto` | Créditos saíram do jogo (commit `099a486`) |
| `golpes_1080.jpg`, `_720` | Compêndio, aba Golpes | relatório ui: `--title --screen=moves` | |
| `juramentos_1080.jpg`, `_720` | Juramentos | relatório ui: `--title --screen=juramentos --wins=1` | |
| `compendio_aba0` a `aba7` (`_1080`, `_720`) | Compêndio: Dons, Bênçãos, Elos, Salmos, Inimigos, Morvath, Arenas, Golpes | 1080: `tools/book_lab.gd` da etapa 2; 720: relatório ui | Dados de exemplo (parte descoberta) |
| `nome_da_sala_santuario_1080.jpg`, `_720` | Nome da arena ao entrar (Santuário, sala 9) | relatório ui (`doors_*`) | |

## 3_gameplay

| Arquivo | O que mostra | Comando | Contexto |
|---|---|---|---|
| `01_luta_salao_1080.jpg` | Luta no salão, HUD | relatório art: `--bot --autopick --seed=5 --shot-at=9` | Salão com peças do KayKit (provisório) |
| `02_hud_luta_1080.jpg`, `_720` | HUD em luta | relatório ui | |
| `03_multidao_estresse_1080.jpg`, `_720` | 300 inimigos (teste de estresse, não é jogo normal) | relatório ui: `--stress=300` | O jogo tem no máximo 20 de pé |
| `04_cripta_sala_vencida_recompensa_1080.jpg`, `_720` | Cripta vencida: recompensa e saudação de Bênção nova | relatório ui (`hall8_*`) | Recompensa é primitivo sem luz (provisório) |
| `05_ultimate_corte_do_juizo_1080.jpg`, `05_ultimate_720.jpg` | Ultimate U-1 | relatório ui: `--ultimate=cleave --ult-full --boons=4 --shot-at=10` | |
| `06_corredores_gpu.jpg`, `07_corredor_corrida_tira.jpg` | Corredor com a corrida nova (pés no chão) | `docs/gallery/t5b/runner/` (commit `40d6618`, o do HEAD) | |
| `08_feiticeiro_trote_tira.jpg`, `09_esqueleto_corrida_tira.jpg` | Tiras de 24 quadros de lado | `docs/gallery/t5b/boss/` (`tools/walk_strip.gd`) | |
| `10_acerto_golpe_numeros_1080.jpg` | Golpe que acerta, números e ouro | `--bot --autopick --seed=5 --shot-at=6 --shot-on=hit --shot-after=0.05` | |
| `11_giro_finalizador_1080.jpg` | Finalizador em giro | `... --shot-on=spin --shot-after=0.08` | |
| `12_especial_onda_da_lamina_1080.jpg` | Especial (onda da lâmina) | `... --shot-on=special --shot-after=0.12` | |
| `13_golpe_sofrido_santuario_1080.jpg` | Golpe sofrido no Santuário, coluna de luz, Brasas | `... --shot-at=5 --shot-on=hurt --shot-after=0.05` | |
| `14_guardiao_sacerdote_dos_mortos_1080.jpg` | Guardião com barra no topo | `--start=miniboss --bot --autopick --seed=5 --shot-at=7` | |
| `20_inimigos_todos_frente_recorte_1080.jpg` | Os nove de frente, herói para escala | `tools/enemy_lab.gd -- <prefixo>` (recorte da `_front`) | Modelos do Meshy (definitivo); armas do KayKit repintadas (provisório) |
| `21a_` / `21b_` / `21c_inimigos_todos_*_1080.jpg` | Os nove na câmera do jogo, de costas e de lado | idem (`_game`, `_back`, `_side`) | |
| `22_elites_frente_recorte_1080.jpg`, `23a_`, `23b_elites_*_1080.jpg` | Elites (esqueleto, corredor, feiticeiro, besteiro, sacerdote, Escudo) | `tools/enemy_lab.gd -- <prefixo> idle 0 skeleton_elite runner_elite mage_elite archer_elite priest_elite guard_elite` | Ouro velho por shader (sem repintura no Meshy) |
| `24_preparo_aviso_barras_camera_do_jogo_1080.jpg`, `24b_preparo_aviso_barras_frente_1080.jpg` | Preparo, avisos no chão a 60% e barras de vida | `tools/enemy_lab.gd -- <prefixo> idle 0 skeleton runner mage archer priest guard knight priest_elder --tell=0.8 --bars --warn=0.6` | |

## 4_cenarios

| Arquivo | O que mostra | Comando | Contexto |
|---|---|---|---|
| `01_salao_vitrine_1080.jpg` | Salão das Catacumbas no enquadramento da pintura de referência | relatório art: `--showcase --seed=5 --shot-at=2` | Estátuas, portal e ruínas provisórios |
| `salao_loja_1080.jpg` | Loja na sala 10, com a porta de Morvath | relatório art: `--start=shop --shot-at=3` | Itens da loja são primitivos (provisório) |
| `crypt_A_1080.jpg`, `rift_A_1080.jpg`, `garden_A_1080.jpg`, `sanctuary_A_1080.jpg`, `bridge_A_1080.jpg`, `runes_A_1080.jpg` | As seis arenas de luta, variante A, em luta | relatório art: `--arena=<id> --bot --autopick --seed=5 --shot-at=7` (Runas 8) | |
| `*_B_1672.jpg` | Variantes B das seis arenas | relatório env: `tools/gpu.sh shot` com `--arena=<id> --variant=1` (1672 x 941) | |
| `provacao_camara_1080.jpg`, `provacao_camara_1672.jpg` | Câmara da Provação | relatório art `--start=trial --shot-at=3`; relatório env | |
| `altar_camara_1080.jpg`, `altar_camara_1672.jpg`, `altar_porta_1672.jpg` | Altar Esquecido e a porta dele | relatório art `--start=altar`; relatório env | |
| `navegador_compatibility/*.jpg` | Salão, Cripta, Jardim e Câmara no renderizador do navegador | relatório env (Compatibility, `--rendering-driver opengl3`) | Só para comparação; o desktop é o que vale |

## 5_morvath

| Arquivo | O que mostra | Comando | Contexto |
|---|---|---|---|
| `00_camara_do_selo_vitrine_1080.jpg` | Câmara do Selo sem luta, herói e Morvath | `tools/chamber_lab.gd -- <saída> --showcase --hero --boss` | |
| `01_entrada_camara_1080.jpg` | 1,2 s depois de entrar | `--start=boss --bot --autopick --seed=5 --shot-at=1.2` | |
| `02_fase1_1080.jpg`, `03_fase1_hud_1080.jpg` | Fase 1 com a barra e as marcas de fase | relatório art `--start=boss ... --shot-at=7`; relatório ui | |
| `04_fase1_foice_aviso_1080.jpg` | Aviso da Foice Sepulcral | `--start=boss --bot --autopick --seed=5 --boss-only=scythe --shot-at=2 --shot-on=boss:scythe_warn --shot-after=0.35` | A "foice" é a lâmina do modelo |
| `04b_fase1_laminas_das_almas_1080.jpg` | Lâminas das Almas (meias-luas violeta) | `... --boss-only=blades --shot-on=boss:blades_fire --shot-after=0.25` | |
| `05_ritual_1080.jpg` | Fase 2: escudo do ritual, mortos, erupção | relatório art: `--boss-hp=0.68 --shot-on=boss:ritual --shot-after=2.5` | |
| `06_fase2_runas_de_invocacao_1080.jpg` | Runas de invocação | `--start=boss ... --boss-hp=0.5 --boss-only=summon --shot-on=boss:summon --shot-after=1.2` | |
| `07_fase3_maldicao_erupcoes_1080.jpg` | Fase 3: maldição e erupções | relatório art: `--boss-hp=0.3 --boss-only=curse --shot-on=boss:cursed --shot-after=0.5` | |
| `08_fase3_foice_e_erupcao_em_camadas_720.jpg` | Foice com erupção por baixo (camadas da fase 3) | quadro de `videos/v7_morvath_fase3` (4,5 s) | |
| `08b_quadro_de_impacto_preto_e_branco_720.jpg` | Quadro de impacto ao quebrar a fase | quadro de `videos/v7_morvath_fase3` (6 s) | |
| `09_fase4_tempestade_1080.jpg` | Fase 4: Tempestade das Seis Almas | relatório art: `--boss-hp=0.14 --boss-only=storm --shot-on=boss:storm_fire --shot-after=0.4` | |
| `09b_fase4_tempestade_faixas_720.jpg` | As seis faixas no chão | quadro de `videos/v8_morvath_fase4_tempestade` (13,5 s) | |
| `10_fase4_portal_1672.jpg` | Fase 4, portal inquieto | relatório env | |
| `11_vitoria_selagem_1080.jpg` | Queda e selagem, com a legenda | relatório art: `--boss-hp=0.02 --shot-on=boss:victory --shot-after=1.5` | |
| `12_morvath_foi_selado_emblema_1080.jpg` | "Morvath foi selado" com o leão, sobre a câmara | `--start=boss --bot --autopick --seed=5 --boss-hp=0.02 --hero-hp=999 --shot-at=1 --shot-on=boss:fallen --shot-after=0.6` | |

## 6_identidade

| Arquivo | O que mostra | Comando | Contexto |
|---|---|---|---|
| `logotipo_e_botoes_recorte_1080.jpg` | Logotipo pintado e botões do título (com a cruz do estandarte ao lado) | recorte de `1_titulo_livro/01_titulo_1080.jpg` | |
| `hud_rodape_recorte_1080.jpg`, `hud_topo_recorte_1080.jpg` | HUD de perto: medalhão, barras, losangos das ações, topo | recortes de `3_gameplay/02_hud_luta_1080.jpg` | |
| `medalhoes_tres_familias_1080.jpg` | Medalhões pintados, vetoriais da Provação e do Salmo lado a lado | recortes de `2_menus/bencao_cartas_1080.jpg`, `provacao_cartas_1080.jpg`, `salmo_carta_1080.jpg` | Mostra a mistura de famílias |
| `raridades_molduras_1080.jpg` | Molduras de raridade e da troca | recortes de `2_menus/bencao_troca_raridade_1080.jpg` e `bencao_texto_longo_1080.jpg` | |
| `leao_selo_e_como_jogar_1080.jpg` | O leão no emblema da vitória e no Como Jogar | recortes de `5_morvath/12_` e `2_menus/howto_1080.jpg` | |
| `tipografia_livro_1080.jpg` | Cinzel e Alegreya no Livro | recorte de `1_titulo_livro/04_livro_o_guerreiro_1080.jpg` | |

## videos (1280 x 720, 30 qps, H.264 com som)

| Arquivo | Duração | O que mostra | Comando (`RES=1280x720 tools/movie.sh <avi> <quadros> ...`) |
|---|---|---|---|
| `v1_luta_cripta.mp4` | 20 s | Luta comum na Cripta (esqueletos, feiticeiro), sala vencida, recompensa, passagem para o Jardim | `720 --bot --autopick --seed=5 --arena=crypt` |
| `v2_combo.mp4` | 13 s | Combo do Guerreiro sobre o grupo (golpes curtos, giro, esquiva) no salão | `PRE="-s res://tools/feel_driver.gd"`, `420 --bot --seed=5 --feel=hits --hero-hp=999` |
| `v3_especial_omegas.mp4` | 17 s | Especial (onda), círculo de luz e os três Ômegas | `PRE=... feel_driver`, `540 --bot --seed=5 --feel=abilities --hero-hp=999` |
| `v4_corredores_feiticeiros.mp4` | 18 s | Corredores, feiticeiros e besteiros andando, preparando e atacando (mira no chão) | `540 --bot --autopick --seed=5 --stress=9 --stress-ids=runner,mage,archer` |
| `v5_morvath_fase1.mp4` | 20 s | Entrada e fase 1, até a quebra da fase com o quadro de impacto | `600 --start=boss --bot --autopick --seed=5 --hero-hp=999` |
| `v6_morvath_ritual.mp4` | 20 s | Fase 2: ritual, escudo, mortos, erupções, o escudo se partindo e a volta à luta | `660 --start=boss --bot --autopick --seed=5 --hero-hp=999 --boss-hp=0.6` |
| `v7_morvath_fase3.mp4` | 18 s | Fase 3: maldição, foice com erupções | `540 --start=boss --bot --autopick --seed=5 --hero-hp=999 --boss-hp=0.3` |
| `v8_morvath_fase4_tempestade.mp4` | 18 s | Fase 4: tempestade das seis almas, meias-luas | `600 --start=boss --bot --autopick --seed=5 --hero-hp=999 --boss-hp=0.14 --boss-only=storm` |
| `v9_morvath_vitoria.mp4` | 20 s | Fim da fase 4, golpe final, selagem do portal, "Morvath foi selado" | `660 --start=boss --bot --autopick --seed=5 --hero-hp=999 --boss-hp=0.03` |

Nos vídeos o herói joga com o robô e `--hero-hp=999` (a barra mostra 999): é para a luta durar o vídeo inteiro, não é
o valor do jogo (vida 30).

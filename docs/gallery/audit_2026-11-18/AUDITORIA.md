# Auditoria de direção de arte, de ponta a ponta (2026-11-18)

Autor: art-director (Claude Code). Versão avaliada: `arpg-3d` no commit `dd1f5ba` (o exe de teste atual).
Evidência: só capturas reais da Godot desta versão, na GPU do Daniel (RTX 5060, Vulkan, Forward+), nesta pasta
(`INDEX.md` diz o comando de cada uma). Onde uma tela não tem captura, isso está escrito e ela não recebe veredito.
Nenhuma nota numérica: cada item diz o problema, a evidência e o que fazer. A aprovação artística final é do Daniel.

Referências de qualidade: Hades II (leitura do combate, interface, mecânica), Ember & Blade (sensação visual do
cenário e dos efeitos), Ravenswatch (heróis com kit próprio, princípios). Identidade própria: fantasia sombria de
aventura (não terror), o Guerreiro de cabelo vermelho e cachecol azul-petróleo, a Emeth esmeralda com veios de ouro,
o Livro de Ahk como narrador, o leão como símbolo do herói, ouro velho, pedra ardósia.

Legenda:
- **Manter**: está no nível pedido ou perto; só polir.
- **Melhorar**: a direção está certa, a execução não.
- **Refazer**: a peça não serve como está (placeholder ou leitura errada).
- **P0**: derruba a imagem em toda partida ou contradiz a identidade; **P1**: perceptível e importante; **P2**: acabamento.
- Responsáveis: `art-director` (especificação e revisão), `environment-artist` (cenário, luz, materiais, efeitos de
  cenário), `ui-ux-designer` (HUD, menus, cartas), `gameplay-engineer` (avisos, câmera, regras do desenho dos inimigos),
  `technical-artist` (modelos, assados, texturas, arte raster da UI), `combat-feel-director` (leitura e peso do combate).

## Resumo

1. A base visual é coerente e já tem cara própria: pedra ardósia fria, ouro velho, Emeth esmeralda, leão, Cinzel e
   Alegreya. Cartas, pausa, vitória, derrota, Configurações e o Livro de Ahk falam a mesma língua de moldura e ouro velho.
2. O que mais derruba a imagem: recompensas, loja, altar e Provação são primitivos chapados sem luz (cubos, prismas,
   moedas de cor pura) em toda sala vencida (P0).
3. Segundo maior problema: o cenário compete com os efeitos. Abismo violeta, portal verde e dezenas de velas laranja
   saturam ao mesmo tempo; no Ember & Blade só o efeito satura (P1). Cripta e Santuário são escuros e repetitivos
   (colunas em "Y" iguais em grade).
4. Morvath e a câmara estão no melhor nível do jogo; o problema é a família de verdes e cianos (escudo, partículas,
   erupções) que engole o herói nas fases 2 a 4 (P1).
5. A interface é limpa e legível, mas mistura três níveis de ilustração (medalhões pintados, ícones vetoriais chapados,
   peças 3D de protótipo) e o Livro de Ahk ainda não tem as ilustrações que contam a história (P1).
6. Identidade: a tela de título tem cruzes (clérigo, estandarte) e a maga antiga, contra a regra "leão, sem cruz nem sol"
   e a prancha 08 aprovada. Precisa de decisão do Daniel (P1). Não existe ainda o `docs/art/art_direction.md` (paleta com
   valores, regras de leitura) pedido no papel do art-director; o guia é só o `docs/arte/estetica.md` (P1, documento).

---

## 1. Tela inicial e Livro de Ahk

| Elemento | Veredito | Problema | Evidência | Impacto | Prior. | Solução proposta | Responsável |
|---|---|---|---|---|---|---|---|
| Arte do título (fundo) | Melhorar | A maga é a antiga (roxa, magia violeta), não a "Maga de Fogo com Cometa" aprovada (prancha 08). O clérigo segura uma cruz de ouro e tem cruzes no peito; o estandarte da fortaleza tem cruz. Contradiz "símbolo do herói é o leão, sem cruz nem sol". Arte de IA. | `1_titulo_livro/01_titulo_1080.jpg`, `6_identidade/logotipo_e_botoes_recorte_1080.jpg` | Primeira imagem do jogo e capa da Steam: é o que define a identidade | P1 | Pergunta ao Daniel pelo Game Director: cruz fica na arte do título ou vira leão/espada? Depois, integrar a arte nova da prancha 08 com o logotipo como camada e os botões nas mesmas áreas (`tools/title_flow_check.gd`); registrar no `docs/steam-ia.md` | Game Director (pergunta), `ui-ux-designer` (integração), `art-director` (revisão) |
| Logotipo e botões | Manter | Logotipo pintado lê bem; botões vetoriais em Alegreya sobre a arte, alinhados. O botão principal tem ouro saturado mais vivo que o ouro velho do resto. | `01_titulo_1080.jpg`, `02_titulo_720.jpg` | Baixo | P2 | Puxar o amarelo do "Iniciar" para o ouro velho `UiKit.OLD_GOLD` com brilho só na borda em foco | `ui-ux-designer` |
| Livro: Abertura | Melhorar | Página dupla só com texto e três itens com ícone; a prancha 04 abre com a cena de Ahk escrevendo (narrativa visual). Sem ilustração o "história narrada" fica só no texto. | `03_livro_abertura_1080.jpg`, `livro_opening_720.jpg` | A história do jogo não aparece na imagem | P1 | Vinheta de abertura em tinta sépia na página esquerda (Ahk como silhueta até o Daniel aprovar o visual dele), capitular ornada no texto. Sem IA nova: esboço em traço pode sair do nosso próprio render; com IA, registrar | `art-director` (spec), `ui-ux-designer`, Daniel (visual de Ahk) |
| Livro: O Guerreiro | Manter | Retrato pintado forte, hierarquia clara (arma, estilo, habilidades). A Emeth do retrato é curta e reta, sem a guarda de chifres nem o punho vermelho do modelo. Retrato 330 x 400 sem mipmaps. | `04_livro_o_guerreiro_1080.jpg` | Inconsistência pequena entre ilustração e modelo | P2 | Retrato novo com a Emeth certa quando houver arte; até lá, medir se borra a 1080 (technical-artist P2-7) | `technical-artist`, `art-director` |
| Livro: árvore de Dons | Melhorar | A árvore fica num painel escuro de tela dentro do pergaminho: lê como uma janela de jogo colada no livro. Glifos vetoriais pequenos e genéricos (prancha 09, etapa 3, não feita). Cadeados e números dominam os nós trancados. | `05_livro_dons_furia_plena_1080.jpg`, `08_livro_dons_ultimate_1080.jpg` | A árvore é a tela mais visitada fora da partida | P1 | Moldura de couro e cantos de metal no painel (prancha 05); motivos da prancha 09 por efeito real de cada Dom; trancado com o motivo apagado e o nível pequeno, não cadeado em destaque | `ui-ux-designer`, `art-director` (validar motivo por Dom) |
| Livro: abas e botões | Melhorar | Abas "Abertura / O Guerreiro / Dons" e botões "Voltar" são lajes escuras de interface por cima do pergaminho, fora do material do livro. | `03` a `08` em `1_titulo_livro/` | Quebra a fantasia do objeto livro | P2 | Abas como fitas marcadoras de couro saindo da borda; botões de ação em ouro velho gravado no papel | `ui-ux-designer` |
| Transições título > livro > partida | Sem evidência | Não há vídeo da navegação nesta pasta; não avaliado. | (nenhuma) | | | Gravar com `tools/movie.sh` um passeio pelo título, livro e entrada na partida | QA (`qa-performance`) |

## 2. Menus

| Elemento | Veredito | Problema | Evidência | Impacto | Prior. | Solução proposta | Responsável |
|---|---|---|---|---|---|---|---|
| Escolha de Bênção (cartas) | Manter | Três cartas comparáveis, raridade pela moldura, foco marfim. Com descrição curta, 40% da carta é tinta vazia. Sete medalhões pintados; as outras Bênçãos usam o glifo vetorial (a mesma tela mistura os dois). | `2_menus/bencao_cartas_1080.jpg`, `bencao_troca_raridade_1080.jpg`, `bencao_texto_longo_1080.jpg` | Tela vista de 15 a 20 vezes por partida | P1 (mistura), P2 (vazio) | Pintar os medalhões das Bênçãos e Elos que faltam no mesmo estilo (prancha 02); carta encolhe a área de texto ou centraliza verticalmente quando a descrição é curta | `technical-artist` (recorte), `ui-ux-designer`, `art-director` (aprovar prancha) |
| Carta de Elo | Manter | Corrente de ouro velho com as duas origens lê bem e só aparece no Elo. | `elo_carta_1080.jpg`, `elo_formado_1080.jpg` | | P2 | Nada além dos medalhões pintados dos 6 Elos | `ui-ux-designer` |
| Carta de Salmo | Manter | Moldura octogonal própria, arco ogival, "Aberto por". Medalhão vetorial mais simples que os pintados ao lado. | `salmo_carta_1080.jpg`, `salmo_descoberto_720.jpg` | | P2 | Medalhões pintados dos quatro Salmos (sem cruz nem sol) | `art-director` (prompt), `technical-artist` |
| Provação (cartas, laje, selo) | Melhorar | Interface clara (recebe, carrega, lutas). Os medalhões das cartas são vetoriais chapados (diamante, mira, coração), outro nível de acabamento que as Bênçãos; "22,5 de vida máxima" com decimal. | `provacao_cartas_1080.jpg`, `provacao_laje_placa_1080.jpg`, `provacao_selo_hud_1080.jpg`, `provacao_vencida_1080.jpg` | | P2 | Usar o medalhão da Bênção oferecida (pintado quando houver); arredondar o número mostrado | `ui-ux-designer`, `gameplay-engineer` (número) |
| Altar Esquecido | Manter | Medalhões pintados (romã, velas, passagem), entrega e recebe legíveis, motivo do bloqueio escrito. | `altar_trocas_1080.jpg` | | P2 | Nada na tela; o problema é a sala (área 4) | |
| Loja e placas das portas | Melhorar | Placas legíveis com marca de recompensa. Mas o objeto sobre cada item e cada porta é um primitivo de cor pura sem luz. | `4_cenarios/salao_loja_1080.jpg`, `4_cenarios/altar_porta_1672.jpg`, `3_gameplay/04_cripta_sala_vencida_recompensa_1080.jpg` | Toda sala vencida | **P0** | Trocar os primitivos (`Rooms.gem_mesh`) por um disco de ouro velho com o medalhão pintado da recompensa, sombreado, girando devagar sobre pedestal baixo, halo da cor abaixo do glow (ver área 4) | `environment-artist` (peça), `ui-ux-designer` (medalhão por recompensa) |
| Pausa | Melhorar | Painel limpo. Com muitas Bênçãos, a fileira do HUD e o painel mostram as mesmas ao mesmo tempo, e a saudação "Bênção nova" fica por cima da pausa. | `pause_1080.jpg`, `pause_many_1080.jpg` | | P2 | Esconder a fileira do HUD e as saudações enquanto a pausa está aberta | `ui-ux-designer` |
| Suas Bênçãos | Manter | Abas por categoria, raridade e nível na linha, rolagem. | `boons_1080.jpg`, `suas_bencaos_painel_1080.jpg` | | | | |
| Compêndio | Melhorar | Índice e listas legíveis, mas as páginas de detalhe são tabelas de texto; com pouco descoberto, a página vira uma coluna de "???". A prancha 04 tem um esboço de cada inimigo. | `compendio_aba0_1080.jpg` a `compendio_aba7_1080.jpg` | Compêndio é recompensa de exploração; sem imagem não recompensa | P1 | Página de inimigo com o desenho dele em traço (render do nosso modelo assado, sem IA), desconhecido como silhueta apagada; "???" agrupado em uma linha "N por descobrir" | `ui-ux-designer`, `technical-artist` (render em traço) |
| Configurações, Músicas, Como Jogar, Golpes | Manter | Abas, valores e leitura bons a 720 e 1080. O fundo é a arte do título escurecida (a cruz aparece atrás). | `options_*_1080.jpg`, `music_1080.jpg`, `howto_1080.jpg`, `golpes_1080.jpg` | | P2 | Fundo mais escuro e desfocado nessas telas, ou a arte sem cruz depois da decisão do título | `ui-ux-designer` |
| Juramentos | Melhorar | Tabela funcional, mas plana: nove linhas iguais, o logotipo pintado aparece fantasma atrás do título "Juramentos". | `juramentos_1080.jpg`, `juramentos_720.jpg` | Tela de meta-progressão, pouco vista no começo | P2 | Fundo sem o logotipo; cada voto com um selo pequeno; Peso total em destaque com o medalhão do leão | `ui-ux-designer` |
| Vitória | Melhorar | "Morvath foi selado" com o leão e resumo claros. Atrás do medalhão do selo há um disco amarelo-oliva chapado; a legenda da selagem na luta é versalete fino sem véu. | `victory_seal_1080.jpg`, `victory_1080.jpg`, `victory_closing_1080.jpg`, `5_morvath/11_vitoria_selagem_1080.jpg` | Momento de maior emoção da partida | P1 | Halo em degradê radial (sem disco); véu escuro e corpo maior na legenda; leão com um brilho que cresce em 0,6 s | `ui-ux-designer` |
| Derrota | Manter | "A luz não se apaga", "Derrotado por", onde caiu e Maestria ganha: hierarquia boa e tom de aventura. | `defeat_1080.jpg` | | | | |

## 3. Gameplay

| Elemento | Veredito | Problema | Evidência | Impacto | Prior. | Solução proposta | Responsável |
|---|---|---|---|---|---|---|---|
| Guerreiro (modelo e leitura) | Manter | Cabelo vermelho, cachecol petróleo e Emeth verde leem a 1080 com cerca de 130 px de altura; anel petróleo no chão o acha na multidão. | `3_gameplay/01_luta_salao_1080.jpg`, `02_hud_luta_1080.jpg`, `videos/v2_combo.mp4` | | | | |
| Emeth (lâmina e cortes) | Manter | Brilho esmeralda abaixo do glow, fita do corte fina, finalizador em giro com aro. | `11_giro_finalizador_1080.jpg`, `10_acerto_golpe_numeros_1080.jpg` | | | | |
| Especial (onda da lâmina) | Melhorar | A meia-lua de 1,6 m mal aparece a 1080 na câmera do jogo; o HUD chama de "Seta de Luz" o que a imagem mostra como onda. | `12_especial_onda_da_lamina_1080.jpg`, `videos/v3_especial_omegas.mp4` | O golpe característico do herói não se lê | P1 | Onda com mais 25% de comprimento visual (sem mudar o acerto) e rastro curto mais claro; nome do golpe no texto alinhado com o visual (decisão de texto do Daniel) | `combat-feel-director` (medir), `environment-artist`/VFX (shader `emeth_wave`), Game Director (nome) |
| Números de dano e ouro | Melhorar | "+1 ouro" e números empilham no mesmo ponto sobre o grupo. | `10_acerto_golpe_numeros_1080.jpg`, `01_luta_salao_1080.jpg` | Ruído sobre a ação | P2 | Ouro sobe ao lado (deslocado 0,6 m para a direita da tela) e menor que os números | `ui-ux-designer` (`Fx`/`NumberTally`) |
| Inimigos (os nove, modelos do Meshy) | Manter | Cada papel tem silhueta própria (lâmina, corredor curvado cor de ferrugem, cajado com caveira e orbe, besta, capuz roxo, escudo grande, Cavaleiro, ancião de cajado, Morvath). Seis dos nove são marfim-osso com pano vermelho: na câmera do jogo, a 60 a 90 px de altura, a diferença fica só na silhueta. Armas são do KayKit repintadas (provisório); cajado do feiticeiro rígido e longe do corpo. | `3_gameplay/20_inimigos_todos_frente_recorte_1080.jpg`, `21a_inimigos_todos_camera_do_jogo_1080.jpg`, `21b_`, `21c_`, `08_feiticeiro_trote_tira.jpg` | Leitura de papel na multidão | P2 | Um acento de cor por papel no pano ou no capuz, sem tocar o osso (atirador azul-ardósia, controle violeta já existe, bloqueio ferro escuro); armas do Meshy no lote de inimigos quando o Daniel liberar créditos; cajado inclinado 15 graus para trás e colado ao ombro | `technical-artist` (assado, `tools/bake.gd`), `art-director` (acentos), Daniel (créditos) |
| Elites | Melhorar (a confirmar) | No laboratório, de frente, a elite quase não se distingue do comum: o ouro velho só no aço some nessa luz. Não há captura de elite em luta nesta pasta para conferir o contorno escuro e a barra de armadura no jogo. | `22_elites_frente_recorte_1080.jpg`, `23a_elites_camera_do_jogo_1080.jpg`, `23b_elites_lado_1080.jpg` | Elite pede outra resposta do jogador (armadura) | P1 | Capturar elites em luta (`--stress=6 --stress-ids=skeleton_elite,mage_elite,guard_elite`); se confirmado, ouro velho em placas maiores (ombro, elmo) e aro de ouro velho fino na barra de vida já de longe | QA (captura), `technical-artist`, `art-director` |
| Animações dos inimigos | Manter | Corrida nova do corredor com pé no chão (aprovada hoje), preparo em três tempos, recuo ao levar golpe, queda arremessada. Feiticeiro ainda tira os dois pés do chão no trote. | `07_corredor_corrida_tira.jpg`, `09_esqueleto_corrida_tira.jpg`, `videos/v1_luta_cripta.mp4`, `videos/v4_corredores_feiticeiros.mp4` | | P2 | `"lift"` do trote do feiticeiro de 0,5 para 0,3 | `technical-artist` |
| Avisos de preparo (laboratório) | Melhorar | Com 60% do preparo, os avisos já são discos e faixas vermelhas brilhantes e quase opacas; vários juntos viram um tapete vermelho. | `24_preparo_aviso_barras_camera_do_jogo_1080.jpg`, `24b_preparo_aviso_barras_frente_1080.jpg` | Vermelho deixa de ser exceção | P1 | Ver linha abaixo | |
| Avisos no chão | Melhorar | O bote do esqueleto e a mira do besteiro saem como faixas vermelhas opacas, a coisa mais forte da tela, sem o degradê para a ponta clara pedido no ciclo 8. Lajes das Runas em âmbar cheio competem com a mira. | `videos/v2_combo.mp4` (0:05 a 0:09), `4_cenarios/bridge_A_1080.jpg`, `runes_A_1080.jpg`, `14_guardiao_sacerdote_dos_mortos_1080.jpg` | Leitura do combate | P1 | Linha: fio de até 10 px com ponta clara e corpo até alfa 0,45, enchendo só nos últimos 30%; Runas: preenchimento até 0,25 até os últimos 30% | `gameplay-engineer` (`GroundLook`), `environment-artist` (`rune_floor.gdshader`), `combat-feel-director` (aprovar) |
| Golpe sofrido | Manter | O herói clareia morno, sem silhueta branca; bordas da tela discretas. | `13_golpe_sofrido_santuario_1080.jpg` | | | | |
| Ultimate (Corte do Juízo) | Manter | Faixa e corte legíveis, anel de pronta no HUD. | `05_ultimate_corte_do_juizo_1080.jpg`, `05_ultimate_720.jpg` | | | | |
| Multidão (legibilidade) | Manter | Em lutas reais (4 a 12 de pé) cada inimigo lê; o teste de 300 só mostra que o herói não some. Barras vermelhas saturadas em grupo viram a mancha mais forte. | `03_multidao_estresse_1080.jpg`, `06_corredores_gpu.jpg`, `videos/v1_luta_cripta.mp4` | | P2 | Barras dos comuns 15% mais escuras e mais finas; só elites com moldura | `ui-ux-designer` |
| HUD em luta | Manter | Medalhão, barras e losangos legíveis. As correntes do cenário passam por trás do relógio no topo; os textos do topo (Cinzel fino em versalete) têm contraste baixo sobre o teal. | `02_hud_luta_1080.jpg`, `6_identidade/hud_topo_recorte_1080.jpg`, `hud_rodape_recorte_1080.jpg` | | P2 | Faixa de véu escuro de 60 px atrás do topo; peso de fonte um passo acima no relógio e no "Sala N de 11" | `ui-ux-designer` |

## 4. Cenários

| Elemento | Veredito | Problema | Evidência | Impacto | Prior. | Solução proposta | Responsável |
|---|---|---|---|---|---|---|---|
| Recompensas, loja, altar, Provação (objetos) | **Refazer** | Primitivos (`PrismMesh`, `SphereMesh`, `BoxMesh`) sem sombreamento em cores puras pairando sobre portas e itens; cubo violeta na Provação. | `4_cenarios/salao_loja_1080.jpg`, `altar_camara_1080.jpg`, `provacao_camara_1080.jpg`, `3_gameplay/04_cripta_sala_vencida_recompensa_1080.jpg` | Em toda sala vencida; a peça mais "protótipo" do jogo | **P0** | Disco de ouro velho com o medalhão pintado (já existe em `assets/ui/boons` e `assets/ui/events`) sobre pedestal baixo de pedra, sombreado, girando a 20 graus/s, halo da cor da recompensa com maior canal até 1,0 | `environment-artist`, `ui-ux-designer` |
| Paleta do cenário (todas as salas) | Melhorar | Três manchas saturadas no cenário ao mesmo tempo (abismo violeta, portal verde, velas laranja). O Ember & Blade deixa o cenário num tom frio só e satura só os efeitos. Medido pelo art-director hoje: p90 de saturação 35 a 51 no salão e na câmara contra 24 a 25 na referência. | `01_salao_vitrine_1080.jpg`, `3_gameplay/01_luta_salao_1080.jpg`, `5_morvath/02_fase1_1080.jpg` | Os efeitos do combate perdem destaque | P1 | Bruma do abismo e nuvens da câmara com saturação até 0,45; portal como único verde; metade das velas restantes apagadas ou mais frias | `environment-artist` |
| Portal verde do salão | Melhorar | Mancha verde chapada sem forma (chama de cor pura), a área mais saturada do salão. | `01_salao_vitrine_1080.jpg`, `03_multidao_estresse_720.jpg` | Ponto focal da sala de abertura | P1 | Véu com profundidade (gradiente do centro escuro para a borda), veios mais claros que se movem, verde puxado para o esmeralda corrompido escuro com núcleo pálido | `environment-artist` |
| Salão das Catacumbas | Manter | Composição da pintura de referência, chão com rosa-dos-ventos, balaustradas e velas. Estátuas, moldura do portal e ruínas seguem provisórias (KayKit e formas próprias). | `01_salao_vitrine_1080.jpg`, `navegador_compat_hall.jpg` | | P2 | Modelos do `docs/art/meshy_asset_plan.md` quando o Daniel liberar créditos | `art-director` (prompts), Daniel |
| Cripta dos Esquecidos | Melhorar | Escura demais (luma média 37 contra 55 a 70 da meta), paredes do KayKit em tijolos grandes de brinquedo, colunas com capitel em "Y". | `crypt_A_1080.jpg`, `crypt_B_1672.jpg`, `videos/v1_luta_cripta.mp4` | Arena frequente | P1 | Clareiras pálidas pintadas no chão e luz de preenchimento só do chão; capitel com ábaco ou coluna quebrada; tijolos menores pela cantaria do `Masonry` | `environment-artist` |
| Salão das Fendas | Manter | Pontes, lábios quebrados e bruma violeta funcionam; o violeta de baixo é saturado demais (ver paleta). | `rift_A_1080.jpg`, `rift_B_1672.jpg` | | P2 | Bruma com menos saturação | `environment-artist` |
| Jardim das Raízes Mortas | Melhorar | Árvore sem copa nem flores (a prancha 07 tem copa violeta, que é o motivo da sala); cristais verde-menta chapados e acesos, não "esmeralda corrompido escuro". | `garden_A_1080.jpg`, `garden_B_1672.jpg` | Arena-assinatura | P1 | Copa com cartões de folhagem e pétalas lilás apagadas caindo; cristais com valor 0,35 e brilho só na aresta | `environment-artist` |
| Santuário Desmoronado | Melhorar | Nave de colunas iguais em grade com capitel em "Y"; lê como tabuleiro. Bom chão e fachos de lua. | `sanctuary_A_1080.jpg`, `sanctuary_B_1672.jpg`, `3_gameplay/14_guardiao_sacerdote_dos_mortos_1080.jpg` | Casa do guardião | P1 | Três silhuetas de coluna (inteira com capitel, quebrada alta, toco) e duas alturas; entulho entre elas | `environment-artist` |
| Ponte dos Condenados | Manter | Melhor arena de luta: profundidade, correntes, céu, plataformas. | `bridge_A_1080.jpg`, `bridge_B_1672.jpg` | | | | |
| Câmara das Runas | Melhorar | Lajes armadas em âmbar sólido saturado, um terço do chão aceso; pilares com listras laranja. Lê como piso de discoteca. | `runes_A_1080.jpg`, `runes_B_1672.jpg` | Leitura do perigo e da mira | P1 | Ver "Avisos no chão" (área 3) | `environment-artist` |
| Provação e Altar (salas) | Refazer | Caixas flutuando no vazio liso (preto-violeta, azul-petróleo) com o corte das paredes à mostra; parecem maquete. | `provacao_camara_1080.jpg`, `provacao_camara_1672.jpg`, `altar_camara_1080.jpg`, `altar_camara_1672.jpg` | Eventos raros, mas a quebra é total | P1 | Fundo com bruma e silhuetas de ruína em duas camadas, como as arenas; nenhum corte de parede visível na câmera | `environment-artist` |
| Navegador (Compatibility) | Manter | Mais escuro e plano, aceitável como secundário. | `navegador_compat_*.jpg` | | P2 | | |

## 5. Morvath

| Elemento | Veredito | Problema | Evidência | Impacto | Prior. | Solução proposta | Responsável |
|---|---|---|---|---|---|---|---|
| Câmara do Selo (cenário) | Manter | Composição da prancha 07: anel de balaustrada com velas, fachada com a porta selada, torre, correntes, céu azul-marinho, selo com o leão. Janelinhas da muralha distante são retângulos laranja chapados; nuvens violeta laterais saturadas. | `5_morvath/00_camara_do_selo_vitrine_1080.jpg`, `01_entrada_camara_1080.jpg`, `02_fase1_1080.jpg` | Melhor cenário do jogo | P2 | Janelas com caixilho e luz em degradê (ou menos e menores); nuvens com saturação até 0,45 | `environment-artist` |
| Entrada de Morvath | Melhorar | Aos 1,2 s a entrada não tem momento: ele já está parado sobre o selo, o anel espectral não aparece no quadro, e o nome "A Câmara do Selo" cai sobre as janelas laranja sem véu. | `01_entrada_camara_1080.jpg`, `videos/v5_morvath_fase1.mp4` (0:00 a 0:03) | Primeira impressão do chefe | P2 | Nome da sala com véu escuro; 1,5 s de entrada (Morvath erguendo-se do selo com o anel espectral e as almas, câmera parada) | `gameplay-engineer` (tempo), `environment-artist` (efeito), `ui-ux-designer` (véu) |
| Silhueta de Morvath | Manter | Alto, coroa pálida, manto violeta, gancho de ouro velho; lê em qualquer fase. Quando o herói passa atrás dele, o corpo do chefe cobre o herói por inteiro (sem raio-x contra o chefe). | `00_`, `06_fase2_runas_de_invocacao_1080.jpg` | | P2 | Raio-x do herói também atrás de Morvath (como atrás da multidão) | `environment-artist` (shader do raio-x) |
| Animações de Morvath | Manter | Gira em vez de saltar (T5b), foice com as duas mãos, arremesso, investida com preparo. A "foice" é a lâmina do modelo (ele não tem foice). | `04_fase1_foice_aviso_1080.jpg`, `04b_fase1_laminas_das_almas_1080.jpg`, `videos/v5_morvath_fase1.mp4` | | P2 | Foice como arma própria no modelo quando houver créditos (pedido do Daniel) | `art-director` (prompt Meshy), Daniel |
| Fase 1: foice e lâminas | Manter | Meio círculo vermelho com runas na borda e meias-luas violeta frias com miolo claro (prancha 07). O preenchimento vermelho da foice cobre o herói por inteiro. | `04_`, `04b_` | | P2 | Preenchimento da foice até 0,35 com o herói recortado (`hero_hole`) | `environment-artist` |
| Fase 2: ritual | Melhorar | Domo ciano saturado, círculo de runas verde, erupção vermelha e o anel petróleo do herói numa área de 400 px: quatro cores saturadas brigando. O ciano do domo é o mesmo matiz do anel do herói. | `05_ritual_1080.jpg`, `06_fase2_runas_de_invocacao_1080.jpg`, `videos/v6_morvath_ritual.mp4` | Leitura do herói e do perigo | P1 | Domo mais translúcido e no esmeralda corrompido escuro (matiz 165, valor 0,7), runas de invocação no mesmo matiz e mais finas; o vermelho só no que fere | `environment-artist` |
| Fase 3: maldição e camadas | Melhorar | Erupções em magenta quase opaco com colunas ciano, sobrepostas à foice; o herói dentro de uma erupção fica tingido de rosa. | `07_fase3_maldicao_erupcoes_1080.jpg`, `08_fase3_foice_e_erupcao_em_camadas_720.jpg`, `videos/v7_morvath_fase3.mp4` | Perigo maior que a necessidade | P1 | Miolo das erupções a 0,35 no vermelho da assinatura (não magenta), aro sem ciano, coluna só no instante do golpe | `environment-artist`, `combat-feel-director` (leitura) |
| Fase 4: tempestade | Melhorar | Seis faixas vermelhas com divisas cobrem perto de metade do chão, mais meias-luas violeta, orbes lilás e partículas ciano em volta do herói. É legível como "onde não ficar", mas o herói some na mistura. | `09_fase4_tempestade_1080.jpg`, `09b_fase4_tempestade_faixas_720.jpg`, `10_fase4_portal_1672.jpg`, `videos/v8_morvath_fase4_tempestade.mp4` | Fase decisiva da luta | P1 | Faixas com aro e divisas, preenchimento até 0,12; partículas espectrais até 0,12 m e nunca a menos de 1,5 m do herói | `environment-artist`, `combat-feel-director` |
| Quadro de impacto (preto e branco) | Manter | Forte e raro (quebra de fase), lê como golpe decisivo. | `08b_quadro_de_impacto_preto_e_branco_720.jpg`, `videos/v5_morvath_fase1.mp4` (0:17) | | | | |
| Vitória e selagem | Melhorar | O poder volta ao altar e o portal se fecha; a legenda "A magia de Morvath se desfaz..." é versalete fino sem véu sobre a balaustrada. O emblema "Morvath foi selado" com o leão é forte. | `11_vitoria_selagem_1080.jpg`, `12_morvath_foi_selado_emblema_1080.jpg`, `videos/v9_morvath_vitoria.mp4` | Fecho emocional da partida | P1 | Legenda em Alegreya Sans, corpo maior, véu escuro; leão do emblema com brilho crescente de ouro velho | `ui-ux-designer` |

## 6. Identidade visual

| Elemento | Veredito | Problema | Evidência | Impacto | Prior. | Solução proposta | Responsável |
|---|---|---|---|---|---|---|---|
| Tipografia | Manter | Cinzel em versalete para títulos e Alegreya Sans para corpo, em todas as telas. Cinzel fino perde contraste em tamanho pequeno (topo do HUD, nome do golpe, legenda da vitória). | `6_identidade/hud_topo_recorte_1080.jpg`, `5_morvath/11_vitoria_selagem_1080.jpg`, `2_menus/*` | | P2 | Regra: Cinzel só a partir de 24 px a 1080; abaixo disso, Alegreya Sans Bold | `ui-ux-designer`, `art-director` (regra no guia) |
| Paleta | Melhorar | Ouro velho e ardósia consistentes na interface. Barras de vida e Magia em vermelho e azul puros e brilhantes, mais saturadas que o resto da HUD; no cenário, ver área 4. Não existe `docs/art/art_direction.md` com a paleta em valores. | `6_identidade/hud_rodape_recorte_1080.jpg`, `3_gameplay/02_hud_luta_1080.jpg` | Base para todas as frentes | P1 (documento), P2 (barras) | Escrever o `docs/art/art_direction.md` (paleta com valores, matizes reservados: esmeralda da Emeth, petróleo do herói, verde espectral de Morvath, violeta frio, vermelho só de perigo, ouro velho; regras de leitura); barras com saturação 15% menor | `art-director` |
| Ícones e medalhões | Refazer (sistema) | Três famílias convivem: medalhões pintados (7 Bênçãos e os eventos), ícones vetoriais chapados (as outras Bênçãos, cartas da Provação, Salmos) e primitivos 3D (recompensas no mundo). | `2_menus/bencao_cartas_1080.jpg`, `provacao_cartas_1080.jpg`, `salmo_carta_1080.jpg`, `4_cenarios/salao_loja_1080.jpg` | A coleção não parece uma coleção | P1 | Regra: tudo que se coleciona (Bênção, Elo, Salmo, recompensa) tem medalhão pintado no mesmo aro; vetor só para ações e marcas pequenas do HUD e das placas | `art-director` (prancha e regra), `technical-artist` (recorte), `ui-ux-designer` |
| Molduras | Manter | Uma linguagem: tinta escura, filete de ouro velho, losango no meio; o livro tem a sua (pergaminho), de propósito. Painéis escuros dentro do livro quebram a regra (área 1). | `2_menus/pause_1080.jpg`, `defeat_1080.jpg`, `1_titulo_livro/05_livro_dons_furia_plena_1080.jpg` | | P2 | Ver área 1 | |
| Raridades | Manter | Uma cor por raridade em todo o jogo (rara azul, épica violeta, lendária ouro velho, comum no metal), nas cartas, na Provação e em Suas Bênçãos. | `bencao_cartas_1080.jpg`, `bencao_troca_raridade_1080.jpg`, `provacao_cartas_1080.jpg`, `suas_bencaos_painel_1080.jpg` | | | | |
| Símbolos (leão, espada, sem cruz nem sol) | Melhorar | No jogo: leão no selo, nos estandartes, na vitória e no Como Jogar; espada na Câmara. A exceção é a arte do título (cruzes), ver área 1. | `5_morvath/12_morvath_foi_selado_emblema_1080.jpg`, `2_menus/howto_1080.jpg`, `1_titulo_livro/01_titulo_1080.jpg` | Identidade e regra do cânone | P1 | Decisão do Daniel sobre a arte do título | Game Director |
| Coerência do herói entre mídias | Manter | Cabelo vermelho, cachecol petróleo e Emeth verde no título, no Livro, no retrato do HUD e no modelo 3D. A Emeth do retrato do Livro não tem a guarda de chifres. | `01_titulo_1080.jpg`, `04_livro_o_guerreiro_1080.jpg`, `20_inimigos_todos_frente_recorte_1080.jpg` | | P2 | Ver área 1 | |
| Assets provisórios | Melhorar | Provisórios visíveis: paredes, escadas, barris e peças do KayKit (tijolos grandes de brinquedo), armas do KayKit nos inimigos, estátuas e moldura do portal do salão, primitivos das recompensas, janelas laranja chapadas. Definitivos (com a licença do Meshy a registrar): Guerreiro, Emeth, os nove inimigos. | `4_cenarios/crypt_A_1080.jpg`, `01_salao_vitrine_1080.jpg`, `20_inimigos_todos_frente_recorte_1080.jpg` | Qualidade percebida | P1 | Plano por ordem de ganho: recompensas, cantaria nas peças de parede do KayKit, armas do Meshy, estátuas e portal | `environment-artist`, `technical-artist`, Daniel (créditos e licença) |

---

## O que não foi avaliado (sem captura nesta pasta)

- Transições entre título, Livro e partida (escurecimento, entrada na primeira sala): não há vídeo; nenhum veredito.
- Elites em luta (contorno, barra de armadura, quebra): só o laboratório (`3_gameplay/22_`, `23a_`, `23b_`).
- Sala da Fonte e laje da Provação numa sala de luta em Forward+ a 1080 (a laje está em `2_menus/provacao_laje_placa_1080.jpg`, com o
  fundo da fonte).
- Variantes B das arenas a 1080: estão a 1672 x 941 (`4_cenarios/*_B_1672.jpg`), capturadas hoje pelo environment-artist.
- Celular e toque: fora do escopo desta versão.
- Fase 3 com a maldição no momento exato (`--shot-on=boss:cursed` não disparou na nova tentativa): vale a captura do art-director de hoje (`5_morvath/07_`) e o vídeo `v7`.

## Depende de decisão do Daniel ou de asset que não existe

1. Cruz na arte do título e a maga aprovada da prancha 08 (arte nova; IA registrada no `docs/steam-ia.md`).
2. Visual de Ahk para a cena de abertura do Livro (até lá, silhueta).
3. Licença do Meshy registrada (P1-3 do technical-artist) antes de qualquer modelo novo.
4. Créditos do Meshy (546 sobram; o Daniel pediu para segurar): armas dos inimigos, foice de Morvath, estátuas e moldura
   do portal do salão (`docs/art/meshy_asset_plan.md`).
5. Medalhões pintados das Bênçãos, Elos e Salmos que faltam (prancha nova do PO ou pintura nossa).
6. Nome do especial no texto ("Seta de Luz" contra o visual de onda da lâmina, D-69).

## Ordem recomendada (do maior ganho ao menor)

1. P0: recompensas, loja, altar e Provação sem primitivos.
2. P1 de leitura do combate: avisos (linha, Runas, tempestade, erupções, ritual) e família de verdes e cianos em volta do herói.
3. P1 de cenário: um tom só (bruma, nuvens, portal, velas), clareiras e valor nas arenas escuras, colunas, Jardim, salas de evento.
4. P1 de identidade: `docs/art/art_direction.md`; sistema de medalhões; título (depois da decisão).
5. P1 de interface: Livro (abertura ilustrada, árvore com moldura e motivos), Compêndio com desenho, vitória.
6. P2: o resto das tabelas.

---

## Prompt consolidado para o Claude Code

```text
Contexto: Crônicas de Eterra: A Selagem, Godot 4.7, branch arpg-3d (auditoria feita no commit dd1f5ba).
Leia CLAUDE.md, docs/development/agent_workflow.md, docs/arte/estetica.md e
docs/gallery/audit_2026-11-18/AUDITORIA.md (evidências na mesma pasta). Regras: nada copiado de outros jogos;
texto ao jogador em português do Brasil, sem travessão, só em data/text_pt.tres; símbolo do herói é o leão, nada de
cruz nem sol; não inventar lore; não gastar créditos do Meshy sem o Daniel; cada entrega com capturas reais na GPU
(tools/gpu.sh shot, 1920x1080 e 1280x720) antes e depois, revisadas pelo art-director; testes GUT verdes.
Entregar em uma versão MVP só, na ordem abaixo.

Tarefa 1 (P0, environment-artist + ui-ux-designer): trocar os primitivos sem luz das recompensas (Rooms.gem_mesh),
da loja, do altar e da Provação por um disco de ouro velho sombreado com o medalhão pintado da recompensa
(assets/ui/boons, assets/ui/events; DoorGlyph.of_reward para a escolha), sobre pedestal baixo de pedra, girando a
20 graus/s, halo da cor da recompensa com maior canal até 1,0 (ScreenTone). Aceite: nenhuma BoxMesh, PrismMesh ou
SphereMesh unshaded em --start=shop, --start=altar, --start=trial e numa sala vencida; recompensa reconhecível pelo
símbolo a 1280x720 sem ler a placa.

Tarefa 2 (P1, gameplay-engineer + environment-artist, aprovação do combat-feel-director): avisos no chão.
Linha (besteiro, bote do esqueleto): fio de até 10 px a 1080, ponta de longe clara, corpo até alfa 0,45, enchendo
só nos últimos 30% do preparo (GroundLook). Runas: preenchimento até 0,25 até os últimos 30%, sem listras acesas
nos pilares em repouso (rune_floor.gdshader). Tempestade de Morvath: preenchimento até 0,12, aro e divisas ficam.
Erupções: miolo 0,35 no vermelho da assinatura, sem magenta, aro sem ciano. Foice: preenchimento até 0,35 com o
herói recortado (hero_hole). Aceite: em capturas de --boss-only=storm, --boss-hp=0.3 e --arena=runes o herói lê
com as próprias cores dentro de qualquer aviso; área vermelha ou âmbar saturada abaixo de 12% da tela fora da
tempestade.

Tarefa 3 (P1, environment-artist): família de verdes. Domo do ritual mais translúcido no esmeralda corrompido escuro
(matiz 165, valor 0,7), runas de invocação no mesmo matiz e mais finas; partículas espectrais até 0,12 m, maior canal
até 0,9, nunca a menos de 1,5 m do herói. Aceite: nenhuma bolha verde ou ciano numa caixa de 300x300 px em volta do
herói em capturas do ritual, da fase 3 e da fase 4.

Tarefa 4 (P1, environment-artist): cenário num tom só. Bruma do abismo e nuvens da Câmara com saturação até 0,45;
portal do salão com profundidade (centro escuro, borda e veios claros, esmeralda corrompido) e como único verde da
sala; mais grupos de velas apagados ou frios; clareiras pálidas pintadas no chão (catacomb_floor.gdshader e chãos das
arenas) e luz de preenchimento do chão na Cripta. Aceite: p90 de saturação do quadro sem efeitos até 32 no salão e na
Câmara; luma média do quadro de luta entre 55 e 70 em todas as arenas.

Tarefa 5 (P1, environment-artist): arquitetura. Colunas do Santuário e da Cripta sem o capitel em "Y": três
silhuetas (inteira com capitel e ábaco, quebrada alta, toco) e duas alturas, entulho entre elas. Jardim: copa com
cartões de folhagem e pétalas lilás apagadas caindo; cristais com valor 0,35 e brilho só na aresta. Provação e
Altar: fundo com bruma e silhuetas de ruína em duas camadas, nenhum corte de parede visível na câmera. Janelas
distantes da Câmara com caixilho e luz em degradê.

Tarefa 6 (P1, art-director): escrever docs/art/art_direction.md: paleta com valores (ardósia, ouro velho
UiKit.OLD_GOLD, esmeralda da Emeth, petróleo do herói, verde espectral e violeta de Morvath, vermelho só de perigo,
cores de raridade de Boon.RARITY_COLOR), regras de leitura da tela, regra de tipografia (Cinzel a partir de 24 px a
1080, abaixo Alegreya Sans Bold) e regra de ícones (tudo que se coleciona tem medalhão pintado no mesmo aro; vetor só
para ações e marcas do HUD e das placas). Depois, a prancha de medalhões das Bênçãos, Elos e Salmos que faltam,
para o Daniel aprovar (sem gerar nada sem ele).

Tarefa 7 (P1, ui-ux-designer): Livro de Ahk. Árvore de Dons com moldura de couro e cantos de metal (prancha 05),
motivos da prancha 09 por efeito real de cada Dom, trancado com o motivo apagado e o nível pequeno; abas como fitas
de couro e botões em ouro velho gravado; abertura com vinheta em tinta e capitular (Ahk em silhueta até o Daniel
aprovar o visual). Compêndio: página de inimigo com o desenho dele em traço a partir do nosso modelo assado
(technical-artist faz o render), desconhecido como silhueta; "???" juntados numa linha "N por descobrir".

Tarefa 8 (P1, ui-ux-designer): vitória. Legenda da selagem em Alegreya Sans com véu escuro e corpo maior; halo do
emblema em degradê radial (sem disco chapado); o leão do emblema com brilho de ouro velho crescendo em 0,6 s.

Tarefa 9 (P1, QA): capturar elites em luta (--stress=6 --stress-ids=skeleton_elite,mage_elite,guard_elite) e um
vídeo do título ao Livro e à primeira sala; o art-director decide se as elites precisam de mais ouro velho.

Tarefa 10 (P2, vários): ouro sobe ao lado dos números (ui-ux-designer); véu de 60 px atrás do topo do HUD e da
entrada do nome da sala; barras do HUD 15% menos saturadas; pausa sem a fileira de Bênçãos do HUD nem saudações por
cima; cartas com descrição curta centralizadas; números da Provação sem decimal (gameplay-engineer); Juramentos sem
o logotipo fantasma atrás do título; feiticeiro com o cajado inclinado e "lift" 0,3 (technical-artist); raio-x do
herói também atrás de Morvath (environment-artist).

Pendências que só o Daniel decide (perguntar pelo Game Director, não implementar antes): cruz na arte do título e
a maga da prancha 08; visual de Ahk; nome do especial; créditos do Meshy para armas, foice, estátuas e portal;
licença do Meshy registrada.
```

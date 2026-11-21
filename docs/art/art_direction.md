# Direção de arte de A Selagem: o guia em valores

> **A revisar pelo art-director.** Primeira versão consolidada pelo game-director em 2026-11-18 (commit `f83ccff`), a
> pedido da diretriz do PO de art polish (`docs/art/po_directive_art_polish_2026-11-18.md`). Fontes: `docs/arte/estetica.md`
> (análise das referências e histórico de cada ciclo, que continua valendo), a auditoria
> `docs/gallery/audit_2026-11-18/AUDITORIA.md`, as medidas do C18 (`docs/gallery/c18/README.md`) e as constantes do
> código citadas em cada linha. Onde um número é proposta e não medida, está escrito "proposta". O dono deste documento
> é o `art-director`; o backlog de arte está em `docs/art/art_polish_backlog.md`.

## 1. Identidade em cinco frases

1. **Fantasia sombria de aventura, não terror**: catacumbas frias, monumentais, sobre o abismo; nada de gore, nada de
   susto. A luz vem de Elun e é morna, rara e preciosa.
2. **O cenário é calmo e frio; só o que importa satura.** Ardósia e azul-petróleo no fundo, ouro velho nos acentos;
   a cor forte é do herói, do perigo e dos efeitos (a lição do Ember & Blade, `estetica.md` 1).
3. **O herói é sempre legível**: cabelo vermelho, cachecol azul-petróleo, Emeth esmeralda com ouro. Nada brilha por cima
   dele; nada tem a cor dele.
4. **O leão é o símbolo** (Hanokh e Elun, cânone). A espada erguida é dos guardiões (a Câmara do Selo). **Nunca cruz,
   nunca sol**, nem em glifo pequeno.
5. **Dez coisas bem acabadas valem mais que cinquenta provisórias** (o PO, 2026-11-18). Cada efeito novo precisa
   provar que melhora a leitura.

## 2. Paleta em valores

Matiz em graus (HSV), saturação e valor de 0 a 1. "Material" é a cor de superfície; "luz" é cor que pode passar de 1 (só
abaixo do limiar do glow, 1,3, `Game.GLOW_THRESHOLD`); "UI" é cor de interface em sRGB.

### 2.1 Cores reservadas (um dono cada)

| Nome | Dono, e só ele | Valor no código | Matiz | Onde |
|---|---|---|---|---|
| Esmeralda da Emeth | a lâmina, os cortes sem Bênção, a onda do especial | `Combat.EMETH` (0,3; 1,0; 0,45), luz | 133 | `combat.gd`, `emeth.gdshader`, `emeth_wave.gdshader` |
| Petróleo do herói | cachecol, anel no chão, raio-x | `Player.RING_COLOR` 3e9094 | 183 | `player.gd`, `hero_ring.gdshader` |
| Vermelho do perigo | avisos de ataque, golpe sofrido nas bordas | `GroundLook.WARNING_COLOR` (1,0; 0,18; 0,12) | 4 | `ground_look.gd`, `screen.gdshader` |
| Âmbar do perigo de sala | todo perigo de sala (Runas, lajes, seteira, corrente, raiz, planta, nicho, pedras, cristal, urna de óleo), pela gramática SW-G7 (`docs/art/sw_g7_hazard_grammar.md`: divisa em ouro velho escuro, fenda com brasa, aro âmbar); na tela matiz 26 a 34, saturação 0,30 a 0,55, abaixo da Chama (0,6 a 0,85) | `GroundLook.HAZARD_COLOR` (1,0; 0,62; 0,25) | 30 | `ground_look.gd`, `rune_tiles.gdshaderinc` |
| Verde espectral | a necromancia de Morvath (almas, invocação) | `Boss.SPECTRAL` (0,38; 1,55; 1,1), luz | 157 | `boss.gd` |
| Esmeralda corrompido | escudo do ritual, colunas, runas de Morvath | `BossShield.COLOR` (0,315; 0,7; 0,604), saturação 0,55, valor 0,7 | 165 | `boss_shield.gd`, `spectral_column.gdshader` |
| Violeta de Morvath | o corpo, as meias-luas, a fase 4 | `Boss.VIOLET` (0,62; 0,22; 1,2), `SOUL_VIOLET` (0,62; 0,44; 1,3) | 253 a 265 | `boss.gd`, `soul_crescent.gdshader` |
| Violeta da maldição | aura no herói, selo do HUD | `CurseAura.COLOR` (0,62; 0,32; 0,95) | 269 | `curse_aura.gd` |

Regras:
- Duas cores reservadas que podem aparecer juntas ficam a **30 graus de matiz ou mais**, ou separadas por valor (0,2 ou
  mais). Exceções conhecidas, a conferir: Emeth (133) e verde espectral (157) a 24 graus, separados pelo valor e pelo
  lugar (a Emeth está na mão do herói, o espectral no chão e nos mortos); esmeralda corrompido (165) e petróleo do herói
  (183) a 18 graus (ART-05.8).
- O vermelho do perigo não aparece em nada que não fira. Hoje os estandartes do leão violam isso (ART-02.4, Q-22).
- Ninguém além do herói usa o petróleo saturado; ninguém além da Emeth usa o esmeralda vivo.

### 2.2 Ouro velho (as seis definições de hoje)

| Uso | Valor | Tipo | Onde |
|---|---|---|---|
| Moldura, filete e texto de destaque da interface | `UiKit.OLD_GOLD` 8e7444 (matiz 39, saturação 0,52, valor 0,56) | UI | `ui_kit.gd` |
| Ouro que lê no pergaminho do Livro | `Book.GILT` (0,5; 0,36; 0,15) | UI | `book.gd` |
| Lendária | `Boon.RARITY_COLOR[3]` d4ad66 (matiz 39) | UI | `boon.gd` |
| Aço das elites, ouro pintado nas figuras | `CrowdRenderer.GILD_COLOR` (0,62; 0,46; 0,22) | material | `crowd_renderer.gd`, `crowd.gdshader` |
| Disco das recompensas | `RewardGem.GOLD` (0,66; 0,5; 0,26) | material | `reward_gem.gd` |
| Fio de ouro dos efeitos (onda, Ômega, estrela do especial) | `Fx.OLD_GOLD` (0,95; 0,72; 0,3); centelhas `EnemyFx.OLD_GOLD` (1,5; 1,1; 0,5) | luz | `fx.gd`, `enemy_fx.gd` |

Regra: ouro velho tem **matiz entre 34 e 42 e saturação até 0,6** em material e interface; nunca amarelo vivo (matiz
acima de 48 com saturação acima de 0,7). Em luz, o maior canal fica abaixo do limiar do glow. Os seis valores não se
unificam (luz e material não são o mesmo número), mas cada constante aponta para esta tabela (ART-02.7).

### 2.3 Cenário e interface

| Nome | Valor | Onde |
|---|---|---|
| Tinta da interface | `UiKit.INK` 0c0a0e | painéis, cartas, pausa |
| Pergaminho | `UiKit.PARCHMENT` d8c8a8; tinta do livro `Book.INK` (0,16; 0,11; 0,07), apagada `FADED`, rubrica `RUBRIC` (0,47; 0,13; 0,09) | Livro de Ahk |
| Marfim | (0,97; 0,93; 0,84) | texto principal, glifos, foco |
| Raridades | comum no metal, rara 6f9be6 (218), épica b07ae6 (270), lendária d4ad66 | uma cor por raridade em todo o jogo |
| Pedra do cenário | ardósia fria, matiz do ar por sala (`RoomMood`, `air()` de cada look) | `masonry.gdshader`, `catacomb_floor.gdshaderinc` |

## 3. Hierarquia de leitura (luma e saturação por camada)

Medido com `python3 -I tools/frame_stats.py` (imagem reduzida a 640 px, faixa de TV; luma média `YAVG`, saturação p90
`SATHIGH`; "violeta" = matiz 250 a 320 com saturação acima de 60%). Referência do Ember & Blade medida pelo art-director em
2026-11-18: saturação p90 de 24 a 25 e luma de 67 a 75.

| Camada | Regra | Medido no C18 (depois) |
|---|---|---|
| Quadro de luta inteiro | luma média 55 a 70 | 55 a 68 em toda arena (`c18/README.md`) |
| Cenário sem efeitos | saturação p90 até 32 | salão 25 a 28, câmara 26 a 31, arenas 10 a 29 |
| Cena estilizada (`--scene --hue`, 2026-11-20) | saturação p50 de **0,30 a 0,45** no matiz do bioma, luma p50 45 a 65; matiz de cada bioma na matriz do `benchmark_hades2_style.md` 7.2 (vizinhos a 15 graus ou mais) | Salão 0,38 a 0,41 / 54 a 61 |
| Chão nu (200 x 150, só laje) | p90 menos p10 até 30; caixas a 6 m diferem 10 ou mais (luz, material, marcos; não ruído) | Salão 18 a 32 |
| Moldura (laterais e faixa de perto, caixas do benchmark) | luma p50 até 0,65 do meio; faixa de perto até 0,70 quando mais da metade é chão andável; sat 0,30 ou mais | Salão laterais 0,45 a 0,60, perto 0,59 a 0,66 |
| Hub | `hub_spec_art.md` 4.2 emendada: cena 50 a 65 e sat 0,25 a 0,35, praça 60 a 75, estação 1,8 vez a praça, bordas até 0,70 | cena 52 a 56, estações 1,8 a 3,2 |
| Violeta saturado | até 5% da tela | 0,0 a 3,6%; fase 4 7,6% (exceção aceita: meias-luas e veios, ART-05.6) |
| Vermelho saturado (perigo) | proposta: até 1,5% da tela fora dos últimos 30% de um aviso | fase 3 3,0% (ART-05.2, a corrigir) |
| Âmbar saturado (Runas) | até 12% da tela em preparo | 1,1% no quadro medido |
| Chão | valor médio 45 a 60 na câmera do jogo; clareiras pálidas para o olho descansar | Cripta 57, Santuário 62 a 68 |
| Fundo além da sala | mais escuro que o chão, nunca preto puro e nunca cinza liso | Cripta ainda cinza liso (ART-03.1) |
| Multidão | cinza claro sobre o chão escuro, cor apagada; a forma separa os papéis | aprovado na auditoria |
| Elites e guardiões | o mesmo corpo com aço em ouro velho, contorno escuro fino e borda fraca | a medir em luta (ART-09.1) |
| Herói | cerca de 130 px a 1080; contraste próprio, nunca coberto sem raio-x | aprovado; falta atrás de Morvath (ART-05.3) |
| Caixa de 300 x 300 px em volta do herói | verde e ciano até 2%; rosa só da maldição | fase 4 1,9%; erupção 0,0% |
| HUD | ouro velho e marfim sobre tinta; só vida, Magia e raridades com cor forte | ok |

Ordem de destaque na tela, do mais forte ao mais fraco: **aviso que vai ferir agora > herói > inimigo que prepara >
recompensa e porta > inimigos parados > efeitos do herói depois do acerto > cenário**. Qualquer coisa que inverta essa
ordem num quadro de luta é defeito.

## 4. Materiais

- **Pedra**: cantaria triplanar da `Masonry` (`masonry.gdshader`), ardósia fria com o matiz do ar da sala; juntas escuras,
  quinas gastas; nunca a textura de tijolo grande do KayKit à vista (ART-03.1). Chão em lajes com clareiras pálidas
  (`clearing*` no `catacomb_floor.gdshaderinc`).
- **Ouro velho**: metal gasto, especular baixo, mais escuro nas cavidades; nunca dourado novo.
- **Pano**: estandartes desbotados, bordas gastas, um rasgado por sala no máximo; cor dos estandartes pendente (Q-22).
- **Osso e pano dos inimigos**: osso marfim apagado, pano vermelho-ferrugem apagado (não o vermelho do perigo), metal
  escuro; o brilho só nos olhos, gemas e orbes (`paint_glow`).
- **Cristal**: esmeralda corrompido escuro com brilho só na aresta (`crystal_edge.gdshader`); o cristal vivo é só da Emeth.
- **Peças interativas**: pedra do salão e ouro velho, iluminadas pela sala, sem luz própria; o esmalte da recompensa é a
  única cor (seção 6).

## 5. Luz

- Uma chave fria por sala (lua ou facho), braseiros e velas quentes só como acento; metade das velas de borda apagadas.
- Sombras por sala no Forward+: no máximo 6 luzes com sombra, o que as salas usam hoje (`e5_spec`, C12); fachos sem sombra no Compatibility.
- Preenchimento só do chão quando a sala fica escura (`FLOOR_LAYER` 64, Cripta e Provação), nunca uma omni que clareia a
  parede inteira.
- Chamas: núcleo âmbar, nunca branco; maior canal na tela até 226 (`ScreenTone.SAFE`; teto absoluto 235). Proposta
  ART-02.3: nenhum pixel com os três canais acima de 235 num braseiro.
- Fase 4 de Morvath: o ar passa ao violeta por `RoomMood.LAST_BREATH`; herói, multidão e avisos não mudam.

## 6. Objetos interativos e recompensas

### 6.1 Regras
- Nenhum primitivo geométrico de cor pura à vista (cubo, prisma, esfera). Todo objeto que se usa é uma peça do mundo:
  relicário, estela, laje, altar.
- O objeto pousa em algo (relicário, suporte, estela). Flutuar só onde for sinal de longe (sobre a boca da porta), e preso
  a uma haste (ART-01.5).
- Halo abaixo do glow: maior canal até 1,0 no material e 226 na tela (`RewardGem.HALO_PEAK` 0,55 hoje).
- Um material por tipo de recompensa, nenhuma luz própria (desempenho, `RewardGem`).

### 6.2 Leitura
- A recompensa se reconhece pela forma da marca e pela cor do esmalte **antes** da placa, a 720 linhas.
- Meta proposta: disco com 90 px de diâmetro a 1080 na câmera do jogo; marca com 60% da face.

### 6.3 Esmalte por família (proposta de partida para o art-director)

| Recompensa | Marca (`DoorGlyph`) | Esmalte proposto | Por quê |
|---|---|---|---|
| Bênção | aro com o losango das cartas | petróleo escuro (saturação até 0,4, abaixo do petróleo do herói), marca marfim | o poder do herói; fica longe do ouro da moeda |
| Ouro | moeda | sem esmalte: a própria moeda em ouro velho, relevo | a única dourada inteira |
| Romã | romã (medalhão pintado) | carmim apagado (valor até 0,4) | não é o vermelho do perigo |
| Coração | coração | rosa antigo (saturação até 0,4) | separa da romã pelo matiz e da vida do HUD pelo valor |
| Magia | gema | azul-ardósia | a cor da barra de Magia, em valor baixo |
| Fonte | gota | marfim-azulado | água viva, clara e fria |
| Provação | selo rachado (pintado) | lilás acinzentado | o mesmo do selo do HUD |

Teto: saturação do esmalte até 0,5 e valor até 0,45; quaisquer dois a 40 graus de matiz ou 0,2 de valor.

## 7. Iconografia

- **Leão**: o herói, o selo, os estandartes, a vitória, o Como Jogar (campo `lion_sdf.res`, `banner_lion.gdshader`).
  Rampante ou de pé, nunca deitado como enfeite.
- **Espada erguida**: os guardiões dos selos; só na Câmara do Selo e no que for deles. Lâmina larga afinando, guarda curta,
  nunca em forma de cruz (`BossChamber._sword`).
- **Proibido**: cruz (nem em glifo de 16 px, ver QW-117), sol como símbolo de Elun, nome de poder com Elun, "Punho de
  Elun", "Aliança", "Convênio" (D-64 a D-71). Os Selos são as fechaduras do Abismo no cânone: nunca moeda nem item.
- **Medalhões**: tudo o que se coleciona (Bênção, Elo, Salmo, recompensa) tem medalhão pintado no mesmo aro de ouro
  velho; Elo com aro de elos; Salmo com arco ogival e moldura própria. Vetor só para ações (`ActionSlot.mark`), marcas
  das placas (`DoorGlyph`) e glifos pequenos do HUD. Estado hoje: 7 de 26 Bênçãos pintadas (ART-06.2).
- **Círculo no chão**: é de Morvath (avisos, runas, selo) e do Círculo de luz do herói. Arenas não têm círculo fechado nem
  inscrição acesa no chão; o medalhão gravado do salão é a exceção da pintura de referência.
- **Ahk**: o narrador do Livro. Sem rosto até o Daniel definir (Q-03, Q-23); por enquanto voz (epígrafes do cânone) e
  objetos (papiros, pena, tinteiro).

## 8. Interface e tipografia

- Cinzel em versalete para títulos; Alegreya Sans para corpo. Proposta da auditoria: **Cinzel só a partir de 24 px a
  1080**; abaixo disso, Alegreya Sans Bold (topo do HUD, nome do golpe, legenda da vitória).
- Corpo mínimo 14 px a 720 (C17, QW-114). Placas do mundo com maiúsculas de 19 px a 1080 e contraste de 4,5:1 com o
  contorno (`DoorSign.CAP_PX`, `contrast`).
- Uma língua de moldura: tinta escura, filete de ouro velho, losango no meio (`UiKit.page`, `GoldRule`); o Livro tem a
  dele (pergaminho, couro, cantoneiras) e nada de painel escuro de tela dentro dele (ART-07.1).
- Texto sobre cena sempre com véu ou sombra; nada de versalete fino solto sobre o cenário.

## 9. Efeitos (VFX)

- **Teto de brilho**: nada acima do limiar do glow (1,3) sobre o herói; inimigo atingido até `flash_cap` 1,0; o primeiro
  quadro de um golpe forte vai ao marfim, nunca ao branco puro; tela até `ScreenTone.SAFE` 226.
- **Nada sobre o herói**: partículas espectrais a 1,5 m dele ou mais; colunas de luz abrem em volta dele (`hero_hole`) ou
  saem fracas (`Game.column`); brilho do finalizador só 0,2 da luz sobre o corpo.
- **Corte**: fio marfim-menta na borda de ataque, miolo pálido, tinta escura translúcida (alfa até 0,6), varre em 3 quadros
  (C12d).
- **Avisos**: aro e forma sempre; preenchimento fraco até os últimos 30% do preparo (teto 0,35; mira em fio de 6 px,
  faixa até 0,22); cruzamentos não somam (stencil). O aviso enche no quadro do dano (0 a 1 quadro).
- **Orçamento por quadro**: 40 lascas, 8 talhos, 6 explosões (`FxBudget`); números somados por alvo, no máximo 12 na tela
  (`NumberTally`).
- **Raros e caros**: quadro de impacto preto e branco no máximo a cada 10 s; câmera lenta no último abate e no máximo uma
  vez a cada 6 s nos golpes.
- **Cor do efeito diz quem o fez**: esmeralda e ouro = herói; vermelho = vai ferir; violeta e verde espectral = Morvath;
  âmbar = a sala que fere (todo perigo de sala, SW-G7).

## 10. Regras de consistência e de entrega

1. Toda mudança visual relevante entrega antes e depois no **mesmo enquadramento e resolução**: 1920 x 1080 na GPU
   (`tools/gpu.sh shot`) e 1280 x 720 com interface; vídeo quando o que mudou é temporal.
2. Toda captura vem com `frame_stats` (quadro e, quando for o caso, a caixa do herói).
3. Combate: o `combat-feel-director` aprova leitura e tempo; arte: o `art-director` aprova coerência. Testes passando não
   aprovam arte.
4. Desempenho: iGPU na qualidade Baixa a 1280 x 720 sem cair mais de 3 qps da tabela anterior.
5. Nunca uma imagem conceitual (pranchas do PO, IA) como captura de evidência; pranchas são intenção, não modelo.
6. Nada copiado das referências (Hades II, Ember & Blade, Ravenswatch): estudamos valores, tempos e leitura.
7. Arte de IA nova sempre declarada no `docs/steam-ia.md`; nenhum crédito do Meshy sem o Daniel.
8. Nada de lore nova na arte: inscrições sem texto legível, nenhum personagem novo, nenhum símbolo fora da seção 7.
9. Um ajuste de arte não muda regra, colisão, tempo de aviso, dano nem economia; se precisar, vira item de gameplay com
   aprovação.
10. **Nunca pedir ao ChatGPT (ou a qualquer gerador de imagem fora do projeto) só a pintura** (regra permanente do PO,
    2026-11-20). Todo material visual novo pedido fora (cenário, sala, estação, peça) vem com os cinco, e pedido sem os
    cinco volta:
    1. **pintura na câmera real** do jogo: giro 35, inclinação 30, campo de visão 24, Perto 37 m e Longe 54 m, 16:9;
    2. **planta de cima com medidas aproximadas**: contorno do chão, portas e saídas, onde o herói entra, obstáculos que
       colidem, o que dá cobertura, pontos de uso e interações, no mesmo referencial que o jogo usa (diga qual: x leste e
       z norte, ou o (u; v) do `HubPlan`);
    3. **lista ESSENCIAL contra CLIMA**: o que não se corta sem novo layout e o que se corta, reduz ou move se atrapalhar
       a leitura;
    4. **notas de luz, colisão e leitura**: fontes de luz com cor e área, o que colide e o que não, o que precisa ler
       primeiro em 3 s;
    5. **entrega lado a lado** para a reconstrução na Godot (pintura e planta na mesma folha ou par de arquivos com o
       mesmo nome).
    Na reconstrução vale: a planta manda em posição e medida, a pintura em cor, forma e clima, e a câmera do jogo é a
    prova final. A imagem pedida fora é referência (não asset nem evidência, regra 5), fica fora do repositório público
    ou só local em `docs/art/ref/`, e entra no `docs/steam-ia.md` quando for de IA. Exemplo bem feito: o pacote do
    Santuário da Vigília Rev. 02 (`docs/design/po_2026-11-20/santuario_vigilia/`), convertido em
    `docs/art/hv_santuario_vigilia_art.md`.

## 11. Pendências deste guia

- Revisão e assinatura do art-director (números das seções 3, 6.3 e 8 marcados como proposta).
- Cor dos estandartes (Q-22) muda a seção 2.1 e a 4.
- Fonte dos medalhões pintados (Q-24) e o rosto de Ahk (Q-23).
- Medir as elites em luta para fechar a linha da seção 3.

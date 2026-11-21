# SW-G7: gramática visual do perigo de sala

Dono: `art-director`. Para: `environment-artist` (peças, chão, luz) e `technical-artist` (shaders, efeitos, a figura do
nicho). Data: 2026-11-21. Lido: `CLAUDE.md` (perigos RP-06 a RP-17, VFX, estilizado), `docs/backlog.md` (Lote A, A1 e A2;
pacotes do PO de 2026-11-20, P.4), `docs/design/rooms_progression.md` (RP-12, RP-14, RP-18, RP-20, seção 8),
`docs/art/vfx_pass_spec.md` (seções 3 e 4), `docs/art/sworn_reference_ideas.md` (SW-G7), o atlas do PO
(`docs/design/po_2026-11-20/layout_salas/`). Sem Meshy: tudo procedural, KayKit, UAL ou assado que já existe.

Tempo, alcance, dano, faixa e colisão de cada perigo **não mudam** com esta spec: são do `room-designer` e do
`gameplay-engineer` (números em `rooms_progression.md` e no `_stage` do `make_data.gd`). Aqui está só como cada um se
mostra. O `combat-feel-director` aprova o aviso (começo do preparo, alcance lido, impacto, cruzamento com avisos de
inimigo) depois que a peça existir.

---

## 1. A regra em seis frases (vale para todo perigo de sala, de hoje e futuro)

1. **Quem fere é a sala, não um inimigo**: o perigo de sala fala **âmbar** (matiz 26 a 34 na tela); o inimigo fala
   **vermelho** (349 a 4) e carmim ou magenta (330 a 355). Nunca o contrário: nenhum perigo de sala usa vermelho, nenhum
   aviso de inimigo usa âmbar. Nunca verde da Emeth (125 a 145), nunca o violeta de Morvath (253 a 270), nunca o
   esmeralda corrompido (165).
2. **Toda peça que age tem a marca**: a **divisa** (chevron) gravada funda em ouro velho escuro, apontando para onde o
   golpe empurra ou vai. Decoração nunca tem divisa. É a palavra única da gramática: o jogador aprende numa sala e lê em
   todas.
3. **Toda peça viva tem a fenda**: uma fissura escura na própria peça que guarda uma brasa âmbar muito baixa quando o
   perigo está acordado, e que **acende e abre** no preparo. Dormente (antes do progresso 0,34) a fenda é cheia de pó
   claro e sem brasa.
4. **O preparo se lê em três lugares ao mesmo tempo**: a peça se mexe (afunda, ergue, recua, fecha), a fenda acende e o
   chão mostra a área com aro âmbar e preenchimento fraco. Nunca só um deles.
5. **O golpe é curto e claro**: 0,25 s de clarão marfim-âmbar dentro da área, um movimento físico da peça e lascas ou
   poeira; nada acima de 226 na tela, nada branco estourado.
6. **Depois, a peça mostra que gastou**: brasa de 0,4 s (`ArenaHazard.EMBER`), a fenda esfria em 1 s, a peça fica num
   estado "gasto" até a recarga e volta ao repouso no último 0,5 s.

### 1.1 O que distingue o que fere do que é só decoração (checklist de cada peça)

| Sinal | Peça de perigo | Decoração |
|---|---|---|
| Divisa gravada em ouro velho escuro | sim, sempre (1 a 4 por peça) | nunca |
| Fenda com brasa âmbar baixa (acordado) | sim | nunca (rachaduras de decoração são escuras e frias) |
| Ferro escurecido com rebites | moldura, ponteira, aro | só nas grades, gaiolas e lanternas de sempre, sem divisa |
| Junta escura em volta (peça solta do chão) | lajes, nicho | lajes emolduradas têm **moldura saliente clara** (SW-G3); tumulares têm **sulco e leão** (SW-C1); nenhuma tem junta escura larga |
| Âmbar no chão | só no preparo e na brasa | nunca (poças de fogo são manchas macias sem aro, sem divisa) |
| Contorno de tinta das figuras e barra de vida | nunca (nem o esqueleto do nicho) | não se aplica |

Medida do aceite: na captura Perto com o HUD (AC-AT 1), três pessoas da equipe de agentes (art-director,
room-designer, combat-feel-director) apontam as peças de perigo da sala sem errar nenhuma decoração; e a medida
objetiva da seção 4.

---

## 2. Valores comuns

### 2.1 Cor

| Uso | Material ou luz (partida) | Na tela (alvo, estilizado, Forward+) |
|---|---|---|
| Âmbar do perigo, aro e preenchimento | `GroundLook.HAZARD_COLOR` (1,0; 0,62; 0,25), com o cinza das Runas (`fill_grey`) | matiz 26 a 34, saturação 0,30 a 0,55, aro luma 140 a 200 |
| Clarão do golpe | marfim-âmbar (1,0; 0,86; 0,62) | matiz 30 a 40, saturação 0,15 a 0,30, até 226 |
| Brasa da fenda, acordado | (1,0; 0,55; 0,2) a 0,08 da luz | +4 a +8 de luma sobre a fenda escura, saturação até 0,30 |
| Brasa da fenda, preparo | a mesma, subindo a 0,6 da luz nos últimos 30% | luma 120 a 180 dentro da fenda |
| Divisa gravada | ouro velho escuro (0,36; 0,27; 0,13) (o `MEDALLION_GOLD` do hub) | matiz 34 a 42, luma 10 a 20 abaixo da pedra em volta; um lábio claro de 0,02 m no lado da luz |
| Ferro escurecido | `ArenaKit.STY_IRON` | como as gaiolas e correntes |
| Pó do dormente | pedra da sala a 1,25 | sem saturação |

**Âmbar do perigo contra a Chama (Bênção de Sarael, 30 a 38)**: estão no mesmo matiz. Separação pela saturação (perigo
0,30 a 0,55, Chama 0,6 a 0,85), pela forma (perigo é figura geométrica presa ao chão ou à peça: aro, faixa, fenda,
divisa; Chama é língua que sobe, borda serrilhada, sobre inimigos) e pelo lugar. Conferir numa sala com Bênção de Chama e
laje armada juntas (captura do aceite, 4.3).

### 2.2 Tamanhos (legíveis na câmera Perto, 37 m, cerca de 68 px por metro a 1080; Longe cerca de 47)

- Divisa: 0,35 a 0,5 m de abertura, traço 0,07 m (5 px Perto, 3 px Longe), 0,02 a 0,04 m de fundo (só normal e
  sombreado, nada colide). Três divisas encaixadas quando a peça tem direção forte (corrente, seteira); uma quando não.
- Fenda: 0,03 m em repouso, abre a 0,08 a 0,12 m no preparo (pela largura da faixa acesa no shader, não por malha).
- Aro do chão: 0,12 m (a moldura das Runas, `tile_m`), divisas no chão de 0,5 m dentro da área, apontando para o
  empurrão quando há empurrão (como a varredura das Runas, `ArenaHazard.chevron`).

### 2.3 Tempo dos quatro estados (o desenho segue o relógio do `ArenaHazard`, `PlateHazard`, `BandHazard`, `ColumnFall`)

| Estado | O que se vê | Duração |
|---|---|---|
| **Dormente** (antes de `from_progress`) | peça inteira, divisa, fenda cheia de pó claro, nada âmbar | a sala toda |
| **Repouso** (acordado) | peça, divisa, fenda escura com brasa a 0,08 que respira devagar (período 3 s, mais ou menos 0,03) | até armar |
| **Preparo** | movimento da peça nos primeiros 0,15 a 0,3 s (o jogador vê "começou"); aro âmbar inteiro desde o primeiro quadro; preenchimento até 0,25 até os últimos 30%, depois até 0,35 (como os avisos de inimigo, `fill_max`); fenda acende; poeira; som `<nome>_arm` | o do perigo (1,0 a 1,2 s) |
| **Golpe** | clarão marfim-âmbar na área, movimento físico, lascas ou poeira, tremor só se o herói estiver na área | 0,25 s |
| **Depois** | brasa 0,4 s, fenda esfria em 1 s, peça "gasta" até a recarga, volta no último 0,5 s | a recarga |

Nada do desenho muda o quadro do dano: o aviso enche no quadro do golpe (0 a 1 quadro, a regra dos avisos).

### 2.4 Os dois looks e o Compatibility

- Perigo é jogo: existe no clássico e no estilizado, com a mesma forma e o mesmo tempo. No estilizado a peça passa pelo
  `paint_look` da sala (pedra pintada), e o âmbar segue as regras do chão pintado (`style_rim_gain`, `paint_trace`).
- Compatibility: usar os ganhos já medidos para as Runas (`COMPAT_GAIN` 1,6, `COMPAT_FILL`, `COMPAT_TONE`, `COMPAT_GLOW`,
  `COMPAT_STRIKE` do `RunesLook`) para todo aviso âmbar desenhado pelo `GroundLook`, no mesmo padrão neutro (Forward+
  igual). Meta: laje armada pelo menos +30 de luma e saturação 0,35 ou mais sobre a vizinha, no Compatibility.
- Classificação: nenhum perigo ganha o contorno de casca da multidão (`crowd_outline`) nem barra de vida.

---

## 3. Perigo por perigo

Cada item: peça, repouso, preparo, golpe, depois, e onde está hoje o placeholder.

### 3.1 Laje Rachada (RP-06, RP-21; AT-H1 "afunda"). Cripta A e B, Santuário A e B

Hoje: `GroundLook.plate` e `set_plate` (moldura e duas rachaduras em osso apagado, `PLATE_REST_COLOR`; âmbar da borda para
o meio). Placeholder até esta peça.

- **Peça (3 x 3 m)**: a laje solta do chão por uma **junta escura** de 0,06 m em volta (luma 25 a 35 abaixo do chão),
  com o lado de dentro da junta virado para a luz um pouco mais escuro (lê como degrau para baixo); quatro **divisas**
  gravadas de 0,4 m, uma no meio de cada lado, apontando para o centro ("aqui"; nenhuma linha passa pelo centro, então
  não é cruz); **duas rachaduras** que não se cruzam, de canto a lado, com a brasa da fenda. Sem moldura saliente (é o
  que a separa da emoldurada, SW-G3) e sem sulco nem leão (separa da tumular, SW-C1). Mantém o `PLATE_CLEAR` 0,6 m das
  lajes só desenhadas.
- **Dormente**: rachaduras cheias de pó claro, divisas iguais.
- **Repouso**: brasa a 0,08 nas rachaduras.
- **Preparo (1,0 s)**: **afunda 4 cm** nos primeiros 0,15 s (AT-H1): a peça tem malha própria (o nó do `GroundLook`),
  então baixa 0,04 m de verdade, e a junta escurece a 0,6 do valor e alarga a 0,09 m; 8 fiapos de pó (`Fx.wisps`, pedra
  da sala) saem da junta; as rachaduras abrem e acendem; o âmbar entra da borda para o meio (como hoje). Som `plate_arm`.
- **Golpe (0,25 s)**: clarão; as duas rachaduras se ramificam (mais 3 a 5 fios curtos), 6 lascas de pedra (forma farpa)
  sobem 0,3 m.
- **Depois (5 s de recarga)**: a laje fica 0,02 m abaixo com os fios novos marcados em escuro; sobe ao repouso no último
  0,5 s; os fios novos somem junto.
- **Borda que desmorona (RP-13, pontas do buraco do Santuário B)**: a mesma laje, mas as quatro divisas viram **três
  divisas encaixadas num lado só**, apontando para longe do buraco (o empurrão); no golpe, 3 a 5 pedaços do lábio do
  buraco (`broken_lip`) caem para dentro dele (só desenho, somem a 2 m abaixo). A borda decorativa do buraco nunca tem
  junta escura nem divisa.

### 3.2 Seteira (RP-16). Cripta B, parede norte

Hoje: peça `bolt_slit` 0,5 x 0,6 m e 1,2 m, bloco provisório.

- **Peça**: bloco de cantaria da parede de 1,0 m de largura e 1,4 m de altura, saliente 0,1 m, com a **boca** de 0,18 x
  0,45 m de pé (escura, quase preta), moldura de ferro escurecido em volta da boca, e **três divisas encaixadas** acima
  dela apontando para o sul (para onde atira). A pegada de colisão é a de hoje (o bloco desenhado cobre os 0,5 x 0,6 m).
- **A laje que arma (a de `aims`)**: a laje de 3.1 com as quatro divisas trocadas por **três divisas num lado só
  apontando para a seteira** que ela arma (do outro lado do muro). É assim que se lê a ligação.
- **Repouso**: brasa a 0,08 no fundo da boca.
- **Preparo (1,0 s)**: a boca acende âmbar por dentro de baixo para cima; 2 fiapos de pó saem dela; a faixa do chão
  (`Ground.add_band`, `SLIT_SOURCE`) com aro âmbar e divisas apontando para o sul, enchendo da boca para a ponta.
- **Golpe**: três virotes de 0,6 m em 0,1 s (desenho), **agulha escura com a ponta âmbar** (nunca a ponta carmim dos
  virotes de inimigo, V-11), rastro de fumaça curto; lascas de pedra onde param.
- **Depois**: fumaça escura sai da boca por 1 s; a brasa da boca volta a 0,08.

### 3.3 Corrente da Ponte (RP-11). Ponte A e B

Hoje: faixa âmbar do `Ground.add_hazard` (`CHAIN_SOURCE`), sem peça.

- **Peça**: em cada faixa, um **poste de ferro** de 3,6 m fora do tabuleiro (além do parapeito, do lado da câmera
  contrário: o lado de longe, para não cobrir a faixa), com braço curto no topo e uma **corrente de 3,0 m com peso**
  (o `EdgeKit.chain_weight` refeito: elos a 90 graus, contrapeso de 0,7 m em ferro escurecido com **três divisas
  encaixadas** apontando para a plataforma para onde ele empurra). Nada colide; o peso nunca passa sobre o tabuleiro em
  repouso.
- **Repouso**: o peso pendurado parado, balanço de 2 graus; brasa na fenda da cinta do peso.
- **Preparo (1,2 s)**: o peso recua para fora da ponte e sobe (pêndulo armado, 35 graus em 0,3 s, segura com tremor de
  1 grau); a faixa de 2 m no tabuleiro com aro âmbar e divisas apontando para a plataforma (direção do empurrão).
- **Golpe (0,25 s)**: o peso varre a faixa baixo, a 1,2 m do tabuleiro, de um lado ao outro; 8 lascas e poeira na
  faixa; clarão.
- **Depois**: balança amortecendo em 2 s até parar.
- Na Ponte B (as duas metades da ponte longa) o mesmo poste, um por metade.

### 3.4 Raiz Morta (RP-10). Jardim A e B

Hoje: `GroundLook.plate_band` (moldura da laje ao longo da raiz), placeholder.

- **Peça**: a raiz que fere tem **malha própria** (a mesma forma das raízes do `StoneTree`, separada do tronco para
  poder se mexer), com casca torcida como as outras, e duas diferenças só nela: **fendas longitudinais** ao longo do
  lombo (3 a 5, de 0,8 a 1,5 m) com a brasa, e **duas divisas** gravadas na casca perto da ponta, uma de cada lado,
  apontando para fora da linha da raiz (o `push_out`). As outras raízes do tronco não têm fenda nem divisa.
- **Repouso**: brasa a 0,08 nas fendas.
- **Preparo (1,2 s)**: a raiz sobe 0,15 m pela ponta (a malha inclina a partir da face do tronco), as fendas abrem e
  acendem, pó cai da casca; a faixa de 3 m com aro âmbar e divisas apontando para fora, dos dois lados.
- **Golpe**: chicotada: a ponta sobe a 0,5 m e bate (0,25 s), 8 lascas de casca (forma farpa, casca da árvore), poeira
  ao longo da faixa.
- **Depois (6 s)**: a raiz assenta em 0,3 s; as fendas esfriam.

### 3.5 Planta Hostil (AT-H3). Jardim B, no lugar da raiz do toco junto da parede oeste

- **Peça**: brota de uma **laje rachada com junta escura e uma divisa** apontando para a faixa (a mesma família da 3.1:
  é a laje que diz "perigo", não a planta). A planta: leque **rijo e escuro** de 5 a 7 folhas em lâmina, 0,9 a 1,3 m de
  altura, de pé, pontudas, com uma **bolota de raiz** na base. Cor: bronze-oliva escuro (matiz 60 a 75, saturação 0,30 a
  0,40, valor 0,22 a 0,30) com as bordas das folhas em ferrugem (matiz 18 a 25, valor 0,35). Nunca o verde da Emeth,
  nunca a sálvia clara da Vigília (80 a 95 com valor alto).
- **Contra as mudas frágeis do AT-JB3** (quebráveis, ver `docs/art/at_q0_breakables.md`): as mudas são **pálidas**
  (marfim-ocre, valor 0,55 a 0,7), **baixas** (0,35 a 0,5 m), folhas **redondas e moles**, sem laje, sem divisa. Escura,
  alta, pontuda e plantada numa laje marcada contra clara, baixa, redonda e solta.
- **Repouso**: folhas abertas em leque, balanço lento de 3 graus; brasa na rachadura da laje.
- **Preparo (1,0 s)**: as folhas **se fecham** num feixe de pé em 0,3 s e seguram tremendo; a rachadura acende; faixa de
  2,5 m com aro âmbar e divisas apontando para fora.
- **Golpe**: uma raiz sai da bolota e corre a faixa rente ao chão (0,25 s), poeira e 6 lascas de terra; clarão.
- **Depois**: a raiz volta para a bolota em 0,4 s, as folhas reabrem em 0,8 s.
- **Golpe da Emeth nela**: faísca de ouro velho (a do escudo do ritual, `WARD_SPARK*`), as folhas se encolhem 0,2 s; sem
  número, sem pisca, sem lascas de acerto (diz "não fere").

### 3.6 Coluna que tomba (RP-09). Santuário A e B, Jardim A, Cripta B

Hoje: malhas fora do `merge` sob um pivô, balanço de 3 graus, tombo girando o pivô e troca por `TombKit.column` quebrada.
É **ferramenta do herói** (fere só inimigos), então leva a fenda e **não leva divisa** (a divisa é "isto te fere").

- **Peça**: a coluna da sala com **uma fenda vertical** de 1,2 m no terço de baixo, virada para a câmera, com a brasa.
  Nenhuma outra coluna da sala tem fenda com brasa.
- **1º golpe (racha)**: a fenda abre a 0,12 m e sobe até 2,5 m, acende a 0,4 da luz e fica assim; 6 lascas caem; anel de
  poeira no pé; balanço de 3 graus (como hoje).
- **2º golpe (tomba, 0,6 s)**: a coluna separa em **3 ou 4 tambores** (cortes onde a fenda atravessa) que caem juntos
  girando até 82 graus e se afastam 0,1 a 0,3 m uns dos outros no fim; a faixa âmbar de 1,2 x 5 m no chão enquanto
  inclina (como hoje); no impacto, poeira grossa ao longo da faixa (12 fiapos), 10 lascas, tremor.
- **Depois**: os tambores ficam deitados na faixa, **afundados** a no máximo 0,45 m de altura e um degrau mais escuros
  (0,8 do valor), e descem mais 0,2 m em 4 s (lêem como entulho baixo, não como obstáculo novo; não colidem). O **toco**
  fica: topo irregular (3 a 5 dentes), lascas em volta num raio de 1 m, mesma colisão de hoje.

### 3.7 Fenda que respira (RP-08). Fendas A e B. Empurra, não fere

- **Peça**: nenhuma peça nova na beira; o trecho que respira é marcado por **três divisas** gravadas no chão a 0,6 m da
  beira, apontando para longe dela (o empurrão), em cada um dos quatro trechos, e pela bruma da fenda (`rift_haze`).
- **Repouso**: nada âmbar.
- **Preparo (1,2 s)**: a bruma sobe da fenda ao longo do trecho em folhas cinza-índigo (a cor da bruma estilizada das
  Fendas, `STY_HAZE_GREY`, **nunca violeta**), de 0,5 a 2 m de altura; no chão, **só o aro âmbar e as divisas, sem
  preenchimento** (sem preenchimento = sem dano: é a única exceção da regra 4, e é a que diz "não machuca").
- **Golpe**: rajada: as folhas de bruma sobem a 3 m e se rasgam, 10 traços claros e curtos correm na direção do
  empurrão; sem clarão.
- **Depois**: a bruma volta para dentro em 1 s.

### 3.8 Pedras da abóbada (RP-20). Santuário B (e Fendas B se a medida pedir)

- **Peça**: o rasgo da abóbada (`VAULT_*`) é a origem; nada novo no teto.
- **Repouso**: nada no chão.
- **Preparo (1,2 s)**: **sombra quadrada** de tinta escura (alfa até 0,5) cresce no chão de 0,6 a 2 m com o aro âmbar
  e cantos vivos (nunca redonda: a pedra é um bloco); ao mesmo tempo, uma **coluna de pó** cai do rasgo sobre o mesmo
  ponto (12 fiapos de pó de pedra caindo, cinza claro, sem luz), que é o "de onde vem" sem linha nova.
- **Golpe (0,25 s)**: um bloco irregular de 1,2 a 1,5 m da pedra da abóbada cai em 0,15 s e bate; 12 lascas; poeira em
  anel quadrado; clarão marfim-âmbar só dentro dos 2 x 2 m.
- **Depois (3 s)**: o bloco fica como entulho baixo (até 0,6 m), rachado; nos últimos 0,6 s se desfaz em lascas e pó.
- Duas pedras ao mesmo tempo no máximo: cada uma com sua sombra; nada soma (stencil dos avisos).

### 3.9 Cristal que descarrega (RP-14). Runas B, fora do chão ao norte

- **Peça**: um prisma alto de 2,4 m da família dos cristais R5 (`crystal_edge`), mas **ardósia escura** por dentro
  (0,18; 0,20; 0,24) com a aresta marfim apagada (nunca o esmeralda corrompido, nunca o verde da Emeth), sobre uma
  **base de ferro escurecido** com **três divisas encaixadas** apontando para a fileira de lajes que ele descarrega, e
  **três entalhes** na base (o contador: um por golpe do herói perto dele).
- **Repouso**: entalhes escuros; brasa baixa na fenda da base.
- **Carga**: cada golpe do herói acende um entalhe em âmbar (0,5 da luz) com uma centelha curta; no terceiro, a aresta do
  prisma acende âmbar de baixo para cima em 0,3 s.
- **Preparo e golpe**: as lajes da fileira usam **a gramática das Runas que já existe** (preparo, golpe, brasa,
  `RuneFloor.paint`); um traço âmbar fino corre da base do cristal até a primeira laje no começo do preparo (liga a causa
  ao efeito) e some quando ela acende.
- **Depois**: entalhes apagam; a aresta volta ao marfim em 1 s.
- Os prismas R5 de decoração continuam sem base de ferro, sem divisa e sem entalhe.

### 3.10 Urna de óleo (RP-12). Cripta tardia

- **Peça**: urna isolada (nunca em grupo de quebráveis), 0,8 m, de **bronze escurecido** (0,30; 0,22; 0,14), brilho
  metálico baixo, cinta de ferro com **uma divisa** apontando para o canal por onde o óleo vai correr, e **pavio** torcido
  à mostra na tampa. A cerâmica quebrável é terra fosca, sem metal, sem pavio (ver `at_q0_breakables.md` 2).
- **Repouso**: o pavio apagado, escuro.
- **Golpe do herói nela (preparo, 1,0 s)**: o pavio acende com uma chama âmbar pequena (0,15 m, abaixo do glow) que desce;
  no chão, o aro âmbar de 2,5 m em volta e as divisas para fora; ao longo do canal, só o aro âmbar do primeiro trecho.
- **Explosão (golpe)**: a urna se abre em 6 a 8 pedaços de bronze (curvos, escuros), clarão dentro dos 2,5 m, fumaça
  escura em 6 fiapos.
- **Óleo que corre**: decalque escuro e brilhante (marrom-âmbar, valor 0,15) avançando pelo canal a 3 m/s; à frente dele,
  1 m de aro âmbar com preenchimento fraco (o aviso que anda); o fogo sobre o óleo em línguas baixas (até 0,3 m) e
  âmbar acinzentado, com o aro do perigo em volta (é isso que o separa da Chama da Bênção, que sobe e não tem aro); apaga
  em 2 s, deixando chão chamuscado escuro que some em 4 s.

### 3.11 Esqueleto do nicho (AT-H2). Cripta B

- **Peça**: o nicho é da parede (largura 1,2 m, altura 2,2 m, fundo escuro), com **soleira de pedra com três divisas
  encaixadas apontando para dentro do nicho** (o puxão vai para ele: a divisa diz para onde) e uma laje com junta escura
  diante dele do tamanho do leque (2,2 m). Dentro, a figura do esqueleto assado (molde do `HubNpc`, um `CrowdRenderer` de
  uma figura), **coberta de pó**: osso a valor 0,4 a 0,45, saturação até 0,08 (mais apagado que os esqueletos da luta),
  **sem contorno de casca, sem barra de vida, sem olhos acesos**. Em repouso, **uma mão de osso à mostra** sobre a borda
  do nicho (o sinal pedido pelo PO).
- **Dormente** (antes da sala 4): a mão recolhida, soleira com pó nas divisas.
- **Repouso**: a mão sobre a borda; a cada 4 a 7 s um osso mexe (2 graus), sem som.
- **Preparo (1,0 s)**: o braço sai até o cotovelo, os ossos do ombro e da cabeça mexem, pó cai da borda; som de pedra
  raspando (`niche_arm`); no chão, o leque de 2,2 m com aro âmbar e **divisas apontando para o nicho**; a soleira acende
  nas divisas.
- **Golpe (agarrar, 0,25 s)**: o braço avança 1,5 m rente ao chão e fecha a mão; clarão no leque; 6 lascas de osso
  cinza.
- **Depois (6 s)**: o braço volta devagar em 0,8 s; pó.
- **Golpe da Emeth nele**: faísca de ouro velho (como o escudo do ritual), sem número, sem pisca.

### 3.12 Colunata (RP-18). Variante tardia (Santuário C)

Não é perigo novo: é cobertura. A gramática vale nela por contraste.

- **Colunas inteiras** (barram corpo e tiro) e **tocos** (barram só corpo): toco com topo irregular e **altura até 1,0
  m** (a regra do tiro: até 1,0 m passa por cima), coluna inteira com capitel. A altura é a leitura: nada entre 1,0 e
  1,25 m.
- A coluna caída atravessada (caixa baixa) fica abaixo de 0,6 m, com tambores separados e pó, sem fenda.
- Se uma coluna da grade for a do RP-09, ela leva a fenda da 3.6 e nenhuma outra leva.

---

## 4. Aceite (por peça, somado ao AC-RS e ao AC-AT do backlog)

1. **Captura Perto com HUD** (1920 x 1080, GPU, semente 5) de cada peça em repouso, no preparo a 0,75 do aviso, no golpe
   e no depois; clipe em velocidade real (aviso, reação boa, consequência). No máximo 2 capturas de GPU ao mesmo tempo.
2. **Medida** (`tools/frame_stats.py --hue --box=...`): no preparo a 0,75 do aviso, a área tem matiz 26 a 34 e
   saturação 0,30 a 0,55; aro pelo menos 40 de luma acima do chão em volta; no golpe, nada acima de 226 em mais de 1%
   da caixa e 0% com os três canais acima de 235. Em repouso, a peça viva sem nenhum pixel na faixa âmbar com saturação
   acima de 0,30 (a brasa é baixa). Divisa: caixa de 30 x 30 px sobre ela 10 a 20 de luma abaixo da pedra a 1 m.
3. **Distinção**: na mesma captura, a laje rachada contra a emoldurada e a tumular (Cripta A, Santuário A), a planta
   contra uma muda frágil (Jardim B), a urna de óleo contra a cerâmica (Cripta tardia), o cristal contra um prisma R5
   (Runas B). O art-director confere e registra em `docs/art/visual_review.md`.
4. **Cruzamento**: um aviso de inimigo (vermelho) sobre uma área âmbar armada: os dois aros legíveis, o vermelho por
   cima, nada soma acima do teto (stencil); com uma Bênção de Chama acertando dentro de uma área âmbar: as línguas da
   Chama separadas do aro (combat-feel-director).
5. **Compatibility** (1280 x 720): o mesmo preparo com pelo menos +30 de luma e saturação 0,35 sobre a vizinha.
6. Clássico igual fora das peças de perigo; F7 exato; colisão e faixa iguais (testes do RP de cada uma); `fit_probe` sem
   subir; iGPU 720 Baixa até 0,5 ms a mais por sala.

## 5. Ordem sugerida para o environment-artist e o technical-artist

1. A divisa e a fenda como peças comuns (uma função para gravar divisa em qualquer malha de pedra ou ferro, um uniform de
   brasa por material de perigo) e a laje rachada (3.1, com o "afunda" do AT-H1) e a borda que desmorona.
2. Seteira e laje que arma (3.2), coluna que tomba (3.6), raiz (3.4), corrente (3.3).
3. Os do Lote A1 conforme o gameplay-engineer os entrega: cristal (3.9), urna (3.10), pedras (3.8); fenda que respira
   (3.7) junto.
4. Os protótipos do Lote D: planta (3.5) e nicho (3.11, a figura é do technical-artist).

Pendente de quem decide: nomes dos perigos seguem provisórios (resposta 7 do Daniel); nenhum símbolo novo além da divisa
(que é geométrica, não lore).

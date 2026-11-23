# A Maga (v2, reconciliada com o pacote do Daniel de 2026-11-23)

- **Data**: 2026-11-23. **Autor**: `hero-designer`. Proposta; números de partida para o `balance-designer`. Sem nome próprio nem origem (ver Perguntas).
- **v1 superada**: o rascunho de 2026-11-21 (Rajada, Lança de Luz, Campo, Pilar, Chuva de Estrelas, Blink, recurso Brilho, paleta esmeralda) fica
  no histórico do git. Sai de lá só a ideia de "distância e Blink"; o resto foi trocado pelo pacote.
- **Fontes**: `maga_pacote_2026-11-23/` (`LEIA_PRIMEIRO.md`, documentos 01 a 04, imagens 01 a 04), `README.md` desta pasta (regra dos botões),
  `guerreiro.md`, `docs/design/kit_c1c.md`, `docs/design/bencaos_por_anjo.md`, `docs/reference/meta.md` e `gameplay.md`, `tools/make_data.gd` (só leitura).
- **O que o pacote ganha** (aprovado pelo Daniel): identidade de **Maga de Fogo**; laço **marcar, agrupar, detonar**; ataque de projéteis cujo 3º
  acerto aplica a Marca Arcana; Especial Explosão Rúnica; Círculo de Contenção; Passo Etéreo; Tempestade dos Selos; passiva Ressonância; cajado de
  **duas pontas**; capa **marfim** sobre **azul profundo**; três ramos de Dons (Piromancia, Arcanismo, Controle/Selos; gelo só como ramo secundário
  futuro); entregas M1, M2, M3.
- **O que o projeto ganha** (decisões de 2026-11-21): 5 ativas (esquerdo, direito, Q, E, Shift = ultimate) mais a travessia no Espaço, então o R do pacote
  vira Shift e **falta uma habilidade no E**; cores reservadas (aviso vermelho, Emeth esmeralda, Morvath violeta, elite ouro velho); círculos inteiros
  no chão são de Morvath; Bênçãos dos 7 anjos são compartilhadas; regra F8 (golpe comum nunca atordoa); recurso em cargas, sem segunda barra.

## 1. Fantasia, papel, arma

- **Em uma frase**: estudiosa dos selos que escreve o campo com fogo: marca quem está longe, reúne o grupo e o detona de uma vez.
- **Papel e distância**: dano à distância e controle de área, de 6 a 12 m; lê a sala antes de agir. Fraca de perto e parada; forte quando o
  grupo está agrupado e marcado. **Ritmo**: três tiros, marca, o Círculo reúne, a Explosão detona, a Ressonância enche, a Explosão amplificada fecha.
- **Arma**: Bastão Rúnico de Duas Pontas (cada ponta com um aro de ouro e uma chama; o pacote chama de "bastão" e "cajado", usar **bastão**
  no texto do jogo). Sem troca de arma no M1 (Grimório das Cinzas, Orbe do Inverno e Anéis de Ressonância são M3).
- **Silhueta**: cabelo curto preto, capa marfim rasgada com bordado dourado fino sobre roupa azul profundo, cinto de couro com pergaminhos, botas
  práticas, a mão livre sustenta uma chama pequena. **A arte 01 é a única âncora** (decidido, seção 11).

## 2. As 5 habilidades e a travessia

Escala do Guerreiro (hoje: ataque 15/15/20; onda 55 por 12 de Magia e 0,5 s; Brado 35, recarga 12 s; Investida 60, recarga 5 s; Magia 50; vida 30;
esquiva 5,6 m, 19 quadros, 1 carga em 0,8 s). A Maga bate menos por golpe, mas de longe e em área, e **precisa de preparo** para chegar ao pico.
Tempos em segundos; os do `combat-feel-director` (preparação, impacto, recuperação) valem sobre estes, na cadência mais rápida de 2026-11-23.

| Botão | Papel | O que faz | Custo, recarga | Preparação / recuperação (pés presos) | Cancela | Lê na tela |
|---|---|---|---|---|---|---|
| **Esquerdo** | **Ataque**: Chama Sigilada | cadeia de 3 projéteis na mira, alcance 11 m, voam a 30 m/s e **batem no primeiro inimigo**: 8, 8 e **12**. O 3º acerto da cadeia **aplica 1 Selo** (a Marca Arcana do pacote) no alvo. Dentro do Círculo (Q) o Selo vem no **2º** acerto | sem custo; devolve Magia (item 3) | 0,08 / 0,13 (tiro 1), 0,10 / 0,13 (tiro 2), 0,14 / 0,20 (tiro 3, maior); janela de cadeia 0,4; pés presos 0,18, 0,20 e 0,30 | esquiva, ultimate | bola de chama âmbar com rastro fino; no 3º, a chama vira um aro de runa; número âmbar, o do 3º maior |
| **Direito** | **Especial**: Explosão Rúnica | explosão **no ponto da mira** (até 10 m, gruda no inimigo com Selo mais perto num raio de 1,5 m), raio 3,2 m: **25** em todos e **+35** em cada inimigo com Selo (total 60), **consome** os Selos. Com **Ressonância cheia** (item 3), a próxima sai amplificada: dano x1,5 (38/90), raio 4,5 m, **0 de Magia** | **10 de Magia** (sem Magia não sai: aviso "Sem Magia", como a onda); 0,6 s entre usos | 0,18 / 0,25; pés presos 0,35; só a esquiva corta | esquiva | aviso de runas pálidas no chão no ponto (anel de sigilos separados, ver 2.3, ouro marfim), depois clarão âmbar e o Selo se acende e some |
| **Q** | **Poder**: Círculo de Contenção | **área** no cursor (até 8 m) de raio 3,2 m por 4 s: **lentidão de 50%**, e ao conjurar **junta** os inimigos 1,2 m para o centro em 0,4 s (comuns; elites e guardiões só lentidão; chefe nada). Não dá dano. Quem está dentro leva o Selo no 2º acerto e **o Selo dele não se apaga** enquanto estiver lá | **recarga 10 s**; cada Selo detonado devolve 1 s (piso 6 s, teto por uso 4 s, regra de `KitFeed`) | 0,20 / 0,15; pés presos 0,25 | esquiva | seis sigilos dourados em hexágono que se acendem em sequência (0,4 s), ficam acesos até o fim e piscam nos últimos 0,8 s. Ver 2.3 |
| **E** | **Defesa**: Suspensão Arcana | domo de 2,6 m em volta dela por **2,5 s**: projéteis inimigos que entram **param no ar** e somem quando o domo cai; inimigos dentro ficam **40% mais lentos** e os avisos deles andam 40% mais devagar; ela anda a 100%. Vem do segundo "supremo" do pacote, rebaixado a habilidade de recarga | **recarga 14 s** | 0,20 / 0,20; pés presos 0,2 | esquiva | película fina marfim com hexágonos dourados, borda âmbar suave; sem violeta |
| **Shift** | **Ultimate**: Tempestade dos Selos | área de 6 m no cursor (até 9 m) por **4 s**: no 1º tique **todo inimigo** dentro leva 1 Selo; tiques de **8 a cada 0,5 s** (64) e, no fim, **detona** todos os Selos: **110** a cada um. Total 174 em quem ficou. Elites 50%, guardiões 25%, Morvath só os tiques e o Selo (sem detonação) | carga: **Magia gasta, dano causado e vida perdida** (`UltCharge`, `UltDef`), 90 de Magia como a Voragem, `Maestria 2` (primeira); a segunda (Maestria 6) fica em aberto | gesto `ULT` 0,3 protegida; depois anda livre, a tempestade fica no chão | esquiva corta o gesto, nunca a tempestade já solta | selos dourados em círculo de runas que se escrevem e giram, relâmpagos âmbar; os tiques marcam cada alvo com o glifo do Selo. Sem círculo cheio no chão (ver 2.3) |
| **Espaço** | **Travessia**: Passo Etéreo | desaparece e reaparece **4,5 m** na direção do movimento (ou da mira parada), **14 quadros** protegidos, **2 cargas** (1,0 s cada), pode atravessar inimigos e paredes baixas não, termina sempre no chão livre | cargas | 0,04 / 0,10 (some 0,04, aparece em 0,10) | tudo o que ela faz | resíduo marfim pálido onde estava (`dodge_ghost`), poeira de brasa onde aparece; sem som de golpe |

### 2.1 A Marca Arcana (o Selo) e o laço
- **Selo**: contador 0 ou 1 por inimigo (2 só com o Dom Selo Duplo), vive **8 s** (não conta enquanto está no Círculo ou no domo), some ao ser
  detonado. Aplicável a comuns, elites e guardiões; chefe aceita Selo mas a Explosão dá a ele só os +35 uma vez por 3 s.
- **Laço de 5 passos** (o do pacote): (1) tiros marcam; (2) o Círculo reúne e segura; (3) a Explosão detona; (4) cada Selo detonado enche a
  Ressonância; (5) a Explosão amplificada fecha sem custo. O jogador sempre responde **"onde o grupo vai estar"** e **"quando detonar"**.
- **Nome**: no texto do jogador usar **Selo** (os "selos" do jogo, Morvath e a Selagem combinam) e deixar **Marca** para a família de Bênção do
  anjo Qeshael, que já existe e dá +dano em quem está marcado. Os dois ficam compatíveis (um inimigo com Selo e com Marca leva os dois efeitos).
  *Decisão 6, seção 11.*

### 2.2 Os botões se alimentam (princípio do `kit_c1c.md`, tetos iguais)
| Origem | Ganho | Para onde |
|---|---|---|
| Projétil do ataque que acerta | **+0,3 Magia** (teto `gain_cap` 3 por 1 s) | Magia |
| 3º acerto que aplica Selo | **+1 Magia** | Magia |
| Selo detonado (Explosão) | **+1 Magia** por Selo (no máximo 6 por Explosão), **+1 ponto de Ressonância**, **-1 s** na recarga do Q | Magia, Ressonância, Q |
| Quebra (poise) causada por ataque ou Explosão | **+3 Magia** (`magick_on_break`), nunca a da ultimate | Magia |
| Magia gasta (10 por Explosão) | carga da Tempestade (`UltCharge`) | ultimate |
| Selo detonado pela Tempestade | +3 pontos de Ressonância no total (teto) | Ressonância |
| Explosão **amplificada** | não dá Ressonância (corta o laço) e não gasta Magia | |
Resultado: a Explosão custa 10 e devolve até 6 mais os tiros; com 3 Selos ela quase se paga. Sem Selo ela fica cara (de propósito).

### 2.3 Forma do Círculo e leitura (decidido: seção 11)
Círculo cheio no chão é de Morvath. O Círculo de Contenção é **área circular só na simulação** (raio 3,2 m); na tela são **seis sigilos
dourados em hexágono**, sem linha contínua entre eles e sem preenchimento: cada sigilo é uma placa pequena de runas que se acende e solta
uma tira fina de luz até a vizinha só no instante da conjuração. O lado a lado fica **reconhecível como dela** (hexágono dourado), e o piso
entre eles é o da catacumba. Alternativa: um **quadrado de runas** (quatro cantos com cunhas). *Recomendo o hexágono de seis sigilos.*

### 2.4 Cores e leitura (regra de paleta)
- **Dela**: âmbar e laranja (fogo), marfim e ouro pálido (runas, Selo, Ressonância), azul profundo só no traje. **Violeta**: não usar nos efeitos;
  no máximo uma fita muito fraca no forro da capa, como na arte 01 (que tem um pouco de roxo no forro). Verde-esmeralda é da Emeth (Guerreiro) e
  o violeta é de Morvath e dos feiticeiros.
- **Selo** no inimigo: um glifo pequeno (hexágono com ponto central) **acima da cabeça**, ouro marfim, girando devagar, nunca no chão e nunca vermelho
  nem piscando. **O aviso de golpe inimigo é vermelho no chão e pisca; o Selo é dourado no ar e fixo**, então não se confundem. Quando a Explosão
  vai consumir, o Selo vira uma centelha branca por 0,1 s antes de sumir.
- **Ressonância** no HUD: 3 losangos de borda marfim e miolo âmbar (como os da Fúria, mas âmbar), cada um com metade acesa. Cheio, os três pulsam e o
  texto do botão direito muda para "Explosão Rúnica: amplificada".

## 3. Passiva e recurso: Ressonância

- **Ressonância** (3 losangos, 2 pontos cada = 6 pontos, sem barra nova; o pacote diz "barra", aqui são cargas como a Fúria, `README.md` item 5).
  Cada Selo detonado vale 1 ponto (item 2.2). **Cheia**, a próxima Explosão Rúnica sai amplificada (x1,5 de dano, raio 4,5 m) e **não gasta Magia**, e
  zera. Não decai por tempo (cresce por jogo bom) e zera ao fim da descida. A Explosão amplificada **não** dá Ressonância.
- **Passiva** (como o "Brilho" do Guerreiro): cada finalizador (3º tiro que acerta, Explosão que detona Selo, Tempestade) devolve 1 de Magia a mais.
- **Magia** (50) existe: paga a Explosão, a Tempestade carrega por ela. Vida **30** (como os outros): a fragilidade vem de ficar parada nos feitiços,
  de não ter bloqueio e de a Suspensão cobrir só o corpo.

## 4. Como as 7 famílias de Bênção mudam cada botão (reinterpretação, sem duplicar)
Os textos e números ficam os de `bencaos_por_anjo.md`; só muda o que cada Bênção toca em cada botão dela. Mapa de slots: Atq = ataque, Esp = Explosão,
Q = Círculo, E = Suspensão, Sh = Tempestade, Espaço = Passo. Para Q, E e Shift a etiqueta é por papel (`TECH`, `DEF`, `ULT`, ver Código).

| Anjo (família) | Atq (Chama Sigilada) | Esp (Explosão) | Q (Círculo) | E (Suspensão) | Sh (Tempestade) | Espaço (Passo) |
|---|---|---|---|---|---|---|
| Sarael (Chama) | os tiros queimam | deixa brasa onde caiu (zona) | o chão do Círculo queima quem fica | a película queima quem encosta | queda de brasas extra | rastro de brasa onde saiu |
| Nivael (Geada) | tiro congela curto; congelado leva mais da Explosão (estilhaça) | Explosão congela no raio | Círculo gela (a lentidão vira congelar no fim) | domo congela os projetos que entraram | gelo no centro, estilhaça na detonação | flocos onde aparece |
| Lumael (Luz) | +dano limpo nos tiros | +dano e raio maior | Círculo cura 1 por inimigo morto dentro | domo cura 1 ao fim por inimigo preso | +25% de carga e dano | clarão onde some |
| Shomael (Vigília) | a cada 4 acertos 0,5 s de proteção | empurra um pouco os da borda | quem está dentro bate 15% mais fraco | domo dura +1 s e **absorve 1 golpe** (sem cura) | proteção 1 s ao soltar | 1 s de proteção ao 2º Passo |
| Velael (Véu) | tiros atravessam o 1º alvo | a Explosão acerta o fantasma de um segundo ponto | Círculo some e reaparece 1 vez noutro ponto | domo vira véu: ela some 1,5 s | tempestade sem aviso | Passo atravessa e some 0,5 s |
| Galael (Maré) | tiros em onda larga (ângulo) | Explosão em onda que se espalha | Círculo puxa mais 0,6 m | domo empurra | tempestade segue o cursor | Passo deixa poça lenta |
| Qeshael (Marca) | o 3º tiro **também marca** (Marca da Bênção) | Explosão acerta crítico em quem tem Selo e Marca | Círculo marca quem junta | domo marca quem entra | tempestade marca todos | Passo marca quem está perto |
`bencaos_por_anjo.md` tem 42 Bênçãos por botão; só 6 por anjo mudam de lugar na Maga (a coluna Esp vira "Explosão" e a "onda" some). Nenhuma Bênção
nova de dado: usam `mark_time`, `burn_dps`, `freeze_time`, `shield_on`, `cooldown_pct`, `reach_pct`, `damage_pct` e as habilidades do gatilho do botão.

## 5. Dons (árvore, 3 ramos do pacote mais sustento; efeitos em estatísticas que já existem)
- **Piromancia** (dano, queimadura, explosão): entrada *Brasa Viva* (o Selo detonado deixa 3 s de queimadura 4/s), meio *Combustão* (a Explosão queima
  quem o Selo não pegou, +25% de raio), ápice *Inferno Rúnico* (a Explosão amplificada deixa 4 s de brasa no chão).
- **Arcanismo** (Selos, propagação, eficiência): entrada *Eco Arcano* (o Selo detonado dá +1 de Magia), meio *Selo Duplo* (2 Selos por inimigo, a Explosão
  consome um por vez e dá 40% do dano a mais com 2), ápice *Ruptura* (o Selo detonado salta para o mais próximo sem Selo).
- **Controle e Selos** (lentidão, domínio, preparo): entrada *Círculo Expandido* (+0,8 m de raio), meio *Prisão Sigilada* (o Círculo prende 0,6 s no centro, só
  comuns), ápice *Contenção Perfeita* (o Círculo dura +2 s e o Selo vem no 1º acerto).
- **Pontes** (ligam dois ramos): *Chama que Marca* (Piromancia e Arcanismo: o 3º tiro queima 3 s), *Brasa que Prende* (Piromancia e Controle: o Círculo
  queima ao fechar), *Selo no Chão* (Arcanismo e Controle: o Círculo aplica 1 Selo a todos).
- **Sustento**: *Reserva* (+10 de Magia), *Firmeza* (+10 de vida), *Passo Longo* (+0,8 m no Passo).
- **Frio** (Criomancia do pacote): ramo secundário **só no M3** (Orbe do Inverno); até lá o frio vem das Bênçãos de Nivael.
- Dons que mexem na Tempestade: **Maestria 6**, junto com a segunda ultimate.

## 6. Três combinações só dela
1. **Gancho de cadeia**: 3 tiros com o Círculo aberto (Selo no 2º) em 4 inimigos, os Selos viram 4, a Explosão paga 4 Magia e dá 4 pontos; segunda cadeia
   enche a Ressonância.
2. **Ressonância cheia no chefe de guardiões**: com o grupo preso e marcado, a Explosão amplificada tira a Postura (peso 0,6 x raio) e sai de graça.
3. **Passo, Suspensão, Tempestade**: o Passo tira de dentro do ataque, a Suspensão segura os projéteis da horda de atiradores e a Tempestade fecha a sala
   com os Selos já postos.

## 7. O que a distingue dos outros três

| | **Guerreiro** | **Maga** | **Ladina** | **Paladino** |
|---|---|---|---|---|
| Fantasia | combos de espada | marcar, reunir e detonar | assassina de um alvo | muralha de luz |
| Distância | 3 m | 6 a 12 m | 2 m, por trás | 2,5 m, área em volta |
| Como causa dano | combo e onda de 6 m | Selos e uma explosão | pico em janela | devolve o que recebe |
| Recurso | Fúria (cargas, abate) | **Ressonância** (3 losangos, Selo detonado) | Marca (pontos) | camadas de proteção |
| Travessia | esquiva 5,6 m | **Passo Etéreo** 4,5 m, 2 cargas | Mergulho | Avanço de Escudo |
| Q | Brado | Círculo de Contenção | Fumaça | Chão Consagrado |
| E | Investida | **Suspensão Arcana** | Pulo de Sombra | (ultimate) |
| Shift | ultimate | **Tempestade dos Selos** | ultimate | Guarda |

## 8. Riscos
- **Forte demais**: tudo à distância mais domo mais Passo de 2 cargas. Mitigação: o ataque é só 28 por cadeia de ~0,95 s, a Explosão só chega ao pico com
  Selo, o domo tem recarga 14 s e dura 2,5 s, os atiradores inimigos já fogem e miram nela, a Explosão amplificada precisa de 6 Selos.
- **Fraca demais**: sem Selo ela é pior que o Guerreiro de longe. Medir: 12 sementes e o robô ("marca com o 3º tiro", "Círculo com 3 perto", "Explosão com 3 Selos").
- **Laço infinito**: Ressonância cheia, Explosão de graça, mais Selos e mais Ressonância. Cortado pela regra "a amplificada não dá Ressonância",
  pelo teto de Magia por segundo e pelo teto de 6 Selos por Explosão.
- **Leitura**: Selo no ar mais Marca mais aviso vermelho mais projéteis inimigos; revisar em captura ao lado do Guerreiro.
- **Chefe**: a Explosão amplificada tira Postura demais; usar `Feel.poise_weights` (peso 0,6) e o teto por golpe; Selo no chefe só os +35, uma vez a cada 3 s.

## 9. Mapa de reuso e código novo

| Habilidade | Reaproveita | Pede código | Estimativa |
|---|---|---|---|
| Ataque (3 tiros, Selo no 3º) | `ComboTree`/`ComboNode` (3 nós em cadeia), `Projectiles` (`Kind.SPARK/WAVE` do herói, velocidade, rastro), `Combat.throw_wave`, `magick_per_hit` | **projétil que bate no primeiro inimigo** (hoje o do herói atravessa), contador de acertos por cadeia, tag de aplicação do Selo | **M** |
| Selo (Marca Arcana) | `DamageCalc.marked`, `mark_time`, família Marca do anjo Qeshael, `Horde.damage`/`Horde.dealing` | estado Selo por inimigo (0 a 2, tempo, não conta dentro de área), tiques de apagar, glifo acima da cabeça (`CrowdRenderer`) | **M** |
| Especial (Explosão no cursor) | `ComboNode.Effect.GROUND_MARK` e `Shape.CIRCLE`, `Combat.cast_burst`, `magick_cost`, `magick_refused`, aviso `Ground.Kind.WARNING`/`MARK` (cor própria) | alvo no cursor com gruda no Selo, dano por Selo consumido, devolução de Magia e Ressonância por Selo | **M** |
| Q (Círculo) | `Ground.Zone` com lentidão (`Ground.Kind.BIND`), `Player` cast com cursor, `KitFeed` (`cd_refund`) | puxar para o centro (efeito novo, empurrão para dentro), desenho hexágono de sigilos (`ground_zone` shader) | **P a M** |
| E (Suspensão Arcana) | `Ground.Zone.follow`, `Projectiles._cut_curses` (apagar projétil ao tocar), lentidão em área, `shield_on` | parar projétil no ar e apagar ao fim (variante do corte), avisos 40% mais lentos (hoje só a lentidão de movimento) | **M** |
| Shift (Tempestade) | `UltDef` (`Kind.VORTEX`), `Ultimates.vortex` (área no cursor, tiques, elites 50%, guardiões 25%, Morvath só lento), `UltCharge` | tique que aplica Selo e detonação final, shader da tempestade | **M** |
| Espaço (Passo) | esquiva como dado (`DashDef`, `dodge_charges` 2, `dodge_ghost`), `Player.DODGE_BUFFER` | teletransporte (pos final, não corrida) com 14 quadros e atravessar inimigos | **P a M** |
| Ressonância | `GiftState`/`HeroGifts` (cargas da Fúria), losangos do HUD, `HeroDef.passive_tags` | contador 0 a 6 em 3 losangos âmbar, regra "amplificada", `RESULT` e teste | **P a M** |
| Herói (seleção, save, HUD por herói) | `HeroDef` (`HeroDef.buttons`), `heroes.<id>` do save (já), Maestria por herói, `Controls` | seletor de herói na descida e no Santuário, `HeroDef.maga()`, ação E no pad (RT é eixo), slots `TECH/DEF/ULT` | **M** (compartilhado com Ladina e Paladino) |
| Corpo e bastão | **modelo hoje**: bastão simples `w_staff` já assado (cajado de 1000 triângulos, `HeroBody`); o corpo é o do Explorador | corpo da Maga e bastão de duas pontas: Meshy (créditos só com seu aval) | **G** (arte) |
| Texto, Livro | `data/text_pt.tres` | textos novos de habilidades, Dons e Compêndio | **P** |

**Estimativa total de código: G** (mais que 4 dias de `gameplay-engineer`, sem arte), com M1a em cerca de 3 a 4 dias.
**Meshy**: não há estimativa fechada para um herói. Do que está no projeto: gente do hub 40 créditos cada (`hub_spec_art.md` 3.9), armas ~20 cada (120 por 5
armas e a foice), prévias 5 cada. **Palpite para a Maga**: corpo com esqueleto 50 a 80 créditos, bastão de duas pontas 20 a 25, 2 a 3 prévias 10 a 15;
total **80 a 120 créditos, incerto** (o `art-director` confirma). Nada gerado sem o seu aval.

## 10. Entregas (resumo; tarefas em `docs/backlog.md`, "Maga M1")
- **M1a**: kit completo no corpo e no bastão de hoje, atrás de uma opção de desenvolvimento (`--hero=maga`), com testes.
- **M1b**: seleção, save, HUD da Ressonância, texto, Bênçãos adaptadas, robô.
- **M1c**: modelo e animações da Maga: estimar créditos, gerar só a prévia no Meshy, mostrar ao Daniel e só então o modelo final.
- **M2**: Maestria, Dons, as duas ultimates. **M3**: armas, frio, Livro de Ahk.

## 11. Decisões do Daniel (2026-11-23)

1. **Origem** (decidido pelo Daniel 2026-11-23): a Maga vem do **norte** do mundo do jogo, cujo povo tem traços orientais (o cânone chama esse reino de
   Formeth; o nome do reino e da cidade **não** foram dados por ele para ela, então o texto do jogo só diz "do norte"). Fica do pacote: estudiosa que aprendeu os poderes ao
   longo do tempo, achada por inscrições, registrada no Livro de Ahk; os detalhes podem mudar. **Nada além disso é lore**: nome próprio, família, ordem e
   ligação com os paladinos continuam sem texto. Ainda **não** está dito se ela é uma das quatro paladinas (PALADIN_1 a PALADIN_4): ver Pergunta 1.
2. **Rosto**: só a arte pintada aprovada (01) é âncora; **sem semelhança de pessoa real**. A prancha 04 (outro rosto) não vale.
3. **Paleta**: âmbar e laranja de fogo, runas marfim e ouro pálido; violeta no máximo um toque fraco (o forro da capa da arte 01).
4. **Círculo de Contenção**: anel de sigilos separados em hexágono (simulação circular, sem círculo cheio no chão).
5. **E**: Suspensão Arcana como habilidade de recarga (14 s). **Shift**: Tempestade dos Selos.
6. **Nomes** do pacote como nomes de trabalho (Chama Sigilada, Explosão Rúnica, Círculo de Contenção, Suspensão Arcana, Tempestade dos Selos, Passo Etéreo,
   Ressonância); "Selo" no texto do jogador, "Marca" fica ao anjo Qeshael (a confirmar na revisão de texto).
7. **Meshy**: ele quer ver uma **prévia** antes do modelo final. M1c = estimar créditos, gerar **só a prévia**, mostrar, e o modelo final só com o ok dele.

## 12. Perguntas ao Daniel (em aberto)

1. **Ela é uma das quatro paladinas** (do sangue do leão, Ordem de Erukh, que o cânone situa no sul, de povo claro) ou outra coisa (companheira, aliada)?
   *Recomendo: sem texto de pertencimento até você decidir; símbolo do leão não vai no traje dela por enquanto.* A "Capela Funerária" do pacote existe no cânone? Não achei: *recomendo chamar de "uma capela nas catacumbas" até você dizer.*
2. **Vida**: 30 como os outros, ou 26 como a v1? *Recomendo 30 e controlar pelo preparo.*
3. **Nome do Selo**: "Selo" para ela e "Marca" para a Bênção do anjo Qeshael. *Recomendo sim.*
4. **Segunda ultimate** (Maestria 6): depois da Tempestade, quer a Suspensão como grande (um domo de 8 s) ou outra? *Recomendo decidir só no M2.*

## 13. Decididas pelo Daniel em 2026-11-23 (tarde), seguindo as recomendações da seção 12
- Pertencimento: o texto do jogo não diz se ela é uma das quatro paladinas; o leão fica fora do traje dela por ora.
- Vida 30, igual à do Guerreiro.
- "Selo" para a marca da Maga; "Marca" continua sendo a do anjo Qeshael.

## 14. M1a implementada (2026-11-23, `--hero=maga`)
- Código: `HeroDef.maga()` (`data/heroes/maga.tres`), `ArcaneKit` (números), `SealBook` e `Resonance` (regras puras), `Arcane` (nó em `Game.arcane`:
  Selo, Explosão, Círculo, Suspensão), `UltDef.Kind.STORM` (`data/ultimates/maga/00_storm.tres`, jogada por `Ultimates`), Passo em `Player._teleport`,
  `ComboNode.Effect.BLAST/CONTAIN/DOME` e `wave_stops/wave_speed/wave_color` (tiro que não atravessa), `Projectiles.Shot.stops/frozen`, robô em `Bot._arcane_step`.
  Números em `tools/make_data.gd` (`_maga`, parte `maga`). Testes: `tests/test_maga_seal.gd`, `tests/test_maga_loop.gd`.
- Cursor sem mouse (direcional e robô): Explosão no Selo mais perto dentro de 65 graus, senão no inimigo mais perto, senão 6 m à frente.
- Fora desta etapa: aviso no chão antes da Explosão, avisos inimigos 40% mais lentos no domo, 3 losangos no HUD, hexágono e Selo desenhados (hoje peças planas
  âmbar e marfim), Maestria e Dons, Bênçãos por botão, seletor e save por herói, +1 Magia da Tempestade (a regra `passive_never` do ultimate a impede).

## 15. M1b mínima (2026-11-23): escolha do herói
- Portal do Santuário: botões Descer, "Herói: Guerreiro/Maga" (alterna e reabre a página) e Ficar; vale para teclado, mouse e controle (`Hub._open_portal`). O herói fica no save (`hero`, `SaveData.HEROES`, `picked_hero`, `next_hero`); save antigo ou valor inválido lê como Guerreiro. `Game.hero_option()`: `--hero=` manda; senão o save (só com save ligado e sem robô).
- HUD: glifos próprios (`BoonIcon.BOLT/BLAST/DOME_GLYPH`, Q usa o círculo, Tempestade 112) e a Ressonância nos "lights" do diamante do botão direito (3 losangos âmbar; um losango acende com o primeiro ponto).
- Primeira partida de um save novo ainda desce direto sem passar pelo Santuário (sempre Guerreiro). Maestria e Dons da Maga seguem vazios (M2). `RESULT.hero` e `runs.jsonl` já gravam o herói.

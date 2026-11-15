# Inimigos da fase 1: prancha de referência e plano sem modelos novos

Prancha do Daniel de 2026-11-14 ("Inimigos, Fase 1, referência para modelagem 3D", feita por IA): guardada só
localmente em `docs/art/ref/inimigos_fase1.png` (fora do git: o repositório é público). Nove personagens com frente,
lado, costas e 3/4, comportamento, paleta e escala. Comportamentos da prancha = os que o jogo já tem (nenhum código
novo de regra, exceto o item opcional do Ancião).

## Paleta da facção (mortos-vivos)

Osso claro, osso queimado, cinza-ardósia, preto, vermelho-sangue escuro, roxo, roxo escuro, verde. Dourado velho nos
frisos das elites, dos guardiões e de Morvath. Leitura: osso claro e panos escuros, metal bronze escurecido, um
acento por papel (vermelho nos soldados, roxo nos sacerdotes e em Morvath, laranja de brasa no corredor).

## Por inimigo: o que a prancha pede e como chegar lá agora

Escala da prancha (relativa ao Esqueleto) contra o `size` atual em `tools/make_data.gd` (o Esqueleto fica 1,15).

| # | Inimigo (id) | Prancha | Hoje | Escala prancha / alvo / hoje |
|---|---|---|---|---|
| 1 | Esqueleto (`skeleton`) | elmo redondo de aço, ombreira, pano vermelho na cintura e no pescoço, lâmina | Minion KayKit, lâmina | 1,0 / 1,15 / 1,15 |
| 2 | Corredor (`runner`) | sem arma, curvado, trapos vermelhos, brasas laranja no peito; explode | Rogue KayKit com duas lâminas | 0,9 / 1,04 / 0,6 |
| 3 | Feiticeiro (`mage`) | capuz e manto escuros com vermelho, olhos e gema roxos (decisão do Daniel: roxo no lugar do verde da prancha), projétil roxo | Mage KayKit | 1,1 / 1,27 / 0,9 |
| 4 | Besteiro (`archer`) | capuz roxo escuro e vermelho, besta, leque de virotes laranja | Rogue KayKit com besta | 1,1 / 1,27 / 1,0 |
| 5 | Escudo (`guard`) | armadura pesada de bronze escuro, escudo-torre com emblema, espada | Warrior KayKit, machado e escudo | 1,3 / 1,5 / 1,25 |
| 6 | Sacerdote (`priest`) | capuz e manto roxos com friso dourado, magia roxa caindo do alto | Mage KayKit | (sem número) / 1,3 / 1,3 |
| E | Elites | as mesmas figuras com dourado velho e brilho nos frisos | contorno de elite | iguais aos de cima |
| 7 | Cavaleiro (`knight`) | elmo com coroa de pontas, capa vermelha, placas, escudo e espada | Warrior KayKit | 1,8 / 2,07 / 1,6 |
| 8 | Ancião (`priest_elder`) | coroa, manto roxo e dourado, cajado com orbe roxo; "pode invocar reforços (opcional)" | Mage KayKit | 1,9 / 2,19 / 1,5 |
| 9 | Morvath (`morvath`) | rei esqueleto, coroa, cabelo branco longo, mantos roxos e dourados, gema roxa no peito, magia roxa | Warrior KayKit com lâmina | 2,2 / 2,53 / 1,6 |

Cuidado com a escala: Morvath a 2,53 e os guardiões acima de 2 mudam o raio de colisão (`radius`) e a leitura do
chefe; o Gameplay Engineer confere colisão, alcance dos ataques e a câmera antes de fechar.

## Como fazer sem modelos novos (gratuito, dados e não código)

1. **Paleta por inimigo**: o KayKit pinta tudo por uma paleta de 32 quadrados (1024 x 1024). Uma cópia da paleta por
   inimigo, trocando só os quadrados de pano, metal e acento, dá a cor da prancha a cada um sem tocar na malha.
   `tools/bake.gd` ganha `"texture"` em `MODELS` (a paleta daquele inimigo); as paletas saem de uma tabela de cores
   por inimigo num script (mesmo espírito de `tools/recolor_hero.gd`).
2. **Peças presas aos ossos antes de assar**: `MODELS` já aceita armas em encaixes (`handslot.r/l`); acrescentar
   `"props"` (peças KayKit ou formas simples num osso, com posição): elmo e ombreira do Esqueleto, coroa e capa do
   Cavaleiro, coroa do Ancião, coroa, gema e capa de Morvath, escudo-torre do Escudo, brasas do Corredor (emissivas).
   Como a multidão é assada, as peças entram no assado e não custam nada a mais por inimigo na tela.
3. **Armas certas**: Escudo troca o machado pela lâmina; Corredor perde as lâminas; Cavaleiro com lâmina e escudo.
4. **Escala**: `size` em `tools/make_data.gd` (dado), regerar com `make_data.gd -- enemies` e reassar com `bake.gd`.
5. **Efeitos**: cor dos projéteis e avisos por inimigo (roxo frio do Feiticeiro, laranja do Besteiro, roxo do Sacerdote
   e de Morvath) onde o efeito já existe.

## O que não dá sem modelo novo (Meshy suspenso)

Crânios com expressão, corpos e armaduras esculpidos, cabelo longo de Morvath, mantos com pregas e capas que
balançam: aproximamos por cor, peças rígidas e escala. Pedidos ao Meshy por inimigo podem ficar prontos (imagem de
cada bloco da prancha, como o do Explorador) para quando houver créditos.

## Decisões do Daniel (2026-11-14)

1. **Feiticeiro**: magia e olhos em **roxo**, não verde (o verde fica só da Emeth e do portal). Na paleta e nos
   projéteis dele, trocar o verde da prancha por roxo, distinto do roxo do Sacerdote e de Morvath pelo tom (mais
   frio e claro no Feiticeiro).
2. **Ancião invoca reforços**: depois (não nesta versão).
3. **Morvath**: como na prancha, rei esqueleto com coroa, cabelo branco longo, mantos roxos e dourados, gema roxa.

## Feito em 2026-11-14 (sem modelos novos, sem créditos)

Ferramentas e dados:
- `tools/make_palettes.gd`: uma paleta por inimigo (`assets/models/palettes/<id>.png`) sobre a paleta de 32 quadrados
  do KayKit; tabela de cores no topo (`FACTION` e `PALETTES`). A versão elite de cada um é a mesma paleta com
  dourado velho nos frisos (`ELITE_TRIMS`, `<id>_elite.png`, ligada por `EnemyDef.palette` no `_pair` do
  `make_data.gd`); a barra de armadura e o contorno das elites ficam como estavam.
- Quadrados que brilham sozinhos (`crowd.gdshader`, `glow`): os quatro últimos da fileira de baixo (violeta frio do
  Feiticeiro, roxo dos sacerdotes e de Morvath, brasa, olhos).
- `tools/bake.gd`: cada inimigo com entrada própria em `MODELS` (`texture`, `hide`, `remap` de quadrados por peça,
  `props` presos aos ossos antes de assar, `bend` para curvar, armas com escala). Peças de outros modelos KayKit
  (`Knight_Cape`, `Mage_Cape`, `Skeleton_Rogue_Hood`) entram pintadas num quadrado da paleta, com o sombreado delas.
  A cabeça da multidão encolhe mais 28% (`HEAD_SHRINK`): a prancha tem proporção adulta.
- `PoseBaker.snapshot` grava os assados em 16 bits (`ARRAY_FLAG_COMPRESS_ATTRIBUTES`): com três modelos a mais,
  `assets/baked` ficou em 45 MB (antes 46).
- Escala da prancha em `make_data.gd` (Esqueleto 1,15). Raio de colisão cresce menos que a figura: corredor 0,35 para
  0,45, feiticeiro 0,45 para 0,5, besteiro 0,5 para 0,55, escudo 0,7 para 0,75, cavaleiro 1,0 para 1,1, ancião 0,9
  para 1,0, Morvath 1,2 para 1,4. Os tons frios por inimigo (`tint`) saíram: a cor vem da paleta.
- Cor da magia (`EnemyDef.magic_color`): virote do Feiticeiro violeta frio, leque laranja do Besteiro (corte em
  leque sobre o cone marcado), explosão do Corredor em brasa, anel onde caem os golpes do Sacerdote, do Ancião e da
  chuva de Morvath em roxo. Os avisos no chão continuam vermelhos.
- Pedidos ao Meshy prontos (não rodados): `tools/meshy/prompts.json`, entradas `enemy_<id>`, com as quatro vistas de
  cada bloco da prancha em `tools/meshy/ref/enemies/<id>/` (tira inteira em `<id>.png`; elites em `elites.png`).
  Custo estimado: 35 créditos por inimigo (geração e esqueleto), sem animação (o assado usa as do KayKit).
- Prancha do jogo: `tools/enemy_lab.gd` (vista do jogo, frente e costas, com o herói para escala).

| Inimigo | Fidelidade | O que tem | O que ficou para modelo |
|---|---|---|---|
| Esqueleto | MÉDIA | osso marfim, elmo redondo, ombreira, trapos vermelhos na cintura e no pescoço, lâmina | corpo do KayKit (largo, curto), crânio sem expressão |
| Corredor | MÉDIA | sem arma, curvado, trapos vermelhos, brasas acesas no peito, olhos de brasa | costelas abertas, corpo magro |
| Feiticeiro | MÉDIA | capuz e manto escuros com vermelho, olhos e gema violeta frio, cajado de madeira | manto longo com pregas, ombreiras |
| Besteiro | MÉDIA | capuz roxo escuro, capa e lenço vermelhos, bronze e couro, besta | aljava, armadura das pernas |
| Escudo | MÉDIA | bronze escuro, escudo grande com emblema, espada, trapos vermelhos | escudo-torre de verdade, ombreiras grandes |
| Sacerdote | MÉDIA | capuz e manto roxos, frisos dourados, olhos roxos | manto até o chão com barra rasgada |
| Elites | MÉDIA | mesma figura com frisos de dourado velho, contorno e barra de armadura | brilho nos frisos |
| Cavaleiro | MÉDIA | elmo com chifres e coroa de pontas, capa vermelha, espada e escudo, aço com ouro | placas esculpidas, capa longa |
| Ancião | MÉDIA | coroa com gema, manto e capa roxos com ouro, cajado com orbe roxo | manto em camadas, cajado alto |
| Morvath | BAIXA | coroa, gema roxa no peito, mantos roxos, ombreiras de ouro, cabelo branco em placas | cabelo longo de verdade, mantos em camadas, rosto de rei |

Escala: os corpos do KayKit são largos e curtos; mesmo com o `Slender` e a cabeça menor, ainda não são as figuras
esguias da prancha. Os pedidos ao Meshy resolvem isso.

# Passada de VFX: herói contra inimigos, famílias de Bênção e a luz sobre o que se pega (2026-11-20)

Dono: `art-director`. Implementa: `technical-artist` (shaders e `Fx`), com as ligações pequenas indicadas em cada item
(gameplay-engineer quando toca `rooms.gd`, `horde.gd`, `combat.gd`, `skills.gd` ou `make_data.gd`; o Game Director
divide). Vale só o visual: **nenhum tempo de aviso, alcance, dano, janela ou colisão muda** (regra 9 do
`art_direction.md`). Onde um número é proposta e não medida, está escrito "proposta".

Pedido do Daniel (2026-11-20): "os efeitos do herói e dos inimigos não estão bons, precisa melhorar, deixar mais
profissional, ter mais diferença entre eles. Inclusive quando precisa pegar alguma coisa na sala tinha que cair uma luz em
cima."

## 0. Evidência

HEAD `9271e95` com a árvore de trabalho do dia, estilizado (`--look=stylized`, o padrão do exe), Forward+ na RTX 5060,
1920 x 1080, semente 5. Capturas antes, reduzidas a 1280, em `docs/art/shots/vfx_pass_before/` (os PNG inteiros ficaram no
scratchpad da sessão). Medidas com `tools/frame_stats.py --hue` e dois contadores simples sobre caixas da captura: matiz
p10/p50/p90 dos pixels com saturação acima de 0,3 e luma acima de 80 a 150, e maior canal (p50, p99, % acima de 235, % com
os três canais acima de 235 = "branco estourado"). Teto da tela: `ScreenTone.SAFE` 226, absoluto 235.

| Captura | Comando (todas com `--look=stylized --seed=5`, `RES=1920x1080`) | O que mostra |
|---|---|---|
| `s_swing`, `s_hit`, `s_hit2` | `--bot --stress=5 --stress-ids=skeleton,guard,skeleton --shot-on=swing|hit` | Corte Veloz, acerto, Giro |
| `s_omega` | o mesmo com `--shot-on=omega --shot-after=0.25` | Ômega do ataque (Lança de Luz) |
| `h_swing`, `h_hit`, `h_omega` | `--bot --autopick --shot-on=...` na sala 1 | o quadro de impacto preto e branco do Ômega |
| `h_spin` | `--bot --autopick --shot-on=spin` | Giro da Alvorada com a cruz do brilho |
| `h_special` | `--shot-on=special --shot-after=0.15` | Onda de Luz e o acerto dela |
| `h_ult_cleave`, `h_ult_vortex` | `--ult-full --ultimate=cleave|vortex --shot-on=ult` | ultimates |
| `b_fire`, `b_frost`, `b_light`, `b_vigil` | `--boon-ids=` cinco Bênçãos de cada família, `--shot-on=hit` | famílias |
| `e_ranged`, `e_melee` | `--stress=6/8 --stress-ids=archer,mage,priest` e `skeleton,runner,guard,skeleton_elite --hero-at=0,0` | preparos, tiros, explosão do corredor |
| `m_scythe`, `m_reap`, `m_blades`, `n_*` | `--start=boss --hero-hp=9999 --hero-at=0,6 --boss-only=<ataque> --shot-on=boss:<momento>` | Morvath |
| `r_clear*`, `r_shop` | `--bot --autopick --shot-at=35.5|36.3|38.5`, `--start=shop` | a recompensa depois da sala, a loja |

Referências só observadas (nada copiado, nada no repositório): quadros do Hades II do Daniel (`Boss 1`, 184747 e
185235) e do Ember & Blade (`Captura 211010`).

## 1. Inventário: o que existe hoje e como é feito

### 1.1 Herói
| Efeito | Feito por | Cor | Forma hoje |
|---|---|---|---|
| Corte dos golpes 1 e 2 | `Fx.slash` (`slash.gdshader`, `slash_ink.gdshader`, `slash_strokes`) | `Combat.EMETH` (0,3; 1,0; 0,45) ou a da família | fita em arco com fio claro e tinta |
| Golpe 3 (giro) e finalizadores | `Fx.crescent` (360 graus), `Fx.glint` (cruz e anel), `Fx.ring` | marfim, esmeralda | elipse fina perfeita em volta, cruz de linhas compridas |
| Estocadas, Corte Veloz, Ômega do ataque | `Fx.thrust` (`emeth_thrust.gdshader`) | esmeralda, veios de ouro no Ômega | feixe reto uniforme |
| Onda de Luz e Ômega do especial | `Projectiles` WAVE/SPARK (`emeth_wave.gdshader`) | esmeralda, fio de ouro | meia-lua curta |
| Círculo e Ômega do círculo | `Ground` BIND (estilo 2) e `Fx.ring` + `Fx.chips` no estouro | `CAST_COLOR` marfim | aro fino com marcas |
| Esquiva | nada próprio (só o raio-x e o anel) | | |
| Acerto | `Fx.gash` (`impact.gdshader`), `Fx.chips` cinza-pedra, clarão do inimigo (`crowd.gdshader`) | cor do golpe | talho reto, lascas |
| Acerto do especial | `Fx.impact` estrela (`SPECIAL_STAR`) + lascas de ouro | cor do tiro | estrela de pontas iguais |
| Abate | `Fx.burst(&"bone")`, arremesso (`Horde.THROW`), dissolver em ouro velho (`dissolve_color`) | osso 1,4, ouro velho | pontos redondos, faixa de ouro |
| Ultimate Corte do Juízo | `ult_rift.gdshader`, `Fx.gash` cruzado, `Fx.chips` | esmeralda | retângulo verde no chão, estrelas de 4 pontas |
| Ultimate Voragem | `ult_vortex.gdshader`, `Fx.ring` | véu esmeralda 0,3, braços marfim, aro de ouro | disco com espiral desenhada |
| Bênçãos que agem sozinhas | `Skills` (STRIKES, NOVA, FAN, METEOR, CONSECRATE, ORBIT): `Fx.ring` + `Fx.burst` + `Game.column` | `Boon.FAMILY_COLOR` | o mesmo anel, os mesmos pontos e a mesma coluna para todas |
| Bênçãos no golpe | `Combat.color_of`: Chama `FIRE`, Geada `FROST`, Luz e **Vigília** `LIGHT` | | só a cor do corte muda |
| Salmos | `PsalmPlay`: `Fx.ring`, `Fx.burst(&"dust")`, `Fx.chips` | `PsalmDef.color` ouro velho (todos iguais) | anéis |
| Encantos | Lâmina Tríplice = três ondas; Eco = o giro de novo; Retorno = nada visível | da onda | |
| Números | `Fx.number`, `NumberTally` | pálido, esmeralda nos grandes, família | ok |
| Partículas do herói | `Fx.BURSTS` `light`, `heal`, `spark` (`CPUParticles3D`, `Fx.quad` = ponto redondo macio, aditivo) | 1,1 a 2,6 | bolinhas redondas |

### 1.2 Inimigos e Morvath
| Efeito | Feito por | Cor | Forma hoje |
|---|---|---|---|
| Preparo do esqueleto | `EnemyFx` GLINT | `PALE` (1,25; 1,2; 1,05) | estrela branca de 4 pontas na lâmina |
| Preparo do corredor | `EnemyFx` TREMBLE | poeira | pontos |
| Preparo do feiticeiro e do Ancião | `EnemyFx` ORB | `magic_color` violeta (1,7; 1,25; 3,2) | miolo e anéis redondos |
| Preparo do besteiro | besta desenhada, fio de mira | marfim, vermelho | bom (LC-1b) |
| Rito do sacerdote | V dos braços, chama | roxo (1,9; 0,45; 3,0) | bom (LC-3b) |
| Tiros | `Projectiles` BOLT, ORB (`enemy_orb*.gdshader`), trepadeira `low` | cor da magia: virote âmbar (3,0; 1,3; 0,3), orbes violeta e roxo | losango laranja, bola com halo |
| Explosão do corredor | `Ground.add_warning(..., magic_color)`: o aro de queda na cor da magia | laranja (3,0; 1,1; 0,25) | disco laranja aditivo |
| Golpe do Escudo, bote | avisos do `Ground` | vermelho do perigo | bom |
| Morte | `Fx.burst(&"bone"|&"dust")`, dissolver ouro velho | | igual à do herói |
| Elites | ouro velho no aço, contorno; o resto igual ao comum | | |
| Surgir (elite) | `Game.column` na cor da borda | ouro | a mesma coluna das recompensas |
| Morvath: foice, Ceifa | `Fx.boss_scythe` (`boss_scythe.gdshader`) | violeta com **fio ciano** | setor com fio claro, igual ao corte do herói |
| Lâminas e tempestade | `Projectiles` SOUL (`soul_crescent.gdshader`), `boss_wake` | `SOUL_VIOLET` | meia-lua lisa, igual à onda do herói |
| Erupções, invocação, ritual | `Ground.rune_burst`, `spectral_column`, `BossShield` | vermelho, espectral 165 | bom em forma (ART-05.2 aberto) |
| Maldição | `CurseAura`, `Fx.burst(&"curse")` | violeta 269 | bom |

### 1.3 O que se pega
| Coisa | Hoje |
|---|---|
| Recompensa da sala vencida | `RewardGem` no relicário (disco de ouro velho, halo abaixo do glow) e **uma coluna de 1 s** (`Game.column`, raio 1,4, 12 m, cor de `Rooms._reward_color`), que some; depois nada marca de longe |
| Itens da loja | `RewardGem` em relicário, nenhuma luz |
| Fonte | coluna de 1,2 s ao surgir (`Combat.LIGHT`), depois só a água |
| Bênção tomada, Salmo tomado, elite surgindo, Bênção que cai | a mesma `Game.column` |

## 2. Diagnóstico

### 2.1 O que lê como amador (medido)
1. **Nada respeita o teto da tela.** A regra é 226 (absoluto 235). Medido: explosão do corredor ao lado do herói com o
   maior canal acima de 235 em **67%** da caixa de 330 x 200 (`e_melee`); fogo das Bênçãos de Chama 32% e branco estourado
   3,7% (`b_fire`); estocada do Corte Veloz 39% e branco 12,7% (`s_swing`); acerto de Geada sobre o herói branco 6,9%
   (`b_frost`); estrelas do Corte do Juízo 10%; meias-luas da tempestade 12,6% e branco 5,1%; o fio do corte 7 a 16%. Os
   `Fx.BURSTS` têm cor de 1,4 a 3,2 (acima do limiar do glow 1,3) e o `ring.gdshader` soma `intensity` 1,5 aditivo.
2. **Bolinhas redondas.** Toda explosão de partículas do `Fx.BURSTS` é o mesmo ponto redondo macio aditivo
   (`Fx.soft_dot`): fogo, gelo, luz, osso, cura, almas. Na tela leem como bolhas de sabão (pontos brancos em volta da
   cabeça do herói no Ômega e na ultimate, `s_omega`, `h_ult_cleave`; bolas laranja do Redemoinho, `b_fire`). O Hades II e
   o Ember & Blade não usam ponto redondo: centelha em estrela irregular, lasca, espinho, língua de fogo.
3. **Primitivas iguais para tudo.** O mesmo `Fx.ring` (aro aditivo com preenchimento) marca o círculo do herói, os golpes
   das Bênçãos, o Salmo, a implosão da Voragem e o aviso que cai; a mesma `Game.column` marca recompensa, Bênção tomada,
   elite surgindo e o raio de Luz. Só a cor muda.
4. **Formas de interface no mundo.** A elipse branca fina e perfeita do giro (`h_spin`, `m_scythe`), a cruz de linhas
   compridas do brilho do finalizador (`h_spin`: uma mira de arma atravessando o herói; também uma **cruz**, contra a
   seção 7 do guia), as estrelas de quatro pontas iguais no acerto do especial e do Corte do Juízo, o retângulo verde chapado
   do Corte do Juízo e o disco com espiral desenhada da Voragem (decalque parado, sem volume nem movimento).
5. **Lança de néon.** As estocadas e o Ômega do ataque são feixes retos de largura e brilho constantes, verde saturado
   (`s_swing`, `s_omega`): leem como sabre de luz de plástico.
6. **Acerto fraco no ponto de contato.** No golpe que acerta, o que se vê no inimigo é um traço branco vertical e lascas
   verdes que parecem folhas (`s_hit`); falta o estalo no ponto do contato que diz "pegou".
7. **Morte sem assinatura.** O inimigo some em faixa de ouro velho com pontos redondos de osso: o ouro é do herói e das
   elites.

### 2.2 O que se parece demais
| Par | Medido | Por quê é ruim |
|---|---|---|
| Fio do corte do herói e fio da foice/Ceifa de Morvath | corte: matiz 162 a 190 (p50 170) sobre a câmara (`m_scythe`); fio da Ceifa: 177 a 204 (p50 180, `n_reap`) | o mesmo ciano, a mesma fita com fio claro: o golpe do herói e o golpe do chefe têm a mesma forma e a mesma cor |
| Corte do herói e esmeralda corrompido / espectral de Morvath | o esmeralda da Emeth (133) sai ciano no fio (170) no estilizado | a cor do herói entra na faixa reservada ao chefe (157 a 181) |
| Onda de Luz e Meias-luas das Lâminas e da tempestade | as duas são meia-lua lisa com borda pálida (`m_blades`, `n_storm`) | só a cor separa; de relance, no meio da luta, não |
| Explosão do corredor, virote e Bênçãos de Chama | corredor matiz p50 25; virote 30 a 31; Chama 4 a 15 (p50 15) | o fogo do herói e o fogo do inimigo são o mesmo disco laranja |
| Preparo do feiticeiro e corpo/almas de Morvath | orbe do feiticeiro matiz p50 259; Morvath 253 a 265 | o violeta deixa de ser assinatura do chefe |
| Brilho do preparo do esqueleto e brilho do finalizador do herói | os dois são estrela branca de pontas iguais | "vai bater" e "eu vou bater" com o mesmo sinal |
| Luz e Vigília | o mesmo `Combat.LIGHT` no golpe; no HUD e nas colunas a Vigília é verde (0,45; 0,95; 0,6), matiz 140, a cor da Emeth | duas famílias sem diferença; uma delas com a cor reservada do herói |
| Elo | `FAMILY_COLOR` violeta (0,85; 0,5; 1,0) | a cor de Morvath |
| Salmo (coluna e placa) | `PSALM_COLOR` lilás (0,85; 0,8; 1,0) | a cor de Morvath |
| Coração e romã (colunas) | (1,0; 0,3; 0,45) e (1,0; 0,4; 0,35) saturados | o vermelho do perigo numa coisa boa |
| Recompensa, Bênção tomada, elite surgindo | a mesma coluna | "algo para pegar" e "um inimigo forte chegou" com o mesmo sinal |

### 2.3 O que está bom e fica
Avisos vermelhos no chão (aro, fio da mira, assinatura de Morvath, as runas da foice), besta e rito desenhados por cima
(LC), maldição, raio-x e anel do herói, a fita do corte com tinta (a ideia: o problema é cor, teto e o giro), o talho ao
longo do corte, os números somados, o medalhão e o relicário da recompensa (AP-1).

## 3. A regra: duas línguas

O que vem do herói e o que vem do inimigo se distinguem **por quatro coisas ao mesmo tempo**, nunca só pela cor:

| | Herói (a Emeth e a luz de Elun) | Inimigos comuns e elites (os mortos) | Morvath (a necromancia) |
|---|---|---|---|
| **Forma** | linha, fio, lâmina, lasca de cristal, espinho, aresta reta; afina nas pontas | fumaça, borda rasgada, pingo, brasa suja, massa arredondada que se desfaz | runa, meia-lua de alma com cauda de fumaça, setor com borda roída |
| **Borda** | dura e clara por fora (fio marfim-menta), tinta escura por dentro | macia ou rasgada; **escura por fora** e cor por dentro (o contrário do herói) | aro violeta com borda roída por ruído; nunca fio liso claro |
| **Movimento** | entra em 1 a 2 quadros, a tinta segura e some devagar (0,3 s); lascas voam para fora e caem | junta antes (puxa para dentro, cresce devagar), estoura curto, fumaça sobe e se desfaz em 0,4 a 0,8 s | gira e escorre; almas se juntam antes e se desfazem em fumaça |
| **Cor** | esmeralda 125 a 145, marfim, ouro velho; Bênçãos na cor da família | carmim e magenta do perigo (330 a 355) sobre núcleo escuro; poeira e cinza | violeta 255 a 270, espectral 157 a 181 (só dele) |
| **Partícula** | lasca alongada (`chip.gdshader`) e espinho | fiapo de fumaça e brasa suja (novo `wisp`) | fiapo violeta e alma espectral |

Regras que valem para toda peça nova ou mexida:
1. **Teto**: na tela, nenhum efeito passa de 226 no maior canal em mais de 1% da caixa dele e nada tem os três canais acima
   de 235 (branco estourado 0%). Toda cor de efeito passa por `ScreenTone.fit` ou `linear_peak`, como a coluna e a onda já
   fazem. Nada aditivo sem teto: efeitos novos usam `blend_premul_alpha` (luz = o que soma, alfa = o que cobre).
2. **Sobre o herói**: dentro da caixa de 300 x 300 px em volta dele, nenhum efeito de ninguém passa de 200 no maior canal;
   os efeitos do próprio herói abrem em volta dele (`hero_hole`, como a onda e a coluna) ou ficam atrás dele na vista
   (`Fx.hero_burst`).
3. **Nenhum ponto redondo macio** em efeito novo; os `Fx.BURSTS` existentes são trocados (seção 5.6).
4. **Nunca cruz**: nenhuma estrela de quatro pontas iguais em ângulos retos, nenhuma linha que atravesse o herói. Estrelas
   têm 5 a 7 pontas desiguais e giradas.
5. **Cor diz quem fez**: esmeralda e famílias = herói; carmim e magenta = inimigo que fere; violeta e espectral = Morvath;
   âmbar acinzentado = o chão das Runas; vermelho 349 a 4 = aviso. Duas fontes que se encontram na tela ficam a 25 graus
   de matiz ou mais.
6. **Luz que vem de cima é só do que se pega** (seção 6). Coluna de luz para qualquer outra coisa sai.

## 4. Paleta dos efeitos por fonte (valores na tela, estilizado)

Matiz em graus medido na captura (o `ScreenTone` e a saturação do mundo deslocam o matiz do material; o implementador
acerta o material até a tela dar a faixa). Saturação HSV dos pixels do efeito, p50.

| Fonte | Matiz na tela | Sat p50 | Valor (maior canal, p50 do miolo) | Material de partida (proposta) |
|---|---|---|---|---|
| Emeth, corte e onda sem Bênção | **125 a 145** (hoje 162 a 190 no fio) | 0,45 a 0,7 | 170 a 215 | corpo (0,22; 0,85; 0,38), fio marfim-menta (0,82; 0,95; 0,82) com `edge_pale` até 0,55, não mais |
| Ouro velho do herói (veios, Ômega, onda) | 36 a 42 | 0,45 a 0,6 | até 200 | `Fx.OLD_GOLD` |
| Chama (Sarael) | **30 a 38** (hoje 4 a 25) | 0,6 a 0,85 | 180 a 215 | `Combat.FIRE` (1,0; 0,6; 0,16) |
| Geada (Nivael) | 198 a 208 | 0,35 a 0,6 | 170 a 215 | `FROST` (0,5; 0,82; 1,0) fica |
| Luz (Lumael) | 42 a 48 | **0,2 a 0,35** (pálida) | 190 a 220 | `LIGHT` (1,0; 0,92; 0,7) |
| Vigília (Shomael) | **80 a 95** (sálvia, hoje 140) | 0,3 a 0,45 | 150 a 200 | novo `VIGIL` (0,66; 0,78; 0,46), o `AngelSeal.TINT` da Vigília |
| Elo | as duas cores das famílias, em duas faixas; o elo em ouro velho | | | `FAMILY_COLOR[DUO]` sai do violeta: ouro velho (0,78; 0,62; 0,34) |
| Salmo | ouro velho | 0,35 | até 200 | `PsalmDef.color` (já é) e `Rooms.PSALM_COLOR` igual a ele |
| Inimigo que fere (tiros, explosões, golpe de magia) | **330 a 355** | 0,55 a 0,8 | 150 a 205, sobre núcleo escuro | ver 5.4 |
| Preparo de inimigo ("vai bater") | 345 a 10, pálido | 0,2 a 0,4 | 180 a 215 | `EnemyFx.PALE` vira (1,05; 0,78; 0,74) |
| Morvath | 255 a 270 e 157 a 181 | | | como está; o fio ciano da foice sai (5.5) |
| Aviso | 349 a 4 | | | como está |

Pares a conferir em toda medida: Chama 30 a 38 contra perigo 349 a 4 (26 graus ou mais) e contra Luz 42 a 48 (separados
também pela saturação, 0,6+ contra 0,35-); Vigília 80 a 95 contra Emeth 125 a 145 (30+); Geada 198 a 208 contra espectral
de Morvath 157 a 181 (17+, separados pelo valor e pelo lugar, como hoje a Emeth e o espectral; conferir na luta de
Morvath com uma Bênção de Geada).

## 5. Proposta por item

Todos os tempos de golpe, aviso e acerto ficam. "Duração" é do desenho.

### 5.1 Herói, a lâmina (P0)

**V-01 Cor do corte de volta ao esmeralda (P0).** `slash.gdshader`, `slash_ink.gdshader`, `crescent.gdshader`,
`emeth_thrust.gdshader`, `emeth_wave.gdshader` no estilizado: o fio pálido deixa de puxar para o ciano; miolo e fio no
matiz da Emeth. Teto por `ScreenTone.fit` na cor do fio (hoje `style_edge_cap` 0,38 não segura: p90 255).
Aceite: `s_hit2` e o giro sobre Morvath (`m_scythe` refeita sem `--bot`, ver 8): pixels do corte com matiz p10 a p90 dentro
de **122 a 150**, maior canal p99 até 226, branco estourado 0%.

**V-02 Giro e finalizadores sem elipse de interface (P0).** O `Fx.crescent` de 360 graus do giro vira uma fita que varre
300 graus em 3 quadros (0,05 s, o `slash_sweep_time`), mais larga na cabeça (0,35 m) e afinando para a cauda (0,08 m),
corpo esmeralda sobre tinta (`CRESCENT_INK` 0,28 fica), fio marfim-menta só no terço da cabeça; a cauda some primeiro
(a fita "se fecha" atrás da lâmina); vida 0,3 s (`CRESCENT_TIME`). Diâmetro igual ao de hoje (o alcance). Nos
finalizadores de meia-lua, a mesma fita com 120 a 180 graus. Nenhuma marca tracejada.
Aceite: na captura do giro, nenhum anel fechado; a fita tem largura que varia de 3 vezes ou mais entre a cabeça e a cauda;
teto como V-01.

**V-03 Brilho do finalizador sem cruz (P0).** `glint.gdshader`: as duas linhas (`spike_long` 0,3, `spike_short` 0,12)
viram uma estrela de **6 pontas desiguais** (comprimentos 0,18 a 0,42 m, ângulos com 12 a 20 graus de desvio do regular,
girada a cada golpe pela semente), anel em metros como hoje (até 1,6 m), meio vazado; nenhuma ponta passa de 0,42 m;
cor marfim com as pontas no esmeralda; 0,2 da luz sobre o corpo (fica). Vida e tempos iguais (`ComboNode.glint`).
Aceite: na captura do giro (`--shot-on=spin --shot-after=0.0`), nenhuma linha reta com mais de 60 px a 1080; o recorte do
herói sem linha que o atravesse.

**V-04 Estocada e Ômega do ataque como lâmina, não néon (P0).** `emeth_thrust.gdshader`: perfil de lâmina (afina para a
ponta, de 1,0 da largura na base a 0,15 na ponta), borda dura marfim-menta de 2 px dos dois lados, miolo esmeralda escuro
(valor 0,55 do fio), tinta escura por baixo (alfa 0,4) como no corte, e a luz descendo da base para a ponta em 0,06 s
(entra) e saindo da base para a ponta em 0,15 s (a cauda vai antes); Ômega com os dois veios de ouro velho (ficam) e
quatro a seis espinhos de cristal curtos (0,3 a 0,6 m, `chip` alongado 4:1) saindo da ponta para os lados no quadro do
acerto. Brilho por `ScreenTone.fit`.
Aceite: `s_swing` e `s_omega`: no recorte do feixe, maior canal p99 até 226, branco 0%; largura na ponta até 0,3 da base;
matiz como V-01.

**V-05 Estalo no contato (P0).** Novo `Fx.contact(pos, dir, color, heavy)`, chamado onde hoje sai o `Fx.gash` de acerto
real (`Combat`): estrela de 5 a 7 espinhos desiguais (0,25 a 0,6 m; pesado 0,4 a 0,9), voltada para fora do golpe (metade
dos espinhos num leque de 70 graus na direção do corte), miolo marfim pequeno (0,12 m), pontas na cor do golpe, 3 quadros
(0,05 s) com escala 1,0 para 1,25, sem fumaça; o talho ao longo do corte fica e as lascas cinza-pedra também. Orçamento:
entra no `BUDGET_GASHES` (8 por quadro). No inimigo, o clarão do corpo como está.
Aceite: em `s_hit`, no ponto do contato (caixa de 80 x 80 em volta do primeiro inimigo atingido) um estalo visível no
quadro do acerto com maior canal p99 até 226; nenhuma estrela de 4 pontas.

**V-06 Onda de Luz que se lê no voo (P1).** Hoje a onda a 10 m tem maior canal p90 92 (`h_special`, quase some). Corpo
esmeralda 0,75 (era 0,55, `WAVE_BODY_LIGHT`), fio de ataque a 0,5 do pálido, rastro de três fiapos de cristal (lascas
alongadas que ficam 0,15 s no caminho, 1 a cada 0,6 m voado); a meia-lua do herói fica com a borda **lisa e dura**, o que a
separa das almas de Morvath (5.5, borda roída). O acerto em estrela furada de ouro vira o V-05 com espinhos de ouro velho.
Aceite: a onda a 8 a 12 m do herói com maior canal p50 do miolo 160 a 210 e matiz como V-01.

**V-07 Círculo de luz (P1).** Aro e marcas (`circle_rim*`, `circle_mark_*`) em marfim com as marcas em ouro velho, como
hoje; no lançamento, em vez do `Fx.ring` aditivo, quatro a seis lascas de luz caem de 1,5 m sobre o aro (0,2 s) e o aro
desenha do ponto mais perto do herói em volta (0,12 s). Estouro do Ômega: espinhos de cristal (os do V-04) saindo do aro
para dentro, 0,2 s, mais as lascas marfim que já existem. Nenhum preenchimento.

**V-08 Esquiva e Corte Veloz (P2).** Esquiva: um rastro de três a quatro silhuetas de tinta do herói (alfa 0,25 a 0,1, 0,12
s cada, cor da tinta do corte com o fio marfim só na borda de cima), nunca branco. Corte Veloz: o V-04. Retorno do Corte
(Encanto): durante a janela de 1 s, um fio esmeralda fino corre pela lâmina (`EmethSword`, `CORE_*` mais claro, abaixo do
glow) e some no golpe que aproveita.

### 5.2 Herói, ultimates (P1)

**V-09 Corte do Juízo.** O retângulo verde chapado sai. No gesto: a faixa marcada só pelas duas bordas longas em fio
marfim-menta com divisas fracas (o chão continua à mostra). No golpe: uma fenda de cristal ao longo do eixo da faixa
(`ult_rift`: rachadura que já existe, mais clara e larga no meio, 0,32 m), dela sobem **8 a 12 espinhos de cristal
esmeralda** em duas fileiras alternadas, inclinados para fora 15 a 30 graus, 1,2 a 2,4 m de altura, nascem em 0,08 s um
após o outro do herói para a ponta (0,12 s do primeiro ao último) e quebram em lascas em 0,25 s (a sensação do Ember &
Blade, o cristal brotando do chão, em verde e nosso). Nos inimigos atingidos, o V-05 pesado em vez das estrelas de 4
pontas. Teto 226; a fenda e os espinhos abrem em volta do herói (`hero_hole`).
Aceite: `h_ult_cleave`: nenhum preenchimento chapado (p90 menos p10 da luma dentro da faixa, fora dos espinhos, acima de
40); espinhos visíveis; branco 0%.

**V-10 Voragem.** O disco com espiral desenhada vira um redemoinho com volume: o chão dentro escurece (tinta 0,35, mais
forte no meio); três braços de **fiapos de lasca marfim** (o `chip`) girando para dentro numa espiral logarítmica, puxados a
2 a 5 m/s; poeira e cascalho do chão (cinza-pedra, as lascas do acerto) sendo arrastados da borda para o meio; o aro de ouro
velho fino fica e se fecha na implosão; no centro, nada claro até a implosão, que é um estalo V-05 grande (1,2 m) e a onda
de lascas para fora. Véu esmeralda até 0,15 (era 0,3; lia ciano, matiz p50 170).
Aceite: `h_ult_vortex` a 0,6 s: matiz dos pixels saturados dentro do disco 125 a 150 ou ouro velho; nenhuma linha de
espiral contínua desenhada no chão; vídeo de 1 s mostrando movimento para dentro.

### 5.3 Bênçãos por família (P0 na cor, P1 na forma)

Hoje a família só troca a cor do mesmo corte, do mesmo anel, das mesmas bolinhas e da mesma coluna. Cada família ganha uma
**forma própria** que aparece em três lugares: no corte que ela muda (um detalhe na fita), no estalo do acerto (V-05) e no
que ela faz sozinha (`Skills`).

| Família | Forma | No corte | No acerto | Partícula | O que age sozinho (`Skills`) | Duração |
|---|---|---|---|---|---|---|
| **Chama** (âmbar 30 a 38) | língua de fogo para cima, borda serrilhada | a cauda da fita se parte em 3 a 5 línguas que sobem 0,4 m e somem | espinhos curtos + 3 línguas subindo | brasa alongada subindo (gravidade +3), vida 0,5 s, e um fiapo de fumaça escura no fim | NOVA e METEOR: em vez do disco com preenchimento, um anel de línguas no chão (12 a 18 línguas de 0,4 a 0,8 m) que sobem e apagam em 0,4 s, chão chamuscado escuro que some em 1,5 s; Redemoinho (ORBIT): a bola vira uma brasa alongada com cauda de fumaça, miolo âmbar 0,8 | 0,4 a 0,6 s |
| **Geada** (198 a 208) | cristal angular, faceta, rachadura | fita com 4 a 6 farpas de gelo triangulares na borda de ataque | estilhaço de 5 a 7 farpas triangulares que caem | farpa triangular (gravidade -8), vida 0,35 s | NOVA: placas de geada hexagonais irradiando no chão até o raio, que ficam 0,8 s e se desfazem em rachaduras; congelado: casca de gelo facetada no corpo (o `freeze` de hoje pinta o corpo de azul chapado e lê como recorte, `b_frost`) | 0,3 a 0,8 s |
| **Luz** (42 a 48, pálida) | raio vertical fino vindo de cima, pó suspenso | fio da fita marfim-ouro mais fino e longo | um raio fino (0,12 m de largura, 5 m de altura, 0,15 s) cai no alvo e um anel fino com 8 marcas | pó dourado lento subindo (0,3 m/s), vida 0,8 s | STRIKES: o raio fino de cima (é a única coluna que fica fora das recompensas, sempre com 0,12 a 0,2 m de largura, nunca do tamanho de uma coluna de recompensa); CONSECRATE: chão com fio de ouro e pó | 0,15 a 0,8 s |
| **Vigília** (sálvia 80 a 95) | brado: arcos segmentados que se abrem; escamas de escudo | fita com 3 traços paralelos atrás da borda (o eco do brado) | três arcos de 60 graus que se abrem em 0,2 s (1,0 a 1,8 m) | traço reto curto (0,15 m), nenhuma partícula voando | NOVA de Vigília: três arcos segmentados concêntricos (12 segmentos com falhas) que se abrem, sem preenchimento; Escudo e Firmeza: escamas hexagonais em volta do herói, atrás dele na vista, que acendem ao absorver | 0,2 a 0,4 s |
| **Elo** | as duas formas juntas | as duas | as duas, metade dos espinhos de cada | as duas | as duas | |

Ligações: `Combat.color_of` com a Vigília separada da Luz (nova cor `VIGIL`); `Boon.FAMILY_COLOR` com Chama, Luz,
Vigília e Elo da seção 4 (gameplay-engineer, uma linha cada; o HUD e as cartas leem dali, conferir com o ui-ux-designer);
`Skills` chama a peça da família em vez do `fx.ring` + `fx.burst` (technical-artist).
Aceite por família: uma captura de `--boon-ids=` cinco Bênçãos da família `--shot-on=hit` e uma do Skill dela. Matiz dos
pixels saturados do efeito na faixa da seção 4; branco 0%; e um teste cego no Daniel: as quatro capturas sem HUD, ele diz
a família de cada uma.

### 5.4 Inimigos comuns e elites (P0 na cor e teto, P1 na forma)

**V-11 Magia dos mortos no carmim e magenta, com núcleo escuro (P0).** `magic_color` no `_enemies` do `make_data.gd`
(gameplay-engineer): virote e explosão do corredor **carmim** (matiz 350 a 355 na tela; material de partida (1,4; 0,16;
0,3)), orbes do feiticeiro, trepadeira e leque do sacerdote e do Ancião **magenta** (320 a 330; (1,2; 0,18; 0,85)). O
violeta fica só com Morvath. Teto: maior canal até 205 (abaixo do herói, que é a coisa mais clara da tela).
`enemy_orb.gdshader`: o orbe vira o contrário do herói: **núcleo escuro** (tinta (0,05; 0,02; 0,05), 60% do raio) com o
aro na cor e 3 espinhos curtos girando em volta (1 volta a cada 0,8 s), halo misturado (`HALO` 1,5) em fumaça com borda
rasgada por ruído, em vez da bola clara com halo redondo. Virote: agulha escura de 0,6 m com a ponta carmim e um fiapo de
fumaça de 0,8 m atrás (não o losango laranja).
Aceite: `e_ranged`: matiz dos tiros 320 a 355; nenhum pixel de tiro com maior canal acima de 210; nenhum tiro de inimigo no
matiz da Chama (30 a 38) nem no violeta de Morvath.

**V-12 Explosão do corredor (P0).** Hoje o aro de queda (`Ground.land_color`) sai como disco laranja aditivo estourado
(67% acima de 235 ao lado do herói). Passa a: anel de fumaça carmim-escura com borda rasgada que se abre do corpo até o
raio do aviso em 0,1 s, miolo escuro, 6 a 8 brasas sujas (o `wisp`) e fumaça subindo 0,5 s; nenhum preenchimento claro;
maior canal até 205; no estilizado o mesmo. Vale para todo `land_color` de inimigo.
Aceite: `e_melee`: na caixa da explosão, maior canal p99 até 210, branco 0%; o aro do segundo anel do corredor elite visível
0,4 s antes da segunda explosão (o critério P2-C19a continua).

**V-13 Preparo com o sinal do inimigo (P1).** O brilho da lâmina do esqueleto (`EnemyFx` GLINT) e o fio do escudo (SHIELD)
saem do branco do herói: cor `PALE` vira marfim avermelhado (1,05; 0,78; 0,74), a estrela vira um **risco único ao longo
do fio da lâmina** que corre da guarda à ponta (0,6 m, 2 px a 1080, uma vez por preparo) e um ponto quente na ponta,
nunca uma estrela de 4 pontas. O corredor: a poeira fica e o corpo treme (já); o orbe do feiticeiro: o novo orbe escuro do
V-11 crescendo no cajado.
Aceite: em `e_melee` e `e_ranged`, nenhuma estrela branca nos preparos; matiz do sinal 345 a 10 (pálido, sat 0,2 a 0,4).

**V-14 Morte dos mortos (P1).** O dissolver em ouro velho (`dissolve_color` (0,62; 0,42; 0,18)) vira **cinza que sobe**:
as células que vão sumir em brasa suja (carmim escuro (0,35; 0,07; 0,06), `dissolve_band` 0,08) e um fiapo de fumaça
cinza-escura (valor 0,25) subindo 1 m em 0,6 s por inimigo; o `bone` redondo vira lascas de osso (o `chip`, cinza-osso
(0,55; 0,52; 0,46), 6 a 9, gravidade -16 como hoje). Nada de ouro. Elites: o mesmo com duas lascas de ouro velho a mais (o
aço). O arremesso fica.
Aceite: captura com `--shot-on=hit --shot-after=0.25` num abate: nenhum ponto redondo; a cor da morte fora do ouro velho
(matiz fora de 34 a 42).

**V-15 Elite surgindo (P1).** A coluna de luz (`Game.column` com a cor da borda, `rooms.gd` 487 e `game.gd` 1113) sai: no
chão, um anel de fumaça escura com a borda em ouro velho apagado (valor 0,5) que se fecha em 0,4 s, a elite sobe de dentro
(o `rise` já existe) e um sopro de fiapos sobe 1,5 m. Luz de cima é das recompensas (seção 6).

### 5.5 Morvath (P0 no fio da foice, P1 nas almas)

**V-16 Foice e Ceifa sem o fio do herói (P0).** `boss_scythe.gdshader`: o fio claro da borda (hoje ciano 177 a 204, a cor
e a forma do corte do herói) vira **borda roída**: o violeta (255 a 270) do corpo chega até a borda, que é recortada por
ruído (amplitude 0,15 m, escala 0,4 m) e solta fiapos de fumaça violeta escura para fora por 0,3 s; o mais claro do setor é
um lilás-marfim (0,8; 0,72; 0,95) no miolo, nunca na borda. Nada abaixo de 230 de matiz no setor.
Aceite: `n_reap` e `n_scythe` no quadro do golpe: matiz dos pixels saturados do setor p10 a p90 dentro de 240 a 285;
nenhum ciano (150 a 200) acima de 1% do setor; maior canal p99 até 226.

**V-17 Meias-luas das Lâminas e da tempestade com alma (P1).** `soul_crescent.gdshader` e `boss_wake`: borda de ataque
roída por ruído (a do V-16), núcleo escuro violeta (tinta 0,5) com o miolo lilás só no terço de dentro, e **três caudas de
fumaça** que escorrem para trás e ondulam (1,2 a 1,8 m, 0,3 s), girando 15 graus por segundo no voo; nunca a borda lisa
e clara da onda do herói. Colisão igual (`SOUL_*` não muda).
Aceite: `n_blades` e `n_storm`: branco 0% (hoje 5,1%), maior canal p99 até 226; ao lado de uma Onda de Luz (captura com o
herói atirando na tempestade), as duas se distinguem pela borda (lisa contra roída) num recorte de 200 x 200 sem cor
(conferido em tons de cinza).

**V-18 Erupções e ritual (P2).** Já são de Morvath na forma. Só o aro branco das erupções (luma 255 no aro, `n_erupt`) a
lilás-marfim abaixo de 226 (o branco é do herói), dentro do ART-05.2.

### 5.6 Partículas: trocar as bolinhas (P0)

`Fx.BURSTS` deixa de usar `Fx.quad` (ponto redondo aditivo) e passa à MultiMesh de lascas (`chip.gdshader`, que já tem
alongamento pelo voo) com uma forma por tipo, e todo tipo com cor abaixo de 1,0 por canal antes do `ScreenTone`:

| Tipo | Hoje | Depois |
|---|---|---|
| `light` (herói: Bênção tomada, Ômega carregado, círculo) | 18 pontos marfim 1,1 | 10 lascas marfim 0,9 que sobem (+2) e giram, atrás do herói (`hero_burst`), **nunca acima da altura do ombro dele na tela** |
| `spark` | 10 pontos (2,6; 2,2; 1,4) | 8 espinhos marfim 0,95, vida 0,16 s |
| `fire` | 16 pontos (3,0; 1,2; 0,3) | 10 brasas alongadas âmbar (Chama) 0,95 subindo, fumaça no fim |
| `frost` | 14 pontos (1,2; 2,2; 3,2) | 8 farpas triangulares gelo 0,95 caindo |
| `bone` | 9 pontos (1,4; 1,35; 1,2) | V-14 |
| `dust` | 10 pontos | 6 sopros de poeira com borda rasgada (o `wisp` em cinza), vida 0,6 s |
| `heal` | 16 pontos verdes (0,8; 2,6; 1,2), a cor da Emeth | 10 lascas marfim-rosadas (o coração, matiz 345, sat 0,25) subindo |
| `shadow` (inimigo surge) | 16 pontos violeta (0,75; 0,52; 1,3) | 8 fiapos de fumaça escura (valor 0,2) com borda carmim apagada |
| `soul` | 14 pontos (0,45; 0,88; 0,9) | fiapos espectrais (Morvath) como hoje em cor, forma de fiapo |
| `curse` | 10 pontos violeta | fiapos violeta |

Novo `wisp.gdshader` (fiapo: cartão alongado com borda rasgada por ruído que ondula e se desfaz de baixo para cima;
`blend_premul_alpha`), um material, MultiMesh própria de até 96, para fumaça e fiapos dos inimigos e de Morvath.
Aceite: nenhuma captura das seções 5.1 a 5.5 com ponto redondo macio; `test_fx_budget.gd` com o orçamento igual.

### 5.7 Números (P2)
Ficam. Só: dano da família na cor da seção 4 (Vigília deixa o verde); o número do acerto do herói entra com escala 1,3
para 1,0 em 0,08 s (já há `pop` no contador; conferir no `NumberTally`).

## 6. A luz que cai sobre o que se pega (P0, o pedido do Daniel)

Um facho de luz vindo do alto, sobre toda coisa que o herói pode pegar ou comprar, que **chega quando a sala é vencida** e
**fica até ele pegar**. No Hades II a recompensa se marca pela luz e não pela placa; aqui ela é a luz de Elun que desce
(sem sol, sem raios em leque: um facho).

### 6.1 Onde
| Coisa | Facho | Força |
|---|---|---|
| Recompensa da sala vencida (Bênção, romã, coração, Magia, ouro, Prata, Memória, Encanto, Salmo) | sim | 1,0 |
| Item da loja (do salão e da loja de rota) | sim | **0,75 se o ouro dá**, 0,3 se não dá (sem pó), troca quando o ouro muda (`DoorSign.set_gold` já é chamado) |
| Fonte com água | sim, enquanto houver água; apaga junto da `fountain_spent` | 0,8 |
| Laje da Provação e do Altar | não: têm o fio e o foco próprios (E5) | |
| Recompensa sobre a boca da porta (placa de longe) | não | |
| Bênção tomada, Salmo tomado, elite surgindo, dom que cai | **não** (coluna sai; ver 5.3 e 5.4) | |

Um facho só por coisa; no máximo 6 na tela (a loja tem 5 mais a fonte, nunca juntos).

### 6.2 Forma
- **Tronco de cone vertical** sobre o ponto do medalhão (`RewardGem`, o centro do relicário), raio **0,6 m no alto** e
  **1,25 m no chão** (o relicário tem 1,5 m de largura: a luz o abraça), altura 18 m (o topo sai da tela na câmera do jogo
  e na Perto: a luz "vem de cima", nunca se vê a ponta). Malha: cilindro de 16 lados sem tampas, como o `Fx.beam`.
- **Corpo fraco e mais claro embaixo**: o facho deposita `body` 0,3 do teto (a coluna de hoje usa 0,68), lados suaves
  (`side_soft` 2,2), miolo estreito e mais pálido (`core_width` 10, `core_light` 0,4, `core_white` 0,3); na altura, cheio de
  0 a 0,15 e descendo até 0,35 da luz no topo da tela (nunca some antes do topo: lê como vindo de cima); veios descendo
  devagar (`streaks` 0,15, a 0,25 alturas por segundo, para baixo).
- **Poça no chão**: disco achatado de raio 1,7 m sob o relicário, luz `pool` 0,32 do teto no meio caindo em degradê
  (borda macia 0,5 m), por cima do chão e por baixo de figuras e do relicário (`render_priority` como o anel do herói);
  é decalque, **nenhuma luz de verdade** (a luz da sala não muda, custo baixo, igual no Compatibility).
- **Pó descendo**: 8 lascas finas (o `chip`, 0,04 x 0,18 m) por facho caindo a 0,35 m/s dentro do raio, alfa 0,45, na cor
  do facho, recomeçando no topo; uma MultiMesh para todos os fachos.
- Arquivos (proposta): `scripts/game/reward_shaft.gd` (`RewardShaft.make(pai, cor, força)`, `appear`, `take`,
  `set_strength`), `assets/shaders/reward_shaft.gdshader` (o corpo do `beam.gdshader` com o degradê e o `hero_hole`) e a
  poça no mesmo shader com um `#define POOL`, ou no `floor_decal.gdshader`.

### 6.3 Cor
Base = luz de Elun, **marfim morno (1,0; 0,94; 0,82)**, misturada com o tom da recompensa a `tint` 0,3; saturação do facho
na tela até **0,3** no corpo (nunca o vermelho do perigo, nunca o violeta de Morvath). O tom de cada uma é o esmalte do
medalhão (`RewardGem.ENAMEL_*`, seção 6.3 do guia), para a luz e o medalhão dizerem o mesmo:

| Recompensa | Tom (matiz, saturação do tom antes da mistura) | Na tela (alvo) |
|---|---|---|
| Bênção de um anjo | `AngelSeal.TINT` do anjo da porta (Chama 24, Geada 205, Luz 44, Vigília 88), 0,6 | marfim puxado para a família |
| Bênção de "Dois anjos" e do guardião | marfim puro | marfim |
| Romã | 352, 0,5 | marfim rosado, sat até 0,2 |
| Coração | 340, 0,45 | marfim rosado mais frio, sat até 0,2 (separa da romã pelo medalhão, não pela luz) |
| Magia | 225, 0,5 | marfim-azulado |
| Ouro | 40, 0,55 | marfim dourado |
| Prata | 210, 0,1 | marfim frio quase branco |
| Memória | 38, 0,3 | pergaminho |
| Encanto | 135, 0,4 (a Emeth) | marfim esverdeado pálido, sat até 0,2 |
| Salmo | 40, 0,45 (ouro velho; o `PSALM_COLOR` lilás sai) | marfim dourado velho |
| Fonte | 196, 0,25 | marfim frio |

Teto: `cap` = `ScreenTone.linear_peak(cor)` vezes 0,85 (o corpo nunca passa de cerca de 200 na tela, abaixo do herói e do
medalhão, que ficam mais claros que a luz).

### 6.4 Tempo
| Momento | O que acontece | Tempo |
|---|---|---|
| Sala vencida | o `_room_cleared` cria o medalhão e o facho (hoje cria a coluna de 1 s): o facho espera | 0,45 s (fim do segurar da câmera lenta, `LAST_KILL_HOLD` 0,55 a 0,35 da velocidade) |
| Descer | a luz desce do topo da tela até o chão (a borda de baixo do facho corre de cima para baixo, saída suave), o pó começa | 0,35 s |
| Pousar | a poça abre de 0,6 a 1,0 do raio com um pulso de 1,3 vez a luz que volta a 1,0; o medalhão desce 1,2 m até o lugar dele junto (proposta, `RewardGem`) | 0,25 s |
| Esperar | respira entre 0,88 e 1,0 da luz num ciclo de 2,6 s; o pó cai | até pegar |
| Herói perto | a menos de **2,5 m** do eixo, o facho cai a 0,35 da força em 0,2 s e a poça a 0,6 (ele está pegando; nada sobre ele) e abre em volta dele quando está na frente dele (`hero_hole`, como a coluna) | 0,2 s |
| Pegar | a luz sobe: a borda de baixo do facho corre para cima e a poça apaga | 0,3 s |
| Loja | os fachos chegam juntos ao entrar (sem a espera), um item comprado sobe como "pegar"; a força segue o ouro (0,75 ou 0,3) em 0,25 s | |

Com a câmera lenta o desenho anda em tempo real (`Fx.real_dt`), como o HUD.

### 6.5 Regras e orçamento
- Sobre o herói: dentro da caixa de 300 x 300 px dele, o facho e a poça não passam de 200 no maior canal e a luma p50 do
  herói fica a menos de 8% da mesma captura sem o facho.
- Nunca soma: `blend_premul_alpha` (luz = o que soma, alfa = luz / teto); dois fachos que se cruzam na tela não passam do
  teto.
- Custo: 2 chamadas por facho mais 1 da MultiMesh do pó; nenhuma luz, nenhuma sombra. iGPU 720 Baixa na loja (5 fachos)
  sem perder mais de 1 qps.
- Compatibility: a mesma forma; lá a luz sai mais escura (sem o linear para sRGB), corrigir com um ganho próprio
  (`compat_gain`, como o `GroundLook.COMPAT_GAIN`) até a luma do corpo bater com a do Forward+ a 15%.

### 6.6 Aceite
1. Captura 1 s depois da sala vencida (`--bot --autopick --seed=5`, sala 1, `--shot-at` no fim da luta mais 1,2 s):
   o facho vai do topo da tela ao relicário; maior canal p99 no recorte do facho até 210; saturação p50 do corpo até 0,3;
   poça com luma p50 1,3 a 1,7 vez o chão a 3 m dela.
2. A mesma com a câmera Longe e a Perto.
3. Herói em pé no degrau do relicário: luma p50 do herói a menos de 8% da captura sem facho (ligar e desligar por uma
   opção de laboratório, proposta `--no-shafts`).
4. Loja com 50 e com 500 de ouro: fachos fortes só nos itens que dá para comprar.
5. Uma folha com as dez recompensas lado a lado (`tools/gem_lab.gd` com o facho): o matiz de cada uma na tabela 6.3 a 15
   graus.
6. Vídeo de 3 s do pouso (descer, pousar, respirar) e de 1 s do pegar.

## 7. Orçamento e desempenho
- Orçamento por quadro do `FxBudget`: lascas 40, talhos 8, explosões 6 ficam; os estalos V-05 entram nos talhos; fiapos
  `wisp` até 24 por quadro novos (proposta) numa MultiMesh de 96.
- Nenhuma luz nova em efeito (só as que existem). Nenhuma textura grande nova: formas por shader e por ruído.
- Medir antes e depois: RTX 1080 Alta e iGPU 720 Baixa em `--stress=12 --stress-ids=skeleton,runner,mage,archer` com o
  robô e Bênçãos de Chama (o pior caso de partículas), e na fase 4 de Morvath; nada de mais de 3 qps perdidos na iGPU.

## 8. Como medir (todas as capturas)
- GPU, estilizado, 1920 x 1080, semente 5. Para Morvath, **sem `--bot`** (o robô gira em volta dele e o golpe dele não
  aparece): `--start=boss --hero-hp=9999 --hero-at=0,6 --boss-only=<ataque> --shot-on=boss:<momento>`.
- Para o herói, inimigos parados por perto: `--bot --stress=5 --stress-ids=skeleton,guard,skeleton --shot-on=...`; na sala 1
  normal o primeiro golpe do robô é um Ômega com quadro de impacto preto e branco.
- Recortes e números: `tools/frame_stats.py --hue --box=...` e, para o teto, a porcentagem de pixels com maior canal acima
  de 235 e com os três acima de 235 (proposta: o technical-artist acrescenta `--peaks` ao `frame_stats.py`, que hoje não
  conta isso).
- Antes e depois no mesmo enquadramento, em `docs/gallery/vfx_pass/` (antes já em `docs/art/shots/vfx_pass_before/`).
- O combat-feel-director confere que nenhum tempo mudou (sonda 41/41, `enemy_motion_probe` com aviso a -1 a +1 quadro).

## 9. Prioridades e ordem

| Ordem | Itens | Prioridade | Por quê primeiro | Dono |
|---|---|---|---|---|
| 1 | **6 (luz sobre o que se pega)** | P0 | pedido direto do Daniel; peça nova isolada, não mexe em nada | technical-artist (`RewardShaft`, shader); gameplay-engineer: tirar a `game.column` do `_room_cleared`, chamar o facho na loja e na fonte, a força pelo ouro |
| 2 | **5.6 partículas** e o teto (regra 1 da seção 3) | P0 | as bolinhas e o branco estourado estão em todo quadro; base para tudo o resto | technical-artist |
| 3 | **V-11, V-12** (magia dos mortos em carmim e magenta, explosão do corredor) e a paleta da seção 4 (`color_of`, `FAMILY_COLOR`, Vigília, Elo, Salmo, coração e romã) | P0 | é o "mais diferença entre eles": tira o fogo do inimigo da cor da Chama e o violeta do feiticeiro | gameplay-engineer (`make_data.gd`, `combat.gd`, `boon.gd`, `rooms.gd` cores) + technical-artist (orbe, virote, explosão) |
| 4 | **V-01 a V-05** (corte de volta ao esmeralda, giro, brilho sem cruz, lâmina no lugar do néon, estalo no contato) | P0 | o golpe do herói é o efeito mais visto do jogo | technical-artist |
| 5 | **V-16** (foice e Ceifa sem o fio ciano) | P0 | o mesmo par de forma e cor entre herói e chefe | technical-artist |
| 6 | 5.3 formas das famílias, V-06, V-07, V-13, V-14, V-15, V-17 | P1 | identidade de cada família; inimigo e chefe na língua deles | technical-artist; `Skills` com o gameplay-engineer |
| 7 | V-09, V-10 (ultimates) | P1 | raras na tela, mas hoje leem como protótipo | technical-artist |
| 8 | V-08, V-18, 5.7 | P2 | acabamento | technical-artist |

Entrega em dois lotes para o Daniel testar de uma vez (regra das versões MVP): **lote 1** = ordens 1 a 5; **lote 2** = 6 a 8.
Cada lote volta para revisão do art-director (capturas da seção 8) e do combat-feel-director (tempos).

## 10. O que não muda, o que depende de outros e perguntas
- Não muda: tempos, alcances, dano, avisos (forma, tempo e cor), colisão, câmera, HUD.
- Clássico (F7): as mudanças de forma valem nos dois looks; as de cor e teto, se forem por uniform do estilizado
  (`art_style`), conferir o clássico igual ou melhor; nada pode piorar o clássico.
- Nenhum modelo novo, nenhum crédito do Meshy: tudo por shader, lasca e ruído.
- Para o ui-ux-designer: as cores de família da seção 4 chegam ao HUD (losangos das ações, medalhões, cartas) pelo
  `Boon.FAMILY_COLOR`; a Vigília deixa o verde. Conferir as telas.
- Pergunta ao Daniel (pelo Game Director): a luz da Bênção puxa para a cor do anjo da porta (proposta) ou fica marfim
  para todas as Bênçãos? E a cor da Vigília em sálvia (a do selo do Shomael) serve?

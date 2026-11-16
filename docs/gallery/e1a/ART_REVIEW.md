# E1a "Inimigos vivos": revisão de arte

- Data: 2026-11-16. Revisor: `art-director`. Cópia de trabalho não commitada (sobre o `10944b1`).
- Herói: o Guerreiro (`docs/design/warrior_spec.md`); a pergunta é se os inimigos se sustentam ao lado dele.
- Evidências usadas (todas do jogo real, nada gerado):
  - antes: `before/BEFORE.md`, `before/skeleton_walk_contact_12.png`, `before/weapons/*`, `before/stills/*`;
  - armas depois: `after/weapons/before_after_{front,side,game}.jpg`, `morvath_hook_before_after.jpg`,
    `guard_feet_before_after.jpg`, `game_hall_skeleton_archer_mage.jpg`, `game_hall_compat.jpg`, `game_morvath.jpg`;
  - poses depois: tiras do qa-performance renderizadas na GPU (24 quadros de andar, 10 de golpe sofrido, 40 de morte
    a 30 qps, mesmo roteiro do antes), montadas por mim em `after/art_review/walk_strips_after.jpg` e
    `after/art_review/skeleton_death_after.jpg`; quadro a quadro do golpe sofrido com recuo (grade amarela, do QA);
  - partida depois, gravada por mim na RTX 5060 (Forward+, 1920x1080, 30 qps, `MIRROR=.../eterra-gpu-art`,
    `tools/movie.sh ... 420 --bot --stress=9 --stress-ids=skeleton,mage,guard --seed=5`, o mesmo comando do antes):
    `after/art_review/fight_after_1x.mp4`, quadros em `after/art_review/fight_after_seq.jpg` e recorte do salão em
    `after/art_review/hall_crop_cleaver.jpg`;
  - números do assado (log do `tools/bake.gd`: passo medido e escorregamento por passo).
- Limites: não vi a 0,25x em vídeo (só quadro a quadro); Morvath andando na câmara só pelas tiras e por um quadro;
  robô, não gente. O vídeo do QA "depois" não estava pronto quando escrevi.

## Veredito por item

| # | Item | Veredito |
|---|---|---|
| 1 | Andar com 20 poses e mistura | **Aprovado** |
| 2a | Running_B no esqueleto e no corredor | **Aprovado** |
| 2b | Running_B no mago e no besteiro | **Aprovado com ressalva** (cadência lenta; E1b) |
| 2c | Walk_Formal no sacerdote ancião | **Aprovado** |
| 3 | Recuo de 0,24 m (0,15 nos pesados) | **Aprovado** |
| 4a | Repintura das armas (ferro, osso, madeira, metal velho) | **Aprovado** |
| 4b | Cutelo do esqueleto a 0,58 | **Reprovado na leitura**: corrigir antes de fechar a E1a |
| 4c | Besta a 0,5 | **Aprovado** |
| 4d | Gancho de Morvath em ouro velho | **Aprovado** |
| 5 | Pé do Escudo (`even_legs`) | **Aprovado** |
| 6 | Escorregamento do Escudo, Cavaleiro e Morvath | **Aprovado com ressalva** para o commit; corrigir na E1b |

## 1. Andar: ainda é stop motion?

Não. Nas tiras do depois, nenhum par de quadros seguidos a 30 qps repete a pose: 0 de 23 no andar (antes 10 a 15
de 23), 0 de 9 no golpe sofrido (antes 6 de 9) e 0 de 39 na morte (antes 32 de 39), para esqueleto, mago, Escudo e
Morvath (conferido pelo hash da imagem, como no antes). A mistura não amassa membros: na morte do esqueleto
(`skeleton_death_after.jpg`) a queda é contínua em uns 10 quadros, sem braço encolhendo entre poses. O esqueleto
anda de tronco ereto com a cabeça à vista; antes a cabeça ficava escondida atrás da ombreira (folha do antes,
quadros 4 a 11). Na partida (`fight_after_seq.jpg`) a multidão anima no mesmo ritmo que o herói; o engasgo sumiu.

## 2. Corrida (Running_B) e Walk_Formal: lê bem para cada papel?

Cadência real em jogo (da velocidade, do passo medido e do tamanho: `Horde.walk_rate`):

| Inimigo | velocidade | taxa do clipe | ciclo | passos por minuto | escorrega por passo, em jogo |
|---|---|---|---|---|---|
| esqueleto | 3,75 m/s | 0,85x | 1,26 s | cerca de 95 | 2,8 cm |
| corredor | 4,88 m/s | 1,16x | 0,92 s | cerca de 130 | 1,1 cm |
| mago | 3,5 m/s | 0,74x | 1,46 s | cerca de 82 | 2,9 cm |
| besteiro | 3,63 m/s | 0,80x | 1,34 s | cerca de 90 | 2,8 cm |
| sacerdote ancião (Walk_Formal) | 2,0 m/s | 0,67x | lento | cerca de 70 | 9,9 cm |

- **Esqueleto (2a)**: o esqueleto não é lento (3,75 m/s, a pressão da sala), então correr combina com o papel. A
  corrida do KayKit tem passada longa e fase de voo; a 0,85x fica um trote largo, mas lê como "vem para cima de
  você". Aprovado. Elite (4,75 m/s) roda a 1,08x, melhor ainda.
- **Corredor (2a)**: 1,16x, 130 passos por minuto, o melhor dos quatro. Aprovado.
- **Mago e besteiro (2b)**: a 0,74x e 0,80x, com a passada do Running_B (mais de um corpo de altura por passo),
  a corrida fica em câmera lenta, um trote de pouca gravidade. Na câmera do jogo é discreto (eles quase só andam para
  se reposicionar e fugir), por isso não bloqueia. No mago, com o braço do cajado preso na guarda, o braço livre
  fica esticado de lado em metade do ciclo (`walk_strips_after.jpg`, linha 2, quadros 7 a 12): de perto lembra um
  espantalho. **Pedido para a E1b** (`gameplay-engineer`, `tools/bake.gd`): um trote de passada curta para os
  dois (Jog_Fwd da UAL ou outro, passo medido pelo próprio assado), meta de **120 a 150 passos por minuto** e
  escorregamento abaixo de 5 cm por passo **em metros do jogo**; braço livre do mago até 45 graus do corpo.
- **Sacerdote ancião (2c)**: Walk_Formal a 0,67x é solene e lento, combina com o ancião que fica parado invocando.
  Aprovado. Escorrega cerca de 10 cm por passo em jogo (ver item 6), mas ele quase não anda.

## 3. Recuo de 0,24 m

Aprovado. No quadro a quadro do golpe sofrido o corpo sai em 3 quadros e volta em uns 0,25 s sem estalo. Na câmera do
jogo (54 m, campo 24, cerca de 47 px por metro a 1080 linhas) são uns 11 px nos leves e 7 px nos pesados; somado à
pose de 8 quadros, ao clarão e à inclinação do C8, o golpe agora empurra o corpo. Não subir: acima de 0,3 m o recuo,
que é só desenho, começaria a brigar com a posição real (barra de vida e aviso no chão ficam onde o corpo está).
Morvath com 0,15 m está certo para o tamanho dele.

## 4. Armas

- **4a, repintura**: aprovada. Sumiram as faixas de duas cores chapadas e os anéis lilás de plástico
  (`before_after_front.jpg`). Ferro escuro, madeira escura e bronze apagado conversam com a pintura das figuras do
  Meshy; o escudo redondo do Cavaleiro (borda de ferro gasto, tábuas, caveira) e a espada dele agora parecem do mesmo
  mundo que a armadura. A cor da magia ficou só no orbe do cajado (no salão os orbes violeta dos magos aparecem como
  dois pontos claros, `hall_crop_cleaver.jpg`): é o certo, a gema é o único lugar que deve brilhar. As armas escuras
  também não competem com a Emeth, que segue sendo o único verde aceso do quadro.
- **4b, cutelo do esqueleto**: reprovado na leitura. Na câmera do jogo o cutelo não aparece em nenhum dos esqueletos
  do salão (`hall_crop_cleaver.jpg`, `game_hall_skeleton_archer_mage.jpg`): ferro a 0,13 de valor, pendurado baixo
  junto à tanga vermelha, some contra o chão (valor perto de 0,2 a 0,3). De perto (`weapon_skeleton_game.jpg`) o que
  se vê é o arco de osso da empunhadura, não a lâmina. O tamanho não é o problema principal; o valor é.
  **Pedido** (`environment-artist`, `tools/bake.gd`, só o esqueleto, re-assar `skeleton`):
  - lâmina do cutelo (célula `C_BLADE`) num ferro gasto próprio de **valor 0,26 a 0,30** (sRGB, mesmo matiz do
    `iron`), com o fio (as arranhaduras ao longo da lâmina) em **0,45 a 0,5**; costas e espigões continuam no `iron`;
  - escala de 0,58 para **0,66** (cerca de 0,59 m de aço, 0,68 do tronco: o teto de 0,6 que eu tinha posto cai para
    este caso, porque a figura é magra e a arma é o papel dela);
  - critério: captura 1920x1080 na GPU com `--stress=6 --stress-ids=skeleton --seed=5`, a lâmina distinguível como
    forma própria (separada da mão e da tanga) em pelo menos 4 de 6 esqueletos; nenhuma faixa de duas cores.
  Não precisa de captura nova minha: o qa-performance anexa e eu confiro pela imagem.
- **4c, besta a 0,5**: aprovada. Deixou de ser a peça branca sobre a cabeça; tem tamanho de besta de mão ao lado da
  figura e lê como arma apontada (`weapon_archer_game.jpg`). A coronha sai mais âmbar do que a madeira pedida (luz e
  `vivid`), aceitável. A geometria do KayKit continua grossa: substituto definitivo é peça do Meshy, fora da E1a.
- **4d, gancho de Morvath**: aprovado. Saiu do laranja-amarelo de brinquedo para um ouro velho apagado
  (`morvath_hook_before_after.jpg`, matiz 36,7, saturação 0,43, dentro de 35 a 45 e até 0,5). Sob a luz violeta da
  câmara ele puxa um pouco para oliva; se o Daniel achar esverdeado, subir só o vermelho da tinta `gold` (0,33 para
  0,36), sem passar a saturação de 0,5. Não mexer agora.

## 5. Pé do Escudo

Aprovado. Antes as pernas cruzavam e um pé ficava acima do chão (`before/weapons/weapon_guard_side.jpg`); depois a
base é larga e os dois pés apoiam (`after/weapons/weapon_guard_side.jpg`, `guard_feet_before_after.jpg`). A sola
vermelha que aparece por baixo é da pintura do modelo do Meshy, não do assado.

## 6. Escorregamento do Escudo, Cavaleiro e Morvath

Atenção: o escorregamento que o assado imprime (e o teste `test_living_crowd.gd` compara com 5 cm) é medido no
tamanho 1 do modelo; em jogo ele se multiplica pelo `size`. Em metros do jogo:

| Inimigo | escorrega no assado | tamanho | em jogo | taxa do Walk | passos por minuto |
|---|---|---|---|---|---|
| Escudo | 13,3 cm | 1,5 | cerca de 20 cm (9 px a 1080) | 2,15x | cerca de 195 |
| Cavaleiro | 10,2 cm | 2,07 | cerca de 21 cm (10 px) | 1,07x | cerca de 95 |
| Morvath | 5,8 cm | 2,53 | cerca de 15 cm (7 px) | 1,25x | cerca de 110 |
| sacerdote ancião | 4,5 cm | 2,19 | cerca de 10 cm | 0,67x | cerca de 70 |

O Daniel nota? Do Escudo, sim, mas pelo ritmo mais que pelo pé: a figura maior das salas comuns anda a uns 195
passos por minuto, um passinho apressado que contradiz o peso dela (antes o Walk rodava a 1,41x e escorregava mais;
agora escorrega menos e apressa mais). Morvath é o segundo: a câmera fica parada nele por dois minutos e 7 px por
passo aparecem se o olho estiver nos pés. O Cavaleiro aparece uma vez por descida. Nada disso é pior do que o antes
(o antes escorregava todos e engasgava), por isso **não bloqueia o commit**.
**Pedido para a E1b** (`gameplay-engineer`, `tools/bake.gd`, `tests/test_living_crowd.gd`):
- critério do teste em metros do jogo (escorregamento vezes `EnemyDef.size`), meta de **5 cm em jogo** para quem
  corre e **8 cm** para os grandes que andam;
- Escudo: um clipe de passada pesada e longa (trote com o escudo à frente, mesma guarda), meta de **110 a 140 passos
  por minuto**;
- Morvath e Cavaleiro: um andar de passada mais longa que o Walk da UAL (o passo medido do clipe precisa chegar a
  cerca de 1,5 m/s no tamanho 1 para Morvath rodar perto de 1x), meta de 90 a 120 passos por minuto;
- se nenhum clipe das bibliotecas servir, registrar como dependência de animação própria (VX-14).

## Perguntas visuais da diretriz

- **Animação adequada?** Sim para a multidão comum: o stop motion acabou (0 poses repetidas a 30 qps), golpe sofrido
  e morte fluem e o corpo recua. Falta peso no andar do Escudo e cadência no trote de mago e besteiro (E1b).
- **Legível?** Sim pela silhueta: esqueleto ereto com a cabeça à vista, mago de capuz com orbe violeta, besteiro com
  a besta apontada, Escudo com o escudo à frente, Morvath pelo tamanho e pela coroa. A exceção é o cutelo (4b).
- **Parece comercial?** Mais perto. As armas deixaram de ser o que denuncia o protótipo; o que ainda denuncia, olhando
  de perto, é o passinho do Escudo e a geometria grossa das armas do KayKit (fim de linha: peças do Meshy, com
  autorização do Daniel). Placeholder declarado: cutelo, besta, cajados e o escudo e a espada do Cavaleiro continuam
  sendo malhas do KayKit repintadas, não arte final.

## Antes do commit

1. Cutelo do esqueleto (4b): valor da lâmina e escala 0,66, re-assar só o `skeleton`, captura do QA no critério acima.

Para a E1b: trote de mago e besteiro (2b), passada do Escudo, de Morvath e do Cavaleiro e o critério do teste em
metros do jogo (6). Aprovação final da E1a como apresentação é do Daniel, no T3.

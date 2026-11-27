> Índice: [rooms_progression.md](../rooms_progression.md)

## Ideias da referência Sworn (2026-11-19)

Pedido do PO pelo Game Director: estudar as capturas do Sworn que o Daniel juntou (pasta local
`OneDrive/Imagens/Sworn/`, 11 capturas de um vídeo e uma foto; o zip é cópia das mesmas) como referência de
**design de salas**. Só princípios: nada de arte, nome, personagem, layout exato ou identidade do Sworn. Tudo vira
Eterra (catacumbas sob a igreja de Valmor, o leão, tom de aventura); âmbar só para perigo de chão; nada do verde da
Emeth nem do violeta de Morvath num perigo; nada redondo nas Runas (D-29); Meshy zero. **Nada foi implementado.**

### 1. O que cada captura mostra (para a sala, não para a arte)

| Captura | O que se observa |
|---|---|
| 222408 | Tela de escolha de bênção com o patrono ao lado. Nada de sala; só confirma que a escolha pausa a luta. |
| 222420 | Fim de sala: a saída é um portão grande na parede de fundo, de frente para a câmera, com a recompensa flutuando na frente dele e o nome escrito. Um filete de água rasa corta o chão em diagonal sem bloquear; um pilar solto e pedestais com urna perto da porta. |
| 222430 | **Kit de armadilha** visível em repouso: lajes quadradas com moldura saliente e rachaduras (gatilho), blocos de pedra com caveiras na face e uma **seta gravada no topo** que diz para onde atiram. Poças rasas na borda. Os blocos ficam colados ao chão livre, mirando através dele. |
| 222445 | Terraço elevado com balaustrada separando dois níveis; num canto um objeto que "inicia as provas de combate" (desafio opcional dentro da sala). Grupos de potes quebráveis encostados no muro. |
| 222504 | Uma peça central (poço com mureta) **cercada por quatro lajes** em cruz: a melhor cobertura da sala tem preço. Blocos de tiro dos dois lados mirando para dentro. Muretas baixas dividem a sala em faixas; tocos de coluna na entrada. |
| 222527 | Passarela sobre água com mureta dos dois lados; blocos de tiro na mureta mirando **através** da passarela; pares de lajes no acesso dela. Atirador inimigo do outro lado. Aviso de golpe inimigo em aro vermelho no chão. |
| 222537 | Antecâmara pequena só com as duas saídas lado a lado na parede do fundo, cada uma com o símbolo da recompensa; lajes num canto. As portas ficam longe do miolo da luta. |
| 222549 | **Campo de pilares** baixos em grade (alguns quebrados, um com caveira em cima), grades de quatro painéis no chão (provável espeto ou respiro; nenhum disparo nas capturas), um arco partido. Cobertura espalhada, nenhuma grande. |
| 222603 | Objeto interativo opcional numa sala de luta ("espada na pedra") num degrau junto ao muro, ao lado de uma cascata; pilares e grades. |
| 222700 | Arena do chefe ao ar livre: **muitos aros vermelhos** de queda ao mesmo tempo (uns 12), na mesma cor dos avisos dos inimigos, mais a borda da tela vermelha da vida baixa. Ler o que é perigo da sala e o que é ataque fica difícil. |
| 222731 | Projétil em arco com **um rastro da origem até o aro** onde vai cair: o aviso diz onde e de onde. Pedestal com urna como cobertura, grades no chão. |
| pexels-4065021 | Escolha de bênção no mundo: três orbes sobre uma estátua e os patronos ao lado. Nada de sala. |

**O princípio que mais pesa**: o Sworn faz salas diferentes com um **kit pequeno de peças de perigo** (laje,
bloco que atira, grade) sempre visível em repouso e com a direção gravada nele, recombinado em plantas diferentes.
Cada sala tem uma combinação e uma peça central. O que nós temos hoje é o contrário: um perigo só (Runas), numa sala
só. A lição do 222700 é negativa: perigo de sala na cor do ataque inimigo e em quantidade confunde; nós mantemos o
âmbar só para a sala e no máximo 3 avisos de sala ao mesmo tempo.

### 2. Ideias traduzidas para Eterra

Custo: P até meio dia, M 1 a 2 dias, G 3 dias ou mais. Aceite pela régua do item 1 das Sugestões (48 sementes,
`--bot-reaction=0.25 --ultimate=cleave`) e pela métrica "joga diferente" (item 6). Toda regra de perigo das Sugestões
vale (aviso de 1,0 s ou mais, fere inimigos, `DefeatCause`, nunca a menos de 6 m da entrada nem nos 3 s do começo,
saída livre testada no molde do `test_boss_exits.gd`, queda fere e devolve). Nomes de peça e de perigo abaixo são
técnicos e provisórios; o nome para o jogador passa pelo Daniel.

#### Prioridade 1

**[Feito na Cripta B 2026-11-20, ver "Feito em 2026-11-20 (gameplay-engineer): RP-16 e RP-17"] RP-16 (novo) Seteira ligada à laje: o primeiro perigo que o jogador arma contra os inimigos.**
- Da referência: 222430, 222504, 222527 (bloco com a direção gravada que atira através do chão livre).
- Eterra: uma seteira de túmulo (bloco de cantaria baixo, encostado na parede ou na mureta, com uma **divisa reta
  gravada no topo** apontando para onde atira, a mesma linguagem das divisas das Runas e do `DoorGlyph`). Liga a uma ou
  duas lajes do RP-06. Quem pisa na laje (herói ou inimigo) arma a seteira: a divisa acende em âmbar e uma faixa de
  1 m de largura aparece no chão da boca da seteira até a parede oposta, 1,0 s; depois uma rajada de virotes de pedra
  por 0,25 s ao longo da faixa. Herói com o número do RP-03 (7), inimigos 60; recarga 5 s por seteira. O jogador atrai
  o grupo para a faixa e pisa na laje do outro lado (o "usar a seu favor" do PO).
- Onde: Cripta B (duas seteiras no Ossuário, uma de cada lado do muro divisor, mirando o corredor norte-sul); Ponte A
  (uma em cada plataforma de ponta, mirando **através** da plataforma, nunca ao longo de uma ponte: na ponte não há
  para onde sair); Santuário (sob as janelas cegas das naves laterais, somando ao preço das laterais do RP-06).
- Dado: `ArenaObstacle` com `piece` `&"bolt_slit"` (o `yaw` dá a direção; corpo e tiro barrados, topo 1,2 m). O
  perigo é o `LINE` do RP-11 com gatilho: `HazardDef.kind` `PLATES` ganha `links: Array[int]` (laje i arma a linha
  `links[i]`) e `lines` vêm do RP-11. Com RP-06 e RP-11 prontos, é só dado (a ligação é a única lógica nova, pura,
  em `PlateHazard`, com GUT).
- Aceite: nas salas com seteira, dano dela nos inimigos 25 vezes ou mais o do herói; pelo menos 1 inimigo atingido por
  sala em metade das salas (o robô precisa pisar de propósito: regra simples no `Bot`, "pisa na laje se 2 ou mais
  inimigos estão na faixa e ele não"); Cripta B passa a diferir da A em zona dominante e maior fonte de dano.
- Dono: `gameplay-engineer` (ligação e robô), `room-designer` (lugares e números), `environment-artist` (seteira,
  divisa acesa, rajada), `combat-feel-director` (aviso). Custo: M depois do RP-06 e do RP-11.

**[Feito 2026-11-20, ver "Feito em 2026-11-20 (gameplay-engineer): RP-16 e RP-17"] RP-17 (novo) Mureta baixa: o corpo dá a volta, o tiro passa por cima.**
- Da referência: 222504, 222445, 222527 (muretas e balaustradas que dividem a sala em faixas e níveis).
- Eterra: muretas de 0,9 m (a regra do tiro já existe: até 1,0 m passa por cima) dividindo a sala em faixas. Muda a
  pergunta para os atiradores: o mago atira por cima, o esqueleto tem de contornar, o herói escolhe de que lado ficar.
  Um desnível de verdade (terraço) não existe na simulação (o chão é um plano); a mureta faz o mesmo papel no jogo e o
  desenho pode ter um degrau de 0,3 m do outro lado sem mudar a colisão.
- Onde: **Jardim A** (duas muretas quebradas em arco a 6 m do tronco, deixando 3 aberturas de 3 m: a "sombra da árvore"
  vira um pátio fechado); **Cripta A** (uma mureta de 6 m ao sul do sarcófago, paralela a ele, separando a fileira sul
  da do meio). Não nas Fendas (já têm a fenda como divisor) nem nas Runas (atrapalha ler as lajes).
- Dado: só `ArenaObstacle` caixa com `blocks_move` true, `blocks_shots` false, `height` 0,9, `piece` `&"low_wall"` (o
  look desenha com `cut_wall`/`wall_part`, a conferir com o `environment-artist`). Nada de código.
- Aceite: tiros barrados nas salas tocadas **caem** (a mureta não é cobertura) e o primeiro contato sobe 1 s ou mais;
  zona do pátio do Jardim entre 30 e 60%; `test_arenas` (pontos dentro de peças, "cercado") verde; `NavGrid` e robô sem
  `stuck` em 8 sementes por vista.
- Dono: `room-designer`; `environment-artist` desenha a mureta. Custo: P.

**RP-18 (novo) Colunata: um campo de pilares baixos como variante tardia.**
- Da referência: 222549 (cobertura espalhada em grade, nenhuma grande, alguns pilares quebrados).
- Eterra: **Santuário C, "a nave das colunas caídas"**, ou Cripta C se o Daniel preferir a cripta (as duas têm a
  coluna redonda pronta, `round_column`, `column_base`, `drums`). Grade de 3 x 3 colunas de 0,7 m de raio, 4 m entre
  eixos, duas delas tocos (barram corpo, não tiro) e uma caída atravessada (caixa baixa). Nada de perigo novo: a sala
  é a cobertura que vira. É onde a coluna que tomba do RP-09 rende mais.
- Dado: só `ArenaVariant` nova com `obstacles` (pilares e tocos que já existem), `spawns` fora da grade e `areas`
  ("colunata", "beira"). Entra com a faixa do RP-07 (progresso 0,5 a 1,0).
- Aceite: tiros barrados 35% ou mais (a Cripta A, a mais coberta, tem 28%); primeiro contato 1,5 s acima da Santuário A;
  zona "colunata" 40 a 70%; robô sem `stuck` (a grade de 4 m dá corredores de 2,6 m, acima da folga de 0,55 do
  `NavGrid`); `fit_probe` sem fantasma.
- Dono: `room-designer`; `environment-artist` (variante da nave). Custo: P no dado, M na arte.

**RP-19 (novo) Saídas na parede de fundo, longe do miolo da luta.**
- Da referência: 222420 e 222537 (portões grandes de frente para a câmera, recompensa na frente de cada um, e as
  saídas juntas num fim de sala, fora da luta).
- Eterra: auditoria das `ArenaExit` das 12 vistas de luta. Regra proposta: toda saída numa parede que a câmera vê de
  frente (norte ou leste na nossa câmera de 35 graus), a pelo menos 8 m do `hero_spawn` e fora das zonas de
  nascimento; quando a sala tem duas ou três saídas, elas ficam do mesmo lado, a 5 m ou mais uma da outra (o jogador
  lê as placas juntas, como hoje na Ponte). Quem descumpre hoje é o que a auditoria vai dizer; não muda nenhuma peça
  de perigo.
- Dado: `exits` no `_stage`; uma asserção nova em `test_arenas.gd` (distância ao `hero_spawn`, às `spawns` e entre
  saídas).
- Aceite: teste verde nas 12 vistas; captura na GPU de cada sala mudada com as placas inteiras na tela a 720.
- Dono: `room-designer`; `ui-ux-designer` confere as placas. Custo: P.

#### Prioridade 2

**RP-20 (novo) Pedras que caem da abóbada rasgada (Santuário B).**
- Da referência: 222700 e 222731 (queda avisada por aro no chão; o rastro da origem ao aro diz de onde vem). Lição
  inversa do 222700: poucas por vez e numa cor que não é a dos inimigos.
- Eterra: a abóbada rasgada do Santuário B (Lote B, `VAULT_*`) solta pedras sobre a nave: no máximo 2 por vez, a cada 4
  s, só na metade da nave sob o rasgo; aviso de 1,2 s com a sombra quadrada da pedra crescendo no chão em âmbar e poeira
  caindo do teto no mesmo ponto (o "de onde vem" do rastro, sem linha nova); golpe de 0,25 s em 2 x 2 m, 7 no herói e
  60 nos inimigos; a pedra fica 3 s como entulho baixo e se desfaz. Nunca a menos de 6 m da entrada nem sobre o
  `boss_spawn` nos 3 s em que o guardião surge. Dá ao buraco da B o que falta (2.4.7: a B joga igual à A).
- Dado: `HazardDef.kind` `DROPS` com `zones: Array[Rect2]`, `size`, `count`, `every`; o resto (`warn`, `fire`,
  danos, `start_delay`, `quiet`) já existe. Comportamento novo uma vez (lógica pura `DropHazard`, GUT); depois, pedra
  que cai em qualquer sala com teto rasgado é dado (Cripta tardia, Fendas B).
- Aceite: Santuário B com nave abaixo de 55% (A 68%); dano das pedras no herói 0,5 a 2 por sala, inimigos 25 vezes isso;
  nunca 3 avisos de sala ao mesmo tempo (GUT); teste de saída verde.
- Dono: `gameplay-engineer`, `room-designer`, `environment-artist` (sombra, poeira, entulho). Custo: M.

**RP-21 (novo) A melhor cobertura tem preço: lajes em volta da peça central.**
- Da referência: 222504 (poço cercado por quatro lajes).
- Eterra: regra de colocação do RP-06, não perigo novo. A peça que mais barra tiro em cada sala ganha lajes nas pontas
  curtas, nunca nos corredores de 4 m (que seguem livres): o sarcófago do meio da Cripta A (lajes nas duas cabeceiras),
  o tronco do Jardim (uma laje no lado norte, a sombra contra os atiradores do sul) e o patamar da Ponte B (uma laje no
  meio do patamar: o abrigo do RP-11 deixa de ser de graça). Ficar coberto continua possível, mas não parado.
- Dado: só retângulos em `plates` depois do RP-06.
- Aceite: tiros barrados nas salas tocadas caem no máximo 5 pontos (a cobertura continua valendo); dano das lajes 0,5 a
  1,5 por sala; a zona da cobertura cai 10 pontos ou mais.
- Dono: `room-designer`. Custo: P depois do RP-06.

**RP-22 (novo) Filete de água de infiltração: o chão que muda o passo.**
- Da referência: 222420, 222430 (água rasa cortando o chão sem bloquear).
- Eterra: água que escorre das cascatas do Jardim (Lote C já pôs cascatas e o lago da B fora do chão) por um canal raso
  de 2 m de largura atravessando o chão de lado a lado. Dentro dele todo mundo anda a 75% (herói e inimigos; a esquiva
  e a investida não perdem nada). Sem dano, sem aviso (é chão, sempre visível; a regra do aviso é para o que fere).
  Separa a sala em duas margens sem cortar o caminho: os esqueletos que atravessam ficam lentos na frente do herói.
  Também nas Fendas, no fundo do vão sob a ponte caída da B, se a sala pedir.
- Dado: `RoomLayout.slow_zones: Array[Rect2]` e `slow_scale` (também na `ArenaVariant`); comportamento novo pequeno
  (`Horde.speed_scale` e `Player` por posição, `Arena.slow_at`), lógica pura testada.
- Aceite: Jardim com zona "margem leste" e "margem oeste" e nenhuma acima de 70%; dano por sala do Jardim sobe para 1
  a 2 nas salas 4 a 6 (os corredores lentos na frente dele); robô sem `stuck`.
- Dono: `gameplay-engineer` (o lento), `room-designer`, `environment-artist` (o filete; a água escura do Lote C,
  `dark_water.gdshader`, já existe). Custo: M.

**RP-23 (novo) Grade de respiro: a laje de proximidade em outra pele.**
- Da referência: 222549, 222603, 222731 (grades no chão, sempre visíveis).
- Eterra: grade de ferro sobre um respiro do ossário (Cripta e Santuário). Quem fica a menos de 1 m dela (herói ou
  inimigo) arma; 1,0 s de aviso (a grade acende em âmbar pelas frestas e sobe pó de osso); depois poeira quente por 1,5
  s, 1 a cada 0,25 s, como o vapor do Hades (`SteamTrap`: alvo herói e inimigos, recarga 6 s). Difere da laje por ferir
  por tempo, não de uma vez: ensina a sair, não a esquivar.
- Dado: o `PlateHazard` do RP-06 com `ticks` e `tick_every` (zero no RP-06), mais a peça `&"vent_grate"` (só desenho,
  não barra nada). Nada novo além dos dois números se o RP-06 já nascer com eles; recomendo que nasça.
- Aceite: dano médio por disparo no herói abaixo de 3 (ele sai antes do fim); inimigos 20 vezes isso.
- Dono: `room-designer`, `gameplay-engineer` (dois campos), `environment-artist` (grade). Custo: P depois do RP-06.

#### Prioridade 3 (depois da sessão do Daniel)

**RP-24 (novo) Urnas quebráveis em grupos (ouro) e a urna de óleo (RP-12) lidas como coisas diferentes.**
- Da referência: 222430, 222445, 222537 (grupos de potes ao pé dos muros; recompensa por varrer os cantos).
- Eterra: urnas de cerâmica comum em grupos de 3 a 5 ao pé das paredes, que quebram num golpe e soltam um pouco de ouro
  (o Hades II também tem). As de óleo do RP-12 ficam isoladas, em bronze escurecido e com o pavio à mostra: nunca no
  mesmo grupo nem na mesma cor. Muda pouco a luta, muda muito a identidade de cada canto.
- Dado: `ArenaObstacle.breakable` e `drop_gold`; comportamento novo uma vez (peça que some, `NavGrid` refeito encolhendo).
  Ouro é economia: os números são do `gameplay-engineer` e não podem mexer no ouro da descida mais que 5%.
- Dono: `gameplay-engineer`, `environment-artist`. Custo: M.

**RP-25 (novo) Desafio opcional dentro da sala de luta.**
- Da referência: 222445 e 222603 (um objeto na sala que começa uma prova ou dá algo, à escolha do jogador).
- Eterra: depois da luta, às vezes um relicário fechado num canto; tocá-lo chama uma onda curta a mais (com uma elite)
  e, vencida, dá uma recompensa a mais. Sobrepõe a Provação (que já é "risco por Bênção"): só vale se for diferente
  dela (sem maldição, risco só da onda). Precisa de decisão do Daniel antes de qualquer dado; nome e o que é o
  relicário são cânone.
- Dono: Game Director decide; `gameplay-engineer`. Custo: M.

### 3. O que mais deixaria as salas diferentes umas das outras

O Sworn não faz cada sala com um sistema; faz cada sala com **uma combinação** de poucas peças. Com RP-06, RP-11 e
RP-16 a RP-23 prontos, nós temos o kit (laje, seteira, grade, mureta, pedra que cai, filete de água, coluna que tomba)
e cada arena ganha uma assinatura própria, sem repetir a peça central:

| Arena | Peça central (o que a sala pergunta) | Kit dela | Nunca nela |
|---|---|---|---|
| Cripta A | o sarcófago coberto, mas com lajes nas cabeceiras (RP-21) | lajes nos cantos (RP-06), mureta sul (RP-17), grade (RP-23) | seteira |
| Cripta B | o muro divisor varrido pelas seteiras (RP-16) | lajes no pé do muro, grade | mureta |
| Fendas A / B | a ponte; a fenda que respira empurra (RP-08) | tocos (RP-05); na B pedra que cai sob a ponte caída (RP-20) | lajes (a beira já pede atenção) |
| Jardim A / B | o pátio fechado da árvore (RP-17) e a raiz que golpeia (RP-10) | filete de água (RP-22), laje ao norte do tronco | seteira |
| Santuário A | nave ou laterais; laterais com lajes e seteiras (RP-06, RP-16) | coluna que tomba (RP-09) | pedra que cai |
| Santuário B | o rasgo da abóbada que solta pedras (RP-20) | grade, coluna que tomba | seteira |
| Santuário C (nova) | a colunata (RP-18) | coluna que tomba (RP-09) | perigo de chão |
| Ponte A / B | atravessar sob fogo (RP-04); a corrente que varre (RP-11) | seteira nas plataformas da A (RP-16), laje no patamar da B (RP-21) | grade, água |
| Runas A / B | o chão inteiro é o perigo | raio entre pilares na A tardia (RP-11), cristal da B (RP-14) | qualquer outra peça (leitura das lajes) |

Medida: com a tabela acima, nas salas 2 a 6, cada par de vistas tem de diferir em pelo menos duas das cinco medidas do
item 6 das Sugestões (hoje Cripta, Fendas e Jardim diferem só nos tiros barrados).

### 4. Ordem recomendada (junto das Sugestões)

1. RP-01, RP-02, RP-03 (já recomendados) e **RP-17, RP-19** (só dado, P): mureta e saídas.
2. RP-06 nascendo com `ticks` (para o RP-23) e `links` (para o RP-16); logo depois **RP-21** e **RP-23** (só dado).
3. RP-11 e **RP-16** (a seteira é o LINE com gatilho).
4. **RP-18** (variante, só dado) com o RP-07 (faixas) e o RP-09 (coluna que tomba).
5. **RP-20** e **RP-22** (um comportamento novo cada).
6. RP-24 e RP-25 depois do Daniel.

### 5. Riscos

- Kit demais numa sala só vira o 222700: no máximo **um** perigo que fere por sala de luta (a mureta, a água e a coluna
  que tomba não contam) e no máximo 3 avisos de sala ao mesmo tempo.
- A seteira (RP-16) e a laje no patamar (RP-21) na Ponte podem prender o herói entre uma faixa e o abismo: teste de
  saída obrigatório com as pontes, e nunca faixa ao longo de uma ponte.
- O robô não usa o chão a favor (2.4.5): RP-16 e RP-21 pedem uma regra nova no `Bot`, senão o aceite vira a sessão do
  Daniel.
- A lentidão da água (RP-22) no herói pode irritar: medir com gente; se irritar, só os inimigos ficam lentos.

### 6. O que precisa de arte (`environment-artist` com a spec do `art-director`)

Seteira com a divisa reta gravada no topo e a rajada (RP-16); mureta baixa quebrada nos looks da Cripta e do Jardim
(RP-17); variante da nave com a colunata (RP-18); sombra quadrada, poeira do teto e entulho da pedra que cai (RP-20);
filete de água no chão do Jardim (RP-22, da família do `dark_water`); grade de ferro com âmbar nas frestas e pó de osso
(RP-23); urnas de cerâmica comum em grupo, distintas da urna de óleo (RP-24). Placeholder enquanto isso: o estilo
`GroundLook.Style.HAZARD` para todo aviso e as peças que já existem (`block`, `cut_wall`, `column_base`, `Masonry.urn`).

---

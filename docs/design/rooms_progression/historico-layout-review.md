> Índice: [rooms_progression.md](../rooms_progression.md)

## Revisão de layout 2026-11-19 (build d2ff05d)

Pedido do Game Director depois do teste do Daniel do build `d2ff05d` ("ainda precisa de muitas melhorias"): olhar as
salas da descida e o hub como level designer, com a câmera Longe (54 m) e a Perto (37 m). **Nada implementado**; nenhum
dado, código ou teste do repositório mudou.

### 1. Como medi

- Cópia isolada do `d2ff05d` em `/home/dani/tools/rd_layout` (fora do repositório). Nela, só para medir, uma amostra a
  cada 0,25 s da posição do herói e de cada inimigo vivo por sala (`--heat`, linha `HEAT`; não vai para o jogo).
- `tools/smoke.sh 900 --seed=N --bot-reaction=0.25 --ultimate=cleave`, sementes 1 a 24, duas vezes: Longe (padrão) e
  `--cam=near`. 48 descidas, 0 `stuck`, 0 `bot.stuck`, 20 de 24 vitórias nas duas, Morvath aos 228 s (Longe) e 221 s
  (Perto). Saídas e scripts: `/home/dani/tools/rd_layout_runs/` (`an.py` por sala, `heat.py` distâncias e fora da
  tela, `thirds.py` terços da sala).
- Enquadramento calculado pela fórmula do jogo (`CamFrame.screen_of`, 16:9, giro 35, inclinação 30, campo 24) sobre o
  chão de cada `RoomLayout` numa grade de 0,5 m: `tools/rd/frame_cover.gd` na cópia.
- Capturas na GPU (Forward+, 1672 x 941, semente 5, 9 s, robô), só no scratchpad:
  `/tmp/claude-1000/-home-dani-games-eterra-a-selagem/78898d24-f62f-43d1-9d7c-e7eaa36af8bf/scratchpad/layout/`
  (`crypt_near`, `bridge_far`, `bridge_near`, `sanctuary_far`, `sanctuary_near`, `garden_far`, `hub_far`, `hub_near`).
- Ressalva de sempre: é o robô. Ele não procura cobertura nem ilha segura; o que for "lugar não usado" pode ser só ele.
  Onde a leitura depende disso, digo.

### 2. O que as medidas mostram

**2.1 Quanto da tela cada sala ocupa** (câmera no ponto de repouso da sala; "tela" = largura x altura do chão projetado
em telas; "cheia" = parte da tela que é chão andável)

| Sala | Chão | Longe: tamanho na tela | Longe: chão visto / tela cheia | Perto: tamanho na tela | Perto: chão visto / tela cheia |
|---|---|---|---|---|---|
| Cripta A e B | 520 m² | 0,72 x 0,68 | 100% / 26% | 1,05 x 1,03 | 98% / 55% |
| Runas A e B | 726 | 0,85 x 0,76 | 100% / 39% | 1,25 x 1,18 | 87% / 72% |
| Jardim A e B | 941 | 0,98 x 0,84 | 100% / 52% | 1,45 x 1,33 | 77% / 81% |
| Salão | 929 | 1,03 x 1,02 | 97% / 55% | 1,51 x 1,73 | 75% / 81% |
| Fendas A / B | 1076 / 1038 | 1,16 x 1,02 | 91% / 56% | 1,71 x 1,70 | 61% / 70% |
| Santuário A / B | 1225 / 1170 | 1,17 x 1,23 | 90% / 62% | 1,77 x 2,24 | 65% / 84% |
| Ponte A / B | 814 / 742 | 1,37 x 1,11 | 78% / 32% e 28% | 2,19 x 1,94 | 54% / 42% e 30% |
| Provação / Altar | 233 / 268 | 0,47 x 0,42 / 0,56 x 0,49 | 100% / 12% e 14% | 0,69 x 0,62 / 0,81 x 0,74 | 100% / 26% e 31% |
| Câmara do Selo | 490 | 0,61 x 0,55 | 100% / 27% | 0,92 x 0,84 | 100% / 60% |
| Hub | 1601 | 1,48 x 0,80 | 81% / 78% | 2,39 x 1,30 | 49% / 86% |

Leitura: **com a Longe, nenhuma sala de luta é maior que a tela**; Cripta, Runas e Jardim cabem inteiras com folga e a
Cripta é um quarto da tela, o resto parede e escuro. As salas do Érebo do Hades II são maiores que a tela (a Perto é o
ZoomFraction 0,85 delas). **Com a Perto as salas viram o que o desenho pediu**: Cripta do tamanho da tela, Jardim, Salão e
Runas 1,2 a 1,5 telas, Fendas e Santuário 1,7 a 2,2, a Ponte comprida. As câmaras sem luta (Provação, Altar, Selo) são
pequenas nas duas, o que serve a elas (escolha, não luta), mas com a Longe Provação e Altar são uma ilha de 12 a 14% da tela.

**2.2 A câmera Perto muda o jogo, não só a vista.** O atirador só prepara dentro de 5 a 95% da tela da câmera em uso
(`Horde._can_fire`). Com a Perto, nas salas grandes, um terço do tempo deles fica fora dessa faixa:

| Sala | Atirador fora de 5-95% (Longe / Perto) | Tiros por sala (Longe / Perto) | Dano por sala (Longe / Perto) |
|---|---|---|---|
| Jardim A / B | 10 a 11% / 34 a 37% | 9,3 / 5,2 e 11,8 / 12,0 | 1,40 / 0,27 e 1,57 / 1,00 |
| Fendas A / B | 15 e 9% / 31 e 23% | 5,4 / 3,6 e 8,8 / 5,2 | 1,17 / 0,35 e 1,62 / 0,69 |
| Santuário A / B (luta comum) | 17 e 19% / 39 e 37% | 6,4 / 3,9 e 8,9 / 7,9 | 4,39 / 5,83 e 7,10 / 6,10 |
| Ponte A / B | 18 e 17% / 32% | 6,9 / 3,8 e 7,1 / 5,7 | 2,36 / 1,45 e 1,33 / 0,53 |
| Cripta A / B | 2 e 0% / 20 e 11% | 2,6 / 2,1 e 3,5 / 3,0 | 0,62 / 0,62 e 0,64 / 0,64 |

(Fora da tela medido com a câmera no herói, sem a margem da sala: na Longe é o pior caso, nas salas de quadro fixo é
menos.) Na descida inteira o dano por sala de luta cai de 2,48 (Longe) para 1,90 (Perto), 23% a menos, e a vida ao chegar
em Morvath sobe de 52,7 para 56,1. **A opção de câmera é hoje uma opção de dificuldade escondida**, e quanto maior a sala,
mais fácil com a Perto: o papel do atirador some justo nas salas feitas para ele (Fendas, Jardim, Ponte).

**2.3 Onde a luta acontece** (% do tempo do herói em cada terço da sala, oeste/meio/leste e norte/meio/sul; inimigos em
oeste/meio/leste; 48 descidas)

| Sala | Herói O / M / L | Herói N / M / S | Inimigos O / M / L | Zona dominante (RP-01) |
|---|---|---|---|---|
| Cripta A | 28 / 37 / 35 | 32 / 37 / 31 | 15 / 27 / 58 | middle 34, north 34, south 31 |
| Cripta B | 16 / 46 / 38 | 16 / 44 / 40 | 11 / 28 / 61 | **south_open 79 a 82** |
| Fendas A | 18 / 56 / 26 | 14 / 40 / 47 | 8 / 45 / 47 | east 49 a 57; **bridge_n 1 a 2** |
| Fendas B | 15 / 42 / 42 | 8 / 40 / 53 | 6 / 41 / 53 | east 60 a 65 |
| Jardim A | 25 / 54 / 21 | 13 / 34 / 53 | 12 / 56 / 32 | rest e east_field; **tree_shade 3 a 5** |
| Jardim B | 19 / 55 / 26 | 23 / 29 / 48 | 5 / 54 / 41 | **tree_shade 4 a 7** |
| Santuário A (comum) | 46 / 40 / **14** | 34 / 59 / **8** | 66 / 33 / **1** | nave 71 a 73 |
| Santuário B (comum) | 34 / 46 / 21 | 46 / 48 / **6** | 48 / 47 / **5** | nave 67 a 72 |
| Santuário com guardião | 25 a 56 / 33 a 58 / 11 a 17 | 3 a 12 / 74 a 76 / 14 a 22 | 54 a 83 / 16 a 44 / 0 a 2 | |
| Ponte A | 16 / 54 / 31 | | 4 / 23 / 73 | middle 40 a 54, east 12 a 27 |
| Ponte B | 16 / 35 / 49 | | 6 / 16 / 78 | east 41 a 43, bridge 25 a 28 |
| Runas A | 26 / 47 / 27 | 27 / 42 / 31 | 11 / 54 / 35 | equilibrada |
| Runas B | 18 / 52 / 30 | | 10 / 63 / 27 | middle 56 a 63, quiet 9 a 14 |

**2.4 Outros números de forma**

- Distância ao inimigo mais perto: mediana 5,4 a 6,2 m em **toda** sala (5 m com o guardião). A sala não muda a
  distância da luta; muda só por onde se anda até ela.
- Inimigos a mais de 12 m do herói: Cripta B 21%, Cripta A e Runas B 27%, Jardim 50 a 51%, Fendas 42 a 48%, Santuário 42 a
  43%, Ponte 41 a 43%. Nas salas grandes metade da sala de pé está longe: é a fatia que a Perto apaga dos atiradores.
- Primeiro contato (mediana): Cripta 3,2 a 3,7 s, Runas 2,6 a 3,5, Jardim 3,3 a 3,5, Fendas 4,0, Santuário 5,0, Ponte
  5,3 a 6,6 s.
- Amontoado (pares de inimigos a menos de 1,5 m, por amostra): Ponte 0,85 a 0,94, o dobro das outras (Cripta 0,38 a 0,46,
  Jardim 0,29 a 0,40, Salão 0,14). Na captura `bridge_far` o grupo inteiro empilha na cabeceira da ponte 2, de 5 m. Nas
  outras salas não há aperto: média de 3 a 4,5 de pé, 0,24 a 0,48 a menos de 4 m do herói.
- O que barra tiro (`blocked_by`, 24 descidas Longe): no Jardim o **tronco** barrou 1 tiro em 15 salas A e 3 em 14 B (as
  sarcófagos 8 e 6); no Santuário as colunas 31 e 39; nas Runas A os pilares 29, na B 1; na Cripta os sarcófagos.
- Runas: por sala de Runas, 5,2 a 5,9 disparos, 2,3 a 2,7 abates na A e 1,6 a 1,8 na B, 105 a 242 de dano nos inimigos;
  no herói 1,27 (Longe) e 0,32 (Perto) por sala, a mesma faixa ruidosa do RP-03.

**2.5 Hub (`HubPlan`, 50 x 33 m)**

| De / para | Portal | Vendedor | Árvore | Forjador | Livro |
|---|---|---|---|---|---|
| Chegada | 29,8 m, 4,4 s | 29,3, 4,3 | 31,7, 4,7 | 18,9, 2,8 | 24,4, 3,6 |
| Portal | | 21,3, 3,2 | 19,7, 2,9 | 28,9, 4,3 | 28,9, 4,3 |
| Vendedor | | | 39,0, 5,8 | 15,0, 2,2 | **42,9, 6,4** |
| Árvore | | | | 41,1, 6,1 | 14,6, 2,2 |
| Forjador | | | | | 39,6, 5,9 |

(Linha reta, andando a 6,75 m/s; correndo 11,1 m/s é 60% disso.) A spec do hub (`hub_spec_art.md` 2.5) pedia nenhuma
caminhada acima de 3 s; com o chão dobrado, 6 dos 10 pares passam disso. O circuito de toda volta (chegada, Árvore ou
Livro, Portal) é 51 a 54 m, 7,6 a 8 s andando. As cinco estações estão coladas nas paredes (u entre 18,6 e 22,8 de 25);
entre elas e a fonte (raio 2,3) fica uma praça de uns 30 x 30 m com dois bancos e quatro urnas (`hub_far`: o quadro é chão
liso com a fonte no meio). Com a Longe o hub inteiro cabe quase numa tela (81% do chão visto de onde a câmera repousa):
não há o que descobrir andando. O Vendedor e o Forjador ainda são "A definir": metade oeste do hub (cerca de 800 m²) hoje
não tem uso.

### 3. Problemas e propostas

Custo: P até meio dia, M 1 a 2 dias. Aceite sempre com a régua do item 1 (24 sementes por câmera no mínimo, 0 `stuck`,
`test_arenas.gd`, `fit_probe` sem piorar) e vitórias dentro de 2 das de hoje (20 de 24).

#### P0

**LR-01 Decidir a câmera padrão e dimensionar as salas para ela.**
- Evidência: 2.1. Com a Longe toda sala de luta cabe numa tela (Cripta em 26% dela, Runas 39%, Ponte 28 a 32%); a
  sensação de "maquete" e de sala pequena vem daí, não do desenho. Com a Perto os tamanhos ficam no padrão do Hades
  (1 a 2,2 telas) sem mudar nenhuma planta.
- Proposta: **Perto como padrão** (decisão do Daniel pelo Game Director; a Longe fica na opção). Com a Perto, nenhuma sala
  de luta precisa crescer; só a Cripta fica no limite (1,05 tela) e pode ganhar 2 a 3 m se o teste pedir. Se a Longe
  continuar padrão, o contrário: Cripta e Runas precisam crescer cerca de 40% na largura (Cripta 24 para 34 m, Runas 30
  para 40) e as outras 20 a 30%, o que mexe em todo look e em todo `HazardDef`: caro (G) e eu não recomendo.
- Junto: Provação e Altar ficam como estão (sala de escolha); com a Longe valeria só aproximar a câmera nelas
  (`cam_target` com distância própria, gameplay-engineer).
- Dono: Game Director decide; `gameplay-engineer` (padrão do save), `ui-ux-designer` (opção). Custo: P.
- **Feito (gameplay-engineer, 2026-11-19): Perto como padrão.** `SaveData` versão 7, padrão `"near"`; save de antes no
  padrão antigo `"far"` passa a `"near"` uma vez, a menos que o jogador tenha escolhido (`camera_chosen`, marcado por
  `Save.set_option("camera", ...)`; saves da versão 6 não tinham a marca, então quem escolheu Longe no dia de hoje volta
  para Perto uma vez). No hub, com a Perto, nenhuma estação aparece nomeada da chegada (`test_ui_review` fixa a Longe
  nesse caso): é do LR-11.

**LR-02 A Perto não pode calar os atiradores.**
- Evidência: 2.2. A faixa de 5 a 95% da tela da câmera em uso tira um terço do tempo de tiro nas salas grandes; dano por
  sala 23% menor na Perto, e o papel do atirador some nas salas feitas para ele. Precisa vir junto do LR-01 (com a Perto
  padrão, o jogo inteiro fica mais fácil e o `balance-designer` mede a coisa errada).
- Proposta: a regra de justiça lê sempre o quadro da Longe centrado onde a câmera em uso olha (o atirador fora da tela
  da Perto mas dentro da da Longe prepara, e o aviso dele precisa então de uma divisa na borda da tela, como a de elite e
  chefe, `ui-ux-designer`). Alternativa só de sala: nas salas grandes, atiradores nascem e ficam a até 12 m do meio da
  luta (`keep_away` por sala); pior, porque muda o comportamento do inimigo por sala.
- Aceite: tiros por sala e dano por sala na Perto dentro de 10% da Longe nas 12 vistas; `hurt_ctx.offscreen` sem subir.
- Dono: `gameplay-engineer` (`Horde._can_fire`), `ui-ux-designer` (divisa). Custo: P a M.
- **Feito (gameplay-engineer, 2026-11-19, junto com o LR-01).** A regra lê o quadro que a câmera Longe teria (54 m, posta
  pelas regras dela, sem a folga da Perto: `Game._screen_of(..., as_far)`, `CamRig.look_at(..., as_far)`), não o quadro da
  Longe centrado na Perto: assim a câmera não muda nada da simulação. `RESULT` de `--cam=far` igual ao de antes do LR-02
  (semente 5) e, nas 24 sementes da régua (`--bot-reaction=0.25 --ultimate=cleave`), `--cam=near` e `--cam=far` dão o
  mesmo `RESULT` nas 24 (fora fps e tempo de passo). Tiros e dano por sala na Perto (antes / depois, depois = Longe):
  Jardim A 5,2 / 8,4 tiros e 0,27 / 1,35 de dano, Jardim B 12,0 / 11,7 e 1,00 / 2,85, Ponte A 3,8 / 5,8 e 1,45 / 1,33,
  Ponte B 5,7 / 9,1 e 0,53 / 0,77 (as colunas "depois" são de hoje, com a Laje Rachada e a Fatia 1; compare com a Longe
  de hoje, igual). 0 `stuck`, 0 `bot.stuck`. A tela em uso fica para o registro (`Horde.seen`, `screen_flag`) e para a
  divisa: `Horde.off_screen_windups()` (atiradores e sacerdote ancião preparando fora da tela em uso).

#### P1

**LR-03 Santuário: um terço da sala é corredor.**
- Evidência: 2.3. Na luta comum o herói fica 14% (A) e 21% (B) no terço leste e os inimigos 1 a 5%; o sul (a nave lateral
  sul) tem 6 a 8% do herói. O herói entra em (19,5; 2) e anda 5 s até a luta, que é a oeste (nascimentos em x -20 a -2).
  A pergunta da sala (nave aberta ou naves laterais) só existe na metade oeste. `sanctuary_far`: a luta no meio da nave,
  a metade de baixo do quadro vazia.
- Proposta (só dado): na luta comum, a primeira onda nasce também na nave lateral sul e no meio leste
  (`_rect(4, 12, 8, 12)`, `_rect(-2, 6, -12, -8.5)`), a segunda continua fechando por trás (`late_spawns` de hoje); o
  guardião não muda (ele nasce no `boss_spawn`). Assim a luta abre nas duas naves e o lado leste deixa de ser só caminho.
- Aceite: terço leste 25% ou mais do herói e 15% ou mais dos inimigos; nave entre 50 e 65%; primeiro contato abaixo de
  4 s; dano por sala dentro de 20%.
- Dono: `room-designer`. Custo: P.

**LR-04 Jardim: a árvore está fora da luta.**
- Evidência: `tree_shade` 3 a 7% do tempo, o tronco barrou 4 tiros em 29 salas. O tronco fica no canto noroeste (-8; -5);
  o herói entra no sudoeste e a luta vai para o meio e o sul (meio 54 a 55%, sul 48 a 53%). Pode ser em parte o robô (não
  busca cobertura), mas nem os atiradores ficam do outro lado dela.
- Proposta (só dado): os atiradores da primeira onda nascem ao norte do tronco (trocar `_rect(-6, 0, -13.2, -10.5)` por
  `_rect(-12, -5, -13.5, -10.5)`) e a do leste continua: entre a entrada e o grupo do norte fica o tronco, e quem cruza o
  campo leste fica exposto aos dois. Mexer no tronco (mudá-lo para o meio) seria M a G de arte; só se isso não bastar.
- Aceite: `tree_shade` 15% ou mais; tiros barrados pelo tronco 1 ou mais por sala; nenhuma zona acima de 60%.
- Dono: `room-designer`. Custo: P.

**LR-05 Fendas A e B jogam igual; a ponte norte não é usada.**
- Evidência: `bridge_n` 1 a 2% na A; A e B com o leste em 57 e 60% e o mesmo dano. O herói entra no sudoeste (-18; 6,5),
  ao lado da ponte sul e da volta sul: a ponte norte (a diferença da A) fica longe de tudo. A RP-05 deu cobertura, não
  rota.
- Proposta: entrada da A no noroeste, (-18; -9) (a da B fica): na A a ponte mais perto é a do norte e a pergunta "ponte
  norte ou volta sul" aparece; na B, sem ela, a mesma entrada obriga a descer até a ponte sul, outra sala. Pede o
  `environment-artist` (a abertura de entrada é desenhada pelo look, não pelo `hero_spawn`) e a regra de nada perto da
  entrada vale para as zonas de nascimento (o `late_spawns` da B em (-19,5..-15,5; -12..-7) sai de perto).
- Aceite: `bridge_n` 15% ou mais na A; A e B diferem em zona dominante e em primeiro contato (métrica "joga diferente",
  Sugestões 6).
- Dono: `room-designer` (dado), `environment-artist` (entrada). Custo: P a M.

**LR-06 Cripta B: o muro divisor não divide.**
- Evidência: `south_open` 79 a 82% (o aceite do RP-01 era até 75%); oeste do muro 2 a 8%. O muro tem 7 m vindo do norte
  e a luta acontece toda abaixo da ponta dele.
- Proposta (só dado): o muro desce até z 1,5 (de 7 para 12 m, caixa de 0,8 x 12 com centro em z -4,5), deixando 9 m de
  passagem ao sul; a primeira onda nasce a leste dele (já é) e um atirador a oeste (`_rect(-10, -7.5, -10, -8)` já
  existe: mantê-lo na B). A pergunta "de que lado do muro" vira real.
- Aceite: `south_open` abaixo de 60%; `west_of_wall` 15% ou mais; `test_arenas` (cercado) verde, NavGrid sem ilha.
- Dono: `room-designer`; `environment-artist` estende o ossuário (peça que existe). Custo: P.

**LR-07 Hub: caminhadas longas e praça vazia.**
- Evidência: 2.5. Pares a 5,8 a 6,4 s; circuito de toda volta 8 s; estações nas paredes, praça de 30 x 30 m vazia; metade
  oeste sem uso enquanto Vendedor e Forjador são "A definir".
- Proposta (só `HubPlan`, o chão de 50 x 33 que o PO pediu fica): as duas estações de toda volta, Árvore e Livro, vêm para
  perto do eixo chegada-portal, a 10 a 12 m dele, (13; 7) e (12; -5), e Vendedor e Forjador para (-13; 7) e (-12; -5); o
  resto do chão fica de cenário e passeio (ruínas, canteiros, a cascata). Distâncias propostas: chegada-Livro cerca de 18
  m (2,7 s), Livro-Árvore 12 m, Árvore-Portal 15 m (2,2 s); o maior par cerca de 27 m (4 s). A praça entre elas ganha
  as peças que hoje estão nas bordas (bancos, urnas) como divisores baixos. Com a Perto, mais de metade do hub fica fora
  da tela e o andar volta a descobrir.
- Aceite: nenhum par acima de 4 s; circuito de toda volta até 5 s; `test_hub.gd` e `test_camera_near.gd` verdes; o
  `HubLook` redesenhado em volta (environment-artist, art-director).
- Dono: `room-designer` (plano), `environment-artist` (`HubLook`), `ui-ux-designer` (placa). Custo: M.
- Nota: a frente HUB-D, em curso na árvore de trabalho (não no `d2ff05d`), já move as urnas, põe ciprestes em canteiros
  na praça e leva a forja para o canto sudoeste, sem mudar os pontos de uso (`HubPlan.USE`); ela trata a praça vazia,
  não as distâncias. LR-07 vem depois dela e precisa ser casado com ela pelo Game Director.

#### P2

**LR-08 Ponte: o grupo empilha na ponte 2.** Pares a menos de 1,5 m o dobro das outras salas; o grupo inteiro sobe na
ponte de 5 m (`bridge_far`). É a ideia da sala (atravessar sob fogo), mas o amontoado vira uma fila que o herói varre da
cabeceira. Proposta: ponte 2 com 6,5 m (de -3,25 a 3,25) e o bloco do RP-04 1 m mais para o sul; medir pares e a zona
`bridge2`. Pede o `environment-artist` (tabuleiro). Custo: P a M.

**LR-09 Contato demorado na Ponte e no Santuário.** 5,3 a 6,6 s até o primeiro golpe (Cripta 3,2). O LR-03 resolve o
Santuário; na Ponte a demora é a travessia, parte da ideia. Medir de novo depois do LR-03 e do LR-08 antes de mexer.

**LR-10 Runas B: a pedra quieta continua 9 a 14%.** A mesma leitura do RP-01 (o robô não procura ilha). Não mexer antes
da sessão do Daniel; com gente, se ela não for procurada, o RP-14 (cristal) dá o motivo.

**LR-11 A distância da luta é a mesma em toda sala** (5,4 a 6,2 m até o mais perto). O espaço muda o caminho, não a luta.
É o que os perigos da lista de Sugestões (RP-06, RP-11, RP-16) e a mureta (RP-17) atacam; a ordem recomendada lá não muda.

### 4. A câmera Perto e o que as salas pedem (resumo)

- Com a **Longe**, as salas de luta mostram tudo de uma vez: nenhum canto escondido, nenhum atirador fora do quadro, as
  pequenas (Cripta, Runas) e a Ponte com muito vazio em volta. As salas não estão grandes demais nem pequenas demais para
  o jogo; estão pequenas para a tela.
- Com a **Perto**, as salas ficam do tamanho das do Hades (1 a 2,2 telas) sem mudar nenhuma planta; Cripta no limite.
  Nada fica pequeno demais. O que quebra é a regra do atirador (LR-02), que faz das salas grandes as mais fáceis.
- Recomendação: Perto como padrão **junto** com o LR-02; depois disso refazer a régua (24 a 48 sementes) antes de mexer em
  tamanho de sala. As propostas LR-03 a LR-06 valem para as duas câmeras (são de rota e de onde se nasce).

### 5. Riscos

- LR-01 e LR-02 mudam a dificuldade de toda a descida: medir com o `balance-designer` antes do exe.
- LR-03 e LR-04 põem atiradores mais perto da entrada: conferir a regra "nada nos 3 s do começo nem a menos de 6 m da
  entrada" para nascimento (hoje vale para perigo, não para inimigo) e o primeiro contato.
- LR-05 e LR-07 mexem em cenário já aprovado (entrada das Fendas, hub): passam pelo `art-director`.
- Tudo medido com o robô; "lugar não usado" (tronco, pedra quieta, muro) pode ser o robô. A sessão do Daniel decide os
  itens marcados.

### 6. O que precisa de arte

Entrada das Fendas A no noroeste (LR-05); ossuário mais longo na Cripta B (LR-06); hub com as estações mais perto do
eixo e a praça com peças no meio (LR-07, `HubLook`); ponte 2 mais larga (LR-08). Nenhuma peça nova; nenhum perigo novo.

---

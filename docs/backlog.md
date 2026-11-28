# Backlog de A Selagem


> Este arquivo guarda só o que está aberto. O histórico até 2026-11-26 está em `docs/backlog/historico_ate_2026-11-26.md`.

## Hoje, 2026-11-27 (LER PRIMEIRO na conversa nova)

**Exe `6f2fa22a` entregue (PT-28):** itens 1 a 10 feitos; coluna de Bênçãos opção A à esquerda; 159 ícones novos (US$ 7); sala do Morvath pintada. Aberto: PT28-11 Santuário (plano em `docs/art/hub_pt28_plan.md`, espera o sim do Daniel), sala 8 a confirmar com ele.

**Teste do Daniel no exe `bf27962f` (2026-11-27 noite), lote PT-28:**
| id | o quê | dono |
|---|---|---|
| PT28-1 | Golpes do Guerreiro avançam um pouco mais (o inimigo foge antes do golpe); substitui o "golpe plantado" de 2026-11-16 | gameplay-engineer **Feito 2026-11-27:** passos 0,3/0,3/0,8 para 0,5/0,5/1,4 m, Esmagador 0,4 para 0,7, Corte Circular 0 para 0,5, e o passo segue o inimigo à frente (até 3,5 m, cone de 40 graus, `StepRules.steer`); colisão e armadilhas como antes, `DECAY` 6 para 4,5 (pico abaixo da corrida) |
| PT28-2 | Portas fechadas de verdade de novo (hoje só o vão escuro); abrem ao vencer a sala | environment-artist | **FEITO (worktree): `ArenaRoom.door_arch` põe as folhas fechadas (`HallDoor`) no vão de cada porta em parede, abrem em `open_door_leaves(i)`; pontes (escada sobre o abismo) não têm vão; `tests/test_painted_hall.gd`** |
| PT28-3 | Sala 8: peças 3D por cima da pintura (postes) parecem sobrepostas | environment-artist | **FEITO em parte: a chama e a luz da bacia do Jardim (2,9, -14,6) sobre a grade da pintura saem (`PaintedHall.PROPS`); sala 8 exata não identificada, demais salas conferidas por lista de chamas/luzes, sem outra sobreposição certa; ver `docs/gallery/pt28/`** |
| PT28-4 | Pedir ao ChatGPT o desenho de TODOS os ícones de Bênção, e os símbolos das portas e da loja (hoje estranhos) | ai-art-producer |
| PT28-5 | Cartas de Bênção com tamanho fixo (todas iguais, com pouco ou muito texto) | ui-ux-designer | Feito |
| PT28-6 | Ícones das Bênçãos à direita: agrupados por anjo (semelhantes juntas), só aparecem segurando TAB, como o SWORN | ui-ux-designer | Feito; Feito (opção A, esquerda): coluna de 5 lugares fixos (`SlotColumn`), Tab abre as demais por anjo com cartões e 3 fixados (`BlessingTab`), passivas fora da coluna |
| PT28-7 | Esqueleto mago (elite) na sala 12 não morria: elites x1,8 exagerou (mago elite ~2300 de vida) | balance-designer, gameplay-engineer **Feito 2026-11-27:** elites x1,8 para x1,0 (corpo a corpo 1350 a 1500), à distância (mago, arqueiro, sacerdote) x0,7 (910, 875, 910), Capitão x1,2 (1800); ver `docs/design/balance/pt28-elites.md` |
| PT28-8 | Habilidade em recarga fica cinza e "enche" de cor de baixo para cima (como um copo), sem o círculo | ui-ux-designer | Feito |
| PT28-9 | Tirar a barra amarela (armadura) dos chefes, só vida | ui-ux-designer | Feito |
| PT28-10 | Sala do Morvath (Câmara do Selo) sem pintura | ai-art-producer, environment-artist |
| PT28-11 | Santuário muito feio: melhorar bastante (a gente passa muito tempo lá) | art-director, environment-artist |

**Exe `bf27962f` entregue (22h20), fecha as Etapas 1 a 5:** depois do crash do WSL (C: cheio; limpo para 118 GB livres), tudo das
Etapas já estava no ramo; a varredura final juntou o robô do Santuário (BG-4, `--hub --smoke`), o clipe de chamado do Capitão
(QW-2), o facho de recompensa sem o traço branco (conferir na GPU), BG-2, QW-1, QW-5, QW-6 e DT-1, DT-2, DT-5 (parcial: Morvath
assado de 10,8 MB, reduzir só com o art-director). Robô: 21 partidas sem erro nem travamento. Suíte 2805 testes verde.
Abertos: QW-3, QW-4, QW-7, PM-2 a PM-4, DT-4; Capítulo II espera as decisões do Daniel.

**Teste do Daniel no exe 17569337 (noite) e o que foi feito:**
- Antessala travava no "Segure {attack}": o Golpe Esmagador não alimentava o passo `heavy` (é Omega pela tag). Corrigido em
  `Rooms._on_struck` (tag `smash`), teste `test_each_mouse_blow_of_the_warrior_closes_its_own_step`.
- Magia de volta só nos golpes de segurar (Esmagador 12, Lança 20); toques de graça (Corte Circular também). Reverte `53a0a04b`
  menos o custo do Corte. Barra de Magia azul (`3a7ee8`).
- HUD sem a linha do Ritmo de Batalha e sem o nome das Bênçãos ao ganhar (só com o mouse em cima e na pausa).
- "Escolhi Coração e veio Bênção": o registro da partida dele (17h41) mostra a porta do Coração dando +25 de vida máxima (65 para
  90), sem Bênção; a queixa real é Bênção demais no baralho. Duas Bênçãos viraram Prata e Memória (recursos do hub): 6 de 23.
- Arte do hub: pedida ao gpt-image-2 (ai-art-producer), para o Daniel aprovar em `Downloads\ASelagem-GP8\GPT-Hub`.

**Entregue:** exe `059930f7` (16h15): 11 personagens novos do Meshy no estilo pintado (Guerreiro, Esqueleto, Corredor,
Besteiro, Guarda, Mago baixinho, Sacerdote, Maga, Cavaleiro, Ancião, Morvath) com ajuste de cor; HUD v3 com a fileira
de golpes do desenho do Daniel; portas afastadas com uma peça entre elas em todas as salas e vão só escuro; Salas 00, 01
e Antessala com a pintura do jogo e chamas, velas, água e vasos em 3D por cima; números do SWORN; efeitos da espada
verdes.

**Já no jogo, vai no próximo exe:** menos inimigos (salas 1 a 4 escritas à mão para ensinar; curva SWORN x1,5 nas
demais; robô: 5 de 12 chegam a Morvath, 0 vitórias).

**Em andamento:**
- **Mouse sem Magia: FEITO** (`53a0a04b`): 4 golpes a 0, barra de Magia escondida no Guerreiro; Lança com 14% do dano
  no robô; se o Daniel achar spam, recarga de 2 s no nó `lance`.
- **Entradas e ajustes de sala** (room-designer): peça de chegada de verdade em todas as salas (patamar ou passarela que
  sai da tela, nunca "buraco no parapeito"); Altar com as portas na parede do fundo e o túmulo entre elas; Ponte com a
  porta direita para a frente; Runas B sem o pilar na porta esquerda; variantes A e B visivelmente diferentes.

**Prontos em ramos, esperando a próxima sessão juntar:**
- `worktree-agent-af8f656c0f2f4cd06` (`dad5e194`): entrada nova em todas as salas (patamar de pedra 3,2 x 2,4 m pendurado na
  borda sul com escada de 5 degraus saindo da tela; parapeito aberto); Altar com as portas na parede do fundo e o túmulo
  entre elas; Ponte A e B com as portas lado a lado no fundo; Ponte B em zigue-zague; pilar da Runas B fora da porta; teste
  novo `test_no_solid_piece_in_a_doors_approach`. Ainda parecidas: Cripta A/B e Jardim A/B; o Santuário B tem o buraco
  no dado, mas a pintura perdeu (o pedido tem de nomear o buraco). Conflito esperado nos docs: ele editou
  `rooms_progression.md` e `art_rooms.md`, que viraram índices; mover a seção nova para a pasta certa.
- `worktree-agent-a8a4f94e23fde4ed7` (`c881136b`): 14 placas do lote 4 ligadas como dado, e a opção `--clear-air`.

**Caminhada do Cavaleiro e do Ancião (feito 2026-11-27, technical-artist):** `KNIGHT_JOG` passada 0,66 para 0,8 (118 passos por minuto, pé 6,6 cm) e `ELDER_STRIDE` 0,9 para 0,7 (99 passos, 0,2 cm); só `knight.res` e `priest_elder.res` reassados, `test_living_crowd` 12 de 12. Conferir o passo na GPU.

**Exe entregue às 17h16: `17569337`** (mouse sem Magia, menos inimigos, docs divididos; nas duas pastas).

**Próximo, nesta ordem:**
1. ~~Exe com o mouse sem Magia e a redução de inimigos~~ feito (`17569337`).
2. Juntar as entradas novas; recapturar as bases na GPU (`--shot-at=2.5`; Runas com `--clear-air`; Ponte com
   `--cam-at=3,2 --cam-dist=94`).
3. Repintar (ai-art-producer, regras novas no arquivo do agente: sem poças de luz pintadas na versão do jogo, peça de
   chegada, A e B diferentes): as aprovadas só na entrada (02 a 06, 08 a 14, 17), e de novo 15, 16 (Runas) e 18 (Altar).
4. Juntar o ramo das pinturas do lote 4 (`worktree-agent-a8a4f94e23fde4ed7`, commit `c881136b`, 14 salas ligadas
   como dado em `PaintedHall.ROOMS`) trocando as placas pelas repintadas; árvore 3D do Jardim por cima da pintada
   (pôr `stone_tree` em `SOLID` ou esconder); exe.
5. Depois: Capítulo II (abaixo), começando pelas decisões 1 a 4.

**Aprovações do Daniel hoje:** personagens 1 a 11, ícones do HUD, versões do jogo das Salas 00, 01 e Antessala, salas
02 a 07; lote 4: 02 a 06, 08 a 14 e 17 aprovadas (refazer 18; entradas em todas). Regras novas: portas nunca juntas;
vão escuro; entrada visível com peça de chegada; perigos nas pontas de cima e de baixo; nada que se mexe na pintura do
jogo; luz feita pelo jogo; mouse sem Magia; poucos inimigos nas 4 primeiras salas.

**Pastas do Daniel:** `Downloads\ASelagem-GP8\GPT-SalaNN` (uma por sala), `APROVAR-SALAS-LOTE4`, `APROVAR-TUDO`;
exes em `Downloads\ASelagem-3D` e `ASelagem-teste`.

## Maga Redesign V1 (pacote do Daniel de 2026-11-27, `docs/design/heroes/maga_redesign_v1_pack/`) — NO BACKLOG, NÃO FAZER AINDA

Pacote do ChatGPT que substitui o kit da Maga (não o do Guerreiro); esperar o "pode fazer" do Daniel.
- **Kit:** M1 toque Centelha (3 projéteis juntos em leque, 0 Mana); M2 toque Sopro Glacial (cone 90°, 5 m, lentidão);
  M1 segurar Combustão (bola de fogo que cresce com a carga, 15 a 25 Mana); M2 segurar Inverno Eterno (chão congelado na
  mira, raio cresce, 10 a 30 Mana); Shift Tempestade Celestial (raio que salta até 6 alvos); Espaço Passo Etéreo (2 cargas).
  Vida 30, Mana 50, regeneração 3/s também andando; sem Mana por ataque. Custo cobrado ao soltar; esquiva cancela sem custo.
- **Reações:** Fogo + Frio = Choque Térmico; Fogo + Eletrização = Sobrecarga; Frio + Eletrização = Cristalização. Sem
  reação tripla no kit básico; chefes não congelam (usam a Quebra). Toques preparam, carregados resolvem.
- **Arte e efeitos:** fogo âmbar, gelo azul claro e marfim, eletricidade dourada; vermelho só para perigo inimigo;
  tabela de preparação, execução e dissipação por feitiço; SVG de geometria em `arte/`.
- **Integração:** sai Arco Voltaico, Estilhaço, Geada e Convergência do kit ativo (sem quebrar saves); um Supremo por
  arma; Dons novos (Elementalismo, Conjuração, Feitiçaria) só com aprovação.
- **Conflitos a resolver antes:** o HUD do pacote (5 quadrados ofensivos, esquiva à direita, "Bênçãos em losangos") difere
  da coluna de Bênçãos à esquerda aprovada hoje (opção A, PT28-6); o pacote diz "não fazer push", vale a regra do Daniel
  (sempre commit e push); a Maga V2 de hoje (`5f09feda`, Centelha em corrente de três) será substituída.
- **Donos:** hero-designer (revisão e números), gameplay-engineer, technical-artist (VFX), ui-ux-designer (HUD), balance-designer.

## Capítulo II: O Bosque Submerso (pacote do Daniel de 2026-11-27, `docs/design/cap2/`) — NO BACKLOG, começa depois de fechar as salas do Capítulo I

Pacote: `docs/design/cap2/docs/01_MASTER_PLAN.md`, `02_FATIA_JOGAVEL.md`, `03_BIBLIA_ARTISTICA.md`, ordem em
`prompts/00_CLAUDE_CODE.md`, prompts de arte em `prompts/01_PROMPTS_MCP.md`, prancha e recortes em `artes/` (só
inspiração; o texto vale mais que a prancha). Escopo autorizado: só a primeira fatia (Morvath, Átrio, chegada, três
encontros, Ancião Retorcido, recompensa, fim da prévia). O resto é planejamento.

**Marcos (cada um com exe; arte e plano aprovados antes de gastar):**
- **C2-A Transição** (gameplay-engineer): vários `StageDef` por dado; índice da região separado da profundidade;
  passagem idempotente que guarda tudo da partida (herói, vida e Magia, Bênçãos, Elos, Salmos, Encantos, Dons, ouro,
  materiais, estatísticas, semente); save antigo carrega; registro da região separado da vitória final; chave
  (flag) desligada mantém o final de Morvath como hoje. **Átrio** sem inimigos: Malahym, diálogo curto, fonte (cura
  40%), Graça (35% a mais de cura, ou subir a raridade de uma Bênção, ou +1 nível em duas), mercador e portal (E).
  **Chegada** como cometa de luz, título da região, sem dano.
- **C2-B Três salas e quatro inimigos**: Portões do Bosque, Jardim dos Esporos, Templo Inundado (técnica GP-8, duas
  versões, regras de portas e entradas do Capítulo I). Inimigos: Esporinho (bando, nuvem de esporos), Retorcido (golpe
  largo com preparação), Flor Espinhosa (leque de sementes, reposiciona), Sapo do Brejo (salto com onda), reaproveitando
  comportamentos que já existem. Pulso do Bosque: água rasa (-15% de movimento, sempre com rota seca), raízes com aviso
  (nunca sobre o herói nem fechando todas as saídas), esporos (nuvem que afeta todos). Conceitos pela API de imagem,
  aprovação, depois Meshy (estimar créditos antes).
- **C2-C Ancião Retorcido**: arena circular, 3 fases (golpe largo e raízes; raízes e Retorcidos pequenos, no máximo 3;
  mistura), janela de recuperação clara, nada de imunidade; ao vencer a luz âmbar volta ao tronco. Tela "Fim da prévia
  do Capítulo II" e volta ao Santuário, sem marcar vitória completa.
- **C2-D** QA, equilíbrio (lutas comuns 35 a 75 s, guardião 90 a 150 s numa build mediana; Guerreiro e Maga), exe.

**Decisão do Daniel (2026-11-27, substitui as propostas anteriores que conflitam): progressão e minichefes do
Capítulo II.** Cinco salas antes do minichefe; só **um** minichefe obrigatório no capítulo, escolhido pelo jogador nas
portas da sala anterior (uma porta por minichefe). Recompensas: só o sorteio que já existe, qualquer recompensa elegível
pode sair; nada de recompensa própria de minichefe, tabela especial, sistema novo ou raridade privilegiada. Vale só para o
Capítulo II; o Capítulo I fica como está até validar. Prioridade: ação, fluidez, simplicidade, aleatoriedade e
rejogabilidade. Consequências no plano acima: a fatia jogável passa a ter 5 salas antes do minichefe (não 3), a
escolha entre minichefes vira duas portas na sala 5, e o "segundo guardião" (sala 09) e os "dois de três guardiões por
partida" do Master Plan saem; a recompensa do minichefe é a da porta, pelo sorteio normal.

**Bestiário do Capítulo II (lido em 2026-11-27 de `docs/design/cap2/docs/02_FATIA_JOGAVEL.md`, `01_MASTER_PLAN.md`,
`prompts/01_PROMPTS_MCP.md` e das pranchas `artes/08_bestiario_recorte.jpg` e `09_guardioes_recorte.jpg`).** Regra: inimigo novo
com comportamento que já existe é só dado (`EnemyDef`, `tools/make_data.gd`); a coluna "Comportamento" diz qual `Behavior` serve ou o
que falta. Modelos: conceito pela API de imagem, aprovação, depois Meshy (estimar créditos antes). Elites só com o sistema que já existe.

*Fatia jogável (C2-B, quatro):*
| # | Inimigo | Papel | Desenho | Comportamento | Onde aparece |
|---|---|---|---|---|---|
| B2-1 | **Esporinho** | bando, vida baixa | cogumelo atarracado e atrevido, chapéu grande, pernas curtas, rosto expressivo | `PULSE` (corre e solta a nuvem de esporos em volta, anunciada); a nuvem que fica no chão é o perigo de esporos do Pulso do Bosque | Portões, Jardim |
| B2-2 | **Retorcido** | corpo a corpo, vida média | humanoide alto de raiz, braços compridos e assimétricos, musgo e folhas | `SWEEP` ou `CONE` (golpe largo com preparação clara); conferir qual lê melhor | Portões, Jardim, Templo; os pequenos do Ancião |
| B2-3 | **Flor Espinhosa** | atiradora, vida baixa, prioridade alta | flor que anda, cabeça de pétalas, caule como pernas | `ARCHER` com leque de sementes (tiro em leque) e `keep_away` para reposicionar; ver se o leque já existe nos tiros | Jardim, Templo |
| B2-4 | **Sapo do Brejo** | salto, vida média | anfíbio redondo e rabugento, verde musgo e ocre | `LEAP` (salto sinalizado) com onda ao aterrissar (anel no chão); conferir se o `LEAP` já solta onda | Templo |

*Futuros (seis, não implementar agora; combinações pensadas: Cascudo+Flor, Sapo+Serpente, Feiticeiro+Marionete, Lumífago+Caranguejo):*
| # | Inimigo | Desenho e papel | Comportamento |
|---|---|---|---|
| B2-5 | **Cascudo** | tatu-tartaruga de carapaça de pedra; carapaça na frente, fica aberto depois da investida | `RUNNER` + escudo frontal (o do Cavaleiro); a abertura é a janela de punir |
| B2-6 | **Feiticeiro do Bosque** | cogumelo de chapéu grande, vínculo de fortalecimento visível num aliado | `SUPPORT` (como o Gritador) com fio visível até o fortalecido |
| B2-7 | **Serpente das Águas** | serpente azul-turquesa, emerge em água sinalizada e lança ondas | novo: emergir só na água (o mais caro dos seis); onda como o `BEAM`/onda do Sapo |
| B2-8 | **Lumífago** | inseto de asas luminosas, orbes lentos e temporários | `ARCHER` com tiro lento que fica no ar por um tempo; **na prancha é violeta: trocar** (regra) |
| B2-9 | **Caranguejo das Ruínas** | caranguejo com uma construção nas costas, territorial | `CHASE` preso a uma zona (território); novo só o "volta para casa" |
| B2-10 | **Marionete do Bosque** | boneco de madeira animada, deslocamentos desajeitados | `CHASE`/`RUNNER` com passos irregulares (dado de movimento) |

*Guardiões (minichefes) e chefe:*
| # | Nome | Desenho | Quando |
|---|---|---|---|
| B2-11 | **Ancião Retorcido** | treant monumental, rosto na madeira, olhos âmbar, braços de galho assimétricos, raízes como pés | fatia (C2-C): 3 fases (100 a 65 golpe largo e raízes; 65 a 30 raízes e até 3 Retorcidos pequenos; 30 a 0 mistura), aviso 1 s, recuperação 1,5 s, raízes 3 s; **nome para o jogador a decidir** (confunde com o Sacerdote Ancião) |
| B2-12 | **Rei do Brejo** | sapo barrigudo gigante de coroa torta | futuro: saltos e ondas (o Sapo do Brejo em grande) |
| B2-13 | **Flor Adormecida** | lótus colossal marfim e rosa | futuro: alterna pétalas fechadas (protegida) e expostas, sementes; **prancha com violeta: trocar** |
| B2-14 | **A Coroa Partida** | Rainha (marfim e ouro velho, coroa de galhos, serena e melancólica) e Guardião (cervo-leão-árvore, musgo, olhos âmbar) | chefe do capítulo, futuro: 4 fases (Guardião, Rainha, dupla coordenada, manifestação e restauração); **lore a aprovar** |

Pendências do bestiário para o Daniel: o nome do Ancião Retorcido para o jogador; a cor do Lumífago e da Flor Adormecida (sem
violeta); aprovar os conceitos dos quatro da fatia antes do Meshy (crédito estimado antes).

**Futuro (só registrar):** salas 05 a 12 (descanso, Labirinto, evento, Vila, segundo guardião, loja, Coroa Partida),
18 layouts em 6 famílias, seis inimigos (Cascudo, Feiticeiro, Serpente, Lumífago, Caranguejo, Marionete), guardiões
Rei do Brejo e Flor Adormecida, chefe A Coroa Partida (Rainha e Guardião, 4 fases), eventos (Tesouro, Sementes da
Restauração, Jardineira, Travessia do Rio, Ovo Misterioso), reagentes (Cogumelo Lunar, Asa Luminosa, Raiz Ancestral,
Cristal das Águas, Semente Dourada, Fragmento da Coroa), reações elementais com o bosque.

**Conflitos com regras atuais, decidir com o Daniel antes de começar:**
1. **Violeta** aparece na prancha (cogumelos do Jardim, Lumífago, Flor Adormecida, acentos "âmbar e violeta" no
   prompt do Jardim). Regra: violeta só em Morvath. Proposta: trocar por rosa, magenta quente ou âmbar.
2. **"Ancião Retorcido"** confunde com o nosso Sacerdote Ancião (guardião do Capítulo I). Proposta: manter o nome
   técnico e escolher outro nome para o jogador (o Daniel decide).
3. **Lore nova** (a Rainha, a Coroa Partida, o Guardião cervo-leão-árvore, o Bosque Submerso, a civilização antiga):
   o pacote já diz que são propostas; conferir com `../dungeon-rpg/docs/mundo/canone.md` e aprovar com o Daniel.
4. **Malahym da Maré:** o pacote pede o anjo "da Maré" com retrato aprovado. Entre os nossos 9 anjos, o da água é
   Galael ("abre caminho como a água"), dono das Bênçãos de Maré. Proposta: Galael recebe o herói no Átrio.
5. **Portas "altas e próximas"** no pacote contra a regra do Daniel de 2026-11-27 (portas afastadas com algo entre
   elas): vale a regra do Daniel.
6. **"No máximo dois agentes"** no pacote contra a regra atual (até 4 no WSL): vale a atual.
7. A prancha escreve "Punho de Elun" no Guerreiro: o jogo continua mostrando só "O Guerreiro" (D-64).

## Teste do Daniel no exe 1497e18a (2026-11-26, 21h)

- **PT-27a (bug, investigar):** "escolhi pegar um coração na sala 3 mas veio uma Bênção do Sarael com uma opção apenas". O registro
  das partidas (`runs.jsonl`) não mostra o caso: nas partidas registradas o coração deu vida. Hipóteses: medalhão do Sarael
  (vermelho) confundido com o coração, ou mão de 1 carta pela linhagem V2. Dono: gameplay-engineer e ui-ux-designer.
  **Investigado (gameplay-engineer, 2026-11-26):** nenhum caminho de HEART abre Bênção (`_give` só soma vida; `settle` só vira POM,
  PSALM e ENCHANT; coração nunca é encontro nem mostra anjo; mão sempre com 3 cartas, `tests/test_heart_door.gd`). No registro dele a
  única coisa que bate é a porta de Bênção com um anjo só (`fallback: "door"`, `offered: [sarael]`, 3 cartas), desenho previsto da
  Fatia 2: porta vermelha de Sarael ao lado da do coração (`run 32`, sala 3). Hipótese: confusão de medalhão. O registro agora grava
  `angels` por porta e `promised`/`hand` no evento `reward`. Proposta ao ui-ux: diferenciar o medalhão do anjo do coração.
- **PT-27b (depois de fechar o que temos):** jogo muito difícil; heróis dão pouco dano no capítulo 1. Repensar com o balance-designer.
- **PT-27c (depois):** a Maga está chata de jogar, "vamos ter que repensar muito nela". HUD da Maga parado até lá.
- Ordem do Daniel: finalizar tudo o que já temos e só depois pensar em dificuldade, dano e Maga.

- **GP-8, mudança do Daniel (2026-11-26 22h):** "vamos tentar com o GPT primeiro, eu não achei ruim o GPT, achei ruim como foi aplicado".
  Midjourney em espera. Técnica A com a pintura do ChatGPT já aprovada (`docs/art/ref/sala01_2026-11-25/01-arte-aprovada.jpg`)
  projetada como a própria sala (`--painted`), protótipo com o environment-artist.

## Backlog priorizado (2026-11-26 noite): tudo o que está aberto, numa lista só
Junta o que ficou aberto nas rodadas até o exe `abcc4c89` (seções abaixo, revisões `qa_2026-11-26b.md` e `ART_REVIEW_2026-11-26b.md`)
com os 3 pacotes do ChatGPT de 2026-11-26 (textos em `docs/design/packs_2026-11-26/`: `vfx` = PK-1, `herois_v1` = PK-2,
`p0_bencaos_v2` = PK-3; imagens do VFX só locais em `docs/art/ref/vfx_2026-11-26/`). Os pacotes mandam "não fazer push":
vale a regra do Daniel (sempre commit e push). As seções abaixo ficam como histórico e detalhe.

### 1. Bugs
| id | o quê | origem | dono |
|---|---|---|---|
| BG-1 | Efeitos a confirmar no jogo de hoje e corrigir só se ainda acontecem: facho de recompensa (`RewardShaft`) ligado à sala vencida, loja e fonte; contato com miolo branco e pontas em cruz; traço branco vertical sobre a vítima; `glint` cobrindo o herói; lascas acesas acima da cabeça; clarão de Morvath perdendo o violeta; onda do especial acertando em cruz de 4 pontas; Círculo com disco branco chapado; preparo do Feiticeiro acima do teto | PK-1 fase B | technical-artist, art-director confere |
| BG-2 | Bolinha escura ao lado do medalhão da Bênção; na Provação os dois medalhões se encostam e o título aparece duas vezes | sobras SW fase 1 | ui-ux-designer **Feito 2026-11-27:** medalhões da Provação menores e título uma vez (63f52a50); varredura: miolo branco do facho de recompensa apagado (traço fino no HUD 1080p) |
| BG-3 | Retângulo (`Rect2`) negativo na Maga | PK-3 testes | gameplay-engineer | **2026-11-27: não reproduz** (testes da Maga e `--smoke --hero=maga` sem erro); reabrir se aparecer o texto do erro |
| BG-4 | `--smoke` ignora `--hub`: o robô não testa o Santuário. **Feito 2026-11-27:** `--hub --smoke=N --bot` anda por cada estação pela `NavGrid` e entra no portal aventura (RESULT `hub ... reached= stuck= gate=`); `tests/test_hub_smoke.gd` trava o alcance dos pontos de uso | QA 26b | qa-performance |

### 2. Erros e dívidas técnicas
| id | o quê | dono |
|---|---|---|
| DT-1 | Shaders sem uso: `dome_film`, `dome_clock`, `fury_ember`, `dark_water_matte` (apagar depois de conferir) **Feito 2026-11-27:** os quatro já estavam apagados (2802f22c); conferido sem referência; inventário corrigido. | technical-artist |
| DT-2 | O Guerreiro ainda referencia duas ultimates (`00_cleave`, `01_vortex`); a decisão de 2026-11-24 é Corte do Juízo único, Voragem guardada (conferir se a seleção já sumiu e limpar o dado) **Feito 2026-11-26:** `ult_for_weapon` já ignorava a reserva; faltava o anúncio do nível 10 (`unlocks_at`, `MasteryReport`, `first_ult_level`), agora sem a Voragem. **Feito 2026-11-27:** a Voragem (`01_vortex`, `reserve`) fica de propósito no dado e nos testes, e nunca é escolhida (`ult_for_weapon`); nada a limpar sem quebrar testes. | gameplay-engineer |
| DT-3 | CSV das Bênçãos desatualizado (fonte é `make_data.gd`); regerar do dado **Feito 2026-11-27:** `tools/boons_csv.gd` regera `docs/design/bencaos_v2/BALANCEAMENTO_V2.csv` | balance-designer |
| DT-4 | Custo por golpe com 150+ inimigos ainda 25 a 35 ms no `--stress=300` | qa-performance |
| DT-5 | Morvath assado acima de 60 MB (TA-07), medalhões acima de 512 px (TA-08), `disk_report.sh` (TA-02), `docs/steam-ia.md` em dia (TA-12) **Feito 2026-11-27 (parcial):** `assets/baked` soma 72,8 MB (69,5 MiB, no teto de 70); Morvath 10,8 MB, o maior; reduzir pede reassar com menos triângulos (muda o visual, fica para o art-director); medalhões já em até 512 px (só `title/` passa); `steam-ia.md` em dia (18h18). | technical-artist |

### 3. Quickwins (horas)
| id | o quê | dono |
|---|---|---|
| QW-1 | Números de dano empilhados (`fx.gd`) | technical-artist **Feito 2026-11-27:** espalha para o lado (NUMBER_SIDE_TRIES, 2802f22c) |
| QW-2 | Capitão chama ajudantes na pose de andar (falta pose de chamado). **Feito 2026-11-27:** clipe `summon` (Cheer, braço erguido) no atlas do `guard`; `test_enemy_look` exige o clipe | gameplay-engineer |
| QW-3 | Aviso da pedra que cai (`DropFloor`) chapado; xadrez claro das Runas; torres de ruína chapadas da ponte | environment-artist |
| QW-4 | Faixa de água e musgo da sala com brilho forte que compete com os avisos no chão | environment-artist |
| QW-5 | Linha de objetivo no Santuário: ligar ou apagar as chaves | ui-ux-designer **Feito 2026-11-27:** linha apagada no Santuário e chaves removidas (63f52a50) |
| QW-6 | Dicas longas na linha de objetivo em 720p | ui-ux-designer **Feito 2026-11-27:** largura fixa 420 com quebra de linha (63f52a50) |
| QW-7 | Passos Leves (Galael) talvez fraco: medir fora do robô | balance-designer |

### 4. Pequenas melhorias (até 1 dia)
| id | o quê | dono |
|---|---|---|
| PM-1 | **VFX, auditoria e primeira amostra** (PK-1 fases A, B e assinaturas 1 e 6): capturas antecipação, contato e dissipação no HEAD; combo e contato da Emeth em pincelada (sem cruz, núcleo escuro, borda marfim-menta); coleta com facho suave, poça e retirada no pickup. Só VFX, nada de gameplay | technical-artist, art-director, combat-feel-director confere sincronia |
| PM-2 | Santuário, o que falta da revisão 26b: fundo de falésias e montanhas no lugar do azul liso, hera só encostada em parede, nicho em arco atrás do fogo da Vigília, folhagem menos preta, Portão legível de lado, céu | environment-artist |
| PM-3 | Fendas: o herói fica 77% do tempo no leste (ouro e quebráveis nos cantos) | room-designer |
| PM-4 | Até 4 fontes por caminho: conferir a cura | balance-designer |
| PM-5 | Estados das Bênçãos aplicam mesmo quando a guarda reduz o golpe (PK-3 propõe: só golpe que causa dano) **Feito 2026-11-27:** o estado novo já não pegava (`Celestial.after_hit`); queimadura, gelo, fraqueza e marca dos dons antigos também param no golpe que a guarda fechou (`Combat.hit_enemy`). | decisão do Daniel, depois gameplay-engineer |

### 5. Grandes projetos (cada um um lote com exe)
| id | o quê | depende de | donos |
|---|---|---|---|
| GP-1 | **Guerreiro V1 e controles novos** (PK-2): esquerdo toque Combo, segurar Golpe Esmagador; direito toque Corte Circular 360°, segurar Lança da Emeth (o golpe carregado de hoje); Shift Supremo; E só interação; Brado e Investida saem; 40 de vida e 30 de Magia, passiva Ritmo de Batalha, 12 Dons novos com migração de save; HUD, Antessala e dicas novas. Resolve a E6 e o Brado de 1% | C-1 | hero-designer, gameplay-engineer, ui-ux-designer |
| GP-2 | **Bênçãos V2** (PK-3): regras de dano, condições e reações com orçamento e sem recursão; medidor de frio e impacto em chefes; 9 anjos x 9 = 81, dois novos (Peste e Trovão); slots remapeados para os botões do GP-1; 12 arquétipos medidos em 12 sementes | GP-1 (slots), C-5 | gameplay-engineer, balance-designer |
| GP-3 | **VFX "tinta em movimento"** (PK-1 assinaturas 2 a 5): especial e Corte do Juízo, famílias dos anjos com forma própria, mortos e Morvath, Maga | PM-1 aprovada; especial depois do GP-1 | technical-artist, art-director |
| GP-4 | **Salas 03 a 14** (E7), uma por pacote do ChatGPT | pacotes do Daniel | environment-artist, room-designer |
| GP-5 | **Maga V1** (PK-2): 30 de vida, 50 de Magia, regeneração, Centelha, Arco Voltaico, Estilhaço, Geada, 3 reações, 12 Dons | C-3, depois do GP-2 | hero-designer, gameplay-engineer |
| GP-6 | Modelos Meshy (Cavaleiro, Ancião, armadura do Guerreiro), retrato do herói no HUD | autorização de créditos | technical-artist |
| GP-7 | Salas maiores e acabamento por arena (lista (C) da rodada 2026-11-25), heróis novos (Ladina, Paladino) | depois | room-designer, hero-designer |
| GP-8 | **Arte final por IA, fatia vertical** (aprovado pelo Daniel em 2026-11-26: "precisamos melhorar MUITO a arte"). Sala 01 feita de dois jeitos lado a lado: (A) cenário pintado por IA no ângulo exato da câmera e projetado sobre a geometria de colisão e profundidade que já existe (técnica do Hades); (B) kit modular 3D gerado por IA com textura pintada. Guerreiro e 3 inimigos refeitos na melhor ferramenta 3D (teste Meshy x Rodin x Tripo com as mesmas peças). Midjourney com referência de estilo fixa para salas, ícones, retratos e texturas "do mesmo pintor". Aplicação: luz por sala, correção de cor por bioma, decalques, densidade de adereços, VFX na mesma pincelada. Regra: nada entra abaixo da pintura-alvo (captura e pintura lado a lado, art-director e Daniel). Depois da escolha A ou B, as 13 salas e o Santuário. Estimativa de créditos 3D antes de gastar. | assinatura do Midjourney (o Daniel assina; Claude prepara os prompts) | art-director, technical-artist, environment-artist |

### 6. Decisões do Daniel: RESPONDIDAS em 2026-11-26 noite ("concordo com todas")
1. Controles do PK-2 (esquerdo toque Combo / segurar Golpe Esmagador; direito toque Corte Circular / segurar Lança da Emeth; Shift Supremo; Espaço esquiva; Brado e Investida saem; a E6 fecha no Corte Circular).
2. Interagir no E (o F sai). 3. Guerreiro 40 de vida e 30 de Magia sem regeneração; no jogo continua "Magia".
4. Força Titânica sobe a Magia máxima para 40 só com esse Dom. 5. Dons removidos devolvem a Memória e liberam as Vagas.
6. Só o Corte do Juízo; Voragem guardada. 7. Maga depois do Guerreiro e das Bênçãos V2, com o kit do PK-2.
8. 5 botões de Bênção por anjo: Ataque (toque e segurar), Poder, Especial, Esquiva, Supremo (9 x 9).
9. Zerael (Peste) aceito. 10. Baraqel não serve (anjo caído em Enoque): o anjo do Trovão se chama **Saarael** (de *sa'ar*, tempestade; escolhido pelo Daniel em 2026-11-26), id técnico `thunder`.
11. Estados só com golpe que causa dano. 12. Sorteio 3:1 e mão completada por outros anjos, como hoje.
13. Textos pendentes aprovados como estão. 14. Música do Santuário: **Achaidh Cheide**. 15. D-O8: só o Guerreiro na chegada, sem números na fala.
16. Linha de objetivo no Santuário: apagar. 17. Meshy: nada por enquanto. 18. Salas 03 a 14 com os pacotes, uma por vez.
19 a 21. Ordem abaixo. Depois (2026-11-26 noite): "pode fazer tudo, sem me perguntar nada, no fim de tudo me avisa para eu testar": toda a ordem aprovada em sequência, um exe por etapa, o Daniel testa só no fim.

### Ordem aprovada
1. **Lote 1 (começado 2026-11-26 noite):** BG-1 a BG-4, DT-1 a DT-3 e QW-1 a QW-7 num lote só, junto com a PM-1 (não dependem de decisão). Exe.
2. PM-2 a PM-4. Exe.
3. GP-1 (depois do C-1 e do teste do C-6), GP-2, GP-3, GP-5, nessa ordem, um exe por projeto. GP-4 quando chegarem pacotes.


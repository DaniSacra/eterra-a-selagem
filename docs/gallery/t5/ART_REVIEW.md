# T5: revisão de arte (art-director, 2026-11-17, `arpg-3d` em `24c298e`)

Pergunta do PO: o inimigo prepara fisicamente o golpe de forma legível e com qualidade? A corrida do esqueleto parece
esqueleto de fantasia sombria e não gazela? As telas de evento são claras e bonitas na identidade de Eterra?

Material revisto (nenhum quadro novo: o que estava na galeria bastou; tudo da CPU, vista de lado do `tools/enemy_lab.gd`
e telas do `tools/ui_lab.gd`):

- Movimento: `motion/before/` e `motion/after/` (`sheet_*.jpg`, `lab_*_side.jpg`, `walk/skeleton_walk.jpg`,
  `sheet_skeleton_walk.jpg`, `before/skeleton_run_side_24f.jpg`) e as medidas de `docs/qa/t5_enemy_motion.md` seção 6.
- Telas: `ui/before_*` e `ui/after_*` (Provação, selo no HUD, laje, Altar, Altar sem recursos; 720 e 1080).

Limite: vista de lado é o pior caso para ler pose e o melhor para julgar a forma; a câmera do jogo (30 graus de
inclinação, 54 m) não foi vista em movimento. Nada aqui substitui o vídeo na GPU a 60 qps, que segue pendente.
Os modelos do Meshy são finais; os clipes são da UAL e do KayKit (CC0) transferidos, então a qualidade de animação tem o
teto dessas bibliotecas.

## Vereditos

| Item | Veredito |
|---|---|
| 1. Preparação do esqueleto | Aprovado |
| 2. Preparação do corredor (e o giro) | Com ressalva (joelho no 1º quadro) |
| 3. Preparação e tiro do feiticeiro | Com ressalva (gesto do tiro pequeno) |
| 4. Besteiro, Sacerdote, Ancião | Aprovado (pelas medidas e pelas folhas do ancião; besteiro sem folha nova) |
| 5. Escudo: preparação | Aprovado (era bom, ficou igual) |
| 6. Escudo e Cavaleiro: a investida | **Reprovado como forma** (o escudo sai da frente durante a corrida) |
| 7. Cavaleiro: preparação | Aprovado |
| 8. Recuperações | Aprovado |
| 9. Morvath: preparação da Investida e das Lâminas | Aprovado |
| 10. Corrida do esqueleto (`Jog_Fwd`) | Com ressalva (não é mais gazela; agachada demais) |
| 11. Tela da Provação | Com ressalva (medalhão igual nas três cartas) |
| 12. Placa da laje da Provação | Com ressalva (quatro linhas apertadas, pequena a 720) |
| 13. Selo da Provação no HUD | Aprovado |
| 14. Tela do Altar | Com ressalva (medalhões chapados e que dizem o contrário) |

Resposta curta ao PO: **sim, na maioria.** Esqueleto, Cavaleiro, Morvath, ancião e as recuperações agora preparam o
golpe com o corpo, e a pose armada de cada um é diferente da guarda. A exceção visível é a investida do Escudo e do
Cavaleiro: a preparação lê bem, mas o corpo se endireita e o escudo vai para o lado no meio da corrida. A corrida do
esqueleto deixou de ser gazela e passou a ser um trote curvado de morto-vivo, bom para o tom; está agachada um pouco
demais. As telas de evento ficaram muito mais claras (o que se paga, o que se ganha, por quanto tempo); falta o
medalhão dizer a coisa certa.

## 1. Movimento

### 1.1 Esqueleto: preparação e bote (aprovado)

`after/sheet_skeleton_windup.jpg`, `lab_skeleton_windup_side.jpg`: antes só o braço subia, tronco e pernas parados. Agora
o tronco enrola para trás, o joelho dobra e a espada termina erguida atrás do ombro, horizontal, com o peito aberto
para o herói: a silhueta muda de "guarda baixa" para "lâmina no alto" (pose armada 0,31 m). O bote (`sheet_skeleton_attack`)
desce dessa pose numa estocada larga e baixa, e o dano agora sai no quadro em que a lâmina chega (100% dos 110 golpes
dentro do alcance). É o que o PO pediu.

Observação, sem pedido: no último quadro o tronco gira tanto que, de lado, a lâmina fica atrás da cabeça. De cima (a
câmera do jogo) a espada erguida deve ler melhor que de lado; conferir no vídeo da GPU.

### 1.2 Corredor (com ressalva)

`sheet_runner_windup.jpg`: o fim da preparação (agachado, braços para trás, cabeça baixa) é a pose certa de quem vai
explodir. O começo não: os dois primeiros quadros têm o joelho direito erguido à altura do quadril (o `Jump_Start` a
0,18 s), pose de flamingo que não diz nada e que o QA já anotou (6.6). O giro do ataque
(`2H_Melee_Attack_Spinning`, `lab_runner_attack_side.jpg`) com os braços abertos lê como explosão em volta: aceitável.

Correção (gameplay-engineer, `tools/bake.gd`, `runner` `windup`): começar o trecho em `from` 0,24 (era 0,18), mantendo
`to` 0,33; se o pico cair abaixo de 1,0 m/s, `to` 0,36. Critério: em nenhuma pose da preparação o pé que não apoia
sobe mais que 0,15 m (tamanho 1) acima do de apoio.

### 1.3 Feiticeiro (com ressalva)

Preparação (`sheet_mage_cast.jpg`): o cajado sai de baixo, sobe e avança até o alto com o orbe aceso, e o tronco recua:
lê como "vai lançar". Aprovada.
Tiro por orbe (`lab_mage_shot_side.jpg`): o cajado quase não sai do lugar nas seis poses; de lado não se distingue do
segurar. Pico 1,57 m/s passa o critério do QA, mas o olho não vê um gesto.

Correção (gameplay-engineer): no `shot`, usar só o trecho do `Spell_Simple_Shoot` em que o braço vai à frente (medir
com `tools/clip_probe.gd` a mão: o trecho com maior avanço da mão para frente) e tocá-lo em 0,17 s, com a mão andando
pelo menos 0,25 m à frente do peito no pico e voltando. Critério visual: numa folha de 6 quadros do tiro, a ponta do
cajado em duas posições claramente diferentes (à frente e de volta).

### 1.4 Besteiro, Sacerdote, Ancião (aprovado)

Ancião (`sheet_elder_cast.jpg`): de estátua de cajado erguido para um gesto de baixo para cima com o orbe acompanhando:
lê. O `summon` próprio ao erguer os mortos separa os dois ataques (pose armada 0,82 m). Sacerdote: igual ao antes, que
já lia. Besteiro: subir a besta ao ombro em 0,25 s e segurar com a mira é correto para quem atira; não há folha nova,
aprovado pelas medidas (6.1) e com o recuo do tiro (T5-19) ainda pendente.

### 1.5 Escudo: preparação (aprovado)

`sheet_guard_brace.jpg`: agachado atrás do escudo, a espada baixa, o corpo inclinado para o alvo. Era a melhor
preparação do jogo e continua; agora em três tempos.

### 1.6 Escudo e Cavaleiro: a investida (reprovado como forma)

`after/sheet_guard_charge.jpg`, `lab_guard_charge_side.jpg`, `lab_knight_charge_side.jpg`: o trecho 0,3 a 0,8 s do
`Shield_Dash_RM` é o fim do avanço da biblioteca. Nas seis poses o corpo sobe do agachado para em pé, o tronco fica a
prumo, o escudo vai da frente para o lado (Escudo) ou para trás e para fora (Cavaleiro) e a espada pende. Na corrida
que deveria ser o momento mais perigoso, a figura lê como alguém que endireita e anda. Antes era pior (o golpe de
espada no meio da corrida), mas a forma ainda não é a de uma investida de escudo.

Correção (gameplay-engineer, `tools/bake.gd`, `guard` e `knight`, `charge`):
- Tocar só o trecho em que o corpo ainda está baixo e o escudo à frente: `from` 0,3, `to` 0,45 (medir: parar antes da
  pose em que o tronco passa de 10 graus de inclinação para a frente para menos), em laço durante a corrida.
- Se o trecho curto não der pernas de corrida, alternativa: pernas do `Jog_Fwd` ou do `Running_A` e tronco e braço do
  escudo presos na última pose do `brace` (o mesmo mecanismo do `guard` de braço que o assado já usa), tronco inclinado
  15 a 25 graus para a frente.
- Critério objetivo em toda pose da `charge`: centro do escudo pelo menos 0,3 m à frente do peito (tamanho 1), tronco
  inclinado 12 graus ou mais para a frente, cabeça atrás da borda de cima do escudo.
- A recuperação `Idle_Shield_Break` (o escudo baixando, `lab_guard_recover_side.jpg`) está boa e fica.

### 1.7 Cavaleiro: preparação (aprovado)

`sheet_knight_brace.jpg`: de parado em pé (antes) para agachado de lado com o escudo redondo cobrindo o peito e a perna
de trás estendida, como quem vai empurrar. Lê bem e é diferente do Escudo pela silhueta (maior, escudo redondo).

### 1.8 Recuperações (aprovado)

Nenhuma pose parada mais de 0,28 s (antes 1,76 s no esqueleto). O Escudo baixando o escudo depois da investida mostra
cansaço e abre a janela de punir; é a leitura certa.

### 1.9 Morvath (aprovado)

`lab_morvath_dash_windup_side.jpg`: o corpo dobra baixo e para a frente com o gancho à frente, como um touro antes de
arrancar. `lab_morvath_blades_windup_side.jpg`: o gancho sobe por cima do ombro com as duas mãos e o tronco recua, como
quem vai arremessar. Antes as duas preparações eram a mesma guarda parada; agora são duas silhuetas opostas (uma baixa
e para a frente, outra alta e para trás). É a diferença que o jogador precisa. O dano da investida no contato do corpo e
o da foice na descida (`slash3:7`) corrigem o "golpe que chega antes do corpo".

Pendente, sem pedido novo: maldição com o mesmo gesto da invocação e as erupções paradas (T5-17, T5-18, P2).

### 1.10 Corrida do esqueleto (com ressalva)

`after/sheet_skeleton_walk.jpg` e `after/walk/skeleton_walk.jpg` contra `before/skeleton_run_side_24f.jpg`:

- Antes: tronco a prumo, pé de trás chutando à altura do quadril, quase sempre no ar. Gazela, como o PO disse.
- Depois: tronco curvado para a frente (13 a 17 graus), cabeça à frente do peito, braços soltos à frente, pés no chão
  em 15 de 20 poses. Lê como um morto-vivo que trota curvado e insistente: é fantasia sombria, não atleta. Respondo ao
  PO: **não é mais gazela.**
- Ressalva: o corpo baixou demais. Com o `plant` 0,65, em metade das poses os joelhos dobram quase em ângulo reto e a
  pelve fica perto da altura do joelho da pose parada; o esqueleto parece encolher ao correr e, em algumas poses, anda
  de cócoras (linha 1, quadros 1 a 3; linha 3, quadros 1 a 3 da folha `walk`). De cima, isso faz a figura correndo
  parecer menor que a parada. O pé de trás ainda sobe 30 cm, mas com o tronco curvado não incomoda.

Correção (gameplay-engineer, `tools/bake.gd`, `SOLDIER_JOG`): `plant` de 0,65 para 0,4 a 0,45 e conferir as medidas
do QA (pés no ar até 6 de 20 poses, tronco 8 a 17 graus). Critério de arte: o topo da cabeça no andar nunca abaixo de
90% da altura do `idle` (hoje, a olho, cerca de 82 a 85% nas poses mais baixas). Se o `plant` menor voltar a pôr os pés no
ar acima do critério, ficar com 0,5 e aceitar.

## 2. Telas de evento

### 2.1 Provação (com ressalva)

`ui/after_1080_trial.jpg`, `after_720_trial.jpg` contra `before_720_trial.jpg`. Melhorou muito na clareza:
- Subtítulo diz a regra ("A maldição começa agora. Vença as lutas e a Bênção fica com você até o fim da descida.").
- Cada carta separa o que se ganha ("Você recebe depois de 3 lutas", efeito em negrito, "e fica até o fim da descida")
  do que se carrega (faixa lilás "Você carrega nas próximas 3 lutas", nome e efeito). A palavra "Bênção" no lugar de
  "Provação" na linha da família está certa.
- O rodapé ("A vida já foi paga. Escolha uma carta para abrir as portas.") fecha a dúvida de antes.
- Paleta da casa: tinta escura, moldura de ouro velho, lilás acinzentado da maldição, azul da Rara. Cabe a 720.

Ressalvas:
1. O medalhão é o mesmo losango rachado nas três cartas (já era antes). É o ícone da Provação, não o da Bênção; as três
   cartas ficam iguais à distância e o olho não tem onde se apoiar para comparar. Correção (ui-ux-designer,
   `BoonCard.setup_trial`): no topo, o medalhão da Bênção (`BoonArt.medallion` ou `BoonIcon` do id, como na carta de
   Bênção comum) e o losango rachado pequeno (cerca de 30% do medalhão) encostado no canto de baixo à direita dele, como
   selo. Critério: numa captura a 720, as três cartas com medalhões diferentes.
2. Espaço morto entre "e fica até o fim da descida" e a faixa da maldição (cerca de 70 px a 1080). Correção: subir a
   faixa da maldição ou centrar o bloco do meio na altura livre; critério: vazio entre os dois blocos até 40 px a 1080.
3. "Você recebe depois de 3 lutas" e "Você carrega nas próximas 3 lutas" repetem o número; fica, porque tira a dúvida.

### 2.2 Placa da laje (com ressalva)

`ui/after_1080_slab.jpg`, `after_720_slab.jpg` (recortes no scratchpad da revisão): de "Provação / Custa 12 de vida"
para quatro linhas (título, "Pisar custa 12 de vida", "Uma Bênção forte, com uma maldição", "Para recusar, não pise").
O conteúdo está certo e responde o que o PO não entendia. A forma:
- O entrelinhamento é desigual: as linhas 2 e 3 quase se tocam e há um vão maior antes da 4.
- A 720 as linhas 3 e 4 têm cerca de 10 px de altura de minúscula; leem, mas no limite, e ficam sobre o fio de luz
  da coluna e o brilho dourado da laje.
- As linhas 3 e 4 no mesmo cinza lilás; a 4 é instrução e poderia ser menor.

Correção (ui-ux-designer, `DoorSign`): entrelinha fixa entre as linhas do corpo (1,15 da altura da fonte); linha 3 no
mesmo tamanho da 2; linha 4 a 85% e no cinza frio das palavras de grupo da loja. Pôr a placa acima da coluna de luz da
laje ou abrir um véu de tinta escura atrás das linhas 2 a 4 (alfa 0,45, cantos cortados como a faixa da carta).
Critério: contraste de 4,5:1 com o contorno em toda linha (o `DoorSign.contrast` já mede), minúscula de pelo menos 11 px
a 720, nenhum fio de luz atravessando as letras.

### 2.3 Selo da Provação no HUD (aprovado)

`ui/after_720_trial_seal.jpg`: losango com o 3 e "Mais mortos" acima do medalhão, pequeno, sem disputar com a sala.
As portas da câmara (Bênção, Mais vida, Mais magia) leem bem.

### 2.4 Altar (com ressalva)

`ui/after_1080_altar.jpg`, `after_720_poor_altar.jpg` contra `before_720_altar.jpg`. A estrutura "Você entrega / Você
recebe" com o antes e o depois ("Vida máxima: 30 para 20", "Ouro: 120 para 45") é exemplar: ninguém troca sem saber o
que perde. Sem recursos, a carta apagada com o porquê em rosa apagado ("Faltam 35 de ouro") está certa.

Ressalvas:
1. Medalhões chapados (círculo liso com um glifo branco), de outro estilo que os medalhões pintados das Bênçãos e que o
   `PsalmIcon` (tinta, aro de ouro velho e marfim). E dizem o contrário do que acontece: o coração cheio em "Vida por
   romã" lê como "ganhar vida", quando se perde vida; a gota em "Acender as velas" lê como água ou óleo, não chama.
   Correção (ui-ux-designer): desenhar os três no estilo do `PsalmIcon` (selo de tinta, aro de ouro velho): romã (fruto
   com coroa de sépalas) no lugar do coração, chama de vela de verdade (ponta fina, miolo marfim, borda de ouro velho) e,
   para seguir em frente, a divisa de porta ou um arco aberto em vez do losango cinza. Critério: nenhum ícone que, sem
   texto, diga "ganhar vida" numa troca que tira vida.
2. "Seguir em frente" diz "Nada / Nada" e o rodapé repete "Seguir em frente não custa nada". Trocar o rodapé por
   "Uma troca só. Escolha ou siga." ou retirá-lo.

## 3. Pedidos por responsável

| Id | Para | O quê | Prioridade |
|---|---|---|---|
| A-T5-1 | gameplay-engineer | Investida do Escudo e do Cavaleiro com o escudo à frente e o tronco inclinado (1.6) | P1 |
| A-T5-2 | gameplay-engineer | Corrida do esqueleto menos agachada, `plant` 0,4 a 0,5 (1.10) | P2 |
| A-T5-3 | gameplay-engineer | Preparação do corredor sem o joelho de flamingo, `from` 0,24 (1.2) | P2 |
| A-T5-4 | gameplay-engineer | Gesto do tiro do feiticeiro visível (1.3) | P2 |
| A-T5-5 | ui-ux-designer | Medalhão da Bênção na carta da Provação (2.1) | P1 |
| A-T5-6 | ui-ux-designer | Medalhões do Altar no estilo da casa e com o sentido certo (2.4) | P1 |
| A-T5-7 | ui-ux-designer | Placa da laje: entrelinha, tamanho e véu (2.2) | P2 |
| A-T5-8 | qa-performance | Vídeo na GPU a 60 qps da primeira sala (`--play --seed=2`), uma sala com Escudo e Cavaleiro e Morvath fases 1 e 3, para conferir as poses na câmera do jogo | antes do teste do PO |

## 4. Veredito

Aprovado para o teste do Daniel **com ressalva**: o pedido central (preparação física legível) foi atendido em quase
todas as figuras e a corrida deixou de ser gazela; nada aqui piora o que havia. Não bloqueia. A investida do Escudo e
do Cavaleiro (A-T5-1) e os medalhões das telas de evento (A-T5-5, A-T5-6) devem entrar na próxima versão, de preferência
antes do teste se couberem. Nenhuma avaliação aqui foi feita na câmera do jogo em movimento; o vídeo da GPU (A-T5-8) é o
que confirma. A aprovação artística final é do Daniel.

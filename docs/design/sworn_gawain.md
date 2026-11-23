# O chefe cavaleiro do jogo estudado: como a luta é montada e o que levamos para o nosso Cavaleiro

Estudo só de leitura, feito com o Daniel (dono do jogo, "só para verificar como foi feito e pegar ideias, sem copiar nada"). Mesmo método de
`sworn_numeros.md`: leitor UnityPy sobre os pacotes de dados, lidos apenas campos numéricos, tempos de linha do tempo, tipos de tarefa da árvore
de comportamento e nomes técnicos. Nada de textura, malha, áudio, animação, texto narrativo ou código foi exportado; nada foi escrito na pasta
do jogo. As pastas de trabalho e os dumps foram apagados no fim. Os nomes internos de habilidades dele não aparecem aqui: cada ataque tem um
rótulo descritivo nosso. Certeza: **[L]** lido direto num campo, **[D]** derivado de campos lidos (conta nossa), **[I]** inferido (hipótese).

## 0. Quem é, o que existe e o que não achei

- O chefe do bioma da floresta (a área dos pacotes `kingswood`, com a sala de descanso `wirralrest`) é o cavaleiro de machado da arena
  `gawainarenafinal`. O título "Butcher of Wirral" **não está em nenhum campo que consegui ler** (o texto fica em tabelas de localização
  que não abri); a ligação com a floresta vem do nome dos pacotes e da arena [D].
- Há **duas formas** no mesmo ponto de nascimento da arena (campo do ponto: "forma 1" e "forma verdadeira") [L]: o cavaleiro comum (6000
  de vida) e a **forma verdadeira** (5500 de vida, mais ataques). Também existe uma cópia da árvore para um modo de chefes em sequência (o
  pacote de correção traz a mesma árvore e as mesmas fases, só a vida igual a 6000) [L]. Quando a forma verdadeira entra (depois da morte
  da primeira? por dificuldade?) **não consegui ver** [I: segunda luta no mesmo lugar].
- Classes de comportamento nos metadados: quase tudo é "uma classe por habilidade" (salto com pancada de onda, onda no chão, convocação,
  erupção, golpe triplo em saltos, golpe mágico em ondas, pisão em círculo, machado invocado, machado giratório lançado, machado que volta,
  machado giratório de entidade) [L, só os nomes de tipo]. Cada habilidade tem a classe de comportamento, uma linha do tempo e uma ficha de
  números. A árvore que escolhe entre elas usa tarefas genéricas de um editor de árvores de comportamento (seletor por utilidade, sequência,
  cooldown, checagem de vida, comparação de inteiro, tabela de habilidades com peso) e algumas tarefas próprias do estúdio
  (rodar habilidade, tabela com peso, definir cooldowns iniciais, saltar para uma posição, contar adversários vivos) [L].

## 1. Ficha do corpo

| Campo | Cavaleiro (forma 1) | Forma verdadeira |
|---|---|---|
| Vida | 6000 [L] | 5500 [L] |
| Escudo, redução de dano | 0 e 0 [L] | 0 e 0 [L] |
| Velocidade de caminhada | 6,0 (igual à do herói leve) [L] | 6,0 [L] |
| Aceleração e desaceleração | 100 e 100 (para e anda na hora) [L] | 100 e 100 [L] |
| Postura (poise) | 800 (13% da vida) [L, D] | 1000 (18% da vida) [L, D] |
| Golpes para congelar | 25 [L] | 25 [L] |
| Imune a empurrão | sim [L] | sim [L] |
| Imune a atordoamento | não [L] | não [L] |
| Bônus de costas | 0,5, arco de 60 graus (igual aos comuns) [L] | idem [L] |
| Atordoamento ao quebrar a postura | 3,5 s [L], animação de "recuperar o fôlego" | 3,5 s [L] |
| Resistência crescente a atordoar | x1,25 a cada atordoamento seguinte [L] | idem [L] |
| Distância de perseguição | de 2 a 30 m (parâmetros da perseguição) [L] | idem [L] |

- O atordoamento **não tem imunidade em nenhum quadro das linhas do tempo**: nenhuma faixa de "invulnerável" ou de "armadura" em qualquer
  habilidade [L, ausência]. O que existe é troca de **camada de colisão** nos saltos (a camada que ignora o jogador no salto com pancada de
  onda, a que os outros inimigos ignoram nos saltos de golpe de machado) [L]. Não sei se o golpe do herói acerta durante o voo [I: acerta,
  mas ele fica no ar e longe].
- Sem bônus de vida por jogador na ficha do corpo; a escala por jogador está nas contagens das habilidades (erupção e ondas: +1 por jogador
  extra) [L].
- Recompensa: 5 de ouro com 40% de chance (valor genérico de inimigo) e uma moeda de chefe [L, valores genéricos].

## 2. A árvore de comportamento (o coração da luta)

Estrutura [L]: um laço infinito com um **seletor por utilidade**; as opções vão da mais prioritária (em cima) para a menos (embaixo). Cada
opção é uma sequência: condições (fase, cooldown, distância) e depois uma "sequência de ação" que trava o seletor (uma trava de ação),
então **só uma habilidade roda por vez** e nenhuma é interrompida pela escolha seguinte. O que acontece quando duas opções valem ao mesmo
tempo depende da regra do seletor de utilidade, que **não decodifiquei**; a leitura natural é "a primeira da lista que passa" [I]. Se
nenhuma opção passa, ele **persegue** o jogador (sub-árvore de perseguição com alcance de 2 a 30 m) [L].

### 2.1 Cavaleiro (forma 1), na ordem da lista

| Ordem | Opção | Condição | Cooldown | Primeiro uso |
|---|---|---|---|---|
| 1 | Entrada: provocação inicial (uma vez) | no começo | n/a | n/a |
| 2 | Transição para a fase 2 + rugido | vida abaixo de 80% e fase 1 | n/a | n/a |
| 3 | Transição para a fase 3 (sem rugido) | vida abaixo de 60% e fase 2 | n/a | n/a |
| 4 | Transição para a fase 4 + rugido | vida abaixo de 40% e fase 3 | n/a | n/a |
| 5 | Erupções no chão | fase 4 ou mais | 20 s | a partir de 10 s |
| 6 | Convocar reforços | fase 3 ou mais, e poucos reforços vivos (limite 4) | 30 s | a partir de 10 s |
| 7 | Ondas no chão | fase 2 ou mais | 15 s | a partir de 10 s |
| 8 | Salto com pancada de onda | sempre | 10 s | a partir de 5 s |
| 9 | Giro louco | jogador a até 6 m | 10 s | a partir de 6 s |
| 10 | Ataque básico, vez do golpe de machado em salto | jogador a até 12 m e contador de básico igual a 0 | sem | n/a |
| 11 | Ataque básico, vez do projétil | jogador a até 12 m e contador de básico igual a 1 | sem | n/a |
| 12 | Perseguir | nenhuma das anteriores | n/a | n/a |

[L] para valores e ordem. Observações:
- As fases só **somam** habilidades (a condição é "fase igual ou maior"): na fase 4 ele usa tudo. As transições são sequenciais (a fase 3
  só abre depois da 2), então um golpe grande que tira 30% de vida de uma vez passa por uma transição por vez, cada uma com sua pausa [D].
- Os cooldowns **iniciais** diferem (5, 10, 10, 10, 6 s) para a abertura não ser sempre igual e para um ataque não coincidir com o outro
  [L]. O cooldown parece contar a partir do início do ataque, então o tempo entre ataques do mesmo tipo é o valor [I].
- O básico **alterna** salto de machado e projétil: contador 0 faz o salto e muda para 1; contador 1 faz o projétil e volta para 0 [L].
  É o enchimento entre os especiais.
- A trava de ação tem um campo de 1,0 na sequência de ação; provável pausa entre ações (um respiro) [I].
- Pausa implícita: se o jogador está longe (mais de 12 m) só sobram os especiais sem condição de distância (salto com onda, ondas,
  erupções, convocação) e a perseguição [D].

### 2.2 Forma verdadeira

Mesmas fases (80, 60 e 40% da vida; rugido na transição para a fase 2 e para a 4, nenhum na 3) e a mesma lógica, com mais tarefas [L]:

| Ordem | Opção | Condição | Cooldown | Primeiro uso |
|---|---|---|---|---|
| 1 a 3 | Transições de fase 2, 3 e 4 (rugido na 2 e na 4; na 3 liga o golpe triplo no sorteio com peso 4) | vida abaixo de 80, 60 e 40% | n/a | n/a |
| 4 | Machado invocado que dispara erupções | fase 4 | 20 s | a partir de 10 s |
| 5 | Convocar 1 cavaleiro de martelo | fase 3 ou mais, poucos reforços vivos (4) | **50 s** | a partir de 10 s |
| 6 | Ondas no chão | fase 2 ou mais | 15 s | a partir de 10 s |
| 7 | Salto com pancada de onda (com anel); antes salta para uma posição escolhida (3 a 6 m, cone de 45 graus) | sempre | 15 s | a partir de 5 s |
| 8 | Machado giratório lançado | sempre | 30 s | a partir de 15 s |
| 9 | Sorteio entre pisão (peso 1,5, valor extra 10) e giro rápido (peso 2, valor extra 15) | jogador a até 4 m | 15 s | a partir de 1 s |
| 10 | Sorteio de golpe de machado em salto: simples (peso 3), triplo (peso 0, sobe para 4 na fase 3), simples com anel (peso 1) | jogador a até 8 m, contador de básico 0 | sorteio com 0,5 s | a partir de 0,5 s |
| 11 | Sorteio de projétil (peso 3) ou golpe mágico em ondas (peso 2, valor extra 8) | jogador a até 12 m, contador de básico 1 | sorteio com 0,5 s | a partir de 7 s |
| 12 | Perseguir | nenhuma | n/a | n/a |

[L] para tudo; o papel dos dois valores de cada linha do sorteio é [I]: o segundo valor é o peso, o primeiro parece o cooldown próprio do
ataque (10, 15 e 8 s). Cooldowns iniciais da forma verdadeira: 5, 10, 10, 10, 1, 0,5, 7, 15 s [L].

## 3. Os ataques, um a um (forma 1 primeiro)

Tempos em segundos desde o início da linha do tempo da habilidade. "Aviso" = do início até o dano. O dano base aparece na ficha da
habilidade; o dano de projéteis e anéis vem de campos próprios. Áreas são as formas de hitbox lidas dos componentes (esfera, caixa), **antes**
de aplicar a escala dos objetos, então os raios são indicativos [I]. Para desviar, o que vale é a esquiva do herói (invulnerável no clipe
inteiro, 0,2 s no leve; `sworn_numeros.md`).

### 3.1 Salto com pancada de onda ("o salto grande")
- Duração total 2,77 s [L]. Salta (0 a 0,53 s), fica no ar 0,53 a 1,48 s numa camada que ignora o jogador, **trava o alvo em 0,75 s**,
  pousa e dá o dano em **1,63 s** (aviso útil de 1,6 s), recuperação até 2,77 s (1,1 s) [L].
- Dano 15 na pancada [L]; **anel que se expande** a partir do pouso: raio inicial 1,2 m, velocidade 7,5 m/s, até 22 m (a arena inteira em
  2,8 s), espessura de 0,25 m e dano 7 (a cópia visual do anel tem 0,75 m) [L; qual anel é o do dano é [I]].
- Escolha do pouso: entre 4 e 10 m dele, pontuado para ficar perto do jogador; distância ideal 6 m do alvo, 1 m de folga das bordas [L, I].
- Como se evita: sair do ponto marcado e **atravessar o anel com a esquiva** (a janela é a espessura de 0,25 m a 7,5 m/s, ou seja 33 ms,
  então o anel é um teste de timing de esquiva, não de correr) [D]. Cooldown 10 s (15 s na forma verdadeira).

### 3.2 Golpe de machado em salto (o básico de perto)
- 2,25 s [L]. Alvo travado em 0,17 s; no ar de 0,33 a 0,75 s; golpe de pouso por volta de 0,83 s; **recupera o fôlego** de 1,5 a 2,25 s
  (cerca de 0,73 s de janela de ataque do herói) [L].
- Dano 15 [L]. Alcance de salto máximo 7 m, busca de alvo 12 m, desvio aleatório de até 0,5 m no pouso [L]. Esfera de pouso r 2 (corpo do
  salto r 1) [L, escala I].
- Aviso total ao pouso 0,83 s (curto), compensado por recuperação aberta. Faz par com o projétil no básico alternado.
- Forma verdadeira: simples (2,25 s), **triplo** (3 saltos de 1,5 s em 1,5 s, os alvos travados em 0, 1,47 e 2,97 s, no ar 0,33, 1,83 e
  3,33 s, recuperação de 0,73 s no fim, total cerca de 6 s) e versões **com anel** no fim (o anel nasce em 1,37 s no simples e em 4,35 s no
  triplo) [L]. Dano 15 em todos.

### 3.3 Projétil
- 2,52 s [L]. O projétil sai em 0,17 s; marca de "ativado" em 0,67 s [L]. Dano 10, velocidade 20 m/s, alcance 22 m, esfera de r 1,5, uma bola
  por disparo (dois sinais de disparo, em 0,17 e 0,33 s, sugerem dois disparos [I]) [L].
- É o único ataque feito para quem está longe. Esquiva ou lateral (a bola é lenta frente à esquiva do herói).

### 3.4 Giro louco
- Cerca de 6,1 s [L]. **0,83 s parado** em preparo, depois gira por cerca de 3 s avançando para o jogador, a 50% e depois 30% da
  velocidade de caminhada (3 e 1,8 m/s), com 13 pulsos de efeito a cada 0,25 s (0,83 a 3,83 s) e **5 janelas de dano repetido** (1,35 s,
  1,88 s, 2,43 s, 2,97 s, 3,5 s) [L]. Esfera r 4 em volta dele [L, escala I]. Dano 10 por pancada [L].
- Termina com **cerca de 1,3 s de "recuperar o fôlego"** (4,8 a 6,1 s) [L]: a punição.
- Só é escolhido com o jogador a até 6 m (é a resposta dele a quem fica colado) [L]. Cooldown 10 s.

### 3.5 Ondas no chão (fase 2 em diante)
- 3,8 s [L]. Marca "ativado" em 0,87 s [L]. **4 projéteis** de base (0 a mais por jogador na ficha), com uma **zona morta de 135 graus**
  (um arco sem onda) [L]. Cada onda: velocidade 5 m/s, vive 2,5 s (alcance 12,5 m), **persegue devagar** (giro 0,04, começa a perseguir
  depois de 0,5 s), dano 7; a pancada de saída tem dano 15 [L]. Esfera de projétil r 1,5 [L, escala I].
- Como se evita: as ondas são lentas (5 m/s contra os 6 do herói), então basta andar de lado e fugir do arco; a perseguição fraca pune
  quem fica parado [D]. Cooldown 15 s.

### 3.6 Convocação (fase 3 em diante)
- 1,5 s [L]; reforços nascem a partir de 0,42 s, **0,25 s entre cada**, a 3 a 12 m dele (20 tentativas de achar chão válido), e **morrem
  quando o chefe morre** [L]. Número: 3 por convocação [L]. Lista de sorteio: 1 martelador e 2 arremessadores (a mesma lista repetida
  duas vezes; se é sorteio com reposição ou combinação fixa, não vi) [L, I].
- Martelador (comum): vida 250, velocidade 2,25, postura 125, 6 golpes para congelar [L]. Arremessador: vida 150, velocidade 2,5, postura
  75, 4 golpes para congelar [L]. Danos deles: um ataque de martelo com dano nominal 1 (o dano real vem da entidade, não lido) [L].
- Só roda se há poucos reforços vivos (limite 4), então **nunca acumula** [L, I]. Cooldown 30 s. Forma verdadeira: **1 cavaleiro de martelo**
  por convocação (500 de vida, 250 de postura, 15 golpes para congelar, velocidade 3,5; ataques: anel de pancada 15 e giro de martelo 10) [L],
  cooldown 50 s.

### 3.7 Erupções (fase 4)
- 6,75 s de ação (mais um descanso: ele fica parado 8 s no total) [L]. Faz **3 salvas**: marcação dos alvos em 0,58, 2,73 e 4,77 s, dano em
  1,43, 3,70 e 5,87 s, ou seja **avisos de 0,85, 0,97 e 1,10 s** [L].
- Por salva: 10 pontos (+1 por jogador extra), cada um com círculo de aviso de r 2,5 m que enche em 1,0 s, dano 10 [L]. A escolha dos
  pontos favorece **lugares a 1,5 m do jogador** (não em cima dele), **espaçados** (ideal 3 m entre pontos, influência até 6 m) e a 0,5 m da
  borda [L].
- Pressão de posição: obriga a mexer sem que a posição do jogador seja o centro de nenhum círculo. Cooldown 20 s.
- Forma verdadeira: ele **crava o machado no chão** e o machado dispara **4 salvas** (avisos em 1,5, 3,5, 5,5 e 7,5 s; dano em 2,5, 4,5, 6,5
  e 8,5 s; 1,0 s de aviso, a cada 2 s, total 10 s), dano 10 [L]. Enquanto isso ele **continua em jogo** (as outras opções seguem na lista) [I].

### 3.8 Provocações (rugidos)
- Provocação inicial 1,82 s (cena da entrada); rugido das fases 1,78 s [L]. Sem dano (máscara de acerto 0, dano nominal 1) e **sem troca
  de camada**: ele continua atingível e fica enraizado [L]. É uma **janela de respiro e de dano grátis** no meio da luta, e aviso de que a
  fase mudou [D].

### 3.9 Atordoado
- Quando a postura quebra: 3,5 s "recuperando o fôlego" (a mesma animação das recuperações) [L].

### 3.10 Ataques só da forma verdadeira
- **Golpe mágico em ondas**: golpe de 0,7 s (dano 10), depois **3 ondas de tremores no chão** a cada 0,2 s, avançando para a frente com
  4 m entre tremores e entre ondas, começando a 3 m, com 1, 2 e 3 tremores por onda (a forma de leque se alarga), dano 10, sinal de
  disparo em 1,7 s [L]. Só a 12 m ou menos.
- **Pisão em círculo ("pisão")**: 1,0 s, dano em 0,17 s (muito rápido, só a 4 m ou menos), esfera r 3 em volta dele, dano 10, mais um
  anel mágico em 0,67 s [L, I].
- **Giro rápido**: cerca de 2,2 s, 10 de dano, avança 0,4 s; resposta curta ao jogador colado [L].
- **Machado giratório lançado**: ele lança o machado em 0,67 s; o machado **orbita num raio de 8 m por cerca de 10,8 s** com dano 10 e
  uma janela de dano repetido a cada 0,5 s, depois volta (11,75 a 12,25 s) [L]. Cooldown 30 s. É um perigo móvel que fica na arena
  enquanto ele luta [I]. Existe também uma versão que volta (dano 10, 8 m) que **não está na árvore** (conteúdo sem uso) [L].
- **Machado invocado**: ver 3.7.
- **Reforço** de apenas 1 cavaleiro (3.6).
- Os outros conteúdos sem uso lidos: um golpe duplo de machado com pancada no chão (4,2 s) e um golpe de lado (2,5 s), e uma ativação de
  "montes de ossos" que não aparece na árvore (a convocação usa o ponto de nascimento comum) [L].

### 3.11 Mapa de dano
- Dano por acerto: 7 (onda e anel), 10 (projétil, giro, erupção, tremores), 15 (salto, pancada de onda, golpe em salto), contra herói leve
  de **50 de vida** e pesado de 75 [L, `sworn_numeros.md`]: o herói leve cai com 4 a 7 acertos, o pesado com 5 a 8 [D]. Todos os valores são
  da escala normal; os níveis de dificuldade multiplicam dano por 0,85 a 2,0 [L, `sworn_numeros.md`].

## 4. Arena

- Caixa de malha de navegação do jogador: centro (7, 1, -11), meia extensão (11,55, 2,05, 14,55), ou seja cerca de **23,1 x 29,1 m**
  contando margens; pelos pontos de nascimento e pelas armadilhas, a área jogável é cerca de **19 x 21 m** (x de -2,5 a 16,5, z de 1,5 a
  -19,5) [L, D]. É maior que as nossas arenas de combate comuns (a medir) [I].
- **Jogadores nascem no extremo norte** (cerca de 6,5, 1,3) e o **chefe nasce 22 m ao sul** (6,4, -21,3), fora do quadrado das armadilhas,
  então a luta abre com travessia e provocação [L, D].
- **12 armadilhas de espetos de 3 x 3 m, em L nos quatro cantos** (em x de -1 e 2, ou de 12 e 15; em z de 0 e -3, ou de -15 e -18) [L].
  Espeta ao pisar: placa desce em 0,07 s, espetos sobem de 0,07 a 0,33 s, descem em 0,33 s e a placa volta em 1,65 s (reativa em cerca de
  1,9 s) [L]. O dano da armadilha **não li**. Mantém o jogador longe dos cantos, onde ele fugiria das ondas e das erupções [I].
- 5 pontos de totem de bônus (nascem em um evento próprio), 9 pontos de nascimento de combate numa grade de 5 m (x -5 a 5, z -5 a -15), 48
  pontos de nascimento de reforços [L]. Chão de terra 100 x 100 com uma área de queda abaixo (volume que mata, 100 x 5 x 100) [L]: bordas
  abertas, sem paredes, com cachoeiras e pilares só de enfeite [L, I].
- Sem armadilhas ligadas ao chefe (não há peça de arena que ele ative nem que mude por fase) [L, ausência].

## 5. Duração da luta

- Vida 6000 (forma 1). Dano por segundo do herói em sequência: 33 a 65, mediana 40 (`sworn_numeros.md`). Com o chefe indisponível metade
  do tempo (saltos, ondas, giros longe), o dano efetivo cai para cerca de 20 a 30 por segundo: **3,3 a 5 minutos sem melhorias** [D].
  Com as melhorias de uma descida (multiplicador típico de 1,5 a 2,5 vezes) cai para **1,5 a 3 minutos** [I].
- Ritmo: cerca de um ataque a cada 3 a 4 s com 70% de uso de ação (ataques de 2,2 a 3,8 s, mais perseguição e pausas) [D].
- Fases por vida: 6000 a 4800 (fase 1), 4800 a 3600 (fase 2), 3600 a 2400 (fase 3), 2400 a 0 (fase 4) [D]. Cada fase dura cerca de 20% da
  luta, a última 40% [D].
- Atordoamento: postura 800 e 25 golpes: o herói quebra a postura a cada cerca de 25 golpes (0,5 a 1 min de combate seguido), 3,5 s de
  janela cada, e a resistência cresce x1,25, então se espera 2 a 4 quebras por luta [I].
- Forma verdadeira: 5500 de vida, ataques adicionais, ritmo parecido [D, I].

## 6. O que não consegui ver

- A **regra do seletor por utilidade** (se escolhe a primeira, a de maior pontuação ou sorteia) e o significado dos dois inteiros 3 e 3
  do seletor [não lido]. O 1,0 da sequência de ação. Os inteiros extras de "rodar habilidade" (valem 2 e 2 nas habilidades de ataque e 0 e 0
  nas provocações e na convocação).
- Para onde cada **sinal** da linha do tempo aponta (ligar e desligar o hitbox, tremor de câmera, efeito): os sinais apontam para ativos de
  outro pacote; só os marcadores de "ativado" e "alvo travado" foram lidos. A **forma real** do hitbox em cada quadro (só as formas dos
  colliders e a escala não aplicada).
- O **tipo e o valor dos modificadores de movimento** das faixas de estatística (tipo 2 parece "fixar velocidade em x vezes"): usei só a
  leitura "valor 0 = parado" [I].
- O **dano das armadilhas**, o dano real dos reforços (nas entidades), a fórmula de postura contra dano, o gatilho da forma verdadeira e a
  dificuldade (os multiplicadores gerais estão em `sworn_numeros.md`), a cena de entrada e a de morte, o texto do título e as falas.
- O tratamento de "ameaça" (mira entre vários jogadores) e o co-op (não relevante).

## Princípios para o nosso Cavaleiro

Ideias como princípios, sem nomes nem conteúdo copiados. A escala é a nossa (herói do Guerreiro, esquiva, vida) e se ajusta com o robô.

1. **Luta em quatro faixas de vida (80, 60, 40%) em que cada faixa só soma um verbo.** Cada limiar liga uma habilidade nova de forma
   cumulativa e vem com uma pausa curta (rugido de cerca de 1,8 s, sem dano, ele continua atingível). A pausa serve de respiro, de aviso e
   de bônus de dano grátis; o jogador entende que a luta mudou sem texto.
2. **Lista de prioridade com cooldowns, uma ação por vez.** Uma lista fixa de opções (as raras e caras em cima), cada uma com condição de
   fase, cooldown e, às vezes, distância; um ataque básico que **alterna** corpo a corpo e à distância preenche o espaço entre os
   especiais; sem opção válida, persegue. Ninguém é interrompido, então toda leitura é justa. Em dado, não em código.
3. **Cooldowns iniciais diferentes e escalonados** (5, 10, 10, 10, 6 s) para a abertura variar e ninguém ver dois especiais juntos.
4. **Distância escolhe a resposta.** Colado, ele usa a resposta de perto (giro com preparo parado de 0,8 s e fechamento de 1,3 s); longe, o
   projétil; no meio, salta. O jogador nunca fica "livre" na posição segura: cada distância tem uma resposta.
5. **Duas cadências de aviso.** Rápido (perto de 0,8 s) com recuperação aberta de 0,7 s; lento e grande (1,6 s) com recuperação de 1,1 s e
   uma consequência que se estende (anel). Aviso longo exige efeito maior; aviso curto exige punição sólida (a janela de "recuperar o
   fôlego"). Toda sequência longa termina em fôlego, nunca em esquiva livre.
6. **Anel que se expande a 7,5 m/s e fino (0,25 m) como teste de esquiva**, não de corrida: a única defesa é a esquiva na hora. Combina
   bem com o nosso foco (a esquiva é o que eles mais gostam). Um anel por salto grande, no máximo, e nunca em cima de outro perigo.
7. **Círculos no chão que não caem em cima do jogador**: o ponto ideal fica a cerca de 1,5 m dele e espaçado dos outros em 3 m, com aviso
   de 1,0 s e 3 salvas em sequência. O jogador se mexe sem ser a mira; o círculo de r 2,5 m é grande o bastante para parecer justo.
8. **Projéteis lentos e que perseguem pouco** (5 m/s, giro baixo, começo atrasado de 0,5 s) contra o herói a 6 m/s: ameaçam quem para,
   perdoam quem anda de lado. Um arco sem projétil (zona morta de 135 graus) dá uma saída clara.
9. **Reforços pequenos e com teto.** Três por vez (um forte, dois fracos), nascendo em volta a 0,25 s uns dos outros, **nunca acumulam**
   (só convoca com poucos vivos), somem quando o chefe morre. O chefe deixa de ser o único inimigo sem virar horda; o cooldown longo (30 s)
   e a regra de contagem protegem o ritmo.
10. **Postura própria do chefe** (cerca de 13% da vida, imune a empurrão, 25 golpes), com atordoamento de 3,5 s e **resistência crescente**
    (x1,25) a cada quebra: o jogador pode abrir a luta, mas não repetir a mesma quebra. Atordoar vale mais que causar dano.
11. **Dano em três degraus** (7, 10, 15) contra 50 a 75 de vida do herói, ou seja 4 a 8 acertos para derrubar; os efeitos que se repetem
    (giro, machado orbital) acertam de novo só em janelas de 0,5 s, evitando derreter em um quadro.
12. **Chefe com velocidade igual à do herói e parado nos ataques**: ele nunca "ganha" na corrida e nunca anda enquanto avisa. Perseguição
    de 2 a 30 m.
13. **Arena grande aberta com perigos só nos cantos** (L de 3 peças nos 4 cantos), pontos de nascimento do chefe e do jogador em
    **extremos opostos** (22 m), de forma que o começo é uma travessia curta e uma provocação. Nenhuma peça de arena muda por fase: toda a
    variação sai do chefe.
14. **Forma final opcional**: a segunda forma não precisa de arte nova; ela soma verbos (golpe triplo em saltos, machado orbital, pisão,
    ondas de tremores) com sorteio por peso e liga ataques no meio da luta por **mudar o peso** (de 0 para 4). Útil para rejogabilidade.
15. **Duração alvo**: 2 a 4 minutos com a vida em quatro faixas de cerca de 20% e a última de 40%; aviso para o robô de equilíbrio medir.

Aplicação ao nosso Cavaleiro (sem copiar): ver `docs/design/` (guardiões) e o item de backlog do Cavaleiro; os números acima são faixas
para o `balance-designer` ajustar com o robô de 12 sementes, não valores a copiar.

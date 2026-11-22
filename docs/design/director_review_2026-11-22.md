# Análise do Diretor do Jogo: combate, 42 Bênçãos, Elos e Lotes 8 a 10 (2026-11-22)

Resposta à diretriz do PO de 2026-11-22. **Só análise: nada foi implementado.** Commit lido: `ca34533` (confirmado, é o último do remoto).
Cada afirmação traz a fonte: [C] lido no código ou no dado, [M] medido (24 partidas do robô de 0,25 s, 12 novato e 12 evoluído, com este
commit), [E] estimado em simulação simples, [O] opinião de design. Robô não é jogador: serve para comparar versões, não para dizer se é divertido.

## 0. Sobre a diretriz em si
**Mantenho**: seis Bênçãos por anjo, qualidade antes de quantidade, assinatura perceptível sem abrir menu, ações que conversam, Elo que não
seja soma de bônus, sem barra nova, sem heróis nem anjos novos. É a direção certa.

**Corrijo, porque não bate com o jogo:**
| A diretriz diz | O que existe [C] |
|---|---|
| Mouse direito é "Ataque Pesado" de impacto e ruptura | É a **Onda de Luz**: rajada à distância, 35 de dano, 6 m, atravessa, 12 de Magia (decisão do PO de 21/11). Não é golpe de espada. **Conflito central, ver 2.2** |
| Esquiva vira Corte Veloz (seções 4.1, 5, build A) | **Não existe mais**: virou a Investida (E) em 21/11; `tree.dodge` está vazio. `warrior_spec.md` está velho; vale o topo de `heroes/guerreiro.md` |
| Cinco ações e a esquiva | Há uma sexta: o **Ômega** (segurar o ataque 0,8 s, 20 de Magia, 160 de dano). Nenhuma das 42 cartas foi desenhada para ele |
| "Validar as 42 Bênçãos existentes" | No jogo há 63 e 12 Elos. Das 42: 28 ids existem (muitos com efeito novo no papel), 4 mudam de botão, 10 são novas |
| Crítico da Marca | Não há sorte: marcado leva +25% de dano sempre, e `crit_pct` soma a isso. Trocar a palavra |
| Prólogo e tutorial existentes | Não há tutorial na partida; só o Como Jogar no título. A primeira descida abre direto |
| "Coroa do Ancião" | Era **contorno** do Ancião (amarelo por dentro do manto, GR-6). Não há coroa no plano |
| "Soldados que desaparecem no chão" | Defeito de leitura: têm a **luma do chão** (43 contra 43, GR-5). Não é efeito desejado |
| "Sete Ultimates" | São sete Bênçãos **do** Shift. Ultimates há duas: Corte do Juízo (Maestria 6) e Voragem (10) |
| Jogadores simulados iniciantes | É o robô sem melhorias. Nenhuma pessoa foi medida |

**Simplificaria**: 12 entregáveis e 12 campos por história é mais papel do que o time lê. Este documento cobre os doze em um só lugar.

## 1. Diagnóstico do combate
**Funciona**: combo 20/25/60 plantado, com peso crescente [C]; Quarto Corte, Passo Encadeado e Golpe sem Fim implementados e com teste
(`GiftState`, `test_warrior_talents`) [C]; Magia que só volta batendo (giro +2, Investida +2 por inimigo) [C].

**Não funciona:**
1. **Só uma ação importa** [M]: ataque 60% do dano do novato (51% do evoluído), especial 10%, Investida 6 a 8%, Ômega 2 a 4%, Brado 2 a 3%.
   60% é aceitável para espada; o problema é que nada manda usar o resto.
2. **Ômega quase não existe** [M]: 4,7 tentativas por partida, e 34 a 37% são cortadas por golpe levado.
3. **Ultimate: zero usos em 24 partidas** [M], porque a régua não abre a Maestria. O Shift nunca foi medido, e 7 das 42 cartas não aparecem para o novato.
4. **A regra "nenhum golpe atordoa" tem um furo** [C]: gelo não passa pelo `StunRule`. Golpe de Geada congela a **cada corte** do ataque, ou seja,
   é o atordoamento universal que o PO mandou tirar.
5. **Três anjos apagam diante do chefe** [C]: Morvath é imune a gelo (`_freeze`); Fraqueza não vale nos ataques de Morvath nem no que é roteiro do guardião
   (`_weaken`); empurrão não move blindado. Geada, Véu e Maré ficam só com o dano justamente na luta que decide a partida.
6. **A build chega tarde** [M]: novato pega 2 a 6 Bênçãos (mediana 3,5), evoluído 2 a 7 (5,5). **0 Elos e 0 Salmos em 24 partidas.**

## 2. As cinco ações, o Ômega e a esquiva
| Ação | Papel hoje | Recomendo |
|---|---|---|
| Ataque | 60% do dano, dá Magia no giro | Manter os números. É a base |
| Ômega | Golpe de 160, raro | Manter; é o prêmio da Magia. O Brado deveria protegê-lo (2.3) |
| Especial | Rajada à distância | Dar função: **quebrar blindagem** (2.2) |
| Brado (Q) | +15% de velocidade, 15% menos dano, 5 s | Absorver **um** golpe (2.3) |
| Investida (E) | Estocada de 35 que leva 4 m, devolve Magia | Manter; **sem** proteção contra dano [C], o que já é o risco certo |
| Ultimate | 2 opções, abrem na Maestria | Medir antes de mexer |
| Esquiva | 5,6 m, protegida 0,3 s, 1 carga | Não mexer |

### 2.1 Combo
Não criar bônus novo por completar o combo: ele **já** devolve Magia, e Lâmina Faminta já liga o giro ao Ômega barato. Mais um prêmio o tornaria obrigatório.

### 2.2 Especial e ruptura: o conflito a decidir
A diretriz quer um Pesado corpo a corpo; o jogo tem uma rajada. Opções: **(a)** manter a rajada e dar a ela a ruptura; (b) trocar por um golpe pesado.
**Recomendo (a)**: (b) refaz animação, Dons, Encantos, Forja, um Salmo e sete Bênçãos. E **a ruptura já existe**: é a blindagem das elites (barra amarela, que ao
quebrar abre 2,5 s de janela). Basta o especial tirar **+50% da blindagem**, a Investida +25% e o ataque o que tira hoje. Sem barra nova, um número por etiqueta.
Isso responde "por que apertar o direito": abre a janela em que o combo e o Ômega rendem.

### 2.3 Brado
Uma mudança só: **absorve um golpe por até 5 s** (o código do escudo já existe). Motivos: hoje perder um golpe custa 30 a 40% da vida e corta 1 em cada 3 Ômegas.
Brado e depois Ômega vira a sequência segura. Recuperar Magia, ruptura e bônus por abate ficam com as Bênçãos. Com isso a Shomael precisa de menos escudo (seção 3).

### 2.4 Interações
| Sequência | Como | Situação | Vale entrar? |
|---|---|---|---|
| Combo e Ômega | giro dá Magia; Lâmina Faminta corta o custo | existe | Não mexer |
| Investida e combo | Passo Encadeado; Encanto Retorno do Corte | existe, por Dom e Encanto | Não mexer |
| **Especial e combo** | a onda quebra a blindagem, 2,5 s de janela | quase existe | **Sim, 10A.** Aviso: estalo e lasca no peito em 75, 50 e 25% |
| **Brado e Ômega** | o golpe absorvido não corta a carga | novo, pequeno | **Sim, 10A.** Risco: ficar obrigatório; a recarga de 12 s segura |
| **Investida em alvo marcado** | abate devolve a Investida | novo, é a carta da Marca | **Sim, 8B.** Só com a Bênção |
| **Giro congela, onda estilhaça** | ações diferentes preparam e cobram | novo, são as cartas da Geada | **Sim, 8B** |
| **Brado puxa, giro acerta o grupo** | a carta da Maré troca empurrar por puxar | novo | **Sim, 8B.** Risco: puxar demais sobre 30 de vida |
| Esquiva por aviso e Ômega grátis | Salmo da Sentinela | existe | Não mexer |

## 3. As 42 Bênçãos, uma a uma
Três erros técnicos a corrigir antes de programar (o papel promete o que o código não faz) [C]:
- **`cast_size_pct` não aumenta o Brado** (só o círculo antigo, que saiu do kit, e a Voragem): afeta `circulo_geada`, `circulo_firme`, `circulo_veu` e
  `circulo_marca`. Usar `reach_pct` com etiqueta `cast`. **A `circulo_firme` de hoje já tem metade do texto sem efeito por isso.**
- **`heal_on_kill` não tem etiqueta**: `passo_radiante` curaria em **qualquer** abate, não só nos da Investida. Passar a ler a etiqueta.
- **`max_hp` na carta do ultimate**: `ultimo_firme` daria +20 de vida (até +50 lendária) a um herói de 30, sem apertar nada. Tirar.

M = manter, A = ajustar. Nenhuma precisa sair: o total de 42 fica.
| Anjo | Ataque | Especial | Brado | Investida | Ultimate | Esquiva |
|---|---|---|---|---|---|---|
| **Sarael** | M | A: só o chão em brasa (hoje queima duas vezes) | A: **detona** a queimadura de quem já arde, em vez de queimar de novo | M | M | M |
| **Nivael** | A: só o **giro** congela (0,8 s), não cada corte | A: **estilhaça** congelados (+X%), em vez de congelar | A: congela em volta (sem o anel extra; alcance no lugar do tamanho) | M | M | A: flocos **atrasam**; congelar a cada 0,5 s prende tudo |
| **Lumael** | M (um número puro por anjo é bom) | M | M | A: cura só no abate da Investida, teto de 3 por sala | M | M |
| **Shomael** | M | A: troca o escudo por **desfazer os tiros** no caminho da onda | A: alcance no lugar do tamanho; chão lento fica | M (escudo) | A: escudo sem a vida extra | M, vigiar: +1 esquiva é muito forte |
| **Velael** | M | A: a onda **causa mais dano em enfraquecidos** | A: alcance no lugar do tamanho | M | M | M |
| **Galael** | A: empurra só no giro; empurrar a cada corte tira o alvo do alcance | M | A: **puxa** em vez de empurrar | M | M | M |
| **Qeshael** | A: texto sem "crítico" | A: texto | A: alcance no lugar do tamanho | A: **abate em marcado devolve a Investida** | M | M |

Vinte e quatro ficam como estão e dezoito ajustam. Código novo pedido pelos ajustes: detonar a queimadura, estilhaço com etiqueta, puxar, desfazer tiros, dano em
enfraquecidos e devolver a Investida. São seis coisas pequenas, todas servindo a uma carta de assinatura.

## 4. Identidade dos sete anjos
| Anjo | Assinatura | Como se vê | Sequência | Fraco em | Risco de parecer com |
|---|---|---|---|---|---|
| Sarael | dano que continua | chão e corpos em brasa | ataque, Brado detona | alvo único blindado | Elos de fogo |
| Nivael | preparar e quebrar | estátua azul, estouro | giro congela, onda estilhaça | **Morvath** | Maré (ambas param) |
| Lumael | dano direto e vida | raios brancos, sem estado | qualquer uma | defesa na hora | a mais genérica; é a porta de entrada |
| Shomael | aguentar | aro de escudo, tiros desfeitos | Investida protegida | dano | o Brado novo (2.3) |
| Velael | inimigo fraco | cinza e olhos apagados | enfraquecer, onda cobra | **guardião e Morvath** | Marca; **é a menos visível hoje** |
| Galael | mover o grupo | ondas e corpos que deslizam | Brado puxa, giro empurra | **blindados e Morvath** | Geada |
| Qeshael | um alvo por vez | selo sobre o alvo | marcar, Investida executa | salas cheias | Véu |

**Contra o chefe** (problema 5): regra única e barata: o efeito que Morvath ignora vira **metade em forma de dano extra** no mesmo golpe (gelo, empurrão), e a Fraqueza
passa a valer nele pela metade. Sem isso, três dos sete anjos são escolhas piores para vencer a partida. Decisão do PO.

**Como validar a assinatura** (cada anjo, depois dos sete):
1. *Automático*: mesma sala, mesmas 12 sementes, só as Bênçãos do anjo nos cinco botões, nível 1 comum, contra nenhuma. Mede dano por ação, usos por ação, dano sofrido, tempo.
   **Assinatura existe se o uso ou o dano de pelo menos duas ações muda 25% ou mais** contra nenhuma e se o perfil difere dos outros seis.
2. *Olho*: captura e vídeo curto sem HUD de cada anjo; outra pessoa diz qual é o anjo. Meta: 6 de 7.
3. *Pessoas*: 3 jogadores, 2 descidas com anjo fixo; pergunta única: "o que mudou no seu jeito de jogar?". É o teste que vale.

## 5. Os 12 Elos
| Elo | Tipo | Veredito |
|---|---|---|
| Vapor | transforma (nuvem que cega) | Manter: é o modelo |
| Bastião | transforma (escudo quebrado explode) | Manter; abrir a lista para o escudo do Brado |
| Aurora, Chama Viva, Mira Clara | somam efeito aos raios de Luz | Manter; dependem de só 3 cartas de Luz |
| Rastro | **igual** à `passo_brasa` | Redundante |
| Passo Frio | quase igual à `passo_geada` | Redundante |
| Névoa Gelada | quase igual à `toque_geada` de hoje | Deixa de repetir se a carta passar a estilhaçar (seção 3) |
| Cinza Viva | **igual** à `golpe_brasa` | Redundante |
| Maré Ardente | **igual** à `circulo_brasa` de hoje | Deixa de repetir se a carta passar a detonar (seção 3) |
| Correnteza, Olho Firme | só número | Fracos e pouco visíveis |

**Só 2 dos 12 transformam o combate; 7 entregam o que uma carta comum já dá.** Hoje o Elo não é prêmio, e aumentar a chance só distribuiria mais do mesmo.

**Frequência**: 0 em 24 partidas [M]; na medição anterior, evoluído 4 em 12 (amostras pequenas). **Os pré-requisitos não são o gargalo** [E]: com as 42, quem tem 3 Bênçãos já pode
formar algum Elo em 56% (foco num anjo) a 68% (ao acaso) das vezes; com 5, 80 a 91%. O gargalo é a **oferta**: 12% por carta, só quando o anjo certo aparece, e com 3 ou 4
escolhas na partida. Proposta: com um par pronto e o anjo certo na porta, a **segunda** oferta seguida sem Elo garante a carta. Dá previsão ao jogador sem dar tudo. Antes de programar:
simular 1000 descidas com a regra velha e a nova; meta, Elo em 35% das partidas que passam da sala 6, e dois ou mais em menos de 15%.

## 6. Benchmark de SWORN (princípios)
| Aproveitar | Como já cabe aqui |
|---|---|
| Cada poder mora num botão | As seis por anjo (BO-2) |
| Uma ação prepara, outra cobra | Geada, Marca e Maré da seção 3 |
| Saber na hora o que a carta muda | Lista com a tecla e a habilidade acesa (BC-1) |
| Dois poderes, um resultado novo | Elos: refazer os 7 repetidos, não criar outros |

**Não copiar**: catálogo extenso, camadas de evolução de cada poder, poderes automáticos empilhados, textos e arte. Hades II confirma o mesmo (poder por botão e economia de
Magia); Ravenswatch, o talento que muda a ação em vez do número. Não joguei nenhum deles: é leitura, e o PO conhece melhor a sensação.

## 7. Matriz de sinergias
| | Dom (permanente) | Encanto (nesta descida, muda o golpe) | Bênção (efeito do anjo) | Elo | Salmo | Forja (números) |
|---|---|---|---|---|---|---|
| Ataque | Quarto Corte, Golpe sem Fim, Corte Crescente, Fio Longo | Lâmina Tríplice, Eco da Verdade, Corte Sísmico | 7 | Cinza Viva | Rocha | Fio, Pressa, ~~Peso~~ |
| Especial | Onda Atravessante, Onda Carregada | Onda Gêmea | 7 | Névoa Gelada, Olho Firme | Pastor | Onda Larga, Onda Pronta, ~~Onda Pesada~~ |
| Brado | **vazio** (só Ímpeto) | **vazio** | 7 | Maré Ardente | Sentinela | **vazio** |
| Investida | Passo Encadeado, Fio do Passo, Investida | Retorno do Corte, Eco do Passo | 7 | Passo Frio, Correnteza | **vazio** | **vazio** |
| Ultimate | Coração da Emeth | **vazio** | 7 | **vazio** | **vazio** | **vazio** |
| Esquiva | Avanço Feroz | **vazio** | 7 | Rastro | Abrigo | **vazio** |
| Ômega | Lâmina Faminta, Sangue Quente | **vazio** | nenhuma direta | **vazio** | Sentinela | **vazio** |

- **Riscado** = morto com o F8 em NENHUM. **Conflito**: três Encantos caem no giro; por isso o giro soma quase tudo.
- **Redundância**: Forja Fio e Dom Fio Longo dão alcance ao mesmo golpe; Onda Larga e quatro Bênçãos dão tamanho à onda. Toleráveis: são números de camadas diferentes.
- **Oportunidade** (depois, não agora): o primeiro Encanto do Brado e o primeiro da esquiva. Vazios não são defeito: não preencher por simetria.

## 8. Propostas criativas, por impacto sobre complexidade
**Combate**: (1) especial quebra blindagem [alto, P]; (2) Brado absorve um golpe [alto, P]; (3) reação desenhada do blindado e estalo da barra [alto, M]; (4) o efeito que o chefe
ignora vira dano [alto, P]; (5) gelo respeita a regra do F8: só golpes finais, Brado e ultimate congelam [médio, P]. **Interações**: (1) especial e combo, (2) Brado e Ômega, (3) giro e
estilhaço, (4) marca e Investida, (5) puxar e giro (seção 2.4).
**Descarto**: bônus por completar combo, barra de postura, Brado com vários efeitos, Pesado corpo a corpo novo, 50% de chance de Elo na terceira Bênção (trocado pela garantia da seção 5).

## 9. Balanceamento
**Ancião**: matou 9 de 11 robôs novatos somando as duas medições (4 de 4 antes do ajuste, 5 de 7 depois); **Cavaleiro 0 de 9** [M]. As versões diferem, mas o contraste é grande demais para ser sorte.
Ele causa 31% de todo o dano sofrido pelo novato. Recomendo: orbes de 7 para 6 m/s e meio segundo a mais entre leques, e o Cavaleiro ganha **uma** segunda investida curta depois da primeira (posição, não dano).
**Morvath**: a maldição acertou 7 de 7 (9 lutas do evoluído). Causa provável: gira 75 graus por segundo durante 1,4 s, a 7 m/s. Afrouxar para 55 e 0,9 s **não foi medido sozinho**; medi junto de menos ajudantes e o
jogo ficou fácil demais (com o robô sem atraso, não comparável à régua), por isso desfiz. Testar só a maldição, sem mexer nos ajudantes. Os ajudantes ferem mais que ele (36% do dano) e são o segundo alvo.
**Mago**: caiu de 33% para 22% do dano sofrido com o limite de 3 [M]. Cumpriu a meta.

**Os quatro que prometem atordoar** (causa igual: a regra do F8 em NENHUM):
| Item | Promete | Faz | Trocar por |
|---|---|---|---|
| Forja, Refinar Peso (25 de Prata) | ataque atordoa 50% mais | nada | ataque tira +20% da blindagem |
| Forja, Refinar Onda Pesada (25 de Prata) | especial atordoa 50% mais | nada | especial tira +30% da blindagem |
| Dom Fúria Plena | finalizador atordoa com 3 cargas | nada | finalizador com 3 cargas causa +40% |
| Bênção Vigia Firme | atordoa mais | nada | sai com o Lote 8 (não está nas 42) |

**Métricas fixas por lote**: dano e usos por ação, Ômegas iniciados e cortados, Magia gasta e ganha, usos de ultimate (régua nova com Maestria 6), vida ao guardião, mortes por guardião, Elos, Salmos, tempo por sala.
24 sementes quando a decisão for fina (12 erram uns 14 pontos). **Falta na régua**: um robô que use Brado antes do golpe; sem isso o Brado novo não se mede.

## 10. Backlog revisado (proposta; o plano vigente só muda com o sim do PO)
**Dependência que corrige a minha sugestão anterior**: o Lote 9 **não** é independente. A fala do anjo e a figura grande moram na mesma tela da lista (BC-1). O 8A vem antes, ou os dois juntos.
| ID | Entrega e valor | Depende | Tam. | Aceite e evidência | Risco | Arquivos |
|---|---|---|---|---|---|---|
| **8A** (P1) | Lista, tecla e habilidade acesa (BC-1, BC-2): entender a carta em 3 s | nada | M | 1280 e 1920 sem sobreposição, mouse, teclado e controle; capturas das 7 famílias | telas que estendem `BoonChoice` | `boon_choice`, `boon_card`, `build_column` |
| **9** (P1) | Dois anjos, fala, depois opções (BC-3, BC-4) | 8A | M | fala passa em 2,5 s ou no aperto; não repete na mesma sala; vídeo | cansar após muitas descidas | `encounter_screen`, `encounters` |
| **10A-1** (P1) | Especial e Forja quebram blindagem; estalo e reação do blindado | nada | M | vídeo antes e depois; especial acima de 15% do dano em elites | Ancião cair rápido demais | `combat`, `horde`, `make_data` |
| **10A-2** (P1) | Brado absorve um golpe; Fúria Plena nova; robô usa Brado | nada | P | Ômegas cortados de 35% para 20% | ficar obrigatório | `player`, `gift_state`, `bot` |
| **10A-3** (P1) | Gelo na regra do F8; efeito vira dano no chefe | decisões 6 e 13 | P | ninguém preso por mais de 1 s; teste com a regra NENHUM (BH-9) | Geada fraca | `combat`, `stun_rule` |
| **8B-1** (P1) | Base: 6 encaixes, gatilhos, escudo por botão; **Sarael e Nivael** completos | 8A, 10A | G | seção 4, testes 1 e 2; sem carta que age sozinha nos dois | o maior risco técnico do plano | `boon`, `boon_state`, `skills`, `make_data` |
| **8B-2** (P1) | Os outros cinco anjos; 35 vão para a reserva | 8B-1 aprovado | G | 42 no sorteio; tabela de dano por carta; saves antigos abrem | textos sem aprovação | idem, `text_pt` |
| **8C** (P1) | Refazer os Elos repetidos; garantia na segunda oferta | 8B-2 | M | 1000 descidas simuladas; meta da seção 5 | Elo automático | `boon_state`, `encounter`, `psalms` |
| **10B-1** (P1) | Ancião, Cavaleiro e maldição, **um por vez** | 8B-2 | M | 24 sementes cada; guardião mata 25 a 40% do novato | ficar fácil | `make_data`, `boss`, `horde` |
| **10B-2** (P2) | Quatro dicas, uma vez por save (bater e esquivar; segurar; blindagem; par de Bênçãos) | 10A | P | 2 de 3 pessoas explicam a barra amarela | interromper | `hud`, `text_pt` |
| **10B-3** (P2) | Leitura: soldados, contorno do Ancião, rosto de Morvath, cor das orbes | nada | M | luma de soldado 20 acima do chão; capturas | poluir | shaders e figuras |

## 11. Roadmap incremental (um exe por passo; parar para testar em cada um)
1. **8A + 9**: a tela que o PO pediu. Só interface, risco baixo. 2. **10A**: ações com motivo. Teste: "você usou o especial e o Brado?". 3. **8B-1**: dois anjos. **Portão**: se Sarael e
Nivael não parecerem diferentes jogando, parar e rever antes dos outros cinco. 4. **8B-2**. 5. **8C**. 6. **10B**.
10A vem antes de 8B porque balancear 42 cartas sobre ações que vão mudar é fazer duas vezes. Pode esperar: 10B-3, raridade lendária. Rápido de testar: 10A-2 e os três erros da seção 3.
**Maior impacto na diversão**: 10A e o portão do 8B-1. **Maior risco técnico**: 8B-1 (encaixes, gatilhos, saves).

## 12. Decisões do PO (recomendação)
**O Daniel aprovou dez delas em 2026-11-22; a lista que vale está no topo de `docs/backlog.md`** (ele aprovou nomes e textos só de Sarael e Nivael).

| # | Questão | Recomendo |
|---|---|---|
| 1 | Nomes e textos das 42 | Aprovar anjo por anjo, no 8B-1 só dois. Evitar dizer "crítico" |
| 2 | As quatro orbitais | Nascer de botão, sim; Nivael passa a atrasar em vez de congelar |
| 3 | Escudos da Shomael | Dois (Investida e ultimate); o especial desfaz tiros |
| 4 | Cura | Só Lumael, no abate da Investida, teto de 3 por sala |
| 5 | Lendária | 1% no sorteio comum: com uma mediana de 3,5 escolhas de 3 cartas, cerca de 10% das partidas veem uma. Guardião 3% |
| 6 | Quatro que atordoam | Trocar os efeitos (seção 9) e manter o F8 em NENHUM |
| 7 | Ruptura | Sim, usando a blindagem que já existe; sem barra nova |
| 8 | Ancião e Cavaleiro | Ancião mais lento, Cavaleiro com segunda investida |
| 9 | Maldição | 55 graus e 0,9 s, medida sozinha |
| 10 | Ordem | Seção 11 |
| 11 | Combinações que viram Dom | Nenhuma agora; só cartas e regras |
| 12 | Brado | Absorver um golpe, nada mais |
| 13 | **Nova**: anjos fracos contra Morvath | O efeito ignorado vira dano, metade |
| 14 | **Nova**: mouse direito | Continua a rajada; a ruptura entra nela |
| 15 | **Nova**: as 7 cartas do Shift | O novato não as vê até a Maestria 6: aceitar (5 por anjo) ou abrir a primeira ultimate mais cedo? Recomendo abrir na Maestria 3 |

# A Ladina

- **Data**: 2026-11-21. **Autor**: `hero-designer`. Proposta; números de partida. **Cânone**: o RPG tem a ladina Andilla (nome guardado do Daniel, `canone.md` linha 169); **não usei o nome**: ver Perguntas.
- **Fantasia**: assassina de um alvo por vez; entra por trás, corta e some antes de a sala responder.
- **Papel e distância**: dano alto em alvo único, mobilidade, 1,5 a 3 m (adagas) e 8 m (adaga lançada). **Arma**: duas adagas.
- **Ritmo**: explosivo; janela de 2 a 3 s de pico depois de uma marca, depois some e espera a recarga.
- **Recurso próprio: Pontos de Marca** (0 a 5, losangos): o Especial **marca** um inimigo (a marca dura 6 s); cada golpe nele dá 1 ponto; o finalizador do Ataque gasta os pontos (+20% de dano por ponto). Sem barra.

## 1. As 5 habilidades e a travessia
| Botão | Papel | O que faz | Custo, recarga | Preparação, recuperação (s) | Cancela | Lê na tela |
|---|---|---|---|---|---|---|
| Esquerdo | **Ataque**: Facadas | combo de 4 golpes curtos e rápidos (10, 10, 12, finalizador 30 que gasta pontos); **por trás** do alvo o dano é +30% | sem custo | 0,05 / 0,12 por golpe | esquiva, Pulo | cortes pequenos e rápidos, brilho no finalizador |
| Direito | **Especial**: Adaga Marcada | lança uma adaga em 8 m (20); o alvo fica **marcado** 6 s | 2 s de recarga | 0,15 / 0,20 | esquiva | símbolo sobre o inimigo, linha |
| Q | **Defesa**: Fumaça | granada de fumaça no chão (3 m, 3 s): quem está dentro perde o alvo e erra o golpe; ela fica **invisível** para atiradores | 12 s | 0,2 / 0,15 | esquiva | nuvem no chão |
| E | **Tática**: Pulo de Sombra | vai instantaneamente para as costas do marcado (ou 5 m à frente se não houver), com 15 quadros protegidos; o próximo golpe é de costas | 7 s | 0,05 / 0,10 | tudo | poeira escura nos dois pontos |
| Shift | **Ultimate**: Dança das Lâminas | por 3 s, ataca cada marcado na sala em sequência (35 por golpe, 2 por alvo), de volta ao ponto de partida | carga | 0,3 / 0,3 | esquiva corta | linhas luminosas ligando as marcas |
| Espaço | **Mergulho** | rola 7 m **atravessando inimigos** (1 carga e meia, 0,9 s), 19 quadros protegidos; ataque na rolagem é uma facada de 20 | cargas | 0,05 / 0,10 | tudo | sombra e poeira |

**Passiva**: o primeiro golpe em alvo desatento (parado ou de costas) conta como crítico e dá 2 de Magia. **Mapa de botões**: ultimate no Shift (recomendação).

## 2. Bênçãos por botão
| Família | Esquerdo | Direito | Q | E | Shift | Mergulho |
|---|---|---|---|---|---|---|
| Chama | facadas queimam | a marca queima | a fumaça pega fogo (chão em chamas) | o Pulo deixa brasas | a Dança queima | rola deixando fogo |
| Geada | facadas gelam | a marca congela por 1 s | a fumaça gela quem sai | o Pulo gela o marcado | a Dança congela | rola gelando o chão |
| Luz | facada final ofusca | a marca dá 2 pontos | a fumaça cura 1 por abate | o Pulo é finalizador | +25% de carga | atravessa sem gastar carga a cada 3 |
| Vigília | cada 4 acertos dão 0,5 s de proteção | a adaga puxa o marcado 1 m | a fumaça protege 10% | o Pulo dá 1,3 s protegida | protegida durante a Dança | o Mergulho dá 0,3 s a mais |

## 3. Dons
- **Facada**: *Quinta Facada*, *Fio Duplo* (cada finalizador solta 2 facadas), ápice *Corte Fantasma* (o finalizador não gasta pontos 1 vez por sala).
- **Marca**: *Marca Funda* (+1 ponto), *Marca Dupla* (2 marcas), ápice *Sentença* (a marca explode ao fim em 40).
- **Sombra**: *Pulo Curto* (menos recarga), *Duplo* (2 cargas), ápice *Sombra que Fica* (um eco ataca o alvo).
- **Mergulho**: *Passo Sutil* (+1 m), *Rolagem Cortante* (acerta 15 ao atravessar), ápice *Furtiva* (o Mergulho deixa a Ladina desatenta por 1 s).
- Sustento: *Firmeza*, *Respiro*.

## 4. Três combinações só dela
1. **Adaga, Pulo, Facadas**: marca o mais forte, pula nas costas e gasta 5 pontos de uma vez com o finalizador.
2. **Fumaça, Pulo, Dança**: a fumaça tira o alvo do grupo, o Pulo vai ao marcado e a Dança fecha as marcas.
3. **Mergulho cortante**: rola atravessando o grupo, deixa a Marca Dupla em dois e termina com o Ômega (a mesma carga do ataque na rolagem).

## 5. O que a distingue
Alvo único e marca (os outros três são de área), travessia que atravessa inimigos, mobilidade tática com E, defesa por engano (fumaça) e não por escudo.

## 6. Riscos
- **Forte demais**: dano de costas + marca em chefe (os 5 pontos viram dano por muito tempo). Mitigação: chefe tem pontos máximos 3 e sem bônus de costas; fases do chefe saem do alcance.
- **Fraca demais** em sala cheia: marca uma pessoa por vez. Mitigação: Marca Dupla e a Dança.
- **Frustração**: perder a marca quando o inimigo morre; a marca passa ao mais perto (regra).
- **Parece o Guerreiro com adagas** se o combo não for muito mais rápido: ritmo e facada final.

## 7. Reuso e código novo
| Item | Reaproveita | Pede código | Estimativa |
|---|---|---|---|
| Facadas (combo de 4) | `ComboNode`, árvore `Combo` | bônus por trás (ângulo em `Combat.hit_enemy`) | M |
| Adaga marcada | `Projectiles`, `Combat.on_shot_hit`, status | marca e pontos (recurso novo, HUD) | M |
| Fumaça | `Ground.Zone` | inimigos que perdem o alvo (`Enemy`: erra o golpe) | M a G |
| Pulo de Sombra | esquiva e `Player.State.DODGE` | teleporte ao marcado | M |
| Dança das Lâminas | `Ultimates` | sequência de golpes entre marcas | M |
| Mergulho | `DODGE`, `Feel` | atravessar corpos (`BodyBlock`) | P a M |
| Herói | `HeroDef` | modelo, animações, 2 armas (Meshy, estimar) | G |
| **Total** | | | **G** |

## 8. Perguntas ao Daniel
1. A Ladina é Andilla? Se não, que nome e origem? (Sem nome até lá.)
2. O Mergulho atravessar inimigos pode (a esquiva do Guerreiro não atravessa)? Recomendo sim, é a identidade.
3. Fumaça: os inimigos "perdem o alvo" é uma mecânica nova; recomendo implementar só depois do Paladino e da Maga.

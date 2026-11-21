# O Paladino

- **Data**: 2026-11-21. **Autor**: `hero-designer`. Proposta; números de partida.
- **Cânone** (`canone.md`): "paladino do leão" é um por selo, do sangue de Hanokh; a Ordem de Erukh são "cavaleiros disciplinados"; "a convicção destes guerreiros contagia os aliados e lhes concede poderes mágicos divinos" (linha 271). Isto sustenta um paladino que **protege e contagia**; **mas** o jogo diz que os quatro heróis são paladinos (premissa); a ligação ainda é pergunta. Nomes: `PALADIN_1` a `PALADIN_4`. Sem cruz; símbolo = o leão; luz vem de Elun (sem nome de poder com Elun).
- **Fantasia**: a muralha de luz que segura a linha da sala e devolve o que recebe.
- **Papel e distância**: defesa ativa e controle de posição, 1 a 3 m. **Arma**: maça de luz e escudo (modelos `w_knight_shield` e outros em `assets/models/meshy/`, a conferir com `art-director`). Silhueta separada do Guerreiro (largo, escuro, escudo).
- **Ritmo**: ciclo. Segura (Guarda), absorve (camadas), responde (Golpe de Escudo e ecos), fecha (ultimate). Mais lento que o Guerreiro e com menos esquiva.
- **Recurso próprio: Fé em Camadas** (0 a 3 camadas de luz, sem barra): cada camada **absorve um golpe inteiro**; ganha uma por 3 abates, por acerto de Guarda perfeita (o golpe recebido no momento da Guarda) ou pelo Chão Consagrado; quando absorve, **ecoa** 20 de dano em 3 m. Distinto do Guerreiro: o Guerreiro **não bloqueia**; o Paladino bloqueia com custo (camada) e ganha do lado do inimigo.

## 1. As 5 habilidades e a travessia
| Botão | Papel | O que faz | Custo, recarga | Preparação, recuperação (s) | Cancela | Lê na tela |
|---|---|---|---|---|---|---|
| Esquerdo | **Ataque**: Maça | combo de 3 golpes lentos (22, 26, 45 em área curta de 3 m); o 3º empurra | sem custo | 0,12 / 0,25 | esquiva e Avanço | maça com brilho, arco curto |
| Direito | **Especial**: Golpe de Escudo | pancada de escudo à frente (30), empurra 3 m e atordoa os comuns 0,7 s; acerto dá 1 camada de Fé | 3 s de recarga | 0,20 / 0,30 | esquiva | ondas curtas, escudo brilhando |
| Q | **Poder**: Chão Consagrado | zona de 4 m em volta dele por 5 s: inimigos dentro ficam lentos; os golpes **que ele recebe** dentro valem metade; ele fica parado só se quiser (anda com ele pelo Dom Sentinela) | 12 s | 0,3 / 0,2 | esquiva | círculo dourado no chão |
| E | **Ultimate**: Muralha | ergue um arco de luz de 8 m à frente por 4 s: bloqueia tiros inimigos e empurra quem encosta (30), e dá 3 camadas; ele fica protegido 0,3 s ao subir | carga | 0,3 / 0,4 | esquiva | parede dourada e marfim |
| Shift | **Guarda** (segurar) | segurando, ele para e levanta o escudo na frente (arco de 120 graus): o primeiro golpe de frente é absorvido (consome 1 camada; sem camadas, recebe metade); soltar dá uma pancada curta (15); anda a 40% da velocidade | sem custo, 0,7 s de recarga ao soltar | 0,10 / 0,15 | esquiva | escudo brilhante, anel ao absorver |
| Espaço | **Avanço de Escudo** | arranca 3,5 m com o escudo na frente, empurra e acerta 15 em quem toca; 1 carga (1,0 s), 14 quadros protegidos | cargas | 0,05 / 0,12 | tudo | poeira e brilho dourado |

**Passiva**: cada camada absorvida cura 1 de vida (no máximo 6 por sala). **Mapa**: Shift = Guarda; ultimate no E (recomendação).

## 2. Bênçãos por botão
| Família | Esquerdo | Direito | Q | E (Muralha) | Shift (Guarda) | Avanço |
|---|---|---|---|---|---|---|
| Chama | golpes queimam | o escudo deixa brasas | o chão queima | a parede queima quem encosta | o eco ao absorver queima | o Avanço deixa fogo |
| Geada | golpes gelam | o escudo gela | o chão gela | a parede gela | o eco gela | o Avanço gela |
| Luz | giro mais largo | o escudo atordoa +0,3 s | o chão cura 1 por abate | a Muralha dura +1 s | cada Guarda cura 1 | o Avanço cura 1 |
| Vigília | cada abate dá 0,3 s de proteção | o escudo dá 1 camada a cada 2 acertos | o chão reduz mais dano | a Muralha dá 4 camadas | a Guarda absorve um 2º golpe | o Avanço dá 1 camada |

## 3. Dons
- **Maça**: *Maça Longa* (+0,5 m), *Quarto Golpe*, ápice *Martelo* (o 3º golpe atordoa).
- **Escudo**: *Golpe Largo*, *Eco do Escudo* (o eco vira 30), ápice *Escudo Refletor* (a Guarda devolve tiros).
- **Consagração**: *Chão Largo*, *Chão que Anda* (a zona o segue), ápice *Salmo do Pastor* (o chão cura 1 por segundo).
- **Fé**: *Camada Extra* (4 camadas), *Camada Rápida* (a cada 2 abates), ápice *Ainda de Pé* (se cair, uma camada o levanta).
- Sustento: *Firmeza*, *Respiro*.

## 4. Três combinações só dele
1. **Guarda, eco, giro**: segura o grupo, absorve 3 golpes (3 ecos de 20 em volta) e o giro da maça fecha.
2. **Chão, Avanço, Golpe de Escudo**: empurra o grupo para dentro do chão consagrado, onde está lento e em chamas ou gelo.
3. **Muralha contra atiradores**: a Muralha bloqueia a fila de atiradores e ele avança dentro da área.

## 5. O que o distingue
Defende **segurando** (Guarda), recurso de camadas, absorve para dar dano (eco); o Guerreiro ofensivo nunca bloqueia, e o Paladino é um segundo de esquiva a menos, mais vida, mais controle de espaço e menos dano por segundo.

## 6. Riscos
- **Parede passiva**: se a Guarda for gratuita e infinita o jogo fica sem tensão. Mitigação: só os golpes de frente, 0,7 s de recarga ao soltar, anda a 40%, e **golpes de área ignoram** a Guarda (círculos e erupções do chefe), forçando o Avanço.
- **Fraco demais** de dano: o eco e o Golpe de Escudo compensam; ajuste pelo `balance-designer`.
- **Lembrar o aparo do Guerreiro** (a spec dele proíbe): aqui é Guarda **segura**, não aparo na hora.
- **Morvath**: o Paladino vence mais devagar, quase sem risco; medir o tempo de luta.

## 7. Reuso e código novo
| Item | Reaproveita | Pede código | Estimativa |
|---|---|---|---|
| Maça (3 golpes) | `ComboNode`, árvore | animação e dados | P |
| Golpe de Escudo | `Effect.STUN`, `LAUNCH` | acerto dá camada | P |
| Chão Consagrado | `Ground.Kind.HOLY`, `Zone.follow` (Sentinela), `STONE` | dano recebido reduzido dentro da zona | M |
| Muralha | `Ground.Kind.SHELTER` e `Projectiles.shelter` (desfaz tiros) | parede em arco que empurra | M |
| Guarda | nada | segurar: estado `GUARD` no `Player`, arco de 120 graus, absorver golpe e tiro | M a G |
| Camadas de Fé | losangos do HUD | recurso novo, eco ao absorver | M |
| Avanço | esquiva | empurra quem toca | P |
| Herói | `HeroDef` | modelo e animações (maça e escudo) | G |
| **Total** | | | **M a G** (o mais barato dos três novos) |

## 8. Perguntas ao Daniel
1. A Guarda segurada (bloqueio, com custo em camadas) pode ser do Paladino, já que o Guerreiro é o que não bloqueia? Recomendo sim.
2. Maça e escudo (silhueta separada) ou espada e escudo? Recomendo maça.
3. A passiva cura por camada absorvida: sustento é aceitável, ou só dano devolvido (eco)? Recomendo manter o cura baixo (1 por camada, 6 por sala).

# Referência SWORN do Daniel: HUD, gráficos e perigos de sala (2026-11-21)

Fonte: 12 capturas do Daniel (vídeo de gameplay), cópia local em `docs/art/ref/sworn_daniel/sw_01..12.jpg`
(fora do git: são do jogo deles). Regra: **princípios, nada copiado** (nem arte, nem layout idêntico, nem nomes).
Paleta e identidade continuam as de Eterra (Ember & Blade, `docs/reference/art_core.md`).

## 1. O que as imagens mostram

**HUD**
- Canto inferior esquerdo enxuto: retrato do herói, e ao lado três barras finas empilhadas: uma de carga
  (amarela, com ícone; a ultimate), a de magia (azul e curta) e a de vida (vermelha e longa, com "80 / 80"). Nenhum
  botão de habilidade na tela. (sw_02, 06, 07, 10)
- **Coluna da build na borda direita**: um estandarte escuro vertical com um ícone por botão (ataque leve, pesado,
  magia, esquiva, ultimate, companheiro), cada um com o nível da Bênção ("Nv. 3") ou vazio em cinza. Lê a build
  inteira de relance. (sw_02, 04, 07, 09, 12)
- Canto inferior direito: contadores de moedas (ouro, brasas, cristais) e o aviso de coleta ("+20 Fragmento de
  cristal", "+3 Ouro"). (sw_07, 09, 11)
- Avisos centrais embaixo: placa escura com título dourado e o botão ("Espada na pedra / Interagir", "Continuar",
  "Inicie as Provas de combate"). (sw_02, 04, 09)
- Chefe: barra fina vermelha no topo com o nome em versaletes. (sw_10)
- Porta: orbe grande com o ícone da recompensa sobre a porta e a legenda "Recompensa: brasas feéricas". (sw_02, 07)
- Vida baixa: vinheta vermelha com respingos nas bordas da tela. (sw_10)
- Números de dano pequenos, roxos e brancos, sem poluir. (sw_03, 05, 08)

**Tela de Bênção** (sw_01, 12)
- Arte grande do patrono à esquerda; placa com nome e uma frase; três cartas com raridade colorida (Comum branco,
  Incomum verde), ícone quadrado com "Nova!", palavra-chave colorida no texto ("fraqueza") e **o significado ao lado**
  numa caixinha ("Fraqueza: reduz o dano do inimigo"). A coluna da build continua visível à direita.
- Antes da tela: os orbes de escolha flutuam **no mundo**, sobre o altar, com os retratos nas laterais em nuvens e a
  placa "Nome / Aceitar bênção" embaixo.

**Gráficos**
- Tinta de quadrinho: contorno preto grosso, sombra chapada, hachura; cor local forte (musgo, água turquesa).
- Chão muito rico: manchas de musgo, poças com borda quebrada, tufos de grama, raízes, potes em grupos, crânios,
  **manchas de sangue que ficam no chão**.
- Moldura escura: ruínas grandes e cachoeiras nas bordas, o centro mais claro onde se luta.
- Golpe: meia-lua enorme branca e dourada; inimigo atingido pisca em silhueta vermelha e amarela. (sw_08)

**Perigos de sala**
- **Bloco de armadilha na parede** com rostos de caveira que dispara lâminas ou dardos em linha; setas talhadas no
  topo mostram a direção. (sw_03, 05, 06)
- **Lajes rachadas** no chão (quadrados de pedra com rachaduras) e **grades de fosso** de quatro vãos. (sw_03, 06, 07, 08, 11)
- **Aviso de área**: círculo vermelho de contorno limpo e preenchimento leve; projétil com rastro vermelho até o
  círculo. (sw_06, 10, 11)
- Eventos no mundo: "Espada na pedra" (interagir dá recompensa), cristal que inicia as Provas de combate. (sw_04, 09)
- Água como divisão do terreno; potes quebráveis com ouro.

## 2. O que já temos (não refazer)
Lajes de runa, Runas, fissuras, corrente, coluna, raiz, cristal, urna, pedras, nicho, planta, quebráveis
(`docs/reference/rooms.md`); Provação e Altar (E5); placas de porta com o ícone da recompensa; aviso vermelho dos
golpes; barra do chefe; vinheta de vida baixa (conferir).

## 3. Backlog (ordem sugerida; dono entre parênteses)

### HUD (ui-ux-designer, com o art-director)
- **SR-H1 Coluna da build** (FEITO, feito no Lote 2, `BuildColumn`) na borda direita: um ícone por botão (esquerdo, direito, Q, E, Shift, Espaço) com a
  Bênção do slot e o nível; vazio em cinza. Substitui a necessidade de abrir o Livro para lembrar a build. *Médio.*
- **SR-H2 Canto do herói enxuto** (FEITO, feito no Lote 2: retrato, Magia em cima, Vida, carga da ultimate; fileira centrada): retrato + três barras finas (ultimate com ícone, Magia, Vida com números); a
  fileira de losangos vira só recargas pequenas ao lado do retrato ou some para a coluna da SR-H1 (decidir com o
  Daniel). *Médio.*
- **SR-H3 Moedas no canto inferior direito** (FEITO, feito no Lote 2, `CoinCorner`) com o aviso de coleta ("+10 Prata"). *Pequeno.*
- **SR-H4 Palavra-chave com definição** (FEITO, feito no Lote 2: cor por termo e Fúria; a caixinha já existia (`Glossary`)) na carta de Bênção (atordoar, queimar, gelo, fraqueza...): cor + caixinha
  com o significado ao passar ou focar. *Pequeno a médio.*
- **SR-H5 Placa central de interação** (FEITO, feito no Lote 2: auditada, já era uma só (`StationSign`)) (título dourado + botão) para estação, evento e porta, a mesma em todo lugar. *Pequeno.*
- **SR-H6 Vinheta de vida baixa** (FEITO, feito no Lote 2, `LifeVignette`) com bordas de tinta vermelha (conferir a nossa e ajustar). *Pequeno.*

### Gráficos (art-director especifica, environment-artist e technical-artist fazem)
- **SR-G1 Chão mais rico (feito no lote 4, `art_rooms.md`; sangue fica em G2)**: manchas de musgo e de umidade, tufos, raízes, potes em grupos, crânios espalhados, por
  bioma, sem mexer na colisão. *Médio.*
- **SR-G2 Sangue e marcas que ficam** no chão depois do combate (decalques baratos, limite por sala; tom de aventura:
  escuro, pouco vermelho, nada de terror). Pergunta ao Daniel. *Pequeno a médio.*
- **SR-G3 Moldura escura nas bordas (feito no lote 4: faixa escura e pedras caídas; falta cachoeira)** com peças grandes de ruína e cachoeira, centro mais claro. *Médio.*
- **SR-G4 Golpe e impacto (feito no lote 4, `art_fx.md`)**: arco do giro maior e mais claro; pisca do inimigo em silhueta quente. *Pequeno.*
- **SR-G5 Contorno de tinta (experimento `--ink` no lote 4, desligado)** (outline) no herói e nos inimigos no look estilizado, medindo o custo. *Médio.*

### Perigos de sala (room-designer, com o environment-artist)
- **SR-P1 Bloco de armadilha na parede (feito no lote 3, 2026-11-21; `rooms.md`)** que dispara lâminas em linha a intervalos, com direção talhada na pedra e
  aviso antes do disparo; acerta inimigos também (usar a favor). Comportamento novo, depois só dado. *Médio.*
- **SR-P2 Laje que cede (feito, 2026-11-21; `rooms.md`)**: lajes rachadas que afundam um tempo depois de pisadas e voltam; dá forma à luta. *Médio.*
- **SR-P3 Grade de fosso (feito, 2026-11-21; `rooms.md`)**: abre e fecha em ritmo, com espinhos. *Médio.*
- **SR-P4 Aviso de área padronizado (feito no lote 3, 2026-11-21; `rooms.md`)**: círculo de contorno limpo + preenchimento leve para todo golpe de área (chefe,
  atiradores, perigos), um só estilo no jogo. *Pequeno.*
- **SR-P5 Evento "relíquia na pedra" (feito, 2026-11-21; tema a confirmar com o Daniel: hoje só uma pedra gasta com um anel claro, sem nome nem história; `rooms.md`)** (nossa versão, sem copiar a espada na pedra; tema a definir com o Daniel e o
  cânone): interagir dá ouro ou Prata. *Pequeno.*

## 4. Decisões do Daniel (2026-11-21)
- **Habilidades no centro embaixo**, como no Ravenswatch: a fileira de habilidades (esquerdo, direito, Q, E, Shift,
  Espaço, com recarga) sai do canto do retrato e fica centrada na base da tela. A SR-H2 deixa no canto só o retrato e
  as barras.
- **Canto inferior esquerdo**: o retrato à esquerda e, ao lado dele, as barras empilhadas com a **Magia em cima e a
  Vida embaixo** (a carga da ultimate junto, fina).
- **Bênçãos na borda direita**, como no SWORN: a coluna da build (SR-H1) mostra as Bênçãos pegas.

**Lote 2 (2026-11-21)**: H1 a H6 e AN-1 (retratos dos anjos 1 a 4 no Encontro) feitos; ver `docs/reference/ui.md`.

## 5. Perguntas ao Daniel
1. A fileira de habilidades sai da tela (como no SWORN) e fica só a coluna da build, ou mantemos as recargas visíveis?
2. Sangue no chão: sim, pouco e escuro, ou nada (tom de aventura)?
3. Contorno de tinta grosso (quadrinho) no estilizado: vale experimentar? Muda bastante a cara do jogo.
4. Por onde começar: HUD (H1 a H3), chão rico (G1) ou armadilhas (P1, P4)?

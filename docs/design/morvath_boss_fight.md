# Morvath, a luta inteira (proposta)

> **PROPOSTA PARA O CICLO 9, SEM IMPLEMENTAÇÃO.** Nada deste documento está no jogo. Os números são ponto de partida
> para o teste, não decisão. Lore: só o que está no cânone (`../dungeon-rpg/docs/mundo/canone.md` e
> `personagens.md`); o resto está marcado como **pergunta para o Daniel**. Nomes de ataques e de interlúdios são
> provisórios e só de trabalho (o texto do jogador vai para `data/text_pt.tres` depois de aprovado).

Autor: gameplay-engineer, ciclo 8, frente D (2026-11-15).

## 1. Ponto de partida

### A luta de hoje (`scripts/game/boss.gd`, `scripts/core/boss_rules.gd`, `data/enemies/morvath.tres`)
- Vida 6050, velocidade 3,75 m/s, contato 8, `attack_damage` 10, raio 1,4, `heavy`, armadura 0.
- Fases por vida: 2 em 60% e 3 em 25% (`BossRules.PHASE_2_AT`, `PHASE_3_AT`). Na troca: rugido de 1,6 s
  invulnerável, limpa avisos e projéteis, empurra o paladino 4 m, aviso na HUD.
- Fase 1: três cortes (arco, 0,6 s de preparo, alcance 4,6 / 5,4 / 6,2 m, 120 / 150 / 180°) e investida (faixa de
  16 x 2,8 m, 0,8 s, dano 12).
- Fase 2: mais chuva (círculos de 2 m, 0,9 a 1,5 s) e invocação de 2 + fase esqueletos (se houver menos de 30 vivos).
- Fase 3: névoa escura que fecha de 46 m para 12 m de raio em 12 s (1,5 de dano a cada 0,5 s fora), rajadas de
  orbes (anel de 14 e leque de 7, dano 8) e atordoamento por 3 golpes pesados em 4 s (2,6 s atordoado).
- Preparos 15% mais curtos e descansos 12% menores por fase.

### Medição de hoje (robô, `tools/smoke.sh 300 --start=boss`, 2026-11-15, antes de qualquer mudança)

| Opções | Dons | Resultado | Linha `RESULT` (resumida) |
|---|---|---|---|
| `--boons=5 --seed=1` | 4 | perdeu na fase 3 | `"time": 162.2, "boss_hp": 1285, "phase": 3, "damage": 5830` |
| `--boons=5 --seed=5` | 4 | perdeu na fase 2 | `"time": 111.5, "boss_hp": 1895, "phase": 2, "damage": 4299` |
| `--boons=8 --seed=2` | 6 | venceu | `"time": 103.7, "hp": 26, "mode": "ENDING", "damage": 6388` |
| `--boons=8 --seed=5` | 5 | perdeu na fase 3 | `"time": 141.2, "boss_hp": 983, "phase": 3, "damage": 5740` |
| `--boons=25 --seed=5` | 8 | venceu | `"time": 121.3, "hp": 18, "mode": "ENDING", "damage": 6867` |

Leitura: a luta de hoje dura de 1 min 40 s a 2 min 40 s para o robô, que tira de 30 a 60 de
vida por segundo do chefe. Ela não tem nenhum momento em que o jogador faz outra coisa além de bater e esquivar.

### Problemas que a proposta já resolve
1. As rajadas de orbes (`_step_volley`) só têm o braço erguido como aviso, sem nada no chão: fere a regra "todo
   ataque inimigo tem aviso no chão".
2. O `CLAUDE.md` diz que Morvath se rearma depois do atordoamento, mas a armadura dele é 0 nos dados: o caminho
   `break_armor` nunca acontece; quem atordoa é a contagem de golpes pesados.
3. `break_armor` e `_on_struck` repetem o mesmo bloco de atordoamento (DRY).
4. Os números da luta são constantes em `boss.gd` (`DASH_LENGTH`, `MIST_*`, dano por multiplicador); a regra é
   "conteúdo é dado".
5. O teto de invocação é 30 inimigos vivos na sala, alto demais para uma luta de chefe no molde do Hades II.

## 2. A estrutura da Hécate, traduzida

| Hécate (dados do jogo do Daniel) | Morvath (proposta) |
|---|---|
| 6050 de vida (7250 numa variante) | 6050 (a variante fica para uma dificuldade futura, como os Votos) |
| Transições em 66% e 33% | Transições em 66% e 33% (`BossRules` 0,66 e 0,33) |
| Interlúdio 1: encontros invocados, cópias, chuva de meteoros, anéis de tochas | Interlúdio 1, "Marcas do Inverno": reforços, cópias ilusórias, chuva, anel com saída, e um objetivo ativo (apagar 3 marcas) |
| Interlúdio 2: espirais, cone, laser, transforma o jogador | Interlúdio 2, "Ritual sobre a Emeth": espiral de orbes, leque, e o ritual de corrupção da espada, que o jogador interrompe quebrando âncoras |
| Armas por fase: combo corpo a corpo, cópias que se dividem, teletransporte | Fase 1: cortes e investida. Fase 2: cortes espelhados por cópias. Fase 3: passo na névoa (teletransporte) e investida dividida |

Copiamos a estrutura e os números. Nada de nome, figura, som ou tema da Hécate.

## 3. Regras gerais da luta

- **Vida:** 6050. Dano em escala do Hades: o paladino tem 30 de vida (como a heroína do Hades II) e o dano fica de
  4 a 14 por golpe (a faixa da Hécate). Nenhum golpe tira mais de 14.
- **Fases:** 1 de 100% a 66%; interlúdio 1; 2 de 66% a 33%; interlúdio 2; 3 de 33% a 0.
- **Transição:** o golpe que cruza o limiar pára a vida no limiar (o excesso se perde, como no Hades), Morvath ruge
  (1,6 s, invulnerável, já existe), limpa avisos e projéteis (já existe) e vai para o altar ao norte.
- **Interlúdio:** Morvath fica no alto da escada do altar, diante do portal, invulnerável e visível (sem barra de
  dano, com a barra do topo travada e um ícone de selo). O objetivo aparece no chão e num contador da HUD
  (dono: ui-ux-designer). Duração máxima 35 s; ao cumprir, ou ao acabar o tempo, a fase seguinte começa.
- **Recompensa por cumprir:** Magia (+10 por objetivo cumprido, a barra tem 50) e Morvath começa a fase seguinte
  atordoado por 2,0 s. Na luta de hoje quase não entra Magia (só 1 por esqueleto), então o Ômega aparece pouco; o
  objetivo vira a fonte de Magia do chefe. **Mexe no balanceamento: precisa do sim do Game Director.**
- **Falhar não mata:** objetivo não cumprido deixa um custo pequeno e recuperável na fase seguinte (abaixo).
- **Reforços:** chefe mais no máximo 4 vivos nas fases 2 e 3 e 6 vivos nos interlúdios; fase 1 sem reforço. Teto
  global: 20 reforços na luta inteira (depois disso a invocação sai da lista de ataques). Cópias ilusórias não contam
  no teto (não dão Magia, não deixam corpo e somem com 1 golpe), mas nunca há mais de 3 de pé.
- **Aviso:** todo ataque, do chefe ou de cópia, tem aviso no chão com o mesmo formato e a mesma clareza. A dúvida
  das cópias é "em quem bater", nunca "de onde vem o golpe".
- **Nunca dois ataques grandes ao mesmo tempo:** o chefe e as cópias atacam em fila; enquanto um aviso grande
  (faixa, anel, feixe) está no chão, nenhum outro grande nasce. Chuva e orbes podem somar com cortes de cópia.

## 4. Fases e interlúdios

Colunas: tipo de aviso (o que já existe em `Ground`: círculo `add_warning`, faixa `add_line_warning`, arco
`add_arc_warning`), preparo em segundos (do aviso até o dano), dano (escala do Hades: o paladino tem 30), como
esquivar (o avanço cobre 5,6 m em 0,2 s com 0,27 s de proteção), e origem (existe hoje ou é novo).

### Fase 1, "O rei de pé" (100% a 66%)
Só corpo a corpo, para o jogador aprender o ritmo. Sem reforços.

| Ataque | Aviso no chão | Preparo | Dano | Como esquivar | Origem |
|---|---|---|---|---|---|
| Três cortes | arco: 4,6 / 5,4 / 6,2 m, 120 / 150 / 180° | 0,6 s cada, 0,3 s entre eles | 10 cada | avanço para fora do arco ou para as costas dele; revidar nos 0,3 s entre cortes | existe |
| Investida | faixa 16 x 2,8 m | 0,8 s | 12 | avanço para o lado | existe |
| Onda fria | círculo de 6 m em volta dele | 1,0 s | 8 | sair do círculo ou avançar por cima no fim | novo (círculo que existe) |
| Leque curto | uma faixa fina (0,9 m) por orbe, 5 orbes, 9 m | 0,7 s | 6 por orbe | ficar entre faixas, ou avançar através | novo (hoje só na fase 3, sem aviso no chão) |

Descanso entre ataques 1,0 s (hoje 0,9 a 1,2). Não repete o mesmo ataque duas vezes seguidas (já existe).

### Interlúdio 1, "Marcas do Inverno" (em 66%)
Objetivo ativo: **apagar 3 marcas de geada** no chão (círculos de 2 m, em triângulo a 9 m do centro, nunca a menos de
6 m do paladino quando nascem). A marca se apaga quando o **círculo de luz** (Q) a cobre por 1,5 s, ou quando o
paladino fica de pé sobre ela por 3,0 s (caminho mais lento, para quem ainda não usa o círculo). Usa a zona
`Ground.Kind.BIND` que já existe. Cada marca apagada: +10 de Magia. Leitura de sentido: o inverno é o domínio de
Morvath no cânone; a luz o derrete (ver a seção 8).

| Pressão | Aviso no chão | Preparo | Dano | Como esquivar | Origem |
|---|---|---|---|---|---|
| Chuva sobre o paladino | círculo 2,2 m no paladino e 4 círculos de 0,9 a 1,5 m em volta | 0,9 a 1,5 s, a cada 6 s | 10 | sair dos círculos | existe |
| Anel com saída | 10 círculos de 1,2 m num anel de 5 m em volta do paladino, um deles faltando (a saída mais clara) | 1,2 s | 10 | sair pela abertura ou avançar por cima do anel | novo (círculos que existem) |
| Cópia ilusória | arco de 4,6 m, 120° | 0,8 s | 8 | igual aos cortes; a cópia some com 1 golpe | novo |
| Reforços | (aviso de cada esqueleto, já existe) | 0,9 s | 3 | igual ao comum | existe |

Até 3 cópias de pé, até 6 reforços vivos. **Falha (35 s sem apagar as 3):** cada marca que sobrou vira chão de
geada na fase 2 (o paladino anda 30% mais devagar sobre ele, sem dano) até ser apagada do mesmo jeito.

### Fase 2, "A corte dos mortos" (66% a 33%)
Entram as cópias (a arma da Hécate na fase 2) e os reforços. Preparos 15% mais curtos (já existe).

| Ataque | Aviso no chão | Preparo | Dano | Como esquivar | Origem |
|---|---|---|---|---|---|
| Três cortes | arco, como na fase 1 | 0,51 s cada | 10 cada | como na fase 1 | existe |
| Investida dupla | faixa 16 x 2,8 m, depois uma segunda faixa reapontada no fim da primeira | 0,8 s e 0,6 s | 12 cada | avanço para o lado duas vezes; a segunda faixa aparece só quando a primeira termina | novo (faixa que existe) |
| Cortes espelhados | Morvath e 2 cópias surgem a 5 m, cada um com seu arco (4,6 m, 120°) | 0,8 s, todos juntos | 10 (Morvath), 8 (cópia) | os arcos deixam um vão; avanço pelo vão. Bater numa cópia a desfaz | novo |
| Chuva | círculos, como hoje | 0,9 a 1,5 s | 10 | sair dos círculos | existe |
| Invocação | círculo de sombra em cada ponto de nascimento | 1,1 s | (o esqueleto ataca depois com o aviso dele) | afastar-se dos pontos | existe, com teto novo (2 por vez, até 4 vivos) |
| Anel com saída | como no interlúdio 1 | 1,2 s | 10 | sair pela abertura | novo |

### Interlúdio 2, "Ritual sobre a Emeth" (em 33%)
Morvath volta ao altar e ergue o ritual: **3 correntes** saem de 3 âncoras (nos obeliscos ou pilares da sala; posição
final com o environment-artist) e se prendem na lâmina da Emeth. Uma barra de corrupção enche em 20 s; cada corrente
de pé enche um terço da velocidade. Objetivo ativo: **quebrar as âncoras**. Cada âncora é um alvo parado, sem vida,
só com armadura (barra amarela de 200, quebra no fim como a armadura que já existe: `EnemyDef.armor`,
`Horde.armor_broken`). Com 4 a 7 dons, cerca de 2 a 3 s de golpes por âncora. Cada âncora quebrada: +10 de Magia e
a corrente estala de volta para o altar.

| Pressão | Aviso no chão | Preparo | Dano | Como esquivar | Origem |
|---|---|---|---|---|---|
| Espiral de orbes (do altar) | faixa fina por orbe no primeiro giro, depois o anel que gira devagar já é previsível | 0,7 s, ondas a cada 0,55 s | 6 por orbe | andar no vão que gira | existe (`BossRules.ring` com deslocamento), aviso novo |
| Leque | faixa fina por orbe, 7 orbes | 0,7 s | 6 | entre faixas | existe, aviso novo |
| Cópias | arco 4,6 m | 0,8 s | 8 | como antes | novo |
| Reforços | aviso de cada um | | | | existe, até 6 vivos |

**Resultado do ritual** (quando as 3 âncoras caem, ou aos 20 s): a corrupção fica no nível das correntes de pé no
fim, de 0 a 3 (ver a seção 5). Com as 3 quebradas antes de 20 s: nível 0, e Morvath começa a fase 3 atordoado.

### Fase 3, "A névoa" (33% a 0)
Mantém o que a fase 3 já tem (névoa, rajadas, atordoamento por golpes pesados) e ganha o teletransporte e a
divisão (armas da Hécate na fase 3).

| Ataque | Aviso no chão | Preparo | Dano | Como esquivar | Origem |
|---|---|---|---|---|---|
| Névoa | borda luminosa do anel que fecha (de 46 para 14 m em 12 s) | contínuo | 1,5 a cada 0,5 s fora | ficar dentro do anel | existe (fecha em 14 m, hoje 12) |
| Três cortes | arco | 0,51 s cada | 10 cada | como antes | existe |
| Passo na névoa | Morvath some (0,4 s), um círculo de 3 m aparece atrás do paladino e vira arco de 5,4 m, 150° | 0,9 s depois do círculo | 12 | avançar para a frente ou para o lado quando o círculo aparece | novo |
| Investida dividida | 3 faixas de 16 x 2,4 m que convergem no paladino (Morvath e 2 cópias) | 0,9 s | 12 (Morvath), 8 (cópia) | avanço no vão entre faixas; nunca as 3 cruzam no mesmo ponto sem deixar vão | novo |
| Rajadas | anel de 14 e leque de 7 alternados; faixa fina por orbe no leque, aro no chão no anel | 0,7 s, ondas a cada 0,55 s | 8 (hoje), proposta 6 | vão do anel, entre faixas do leque | existe, aviso novo |
| Feixe da coroa (opcional) | faixa de 18 x 1,2 m com uma seta do lado em que vai girar; gira 90° em 2 s | 1,0 s parada antes de girar | 10, com 1,3 s de proteção depois (já existe) | correr no sentido do giro ou avançar por cima da faixa | novo (aviso que gira: código novo) |
| Atordoamento | | | | 3 golpes pesados em 4 s: 2,6 s atordoado | existe |

Até 4 reforços vivos (a névoa aperta a sala). O feixe é o único ataque que pede um tipo novo de aviso; se ficar caro,
sai da primeira versão.

## 5. O ritual de corrupção da Emeth

### O que o cânone diz
- **A Emeth não está no cânone.** O nome é decisão do Daniel para este jogo (2026-11-14: "Emeth é o nome da espada,
  não do herói"), e o desenho é a imagem dele de 2026-11-15. Não há regra do mundo sobre o que pode acontecer com ela.
- O que está no cânone e sustenta a ideia: Morvath, o Lich-Rei do Sul, tem como domínio "a morte e o inverno sem fim,
  os mortos-vivos, o medo de morrer"; "o mal não cria, só imita"; a luz vem de Elun; vilões nunca usam palavras de fé.
- Por isso a proposta trata a corrupção como **uma crosta de inverno sobre a lâmina, nunca como a luz se apagando**:
  o frio cobre, a luz por baixo continua e quebra a crosta. **Pergunta para o Daniel** (seção 10).

### Mecânica
- Nível de corrupção de 0 a 3, decidido no fim do interlúdio 2 (correntes de pé).
- Cada nível: as ações da espada (ataque, especial, Ômega) fazem 15% menos dano (no máximo 45%). Entra como bônus
  negativo no `bonus_pct` de `DamageCalc.hit`, o mesmo lugar dos dons.
- No nível 3, os Ômegas do ataque e do especial ficam travados (o botão segurado faz o golpe simples).
- **Nada tira o controle:** andar, esquivar e o círculo de luz seguem iguais. (A Hécate transforma a jogadora; aqui a
  transformação é da espada, não do paladino.)
- **Limpar:** cada finalizador (o giro do 3º corte ou o Ômega do ataque) que acerta Morvath tira 1 nível. Atordoar
  Morvath (3 golpes pesados) tira tudo. Ao morrer Morvath, tudo some.
- Estado puro em `scripts/core/` (nível, quanto tira, quando limpa), testado.

### Leitura visual (proposta para o art-director; nada definido aqui)
- Na lâmina: uma crosta cinza violácea com rachaduras sobe da guarda para a ponta, um terço por nível (um parâmetro
  `corruption` de 0 a 1 no `emeth.gdshader`); o fio central (`CORE_*`) apaga um passo por nível; a esmeralda da guarda
  fica fosca.
- Nos golpes: a fita do corte perde o verde para um cinza frio, na mesma proporção.
- As correntes: um traço violeta fino do topo da âncora até a ponta da lâmina, que pulsa quando a barra enche.
- Ao limpar um nível: a crosta estala da ponta para baixo, lascas claras e um pulso verde curto da lâmina (sem luz
  nova, como o `PULSE_GLOW`).
- Na HUD: três marcas de gelo no losango do ataque, uma por nível (dono: ui-ux-designer).
- A crosta precisa ler bem também pelo raio-x do herói (os passes `xray`).

## 6. Duração estimada (a conta)

### DPS do paladino a partir de `tools/make_data.gd`
- Ataque em 3: corte 1 (20 de dano, preparo 0,06 s, volta 8/60 s), corte 2 (25, 0,11 s, 13/60 s), giro (60, 0,28 s,
  18/60 s). Tempo de simulação da sequência: 0,193 + 0,327 + 0,580 = **1,10 s** para **105 de dano**.
- Pausas de impacto (`hit_stop_ms` 25 + 65 + 70 = 0,16 s) não andam o relógio da partida, mas andam o relógio da
  parede: **1,26 s por sequência**, ou **83 de dano por segundo** sem dom, colado no chefe.
- Bônus de sequência (`DamageCalc.combo_bonus`, 1% por golpe até 40%, guardado 3 s): numa luta com interrupções,
  em média cerca de +20%.
- Especial à distância: 40 por 0,7 s (57 por segundo), útil na névoa e contra as âncoras.

| Cenário | Dons (exemplo do baralho atual) | Conta | DPS colado |
|---|---|---|---|
| 4 dons | golpe radiante (+40%, raro), brasas (cerca de 26 x 1,5 golpes no chefe a cada 3 s), um de esquiva, um de círculo | 83 x (1 + 0,40 + 0,20) + 13 | **cerca de 145** |
| 7 dons | golpe radiante (+55%), lâmina ardente (+35% no giro, que é 57% do dano: +0,20; queima 9/s), flagelo e brasas (cerca de 25/s juntos), mais 3 de suporte | 83 x (1 + 0,55 + 0,20 + 0,25) + 9 + 25 | **cerca de 200** |

### Tempo colado (aproveitamento)
- Medido no robô hoje (tabela da seção 1): 4 dons, 4765 de dano no chefe em cerca de 158 s úteis = **30/s**, cerca de
  21% de 145; 6 a 8 dons, 6050 em cerca de 96 s úteis = **60 a 63/s**, cerca de 30% de 200.
- Para gente, o Hades II espera algo como 40 a 50% do tempo batendo numa chefe da primeira região (estimativa nossa,
  não número do jogo; medir com gente, seção 7).

### Tempo de luta = 6050 / DPS útil + interlúdios + transições
- Interlúdios: cerca de 25 s cada (teto 35 s) = 50 s. Transições: entrada 2,4 s, 2 rugidos de 1,6 s, a queda final
  2,4 s, idas ao altar cerca de 2 s cada = cerca de 12 s.

| Quem | DPS útil | Fases de dano | Total |
|---|---|---|---|
| Gente, 4 dons (40% de 145) | 58 | 104 s | cerca de **2 min 46 s** |
| Gente, 7 dons (50% de 200) | 100 | 61 s | cerca de **2 min 03 s** |
| Robô, 4 dons (21% de 145) | 30 | 200 s | cerca de **4 min 22 s** (deve perder antes) |
| Robô, 7 dons (30% de 200) | 60 | 101 s | cerca de **2 min 43 s** |

Alvo: **2 a 4 minutos** com 4 a 7 dons, mediana perto de 3 min. As cópias e os reforços tiram tempo colado: se o
aproveitamento cair 10 pontos, a luta de 4 dons passa de 3 min. A recompensa de Magia dos interlúdios (Ômegas de 160)
compensa parte disso: 3 Ômegas extras = 480 de dano, cerca de 8% da vida.

## 7. Critérios de balanceamento (mensuráveis)

### Instrumentação nova (para o robô e para gente)
- `RESULT` ganha: `boss_time` (s da entrada à queda), `phase_time` (lista por fase e interlúdio), `objectives`
  (marcas e âncoras cumpridas), `corruption` (nível no fim do ritual), `hurt_by` (dano recebido por ataque),
  `unwarned` (dano recebido sem aviso ativo no chão), `adds_peak` e `adds_total` (reforços vivos no pico e somados).
- Em partida normal, o mesmo registro vai para `user://boss_log.json` (só com uma opção ligada), para o teste com gente.

### Robô (`tools/smoke.sh 300 --start=boss --boons=N --seed=1..20`, N = 5 e N = 8)
| Medida | Alvo |
|---|---|
| Vitória com 4 a 5 dons | 25 a 50% das sementes |
| Vitória com 6 a 8 dons | 60 a 85% |
| Duração das vitórias | mediana 150 a 240 s; nenhuma acima de 330 s |
| Interlúdio 1 cumprido antes de 35 s | 80% ou mais |
| Corrupção média no fim do ritual | 1 ou menos |
| Dano recebido de um único ataque | no máximo 35% do total; névoa no máximo 10% |
| `unwarned` | **0** em todas as sementes |
| Reforços | `adds_peak` no máximo 6, `adds_total` no máximo 20; cópias de pé no máximo 3 |
| Partida inteira `tools/smoke.sh 300 --seed=5` | continua chegando em Morvath |
| Custo | `step_ms` da luta no máximo 0,5 sem tela; na GPU (`tools/gpu.sh`), no máximo 10% de queda de fps contra a luta de hoje |

### Gente (o Daniel e quem ele chamar)
| Medida | Alvo |
|---|---|
| Chegar à fase 3 na 1ª tentativa | metade ou mais |
| Vencer em até 3 tentativas com 5 dons ou mais | metade ou mais |
| Duração | 2 a 4 min |
| "Morri por algo que não vi" (3 perguntas depois da luta) | no máximo 1 relato por luta |
| Entender o objetivo do interlúdio sem ler o texto | em até 5 s (gravação da tela) |
| Ritual: o jogador percebe que a espada mudou e por quê | 4 em 5 testadores |

## 8. História e mecânica

| Cânone | Na luta |
|---|---|
| Morvath, o Lich-Rei do Sul: a morte, o inverno sem fim | marcas de geada, chão de geada, crosta de inverno na Emeth, onda fria |
| Os mortos-vivos | reforços de esqueletos, com teto |
| O medo de morrer | a névoa que fecha a sala (o espaço some); sem mecânica de "medo" própria |
| "O mal não cria, só imita" | as cópias ilusórias: imitações vazias, que somem com 1 golpe e não deixam corpo |
| A luz vem de Elun | o círculo de luz apaga as marcas; a crosta nunca apaga a luz, só cobre, e quebra por dentro |
| Vilões não usam palavras de fé | os avisos da HUD do chefe falam de frio, sombra e reis, nunca de fé |
| Morvath não morre: é selado de novo (`personagens.md`) | **conflito**: hoje a luta termina com "Morvath derrotado" e o corpo dele some. Proposta: a queda vira a selagem (pergunta 1) |
| Cada selo foi fechado por um paladino do sangue do leão, que deu a vida; quatro guardiões seguram, nos quatro cantos | não usado sem o Daniel (perguntas 2 e 3) |

## 9. O que reaproveitar e o que é novo

### Reaproveitar (sem trocar por versão simplificada)
- A máquina de estados de `Boss` (`_choose`, `_go`, `_rest`, `ROAR`, `STUNNED`, `DYING`), a troca de fase
  (`_change_phase`: rugido, limpeza, empurrão), a névoa (`_make_mist`, `BossRules.mist_radius`), o atordoamento por
  golpes pesados (`BossRules.STAGGER_*`).
- `BossRules.phase_for` (só os limiares mudam para 0,66 e 0,33, com o teste `test_boss.gd` atualizado), `ring` e
  `fan` (espiral = `ring` com deslocamento que cresce).
- Avisos `Ground.add_warning`, `add_line_warning`, `add_arc_warning`; zona `BIND` do círculo de luz para apagar as
  marcas; `Projectiles.fire` com `ORB`.
- `Horde.spawn` para reforços e cópias; `Enemy.invulnerable`; armadura e `Horde.armor_broken` para as âncoras.
- `DamageCalc.hit` (`bonus_pct`) para a corrupção; `Magick.gain` para a recompensa.
- `Fx` (rugido, quadro de impacto, câmera lenta da queda), `hud.show_notice`, `T.t`.
- O fluxo de `Rooms` até `game.start_boss`, e `--start=boss`, `--boss-hp`, `--boons` para testar.

### Novo
- `BossRules`: limiares 0,66 e 0,33; travar a vida no limiar; orçamento de reforços (vivos por fase, total 20);
  progresso dos objetivos (marca por tempo dentro do círculo ou de pé); nível de corrupção (enche, decide, limpa).
  Tudo puro e testado.
- `Boss`: estados `INTERLUDE` (um só, com o objetivo vindo de dados), `MIRROR` (cortes espelhados), `BLINK` (passo na
  névoa), `SPLIT_DASH`, `RING_GAP`, `COLD_WAVE`, `BEAM` (opcional); ida ao altar; `break_armor` e `_on_struck` numa
  função só.
- Dados: `BossDef` (um Resource em `data/bosses/morvath.tres`, gerado por `make_data.gd`: limiares, tetos, danos,
  preparos, duração dos interlúdios), para que o balanceamento não precise de código; `morvath_shade` (cópia: 1 de
  vida, sem Magia, sem corpo) e `ritual_anchor` (âncora: só armadura, parada, não ataca) como `EnemyDef`. A âncora pede
  um comportamento parado sem ataque (talvez `EnemyDef.Behavior` novo).
- Aviso no chão para os orbes (faixas finas e aro) e, se ficar, o aviso que gira do feixe.
- Corrupção na espada: estado no `Player` ou no `Combat`, parâmetro no `EmethSword` (com o art-director).
- HUD: contador do objetivo, barra de corrupção, marcas no losango (ui-ux-designer).
- Robô (`bot.gd`): ir às marcas e erguer o círculo, bater nas âncoras, preferir o Morvath de verdade às cópias.
- `Game.result()`: os campos novos da seção 7.
- Textos novos em `data/text_pt.tres` (nomes dos interlúdios, avisos), depois de aprovados.

### Donos (para o plano do Game Director)
gameplay-engineer: `boss.gd`, `boss_rules.gd`, `make_data.gd`, `bot.gd`, `combat.gd`, `player.gd`, testes.
art-director: aparência das cópias (como se distinguem do verdadeiro sem enganar o aviso), da crosta, das correntes,
das marcas e da âncora. environment-artist: onde ficam as âncoras na sala. ui-ux-designer: HUD do interlúdio e da
corrupção. qa-performance: as medições da seção 7.

## 10. Perguntas para o Daniel
1. **Morvath "não morre, é selado" no cânone.** A luta deve terminar numa selagem, e não numa morte? Como ela aparece?
2. **Quem sela.** O cânone diz que cada selo foi fechado por um paladino do sangue do leão que deu a vida ali, com
   quatro guardiões nos cantos; o jogo fala em quatro paladinos. O herói de A Selagem é esse paladino? Ele morre no
   fim? (Isso muda o tom do final; o jogo pede tom de aventura.)
3. **Os quatro cantos.** Posso usar os quatro cantos da sala (os guardiões) como lugar dos objetivos? Ou isso é da
   camada "só o autor sabe"?
4. **A Emeth pode ser tocada pelo mal?** Ela não está no cânone. A crosta de inverno que cobre sem apagar a luz é
   aceitável? Ou a espada é intocável, e o ritual mira outra coisa (o paladino, a sala, o portal)?
5. **De onde vem a luz da Emeth?** De Elun, pelo paladino, pela própria espada? Isso decide como ela se limpa.
6. **As cópias:** "o mal só imita" serve de base para elas? Elas podem ter a figura do próprio Morvath?
7. **O inverno de Morvath e a família Geada dos dons do paladino** usam o mesmo frio. Isso confunde? A geada dos dons
   deveria ter outra cara (ou a de Morvath ser mais sombra que gelo)?
8. **O altar e o portal verde** ao norte: o que são na história? Morvath pode usá-los no ritual?
9. **A Lâmpada** (a vida do paladino numa pedra de luz, num nicho sob o leão) aparece nesta luta?
10. **Nomes:** "Marcas do Inverno", "Ritual sobre a Emeth", "A corte dos mortos", "A névoa" são de trabalho. Quer
    outros? Morvath fala durante a luta? (O cânone dá a ele a imagem do frio e dos reis, nunca fé.)
11. **Dificuldade:** o objetivo do interlúdio pode falhar com um custo (chão lento, espada mais fraca), ou deve ser
    impossível perder a parte do objetivo?
12. A variante de 7250 de vida entra como dificuldade futura (como os Votos do Hades II)?

## 11. Riscos
- **Escopo:** cópias, objetivos, âncoras, corrupção, robô novo e HUD nova somam um ciclo inteiro. Ordem sugerida, cada
  passo jogável: (1) limiares 66/33, avisos dos orbes, `BossDef`, tetos de reforço; (2) interlúdio 1; (3) cópias na
  fase 2; (4) interlúdio 2 e corrupção; (5) fase 3 nova; (6) feixe, se sobrar.
- **Leitura:** cópias no meio de esqueletos e da névoa podem confundir. Regra dura: aviso igual para todos, cópias no
  máximo 3, nunca dois grandes juntos. Revisão do art-director em captura real na GPU.
- **Castigo demais:** corrupção mais névoa mais reforços pode virar espiral de derrota. Por isso a corrupção limpa com
  finalizadores e com o atordoamento, e não tira controle.
- **Interlúdio que parece espera:** chefe invulnerável por até 35 s cansa se o objetivo for fácil demais ou longe
  demais. Medir o tempo dos interlúdios (alvo cerca de 25 s) e encurtar.
- **Robô:** hoje ele não sabe fazer objetivos; sem isso a métrica do robô não vale. O robô novo precisa vir junto.
- **Balanceamento:** a recompensa de Magia, a fase 3 com fecho em 14 m e o dano 6 nas rajadas mudam números; tudo
  passa pelo Game Director antes.
- **Lore:** sem respostas às perguntas 1, 2 e 4, o ritual e o final podem precisar de outra roupa; a mecânica (quebrar
  âncoras, limpar com finalizadores) sobrevive à troca de tema.
- **Desempenho:** cópias usam o mesmo modelo assado do chefe (mesmo lote da multidão); os avisos novos são poucos.
  Medir na GPU antes de entregar.
- **Teste encurtado:** com Morvath na sala 5 o jogador chega com 4 a 7 dons; com a região inteira (sala 11) chegará
  com mais, e a luta ficará mais curta. Rever os alvos quando a região voltar ao tamanho cheio.

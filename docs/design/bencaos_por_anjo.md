# Bênçãos por anjo (BO-3): 7 anjos x 6 botões = 42

Rascunho do `hero-designer` para o Daniel aprovar nomes e textos. Só as mecânicas fechadas (A modificadores com etiqueta, B gatilho de efeito, C `shield_on`); sem `stun`. Nenhuma age sozinha: toda carta vive num botão (Atq = mouse esq., Esp = mouse dir., Q = Brado, E = Investida, Sh = ultimate, Espaço = esquiva).
Notação: `_mod(id, base, [passos de nível], etiqueta)` escala com raridade (x1, x1,5, x2, x2,5); `_fixed` não escala; `skill{}` = SkillDef (`damage`, `count`, `radius`, `status_power` em 3 níveis; `duration` e `gap` em s). Textos: {a}{b} = números do dado, {dmg} {count} {cd} {radius}. "Ex." = id que já existe (28 ao todo, mais `redemoinho`, `floco_errante`, `fios_cinza`, `espuma` que mudam de botão); "Nova" = 10 ids novos (7 `ultimo_*`, `passo_firme`, `clarao_radiante`, `passo_atento`).
Medalhão: um glifo por botão (6 formas) tingido na cor do anjo, em vez de um por família; o Daniel ou o `art-director` desenha.
Ultimate (Sh): só entra no sorteio depois da Maestria; o novato vê 5 por anjo.

## 1. Sarael (Chama): "o que você toca continua queimando"
Fogo que age depois do golpe: dano ao longo do tempo, chão em brasa, chamas que giram, chuva de fogo. Joga de perto e em vaivém.
| Botão | id | | Nome | Texto | Mods / skill | Por que é diferente |
|---|---|---|---|---|---|---|
| Atq | golpe_brasa | Ex. | Golpe em Brasa | O ataque incendeia: {a} de dano por segundo. | `_mod(&"burn_dps",4,[2,2],&"light")` | O fogo básico, dano em fio sobre o grupo. |
| Esp | pesado_brasa | Ex.* | Peso em Brasa | A onda deixa brasa no chão por {b} s: {dmg} de dano por segundo a quem pisa. | `_mod(&"burn_dps",6,[3,3],&"heavy")` + skill CONSECRATE, trigger special, damage [6,9,12], duration 3, radius 2.5, status burn [4,5,6], gap 3 | Vira uma zona: o especial passa a ser posição, não só dano. |
| Q | circulo_brasa | Ex. | Brado em Brasa | O Brado queima quem empurra: {a} de dano por segundo. | `_mod(&"burn_dps",8,[4,4],&"cast")` | Queima em área 4 m: acende a sala de uma vez. |
| E | redemoinho | Ex.* | Redemoinho de Fogo | A Investida levanta {count} chamas que giram {b} s em volta de você. | skill ORBIT, trigger rush, damage [10,14,19], count [2,3,4], duration 4, radius 3, burn [4,6,8], gap 5 | Armadura de fogo de curta duração, cobre o corpo a corpo depois da Investida. |
| Sh | ultimo_brasa | Nova | Chuva de Brasas | O ultimate faz cair {count} brasas em volta: {dmg} de dano e queimadura. | skill STRIKES, trigger ult, damage [20,30,42], count [8,10,12], radius 2.2, burn [6,8,10], gap 0 | Fogo espalhado por toda a sala em vez de um alvo. |
| Espaço | passo_brasa | Ex. | Passo em Brasa | A esquiva deixa um rastro que queima: {a} de dano por segundo. | `_mod(&"dodge_ember_dps",6,[3,3])` | Sai da roda queimando quem a persegue. |
(*) Ex. com efeito novo: ganha o skill do gatilho.

## 2. Nivael (Geada): "o que para, quebra"
Congelar e estilhaçar: cada golpe prepara o gelo, o dano grande vem de bater no congelado. Ritmo de controle, distância média.
| Botão | id | | Nome | Texto | Mods / skill | Por que é diferente |
|---|---|---|---|---|---|---|
| Atq | golpe_geada | Ex. | Golpe de Geada | O ataque congela por {a} s e quem está congelado leva {b}% a mais. | `_mod(&"freeze_time",0.3,[0.15,0.15],&"light")` + `_mod(&"shatter_pct",0.25,[0.15,0.15])` | A única Bênção de ataque que cobra mais de quem já parou. |
| Esp | toque_geada | Ex. | Toque da Geada | A onda é {b}% maior e congela por {a} s. | `_mod(&"freeze_time",1.0,[0.5,0.5],&"heavy")` + `_fixed(&"wave_size_pct",0.2,[0.1,0.1],&"heavy")` | Congela em linha longa: junta a fila antes do Brado. |
| Q | circulo_geada | Ex. | Brado de Geada | O Brado cresce {b}% e solta um anel de gelo: {dmg} de dano, congela {a} s. | `_fixed(&"cast_size_pct",0.2,[0.1,0.1])` + skill NOVA, trigger shout, damage [14,20,28], radius 4.5, freeze [0.8,1.0,1.2], gap 6 | Congela a sala toda de uma vez, mas só a cada 6 s. |
| E | passo_geada | Ex. | Passo de Geada | A Investida lança {count} lâminas de gelo à frente: {dmg} de dano, congelam {a} s. | skill FAN, trigger rush, damage [14,20,28], count [3,5,7], radius 10, freeze [0.6,0.8,1.0], gap 5 | Congela a linha que você atravessa. |
| Sh | ultimo_geada | Nova | Peso do Inverno | O ultimate derruba um bloco de gelo: {dmg} de dano, congela {a} s. | skill METEOR, trigger ult, damage [60,90,130], radius [4,4.5,5], freeze [2.0,2.2,2.5], gap 0 | Um golpe grande num ponto; o resto fica parado para ser estilhaçado. |
| Espaço | floco_errante | Ex. | Flocos Errantes | A esquiva solta {count} flocos que giram {b} s e congelam. | skill ORBIT, trigger dodge, damage [8,11,15], count [2,3,4], duration 3, radius 3, freeze [0.5,0.6,0.7], gap 4 | Fugir vira defesa: o que persegue congela. |

## 3. Lumael (Luz): "dano limpo e vida de volta"
Dano direto sem esperar, cura ao matar, clarões: o caminho mais simples e o que mais perdoa. Distância curta a média.
| Botão | id | | Nome | Texto | Mods / skill | Por que é diferente |
|---|---|---|---|---|---|---|
| Atq | golpe_radiante | Ex. | Golpe Radiante | O ataque dá {a}% a mais de dano. | `_mod(&"damage_pct",0.25,[0.15,0.15],&"light")` | Dano puro, sem estado nenhum para gerir. |
| Esp | pesado_radiante | Ex. | Peso Radiante | A onda é {b}% maior e dá {a}% a mais de dano. | `_mod(&"damage_pct",0.2,[0.1,0.1],&"heavy")` + `_fixed(&"wave_size_pct",0.25,[0.1,0.1],&"heavy")` | Onda larga e forte (absorve a Onda Clara). |
| Q | circulo_radiante | Ex. | Brado Radiante | O Brado derruba {count} raios nos inimigos próximos: {dmg} de dano cada. | skill STRIKES, trigger shout, damage [15,22,30], count [3,4,5], radius 1.8, gap 4 | Os raios escolhem os alvos; Brado vira ataque. |
| E | passo_radiante | Ex. | Passo Radiante | A Investida dá {a}% a mais de dano e quem cai por ela devolve {b} de vida. | `_mod(&"damage_pct",0.4,[0.2,0.2],&"dash")` + `_mod(&"heal_on_kill",0.4,[0.3,0.3])` | A cura do Consolo agora tem de ser buscada, com risco. |
| Sh | ultimo_radiante | Nova | Chão Claro | O ultimate acende o chão por {b} s: {dmg} de dano por segundo e o ultimate dá {a}% a mais. | skill CONSECRATE, trigger ult, damage [10,14,18], duration 6, radius 4, gap 0 + `_mod(&"damage_pct",0.4,[0.2,0.2],&"ultimate")` | Zona de luz que se defende ficando dentro. |
| Espaço | clarao_radiante | Nova | Clarão | A esquiva solta um clarão onde começa: {dmg} de dano em {radius} m. | skill NOVA, trigger dodge, damage [14,20,28], radius [2.5,3,3.5], gap 1.5 | Afasta e fere quem estava colado. |

## 4. Shomael (Vigília): "um golpe a menos por vez"
Aguentar: escudo que absorve um golpe, vida maior, esquiva mais longa, chão que atrasa. Dá o menor dano e mais folga; para o novato que não chega ao guardião.
| Botão | id | | Nome | Texto | Mods / skill | Por que é diferente |
|---|---|---|---|---|---|---|
| Atq | golpe_firme | Ex. | Golpe Firme | O ataque alcança {a}% mais longe e dá {b}% a mais de dano. | `_fixed(&"reach_pct",0.12,[0.06,0.07],&"light")` + `_mod(&"damage_pct",0.1,[0.05,0.05],&"light")` | Bate de mais longe: fica fora do alcance deles. |
| Esp | pesado_firme | Ex. | Peso Firme | A onda alcança {a}% mais longe e abre um escudo por {b} s. | `_fixed(&"reach_pct",0.15,[0.07,0.08],&"heavy")` + `_mod(&"damage_pct",0.1,[0.05,0.05],&"heavy")` + shield_on special 1.5 s (níveis 1.5, 2, 2.5), recarga 12 s | O especial já é o ataque que expõe; aqui cobre a recuperação. |
| Q | circulo_firme | Ex. | Brado Firme | O Brado cresce {a}% e deixa o chão pesado por {b} s: inimigos lentos. | `_fixed(&"cast_size_pct",0.25,[0.15,0.15])` + skill CONSECRATE, trigger shout, damage [8,12,16], duration 4, radius [4,5,6], slow [4,4.5,5], gap 8 | Domina a área em vez de empurrar. |
| E | passo_firme | Nova | Passo Firme | A Investida abre um escudo por {a} s: absorve 1 golpe. | shield_on dash 1.2 s (níveis 1.2, 1.5, 1.8), recarga 8 s + `_mod(&"damage_pct",0.1,[0.05,0.05],&"dash")` | Entrar no meio da roda com garantia de uma batida. |
| Sh | ultimo_firme | Nova | Muralha | O ultimate abre um escudo por {a} s e dá {b} de vida máxima. | shield_on ult 6 s (níveis 6, 8, 10; 1 golpe a cada 3 s dentro) + `_mod(&"max_hp",20,[15,15])` | Única ultimate que não mata; compra tempo. |
| Espaço | passos | Ex. | Passos Leves | A esquiva ganha +{a} carga e você corre {b}% mais. | `_fixed(&"dodge_charges",1,[0,1])` + `_fixed(&"move_speed_pct",0.08,[0.06,0.06])` | Esquiva em sequência e perna mais rápida. |

## 5. Velael (Véu): "bate menos quem foi enfraquecido"
Fraqueza: o inimigo causa menos dano. Cada botão enfraquece de um jeito (um alvo, fila, área, chão, tudo); o ultimate aprofunda.
| Botão | id | | Nome | Texto | Mods / skill | Por que é diferente |
|---|---|---|---|---|---|---|
| Atq | golpe_veu | Ex. | Golpe Velado | O ataque enfraquece por {a} s. | `_mod(&"weak_time",2.0,[1.0,1.0],&"light")` + `_mod(&"weak_time",3.0,[1.0,1.0],&"finisher")` | Cada golpe enfraquece o alvo que você está tratando (o final dura mais). |
| Esp | pesado_veu | Ex. | Peso Velado | A onda é {b}% maior e enfraquece por {a} s. | `_mod(&"weak_time",3.0,[1.0,1.0],&"heavy")` + `_fixed(&"wave_size_pct",0.15,[0.1,0.1],&"heavy")` | Enfraquece em linha: a fila inteira de uma vez. |
| Q | circulo_veu | Ex. | Brado Velado | O Brado enfraquece por {a} s e cresce {b}%. | `_mod(&"weak_time",4.0,[1.5,1.5],&"cast")` + `_fixed(&"cast_size_pct",0.2,[0.1,0.1])` | Enfraquece todos em volta antes do embate. |
| E | passo_veu | Ex. | Passo Velado | A Investida deixa névoa por {a} s: quem entra fica fraco. | `_mod(&"weak_time",3.0,[1.0,1.0],&"dash")` + skill CONSECRATE, trigger rush, damage [4,6,8], duration 3, radius 2.5, weak [2,3,4], gap 5 | Cria uma faixa de segurança no chão. |
| Sh | ultimo_veu | Nova | Crepúsculo | O ultimate enfraquece tudo em {radius} m por {a} s e a Fraqueza corta {b}% a mais. | skill NOVA, trigger ult, damage [20,28,36], radius [7,8,9], weak [5,6,7], gap 0 + `_fixed(&"weak_pct",0.1,[0.05,0.05])` | Quase apaga a sala por segundos, sem congelar nem empurrar. |
| Espaço | fios_cinza | Ex. | Fios de Cinza | A esquiva solta {count} fios que giram {b} s e enfraquecem. | skill ORBIT, trigger dodge, damage [7,10,14], count [2,3,4], duration 3, radius 3, weak [1.5,2,2.5], gap 4 | Quem te persegue chega fraco. |

## 6. Galael (Maré): "abrir caminho e bater no que desliza"
Empurrar: o inimigo em movimento leva mais. Controla o espaço em vez de parar; combina com paredes e perigos da sala.
| Botão | id | | Nome | Texto | Mods / skill | Por que é diferente |
|---|---|---|---|---|---|---|
| Atq | golpe_mare | Ex. | Golpe de Maré | O ataque empurra {a}% mais e quem desliza leva {b}% a mais. | `_mod(&"push_pct",0.4,[0.2,0.2],&"light")` + `_mod(&"shove_pct",0.2,[0.15,0.15])` | Prepara o alvo e cobra do que já desliza (absorve Arrebentação). |
| Esp | pesado_mare | Ex. | Peso de Maré | A onda é {b}% maior e empurra {a}% mais longe. | `_mod(&"push_pct",0.6,[0.3,0.3],&"heavy")` + `_fixed(&"wave_size_pct",0.2,[0.1,0.1],&"heavy")` | Varre uma linha larga. |
| Q | circulo_mare | Ex. | Brado de Maré | O Brado empurra {a}% mais longe e alcança {b}% mais. | `_mod(&"push_pct",0.8,[0.4,0.4],&"cast")` + `_fixed(&"reach_pct",0.15,[0.1,0.1],&"cast")` | O Brado vira afastar a sala. |
| E | passo_mare | Ex. | Passo de Maré | A Investida empurra {a}% mais longe e dá {b}% a mais de dano. | `_mod(&"push_pct",0.8,[0.4,0.4],&"dash")` + `_mod(&"damage_pct",0.15,[0.1,0.1],&"dash")` | Arrasta o grupo adiante em vez de furar. |
| Sh | ultimo_mare | Nova | Maré Cheia | O ultimate lança uma onda de {radius} m: {dmg} de dano, empurra e atrasa. | skill NOVA, trigger ult, damage [40,60,80], radius [7,8,9], slow [2.5,3,3.5], gap 0 + `_mod(&"push_pct",1.0,[0.5,0.5],&"ultimate")` | Limpa o centro da sala; a parede faz o resto. |
| Espaço | espuma | Ex. | Espuma | A esquiva solta {count} bolhas que giram {b} s e atrasam. | skill ORBIT, trigger dodge, damage [9,13,18], count [2,3,4], duration 3, radius 3, slow [1.0,1.2,1.4], gap 4 | Segura quem corre atrás sem parar. |

## 7. Qeshael (Marca): "um alvo de cada vez, e ele cai"
Marcar e criticar: o marcado leva crítico de tudo. Joga na escolha do alvo e no tempo; distância média a longa.
| Botão | id | | Nome | Texto | Mods / skill | Por que é diferente |
|---|---|---|---|---|---|---|
| Atq | golpe_marca | Ex. | Golpe Marcado | O ataque marca por {a} s e o golpe final acerta crítico {b}% mais. | `_mod(&"mark_time",3.0,[1.0,1.0],&"light")` + `_mod(&"crit_pct",0.15,[0.1,0.1],&"finisher")` | O terceiro golpe é a execução do que o resto marcou. |
| Esp | pesado_marca | Ex. | Peso Marcado | A onda marca por {a} s e acerta crítico {b}% mais. | `_mod(&"mark_time",4.0,[1.5,1.5],&"heavy")` + `_mod(&"crit_pct",0.1,[0.05,0.05],&"heavy")` | Marca a fila e já cobra a primeira. |
| Q | circulo_marca | Ex. | Brado Marcado | O Brado marca todos por {a} s e cresce {b}%. | `_mod(&"mark_time",4.0,[1.5,1.5],&"cast")` + `_fixed(&"cast_size_pct",0.2,[0.1,0.1],&"cast")` | Marca a sala; a E e o Atq executam. |
| E | passo_marca | Ex. | Passo Marcado | A Investida marca por {a} s e acerta crítico {b}% mais. | `_mod(&"mark_time",3.0,[1.0,1.0],&"dash")` + `_mod(&"crit_pct",0.1,[0.05,0.05],&"dash")` | A Investida (35) com crítico é o maior golpe isolado. |
| Sh | ultimo_marca | Nova | Chuva de Flechas | O ultimate marca e fere {count} inimigos: {dmg} de dano; críticos {b}% mais. | skill STRIKES, trigger ult, damage [16,24,34], count [6,8,10], radius 1.8, mark [4,5,6], gap 0 + `_mod(&"crit_pct",0.2,[0.1,0.1],&"ultimate")` | Marca e fere de longe: abre a sala para o resto do kit. |
| Espaço | passo_atento | Nova | Olhar Rápido | A esquiva marca quem está perto por {a} s. | skill NOVA, trigger dodge, damage [6,9,12], radius 4, mark [3,3.5,4], gap 2 | Esquivar vira escolher o próximo alvo. |

## Os 12 Elos (refeitos sobre as 42; efeito igual salvo nota)
Cada lista é "uma de cada" (`requires_sets`). Famílias inteiras (as 6 do anjo): CHAMA, GEADA, LUZ, VIGILIA, VEU, MARE, MARCA.
LUZ_HIT = {circulo_radiante, clarao_radiante, ultimo_radiante} (as que acertam de longe: o "luz" do efeito).
| Elo | Sets | Efeito | Nota |
|---|---|---|---|
| vapor | CHAMA x GEADA | `steam_time` 2 | igual |
| aurora | LUZ_HIT x GEADA | `freeze_time` 0.8 `luz` | agora só os raios, o clarão e o Sol |
| chama_viva | CHAMA x LUZ_HIT | `burn_dps` 5 `luz` | idem |
| bastiao | {passo_firme, ultimo_firme, pesado_firme} x LUZ | `shield_burst` 40 | base é qualquer escudo; Luz dá a explosão |
| rastro | VIGILIA x CHAMA | `dodge_ember_dps` 8 | igual |
| passo_frio | VIGILIA x GEADA | `freeze_time` 1.0 `dash` | igual |
| nevoa_gelida | VEU x GEADA | `freeze_time` 0.8 `heavy` | igual |
| cinza_viva | VEU x CHAMA | `burn_dps` 5 `light` | igual |
| mare_ardente | MARE x CHAMA | `burn_dps` 6 `cast` | igual |
| correnteza | MARE x VIGILIA | `push_pct` 0.5 `dash` | igual |
| mira_clara | LUZ_HIT x MARCA | `mark_time` 3 `luz` | como aurora |
| olho_firme | MARCA x VIGILIA | `crit_pct` 0.2 `heavy` | igual |
Nenhum Elo sai: todos têm base possível (Bastião fica com 3 fontes de escudo; é o mais raro, de propósito).

## Os 4 Salmos (`requires`, três grupos, `dom:` mantidos)
- **sentinela** (Brado): g1 = circulo_brasa, circulo_geada, circulo_radiante, circulo_firme, circulo_veu, circulo_mare, circulo_marca; g2 = passos, ultimo_firme, passo_firme, pesado_firme, golpe_firme; g3 = bastiao, rastro, passo_frio, dom:reserva, dom:lamina_faminta, dom:coracao_da_emeth.
- **abrigo** (esquiva): g1 = passos, passo_brasa, floco_errante, clarao_radiante, fios_cinza, espuma, passo_atento; g2 = passo_firme, ultimo_firme, passo_radiante, circulo_firme; g3 = rastro, passo_frio, bastiao, dom:passo_encadeado, dom:fio_do_passo, dom:investida.
- **pastor** (especial): g1 = toque_geada, pesado_brasa, pesado_radiante, pesado_firme, pesado_veu, pesado_mare, pesado_marca; g2 = golpe_radiante, circulo_radiante, passo_radiante, clarao_radiante, ultimo_radiante; g3 = aurora, chama_viva, dom:corte_crescente, dom:onda_carregada, dom:onda_atravessante.
- **rocha** (ataque): g1 = golpe_brasa, golpe_geada, golpe_radiante, golpe_firme, golpe_veu, golpe_mare, golpe_marca; g2 = ultimo_firme, passo_firme, pesado_firme, toque_geada, ultimo_geada; g3 = vapor, bastiao, dom:quarto_corte, dom:golpe_sem_fim, dom:furia_plena, dom:fio_longo.

## Riscos e código que pede
- Código novo (BO-2): trigger por botão no SkillDef (`attack_finisher, omega, special, shout, rush, dodge, ult`) e `duration`/`gap`; `shield_on` por botão (com `shield_cooldown` por origem); etiquetas `finisher`, `omega`, `ultimate`; `Boon.Slot` com E e Shift; `shatter_pct`, `shove_pct`, `weak_pct` já existem. Tudo mais é dado.
- Mais forte: Qeshael (crítico + Investida 35 + Brado marcando tudo); Sarael (CONSECRATE + dot em horda); Nivael ao estilhaçar com Elo Vapor. Mais fraca: Shomael sem cura nem dano (pesa o escudo de 1,2 s no novato); Velael só vale se a Fraqueza (-25%) for lida pelo jogador.
- Esquiva com skill (Sarael não, Nivael, Lumael, Velael, Galael, Qeshael) usa `gap` de 1,5 a 4 s para não virar spam: o Espaço continua sem dano base.
- `heal_on_kill` e `max_hp` são globais (sem etiqueta): só a carta do botão os traz. Medir cura de Lumael no novato (30 de vida).

## Perguntas ao Daniel (respondidas em 2026-11-22: ver `docs/backlog.md`, decisões 6 a 10; os ajustes das 42 em `director_review_2026-11-22.md` seção 3)
1. Os nomes e textos acima servem? Em especial os nomes dos 7 ultimates.
2. `redemoinho`, `floco_errante`, `fios_cinza`, `espuma` mudam de botão e perdem o giro permanente: aceito (BO-1)?
3. Shomael escudo no Esp, na Investida e no ultimate (três cartas de escudo): ou deixo só a Investida e o ultimate?
4. Lumael é a única que cura (na Investida); a cura do Consolo sai do sorteio. Pode?
5. Raridade lendária: só do guardião e de Morvath, ou 1% no sorteio comum (BO-2)?

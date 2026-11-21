# A Maga

- **Data**: 2026-11-21. **Autor**: `hero-designer`. Proposta; números de partida. Sem nome próprio nem origem (ver Perguntas).
- **Fantasia**: resolve a sala de longe com luz, posiciona o campo e teletransporta-se antes de ser alcançada.
- **Papel e distância**: dano à distância e controle de área, 8 a 14 m. **Arma**: cajado (modelo `w_staff` já existe em `assets/models/meshy/`). **Ritmo**: rajada curta, posicionar, esperar a recarga, explosão.
- **Recurso próprio: Brilho** (0 a 3 cargas em losangos, sem barra): cada orbe do Ataque que acerta o 3º alvo ou a cada 4 acertos dá 1 Brilho; o **Especial** gasta todas as cargas e ganha +25% de dano por carga. Não é a Magia (que paga o Ômega e a ultimate).

## 1. As 5 habilidades e a travessia
| Botão | Papel | O que faz | Custo, recarga | Preparação, recuperação (s) | Cancela | Lê na tela |
|---|---|---|---|---|---|---|
| Esquerdo | **Ataque**: Rajada | 3 orbes seguidos na mira (8 de dano cada, 14 m, ritmo de 0,3 s); o 3º é maior (14) | sem custo | 0,10 / 0,20 | esquiva e Blink | orbe azul-esmeralda sobe do cajado; número claro |
| Direito | **Especial**: Lança de Luz | raio fino que atravessa tudo em 12 m (40 + 25% por Brilho), segurar 0,65 s = Ômega com 80 e área | 1,5 s de recarga (Ômega 10 Magia) | 0,25 / 0,30 | só esquiva | linha no chão até o fim, faíscas |
| Q | **Poder**: Campo de Luz | zona de 3 m no cursor, 4 s: dá 10 de dano por segundo e deixa lento; a Bênção de família colore (queima, gela, ou cura aliado) | 10 s | 0,2 / 0,15 | esquiva | círculo no chão com aro que se fecha |
| E | **Invocação**: Pilar | planta um pilar de luz que acerta o mais perto a cada 0,8 s por 6 s (10 por acerto); no máximo 2 | 8 s | 0,3 / 0,2 | esquiva | pilar com anel que se apaga |
| Shift | **Ultimate**: Chuva de Estrelas | 8 quedas em 3 s no cursor, 6 m (60 cada), área marcada; a Maga fica parada, mas protegida só os 0,3 s iniciais | carga (Magia gasta, dano, vida perdida) | 0,3 / 0,4 | esquiva corta e perde as quedas restantes | marcas de impacto no chão antes de cair |
| Espaço | **Blink** | teletransporte de 4 m na direção do movimento, 12 quadros protegidos, 2 cargas (0,9 s cada), deixa um brilho que explode ao reaparecer (15 em 2 m) | cargas | 0,05 / 0,10 | tudo | rastro de luz nos dois pontos |

**Passiva**: cada finalizador (3º orbe, Ômega, Blink que acerta) devolve 2 de Magia, como o Guerreiro, e **ganha Brilho** só nos orbes (identidade).
**Mapa de botões** especial: ultimate no Shift (recomendação).

## 2. Bênçãos por botão
| Família | Esquerdo | Direito | Q | E | Shift | Blink |
|---|---|---|---|---|---|---|
| Chama | orbes queimam | a lança deixa brasas | campo queima | pilar solta faíscas de fogo | quedas queimam | o brilho queima |
| Geada | orbes gelam | lança deixa lento | campo gela | pilar gela o alvo | congela a área no fim | o brilho congela |
| Luz | orbes mais largos | lança mais longa | campo cura 1 por abate | pilar mais lento e mais forte | +25% de carga | o brilho atordoa |
| Vigília | orbes dão 0,5 s de proteção a cada 4 acertos | lança empurra | campo reduz o dano de quem está dentro | pilar atrai o ataque (os inimigos o acertam primeiro) | ultimate protegida 1 s | Blink dá 1 s de proteção após o 2º |

## 3. Dons (árvore, 4 ramos como a do Guerreiro)
- **Orbe**: entrada *Orbes Gêmeos* (a Rajada sai com 2 por vez); meio *Orbe Teleguiado*; ápice *Chuva de Orbes* (cada Brilho cheio solta 3 orbes).
- **Lança**: entrada *Lança Longa*; meio *Lança Dupla* (segunda lança depois de 0,4 s); ápice *Raio Atravessante* (atravessa guardiões).
- **Campo e Pilar**: *Campo que Segue* (o campo vai atrás do cursor 1 s), *Pilar Gêmeo* (3 pilares), ápice *Constelação* (os pilares ligam o dano).
- **Blink**: *Blink Duplo* (3 cargas), *Eco* (o brilho dói 30), ápice *Passo Explosivo* (o Blink concede 1 Brilho).
- Sustento no centro: *Firmeza*, *Respiro*.

## 4. Três combinações só dela
1. **Brilho cheio, Lança**: 3 Brilhos acumulados com a Rajada, a Lança sai com +75% e atravessa a sala toda.
2. **Campo, Pilar e Rajada**: o campo prende o grupo lento, o pilar o mata aos poucos e ela continua atirando de longe.
3. **Blink explosivo e Ômega**: Blink dentro do grupo (o brilho dói), Blink de volta, Lança em Ômega.

## 5. O que a distingue
Distância (outros três são corpo a corpo ou médio), recurso por acerto de rajada, travessia que muda de lugar, controle por zonas e pilares, ultimate de área marcada (decisão "para onde").

## 6. Riscos
- **Forte demais**: distância + Blink 2 cargas; limitar com o alcance dos inimigos atiradores (já fogem do herói), com dano baixo por orbe e com a vida baixa (Maga: 24 de vida vs 30, `HeroDef.max_hp`).
- **Fraca demais**: sem proteção no ataque e sem empurrão; o Blink e o Campo precisam ser baratos.
- **Chefe**: dano seguro de longe quebra Morvath; as fases dele têm tempestade e erupções que cobrem a arena (já impedem ficar parado).

## 7. Reuso e código novo
| Item | Reaproveita como dado | Pede código | Estimativa |
|---|---|---|---|
| Rajada (disparo mirado, vários orbes) | `Projectiles.Kind.ORB/BOLT`, `Combat.throw_wave`, `ComboNode.wave_bolt` | ataque que é disparo e não arco (`Combat`), mira longa | M |
| Brilho (cargas) | losangos do HUD, `GiftState` | recurso novo e HUD | M |
| Lança (atravessa) | onda do Guerreiro, `Onda Atravessante` | tiro que atravessa e acerta uma vez por alvo | P |
| Campo | `Ground.Zone` (dano e lentidão) | zona no cursor com cast à distância | P |
| Pilar | `Ground.Zone.follow/strike` (Sentinela) | zona fixa que golpeia o mais perto | M |
| Chuva de Estrelas | `Ultimates.vortex` (padrão de área) | quedas sequenciais no cursor | M |
| Blink | esquiva do `Player` | teletransporte e eco explosivo | M |
| Herói | `HeroDef`, `Combo` | modelo e animações da Maga (Meshy: custo a estimar pelo `art-director`, regra dos créditos) | G |
| **Total** | | | **G** |

## 8. Perguntas ao Daniel
1. A Maga é paladina da Ordem de Erukh, outra ordem, ou companheira? (Cânone só tem "magias divinas" da Ordem.) Nome próprio: deixar "A Maga" até você decidir?
2. O cajado `w_staff` já feito é para ela? 
3. Vida 24 (frágil) ou 30 como os outros?

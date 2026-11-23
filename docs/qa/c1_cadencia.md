# C1: auditoria de cadência e justiça dos golpes novos (2026-11-22)

Método: leitura de `git diff` do C1 (`horde.gd`, `combat.gd`, `player.gd`, `enemy_def.gd`, `tools/make_data.gd`) e dos números.
Nada foi capturado nem rodado; tudo abaixo é **inferência por números**, e as porcentagens de dano são **estimativa** a
remedir (12 sementes). Base: herói 6,75 m/s, vida 30, esquiva de 0,2 s (5,6 m) com 0,3 s protegida, `hurt_invuln` 1,3 s
(`make_data.gd:1715`), U = 80. Reação humana contada como 0,25 s (estimativa).

## Fato que muda a conta da soma injusta
Depois de cada golpe sofrido o herói fica 1,3 s invulnerável. Logo, com 30 de vida, o máximo é um golpe a cada 1,3 s: a
segunda flecha, o segundo e o terceiro orbe e a explosão do corredor que caem dentro dessa janela **não ferem**. A soma
injusta não vem de rajada em um instante, vem de **duas ameaças que travam a mira ao mesmo tempo** (o esquiva só cobre
uma). Pior caso razoável: esqueleto 5 + besteiro 5 + corredor 8 em 1,3 s a 1,3 s = 18 (60% da vida) em 3 s, só se o jogador
ficar parado. P1, não P0.

## Por inimigo
| Inimigo | Tempo de reação real | O que se vê e ouve | Nível | Correção |
|---|---|---|---|---|
| Esqueleto rastreado (`aim_lock` 0,25, preparo 0,9, investida 8,75 m/s por 0,3 s = 2,6 m, descanso 1,2, 3 juntos) | A linha segue até 0,65 s e trava por 0,25 s, mais o voo (0,1 a 0,3 s). Sair da linha de 1 m de meia largura leva 0,15 s: sobra margem de cerca de 0,1 a 0,3 s; é justo com um, apertado com três | linha vermelha girando e firmando; brilho na lâmina (`T.GLINT`); sem som novo | P1 | `max_attackers` 3 só se os preparos começarem com 0,35 s de diferença (escalonar em `horde.gd:737`, onde se checa `attackers(d)`); `aim_lock` 0,25 para 0,3 (`make_data.gd:270`). Comentário da linha 269 ainda diz "2 soldiers" |
| Corredor que explode 0,6 s depois de morrer (`death_burst` 0,6, largura 2,6, dano 8) | 0,6 s de aviso; sair de 1,3 m leva 0,2 s; a finalização do combo prende o herói cerca de 0,4 s (recuperação), sobra 0,2 s: **tolerável, justo** | aviso de círculo cor `DEAD_CRIMSON` no chão onde caiu, mas sem som próprio | P1 (som), P2 (cadeia) | Som de pavio no `Audio.play` ao morrer (arquivo `horde.gd` perto de `death_burst`); com 3 ou mais mortes juntas os avisos se sobrepõem: limitar a 2 explosões vivas (soma de 16); `death_burst` 0,6 para 0,7 se a recuperação do golpe 3 passar de 0,45 s |
| Escudo, bloqueia 70% de frente (`front_block`, 75 graus), onda abre 3 s | Golpe leve cai de 15 para 5 (`roundf(4,5)`): 17 golpes para 255 de vida, sem uma janela é inviável de propósito. A onda custa 12 de mana e abre 3 s: 3 s dão cerca de 6 golpes (30 de dano ao Escudo, 12%), pouco | faíscas no escudo e a palavra de abrir; **nada mostra quando a guarda fecha de novo** (`open_t` não tem desenho) e **a guarda aberta e a fechada têm a mesma silhueta** | P1 | Mostrar `open_t`: escudo apagado enquanto aberto e piscar 0,5 s antes de fechar (`horde.gd:1371`, `tells.armor_break` já existe). `front_open` 3,0 para 4,0 (`enemy_def.gd`, valor no `make_data.gd:320`). Elite herda 0,7 (par `_pair`): para o elite usar `front_block` 0,6. Também abre durante `RECOVER` (já certo) |
| Besteiro, 2ª flecha rastreada (preparo 0,8, intervalo 0,75, `shot_relock` 0,4, 16 m/s, alcance 12 m) | A linha da 2ª segue por 0,35 s e trava por 0,4 s; o voo é 0,1 a 0,75 s: de 0,5 a 1,15 s para sair. **Justo** para quem esquivou a 1ª. Mas a esquiva da 1ª (0,3 s protegida) não cobre a 2ª, 0,75 s depois: exige duas leituras | duas linhas laranja em sequência; o 2º aviso aparece só no disparo da 1ª (`horde.gd:541`, 0,5 de largura) | P1 (volume), P2 (leitura) | Ver "metas de dano" abaixo. Acender a 2ª linha já 0,2 s antes do disparo da 1ª não ajuda: manter |
| Sacerdote blinda 3 vizinhos a cada 5 s (40 de blindagem, raio 10, só `armor<=0`) | Sem reação exigida, é prioridade. 40 de blindagem são cerca de 3 golpes de 15: esqueleto de 4 para 7 golpes. Se cair os fios somem (`_end_wards`) | anel e fios de luz saindo dos blindados; a quebra mostra `armor_break` | P2 | Blindar também feiticeiro e besteiro pesa no dano que ferem; excluir `Behavior.ARCHER` de `_step_ward` (`horde.gd:1385`) ou `ward_armor` 40 para 30 se o dano deles não cair |
| Cavaleiro rastreia (`aim_lock` 0,2, preparo 1,0, 18 m/s por 0,7 s) e invoca 2 (máx. 4) | Investida a 10 m: 0,2 s de trava + 0,55 s de voo = 0,75 s; a 4 m: 0,2 + 0,22 = 0,42 s, menos do que 0,25 de reação mais 0,25 para sair de 1,7 m (largura 2,4). **Injusto de perto, só a esquiva salva** | linha larga seguindo e travando; invocação em pé com espada e escudo (1,0 s), esqueletos saindo com `shadow` e som `summon` | P1 | `aim_lock` 0,2 para 0,3 e **não rastrear a menos de 5 m** (ficar travada), em `horde.gd:843`. A invocação parada de 1,0 s é a janela de ataque legítima: ótima. Com os 2 do Cavaleiro entram 4 esqueletos de 3 em 3: 4 ao mesmo tempo é teto, `max_attackers` já limita |
| Brado absorve um golpe (`buff_ward` 1, 0,5 s de invulnerável, 12 s?) | Não exige reação; é um seguro. Pior caso: gasto num dano pequeno (queimadura, arma de sala) | burst `heal` verde, palavra `word_ward`, som `shield` | P1 | `take_ward` (`gift_state.gd`) só valer para dano de inimigo de 4 ou mais, nunca ticks de perigo de sala; conferir em `player.gd:961`. Não consome durante a Investida do Brado (já certo) |

## Metas de dano: besteiro e feiticeiro em torno de 20% cada (estimativa, remedir)
Hoje: besteiro 26% a 37%, feiticeiro 19% a 28% dos golpes levados. Causa: 2 flechas de 5 por rajada com descanso 1,8 s
(`make_data.gd:312`, 2 desvios exigidos por rajada) e feiticeiro com 3 orbes teleguiados de 7 (era 6).
- **Besteiro**: `attack_cooldown` 1,8 para 2,6 (taxa de rajada -31%: 26 a 37% passa para cerca de 18 a 26%); `max_attackers` 2 mantém.
  Manter o dano 5 (1 golpe por rajada ainda dá 5). Se ainda passar de 25%, `retreat_time` 1,5-1,75 para 2,0-2,3.
- **Feiticeiro**: `attack_damage` 7 para 6 (volta ao de antes: -14%), `attack_cooldown` 0,8+1,85 para 0,8+2,2 (-11% de taxa):
  de 19 a 28% para cerca de 15 a 22%; `keep_away` 0,8 fica. O elite (`attack_cooldown` 0,8+1,0, 7 orbes) já bate bastante: não
  mexer aqui, olhar depois.
- Em ambos o dano é limitado por `hurt_invuln` de 1,3 s, então baixar a taxa vale mais do que baixar o dano.
- Aceite: 12 sementes, besteiro e feiticeiro entre 16% e 24% dos golpes levados cada; esqueleto+corredor 10% ou mais (meta do CB).

## Resumo por gravidade
- **P0**: nenhum encontrado pela leitura (não há deslocamento nem estado inválido novo visível; o Brado e o Cavaleiro mantêm o estado).
- **P1**: Cavaleiro de perto (aim_lock e distância mínima), esqueletos três juntos sem escalonar, guarda do Escudo sem sinal de
  fechar, besteiro e feiticeiro acima de 20%, Brado gastando em dano pequeno, corredor sem som.
- **P2**: cadeia de explosões, Sacerdote blindando atiradores, comentário velho de `max_attackers`.

## Para conferir em captura depois (quem captura é a sessão principal)
Escudo aberto e fechado lado a lado, a linha do esqueleto travando em 3, o aviso da explosão sob o corredor morto.

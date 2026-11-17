# E6: Juramentos (D-63)

Dificuldade por escolha, feita antes de uma descida e aberta depois da primeira vitória sobre Morvath, como os votos do
Juramento do Invisível do Hades II (o "Oath of the Unseen", aberto depois de vencer Cronos uma vez). Mecânica e números
copiados do Hades II onde o nosso jogo já tem o sistema (tabela de `docs/design/hades2_sistemas.md`, seção dos Votos
da Noite e Medo); nomes e textos nossos, em português simples, sem lore nova. O Medo de lá é o **Peso** daqui.

Decisões tomadas sem o Daniel (o PO estava fora; a regra era decidir e registrar). Cada uma pode mudar.

## Regras

- Cada Juramento tem níveis (1 a 3); cada nível tem um número e um Peso. O Peso do nível n é a soma dos n primeiros.
  O Peso total é a soma de todos os Juramentos feitos.
- Fechados até a primeira vitória (`Save.data.wins > 0`). Antes, a tela diz só "Sele Morvath uma vez para fazer
  Juramentos." (`jur_locked`).
- A escolha fica no save e vale para as próximas descidas até ser mudada (como no Hades II).
- Nunca sem save: `--nosave`, os testes e o robô descem sem Juramentos, a não ser com `--juramentos=id:nível,...`.

## Os nove Juramentos

| id | Nome no jogo | Voto do Hades II | Efeito por nível | Peso por nível (total) | Onde age |
|---|---|---|---|---|---|
| pain | Golpes Duros | Dor | inimigos +20% / +60% / +100% de dano | 1, 2, 2 (5) | `Player.hurt_scale` |
| grit | Mortos Resistentes | Firmeza | inimigos +10% / +20% / +30% de vida | 1, 1, 1 (3) | `Horde.vow_hp` (todos, elites, guardiões e Morvath) |
| frenzy | Passo Ligeiro | Frenesi | inimigos +20% / +40% mais rápidos | 3, 3 (6) | `Horde.speed_scale` |
| hordes | Mais Mortos | Hordas | +20% / +40% / +60% de inimigos | 1, 1, 1 (3) | `Juramentos.more_waves` |
| menace | Mais Elites | Ameaça | +10 / +25 pontos de chance de cada parte da luta vir como elite | 1, 2 (3) | `Juramentos.stage_for` |
| scars | Feridas Abertas | Cicatrizes | a cura vale 75% / 50% / 0% | 1, 1, 2 (4) | `Player.heal_scale` |
| debt | Preço Alto | Dívida | preços da loja +40% / +80% | 1, 1 (2) | `Juramentos.stage_for` |
| denial | Escolhas Perdidas | Negação | ao tomar uma Bênção, 2 das não escolhidas somem da descida | 2 (2) | `BoonState.banned`, `Game._deny_others` |
| rivals | Morvath Implacável | Rivais | Morvath descansa 25% menos e ergue 2 mortos a mais de pé | 2 (2) | `Juramentos.boss_for` |

Peso máximo: 30 (no Hades II, 67 com os 17 votos).

### Como cada um foi adaptado

- **Dor** multiplica todo dano que o herói leva (`hurt_scale`), junto com a maldição da Provação. Hoje todo dano no
  herói vem de inimigo ou de Morvath, então é o mesmo que o voto.
- **Firmeza** vale para todos, também elites, guardiões e Morvath (o Hades II diz "inimigos", e lá os chefes também
  ganham). Morvath com 30% a mais tem 7865 de vida.
- **Frenesi**: lá os inimigos ficam mais rápidos em tudo. Aqui só o andar: apressar a preparação encurtaria os avisos no
  chão, que são a regra de justiça do jogo (todo ataque tem aviso). Por isso o Peso de 3 por nível ficou como lá.
- **Hordas** cresce cada onda em round(tamanho x valor), repetindo os tipos da onda a partir do primeiro (o destaque da
  luta). O teto de inimigos de pé (`EncounterGen`) não muda: a mais espera a vez. Guardião e Morvath não mudam.
- **Ameaça**: lá traz inimigos da região seguinte, que não temos. Aqui, o equivalente mais próximo: inimigos mais fortes,
  as elites; a chance de cada parte da luta vir como elite sobe 10 ou 25 pontos (as mesmas porcentagens do voto). As
  elites continuam só desde `elite_from_depth` e no máximo `max_elite_types` por luta.
- **Cicatrizes** vale para toda cura (tudo passa por `Player.heal`: fonte, coração, loja, descanso, Dons e Bênçãos de cura).
- **Dívida** arredonda o preço novo (150 vira 210 e 270).
- **Negação**: depois de tomar uma Bênção de uma tiragem, as duas primeiras das outras saem da descida (nunca mais
  aparecem nas cartas). Não vale para a escolha da romã nem quando se toma um Salmo.
- **Rivais**: lá os guardiões ganham golpes novos; não temos golpes novos para Morvath sem sistema novo. Aqui ele fica
  mais duro com o que já tem: descansos entre ataques (`BossDef.rest`, `chain_rest`) 25% menores e 2 invocados a mais de
  pé em cada fase que invoca e no ritual (`adds_cap`, `ritual_cap`). Um nível só, Peso 2 (o da primeira região lá).

### Ficaram de fora (pedem sistema novo)

Proteções (escudos que absorvem golpes, a armadura só existe nas elites), Retorno (morto que volta), Presas (vantagens
para quem tem armadura), Sombra (servo sombrio do guardião), Renúncia (a primeira Bênção vira nada), Tempo (relógio na
HUD e dano por segundo: pede a HUD, que é do ui-ux-designer; o candidato mais fácil para depois), Vazio (Fôlego, que
não temos) e Soberba (Magia travada por raridade).

## Recompensa

- Maestria: a vitória com Peso dá `MasteryCurve.weight_xp` 3 XP por ponto de Peso (fonte `juramentos` no
  `MasteryReport`, "Juramentos"). Peso 30 dá 90 XP, menos que a primeira vitória (100). Nosso: o Hades II paga em
  Pesadelo, que não temos; pequeno para não acelerar a Maestria, que já deixa o jogo fácil (backlog).
- O save guarda o maior Peso vencido (`juramentos.best`), mostrado na tela.

## Dados e código

- `JuramentoDef` (`scripts/core/juramento_def.gd`): `id`, `name_key`, `desc_key`, `stat`, `values` e `weights` por
  nível, `shown` (como o número aparece: a mais, o que sobra, contagem), `order`. Dados em `data/juramentos/`, gerados
  pela parte `juramentos` do `tools/make_data.gd`.
- `Juramentos` (`scripts/core/juramentos.gd`, puro): níveis, Peso, `scale`, `stage_for`, `boss_for`, `more_waves`,
  `denial`, `parse` (`--juramentos`), `unlocked`, `block` e `record_win` (save).
- Ganchos: `Game._swear_juramentos` (cria e passa a vida para a `Horde`), `Rooms.setup` (fase), `Rooms._apply_curse`
  (velocidade, cura, dano, multiplicando com a Provação), as ondas no `Rooms._enter`, `Boss.setup`, `Game._take`.
- Save versão 4: `juramentos` = `{ranks: {id: nível}, best: Peso}`. Saves antigos abrem sem nenhum
  (`tests/fixtures/save_v4.json`).
- `RESULT` e registro: `juramentos` (id: nível) e `weight`. O registro não mudou de versão (campos novos, como os da E4
  e da E5; linhas antigas sem eles valem como nenhum).
- Tela: `JuramentoScreen` (`scripts/ui/juramento_screen.gd`). Depois da primeira vitória, Iniciar abre os Juramentos
  com "Descer" em foco (Enter duas vezes e ele desce), "Desfazer todos" e Voltar. Cada linha: nome, níveis em losangos
  de ouro velho, o efeito no nível (desligado, o do nível 1 apagado) e o Peso. Cima e baixo andam; esquerda e direita
  mudam o nível; Enter, A ou clique sobe (do topo volta a desligado), clique direito desce. Grava na hora.
- Opções: `--juramentos=pain:2,grit:1` (na partida e, com `--title`, como escolha na tela), `--wins=N` (para capturas
  e conferências: abre os Juramentos só nesta sessão, nada gravado), `--title --screen=juramentos`.
- Testes: `tests/test_juramentos.gd`; fluxo do título em `tools/title_flow_check.gd`.

## Medição (robô, semente 5, 2026-11-17)

| Partida | Peso | Resultado |
|---|---|---|
| `tools/smoke.sh 600 --seed=5` | 0 | Morvath aos 260,7 s, vitória (50 de vida) |
| `--juramentos=pain:1,grit:1,hordes:1,menace:1,debt:1,rivals:1` | 7 | Morvath aos 329,0 s, vitória (30 de vida); a cura da loja custou 70 (50 x 1,4) |
| `--juramentos=pain:2,grit:2,hordes:2,menace:1,scars:1,debt:1` | 10 | morte na sala 8 aos 266,2 s (85 abates) |
| `--start=boss --boons=25` | 0 | vitória, luta de 80,2 s |
| `--start=boss --boons=25 --juramentos=rivals:1,grit:3` | 5 | vitória, luta de 97,4 s |

O robô sem Dons e sem Maestria cai com Peso 10: os Juramentos são para quem já venceu, com Maestria e Dons. Falta
medir com gente (E6, D-11).

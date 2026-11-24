# Revisão dos kits, Guerreiro e Maga (2026-11-24)

**Autor**: `hero-designer`. Só proposta; nada implementado. Dados: QA (`qa_review_2026-11-24.md`), combate (`combat_review_2026-11-24.md`),
registro (`runs_report.py --since=2026-11-23T15:00`, 7 partidas, amostra pequena: o relatório conta Q e E por **dano causado**, então
Brado sem acerto e Investida sem alvo aparecem como "não usados"; o registro não grava teclas). Fonte dos números: `tools/make_data.gd`
(Brado 35, 4 m, recarga 12 s; Investida 35 em 4 m, recarga 5 s, 2 Magia por acerto; Círculo 10 s; Suspensão 14 s; Guerreiro 40 de vida, Maga 30).

## P1

**1. Q e E do Guerreiro são "botões de resposta" sem pergunta (por que ninguém usa).**
- Q (Brado) e E (Investida) não pagam o que o jogador já faz: o Brado dá 35 de dano e um buff de 5 s (15% de velocidade, 15% de guarda) que o jogador
  novo não lê (sem ícone de buff no HUD, nada muda na tela do herói); a Investida é um golpe de 35 que concorre com o ataque e a esquiva (Espaço 55 usos
  por partida: o jogador resolve tudo com ela). Nenhuma das duas alimenta o resto do kit de forma visível (o Brado não dá Magia nem Fúria sem Dom).
- Proposta (dado, `make_data.gd`, dono `balance-designer` com `hero-designer`): (a) o Brado devolve **+6 de Magia** por inimigo atingido (teto 3) e aciona
  **1 carga de Fúria sempre** (hoje `effect_power` só vale com o Dom Ímpeto): vira "o botão que enche o especial"; (b) a Investida **atravessa** e
  dá **0,3 s de proteção** durante o avanço (como um Passo ofensivo; hoje só dá Magia) e devolve a recarga inteira se mata (hoje só o Dom Investida);
  (c) o buff do Brado ganha ícone e contagem no HUD (`ui-ux-designer`, `Hud`), com a faixa âmbar já existente em volta do paladino durante os 5 s.
- Quickwin de leitura: a dica "Q: Brado" aparece na tela quando 3 inimigos estão a menos de 4 m e o Brado está pronto (a mesma conta de
  `Bot.shout_worth`, em `Hud`), 1 s, no máximo 2 vezes por sala. Código pequeno, dono `gameplay-engineer`.

**2. A Maga chega ao chefe em 5 de 6 e o Guerreiro morre cedo em 3 de 6: o desequilíbrio é de rotina, não de vida.**
- A Maga (30 de vida) é mais robusta que o Guerreiro (40) na prática porque o kit dela **nunca fica no alcance**: Suspensão que para projétil, Círculo
  que prende 50%, Passo de 4,5 m com 2 cargas, tiros a 11 m. O Guerreiro corpo a corpo tem 1 carga de esquiva em 0,8 s e 19 quadros.
- Proposta (dado, `balance-designer`): primeiro mexer na Maga, não subir o Guerreiro: Suspensão 14 s para **16 s** e o Círculo sem o desconto de
  -1 s por Selo abaixo de 7 s (`cd_floor` 7); Passo com 2ª carga recarregando em **1,3 s** (de 1,0). Depois dar ao Guerreiro uma **2ª carga de esquiva no Dom
  de entrada do ramo Combo** (já há `dodge_charges`) ou 3 s de proteção de 20% em cada sala nova. Validar com `--hero=maga` e o Guerreiro em 12 sementes.
  Meta: os dois chegam à sala 9 em cerca de 4 de 6.

**3. Ultimate: nenhum dos dois a usa (Maga morreu com 90 de 100; no registro Shift 0,7 por partida).**
- A carga chega devagar (90, dano 0,03 e vida perdida 1 ponto) e o aviso "Pronta" some em `ULT_HINT_TIME`. Quem enche não sente a diferença entre 80% e 100%.
- Proposta: (a) quando enche, pulso e **anel âmbar/ouro no paladino** por 1,5 s e um som próprio (`technical-artist`, `Hud._ult_was_ready` já detecta a borda);
  (b) o botão mostra "Shift" ao lado do losango cheio **enquanto estiver cheio e o paladino com menos de 50% de vida** (ver 3c); (c) **a ultimate cura 10 por cento da
  vida máxima ao começar o gesto** (0,3 s protegida já existe), então apertar na hora de aperto também é sustento: o jogador aprende que Shift salva. Dado: `UltDef.heal_pct`
  (estatística nova, **L**, `gameplay-engineer`). (d) `charge` 90 para 75 nas duas até a Maestria 6 (`balance-designer`).
  Robô: usar a ultimate também quando a vida cai abaixo de 40% (`Bot` linha 346), assim os testes veem o caso.

## P2

**4. O especial do Guerreiro e o tiro da Maga não pesam no contato (combate 2 e 3).**
- Hit stop de 2 quadros (25 ms) em dano de projétil do especial e da Explosão; nada nos tiros 1 e 2 da Maga. Tiro 3 da Maga: som `dart` mais grave, brilho
  (`shot3.glint` 0 para 0,12) e +4 quadros de recuo da mão. Dono `gameplay-engineer` (hit stop em `Projectiles`), `technical-artist` (som, brilho). Os três tiros viram
  uma cadência 8 8 12 que se **ouve**, não só se lê no número.

**5. Maga: Q e E resolvem problemas que o jogador não percebe que tem.**
- O Círculo (reúne e retarda) e a Suspensão (para projéteis) só valem se o jogador entende "o grupo vai ficar aqui" e "os tiros dos atiradores somem". Hoje nenhum
  dos dois dá dano nem recurso. Proposta (dado): o Círculo **aplica 1 Selo em todos ao fechar** (hoje o Selo vem no 2º tiro dentro; o Dom Selo no Chão já existe como ponte,
  então a base fica mais forte e a ponte vira *Selo Duplo no Chão*) e a Suspensão devolve **+8 de Magia** por projétil parado (teto 24). Assim cada botão alimenta o laço
  (marcar, agrupar, detonar), o que a revisão do `kit_c1c.md` pede. Dono `balance-designer`, `make_data.gd` (Maga: `circle`, `dome`); código só se o retorno de Magia por
  projétil parado não existir (**L**, `Arcane`).

**6. Identidade: o Guerreiro tem uma resposta por botão, a Maga uma fórmula.**
- A Maga cumpre o laço de 5 passos (tiro, Círculo, Explosão, Ressonância, Explosão amplificada); quem não segue a ordem toma pouco dano. O Guerreiro tem Fúria em cargas,
  Ômegas, ultimate Ciclone/Voragem e ainda muda de postura com as Bênçãos. Para a Maga escolher: um **Dom de rotação** em cada ramo (Piromancia: a Explosão vira
  **onda de brasa** que avança 5 m; Arcanismo: o 3º tiro **salta** para um Selo próximo; Controle: o Círculo pode ser **solto em movimento** e vira zona que segue o
  cursor por 2 s). Os três são entradas **D** com `circle_follow`, `blast_wave` e `seal_jump` (os dois últimos já em `Arcane`? conferir; senão **L**, `gameplay-engineer`).
  Dono `hero-designer` (texto) + `balance-designer`.

**7. Salmos e Bênçãos tocam pouco Q e E.**
- O Salmo da Sentinela (esquiva) e os 7 anjos têm coluna por botão, mas o registro mostra 2.6 Dons por partida e quase nunca Q ou E (`final_radiante`, `golpe_radiante` e
  `pesado_radiante` dominam). Proposta: no sorteio da Bênção (`reward_deck` e o sorteio de dom), **+30% de peso** para Bênção do botão mais ocioso do herói (tecla com
  menos usos na partida, dado já guardado em `Skills`) e **uma Bênção de Q/E garantida na 1ª oferta da sala 3** (tecla nunca usada). Dono `gameplay-engineer`, regra no sorteio,
  parâmetro em `make_data.gd`. Ensina a tecla por recompensa, como o Hades II oferece a bênção do Cast e do Sprint.

## Quickwin

**8. Tela do herói e dica de tecla.** O primeiro uso de cada tecla (Q, E, Shift) mostra uma linha no centro, 2 s: "Q: Brado de Guerra, empurra e enche a Magia", e o Livro mostra
o que cada botão faz com o verbo e o ganho em uma frase. Texto novo só em `data/text_pt.tres`, sem travessão. Dono `ui-ux-designer`.

**9. Medir uso de verdade.** Gravar no registro de partidas as **vezes** de Q, E, Shift e Espaço (não só o dano), no `RunLog`. Sem isso o relatório confunde "não usou" com
"usou e não acertou". Dono `gameplay-engineer`; o `runs_report.py` já lê o formato.

**10. Passo da Maga e esquiva do Guerreiro: leitura.** A Maga tem 2 cargas em 1,0 s; o QA diz que a segunda esquiva fica fora quando golpes escalonam em menos de 0,8 s. Não mexer na esquiva (o Daniel
gosta); só mostrar as duas cargas como dois pontos pequenos junto ao paladino (já existe em `Hud` para a Maga? conferir). Dono `ui-ux-designer`.

## Perguntas ao Daniel
1. A ultimate pode curar 10% ao começar? (muda o papel de "dano final" para "último recurso").
2. O Brado deve sempre encher Fúria (hoje só com o Dom Ímpeto)? Isso muda o ramo Fúria.
3. Aceita nivelar pela Maga (mais lenta nas defesas) antes de dar mais vida ao Guerreiro?

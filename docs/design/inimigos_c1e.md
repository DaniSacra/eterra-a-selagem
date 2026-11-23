# C1e: seis inimigos novos, modificadores e curva de variedade (proposta, 2026-11-22)

Pedido do Daniel: do SWORN, o que mais gostou foi a **variedade de inimigos** e a esquiva. Aqui só princípio (famílias de comportamento de
`sworn_estudo.md` e `sworn_numeros.md`), nada de cópia de inimigo, nome ou aparência. Só mecânica, sem história nova. **Todos os nomes são
propostas para o Daniel aprovar.** Zero créditos do Meshy: modelos de `assets/baked` e `assets/models` com tamanho, cor, pose e peça diferentes.

## Regras que valem para os seis
- Círculo cheio no chão é só de Morvath. Avisos usam **linha pontilhada, cantos em L, X, anel fino ou fio**, nunca disco.
- Golpe comum não atordoa ninguém (F8); só a Quebra (`poise`, C1b) atordoa. Todo inimigo novo comum tem `poise` 100, exceto onde diz.
- Aviso mínimo 0,7 s (o do comum hoje é 0,75 a 0,85 s). Vida na escala do C1b (esqueleto 95, besteiro 180); herói 30 de vida, comum fere 5 a 14.
- Cada um pede **uma resposta que os 8 atuais não pedem**. Os 8: esqueleto (afastar e matar), corredor (sair antes da explosão), feiticeiro
  e besteiro (esquivar ou dar a volta), Escudo (abrir a guarda), Sacerdote (matar o alvo certo), Trinca (derrubar juntos), Varredor (andar no sentido da volta).
- Tecla = o botão que melhor responde (ataque, onda, Investida/esquiva, Brado). Esquiva tem 1 carga e 18 quadros: nada pede duas seguidas.

## 1. Saltador (salto com área marcada)
- **Papel**: perigo de pouso. Fica a 4 a 7 m, some do chão num salto e cai onde o herói **estava** no fim do aviso. Pede esquiva na hora certa ou sair do lugar.
- **Tecla**: Investida (atravessa o pouso) ou andar de lado. Onda quebra o salto se acertar antes (poise 100).
- **Aviso**: 4 cantos em L no ponto de pouso (lado 3 m, laranja de brasa fina) que se fecham em **0,8 s**; mira trava nos últimos 0,3 s (`aim_lock`).
  Subida visível de 0,25 s. Depois do pouso: recuperação de 1,0 s abaixado (janela de ataque).
- **Números**: vida 140, velocidade 4,2, dano 12 na área (raio 1,6 m no pouso), intervalo 3,2 s, `size` 1,1, poise 100.
- **Reaproveita**: `RUNNER` (`lunge_*`, `aim_lock`, `recover_time`, `windup_gap`), `add_line_warning`. **Código novo**: movimento em arco com pouso em ponto travado e dano em área curta no pouso.
- **Modelo**: `runner.res` (Rogue sem lâminas) com `size` 1,1, tint ferrugem, uma perna de pano a mais (peça). Silhueta agachada, joelhos altos.
- **Aparece**: sala 3 em diante. **Mistura boa**: com Escudo (a guarda não protege do pouso; o herói sai e abre a guarda de lado) e com Besteiro (esquiva ocupada pelo salto, flecha pede andar).

## 2. Lançador (projétil que volta)
- **Papel**: atira um machado grande em arco que **vai e volta pelo mesmo caminho**. Pede ficar fora da linha na ida **e** na volta, ou esquivar na volta, quando o herói relaxa.
- **Tecla**: Investida na volta; andar para o lado resolve as duas. Ataque corpo a corpo não corta o machado.
- **Aviso**: linha pontilhada da mão até o alcance, **0,8 s**; na volta, a linha reaparece em fio fino 0,4 s antes de o machado virar (tempo total até o herói reagir: 0,4 s, curto de propósito, por isso a ida é lenta).
- **Números**: vida 150, velocidade 3,6, dano 9 (ida) e 9 (volta), machado a 9 m/s, alcance 11 m, volta em 1,3 s, intervalo 3,4 s, `size` 1,2, mantém 6 a 8 m.
- **Reaproveita**: `ARCHER` (`shot_line`, `shot_range`, `keep_away`, `shot_relock`). **Código novo**: projétil com volta (ponto de virada, retorno à mão, some ao chegar), sem rastrear o herói na volta.
- **Modelo**: `skeleton` (Minion) com `Skeleton_Axe` grande na mão (peça), `size` 1,2, tint cinza-azulado. Silhueta: um braço levantado e muito peso de um lado.
- **Aparece**: sala 4. **Mistura**: com Trinca (esquiva ocupada, machado cruza as três) e Saltador (dois pedidos de esquiva em tempos diferentes).

## 3. Canalizador (raio contínuo)
- **Papel**: fincado, **mantém um raio fino** por 2,2 s que gira devagar atrás do herói. Pede sair da linha e manter-se em movimento; esquivar atravessa um pulso.
- **Tecla**: Investida para chegar nele, ataque ou onda para quebrar (a Quebra corta o raio). Brado absorve um pulso. Não pune quem fica perto (raio sai da mão a 1 m).
- **Aviso**: linha clara que acende por **0,9 s** antes do primeiro pulso, mira trava nos 0,3 s finais; depois a linha segue o herói a 40 graus/s (`shot_turn`).
- **Números**: vida 130, velocidade 0 (planta os pés), dano 5 a cada 0,45 s (5 pulsos), alcance 12 m, descanso 2,4 s, `size` 1,3, `per_room` 1.
- **Reaproveita**: `CASTER`/`ARCHER` (`shot_ticks`, `shot_interval`, `shot_turn`, `shot_turn_decay`, `shot_line`). **Código novo**: raio como linha contínua com dano por pulso na linha e interrupção pela Quebra.
- **Modelo**: `mage.res` (Skeleton_Mage) parado, cajado erguido na horizontal, tint azul-aço. Distinto do Varredor: este ataca de longe e persegue, o Varredor gira perto e não persegue.
- **Aparece**: sala 6. **Mistura**: com Escudo (obriga a rodear por trás sem entrar na linha) e com Esqueletos (o raio varre o bando, o herói usa os corpos como cobertura se `blocks_body`).

## 4. Gritador (buff de grupo e cura)
- **Papel**: o alvo que **não pode ser ignorado**. Grita e acelera o bando (+30% velocidade de andar e de ataque, 8 m, 8 s) e cura 10% da vida dos vizinhos uma vez por grito. Pede escolher o alvo.
- **Tecla**: Investida para alcançar, onda para quebrar o grito (poise 100) quando o bando está em volta.
- **Aviso**: fios finos âmbar do Gritador até cada aliado e anel fino no pé dele que fecha em **0,9 s** antes de o efeito pegar (nunca disco).
- **Números**: vida 120, velocidade 3,0, sem ataque de dano (empurra com 4 de dano se cercado), grito a cada 9 s, `size` 1,15, `per_room` 1, foge de quem chega a 2 m (`retreat_*`).
- **Reaproveita**: `PRIEST` (`ward_*`, `ward_radius`), `retreat_far`. **Código novo**: buff de velocidade temporário em quem está no raio e cura única por grito (o Sacerdote só dá blindagem).
- **Modelo**: `skeleton` (Minion) com um chifre (peça, `Skeleton_Staff` encurtado), `size` 1,15, tint âmbar-ocre, braços abertos para cima. Distinto do Sacerdote: sem capuz, cor quente, anda.
- **Aparece**: sala 5. **Mistura**: com Corredores (corredores rápidos e quebrados pelo buff exigem matar o Gritador primeiro) e Esqueletos (bando acelerado em volta de Escudo).

## 5. Coveiro (fuga e invocação)
- **Papel**: nunca luta de perto. Foge do herói e **levanta dois esqueletos fracos** de ossos no chão (ou monte) a cada 7 s. Pede perseguir o alvo ou ignorar e sobreviver; matar rápido corta a fonte.
- **Tecla**: Investida (alcança), onda (atinge quem está fugindo e os recém-erguidos). Ataque sozinho persegue demais: isso é o ponto.
- **Aviso**: ossos saem do chão com um **X pontilhado** por **0,9 s** antes de erguer (2 pontos, não sobre o herói: a 3 m dele no mínimo).
- **Números**: vida 90, velocidade 5,2 ao fugir e 3,2 normal, esqueletos erguidos com vida 40 e dano 4, máximo 4 vivos dele (`raise_max`), intervalo 7 s, `size` 1,0, `per_room` 1, poise 100.
- **Reaproveita**: `raise_count`, `raise_every`, `raise_max`, `rise_time`, `retreat_far`, `retreat_time`, `escort`. **Código novo**: posição de invocação longe do herói e fuga que contorna parede (a `cover_hug` já ajuda).
- **Modelo**: `priest.res` ou Mage com pá (`Skeleton_Axe` reduzido) e capuz escuro, `size` 1,0, tint verde-musgo escuro (sem roxo, que é do Sacerdote).
- **Aparece**: sala 8. **Mistura**: com Canalizador (o herói persegue o Coveiro dentro da linha do raio) e Gritador (esqueletos erguidos já nascem acelerados).

## 6. Armadilheiro (armadilha e pune esquiva demais)
- **Papel**: planta **placas de espinho** no chão, onde o herói pisou ou **onde terminou a última esquiva** (se esquivou nos últimos 3 s). Pede esquivar na hora certa e variar o ponto. Quem aperta esquiva sem parar aterrissa na placa.
- **Tecla**: andar (vale mais que esquivar), onda para ele de longe; a esquiva fica guardada para o que o resto da sala atira.
- **Aviso**: placa vira um X pontilhado marfim por **1,0 s**, depois levanta os espinhos por 0,5 s; some em 6 s (máx. 4 placas). Dano de 10 só no X; quem passa por cima na esquiva (i-frames) não leva.
- **Números**: vida 110, velocidade 3,8, mantém 5 a 7 m, planta a cada 2,6 s, dano 10, `size` 1,2, `per_room` 1, poise 100.
- **Reaproveita**: perigos de sala (`rooms.md`, lajes e raiz têm o mesmo aviso e dano), `ARCHER` para manter a distância. **Código novo**: lembrar o fim da última esquiva do herói e criar o perigo com tempo de vida.
- **Modelo**: `skeleton.res` (Rogue) com `Skeleton_Crossbow` descarregada nas costas (peça) e `size` 1,2, tint verde-oliva, capuz de pano. Silhueta curvada olhando para o chão.
- **Aparece**: sala 9. **Mistura**: com Saltador (o pouso e as placas estreitam o espaço de esquiva) e Besteiro (a esquiva fica cara e a flecha pede andar).

## 5 modificadores para salas do fundo (sala 8 em diante)
Marca de leitura: **anel fino colorido no pé**, uma cor por modificador, sem cor reservada (vermelho, esmeralda, violeta, ouro de elites). Nome para o Daniel aprovar.
1. **Furioso** (anel laranja): +25% velocidade de ataque, aviso fica no mínimo de 0,7 s. Usa o campo de velocidade existente. Código novo: nenhum.
2. **Detonante** (anel âmbar): explode ao morrer em 4 lanças curtas em cruz, 8 de dano, aviso 0,7 s. `death_burst` já existe, falta a forma em cruz.
3. **Regenerante** (anel azul-claro): cura 12 de vida depois de 3 s sem levar golpe. Código novo: tique de cura.
4. **Escoltado** (anel branco): nasce com dois esqueletos de 40 de vida em volta (`escort`). Nenhum código novo.
5. **Eco** (anel cinza): ao morrer deixa um monte que se ergue em 3,5 s com 40% da vida, uma vez (`rise_time`, `State.RISE`). Código novo: ligar a regra a qualquer inimigo.
Regra: no máximo 1 modificador por inimigo e 2 por sala; chance 0% até a sala 7, depois 10% por sala (sala 8) subindo 5 pontos a cada sala; nunca em minichefe nem em Morvath.

## Curva de variedade (14 salas; o sorteio nunca repete o mesmo conjunto de papéis seguidos)
| Salas | Tipos que entram | Novos | Observações |
|---|---|---|---|
| 1 a 2 | esqueleto, corredor, besteiro, feiticeiro | nenhum | 2 papéis, 3 a 6 vivos |
| 3 a 4 | + Escudo, Sacerdote; versão maior de esqueleto e corredor (4) | Saltador (3), Lançador (4) | 2 papéis ou mais; no máximo 1 novo por sala |
| 5 a 6 | + Gritador (5), Canalizador (6) | 2 | 1º minichefe na sala 5 (capítulo de 14 salas: minichefes 5 e 10, loja 13, Morvath 14); `per_room` 1 em ambos |
| 7 a 8 | + Trinca, Varredor, Coveiro (8); modificadores a 10% | 1 | Varredor e Canalizador nunca juntos (dois pedidos de direção) |
| 9 a 10 | + Armadilheiro (9) | 1 | todos os 14 tipos possíveis; 3 papéis por sala |
| 11 a 12 | tudo, elites, modificadores 20% | nenhum | sala com 2 novos + 1 antigo e vale de alívio depois |
| 13 a 14 | mistura mais densa, 2º guardião e Morvath | nenhum | só combinações já vistas; regra de "sem repetir" |
Regras de sorteio: (1) a sala nunca repete o conjunto de papéis da anterior; (2) máximo 2 papéis novos (da faixa) por sala; (3) `per_room` 1 em
Canalizador, Gritador, Coveiro e Armadilheiro; (4) proibidos juntos: Canalizador e Varredor, Armadilheiro e corrente (RP-11), Coveiro e Trinca;
(5) uma sala "de respiro" (só papéis já domados) depois de cada sala com 2 novos.

## Ordem de implementação em 3 lotes
- **Lote A (só dado e pouca lógica)**: Gritador (buff e cura), Coveiro (fuga e invocação), modificadores 1, 4 e 2 (cruz). Reaproveitam `PRIEST`/`raise_*`/`escort`/`death_burst`. Também a tabela de sorteio por faixa e `per_room`. Teste de dado e de sorteio; 12 sementes.
- **Lote B (movimento novo)**: Saltador e Lançador. Salto com pouso travado e projétil com volta, mais avisos novos (cantos em L, fio de volta). Medir aviso e janela de punição em 60 quadros (cadência).
- **Lote C (dano contínuo e memória)**: Canalizador (raio), Armadilheiro (placas e memória da esquiva), modificadores 3 e 5. Equilíbrio em 12 sementes; critério: nenhuma luta comum passa de 60 s, esquiva não é a única saída de nenhum inimigo.
- Aceite geral: um estranho aponta quem é quem em imagem parada (silhueta e cor), cada aviso dura 0,7 s ou mais, o robô vence ao menos 20% no evoluído e novato morre antes de Morvath na maioria (critério do C1b).

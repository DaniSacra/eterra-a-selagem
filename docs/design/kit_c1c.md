# C1c: o kit se alimenta e cobra leitura (etapa 2 do plano de combate, 2026-11-22)

Só princípio (`sworn_numeros.md` (c) itens 5, 7, 10, 12), nada copiado. Vem depois do C1b (Quebra, vida do comum 1,6x, graça 0,7 s, versão
maior). Herói segue 15/15/20 e 30 de vida; só a Quebra atordoa (F8). Tudo abaixo é dado em `tools/make_data.gd` (regerar `data/`) salvo onde
dito "código". Números são o ponto de partida do robô, não promessa. Nenhum nome novo para o jogador; termos provisórios marcados (prov.).

## 1. Os botões se alimentam
Hoje: Magia só pelo finalizador (+2) e pela Investida (+2 por alvo); o Brado volta em 12 s sem olhar o que se fez.
- **Magia por acerto**: cada golpe do ataque que acerta (uma vez por golpe, não por alvo) dá **+0,5**; **+3 por Quebra** causada (ataque,
  onda, Investida ou Ômega; a do Brado não). Motivo: a onda custa 12 e passa a ser paga por ~6 acertos de ataque ou 4 Quebras; só mouse enche
  devagar, quem acerta o botão certo enche rápido. Muda: `ComboNode.magick_per_hit` já existe (virar 0,5 no cut1/cut2/cut3) e
  `HeroDef.magick_on_break` (campo novo, código pequeno em `Magick`/`Horde` no evento de Quebra).
- **Brado volta mais cedo**: cada acerto de ataque tira **0,3 s** da recarga; cada Quebra **1,5 s** (a do próprio Brado e a da ultimate não
  contam). **Piso 8 s** (hoje 12; some no máximo 4 s por uso). Motivo: o Brado vira resposta de quem luta bem e não de quem espera; o buff de 5 s
  e a absorção de um golpe ficam com uptime de no máximo 5/8. Muda: `Player` (recarga do Brado) + `HeroDef.cd_refund_hit`, `cd_refund_break`,
  `cd_floor` (código pequeno).
- **Teto contra laço**: ganho de Magia por acerto e por Quebra vale no máximo **3 por segundo** (janela de 1 s) e uma onda devolve no máximo 8
  dos seus 12 (a Quebra que a própria onda causa dá Magia, mas só até 8 por onda). Nada devolve Brado a partir do Brado; a Magia gasta alimenta a
  ultimate (já existe), então a carga dela sobe com o novo ganho: medir (item 5).
- **Teste** `tests/test_kit_c1c.gd`: 10 acertos dão 5 Magia; Quebra dá 3; 4 Quebras no mesmo segundo param no teto; onda numa sala cheia nunca
  devolve mais de 8; Brado com 40 acertos nunca volta antes de 8 s. **Robô** (12 sementes, 0,25): Magia vinda de acerto e Quebra 25 a 40% do
  total gasto (hoje quase 0), onda 4 a 8 usos por luta de sala (hoje limitada pela Magia), Brado 1 uso a cada 9 a 11 s na média, nunca abaixo de 8.

## 2. Ponta da espada
- **Faixa**: os **35% externos do alcance** (cut1 e cut2 têm reach 430/U; a faixa é de 65% a 100% dele). **x1,5** de dano e de Quebra naquele
  golpe; o miolo x1,0. Têm ponta: golpe 1, golpe 2 e Investida (linha de 4 m, últimos 1,4 m). **Não têm**: giro (cut3, círculo), Quarto Corte,
  Ômega, onda, Brado, ultimate. Motivo: a espada de duas mãos deixa de ser "colar e apertar": quem recua um passo e bate de longe ganha 50%.
  Fio Longo (+15% de alcance) e Corte Crescente seguem valendo (a faixa é fração do alcance, então cresce junto).
- **Como lê**: arco fino e claro (marfim, a cor do ataque, sem cor nova) na borda do leque durante o preparo; no acerto de ponta, clarão curto
  no ponto de contato, som seco um tom acima e número de dano maior (já existe `DamageNumbers` com tamanho por valor). O miolo fica como hoje.
- **Muda**: `ComboNode.sweet_start` (0,65) e `sweet_mult` (1,5), código pequeno em `Combat` (distância do alvo ao herói vs alcance), marca no
  `ComboFx`/leque. **Teste**: alvo a 0,6 e a 0,9 do alcance, dano 15 e 22,5; giro nunca tem ponta; a Quebra também x1,5; com Fio Longo a faixa sobe.
- **Robô**: bot não faz kiting de propósito; meta 15 a 25% dos acertos de ataque na ponta (o robô evoluído com Fio Longo até 35%). Se passar de 40%,
  baixar a x1,35. Dano do ataque continua até 40% do dano do evoluído (meta do C1b).

## 3. Golpe que pesa
Parada de impacto (hoje 25, 65, 70, 50, 80 ms): **cut1 40, cut2 60, cut3 90, Investida 50, onda 30 por alvo atingido primeiro (hoje 0),
Ômega 120, Brado 100, Quebra +80 (soma ao golpe), ultimate 150**. Motivo: o giro e a Quebra são os golpes que decidem a luta e merecem o maior peso;
o primeiro golpe fica leve (ritmo). Não vamos aos 160 a 200 ms do estudo: com 3 a 6 vivos haveria parada a cada acerto.
- **Teto**: soma de paradas **no máximo 200 ms por janela de 1 s** e 10% do tempo da luta; o excedente é cortado e a Quebra tem prioridade.
  Vários alvos no mesmo golpe contam uma parada (a maior). Muda: `hit_stop_ms` em `_tree`, teto em `HitStop` (código pequeno), e o teto de 80 do
  `test_combo` sobe para 150 (Brado 100, Ômega 120, ultimate 150 ficam de fora do teto do ataque).
- **Teste**: 20 acertos de cut1 em 1 s nunca passam de 200 ms; a Quebra corta o golpe comum no mesmo quadro. **Robô**: parada total entre 5 e 9% da
  luta de sala (hoje cerca de 3%); `RESULT` ganha `hit_stop_pct`. A sensação em si é do `combat-feel-director`, em captura (uma só).

## 4. Esquiva
Hoje: 1 carga, recarga 1,1 s, 0,3 s de invulnerável (18 quadros), 5,6 m em 0,2 s; graça após dano cai a 0,7 s (C1b).
- **2 cargas, recarga 1,5 s cada** (a primeira volta 1,5 s depois do uso, a segunda é gasta em seguida); invulnerável **0,3 s na primeira e 0,2 s na
  segunda seguida** (a segunda sem janela de espera dentro de 0,4 s da primeira). Motivo: com graça curta o erro custa mais e a esquiva é a resposta
  ao aviso de 0,75 s do esqueleto; duas seguidas cobrem o corredor e a flecha, três seguidas continuam impossíveis. Piso de rapidez parecido com o
  Hades II (duas esquivas, não spam).
- **Passos** (`dodge_charges` +1) passam a dar 3 cargas, mas só a partir da 1ª recarga completa; `passo_veu`, `passo_mare`, `passo_marca` e `rastro`
  tinham 1 carga; agora disparam por esquiva, não por carga, então ficam iguais. Muda: `_hero` (`dodge_charges` 2, `dodge_recharge` 1,5) e `Player`
  (invulnerável da segunda: `dodge_iframes_chain`, campo novo). **Teste**: duas esquivas em 0,3 s passam, a terceira não; carga volta em 1,5 s; Passos
  dá 3. **Robô**: esquivas por luta de sala 2 a 5 (hoje 1 a 2); dano que entra por luta cai 15 a 25% sem mudar o resultado de Morvath mais de 15 pontos.

## 5. Dons e Bênçãos que ficam fortes ou inúteis
- **Brado de Guerra (Voz Larga, Escudo de Guerra, Impeto)**: com o piso de 8 s o Brado fica quase sempre ligado (5/8). Ajuste: o piso fica 8 s, a
  absorção de golpe (`buff_ward`) só renova a cada 12 s, o resto da recarga acelerada é só do dano. Voz Larga (+35% alcance, +50% dano, +30% empurrão)
  também vale para a Quebra do Brado; fica como está (é o Dom do Brado).
- **Avanço Feroz, Investida, Passo Encadeado**: devolvem carga de esquiva ou Investida por abate; com 2 cargas a devolução vale menos que antes
  (carga cheia some). Manter; o teto de 3 cargas vale.
- **Lâmina Faminta (Ômega à metade depois do giro)**: com a Magia por acerto o Ômega de 20 vira a metade de 10, quase de graça. Ajuste: Ômega à
  metade só se a Magia atual for menor que 20 (antes do ganho), ou desconto 0,5 vira 0,65. Medir antes de mexer (robô: Ômegas por luta).
- **Coração da Emeth, Impeto (+6%/carga de velocidade)**: mais golpes, mais acertos, mais Magia; o teto de 3 por segundo trava; a ultimate (carga
  por Magia gasta, 0,02 por dano) sobe: aceitar até 25% mais rápido, acima disso baixar `damage_charge` de 0,02 para 0,015.
- **Fio Longo**: sobe o alcance e leva a ponta junto; passa a ser o Dom mais forte do ataque. Aceitar com a meta do item 2; se o robô passar de 35% de
  ponta, Fio Longo vira +10%.
- **Nivael (onda estilhaça)** e Quebra: onda quebra mais que todos e congela o quebrado; forte demais com Quebra +40% de dano. Ajuste: o estilhaço
  não soma ao bônus de +40% da Quebra (um dos dois, o maior). **Bênçãos de esquiva por acerto** (`gap`): ficam como estão; o `gap` já é o teto.
- **Ficam inúteis**: nenhum. Parada maior não mexe em Dom algum. Medir: nenhum Dom com taxa de escolha do robô abaixo de metade da média.

## 6. Qual tecla resolve o quê (comuns e versões maiores do C1b)
Legenda: A ataque, O onda (Magia 12), Q Brado, E Investida, Esq esquiva, Ômega (A segurado, 20), U ultimate. "Pede" é o que resolve com menos dano.
| Inimigo | Perigo | Pede | Teclas fracas |
|---|---|---|---|
| Esqueleto (95) | golpe com mira rastreada, aviso 0,75 s | Esq lateral e A na ponta do alcance; Brado empurra grupo | O sozinha (sobra) |
| Corredor (70) | explode ao morrer, aviso 0,85 s | matar de longe: O ou Ômega, ou E e afastar; Esq no aviso | A colado (a explosão pega) |
| Besteiro (180) | segunda flecha com nova mira | E para fechar a distância, Esq na 2ª flecha, A de ponta | Q (fora do alcance) |
| Feiticeiro (115) | orbes lentos a distância | E, O na linha; orbes cortam com a ponta? (não, só Esq) | Q, A longe |
| Escudo (255, `guard`) | barra 70% de frente | O abre a frente 4 s; E e Ômega passam; Esq lateral | A de frente |
| Sacerdote (290) | blinda 3 vizinhos | E nele primeiro; Ômega atravessa o grupo | O (blinda) |
| Trinca (45 x3) | enxame que cerca | Q empurra, giro (A3) e Brado de saída; Esq | O, E (um alvo) |
| Varredor (160) | arco fixo no chão | Esq pelo arco, Ômega a distância | E (entra no arco) |
| Esqueleto grande | invoca 3 em 8 s | Quebra (O, depois A de ponta) e Q na cria | E repetida |
| Corredor grande | 2 investidas | Esq em cada uma, Ômega ou O na recuperação | A colado |
O que falta: (a) nenhum comum só se resolve com o Brado, só a Trinca o pede; (b) nenhum pune a esquiva repetida (esquivar duas vezes sempre
resolve); (c) a ponta não é cobrada por ninguém: falta inimigo que recua ou ataca de longe e só se alcança com a ponta (o besteiro ajuda, o
feiticeiro não); (d) o Varredor e a Trinca ainda não têm Quebra (C1b os deixa fora); (e) a ultimate só aparece em minichefe. Pergunta ao C1c final: o
besteiro recua 1,5 m depois de cada tiro (`EnemyDef.kite`, dado se o comportamento existir; senão código pequeno)?

## Ordem e medida final
1) Magia e Brado por acerto e Quebra; 2) ponta; 3) parada com teto; 4) esquiva 2 cargas; 5) medir 12 sementes novato e evoluído, `--bot-mouse` e
todas as teclas: Quebras por luta 3 a 8; só mouse chega a Morvath no máximo metade do todas as teclas; evoluído vence 20 a 40%; nenhuma luta comum
acima de 60 s; o erro de 14 pontos (`balance.md`) é aceito. Se um item estourar a meta, desfazer só ele (cada um é um número e um teste).

# Ciclo 8: revisão de arte (combate tático, legibilidade e polimento)

Revisão do Art Director sobre capturas reais do jogo (Godot 4.7.2 de Windows, NVIDIA GeForce RTX 5060 Laptop GPU,
Vulkan 1.4.357, Forward+, 1920 x 1080). Nenhuma imagem desta pasta foi gerada por IA nem retocada; as montagens só
juntam quadros inteiros com uma faixa de rótulo acima. Comandos, momento da partida e inimigos de pé de cada captura:
[CAPTURAS.md](CAPTURAS.md). Relatório de QA: [latest_report.md](../../qa/latest_report.md). Revisão anterior:
[ciclo 7](../cycle7/ART_REVIEW.md). Proposta da luta de Morvath (ciclo 9, sem implementação):
[morvath_boss_fight.md](../../design/morvath_boss_fight.md).

Abri e olhei cada imagem citada abaixo, e ampliei recortes das capturas `04` e `05` (o bolo de inimigos) e `10` e
`11` (preparo e elites) para julgar o que o QA apontou. Não há percentual de semelhança aqui: só o que se vê. A
aprovação artística final é do Daniel.

## A. Resumo

| Item | Valor |
|---|---|
| Branch | `arpg-3d` |
| Commit inicial | `eb1e9d7` (fim do ciclo 7) |
| Commit final avaliado | `84285e8` |
| Commits do ciclo | `8b821b1` densidade e composição, `3929b11` proposta de Morvath, `41f532b` avisos, barras e HUD, `84285e8` herói, clarão e Emeth |
| Capturas | 14 do contrato, `10b`, 4 montagens de antes e depois, 40 de trabalho em [work/](work/) |

**Veredito**: aprovado para o teste do Daniel, com três ressalvas visuais que não travam o teste (seção D): o herói
atrás do obelisco ainda parece estar em cima dele, os números de dano se sobrepõem quando mais de 10 inimigos levam o
mesmo golpe, e no bolo de 20 o herói some em alguns quadros. Nenhuma das três é regressão: as três já existiam no
ciclo 7 e duas melhoraram.

## B. Mudanças implementadas

**Densidade e composição** (`8b821b1`, gameplay-engineer)
- No máximo 20 inimigos de pé, invocações incluídas. Níveis de encontro: comum 4 a 8, difícil 8 a 12, especial 12 a
  16, mantidos por ondas. Morvath com no máximo 4 ajudantes (6 na fase 3).
- Composição por papel vinda dos dados (`EncounterPool`, `EnemyDef.role`): 2 papéis no começo, 3 no meio, misturas
  mais duras com elites no fim. Mesmas estatísticas de inimigo.

**Avisos, barras e HUD** (`41f532b`)
- Preparos que crescem até o pico pouco antes do golpe: brilho na lâmina do Esqueleto, virote ao longo da mira do
  arqueiro, aro do escudo. Avisos em linha apontam para onde o golpe vai (setas dentro da faixa); arcos com borda nos
  lados (`GroundLook`). Tranco curto ao ser atingido.
- Barras: todos mostram a barra nestas lutas pequenas, mais altas, armadura numa faixa própria, elites com moldura de
  ouro velho, rastro do que o golpe tirou (`BarTrails`), a barra mais perto da câmera por cima.
- HUD: só o corpo do losango fica translúcido quando há alguém atrás; recarga como nível de ouro velho subindo na gema.

**Herói e Emeth** (`84285e8`)
- Atrás de pedra, o Explorador é o próprio corpo escurecido com o fio marfim, sem o anel por cima da pedra; o raio-x
  completo fica só para quando a multidão o cobre. Luz principal um pouco mais quente.
- Inimigo atingido clareia na própria cor, abaixo do limiar do brilho; marfim por um quadro só nos golpes pesados.
  Fim da silhueta branca chapada.
- Fita do corte mais estreita; estocada do Ômega mais larga, com veios de ouro velho; dardo do especial com miolo de
  ouro e estrela no acerto.
- Orçamento de efeitos por quadro (`FxBudget`) e um número somado por alvo (`NumberTally`, finalizadores à parte).

**Proposta de Morvath** (`3929b11`): [docs/design/morvath_boss_fight.md](../../design/morvath_boss_fight.md), 6050 de
vida, fases em 66% e 33%, dois interlúdios ativos, ajudantes limitados, cópias ilusórias, o ritual de corrupção da
Emeth, todo ataque com aviso, critérios de duração e balanceamento, perguntas para o Daniel. Nada implementado.

**Intocados**: arena (`catacomb_hall.gd`, `arena*.gd`, `masonry`, `catacomb_floor`, `screen.gdshader`) e tela de
título (`boot.gd`, `scripts/ui/title*`, `assets/ui/title`): `git diff --stat eb1e9d7..HEAD` nesses caminhos sai vazio.

## C. Metas atingidas

| # | Critério de aceite do ciclo | Veredito | Evidência |
|---|---|---|---|
| 1 | Densidade Hades II: comum 4 a 8, difícil 8 a 12, especial 12 a 16 | SIM | Sonda do QA com 500 sementes por profundidade (`enc_probe.txt`): comuns com teto 8, difíceis 12, especiais 16; `test_encounters.gd` |
| 2 | Teto de 20 de pé | SIM | `max_alive` de 5 a 8 em todas as partidas do robô (QA, seção 1); só o `--stress=300` passa, e ele é opção de teste por fora das salas |
| 3 | Morvath + 4 a 6 ajudantes | SIM (nos dados e nas partidas) | Partidas `--start=boss`: `max_alive` 5 a 6. Sem captura com os ajudantes em volta dele; [14](14_morvath_atual.jpg) mostra Morvath sozinho aos 11,9 s |
| 4 | Composições progressivas por papel | SIM nos dados, sem prova visual | Testes de `test_encounters.gd`. As capturas de multidão usam `--stress-ids` (composição escolhida à mão); nenhuma mostra uma sala 3 real com a mistura sorteada |
| 5 | Explorador legível com 8 a 20 inimigos | PARCIAL | Lê bem com 4, 8, 12 e 16 ([01](01_combate_4_inimigos.jpg), [02](02_combate_8_inimigos.jpg), [03](03_combate_12_inimigos.jpg), [04](04_combate_16_inimigos.jpg): cabelo laranja, túnica verde e a Emeth no meio do bolo). Com 20 ([05](05_combate_20_inimigos.jpg)) o corpo dele fica atrás de um esqueleto e da coluna de números; só o anel petróleo o acha |
| 6 | Sem ciano chapado nem contorno branco exagerado | SIM | Recortes de `04` e `05`: o herói aparece nas cores dele; anel petróleo fino; fio marfim fino ([12](12_obstaculo_transparencia.jpg)) |
| 7 | Corrigir o herói atrás de obstáculos | NÃO | [before_after_obstaculo](before_after_obstaculo.jpg): o anel saiu de cima da pedra e as pernas escureceram um pouco, mas o corpo inteiro continua desenhado sobre o topo do obelisco com os pés contornados de marfim. Lê como "em cima", que era o defeito |
| 8 | Efeitos da Emeth comunicam sem esconder, sem clarão branco | SIM | [before_after_emeth](before_after_emeth.jpg), [cmp_omega](work/cmp_omega.jpg), [cmp_especial](work/cmp_especial.jpg), [cmp_heroi16](work/cmp_heroi16.jpg): o atingido fica na cor dele e o herói não some atrás do branco. [07](07_emeth_ataque.jpg), [08](08_emeth_impacto.jpg), [09](09_emeth_especial.jpg): fita, estocada com veios e dardo lidos |
| 9 | Números de dano legíveis | PARCIAL | Até 8 atingidos estão bons ([07](07_emeth_ataque.jpg), [08](08_emeth_impacto.jpg)). Com 13 e 14 atingidos os números batem uns nos outros: em `05` se lê "1019" (101 sobre 119) e "9722" (97 sobre 122) |
| 10 | Indicadores dos inimigos (preparo e aviso no chão) | SIM | [10b](10b_preparo_laboratorio.jpg) e [c8c_avisos_lab](work/c8c_avisos_lab.jpg): cada papel tem preparo próprio; linha com setas, leque com borda, círculo. Em jogo ([10](10_inimigos_preparando_ataque.jpg), [06](06_explorador_em_combate.jpg), [13](13_hud.jpg)) o aviso no chão é o que se lê; o preparo no corpo é pequeno demais a 54 m (ver D4) |
| 11 | Barras e elites | SIM | [11](11_elite.jpg) e [c8c_barras_12_perto](work/c8c_barras_12_perto.jpg): faixa de armadura separada, moldura de ouro velho só nas elites, rastro claro do dano |
| 12 | HUD pontual | SIM | [c8c_hud_acoes_perto](work/c8c_hud_acoes_perto.jpg): na recarga só o corpo do losango escurece, o nível de ouro sobe na gema, tecla e moldura ficam firmes. [13](13_hud.jpg) a 1920 |
| 13 | Arena e título intocados | SIM | Diff vazio nos arquivos de arena e título (seção B); a sala é a mesma em todas as capturas |
| 14 | Portal vermelho de Morvath validado | SIM | [14](14_morvath_atual.jpg): portal vermelho, a luz que desce pelos degraus e pelo chão é vermelha (corrigido desde o B2 do ciclo 7), nada de verde no altar |
| 15 | Documento de Morvath para o ciclo 9 | SIM | [morvath_boss_fight.md](../../design/morvath_boss_fight.md) |
| 16 | 60 FPS a 1080p na placa do Daniel | SIM | Quadro mediano de 4,78 a 4,84 ms com 4 a 20 de pé (seção G) |

## D. Problemas encontrados (avaliados por mim nas imagens)

**D1. Herói atrás do obelisco lê como em cima dele** (B1 do QA; era o B3 do ciclo 7). Prioridade alta para a
leitura, baixa para o teste. Em [12](12_obstaculo_transparencia.jpg) e no recorte 3x de
[before_after_obstaculo](before_after_obstaculo.jpg) o herói inteiro, inclusive pés e canelas, é desenhado sobre o
topo da pedra; o escurecimento das pernas é fraco demais para o olho e o fio marfim nos pés reforça a borda deles
contra a pedra, o que diz "pisando aqui". Tirar o anel ajudou pouco. Meu veredito: não resolvido.

**D2. Números empilhados com muitos atingidos** (B2 do QA). Em [04](04_combate_16_inimigos.jpg) os números ainda se
leem um a um, apertados (68 sobre 70, 115 sob 120). Em [05](05_combate_20_inimigos.jpg) há sobreposição real ("1019",
"9722") e a coluna de números com "Atordoado!" fica exatamente em cima do herói, cobrindo cabeça e tronco. O
`NumberTally` somou por alvo, mas não há espaço entre alvos. Meu veredito: defeito, porque esconde o herói, que é a
regra principal da tela.

**D3. Herói difícil de achar no bolo de 20** (B3 do QA). Confirmo em `05` (recorte ampliado): o corpo dele fica entre
um esqueleto e a coluna de números; acha-se pelo anel. Em [cmp_heroi20](work/cmp_heroi20.jpg) o ponto mais claro do
bolo é o orbe do feiticeiro, quase branco e com halo grande, que puxa o olho para longe do herói; o mesmo orbe aparece
em [cmp_heroi16](work/cmp_heroi16.jpg). Com 16 ele ainda lê. Meu veredito: PARCIAL; a causa principal é a coluna de
números (D2) e o orbe estourado, não o desenho do herói.

**D4. Preparo no corpo pequeno demais na câmera de jogo.** No laboratório ([10b](10b_preparo_laboratorio.jpg)) os
preparos são distintos. Em [10](10_inimigos_preparando_ataque.jpg), a 54 m, o brilho da lâmina e o aro do escudo não
se distinguem; não consigo dizer pela imagem qual inimigo vai investir (o Escudo está meio atrás do obelisco). O aviso
no chão resolve a jogabilidade. Meu veredito: aceitável para este ciclo.

**D5. Franja de cor no Ômega** (B4 do QA). Em [08](08_emeth_impacto.jpg) o esqueleto perto da borda direita
(x 1700 a 1850) fica com contorno vermelho, verde e azul, como foto 3D sem óculos; a janela e as colunas do abismo à
esquerda também franjam. É a separação de cor dos finalizadores do ciclo 7 (`screen.gdshader`), não mudou neste ciclo.
Meu veredito: lê como defeito de imagem, não como impacto. Dura poucos quadros, então não trava o teste.

**D6. A luta das capturas de multidão acontece no patamar oeste, colada na borda.** Em `01` a `05` o bolo fica entre
x 250 e 650 de 1920, porque o `--stress` solta todos na entrada. O herói fica perto dos 18% da borda (`CamFrame.SAFE`)
e o resto da sala fica vazio. É efeito da opção de teste, não das salas; registro só para que nenhuma captura de
`--stress` seja usada como composição de referência.

**D7. Círculo de luz em creme forte.** Em [07](07_emeth_ataque.jpg) e [09](09_emeth_especial.jpg) o aro do círculo é
o traço mais claro do chão, mais que o aviso vermelho. Ainda lê como "meu", mas compete. Observação, sem pedido agora.

## E. Problemas resolvidos

- Inimigo atingido virava silhueta branca chapada (B4 do ciclo 7) e, no Ômega e nos golpes no bolo, cobria o herói:
  resolvido. [before_after_emeth](before_after_emeth.jpg), [cmp_omega](work/cmp_omega.jpg),
  [cmp_especial](work/cmp_especial.jpg), [cmp_heroi16](work/cmp_heroi16.jpg) (o clarão branco sobre a cabeça do herói
  sumiu).
- Luz do portal nos degraus da sala de Morvath em verde (B2 do ciclo 7): resolvido, [14](14_morvath_atual.jpg).
- Anel do herói desenhado por cima da pedra do obelisco: resolvido (o resto do D1 não).
- Grupos de números acima do limite com 40 a 90 inimigos (ciclo 7): resolvido pela densidade nova e pelo número somado
  por alvo, exceto no caso de mais de 10 alvos de um golpe só (D2).
- HUD inteiro translúcido quando havia alguém atrás: agora só o corpo do losango
  ([c8c_hud_acoes_perto](work/c8c_hud_acoes_perto.jpg)).
- Barras vermelhas iguais para comum e elite: agora a elite tem moldura de ouro velho e armadura em faixa própria
  ([11](11_elite.jpg)).

## F. Pendências, com responsável e pedido

| # | Responsável | Pedido | Critério de aprovação |
|---|---|---|---|
| P1 (D1) | environment-artist, com o gameplay-engineer se tocar no `Player` | Quando uma peça de cenário fica entre a câmera e o herói, recortar a peça em volta dele em vez de desenhar o herói por cima: pontilhado (dither) no `masonry.gdshader` num círculo de cerca de 1,2 m em tela em volta do herói, só nas peças altas (obeliscos, pilares, estátuas). Sem isso, a alternativa mínima: a parte coberta do herói sem corpo, só o fio marfim a no máximo 50% de opacidade | Com o comando do `12`, o topo do obelisco aparece vazado e o herói lê como atrás dele; nenhum pé contornado sobre a pedra |
| P2 (D2, D3) | ui-ux-designer (`Fx`, `NumberTally`) | Com mais de 6 números novos no mesmo quadro, juntar os comuns num número só por golpe sobre o grupo (o total), mantendo separados só finalizadores e Ômega; nenhum número nasce dentro de um raio de 60 px do topo da cabeça do herói em tela (empurrar para fora) | No comando do `05`, nenhum número sobreposto a outro e cabeça e tronco do herói livres de texto |
| P3 (D3) | ui-ux-designer ou quem for dono de `EnemyFx`/projéteis | Orbe do feiticeiro em violeta, abaixo do limiar do brilho (o miolo hoje fica quase branco e com halo maior que a cabeça do herói) | Em `cmp_heroi20` o ponto mais claro do bolo deixa de ser o orbe |
| P4 (D5) | environment-artist (`screen.gdshader`) | Separação de cor dos finalizadores com no máximo 1 px a 1080p e só no centro de 60% da tela (sem franja nas bordas), ou desligada | Em `08` o esqueleto da borda direita sem contorno colorido |
| P5 (critério 4) | qa-performance | Uma captura de sala 3 real com a composição sorteada (sem `--stress-ids`), e uma de Morvath com os ajudantes em volta | Duas imagens novas no próximo ciclo |
| P6 (D4) | art-director, no ciclo 9 | Rever o tamanho dos preparos no corpo a 54 m depois do teste do Daniel; só mexer se ele não ler | Opinião do Daniel |

Dependem de modelo que não existe (sem mudança neste ciclo): estátuas, moldura do portal e ruínas continuam formas
provisórias à espera do `docs/art/meshy_asset_plan.md`; as elites continuam com o ouro por shader (repintura no Meshy
depende do Daniel). Nada deste ciclo muda a fidelidade da sala à pintura de referência.

## G. Resultados dos testes (do QA, `84285e8`)

- Importação e `tools/check.gd`: 0 `SCRIPT ERROR`, 0 `Parse Error`.
- `tools/test.sh`: 24 arquivos, 260 testes, 259 passando, 0 falhando, 1 arriscado (`test_only_finishers_glint`, o
  conhecido). Testes novos do ciclo: `test_encounters.gd`, `test_indicators.gd`, `test_fx_budget.gd`, e
  `test_fx_on_hit.gd` e `test_hero_look.gd` ampliados.
- `tools/title_flow_check.gd`: FLOW ok, 12 de 12.
- Partidas do robô: chega em Morvath nas cinco sementes (aos 62 a 74 s) e vence na semente 7; `max_alive` nunca passa
  de 8 numa partida de verdade. As partidas ficaram mais longas (171 a 233 s, antes 130 a 213): efeito esperado da
  densidade menor; balanceamento é do gameplay-engineer e do Daniel.
- Uma linha `ERROR` por execução (`2 ObjectDB instances were leaked`), igual ao ciclo 7.

## H. Desempenho real (do QA)

Máquina: notebook ASUS TUF Gaming F16 FX608JMI na tomada, Intel Core i7-14650HX, NVIDIA GeForce RTX 5060 Laptop GPU
(8 GB, driver 621.01), 16 GB de RAM, Windows 11. Godot 4.7.2 de Windows, Vulkan Forward+, **1920 x 1080 conferido pela
imagem do viewport**, VSync desligado, `--fixed-fps 60`, semente 5; mediana de três rodadas alternadas de 300 quadros.
Cenas de 8 a 20 com os N inimigos de pé o tempo todo (herói parado com vida alta).

| Cena | De pé | Quadro antes (`eb1e9d7`) | Quadro depois (`84285e8`) | FPS antes / depois | p90 depois | GPU depois |
|---|---|---|---|---|---|---|
| Partida `--bot --autopick` | 2 / 4 | 4,51 ms | 4,78 ms | 222 / 209 | 5,43 ms | 4,67 ms |
| 8 inimigos | 8 | 4,68 ms | 4,78 ms | 214 / 209 | 5,38 ms | 4,70 ms |
| 12 inimigos | 12 | 4,73 ms | 4,84 ms | 211 / 207 | 5,36 ms | 4,76 ms |
| 16 inimigos | 16 | 4,74 ms | 4,82 ms | 211 / 207 | 5,38 ms | 4,71 ms |
| 20 inimigos | 20 | 4,73 ms | 4,82 ms | 211 / 207 | 5,41 ms | 4,72 ms |
| 90 (referência, 1 rodada) | 90 | 5,16 ms | 5,54 ms | 194 / 181 | 6,05 ms | 5,44 ms |
| 300 (referência, 1 rodada) | 300 | 8,30 ms | 8,34 ms | 120 / 120 | 9,00 ms | 7,37 ms |

O ciclo custa de +0,08 a +0,11 ms com 8 a 20 inimigos (a variação entre rodadas chega a 0,5 ms). Meta de 60 FPS a
1080p cumprida com folga. Não medido: celular, navegador (Compatibility), placa fraca, versão exportada, 1440p e 4K.

**Correção do ciclo 7**: a tabela de desempenho da [revisão do ciclo 7](../cycle7/ART_REVIEW.md) (seção E) diz
"janela 1672 x 941", mas aqueles números eram de **1280 x 720**: a sonda antiga, rodando com `-s`, não aplicava o
`--resolution` e o jogo voltava ao tamanho salvo. Por isso o ciclo 7 mostra quadros de 2,7 ms e este de 4,8 ms: não é
o jogo que ficou mais pesado, é a resolução que agora é a pedida. A sonda nova repõe o tamanho e confere pela imagem.

## I. Todas as capturas

**Contrato (depois, `84285e8`)**
- [01 combate com 4](01_combate_4_inimigos.jpg), [02 com 8](02_combate_8_inimigos.jpg),
  [03 com 12](03_combate_12_inimigos.jpg), [04 com 16](04_combate_16_inimigos.jpg),
  [05 com 20](05_combate_20_inimigos.jpg)
- [06 Explorador em combate](06_explorador_em_combate.jpg)
- [07 Emeth ataque](07_emeth_ataque.jpg), [08 Emeth impacto (Ômega)](08_emeth_impacto.jpg),
  [09 Emeth especial](09_emeth_especial.jpg)
- [10 inimigos preparando ataque](10_inimigos_preparando_ataque.jpg),
  [10b preparo no laboratório](10b_preparo_laboratorio.jpg)
- [11 elite](11_elite.jpg), [12 obstáculo e transparência](12_obstaculo_transparencia.jpg), [13 HUD](13_hud.jpg),
  [14 Morvath atual](14_morvath_atual.jpg)

**Antes e depois** (`eb1e9d7` contra `84285e8`; mesmo comando, não o mesmo instante, porque a geração das salas mudou)
- [combate](before_after_combate.jpg), [Emeth](before_after_emeth.jpg), [obstáculo](before_after_obstaculo.jpg),
  [HUD](before_after_hud.jpg)

**Trabalho das frentes** ([work/](work/))
- Herói e Emeth: [cmp_golpe](work/cmp_golpe.jpg), [cmp_impacto](work/cmp_impacto.jpg),
  [cmp_especial](work/cmp_especial.jpg), [cmp_omega](work/cmp_omega.jpg), [cmp_obelisco](work/cmp_obelisco.jpg),
  [cmp_heroi12](work/cmp_heroi12.jpg), [cmp_heroi16](work/cmp_heroi16.jpg), [cmp_heroi20](work/cmp_heroi20.jpg);
  quadros inteiros `antes_*` e `depois_*` na mesma pasta.
- Avisos, barras e HUD: [c8c_avisos_lab](work/c8c_avisos_lab.jpg), [c8c_preparo_lab](work/c8c_preparo_lab.jpg),
  [c8c_aviso_linha_jogo](work/c8c_aviso_linha_jogo.jpg), [c8c_barras_12](work/c8c_barras_12.jpg),
  [c8c_barras_12_perto](work/c8c_barras_12_perto.jpg), [c8c_elite_armadura](work/c8c_elite_armadura.jpg),
  [c8c_hud_1280](work/c8c_hud_1280.jpg), [c8c_hud_1920](work/c8c_hud_1920.jpg),
  [c8c_hud_1920_recarga](work/c8c_hud_1920_recarga.jpg), [c8c_hud_acoes_perto](work/c8c_hud_acoes_perto.jpg),
  [c8c_stress_16](work/c8c_stress_16.jpg), [c8c_stress_20](work/c8c_stress_20.jpg),
  [c8c_stress_300](work/c8c_stress_300.jpg). As `c8c_*` são do `41f532b`, antes da troca do clarão: os inimigos
  brancos que aparecem nelas (por exemplo `c8c_stress_20`, `c8c_barras_12_perto`) já não existem no `84285e8`.

**Documentos**: [CAPTURAS.md](CAPTURAS.md), [proposta de Morvath](../../design/morvath_boss_fight.md),
[relatório de QA](../../qa/latest_report.md).

## Os três problemas mais importantes que ficam

1. Herói atrás do obelisco ainda parece em cima dele (D1, pedido P1).
2. Números de dano sobrepostos e cobrindo o herói quando mais de 10 inimigos levam o mesmo golpe (D2, pedido P2).
3. Herói difícil de achar no bolo de 20, puxado pelos números e pelo orbe quase branco do feiticeiro (D3, pedidos P2
   e P3).

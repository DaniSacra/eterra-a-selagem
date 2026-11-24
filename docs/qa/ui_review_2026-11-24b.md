# Revisão de interface, passada 2 (build 1342184, 2026-11-24)

Método: leitura de `docs/gallery/round_2026-11-24/` (1672x941, uma só resolução) contra `docs/qa/ui_review_2026-11-24.md`. Nada foi implementado nem capturado. `raiox.png` não foi julgado (sem item de interface). Coordenadas em pixels da captura. P = pequeno, M = médio.

## A. Itens da revisão anterior

| # | Estado | Nota |
|---|---|---|
| 1 Nome do golpe ao lado da Esquiva | FEITO | `giro.png`, `sala1_portal.png`: o nome flutua sobre o slot do próprio golpe (Giro da Alvorada, Investida). |
| 2 Glifo por Encanto | NÃO VERIFICÁVEL | Sem captura da escolha de Encanto. Capturar. |
| 3 Preços da Videira | ABERTO em parte | `vine.png`: nós mostram nome e preço, mas os preços dos nós bloqueados (10, 20, 6) são cinza sobre marrom, contraste baixo; "Colheita de Memória" (943,419) cai a ~11 px. Nó comprado não apareceu (0 de 9): sem prova. |
| 4 Medalhão dos Dons | FEITO em parte | Legenda sobe e diz "Escuro: o número é a Maestria que falta" (1296,850). Números dentro dos nós ficam em ~10 px e quase ilegíveis (ver B3). |
| 5 Devoção | FEITO | "Vagas 6 de 6" no topo, texto explicativo em corpo maior. Ver B4 (ícone). |
| 6 Dica cobre o setor | FEITO, com defeito novo | A dica não cobre mais "FÚRIA", mas está cortada (ver B2). |
| 7 Caixa de bloqueio parece botão | NÃO VERIFICÁVEL | O Dom da captura é pagável (EQUIPAR). Capturar um Dom selado sem Memória. |
| 8 Três moedas | FEITO | Prata, Memória, Esmeralda com nome e mesma ordem em Dons, Forja, Vendedor, Videira, Livro. |
| 9 Verbos da Forja | FEITO em parte | Subtítulos presentes ("Acorda a pedra do punho"). Causa do bloqueio de Despertar/Refinar não aparece na captura; o texto do painel só mostra o caso "Pronto". |
| 10 Martelar / ou segure | ABERTO | Agora a mesma frase aparece quatro vezes (ver B6). |
| 11 Enter muda de sentido | ABERTO em três telas | Vendedor "PÔR NO PRATO" e Forja "MARTELAR" corretos. Videira (REGAR sem poder pagar), Livro (ABRIR com foco no botão Descer), fim de descida (CONFIRMAR) errados (ver B1). |
| 12 Voltar | FEITO | Chips iguais em todas; Dons agora usa PageUp/PageDown SETOR e Esc VOLTAR. |
| 13 Inglês | FEITO | Nenhum "Ultimate"/"XP" visível. "Maestria" ok. |
| 14 Aviso do Livro em vermelho | FEITO | "No nível 2 você ganha o Dom Ímpeto" em dourado (ver B9, contraste). |
| 15 Coluna duplicada da direita | FEITO | Some do HUD. |
| 16 Vida e Magia | FEITO | Vida em cima, com coração e gota. Ver B8 (terceira barra). |
| 17, 18, 20 | NÃO VERIFICÁVEL | Sem captura de dica de Mouse, porta com Ouro ou selo ERGUIDA. |
| 19 Texto sobre a porta | ABERTO | `shop_wall.png`: rótulos de preço da loja em ~14 px, e os da direita cortados pela borda (B5). |

## B. Problemas novos

**P0**

B1. **Enter com verbo errado em três telas** (P). 
- `vine.png` (1373-1492, 905): "Enter REGAR" com a raiz Seiva sem pagar (0 de 5 Prata); o botão do painel já diz "Faltam 5 de Prata". Correção: o chip do rodapé vira texto apagado "Faltam 5 de Prata" (ou some) quando `can_afford` é falso. Arquivo: `scripts/ui/vine_screen.gd` (onde monta `bar_water`).
- `book.png` (1380-1465, 905): "Enter ABRIR" com o botão "Descer às catacumbas" em foco; devia ser "DESCER". Arquivo: `scripts/ui/book_screen.gd` (a chave `bar_open_page` só serve com o foco na aba/página). Correção: rótulo vindo do foco (botão = o texto do botão).
- `end_none.png` (1472-1635, 905): "Enter CONFIRMAR" sobre a tela "Morvath foi selado", cujos botões são "Voltar ao Santuário" e "Descer de novo". Correção: o rodapé mostra o texto do botão em foco (`end_screen.gd`). A captura pegou a tela em fade (botões quase invisíveis): ver pedido de recaptura.

**P1**

B2. **Dica do Dom cortada e sobre o herói** (P). `dons.png` (410-770, 487): "O combo ganha um quarto golpe, uma estoc" termina no meio da palavra e a caixa cobre o nó selecionado (443-513, 450-520). A mesma frase já está completa no painel da direita. Arquivo: `scripts/ui/medallion_view.gd` (`caption_spot`). Correção: largura da dica com quebra de linha em duas linhas, ou não repetir a descrição (só o nome do Dom) e posicionar fora do nó.

B3. **Números dos nós dos Dons pequenos demais** (M). `dons.png`: 10 a 12 px, cinza sobre círculo escuro (ex.: 648,218; 1141,501). Para criança de 8 a 12 é ilegível, e o número é justamente a informação ("Maestria que falta"). Arquivo: `medallion_view.gd`. Correção: fonte 16 a 18 px em creme com contorno, e raio do nó um pouco maior (ou só os 28 nós em escala 1.15 em 1280x720).

B4. **Ícone de "Vagas" igual à moeda de Ouro** (P). `dons.png` (1068,73; 1292,537) e HUD `Ouro: 0` (1540,895): mesmo disco dourado. "Vagas 3" no custo parece dinheiro. Arquivos: `dons_screen.gd`, `dons_panel.gd`. Correção: ícone de vaga (engaste vazio/losango) e "Vagas 3" com "de 6 livres" numa só forma. Hoje há duas: "Vagas 6 de 6" (topo) e "livre 6 de 6" (1550-1630, 537). Manter só a do topo.

B5. **Preços das mercadorias cortados e minúsculos** (P). `shop_wall.png`: "50 ouro" (1350,5) e "Mais Vi... 125 ouro" (1590-1672, 22-43) sofrem corte na borda; os de baixo têm ~14 px. A parede de lojas fica perto demais da borda direita/superior na entrada da sala 13. Arquivos: `scripts/game/rooms.gd` `_marker` (raio-x do rótulo), layout da loja. Correção: rótulo com `clamp` à tela (empurrar para dentro) e corpo 18 px com contorno; e/ou dar mais margem à entrada (o `gameplay-engineer` mexe em `rooms.gd`, combinar).

B6. **Forja repete a mesma instrução quatro vezes** (P). `forge.png`: "Pronto: aperte três vezes ou segure para martelar" (306-675, 686-715), chip "MARTELAR ooo" (615-1057, 833), "Aperte três vezes ou segure" (1077-1268, 834), chip do rodapé "Enter MARTELAR" (1340-1492, 905). Além disso o painel tem um vazio grande entre 730 e 800. Arquivo: `forge_screen.gd`, `forge_bench.gd`. Correção: deixar só o botão com três bolinhas e a frase "Aperte três vezes ou segure" dentro dele; o texto de status do painel só serve para o estado de bloqueio (causa) ou o resultado.

B7. **Videira repete "Faltam 5 de Prata" três vezes e deixa o painel vazio** (P). `vine.png` (1278-1430, 257), preço grande "5" em vermelho (1328,585), botão (1357-1552, 675). Linhas "Mais 5 de vida máxima" e "Vida máxima: +5 com esta" também são a mesma informação (1278-1500, 290-324). Painel com 220 px livres. Arquivos: `vine_screen.gd`. Correção: tirar a linha vermelha de cima e a segunda frase do efeito; o preço fica no bloco de baixo, o botão traz o estado.

B8. **Terceira barra sem rótulo e contador "4" solto** (P). `ult_ring_hud.png` (143-400, 891): barra ciano fina abaixo da Magia, sem ícone nem valor (carga do Golpe Supremo, imagina-se). `giro.png` (480-520, 843): losango com "4" e pontinho verde ao lado da Vida sem legenda (contador do combo? Fúria?). Arquivos: `scripts/ui/hud.gd` e componentes. Correção: ícone mínimo à esquerda de cada um (raio para a barra, cargas com o mesmo glifo do slot) e legenda na primeira vez, ou levar a carga para o slot Shift (anel de carga).

B9. **Slot Shift muda de lugar e de estado** (P). `shop_wall.png` mostra Shift com cadeado e rótulo "Maestria 3" sobre ele; `giro.png` e `sala1_portal.png` não têm slot Shift e a barra desloca-se 20 px. Duas leituras: o Shift some ou está ali. Correção: sempre desenhar o slot (apagado e com cadeado) para a barra não pular, e o rótulo "Golpe Supremo no nível 3" em vez de só "Maestria 3". Arquivos: `scripts/ui/action_bar.gd`, `action_slot.gd`.

B10. **Aviso dourado do Livro com contraste baixo** (P). `book.png` (967-1260, 183): ouro claro sobre pergaminho bege, ~11 px. Corpo 16 px e ouro escuro (o mesmo do título da seção), ou cor de rubrica do próprio livro. Arquivo: `scripts/ui/book_screen.gd`. Junto: o losango "1" da Maestria (995,143) não diz que é o nível; escrever "Nível 1" ao lado ou embaixo.

**P2**

B11. **Abas do Livro sem nome** (P). `book.png` (806-968, 28-68): as três abas pequenas (Guerreiro, Forja) são só ícones de 30 px, sem rótulo ao focar. Correção: nome da aba em dica ou ao lado quando em foco (`book_screen.gd`).

B12. **Vendedor: painel da Troca sobre o pé da balança** (P). `vendor.png` (528-1145, 532-712): a caixa corta a haste da balança (837,525) e os pratos fantasmas "10" e "1" ficam cinza claro sobre bege, ilegíveis (600,420; 1100,428); o terço inferior (y 800-940) é vazio. Obras sem descrição: "Discernimento I/II" (1246-1447, 566-665) não dizem o que fazem. Arquivos: `vendor_screen.gd`, `vendor_plate.gd`. Correção: subir a balança e usar o espaço de baixo para uma linha de efeito da Obra em foco.

B13. **Nós da Videira sem legenda de estado** (P). `vine.png`: bolas verdes (disponível?), cinza (bloqueada?) e o anel laranja (foco) sem legenda; "O Viajante" tem preço vermelho de Memória (3) sem que se saiba que a moeda é outra. Arquivo: `vine_screen.gd`. Correção: legenda de duas linhas abaixo do painel e preço em creme com o ícone da moeda (o ícone já existe), vermelho só pintando o número.

B14. **Rótulos de setor encostam nos nós** (P). `dons.png`: "SUSTENTO" (968-1072, 316) sobre o nó 9/12 (1063-1105, 270-340) e "EMETH" (1038-1122, 552) sobre o nó 3 (1134, 553). Arquivo: `medallion_view.gd`. Correção: afastar o rótulo 14 px do raio do círculo externo.

B15. **Número de dano vermelho minúsculo** (P). `ult_ring_hud.png` (325,403): "5" vermelho, ~10 px, sobre parede azul; inverso do "15" branco legível de `sala1_portal.png` (985,355). Arquivo: `scripts/game/fx.gd`. Correção: mínimo de corpo para qualquer cor e contorno escuro (dano ao herói ou recebido? vermelho só se for do herói, senão manter branco).

## C. Observações sem item

- Os números de vida `99984 / 99999` em `ult_ring_hud.png` são do robô, mas a captura em `docs/gallery` deve ser descartada ou refeita com vida normal, para não confundir o Daniel.
- Nomes de arquivo enganam: `sala1_portal.png` não tem portal nem tela de golpe; `giro.png` é a sala 1. Trocar o nome ou refazer.

## D. Capturas que faltam (só a sessão principal)

1. Fim de descida estável (esperar o fade, para ver botões e a linha `end_brought_none`):
`tools/gpu.sh shot docs/gallery/round_2026-11-24/end_stable.png --bot --autopick --seed=5 --boss-hp=0.05 --start=boss --shot-at=14`
2. Dom selado sem Memória e Encanto na escolha: `tools/gpu.sh shot docs/gallery/round_2026-11-24/dons_sealed.png --title --screen=moves` (ajustar para a tela dos Dons com foco num Dom selado).
3. HUD com horda para conferir B8, B9 e B15: `tools/gpu.sh shot docs/gallery/round_2026-11-24/horde.png --bot --autopick --seed=5 --stress=300 --shot-at=9`, e as duas resoluções de cada tela nova (`RES=1280x720`), ainda não verificadas (as capturas desta rodada são todas 1672x941).

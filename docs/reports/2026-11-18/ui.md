# Relatório de interface, 2026-11-18 (ui-ux-designer)

HEAD `dd1f5ba` (`arpg-3d`). Capturas reais na RTX 5060 (Vulkan, Forward+) a 1280 x 720 e 1920 x 1080 em
`docs/reports/2026-11-18/ui/` (JPEG, 102 arquivos, sufixo `_720` ou `_1080`). Nada de código alterado.

## Resumo
1. A interface escala bem de 720 a 1080 (stretch `canvas_items` + âncoras): nenhuma tela cortada ou fora do lugar nas duas resoluções.
2. O nome do especial está dividido: o HUD e o Compêndio dizem "Seta de Luz", o Como Jogar diz "seta de luz", o Livro diz "onda de luz" (D-69). Esse é o achado de texto mais visível.
3. Ainda há termos que não batem entre telas: Leve/Pesado e "(E)/(D)" contra Ataque/Especial, Avanço contra Esquiva, Tentar de novo contra Descer de novo. O texto da ultimate no Como Jogar está desatualizado desde a T5.
4. Com muitas Bênçãos, a fileira de passivas do HUD não tem limite e encosta na borda da tela (16 ícones chegam a x 1916 de 1920). Nas telas Juramentos e Músicas falta a moldura das páginas 1B.
5. Checagem, testes (992/992) e fluxo do título por teclado passam. Controle e mouse não têm verificação automática nos menus, e voltaram os avisos de vazamento no fim dos testes.

## Verificação
- `godot -s tools/check.gd`: `CHECK ok`.
- `tools/test.sh`: 992 de 992 testes passando (237.994 asserts). **Regressão de higiene**: no fim aparecem de novo
  `28 ObjectDB instances were leaked` e `19 resources still in use` (o ciclo 10 tinha zerado isso). Não é da UI, mas
  fica registrado.
- `tools/title_flow_check.gd`: `FLOW ok` (título, Guerreiro, Como Jogar, Compêndio, Configurações e os interruptores de Conforto,
  Músicas, Juramentos, Descer, volta da pausa). Só teclado.
- Textos (`data/text_pt.tres`): nenhum travessão (`—`, `–`). Nenhuma chave usada em `T.t()` falta na tabela.
  `PALADIN_n` só aparece como marcador (some do texto por `TextTable._clauses`; nada visível nas capturas).
- Comandos das capturas: `tools/gpu.sh shot` (HUD, horda, Morvath, título, Juramentos, Como Jogar, Golpes, ultimate,
  Cripta) e `tools/gpu.sh run -s tools/ui_lab.gd|menu_lab.gd|book_lab.gd`, saída temporária em
  `C:\Users\danie\AppData\Local\Temp\eterra_ui` (nada novo em `C:\Users\danie\tools`).

## Achados

### P0
Nenhum. Nada trava a navegação, nenhuma tela fica sem saída e o HUD nunca cobre o herói.

### P1
- **UI-P1-01: o especial tem três nomes.** O HUD mostra "Seta de Luz" abaixo do contador de golpes (`hud_720.jpg`, `boss_720.jpg`,
  `psalm_720_psalm_banner.jpg`, `ult_720.jpg`), e o Compêndio > Golpes também (`move_bolt` em `data/combos/paladin.tres` e
  `paladin_fourth.tres`, gerado em `make_data.gd:118`). O Como Jogar diz "Dispara uma seta de luz" (`howto_heavy_attack_desc`),
  mas o Livro diz "Uma onda de luz da lâmina, à distância" (`hero_skill_special`, `book_720_hero.jpg`). D-69 decidiu
  pela onda, e a chave `move_wave` "Onda de Luz" existe sem uso. Correção: o título do nó passa a `move_wave` no `make_data.gd`,
  regerar `combos` e reescrever `howto_heavy_attack_desc`.
- **UI-P1-02: o Como Jogar ensina a ultimate errado.** `howto_ultimate_desc` diz "escolhido antes da descida. Carrega com a
  Magia gasta nos Ômegas". Desde a T5 a ultimate carrega também pelo dano causado e sofrido, e a primeira aberta vem sem escolha. Já
  o `hud_ult_charge_tip` e o Livro ("Carrega com Magia e dano") estão certos.
- **UI-P1-03: nomes dos golpes nos Controles e nas cartas.** Em Configurações > Controles aparecem "Leve (E)" e "Pesado (D)"
  (`menu_720_options_tab_controls.jpg`): o "D" se confunde com a tecla D, que move para a direita na mesma tela, e "Leve/Pesado" não é
  como o jogo chama essas ações (Ataque/Especial no HUD, no Como Jogar e no Livro). As cartas repetem o problema: "Golpes leves
  incendeiam" (Golpe em Brasa) e "Golpes pesados congelam" (Toque da Geada, que é do Especial) em `elo_720_panel.jpg`. O
  Compêndio > Golpes usa "E E E", "D segurado" e a legenda "E: ataque. D: especial." (`moves_720.jpg`), mais uma notação que
  colide com as teclas. Uniformizar para Ataque/Especial e mostrar o símbolo do HUD (`ActionSlot.mark`) no lugar de E/D.
- **UI-P1-04: a fileira de passivas do HUD não tem limite.** `Hud._update_passives` acrescenta um `BoonIcon` de 30 px por Bênção
  sem limite, a partir de `width/2 + 18` à direita do centro. Com 16 passivas ela chega a x 1916 de 1920
  (`menu_1080_pause_many.jpg`) e a 1275 de 1280 (`menu_720_pause_many.jpg`). Com mais, sai da tela. A pausa e o fim de partida
  já cortam com "+N". O HUD deve fazer o mesmo (no máximo cerca de 10 e depois "+N") ou quebrar em duas linhas.
- **UI-P1-05: Juramentos e Músicas sem a moldura 1B.** As duas ainda são telas soltas sobre o título borrado, com o logotipo
  aparecendo atrás do texto (`juramentos_720.jpg`, `menu_720_music.jpg`). Configurações, Como Jogar, pausa e fim já usam
  o painel com filete e losango. O jogador chega a Músicas a partir das Configurações e a moldura muda de uma tela para a outra.
- **UI-P1-06: texto pequeno e cortado no Livro e no Compêndio a 720.** As descrições das Habilidades na página "O Guerreiro" têm cerca
  de 12 px, cinza sobre pergaminho (`book_720_hero.jpg`). No Compêndio > Dons, a descrição de Ímpeto é cortada com "..."
  (`book_720_codex_0.jpg`), e em lugar nenhum dessa tela se lê o texto inteiro. Quebrar em duas linhas ou mostrar o texto inteiro no foco.
- **UI-P1-07 (confirmar com o gameplay-engineer): `--start=shop` abre a loja na Câmara do Selo com Morvath de pé.** A captura
  mostra "Sala 11 de 11", a barra de Morvath, Morvath no selo e as cinco placas da loja em volta dele (`shop_720_shop.jpg`,
  `shop_1080_shop.jpg`). `Rooms.start_at(SHOP)` põe `depth = stage.rooms - 1`. Pela descida padrão a loja é a sala 10 e fica no salão. Se
  isso for só a opção de teste, as capturas da loja (`ui_lab --shop`) estão erradas. Se a partida real também cai aí, é P0.

### P2
- **UI-P2-01:** a saudação "Bênção nova" (`EloBanner`) continua na tela durante a pausa (`menu_1080_pause_many.jpg`) e aparece
  atrás do título da escolha de Bênção (`elo_720_card.jpg`, onde "Brasas" fica fantasma sob "Escolha uma bênção"). Nas capturas isso vem
  do laboratório, que toma Bênçãos um pouco antes, mas em jogo pode acontecer com um Elo formado logo antes de uma porta. Esconder
  a saudação enquanto uma tela está aberta e mostrar o resto depois, como o "Salmo descoberto" já faz.
- **UI-P2-02:** a saudação fica entre y 92 e 192 a 720 e passa por cima de inimigos na parte de cima da arena (em
  `psalm_720_psalm_banner.jpg` um esqueleto com a barra cruza "A luz vigia ao seu lado"). Dura pouco, mas a regra é não cobrir
  inimigos. Subir para junto do relógio ou pôr um véu escuro atrás.
- **UI-P2-03:** maiúsculas desiguais: "Escolha uma bênção" e "Suas bênçãos" contra "Bênção", "Bênçãos" e "Fortalecer bênção" na
  loja. As Bênçãos da Provação vêm como "Magia ampla" e "Círculo firme", e as das portas como "Maré de Luz" e "Golpe em Brasa". O rodapé do
  Compêndio diz "Toda bênção oferecida". Escolher uma regra: nomes próprios em Title Case, e Bênção sempre maiúscula como termo do jogo.
- **UI-P2-04:** os rótulos dos dois finais não batem: a derrota tem "Tentar de novo / Menu" e a vitória "Descer de novo /
  Continuar" (`menu_720_defeat.jpg`, `menu_720_victory.jpg`). Usar "Descer de novo" nos dois, e "Menu" e "Continuar" com o mesmo destino.
- **UI-P2-05:** a esquiva tem dois nomes: "Avanço" no Como Jogar e no Livro, "Esquiva" no HUD (`slot_dash`), nas Configurações e em 12 textos de
  Bênção e Dom. Ficar com um só ("Esquiva" é o mais usado; "Avanço" também é o nome de um Dom de Fúria, "Avanço Feroz").
- **UI-P2-06:** números quebrados no texto do jogador: "22,5 de vida máxima a mais" (Vigor Rara na Provação,
  `trial_720_trial.jpg`, `trial_720_trial_won.jpg`), enquanto o HUD mostra vida inteira (53/53). Arredondar na exibição.
- **UI-P2-07:** "Ultimate" em inglês no HUD, nas Configurações, no Como Jogar e no fim ("Nova ultimate"). Se for decisão do
  Daniel, tudo bem. Se não, sugerir um nome em português (pergunta para o Game Director).
- **UI-P2-08:** o glifo de cruz aparece nos ícones pequenos. O Corte do Juízo no losango R aparece como uma espada em pé que, a 30 a 54 px, se lê
  como cruz (`ult_720.jpg`, `ult_1080.jpg`). O escudo da Vigília com a estrela de quatro pontas e um ícone azul em "†" nas
  fileiras de Bênçãos (`menu_720_pause_many.jpg`, `menu_720_defeat.jpg`) também lêem como cruz. A regra é "nunca cruz":
  pedir ao art-director para alongar a lâmina ou abrir a guarda nos tamanhos pequenos.
- **UI-P2-09:** o nome do golpe ("Giro da Alvorada", "Seta de Luz") fica no canto direito depois que o contador de golpes some
  (`shop_720_shop.jpg`, `menu_720_defeat.jpg`). Os dois deveriam sumir juntos.
- **UI-P2-10:** a divisa de fora da tela (amarela) da Provação e das salas desenha por cima da legenda "Maestria 2" do 5º losango
  (`trial_720_trial_seal.jpg`, `trial_720_trial_won.jpg`). `EDGE_INSET` embaixo (116) não reserva a faixa da legenda.
- **UI-P2-11:** a legenda da ultimate tem 12 px (`ActionSlot.CAPTION_FONT`) e a tecla do losango 13 px a 720. É a menor letra do
  HUD e lê mal sobre o chão claro.
- **UI-P2-12:** controle nos menus: as abas (Configurações, Como Jogar, capítulos do Livro, índice do Compêndio) só se trocam
  levando o foco até elas. Não há LB/RB, nem troca de capítulo pelos gatilhos. As teclas só se remapeiam no teclado e no mouse
  (`OptionsScreen._input` ignora o controle). Nenhum teste anda os menus pelo controle ou pelo mouse
  (`title_flow_check.gd` é só teclado).
- **UI-P2-13:** espaço morto: Como Jogar > A descida usa um terço do painel (`menu_720_howto.jpg`), Conforto deixa metade
  vazia, as cartas de Bênção têm a metade de baixo vazia quando o texto é curto (`elo_720_card.jpg`). E o Livro > Abertura repete
  o Como Jogar palavra por palavra (`book_720_opening.jpg`).
- **UI-P2-14:** no Livro, a ultimate Voragem, já aberta na Maestria 11, aparece sem estado nenhum, enquanto Corte do Juízo diz
  "Escolhida" (`book_720_gifts_furia_plena.jpg`). Mostrar "Disponível" ou "Equipar".
- **UI-P2-15:** ferramentas. Com `--bot`, o `ui_lab --trial` captura a tela da Provação vazia (só título e linhas, sem
  cartas), porque o robô pisa na laje antes do laboratório. Sem `--bot` funciona (`trial_720_trial.jpg` foi refeito assim). O
  comentário do `ui_lab.gd` precisa dizer isso, ou o laboratório desliga o robô antes dos 7 s. E o `howto_lab` não captura a aba
  Controles do Como Jogar.
- **UI-P2-16 (horda, `--stress=300`):** o herói continua achável pelo anel e pelo raio-x, e o HUD não cobre nada
  (`stress_720.jpg`, `stress_1080.jpg`). Mas acima de 24 inimigos as barras dos feridos viram um tapete de traços vermelhos que
  disputa com os avisos vermelhos do chão. Fica fora do teto de 20 do jogo, então é só informativo. Se o modo horda voltar,
  esconder as barras dos inimigos a mais de 8 m do herói.

## Leitura do combate (o que está bom)
- No HUD só fica o essencial: vida e Magia num canto, as quatro (ou cinco) ações no centro de baixo, sala, relógio e ouro em
  cima. Nada fica sobre o herói. Os números de dano ficam acima das barras e longe da cabeça dele (`hud_1080.jpg`).
- A barra de Morvath com as marcas de fase e o nome fica em cima, e a área de jogo fica livre (`boss_720.jpg`).
- As cartas de Provação e Altar explicam a troca: "você entrega / você recebe", o porquê do bloqueio e "Sem custo"
  (`trial_720_trial.jpg`, `altar_720_altar.jpg`). A laje tem custo e recusa legíveis (`slab_720_slab.jpg`).
- A ultimate pronta tem anel esmeralda e tecla R. Trancada, mostra cadeado e "Maestria 2" (`ult_720.jpg`, `trial_720_trial_seal.jpg`).
- Fim de partida com Maestria, origem do XP e o que abriu, com foco já em "Tentar de novo" ou "Continuar".

## As 10 melhorias de maior ganho
Critério: quanto confunde ou atrapalha um jogador novo (peso 3), quantas telas toca (2) e o custo (1, inverso). Do maior
ganho para o menor.

1. **Um nome só para o especial: "Onda de Luz"** (UI-P1-01). Aparece em toda luta e contradiz a decisão D-69. Custo mínimo: um título no
   `make_data.gd` mais uma frase. Aceite: nenhum "seta" no texto do jogador (teste de texto) e captura do HUD com "Onda de Luz".
2. **Vocabulário único das ações: Ataque, Especial, Círculo, Esquiva, Ultimate** (UI-P1-03, UI-P2-05). Toca Controles,
   Compêndio > Golpes, cartas e Como Jogar. Aceite: um teste que procura "Leve", "Pesado", "(E)" e "(D)" nas chaves de texto do jogador, e
   notação de golpes com os símbolos do HUD.
3. **Como Jogar atualizado: ultimate, especial e eventos** (UI-P1-02). Corrigir a ultimate e acrescentar uma linha para Provação e
   Altar, que o PO não entendeu na T5. Aceite: cada frase do Como Jogar confere com a regra atual (revisão por chave).
4. **Limite na fileira de passivas do HUD** (UI-P1-04). Só aparece em partidas boas, mas sai da tela. Aceite: com 25 Bênçãos
   (`--boons=25`) nada passa de 96% da largura a 720 e a 1080, com "+N" no fim.
5. **Juramentos e Músicas no painel 1B** (UI-P1-05). Fecha o pacote de menus. Aceite: capturas a 720 e 1080 com o mesmo
   painel, título e filete das Configurações, e o fluxo do título passando.
6. **Saudações fora das telas e acima da luta** (UI-P2-01, UI-P2-02). Aceite: com uma escolha ou a pausa aberta, nenhuma
   saudação visível. Na luta, a saudação inteira acima de 12% da altura ou com véu, sem cobrir inimigo na captura com robô.
7. **Texto inteiro no Compêndio e Livro legível a 720** (UI-P1-06, UI-P2-11). Aceite: menor corpo de texto em 14 px a 720
   (21 a 1080), nenhuma reticência de corte, e a descrição do Dom em foco inteira.
8. **Controle nos menus: LB/RB troca abas e capítulos, e um teste de fluxo pelo controle** (UI-P2-12). O jogo é para Steam com
   controle. Aceite: `title_flow_check` ganha uma volta com `InputEventJoypadButton` (A, B, cruz, LB/RB) e outra com clique.
9. **Uma regra de maiúsculas e números arredondados** (UI-P2-03, UI-P2-06). Aceite: teste que confere os nomes de Bênção em Title Case e
   os números exibidos sem ",5" onde o HUD mostra inteiro.
10. **Glifos pequenos sem cruz** (UI-P2-08, com o art-director). Aceite: revisão de arte do losango R e dos ícones de 30 px, a 720
    e 1080, sem leitura de cruz.

## Pendências e observações
- Não capturei a aba Controles do Como Jogar (o `howto_lab` não tem a opção), as placas das portas comuns abertas depois de
  uma luta (`--start=fountain` não mostrou as portas no quadro) nem o selo da maldição de Morvath no HUD (a captura
  `--shot-on=hurt-cursed` pode não terminar se o robô não for amaldiçoado). Foram revisados pelo código.
- A fila da GPU estava dividida com os outros relatórios. As capturas levaram cerca de 1 hora.

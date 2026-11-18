# Backlog de art polish

- **Data**: 2026-11-18. **Autor**: game-director. **Commit lido**: `f83ccff` (HEAD de `arpg-3d`), com
  `git log dd1f5ba..HEAD` (24 commits: C17 gameplay, C17 texto e HUD, C18 cenário, auditoria de arte).
- **Pedido**: diretriz do PO de 2026-11-18 (`docs/art/po_directive_art_polish_2026-11-18.md`). Esta etapa é só
  planejamento: nada aqui foi implementado.
- **Fontes lidas**: a diretriz; a auditoria `docs/gallery/audit_2026-11-18/AUDITORIA.md` e o `INDEX.md` (feita no
  `dd1f5ba`); `docs/gallery/c18/README.md` com a tabela de luma e saturação; `docs/gallery/c17/` e `c17/ui/`; os sete
  relatórios de `docs/reports/2026-11-18/`; `docs/backlog.md`; `docs/arte/estetica.md`;
  `docs/design/game_feel_directive.md`, `po_directive_guardian.md`, `warrior_spec.md`; o cânone
  (`../dungeon-rpg/docs/mundo/canone.md`); o `CLAUDE.md`.
- **Capturas abertas por mim**: `c18/after/` shop, crypt, sanctuary, garden, trial, altar, boss3, storm, ritual, runes,
  vitrine; `c18/before/boss3`; auditoria `01_titulo_1080`, `05_livro_dons_furia_plena_1080`,
  `medalhoes_tres_familias_1080`, `21a_inimigos_todos_camera_do_jogo_1080`, `12_especial_onda_da_lamina_1080`;
  `c17/ui/after_book_1080_opening`; a prancha `docs/art/ref/direcao_2026-11-18/prancha_relicarios_cripta_livro_morvath.png`
  (IA, só local, intenção visual e não modelo).
- **Medido por mim** (com o corte de saturação acima de 60% e valor acima de 35% sobre a imagem reduzida a 640 px, script no
  scratchpad da sessão, mesmo método do `tools/frame_stats.py`): vermelho saturado no quadro `boss3` de 1,4% (antes) para
  3,0% (depois do C18), âmbar das Runas de 3,0% para 1,1%, verde do salão (`vitrine`) 1,7% para 1,9% (o portal).
- **Grafia**: a diretriz escreve "Akh"; o cânone fixa **Ahk** (`canone.md`, registro de 2026-11-04). Uso Ahk em tudo.
- **Numeração**: ART-01 a ART-10 são as famílias da diretriz; os itens são ART-01.1, ART-01.2... Os antigos ART-001 a
  ART-009 (três dígitos, ciclo 10, no `CLAUDE.md`) são outra série, já fechada.

Legenda: **P0** derruba a imagem em toda partida; **P1** perceptível e importante; **P2** acabamento. **Esforço** P
(horas), M (1 a 2 dias), G (vários dias). **Status**: FEITO (com commit), PARCIAL, ABERTO, BLOQUEADO (decisão ou asset),
EVIDÊNCIA (falta captura antes de criar tarefa), RECUSADO. O que é opinião minha está dito.

---

## A. Diagnóstico executivo

**Está bom (preservar):**
1. A identidade já é própria e coerente: ardósia, ouro velho, Emeth esmeralda, leão, Cinzel e Alegreya; cartas, pausa,
   vitória, derrota, Configurações e o Livro de Ahk falam a mesma língua de moldura.
2. O herói lê no meio da luta (cerca de 130 px a 1080, anel petróleo, raio-x atrás da multidão e da pedra).
3. A Câmara do Selo e a Ponte dos Condenados são os melhores cenários; a luta de Morvath tem leitura e espetáculo.
4. O C18 cumpriu o que prometeu nos números: luma de 55 a 68 em toda luta (Cripta 37 para 57), p90 de saturação 25 a 28
   no salão e 26 a 31 na câmara, violeta acima de 60% abaixo de 5% da tela fora da fase 4 (era até 47,9%), recompensas
   sem primitivos sem luz, colunas sem o "Y", câmaras de evento com fundo.

**Está abaixo (o que eu vejo nas capturas depois do C18):**
1. **As recompensas deixaram de ser primitivos, mas ainda não leem sozinhas.** No altar, Ouro e Bênção são dois discos
   dourados quase iguais (`c18/after/altar.jpg`); na loja os discos têm uns 70 px a 1080 e a marca uns 25 px
   (`shop.jpg`); o pedestal de 0,16 m lê como laje solta. A prancha pede relicário: objeto pousado, não ficha no ar.
2. **Ainda há peças chapadas que gritam protótipo**: o bloco da Provação é uma caixa com um X lilás (`trial.jpg`), o
   portal do salão é uma mancha verde sem forma (`vitrine.jpg`), as janelas da Câmara são retângulos laranja lisos em todo
   quadro da luta final (`boss3.jpg`), os braseiros têm miolo branco-amarelo estourado (`vitrine.jpg`, `shop.jpg`).
3. **Salas soltas no vazio**: a Cripta é uma caixa sobre cinza liso (`crypt.jpg`) e a Provação continua maquete com
   corte de parede à mostra e luma 43 (`trial.jpg`). As paredes do KayKit ainda leem como tijolo de brinquedo.
4. **O vermelho do perigo ficou mais forte, não mais leve**: as erupções trocaram o magenta pelo vermelho certo, mas são
   discos cheios; o vermelho saturado do quadro `boss3` dobrou (1,4% para 3,0%). E os estandartes do leão são do mesmo
   vermelho saturado do perigo em toda sala.
5. **Três níveis de ilustração na coleção**: 7 Bênçãos com medalhão pintado, 19 Bênçãos, 6 Elos e 4 Salmos em vetor
   chapado. O Livro tem a árvore num painel escuro de tela colado no pergaminho e a Abertura sem imagem.

**Prioritário de verdade (a minha ordem):** (1) recompensas que se leem pela forma e pela cor, e nenhuma peça chapada à
vista (ART-01, ART-04 e os resíduos de ART-02 e ART-03); (2) o vermelho de volta a ser exceção e o herói visível atrás de
Morvath (ART-05, depois do teste T6 do PO); (3) salas que não flutuam no vazio (ART-03); (4) Livro, coleção e título,
que dependem de respostas do Daniel (ART-06, ART-07, ART-08). Os modelos aprovados (Guerreiro, Emeth, nove inimigos)
ficam: nenhuma evidência pede refazê-los.

**O que só o Daniel jogando responde**: se acha cada recompensa sem ler a placa; se o herói se perde atrás de Morvath; se
os discos vermelhos das erupções incomodam ou ajudam; se a Provação e o Altar ainda parecem maquete com o fundo novo.

---

## B. Backlog consolidado

Cada item: problema, evidência, impacto, prioridade, solução, responsável, dependências, esforço, aceite, riscos, status
e decisão pendente. Itens fechados ficam numa linha com a prova.

### ART-01 Recompensas e objetos interativos (P0)

**ART-01.1 Primitivos sem luz trocados.** FEITO no C18 (`c14ea6e`, merge `befd2d5`): `RewardGem`, disco de ouro velho
com o medalhão pintado ou a marca do `DoorGlyph` em esmalte, sobre pedestal, um material por tipo, sem luz própria
(QW-106). Evidência: `c18/after/shop.jpg`, `altar.jpg`, `trial.jpg`. Falta a revisão do art-director (fecha junto com a
ART-01.2).

**ART-01.2 Cada recompensa reconhecível pela forma e pela cor, sem ler a placa.**
- Problema: discos todos em ouro com marca pequena; Bênção e Ouro iguais; a marca some a 720.
- Evidência: `c18/after/altar.jpg` (Ouro e Bênção, dois discos dourados lado a lado), `shop.jpg` (disco de cerca de 70 px,
  marca de cerca de 25 px a 1080; Bênção amarelada).
- Impacto: toda sala vencida e a loja; o critério de aceite do QW-106 ("reconhecida pelo símbolo a 720") não foi medido.
- Prioridade: **P0**. Esforço: P a M.
- Solução: esmalte por família com matiz e valor separados (proposta de partida na tabela de `art_direction.md` seção
  6.3: Bênção petróleo escuro com marca marfim, Ouro sem esmalte, a própria moeda em relevo, Romã carmim apagado, Coração
  rosa antigo, Magia azul-ardósia, Fonte marfim-azulado); marca a 60% da face; disco maior na tela (meta 90 px de
  diâmetro a 1080 na câmera do jogo).
- Responsável: `environment-artist` (`reward_gem.gd`, `reward_gem.gdshader`), `art-director` (cores), `ui-ux-designer`
  (o mapa recompensa para medalhão, se mudar).
- Dependências: nenhuma.
- Aceite: recorte 720 de loja, altar e sala vencida sem as placas: art-director e QA identificam 6 de 6 tipos; quaisquer
  dois esmaltes com matiz a 40 graus ou mais, ou valor a 0,2 ou mais; maior canal na tela até 226 (`ScreenTone`);
  pergunta no próximo teste do PO.
- Riscos: esmalte saturado demais volta a competir com o perigo (vermelho fica fora: Romã e Coração em valor baixo).
- Status: FEITO no AP-1, aguarda a revisão do art-director; evidências e números em `docs/gallery/ap1/README.md`. Esmalte por família (`RewardGem.ENAMEL_*`), Ouro sem esmalte (a própria moeda),
  marca a 60% da face, disco de 2 m (cerca de 90 px a 1080), halo atrás do disco; recorte 720 sem placa em
  `detail/rewards_720_no_sign.jpg` e Ouro ao lado da Bênção em `detail/altar_gold_blessing_720.jpg`.

**ART-01.3 Relicário: o objeto pousa em algo que se lê.**
- Problema: o pedestal baixo (0,16 m) some na câmera; o disco parece ficha no ar. A prancha mostra relicário de pedra
  com pano e medalhão pousado.
- Evidência: `c18/after/shop.jpg`, `altar.jpg`; prancha (quadro Relicários).
- Impacto: loja (5 itens), altar, fim de cada luta. Prioridade: **P1**. Esforço: M.
- Solução: relicário baixo (até 0,5 m, base chanfrada, filete de ouro velho), medalhão num suporte de ouro velho (sem
  flutuar; o balanço lento para a câmera pode ficar), pano com o leão na cor que o Daniel escolher (Q-22); a zona de pisar
  para comprar não muda e fica à frente do relicário, num degrau de 0,16 m.
- Responsável: `environment-artist` (peça), `gameplay-engineer` (confere a zona e a colisão), `art-director` (spec).
- Dependências: Q-13 (botão de usar muda onde o jogador fica); Q-22 (cor do pano).
- Aceite: `test_economy.gd` e as placas iguais; relicário nunca bloqueia andar nem tiro (topo abaixo de 1,0 m, fora do
  círculo de pisar); `fit_probe` sem área fantasma nova; na captura 720 o relicário é lido como objeto (art-director).
- Riscos: peça visual onde o herói pisa vira "fantasma" (regra do `fit_probe`); por isso o corpo do relicário fica atrás
  da zona, do lado oposto à câmera.
- Status: FEITO no AP-1 (pano petróleo com o leão em ouro velho, Q-22), aguarda a revisão do art-director; evidências e números em `docs/gallery/ap1/README.md`. Relicário de 0,5 m atrás do ponto,
  degrau de 8 cm sobre o ponto do toque (`Rooms` não mudou: a chamada do `RewardGem.make` é a mesma), fora da colisão;
  sobre a boca das portas o disco continua solto (ART-01.5).

**ART-01.4 Bloco da Provação: de caixa com X para estela rachada.**
- Problema: o `trial_block` é um cubo com a rachadura em X lilás (`x_crack.gdshader`); lê como caixa de protótipo.
- Evidência: `c18/after/trial.jpg`.
- Prioridade: **P1**. Esforço: P a M. Responsável: `environment-artist` (`trial_look.gd`).
- Solução: estela de pedra gasta com o selo rachado em relevo (o mesmo desenho do `trial_seal.png`), a rachadura lilás
  só na fenda, mesma caixa de colisão do dado.
- Aceite: colisão igual (`test_trial.gd`); nenhuma face lisa de cubo visível a 1080; a laje e a placa leem iguais.
- Status: FEITO no AP-1, aguarda a revisão do art-director; evidências e números em `docs/gallery/ap1/README.md`. Estela rachada com o selo em relevo, a luz lilás só na fenda, colisão igual.
  Mantive o selo, sem louros.
  no HUD, nas cartas e na laje; louro diz "vitória", não "maldição com prêmio". Mantenho o selo.

**ART-01.5 Marca de recompensa sobre as portas.**
- Problema: a diretriz pede avaliar medalhão em relevo na porta. Hoje o disco paira sobre a boca da porta.
- Prioridade: P2. Esforço: P. Responsável: `art-director` (decide em captura), `environment-artist`.
- Solução proposta (opinião minha): o disco continua no alto da boca, porque é sinal de longe e as portas ficam em
  ângulos variados, mas preso a uma haste de ouro velho no arco (não solto). Relevo na verga só se a captura provar que
  lê a 720.
- Aceite: captura 1080 e 720 de uma sala vencida com três portas, aprovada pelo art-director.
- Status: ABERTO (depois da ART-01.2).

**ART-01.6 Fonte sem evidência.** FEITO no AP-1: capturada (`docs/gallery/ap1/before/fountain_1080.jpg`), era um disco de
luz amarela e um jorro de faíscas brancas; agora bacia de pedra com água, bica e borbotão marfim-azulado (`ArenaKit.fountain`).
Antes: a sala da fonte nunca foi capturada a 1080 em Forward+ (auditoria, "O que não foi
avaliado"). EVIDÊNCIA: `qa-performance` captura `--start=fountain` antes de qualquer tarefa. P1, esforço P.

### ART-02 Paleta, iluminação e hierarquia de leitura (P1)

**ART-02.1 Cenário num tom só e chão com valor.** FEITO no C18 (`c14ea6e`, `91d809f`): tabela em
`docs/gallery/c18/README.md` (luma 55 a 68 em toda luta, p90 até 32 no salão e na câmara, violeta abaixo de 5% fora da
fase 4). A diretriz pede não reduzir saturação global nem clarear tudo: o C18 mexeu por camada (bruma, céu, velas, chão),
não no `WorldEnvironment`; conferido nos números.

**ART-02.2 Guia numérico.** FEITO nesta etapa como primeira versão: `docs/art/art_direction.md`, a revisar pelo
art-director (fecha DT-109 quando revisado).

**ART-02.3 Braseiros com miolo branco-amarelo estourado.**
- Problema: as chamas dos braseiros do salão e da Câmara saem quase brancas e maiores que a cabeça do herói; a regra é
  "nada de clarão branco nem amarelo saturado".
- Evidência: `c18/after/vitrine.jpg` (braseiros do sudeste e do norte), `shop.jpg` (dois no alto), `boss3.jpg`.
- Prioridade: **P1**. Esforço: P. Responsável: `environment-artist`.
- Solução: núcleo da chama em âmbar sob o teto da tela (`ScreenTone`, 226), corpo laranja, altura um terço menor; a luz
  que a chama projeta fica igual.
- Aceite: na caixa de cada braseiro nenhum pixel com os três canais acima de 235; matiz mediano da chama entre 20 e 35
  graus; luma do chão em volta igual (mais ou menos 2).
- Status: FEITO no AP-1, aguarda a revisão do art-director; evidências e números em `docs/gallery/ap1/README.md`. Nenhum pixel acima de 235 nas caixas dos braseiros (antes 112 a 276); matiz
  mediano 16 a 25 (a borda vermelha da bacia puxa para baixo dos 20 em dois deles); a luz igual.

**ART-02.4 Estandartes vermelhos competem com o vermelho do perigo.**
- Problema: o vermelho é reservado ao perigo (e ao golpe sofrido); os estandartes do leão são vermelho saturado em quase
  toda sala, perto do topo da tela.
- Evidência: `c18/after/vitrine.jpg`, `crypt.jpg`, `altar.jpg`, `boss3.jpg`; a prancha usa estandartes petróleo com leão
  de ouro.
- Prioridade: P1. Esforço: P (um material, `banner_lion.gdshader`). Responsável: `environment-artist`.
- Dependência: **Q-22** (cor dos estandartes). O cânone dá cor ao selo real (leão em cera vermelha), não aos estandartes.
- Aceite: vermelho saturado do cenário sem efeitos abaixo de 0,5% da tela no salão, na Cripta e na Câmara.
- Status: BLOQUEADO (Q-22).

**ART-02.5 Janelas da Câmara em retângulos laranja chapados.**
- Problema: 6 a 8 manchas laranja lisas no alto de todo quadro da luta final; leem como textura faltando.
- Evidência: `c18/after/boss3.jpg`, `ritual.jpg`, `storm.jpg`; auditoria (P2).
- Prioridade: **P1** (subo da P2 da auditoria: estão em todo quadro do momento mais visto do jogo). Esforço: P.
- Solução: caixilho em arco com montante, luz em degradê de baixo para cima, metade delas apagadas, matiz âmbar mais frio.
- Responsável: `environment-artist` (`boss_chamber.gd`, `FAR_WINDOW*`).
- Aceite: nenhuma janela de cor única; saturação p90 da faixa de cima da tela (y abaixo de 300 a 1080) abaixo de 35.
- Status: FEITO no AP-1, aguarda a revisão do art-director; evidências e números em `docs/gallery/ap1/README.md`. Lanceta com caixilho, montante e travessa, degradê, metade apagada (a da torre
  também); saturação p90 da faixa de cima 36 para 24.

**ART-02.6 Barras de vida dos inimigos mais vivas que o herói.** ABERTO, P2, `ui-ux-designer` (`life_bar.gdshader`):
barras dos comuns 15% mais escuras e mais finas, elites com moldura. Evidência: `docs/gallery/t5b/runner/runners_gpu_after.jpg`
(ART P2-5). Aceite: num grupo de 6, as barras deixam de ser a mancha mais saturada em volta do herói (`frame_stats --box`).

**ART-02.7 Seis definições de "ouro velho" no código.** `UiKit.OLD_GOLD` 8e7444, `Fx.OLD_GOLD` (0,95; 0,72; 0,3),
`EnemyFx.OLD_GOLD` (1,5; 1,1; 0,5, luz), `CrowdRenderer.GILD_COLOR`, `RewardGem.GOLD`, `Book.GILT`. Dívida P2,
`art-director` com `technical-artist`: a tabela do `art_direction.md` seção 2 diz qual é material, qual é luz e qual é
interface; não unificar os valores às cegas (luz e material não são o mesmo número). Aceite: cada constante com o
comentário apontando a linha da tabela.

**ART-02.8 Compatibility (navegador) satura e salpica o chão.** P2, secundário (memória "desktop primeiro"); ENV P2-4.

### ART-03 Cenários da primeira região (P1)

**ART-03.1 Cripta.** PARCIAL. Feito no C18: luma 37 para 57, capitel com ábaco, preenchimento das paredes do fundo.
Aberto:
- Problema: a sala é uma caixa solta num cinza liso (sem nada além das paredes) e as paredes do KayKit leem como tijolo
  grande de brinquedo.
- Evidência: `c18/after/crypt.jpg`; auditoria `crypt_A_1080.jpg`.
- Prioridade: **P1**. Esforço: M. Responsável: `environment-artist`, `technical-artist` (peças do KayKit que saem).
- Solução: cantaria da `Masonry` nas faces de parede (como já vale para as peças de pedra do KayKit), e o fora da sala em
  escuro com bruma baixa e silhuetas de arcos em duas profundidades (o `ArenaRoom.backdrop` das câmaras de evento).
- Aceite: nenhum cinza liso de fundo na captura 1080 da Cripta A e B; nenhuma peça do `dungeon/` nas paredes; luma de
  luta entre 55 e 70 mantida; iGPU na Baixa sem cair mais de 3 qps (hoje 62).
- Status: ABERTO.
- Não acolho da prancha o círculo gravado no chão da Cripta: a regra das arenas é "círculo fechado no chão é de Morvath"
  (`estetica.md`, arenas do C12) e ele competiria com o Círculo de luz do herói e com os avisos.

**ART-03.2 Santuário.** PARCIAL. Feito no C18: três silhuetas de coluna (capitel, capitel com imposta e anel, quebrada),
B com lábio quebrado. Fica a grade: as colunas são cobertura e planta de jogo (`_sanctuary` no `make_data.gd`); movê-las
muda colisão e ritmo, não é ajuste de arte. Aberto, P2: entulho e tocos só junto às paredes (fora do chão andável) e duas
alturas de coluna quebrada. `environment-artist`. Aceite: `fit_probe` sem fantasma novo; art-director aprova.

**ART-03.3 Jardim.** FEITO no C18 (copa por cartões, cristais escuros com brilho na aresta, Q-21 a). Conferir, P2: na
câmera do jogo a copa fica cortada no alto e o tronco nu domina (`c18/after/garden.jpg`). EVIDÊNCIA: uma captura com a
câmera no herói do lado sul antes de mexer.

**ART-03.4 Runas.** FEITO no C18 (QW-108): âmbar saturado do quadro 3,0% para 1,1% (medido por mim). Conferir, P2: os
pilares aparecem com listras acesas em `c18/after/runes.jpg`; saber se era preparo. EVIDÊNCIA antes de tarefa.

**ART-03.5 Fendas.** FEITO (violeta acima de 60% de 19,1% para 2,5%). Preservar.

**ART-03.6 Ponte dos Condenados.** FEITO (Ponte B pela Q-10 a, parapeito em pontilhado). Preservar, como pede a diretriz.

**ART-03.7 Portal verde do salão.**
- Problema: o único verde do salão é uma chapa de cor pura sem forma; a primeira sala de toda partida.
- Evidência: `c18/after/vitrine.jpg` (verde saturado 1,9% da tela, todo no portal); auditoria.
- Prioridade: **P1**. Esforço: P a M. Responsável: `environment-artist` (`portal.gdshader`).
- Solução: véu com profundidade (centro escuro, borda e veios claros que se movem), verde puxado ao esmeralda corrompido
  escuro com núcleo pálido; continua o ponto focal.
- Aceite: dentro do recorte do portal, desvio padrão da luma pelo menos o dobro do de hoje; maior canal até 226; verde
  saturado do quadro entre 1 e 2%.
- Status: FEITO no AP-1, aguarda a revisão do art-director; evidências e números em `docs/gallery/ap1/README.md`. Desvio da luma no miolo 15,2 para 26,5 (1,7 vez, abaixo do dobro pedido),
  maior canal 255 para 239 (acima de 226 na borda acesa), verde saturado do quadro 2,3 para 2,1%.

**ART-03.8 Salão, estátuas e moldura do portal provisórias.** BLOQUEADO (Q-18, créditos do Meshy). Nenhum crédito será
gasto sem o Daniel.

**ART-03.9 Câmara do Selo.** Preservar a composição. Resíduos: janelas (ART-02.5), entrada de Morvath (ART-05.5).

### ART-04 Altar e Provação (P1)

**ART-04.1 Fundo com bruma e ruínas.** FEITO no C18 (`ArenaRoom.backdrop`): Provação de luma 30 para 43, Altar 55 para
54, violeta 7,2% para 0,5%.

**ART-04.2 Ainda maquete.**
- Problema: plataforma flutuando, corte de parede à mostra à direita da Provação, silhuetas do fundo fracas demais para
  dar chão ao mundo.
- Evidência: `c18/after/trial.jpg`, `altar.jpg`.
- Prioridade: **P1**. Esforço: M. Responsável: `environment-artist` (`trial_look.gd`, `altar_look.gd`, `arena_room.gd`).
- Solução: o chão continua quebrado além da sala para o escuro, a base da plataforma em arcos ou rocha (não em caixa),
  nenhuma face de corte para a câmera; Provação com luz de preenchimento só do chão (o `FLOOR_FILL` da Cripta).
- Aceite: nenhuma face de corte visível a 1080 nas duas; luma da Provação entre 50 e 60; as escolhas (laje, placas, carta)
  iguais (`test_trial.gd`, `test_altar.gd`).
- Status: FEITO no AP-1, aguarda a revisão do art-director; evidências e números em `docs/gallery/ap1/README.md`. Ponta da parede alta em degraus de ruína, chão quebrado sobre rocha além da
  frente baixa, Provação com luz só do chão: luma 43 para 56.

**ART-04.3 Altar novo demais.** P2 (ENV P2-8): pó, quinas gastas, estandartes desbotados. `environment-artist`.

**ART-04.4 Clareza das escolhas.** FEITO (T5 e pacote 1A: VOCÊ ENTREGA, VOCÊ RECEBE, porquês, Seguir em frente). Nada
de regra muda em ajuste de arte.

### ART-05 Morvath: efeitos e legibilidade (P1)

**ART-05.1 Família de verdes separada do herói.** FEITO no C18: domo no matiz 165, erupções sem magenta nem ciano,
partículas até 0,12 m e nunca a menos de 1,5 m do herói; caixa do herói na fase 4 com verde e ciano de 10,5% para 1,9%.

**ART-05.2 Erupções como discos vermelhos cheios.**
- Problema: o C18 trocou o magenta pelo vermelho certo, mas o disco ainda lê cheio e é a coisa mais forte da tela.
- Evidência: `c18/after/boss3.jpg` (dois discos de 4 m, um sob o herói), `ritual.jpg`; vermelho saturado do quadro de
  1,4% para 3,0% (medido por mim).
- Impacto: as erupções entram nas camadas das fases 3 e 4, onde o robô com reação humana mais perde (a maldição e a
  tempestade somam mais da metade do dano que ele leva de Morvath, `CLAUDE.md`, ciclo 9).
- Prioridade: **P1**. Esforço: P. Responsável: `environment-artist` (`ritual_rune.gdshader`), `combat-feel-director`
  aprova.
- Solução: o preenchimento das erupções no mesmo regime dos avisos comuns (fraco até os últimos 30% do aviso, teto 0,35),
  aro e runas carregam a forma. Raio, tempo e dano iguais.
- Aceite: vermelho saturado do quadro `boss3` abaixo de 1,5% fora dos últimos 30% do aviso; aviso enche no quadro do
  dano (sonda e `enemy_motion_probe`, 0 a 1 quadro); combat-feel-director assina.
- Riscos: aviso fraco cedo demais; por isso só o preenchimento muda, nunca o aro.
- Status: ABERTO.

**ART-05.3 Herói some atrás de Morvath.** O raio-x vale atrás da multidão e da pedra, não atrás do chefe (auditoria,
`06_fase2_runas_de_invocacao_1080.jpg`). **P1** (subo da P2: Morvath tem 1,4 m de raio e a luta é de perto). Esforço P a
M. `environment-artist` (`crowd.gdshader` marca o stencil também no chefe; conflito de arquivo com o gameplay a combinar).
Aceite: captura com o herói atrás de Morvath mostra o corpo iluminado e o fio marfim; testes do raio-x verdes.

**ART-05.4 Preenchimento da foice cobre o herói.** P2. `hero_hole` como na onda do especial. `environment-artist`.

**ART-05.5 Entrada de Morvath sem momento.** P2. 1,5 s dele se erguendo do selo com o anel espectral, nome da sala com
véu. Muda o tempo antes do primeiro ataque: `gameplay-engineer` confere que nada da luta muda; `combat-feel-director`
aprova.

**ART-05.6 Fase 4 com 7,6% de violeta.** Aceito como exceção (opinião minha): são as meias-luas, que precisam ser lidas, e
os veios da fase final. Sem tarefa; o art-director confirma na revisão.

**ART-05.7 Sincronia corpo, aviso e golpe.** Feito no T5 para os golpes; herdados abertos T5-17 a T5-19 (preparo da
maldição e das erupções). Ficam no backlog principal (combate, `combat-feel-director`), referenciados aqui.

**ART-05.8 Domo (matiz 165) a 18 graus do anel do herói (183).** P2. Conferir na captura do ritual se o valor separa os
dois; se não, o anel ganha valor, nunca o domo saturação.

### ART-06 Medalhões e ícones (P1)

**ART-06.1 Regra da coleção.** FEITO no guia (`art_direction.md` seção 7): tudo o que se coleciona (Bênção, Elo, Salmo,
recompensa no mundo) tem medalhão pintado no mesmo aro; vetor só para ações, marcas pequenas do HUD e das placas.

**ART-06.2 Medalhões pintados que faltam.**
- Problema: 7 de 26 Bênçãos pintadas; os 6 Elos e os 4 Salmos em vetor; a mesma tela mistura os dois.
- Evidência: `audit/6_identidade/medalhoes_tres_familias_1080.jpg`, `2_menus/bencao_cartas_1080.jpg`; `assets/ui/boons/`
  com 7 PNG.
- Prioridade: **P1**. Esforço: G (arte) mais P (recorte e encaixe). Responsável: `art-director` (prancha e lista por
  efeito), `technical-artist` (recorte por `tools/cut_medallions.gd`, importação), `ui-ux-designer` (encaixe).
- Dependência: **Q-24** (de onde vem a pintura). Prioridade dentro do lote: as Bênçãos mais oferecidas primeiro
  (`qa-performance` conta as ofertas em 72 sementes).
- Aceite: as 10 Bênçãos mais vistas, os 6 Elos e os 4 Salmos pintados; nenhuma cruz nem sol; IA declarada no
  `docs/steam-ia.md`.
- Status: BLOQUEADO (Q-24).

**ART-06.3 Glifos pequenos com leitura de cruz** (Corte do Juízo no losango, escudo da Vigília). P2, QW-117 do backlog
principal. `art-director`, `ui-ux-designer`.

**ART-06.4 Marcas do HUD e das placas.** Manter em vetor (`ActionSlot.mark`, `DoorGlyph`): leem bem e são a outra metade
da regra. Sem tarefa.

### ART-07 Livro de Ahk (P1)

**ART-07.1 Árvore de Dons num painel de tela.**
- Problema: a árvore fica num retângulo escuro dentro do pergaminho; cadeados e números dominam os nós trancados.
- Evidência: `audit/1_titulo_livro/05_livro_dons_furia_plena_1080.jpg`.
- Prioridade: **P1**. Esforço: M. Responsável: `ui-ux-designer` (`talent_tree.gd`, `book_spread.gd`), `art-director`.
- Solução: a árvore desenhada no próprio papel (tinta e ouro gravado) ou numa lousa de couro com cantos de metal; trancado
  com o motivo apagado e o nível pequeno; motivos da prancha 09 conferidos contra o efeito real de cada Dom.
- Aceite: captura 1080 e 720 aprovada pelo art-director; todo nó legível a 720; `tests/test_book.gd` verde.
- Status: ABERTO.

**ART-07.2 Abas e botões fora do material do livro.** P2. Abas como fitas marcadoras de couro saindo da borda; ações em
ouro gravado. A prancha põe as abas de lado: aceito a forma, sem criar capítulo novo (o conteúdo é da Q-05).
`ui-ux-designer`.

**ART-07.3 Abertura sem imagem.**
- Problema: a página esquerda da Abertura é só o título e a epígrafe (`c17/ui/after_book_1080_opening.jpg`).
- Prioridade: P1. Esforço: M. Responsável: `art-director` (spec), `ui-ux-designer`.
- Solução até o Daniel decidir: vinheta em tinta sépia de objetos (papiros, pena, tinteiro, o leão do selo), sem figura,
  e capitular ornada na epígrafe. A cena de Ahk escrevendo só depois da Q-23.
- Status: PARCIAL possível agora (vinheta); a cena fica BLOQUEADA (Q-03, Q-23).
- Recuso da prancha: o texto "Emeth despertou em um tempo de ruptura..." (lore inventada; a Emeth é a espada, não um
  personagem) e a cena com um velho de barba branca e um jovem ouvinte (ver Q-23).

**ART-07.4 Compêndio só texto.** P1. Página de cada inimigo com o desenho dele em traço tirado do nosso modelo assado
(sem IA), desconhecido como silhueta apagada, "???" juntados em "N por descobrir". `technical-artist` (render em traço),
`ui-ux-designer`. Aceite: as 9 figuras e as elites com desenho; legível a 720.

**ART-07.5 Retrato do Guerreiro com a Emeth errada.** P2, Q-04 (lâmina curta e reta, sem guarda de chifres nem punho
vermelho). Sem tarefa até haver arte.

### ART-08 Tela inicial (P1, decisão pendente)

**ART-08.1 Cruzes e a maga antiga.** BLOQUEADO (Q-07): clérigo com cruz e cruzes no peito, estandarte da fortaleza com
cruz, maga de roxo em vez da "Maga de Fogo com Cometa" aprovada (`referencias-aprovadas/maga-de-fogo-e-cometa.png`).
Evidência: `audit/1_titulo_livro/01_titulo_1080.jpg`. Não decido sozinho. Aceite depois da decisão:
`tools/title_flow_check.gd` passa, logotipo e botões nas mesmas áreas, IA no `steam-ia.md`.

**ART-08.2 Botão Iniciar em ouro saturado.** P2. Puxar para o `UiKit.OLD_GOLD` com brilho só na borda em foco.
`ui-ux-designer`.

**ART-08.3 A cruz aparece atrás das Configurações e do Como Jogar.** P2. Fundo mais escuro e desfocado até a ART-08.1.

### ART-09 Guerreiro, Emeth e inimigos (P1 e P2 pela evidência)

**ART-09.1 Elites em luta.** EVIDÊNCIA: só há capturas de laboratório, onde a elite quase não se distingue
(`audit/3_gameplay/22_`, `23a_`). `qa-performance` captura `--stress=6 --stress-ids=skeleton_elite,mage_elite,guard_elite`
a 1080 na GPU; o art-director decide. Nenhuma tarefa antes.

**ART-09.2 Acento de cor por papel nos inimigos.** QUESTIONADO, P2: seis dos nove são osso e pano vermelho, mas a regra
da multidão é "apagada para não brigar com os efeitos" e a silhueta já separa os papéis
(`audit/3_gameplay/21a_inimigos_todos_camera_do_jogo_1080.jpg`). Só entra se a ART-09.1 ou o teste do PO mostrarem
confusão de papel.

**ART-09.3 Feiticeiro de cajado rígido.** P2, QW-116 do backlog principal (cajado 15 graus para trás junto ao ombro,
`lift` 0,3; reassar Morvath).

**ART-09.4 Armas do KayKit e foice de Morvath.** BLOQUEADO (Q-18). Sem créditos.

**ART-09.5 Corredor.** FEITO (`40d6618`), aprovado pelo art-director. A diretriz lembrou: nenhuma tarefa nova.

**ART-09.6 Onda do especial maior no desenho.** FEITO no C18 (QW-111, `look_scale` 1,25, acerto igual). Falta a medida
do `combat-feel-director`.

**ART-09.7 Corpo que clareia no preparo e mira em fio.** FEITO no C17 (QW-104 `5a0dde9`, QW-107 `af5be1c`). Falta a
aprovação do art-director (QW-104) e do combat-feel-director (QW-107).

**ART-09.8 Silhueta do Guerreiro e tamanho da Emeth.** Sem evidência de problema: a auditoria dá "Manter" aos dois
(`01_luta_salao_1080.jpg`, `11_giro_finalizador_1080.jpg`). Não abro tarefa (a diretriz proíbe refazer o aprovado por
preferência).

### ART-10 Menus e HUD (P2)

**ART-10.1 Pausa, saudações, números e abas.** FEITO no C17 (`6eb21c0`, merge `f83ccff`): fileira do HUD some na pausa,
saudações esperam as telas, "+N", números inteiros (BUG-105, BUG-107, BUG-113), LB e RB nas abas, Juramentos e Músicas
no painel (QW-113). Evidência: `docs/gallery/c17/ui/after_*`.

**ART-10.2 Vitória.** **P1** (é o fecho emocional): halo do selo em degradê radial (sem o disco amarelo-oliva), legenda da
selagem em Alegreya Sans com véu, o leão com brilho de ouro velho que cresce em 0,6 s; ouro sobe ao lado dos números.
QW-115 do backlog principal. `ui-ux-designer`. Aceite: capturas 1080 e 720 aprovadas pelo art-director.

**ART-10.3 Cartas com metade vazia.** P2 (ART P2-1). Texto curto centrado na vertical ou carta que encolhe.

**ART-10.4 Topo do HUD.** P2: véu de 60 px atrás do topo; regra Cinzel a partir de 24 px a 1080, abaixo Alegreya Sans
Bold (`art_direction.md` seção 8).

**ART-10.5 Barras de vida e Magia do herói 15% menos saturadas.** RECUSADO (opinião minha): são a leitura mais importante
do HUD e ficam longe da ação; o problema medido é o das barras dos inimigos (ART-02.6).

### Resolvido ou recusado, em uma linha

| Item | Status | Prova ou motivo |
|---|---|---|
| Primitivos sem luz (ART-01.1) | FEITO | `c14ea6e`, `c18/after/shop.jpg` |
| Paleta e chão (ART-02.1) | FEITO | `c18/README.md` |
| Runas no tom dos avisos (ART-03.4) | FEITO | âmbar 3,0% para 1,1% |
| Fendas, Ponte B, Santuário B (ART-03.5, 03.6, 03.2) | FEITO | `c18/README.md`, `fit_probe` |
| Copa e cristais do Jardim (ART-03.3) | FEITO | `c18/after/garden.jpg` |
| Fundo das câmaras de evento (ART-04.1) | FEITO | luma da Provação 30 para 43 |
| Verdes de Morvath (ART-05.1) | FEITO | caixa do herói 10,5% para 1,9% |
| Mira em fio, corpo que clareia (ART-09.7) | FEITO, falta aprovação | `docs/gallery/c17/qw10*` |
| Menus e HUD do C17 (ART-10.1) | FEITO | `docs/gallery/c17/ui/` |
| "Troque seus Selos" na loja (prancha) | RECUSADO | no cânone os Selos são as fechaduras do Abismo; a moeda é ouro (D-41 segue aberta para nomes de Eterra) |
| Lore do Livro na prancha | RECUSADO | inventada; a Emeth é a espada |
| Livro como marca da Bênção (prancha) | RECUSADO | o livro é o Livro de Ahk e o Compêndio; a Bênção tem o aro com losango em todo o jogo |
| Louros violeta na Provação (prancha) | RECUSADO | o selo rachado já é o símbolo do evento |
| Círculo gravado no chão da Cripta (prancha) | RECUSADO | círculo no chão é de Morvath e do Círculo de luz |
| Barras do herói menos saturadas (auditoria) | RECUSADO | ART-10.5 |
| Mover colunas do Santuário | RECUSADO como arte | é planta de jogo |
| Halos fortes dos relicários da prancha | RECUSADO | halo abaixo do glow (maior canal até 1,0 no material, 226 na tela) |

---

## C. Roadmap

Ciclos de arte em série, um por vez, cada um com exe para o Daniel. Eles podem correr ao lado de um ciclo de gameplay
(C19) porque mexem em outros arquivos; dois ciclos de arte juntos, nunca. Estimativas em dias de trabalho dos agentes.

| Ciclo | Objetivo | Itens | Estimativa | Entregáveis | Aceite (resumo) | Depende de |
|---|---|---|---|---|---|---|
| **AP-1 Nada de protótipo** | nenhuma peça chapada à vista e toda recompensa lida sem placa | ART-01.2, 01.3, 01.4, 01.6, 04.2, 03.7, 02.3, 02.5 | 3 a 4 | relicários, estela da Provação, câmaras de evento assentadas, portal, braseiros, janelas | ver seção E | nada (Q-13 e Q-22 só mudam detalhes) |
| **AP-2 Combate que se lê** | o vermelho volta a ser exceção e o herói aparece em qualquer lugar da luta | ART-05.2, 05.3, 05.4, 05.5, 05.8, 02.6, 09.1, 09.3, aprovações de 09.6 e 09.7 | 3 | erupções no regime dos avisos, raio-x atrás de Morvath, barras dos inimigos, elites medidas | vermelho saturado abaixo de 1,5% no quadro da fase 3; herói achado atrás de Morvath; sonda 40/40 | o teste T6 do PO (pela leitura de gente) |
| **AP-3 Masmorras com alma** | nenhuma sala solta no vazio e o KayKit fora das paredes | ART-03.1, 03.2, 03.3, 03.4, 04.3, 02.4, 02.8 | 3 a 4 | Cripta com cantaria e fundo, Santuário e Altar gastos, estandartes, Compatibility | nenhum fundo liso nas 7 arenas e 2 câmaras; luma 55 a 70; iGPU Baixa a no máximo 3 qps de hoje | Q-22 (estandartes) |
| **AP-4 Livro, coleção e título** | a coleção parece uma coleção e o Livro parece um livro | ART-06.2, 06.3, 07.1 a 07.5, 08.1 a 08.3, 10.2 a 10.4, 01.5 | 4 a 5 (mais a pintura) | árvore no papel, Compêndio ilustrado, medalhões, vitória, título | cada tela aprovada a 720 e 1080; nenhuma cruz se Q-07 (a) | Q-03, Q-04, Q-05, Q-07, Q-23, Q-24 |

O AP-4 absorve a parte de arte do C20 do backlog principal; o C20 fica com o técnico (pausa ao perder o foco, menus por
controle, licenças, arquivos grandes).

Referência cruzada (2026-11-18): o AP-4 recebe também o MAP-06 do `docs/backlog.md` (arte completa da página do mapa da
Descida de Valmor no Livro de Ahk); a página funcional do mapa (MAP-03) entra antes, no ciclo DV-1.

---

## D. Decisões do PO

Só as que precisam do Daniel. As que já estavam no `docs/backlog.md` são citadas pelo número de lá.

| ID | Pergunta | Opções | Recomendação |
|---|---|---|---|
| **Q-07** (existente) | Cruzes do título viram leão ou espada? Entra a maga aprovada da prancha 08? | (a) leão e espada, maga nova (arte de IA nova, declarada); (b) a cruz fica só no título; (c) espera o elenco | (a): o jogo inteiro já trocou cruz por leão e espada |
| **Q-03** (existente) e **Q-23** (nova) | Como Ahk aparece no Livro? O cânone diz que ele foi sacerdote de Sindarin (reino de população negra e parda), lutou ao lado de Elun e morreu antes da compilação do Livro Sagrado de Yah. A prancha mostra um velho de barba branca ensinando um jovem que escreve: aparência, o jovem e o encontro não estão no cânone | (a) Ahk só pela voz (epígrafes) e por objetos (papiros, pena, leão), sem rosto; (b) Ahk desenhado como o Daniel definir, sozinho, escrevendo; (c) a cena da prancha (pede o Daniel criar o ouvinte e dizer quando acontece) | (a) agora; (b) se o Daniel quiser o rosto e disser como ele é |
| **Q-04** (existente) | O retrato do Guerreiro no Livro fica, com a Emeth curta e reta? | (a) fica; (b) imagem nova com a Emeth certa | (b) quando houver arte; até lá (a) |
| **Q-05** (existente) | A Abertura repete o Como Jogar | (a) Abertura narrativa a partir do cânone; (b) como está | (a), eu proponho o texto e você aprova |
| **Q-13** (existente) | Botão de usar para loja e recompensa? | (a) botão; (b) pisar | (a); para a arte, o relicário pode ser mais alto e o jogador fica diante dele, como na prancha |
| **Q-18** (existente) | Créditos do Meshy para estátuas, armas e foice | autorizar o lote ou segurar | segurar até depois do AP-3; nenhum item do AP-1 a AP-3 precisa |
| **Q-22** (nova) | Cor dos estandartes do leão: hoje vermelho saturado, o mesmo do perigo; a prancha usa petróleo com leão de ouro | (a) petróleo escuro com leão de ouro velho; (b) vermelho mais escuro e apagado (vinho); (c) como está | (a): libera o vermelho para o perigo e casa com o cachecol do herói e com a prancha. O cânone dá o vermelho ao selo real em cera, não ao estandarte |
| **Q-24** (nova) | De onde vêm os medalhões pintados que faltam (19 Bênçãos, 6 Elos, 4 Salmos)? | (a) prancha nova do PO por IA, no estilo das 7 de hoje, recortada por nós; (b) IA gerada por nós com prompt aprovado (declarada); (c) pintura nossa sem IA, mais lenta | (a): mantém o estilo das 7 aprovadas e a declaração de IA é uma linha |

---

## E. Proposta do primeiro ciclo: AP-1 "Nada de protótipo"

**Objetivo em uma frase**: nenhuma peça que pareça provisória à vista numa descida, e cada recompensa lida pela forma e
pela cor antes da placa.

**Por que primeiro**: é o único P0 da diretriz, está em toda sala vencida, não depende de nenhuma resposta do Daniel
(Q-13 e Q-22 mudam só o pano e a altura do relicário) e não toca no combate, que espera o teste T6 do PO.

**Escopo fechado** (nada além disto):
1. ART-01.2 esmalte por família, marca maior, disco maior na tela.
2. ART-01.3 relicário com degrau de pisar à frente (pano neutro em pedra até a Q-22).
3. ART-01.4 estela rachada no lugar do cubo da Provação.
4. ART-01.6 captura da Fonte (só evidência; se ela tiver primitivo, entra no item 1).
5. ART-04.2 Provação e Altar assentados: chão quebrado além da sala, base em arcos ou rocha, sem corte de parede.
6. ART-03.7 portal do salão com profundidade.
7. ART-02.3 braseiros sem miolo branco.
8. ART-02.5 janelas da Câmara com caixilho e degradê.

**Agentes**:
- `art-director`: spec curta antes de começar (cores dos esmaltes na tabela do `art_direction.md`, desenho do relicário e
  da estela em vista da câmera), revisão no fim, revisa e assina o `art_direction.md`.
- `environment-artist`: itens 1 a 3 e 5 a 8 (`reward_gem.gd`, `reward_gem.gdshader`, `trial_look.gd`, `altar_look.gd`,
  `arena_room.gd`, `catacomb_hall.gd`, `portal.gdshader`, `boss_chamber.gd`, `masonry.gd` se preciso).
- `gameplay-engineer`: revisa que zona de compra, colisão e cobertura não mudaram (`test_economy.gd`, `test_trial.gd`,
  `test_altar.gd`, `fit_probe`); não mexe em regra.
- `technical-artist`: orçamento (triângulos e materiais do relicário, um material por tipo), nada de textura nova sem
  importação comprimida.
- `qa-performance`: capturas antes e depois, iGPU, testes, relatório.
- Sem `ui-ux-designer` neste ciclo (o mapa de medalhões já existe), salvo se o art-director pedir troca de marca.

**Plano de evidências** (pasta `docs/gallery/ap1/`, `before/` e `after/`, mesmo comando e semente):
- Na GPU (`tools/gpu.sh shot`), 1920 x 1080 e 1280 x 720 com HUD: `--start=shop`, `--start=altar`, `--start=trial`,
  `--start=fountain`, sala vencida da Cripta (`--arena=crypt --bot --autopick`), `--showcase` (portal e braseiros),
  `--start=boss` aos 5 s (janelas).
- Recortes 720 de cada recompensa sem placa para o teste de reconhecimento (art-director e QA; vai como pergunta ao PO).
- Vídeo de 6 s do relicário balançando (o movimento é temporal) e da laje da Provação aparecendo.
- `python3 -I tools/frame_stats.py` antes e depois de todas, mais a caixa do portal e dos braseiros.
- iGPU na Baixa a 1280 x 720 no salão, loja e Provação (`docs/qa/` como no C18).
- `tools/test.sh` inteiro, `tools/check.gd`, `tools/title_flow_check.gd`, sonda 40/40 (só para provar que nada do combate
  mudou).
- Revisão do art-director em `docs/gallery/ap1/ART_REVIEW.md`. Nenhuma imagem conceitual como captura.

**Riscos**:
- Relicário que bloqueia ou vira fantasma no `fit_probe`: o corpo dele fica atrás da zona de pisar, abaixo de 1,0 m.
- Esmaltes coloridos voltando a saturar o cenário: o teto da tabela vale (saturação do esmalte até 0,5, valor até 0,45).
- Desempenho: até 5 relicários na loja; um material por tipo, sem luz própria (como o `RewardGem` hoje).
- Retrabalho se a Q-13 vier (a): o relicário pode subir; por isso a altura fica num número só.
- Fila da GPU entre agentes (DT-110): o QA reserva a janela de captura.

**Critério de conclusão**:
- Nenhuma `BoxMesh`, `PrismMesh` ou `SphereMesh` visível sem acabamento em loja, altar, Provação, Fonte e sala vencida;
  nenhuma face lisa de cubo no bloco da Provação.
- 6 de 6 recompensas identificadas sem placa a 720 pelo art-director e pelo QA; quaisquer dois esmaltes a 40 graus de
  matiz ou 0,2 de valor.
- Provação com luma entre 50 e 60 e nenhum corte de parede visível nas duas câmaras.
- Portal: desvio padrão da luma no recorte pelo menos o dobro do de hoje; braseiros sem pixel acima de 235 nos três
  canais; janelas sem cor única.
- Luma de luta e saturação do C18 mantidas (55 a 70; p90 até 32 no salão e na câmara).
- iGPU Baixa a no máximo 3 qps abaixo da tabela do C18; testes e sonda verdes.
- Revisão do art-director aprovada; o exe vai para as duas pastas junto com o próximo lote, sem pedir teste isolado.

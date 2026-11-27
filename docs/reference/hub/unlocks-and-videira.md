> Índice: [hub.md](../hub.md)

## HV-C, pintura do Santuário da Vigília (`docs/art/hv_santuario_vigilia_art.md`; capturas em `docs/gallery/hub/hv_c/`)
- No `HubLook`: toldo do Vendedor em duas águas, a de trás mais longa (`AWNING_RIDGE`), listras terra e vinho apagado
  (`AWNING_STRIPE`); Pátio do Retorno com anel de lajes gastas em volta do selo, falhas escuras no leão
  (`SEAL_PAVING`, `SEAL_FAULTS`), caminho de lajes até o medalhão, braseiros menores (`RETURN_FIRE` 0,65) e um lampião
  âmbar baixo sem sombra na mureta leste da escada (`RETURN_LAMP`); placas baixas dos Dons em volta do estrado da Árvore,
  apagadas (`_gift_plaques`, `PLAQUE_*`, para o HV-E acender); Alquimista com estante e frascos, bancada com pano,
  pilão e balança de ferro, telheiro de tábuas sobre dois postes (sempre acima de 2,6 m sobre o chão, `ALCH_ROOF`),
  ervas penduradas e um lampião âmbar baixo sem sombra (`ALCH_LAMP`). Colisão e `HubPlan` iguais.

## HV-E, o Santuário que cresce com o save (gameplay; `docs/backlog.md` HV-E; testes em `tests/test_hub_evolution.gd`)
- `HubEvolution` (`core/hub_evolution.gd`, puro, só lê o save) dá o `State` do hub em cinco estados, cada um atrás de uma
  bandeira (`FLAGS`; peça sem a mecânica fica escondida): **E1 Forja** `forge_rank` (o Temperar, 0 a 3) e
  `forge_tools` (cada ferramenta só depois de usada: o Refinar, o Despertar ou o Inscrever comprado; a Picareta
  restaurada); **E2 Vendedor** `vendor` (`Stall.CLOSED` até a primeira Pedra Funda, `ORDER` "Tem um pedido", `OPEN`
  entregue) e `obras`; **E3 Árvore** `tree_lit` de `tree_total` 18 placas (um por Dom pago com Memória e aberto; a
  Maestria só em `mastery`, nunca acende placa); **E4 Livro** `book_spines` (uma lombada por capítulo do Compêndio com
  80% achado, `BOOK_SHARE`; Morvath só selado; `Hub.codex_chapters` conta como o Compêndio) e a prateleira de Ofícios
  (`shelf`, `shelf_items` = ferramentas e Obras dos Ofícios); **E5 Alquimista** sempre a bancada vazia (bandeira
  desligada até o Roteiro C). E2 e E4 ligados (o Lote C existe). Nada acende na primeira morte (`State.grown()`):
  tudo sobe só por algo comprado, aberto, entregue ou selado.
- O `Hub.evolve()` aplica ao chegar, depois de forjar, de um Ofício e ao fechar qualquer tela (`HubEvolution.apply`):
  `HubLook.set_forge_rank(n)` (existe) e, **para o environment-artist implementar no `HubLook`** (chamadas só se
  existirem): `set_forge_tools(Array[StringName])`, `set_vendor(estado: int, obras: int)` (0 escondido nunca chega,
  1 fechado, 2 pedido, 3 aberto), `set_tree_plates(acesas, total, nível da Maestria)`, `set_book(lombadas, prateleira,
  itens)`, `set_alchemist(abastecido)`.

## Santuário que abre aos poucos (2026-11-21, `HubGate`, `scripts/core/hub_gate.gd`)
- Gate puro lido do save, um por estação: Portal sempre; Livro e Árvore de Dons com `runs >= 1` (ou um Dom aberto);
  Forja ao vencer o 1º guardião (`firsts.guardian`) ou com Prata para o Temperar I (custo vem do dado, `temper_cost()`);
  Vendedor com `runs >= 3` ou a 1ª Pedra Funda; Juramentos seguem na 1ª vitória; Alquimista desligado. Quem já usou a
  estação (Temperar comprado, ferramenta, pedido, Obra, Dom aberto) a tem aberta. Constantes no topo da classe.
- Estação fechada: `Hub.is_open(id)` falso tira do foco (sem placa nem uso) e do nome flutuante (`HubLabels`); o visual
  apaga a luz e a brasa (`HubLook.set_closed`); o Vendedor já tem o pano (`HubEvolution`). Pendente para o
  environment-artist: uma boca fria da forja e raízes nuas da árvore (hoje só a luz some).
- Apresentação: ao voltar com estação nova aberta, uma linha por estação (`hub_open_*` em `text_pt.tres`) sobre o nome
  do lugar (`HubLabels.announce`, 4 s cada); gravada em `hub.presented` do save (versão 9, uma vez só). Save antigo
  (< 9) conta as abertas como já apresentadas (migração em `SaveData.merged`).
- `--hub-open=all` abre tudo e não apresenta nada (capturas, robô); `tests/hooks/pre_run.gd` o liga para toda a suíte,
  `tests/test_hub_gate.gd` o desliga. `tools/first_tour.gd` pula estação fechada.

## Guia de destrave (PT-5, 2026-11-23, `HubGuide`, `HubGuideOverlay`; testes em `tests/test_pt5_unlock_guide.gd`)
- Pedido do Daniel: toda coisa nova que abre no Santuário é explicada na primeira vez. Ao entrar com algo recém-destravado, depois
  do olhar de chegada, a câmera aproxima suave (`GUIDE_ZOOM` 0,62 da distância, `CamRig.wide`/`lean` sobre o ponto `SHOW` da
  estação), um anel e uma seta apontam o lugar e uma placa diz a frase com a tecla real de `interact` (`{key}`: teclado, controle,
  remapeada). Um guia por vez, em fila; qualquer tecla, botão ou clique avança (meio segundo de carência); depois do último a câmera
  volta ao herói. O herói fica parado enquanto isso.
- A lista é dado: `data/hub_guide/NN_id.tres` (`HubGuideDef`: id, ordem, estação, `text_key`, condição), gerada por `_hub_guide` em
  `tools/make_data.gd`. Guia novo = uma linha lá e um texto `guide_*`. Condições (`HubGuide.CONDITIONS`): `open` (porta da
  `HubGate` aberta), `always`, `wins` (Morvath selado: Juramentos), `account` (A Videira aberta, V2), `maga` (a Maga liberada, PT-9). Hoje: portal, tree (Dons), book (Livro e Compêndio), forge, vendor,
  account (estação da Videira), maga (Estandarte dos Heróis), sworn.
- Uma vez por save: `hub.guided` (versão 11 do save); save antigo conta o que já está devido como visto (`SaveData.merged`). Gravado
  ao começar o guia. A linha `hub_open_*` de uma estação que tem guia na visita não aparece duas vezes.
- Nada com `--bot`, `--smoke`, `--nosave`, `--hero-at` ou `--hub-open=all` (a suíte). Para ver: `--hub --guide=<id>` (`portal`, `tree`,
  `book`, `forge`, `vendor`, `account`, `maga`, `sworn`; `--guide=all` encadeia todos); forçado não grava. Ex.:
  `tools/gpu.sh shot saida.png --hub --guide=tree --shot-at=5`.
- Pendente: Encantos, anjos, Videira e a escolha de herói como destrave próprio (hoje a escolha de herói está sempre aberta e vai na
  frase do Portal); entram como linhas novas no `_hub_guide` quando tiverem estação e condição.
## PT-4, caminhos sem notação (2026-11-23)
- O fio de ouro no meio de cada caminho (`WAY_FILET`) saiu: lia como linha de interface. Agora `_pave_way` põe as lajes do
  terço do meio mais claras (`WORN_TINT`, material `_worn_stone`) e 6 mm mais altas (`WORN_RISE`, `WORN_SHARE` é a largura
  do miolo gasto); o meio-fio escuro e a junta escura enquadram a trilha. Sem shader nem material novo além de uma pedra
  mais clara; colisão e `HubPlan` iguais. Os losangos riscados nas lajes de uso das estações também saíram (`USE_SLAB`); os anéis do medalhão ficam. Captura de CPU: `docs/gallery/hub/pt4/hub_way_cpu.png`; ver com `tools/gpu.sh shot x.png --hub --look=stylized --cam=near`.

## A Videira e o Estandarte dos Heróis (V2 e PT-9, 2026-11-23; testes em `tests/test_videira_v2.gd` e `tests/test_hero_station.gd`)
- **Duas estações novas** em `HubPlan.STATIONS` (`VINE`, `HEROES`; `CORE` são as cinco antigas, que mantêm a regra de no máximo 4 s a pé,
  as novas ficam em `EXTRA_WALK` 6,5 s). **Videira**: arco de pedra no lobo leste (peça `hub_vine`, centro (19,0; 10,0), uso (19,0; 8,2)),
  aberta pela mesma condição do antigo Preparo (`Vine.open`, `HubGate`). **Estandarte dos Heróis**: no lobo oeste ao lado do balcão do
  Vendedor (peça `hub_heroes`, centro (-17,5; 9,5), uso (-17,5; 7,4)), abre junto do Vendedor (3ª volta ou Pedra Funda) ou com a 1ª vitória.
  Placa, âncora, `SHOW`, anel de foco e luz de poça (`STY_POOLS`) como as outras; textos `hub_vine*`, `hub_heroes*`, `hub_open_*`. O canteiro leste
  encolheu e foi para (22,4; 1,6) para o caminho da chegada à Videira não cortá-lo.
- **Peça provisória, nó de `HubLook`**: `VineStation` (`scripts/game/vine_station.gd`, nó "VineStation" no quadro do hub, vaso e 3 hastes
  de 3 estágios) com **`grown(branches_bought)`**: dicionário ramo para nós comprados (0 a 3), `Vine.growth(save)` o monta;
  `HubLook.grow_vine` o repassa em `Hub.evolve` (a cada compra). A V3 troca os meshes sem mexer em quem chama. `HeroStation` (dois
  estandartes, o da Maga cinza travada) idem, `HubLook.show_heroes(save)`.
- **V3 (2026-11-23, `tests/test_videira_v3.gd`)**: `VineStation` virou videira procedural: tronco retorcido do vaso (sempre, com um broto) e três ramos
  (Vida a oeste, Provisão ao centro, Perseverança a leste) de 3 estágios cada (`PATHS`, Catmull-Rom; tubo e folhas esferoides achatadas fundidos em uma malha
  por estágio; estágio 3 com cachos e flores âmbar emissivos); musgo escuro (`LEAF_A/B`). Mesma `grown()`; depois da primeira chamada, cada estágio que aparece cresce de escala 0,15 a 1 em 1,1 s (`_swell`, `GROW_FROM`, `GROW_TIME`) ao voltar da tela de compra. `HeroStation`: estandartes de pano em travessa de ferro
  (`BAR_Y`), Guerreiro vermelho com leão dourado, Maga âmbar com estrela de 8 pontas; Maga travada = pano cinza enrolado (`rolls`, `ROLLED`) sem emblema, abre
  com `hero_open`; pé com suporte de espada e de cajado. A estante do Livro (`SHELF`, `SHOW`) foi para (15,1; -3,1) para não cobrir a Videira na câmera Perto.
  Ver: `tools/gpu.sh shot x.png --hub --look=stylized --cam=near --vine=9` (e `--vine=0`).
- **O Portal só desce** (Descer, Ficar; a frase do herói escolhido continua). A troca de herói é `HeroPickScreen` (folha pequena do Livro, um
  cartão por herói). `SaveData.hero_open(data, id)`: **a Maga só com `wins > 0`**; `picked_hero` devolve o Guerreiro se a Maga escolhida
  estiver travada; `next_hero` anda só pelos abertos. Guia `maga` (condição `maga`) quando ela abre.
- O Forjador volta a abrir só a Forja (`Hub._use_smith`); `VineSheet` e as chaves `vine_smith_*` saíram.
- Ver (só a sessão principal): `tools/gpu.sh shot x.png --hub --hub-open=all --hero-at=vine --look=stylized --cam=near` e `--hero-at=heroes`;
  telas: `--hub --hub-open=all --hub-use=vine` e `--hub-use=heroes`; guias: `--hub --guide=account` e `--guide=maga`.

## Marcos do Santuário (SW-O5, 2026-11-25, `Milestones`, `MilestoneDef`; spec em `docs/design/onboarding_sw_o.md`)
- Quando cada estação abre é **dado**: `MilestoneDef` (`id`, `order`, `opens`, `runs_min`, `needs`, `any_of`), em `data/milestones/NN_id.tres`
  (parte `milestones` do `make_data.gd`, do 3A1); sem a pasta, `Milestones.defaults()` traz a mesma tabela. `needs`: `first` (descida-tutorial
  feita ou pulada, ou `runs > 0`), `guardian` (`firsts.guardian` ou `firsts.guardian_run`; a tutorial não grava nenhum), `win`, `stone`
  (primeira Pedra Funda, pedido ou receita: o mesmo teste do uso do Vendedor), `mastery2`.
- Tabela (D-O1 a): 0 `tree` Árvore (`first`); 1 `forge` Forja (3 descidas **ou** guardião); 2 `book` Livro e Compêndio (3); 3 `account` Videira (4);
  4 `vendor` Vendedor (5 **ou** Pedra Funda); 5 `ult` Ultimate (6 descidas **e** Maestria 2; abre como `ult`, não é estação); 6 `maga`
  Estandarte dos Heróis (primeira vitória; os Juramentos seguem `Juramentos.unlocked`).
- **Uma coisa nova por visita**: `HubGate.begin_visit` (chamado no `Hub._ready`) fixa `Milestones.next_to_present` (o marco mais baixo
  alcançado e ainda não apresentado); `is_open` só abre essa e o que já foi apresentado (`hub.presented`) ou usado (`HubGate.used`: Dom aberto,
  Forja/Temperar, Ofícios, nó da Videira). Os outros esperam a próxima volta. `end_visit` no `_exit_tree`. Fora do Hub (testes, `SaveData`) a
  pergunta usa o próximo vivo; `open_ids` (o que o save ganhou, sem o limite) é o que a migração v9 marca como apresentado.
- Nada que já está aberto fecha: apresentado ou usado continua aberto. `Milestones.grandfather(data)` marca como apresentado/guiado o que o
  save antigo tinha (a Ultimate de quem já tem Maestria 2); `SaveData.merged` deve chamá-la ao migrar para a versão dos marcos (3A1).
- Guias: condição nova `ult` (`HubGuide.CONDITIONS`), que pergunta a `HubGate.is_open(&"ult")`; `account` pergunta a `HubGate` (não a `Vine.open`).
  O guia `ult` (estação `tree`, texto `guide_ult`) entra no `_hub_guide` do `make_data.gd`. A frase de abertura `hub_open_ult` está em `HubGate.TEXT`.
- Mudou em relação a antes: a Prata (15 de Prata não abre mais a Forja), Videira não abre mais com o primeiro guardião, Estandarte
  só com a primeira vitória (antes com o Vendedor). Quem já tinha apresentado fica como estava.

## Revisão de arte 2026-11-26 (Portão e céu; environment-artist, sem captura ainda)
- Portão (`HubBlockout._gate`, `HubScenery._gate_dressing`): os muros ao lado da abertura baixaram para `GATE_WALL_H` (3,2 m);
  só a cabeça do arco (a abertura mais `GATE_HEAD_SIDE` de cada lado) sobe até `HubPlan.GATE_HEIGHT`, com capa própria. Colisão
  e ponto de uso intactos. Luz do Portão dourada de Elun: folha e luzes por `light_portal(..., GATE_LIGHT_TINT)`, coluna
  `GATE_LIGHT_COLOR`, poça `STATION_POOLS` do portal em dourado (nada de verde).
- Céu: com a câmera Perto (pitch 30, fov 24) o fundo é o mar de nuvens e a faixa de montanhas a 160 m ou mais não aparecia.
  `RIDGES` aproximadas (v 70, 110, 160) com a crista entre y 12 e 42, `SEA_Y` -30, `SEA_CLOUD_SCALE` 0,07 (nuvens que a
  câmera distingue), cartão do céu mais baixo (gradiente se vê). Ajustar à vista se ainda sair chapado.

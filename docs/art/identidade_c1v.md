# Identidade C1V: uma imagem que se lembra (plano da noite de 2026-11-22 e depois)

Art Director, 2026-11-22. Pedido do Daniel: refinar o combate e o layout "para que os jovens se lembrem do jogo e que venda pela imagem".
Base: `plano_pintado_a_mao.md` (folhas pintadas, piloto no Salão), `art_direction.md` (cores reservadas, hierarquia), `benchmark_hades2_style.md` 7.2
(matiz por bioma), capturas de hoje em `C:\Users\danie\tools\shots` (`f__05` Salão, `f__19` Fenda, `f__23` Cripta, `g_poise_*`, `e_trinca*`, `b_*`).
Este documento é o atalho por código que vem **antes** das folhas pintadas: muda o que uma captura mostra sem textura nova. Nada aqui é arte final.

## 1. Cinco marcas que alguém lembra de uma imagem
| Marca | O que é (próprio, sem copiar jogo) | Já temos | Falta |
|---|---|---|---|
| M1 Silhueta | o Guerreiro: cabelo vermelho, cachecol petróleo, Emeth esmeralda erguida | modelo e cores reservadas; anel petróleo no chão | a 1080 o herói tem cerca de 130 px e some entre os Escudos grandes (`b_elder_knight`); o cachecol não lê como mancha própria; falta borda morna que o destaque do fundo frio |
| M2 Cor-assinatura | **esmeralda e ouro velho cortando azul-petróleo**: o mundo é frio, só o herói e Elun aquecem | cortes 45% dourado (Lote 4), Salão 205 de matiz | a sala não tem quente nenhum fora das velas; ouro aparece só no corte, não no chão nem na luz |
| M3 Luz | **o facho de Elun**: um feixe marfim-ouro vindo do alto, com poeira, em toda sala de luta | um feixe só na Fonte (azul-branco, frio, liso, lê como holofote) | morno, com borda de pincel e poeira dourada; poça no chão que vira o "palco" da luta |
| M4 Forma de efeito | **a meia-lua aberta** com fio de ouro e tinta escura por baixo; nos grandes momentos ela se parte em lascas marfim | meia-lua (SR-G4), lascas, anel | a Quebra (`g_poise_break`) lê como texto "Quebrou!", não como forma; morte e golpe final sem desenho próprio |
| M5 Composição | **ilha de luz sobre o abismo**: o chão iluminado no meio, muro e abismo escurecendo nas bordas, diagonal do alto à esquerda para baixo à direita | abismo e balaústres no Salão; `--showcase` | as bordas são tão claras quanto o centro (`f__05`: chão 72, muro 62); sem vinheta de cena; neblina em barra lisa |

Regra que amarra tudo: **quente é sagrado ou do herói; frio é o mundo; vermelho só fere; violeta só Morvath.** Nada de cruz, nada de sol (D-64 a D-68).

## 2. O que dá para fazer por código esta noite (só no perfil estilizado)
Medidas com `python3 -I tools/frame_stats.py --scene --hue` e caixas de 200 x 150; GPU pela linha `RESULT` do `tools/gpu.sh`. Teto de GPU da noite: **+0,6 ms** no Salão a 1080.

**2.1 Salão: luz e paleta (environment-artist).** Arquivos: `scripts/game/catacomb_hall.gd`, `scripts/game/arena_kit.gd` (`paint_look`/`STYLE` do Salão),
`scripts/game/room_mood.gd` (só o dicionário estilizado do Salão), `assets/shaders/paint.gdshaderinc` (nova cor de sombra **por uniforme**, padrão = hoje, para as outras salas não mudarem),
`room_air.gdshaderinc`, `beam.gdshader`, `abyss_mist.gdshader`, `abyss_fog.gdshader`.
- Sombra colorida: a sombra puxa para `#1E2236` (violeta-frio) em vez de multiplicar cinza. Critério: matiz da sombra no chão a **20 graus ou mais** do matiz da laje iluminada (rumo a 225 a 240), saturação da sombra 0,25 a 0,40.
- Chave morna: a lua fria fica, entra uma chave âmbar fraca do alto à esquerda (cor perto de `#F2C890`, sem sombra nova; das 6 sombras do Salão não sobe nenhuma). Critério: poça morna com matiz 30 a 40, luma p50 **25 a 40 acima** do chão vizinho, cobrindo 10 a 18% do chão andável, nunca acima de luma 200.
- Facho de Elun (M3): um feixe marfim-ouro na metade de cima do quadro com poeira dourada lenta (reusar `beam.gdshader` e as `motes` do `fx.gd`), borda quebrada por ruído de pincel em mundo. Critério: núcleo luma 150 a 200, matiz 35 a 45, nunca sobre o herói (abre em volta dele como o `hero_hole`); o feixe da Fonte passa a esse mesmo tom.
- Neblina com forma: no abismo, faixas de bruma com borda pincelada em 2 planos (perto mais escuro). Critério: luma da bruma 15 a 35 acima do abismo, zero pixel de bruma sobre chão andável, nenhuma barra vertical lisa (D6).
- Composição (M5): vinheta de cena no estilizado, só cenário (antes da UI e dos efeitos). Critério: caixas de borda com luma p50 **0,55 a 0,70** do centro; cena inteira mantém matiz 200 a 212, sat p50 0,35 a 0,42, luma p50 52 a 62.

**2.2 Contraste herói, inimigo e chão (technical-artist).** Arquivos: `assets/shaders/hero_paint.gdshader`, `figure_paint.gdshaderinc`, `crowd.gdshader`, `crowd_outline.gdshader`, `contact.gdshader`/`soft_shadow.gdshader`.
- Herói: borda morna (rim matiz 30 a 40) do lado da chave; cachecol com +0,1 de valor. Critério: herói p90 a **60 ou mais** acima do p50 do chão; petróleo do cachecol visível (matiz 175 a 190, sat 0,45 ou mais) em pelo menos 150 px a 1080.
- Inimigos: borda fria fina e rosto/mãos/arma um degrau acima. Critério: inimigo p50 a 15 ou mais do chão e **p90 a 40 ou mais** acima (hoje o arqueiro reprova, 76 contra 72); nenhum inimigo com rim quente (o quente é do herói).
- Sombra de contato sob cada figura, luma 15 a 25 abaixo do chão, raio 0,6 do corpo. GPU: +0,1 ms no máximo com 30 inimigos.

**2.3 Efeitos de combate memoráveis (technical-artist).** Arquivos: `scripts/game/fx.gd`, `scripts/game/enemy_fx.gd`, `assets/shaders/crescent.gdshader`, `slash.gdshader`, `impact.gdshader`, `chip.gdshader`, `smoke_ring.gdshader`, `ring.gdshader`.
Só desenho: não tocar `horde.gd`, `player.gd`, `combat.gd` nem os tempos (o `RESULT` não pode mudar); só reagir a chamadas que já existem. Cores: esmeralda, ouro velho, marfim; vermelho nunca.
- Quebra: anel marfim que se parte em 6 arcos voando para fora (0,25 s) mais lascas marfim; a palavra "Quebrou!" fica menor que o anel. Critério: lido sem texto numa captura parada; pico luma 226 no máximo.
- Impacto: estrela de contato achatada de 3 quadros, miolo marfim, borda ouro; nos golpes pesados uma marca de tinta no chão que some em 0,6 s.
- Golpe final do combo: meia-lua dupla (a segunda 0,05 s depois, 20% maior, só fio de ouro) e sulco escuro no chão até 0,8 s. Critério: o 3º golpe se distingue do 1º numa captura parada.
- Esquiva: só o `dodge_ghost.gdshader` (cor petróleo pálida, 2 ecos, rastro de pincel). Outro agente mexe na esquiva agora: **não editar `player.gd`**; se o shader estiver aberto por ele, fica para o Lote N2.
- Morte com pó de osso: a lufada sobe em espiral curta e pousa como mancha que some em 2 s. Critério: mancha com luma até **chão + 25** (D7), sem ficar adesivo; com 12 mortes no quadro, no máximo 40 lascas (`FxBudget`).
- Desempenho: `--stress=300` perde até 2 qps; nenhum efeito sobre o herói acima de 1,3 (glow).

**2.4 HUD e telas bonitas em captura (ui-ux-designer).** Arquivos: `scripts/ui/hud.gd`, `hud_bar.gd`, `life_vignette.gd`, `ui_kit.gd`.
- Defeito visto nas capturas da Fonte: a barra do chefe ("Sacerdote Ancião") cai em cima do título da sala ("Salão das Catacumbas, Fonte de Luz"). Critério: zero sobreposição de texto em 1080 e 720.
- Título da sala como cartela: marfim sobre filete de ouro velho, some em 2,5 s, sem caixa preta. Barra do chefe com moldura ouro velho e nome em versalete.
- Critério geral: HUD ocupa até 9% da área a 1080; texto com contraste 4,5:1 ou mais sobre o que estiver atrás; nenhum elemento novo da UI em vermelho saturado fora da vida e do golpe sofrido.

## 3. Dois lotes para esta noite (cerca de 2 h cada, no máximo 2 agentes ao mesmo tempo)
Regras dos dois: muda **só o perfil estilizado** (`VisualProfile.vary`, dicionário estilizado do `RoomMood`, uniforme com padrão igual a hoje); **F7 continua mostrando o clássico igual ao de antes**;
`tools/smoke.sh` com a mesma semente dá o **mesmo `RESULT`**; testes só por `-gselect` (`test_visual_profile` e os do próprio arquivo). Fora dos limites: gameplay, inimigos, esquiva, chefes, `encounter_gen`,
`scripts/core/`, `tools/make_data.gd`. Nenhum agente captura: pedem à sessão principal.
- **Lote N1** (em paralelo): `environment-artist` faz 2.1 inteiro no Salão; `ui-ux-designer` faz 2.4. Arquivos sem cruzamento.
- **Lote N2** (depois do N1 integrado): `technical-artist` faz 2.2 e 2.3; `environment-artist` leva só a sombra colorida e a chave morna para a Cripta (matiz alvo 184 a 194) e a Fenda (246 a 260), pela mesma receita de uniforme.
Capturas que peço à sessão principal (6, uma por vez, estilizado e Perto, 1080):
1. Salão antes, vitrine: `RES=1920x1080 tools/gpu.sh shot <scratch>/c1v_salao_antes.png --showcase --seed=5 --shot-at=2`
2. Salão antes, luta: `... --bot --autopick --seed=5 --shot-at=9`
3. e 4. as mesmas duas depois do N1 (mais a linha `RESULT` com fps e `step_ms`).
5. Depois do N2, luta com Quebra: o mesmo comando que gerou `g_poise_break.png`.
6. Depois do N2, a captura 4 com `--look=classic` (prova do F7).

## 4. Kit para o Daniel de manhã
- Captura base da pintura-alvo: a número 3 (Salão, `--showcase --seed=5 --shot-at=2`, 1920x1080, estilizado). Se a vitrine não mostrar o herói, a número 4.
- **Pintura-alvo** (no ChatGPT dele, com a captura anexada): *"Repinte esta captura de jogo como pintura digital feita à mão, pincel largo e opaco, mantendo exatamente a câmera, a planta,
  as posições das figuras e a interface. Pedra azul-petróleo fria com sombra violeta, uma luz morna dourada vinda do alto à esquerda formando uma poça no centro, bruma pintada no abismo,
  bordas mais escuras. O herói de cabelo vermelho e cachecol azul-petróleo é o ponto mais claro. Sem texto novo, sem símbolo, sem imitar jogo, estúdio ou artista."*
- **Folha 1, lajes**: *"Doze pedras de piso soltas sobre fundo verde liso, vistas exatamente de cima, pintadas à mão com pincel largo, só cinza (médio 50%, claros até 65%, escuros até 35%),
  luz difusa, sem sombra projetada, borda gasta, cantos lascados, cada uma diferente, sem texto nem símbolo."*
- **Folha 2, blocos**: o mesmo, trocando por *"doze blocos de muro, proporção 2 por 1, sujeira na base, quina de cima gasta"*.
- **Folha 3, faixas**: o mesmo, trocando por *"peças soltas de degrau, tampa de túmulo, fuste de coluna, tábua com veio e ferragem, cada uma reta e de frente"*.
- Perguntas que continuam (seção 5 do plano pintado): quem pinta as folhas; se aceita retoque nas texturas das figuras. A imagem gerada é referência e vai para `docs/steam-ia.md` se virar folha do jogo.

## 5. Vender pela imagem: 6 composições de divulgação (quando o visual estiver pronto)
1. **A ilha de luz**: Salão de cima, herói no centro da poça morna sob o facho, 8 a 12 esqueletos chegando pelas bordas escuras, abismo embaixo. A imagem-chave da loja.
2. **O golpe final**: Perto, o 3º golpe congelado no quadro de impacto, meia-lua dupla esmeralda e ouro, lascas de osso no ar, um inimigo partindo a guarda. Ação em uma imagem.
3. **A Quebra no guardião**: o Cavaleiro ou o Ancião ajoelhado com o anel marfim partido, o herói pequeno à frente; mostra escala e o "momento de abrir a guarda".
4. **Morvath e o selo**: Câmara do Selo, violeta e azul-marinho ao fundo, herói no primeiro terço de baixo, aviso vermelho bem legível no chão; cartaz do chefe.
5. **A descida**: três salas lado a lado (Salão petróleo, Cripta verde-petróleo de velas, Fenda índigo), cada uma com o facho; vende variedade e o "mais uma sala".
6. **O Santuário**: hub morno à noite, poça de luz em cada estação, o Guerreiro descansando; o contraponto calmo e a progressão (Forja, Livro de Ahk).
Para todas: 1920x1080 e 3840x2160 quando possível, HUD desligado em 1, 5 e 6, ligado em 2 e 3 (mostra que é jogo), sem texto de lore inventado, e conferir as regras de declaração de IA antes de publicar.

### Feito na noite de 2026-11-23
- Primeira versão das 6 composições em `docs/gallery/promo/` (cópia em `ASelagem-teste\divulgacao`), capturas reais na RTX, 1920x1080, estilizado e Perto. HUD desligado pela opção nova `--no-hud` (1, 4, 5 e 6); título em Cinzel só na 1; a 5 junta Salão, Cripta e Fenda em três faixas.
- Kit de pintura em `ASelagem-teste\kit_pintura` (captura base do Salão depois do N1 e os prompts da seção 4); cópia em `docs/gallery/c1v/`.
- Faltam: 4K, a Quebra no guardião com o anel no quadro (a 3 pegou o Ancião com o orbe), a Ruptura de Morvath (o robô o venceu antes dela).

## Fila por sala depois do laboratório do Salão (pacote 2026-11-23)

Linguagem comum: massas de luz fortes (fogo âmbar e portal), bordas emolduradas, centro limpo, pedra pintada, nada de
círculo no chão (só Morvath), nada de folhagem vermelha (âmbar seco ou musgo), vermelho, esmeralda, violeta e ouro de elite
reservados. Cada sala precisa de quebráveis.
1. **Cripta B (prioridade 1):** imagem 03. Sarcófagos esculpidos, nichos com velas, relevos; perigo: esqueleto agarrando da
   parede (já existe o nicho, SW-G7); quebráveis: urnas, vasos funerários, bancos. Fazer primeiro: é a sala mais íntima.
2. **Jardim B (prioridade 2):** raízes grossas, água, luz filtrada; planta hostil fixa (já existe); trocar qualquer
   folhagem avermelhada por âmbar seco ou musgo escuro; quebráveis: galhos, vasos de água, jardineiras.
3. **Fendas (prioridade 3):** travessia perigosa; ponte e abismo já têm o código; falta a assinatura própria (bordas
   quebradas, correntes, neblina no fundo). Depende da leitura do vazio em captura.

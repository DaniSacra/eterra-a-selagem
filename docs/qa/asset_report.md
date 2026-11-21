# Relatório de assets (artista técnico)

Auditoria inicial, 2026-11-18, HEAD `d458633` do `arpg-3d`. Inventário completo em `docs/art/asset_inventory.md`.
Nada foi apagado nem alterado nesta auditoria; as únicas adições são as ferramentas de medida `tools/asset_probe.gd`
(modelos, assados, VRAM) e `tools/pck_sizes.py` (o que entra no exe e quanto pesa).

Classificação: **P0** quebra o jogo, a licença ou a entrega; **P1** custa caro (memória, pacote, risco) e tem
correção técnica clara; **P2** limpeza, documentação ou ganho pequeno.

## Resumo dos números

| Medida | Valor | Teto | Como |
|---|---|---|---|
| Exe do Windows | **219,7 MB** (modelo da Godot 109,3 + PCK 110,4); **197,2 MB** depois da C1 | | export `"Windows Desktop"` no worktree, `ls -l` |
| PCK por família | assados 43,92; música 17,22; bonecos do KayKit 11,38; herói 8,27; Emeth 6,99; UI 6,19; texturas 3,91; ambiência 3,01; UAL 2,18; `dungeon_r` 2,17; `dungeon` 1,46; efeitos 1,30; scripts 1,24; fontes 0,35; shaders 0,28; armas 0,20 MB | | `python3 -I tools/pck_sizes.py build/windows/ASelagem.exe` |
| Assados | **43,92 MB** | 70 MB (63%) | `du -cb assets/baked/*.res` |
| Música no pacote | **17,22 MB** (16,57 no disco: o `.oggvorbisstr` soma 4%); **17,73 MB** depois do MUS-1, com 4 peças novas (16,69 no disco) | 18 MB (99%) | PCK; MUS-1 pelos `.oggvorbisstr` de `.godot/imported` |
| VRAM das texturas carregadas | herói 28,5; Emeth 19,4; relevo da rocha 5,3 + 1,3; título 8,8; medalhão de 512 1,3; **21 peças do KayKit 112,0**; assados 79,0 MB | | `tools/gpu.sh run --rendering-driver vulkan -s tools/asset_probe.gd -- vram` (RTX 5060, `RENDER_TEXTURE_MEM_USED`) |

## Feito

### MUS-1, 2026-11-18: música de luta (pedido do PO)
Quatro peças novas sintetizadas pelo projeto (`tools/make_music.gd`): "Marcha das Lâminas", "Tambores do Fundo",
"Pulso de Ferro" (salas, caminhada e luta) e "Morvath, a Batalha" (4 fases); padrão no título, nas salas e em Morvath.
Detalhes, loudness e luta gravada em `docs/design/t5_audio.md` (MUS-1). Para caber: Kevin MacLeod reencodado em
qualidade Vorbis 0 (Q-20 a; 10,2 para 5,6 MB, mesmas amostras e laços, loudness a 0,1 LU), originais, Salmos e vitória
do .wav em qualidade 1. Música no disco 16,57 para 16,69 MB, no pacote 17,22 para 17,73 MB (teto 18). Sobra pouco:
a próxima peça pede tirar "Tempting Secrets" (1,1 MB) ou subir o teto.

### C1, 2026-11-18: melhorias 1 a 4 (aprovadas pelo Daniel)
Nenhuma mudança de aparência; capturas na GPU antes e depois em `docs/gallery/assets/c1/`.

1. **Fontes dos assados fora do pacote** (P1-2): `assets/models/characters/*`, `assets/models/anim/*`,
   `assets/models/weapons/*` e `assets/baked/statue.res` no `exclude_filter` dos presets Windows, Linux e Web. Os
   arquivos ficam no repositório para o `tools/bake.gd` e o `tools/bake_hero.gd`.
2. **Uma paleta do KayKit só** (P1-1): `assets/models/kaykit_material.tres` (StandardMaterial3D igual ao que o
   importador fazia: a paleta e rugosidade 0,45) com `assets/models/kaykit_palette.png` em BC7 com mipmaps; cada
   `.glb.import` de `dungeon/` e `dungeon_r/` aponta para ele (`_subresources` > `materials` > `texture` >
   `use_external`) e não extrai mais imagem (`gltf/embedded_image_handling=0`). As 69 cópias da paleta (mesmo md5
   `1fa0d4f3...`) e os seus `.import` foram apagados; nenhum script, dado ou cena as citava (grep de
   `dungeon_texture`), só os próprios `.glb` importados. `Arena._tinted` e `ArenaKit._stone` agora fazem uma cópia só.
3. **Herói e Emeth em VRAM**: `compress/mode=2` com `compress/high_quality=true` (BC7, da família S3TC/BPTC que o
   preset exporta); a Emeth importada em 1024 (`process/size_limit=1024`).
4. **Rocha**: normal em BC5 (`compress/normal_map=1`, formato RGTC_RG); o `masonry.gdshader` e o
   `catacomb_floor.gdshaderinc` liam o z do texel (`.rgb * 2 - 1`) e agora o refazem de x e y (o `stone_tree.gdshader`
   usa `NORMAL_MAP`, que a Godot já refaz). Altura em BC4 (RGTC_R: verde e azul em "zero" no `channel_remap` e
   `compress/channel_pack=1`; sem isso a imagem cinza vira DXT1).

**A causa e a trava**: o `detect_3d/compress_to` só troca uma textura para VRAM quando o editor com tela a vê num
material 3D; o projeto é importado sem tela, então nunca trocou. Os cinco `.import` agora dizem `compress/mode=2` eles
mesmos e `detect_3d/compress_to=0` (nada fica para o editor decidir). A importação sem tela comprime de verdade
(Linux e a Godot de Windows do espelho: `.s3tc.ctex`, `imported_formats=["s3tc_bptc"]`). `tests/test_asset_import.gd`
falha se algum desses `.import` voltar a sem perda, se a textura carregada não for BC7/BC5/BC4 com mipmaps, se uma
peça do KayKit deixar o material comum ou se uma cópia da paleta reaparecer.

**Navegador**: o preset Web tem `vram_texture_compression/for_desktop=true` (S3TC/BPTC, o mesmo dos assados, que já
eram DXT1); exporta sem erro nem aviso (`index.pck` 88,0 MB). Captura no Compatibility pela placa
(`--rendering-driver opengl3`): `after_compat_hero.jpg`, herói, Emeth e relevo da pedra certos. Onde o navegador não
tiver BPTC ou RGTC, a Godot descomprime ao carregar (custa memória, não quebra).

| Medida | Antes | Depois |
|---|---|---|
| Exe do Windows | 219,72 MB | **197,24 MB** (-22,5) |
| PCK | 110,32 MB, 1 331 entradas | **87,86 MB**, 1 148 |
| PCK: bonecos do KayKit / UAL / armas | 11,38 / 2,18 / 0,20 MB | 0 / 0 / 0 |
| PCK: assados | 43,92 MB | 43,75 (sem a estátua) |
| PCK: herói (pasta) / textura dele | 8,27 / 6,45 MB | 7,41 / 5,59 |
| PCK: Emeth (pasta) | 6,99 MB | 1,68 |
| PCK: `assets/textures` (rocha e leão) | 3,91 MB | 2,81 (normal 2,63 para 1,40; altura 0,57 para 0,70) |
| PCK: peças do KayKit + paleta | 3,63 MB | 0,97 + 1,40 |
| VRAM herói | 21,33 MB (2048 RGB8) | **5,34** (2048 BC7) |
| VRAM Emeth | 21,33 MB (2048 RGB8) | **1,34** (1024 BC7) |
| VRAM normal / altura da rocha | 5,33 / 1,34 MB (RGB8 / L8) | **1,34 / 0,67** (BC5 / BC4) |
| VRAM 21 peças do KayKit de uma descida | 112,03 MB | **1,34** |
| Soma dessas texturas | 161,4 MB | **10,0 MB** |

VRAM medida pela `tools/asset_probe.gd -- vram` na RTX 5060 (Vulkan, espelho `eterra-gpu`), antes e depois com a
mesma sonda. A sonda agora espera 4 quadros depois de cada carga e imprime tamanho e formato: na auditoria inicial ela
lia o monitor um quadro só depois, e o herói (28,5) e a Emeth (19,4) saíram trocados por atraso; o certo, medido de
novo no estado antigo, é 21,33 cada.

**Fidelidade** (textura decodificada contra a fonte, mip 0, PSNR nos canais usados): paleta BC7 56,4 dB (erro máximo
3 de 255; o BC1 dava 36,7 dB e 13); herói BC7 45,0 dB (o BC1 dava 33,2 dB, erro máximo 97 e 11% dos texels acima de 8:
manchas de bloco no rosto e na capa de perto, por isso BC7, que custa o dobro do BC1, 5,3 contra 2,7 MB); Emeth em
1024 BC7 35,7 dB contra a fonte reduzida por Lanczos (boa parte é o filtro da redução); normal BC5 41,2 dB; altura BC4
46,8 dB. **Capturas a 1920 x 1080 na GPU, antes contra depois** (PSNR das PNG, diferença ampliada 6 a 8 vezes):
herói de perto na vitrine 38,2 dB, luta do robô (`--seed=5`, 9 s) 43,9, salão inteiro na vitrine 29,7, salão antigo
do `--horde` (pilares, velas e paredes do KayKit) 42,1; em todas a diferença está só no que se move (inimigos,
chamas, partículas), nada no herói parado, na Emeth, nas peças do KayKit ou na pedra. Recorte lado a lado:
`hero_crop_before_after.jpg`. Nada foi revertido.

Ficou de fora: o BC1 no herói (ver acima; pode-se voltar a pensar se a memória da iGPU apertar); P2-1 a P2-9 e as
melhorias 5 a 7 (não estavam no pedido).

## P0

Nenhum. O pacote não leva nada de origem desconhecida, toda música e todo efeito CC BY está no `CREDITOS.txt` e no
`audio/LICENSES.md`, a arte de IA que vai no jogo está no `docs/steam-ia.md`, todo efeito sonoro e todo shader têm
uso, e não há `.import` órfão.

## P1

**P1-1. As texturas 3D vão sem compressão de vídeo; 21 cópias da mesma paleta ocupam 112 MB de VRAM.** Feito na C1.
Todo `.import` de imagem do projeto está em `compress/mode=0` (sem perda) com `detect_3d/compress_to=1`; a troca
automática para VRAM só acontece quando o editor com tela vê a textura num material 3D, o que nunca aconteceu (o projeto
é importado sem tela). Os `.ctex` confirmam: `hero_explorer-rigged_Image_0.jpg` 2048 x 2048 `store=webp fmt=RGB8`,
`emeth_0.jpg` idem, `rock_surface_nor_gl_1k.jpg` 1024 `webp RGB8`, as 69 paletas do KayKit 1024 `webp RGBA8`
(`python3 -I tools/pck_sizes.py --ctex .godot/imported/<arquivo>.ctex`, cabeçalho `GST2`). Medido na RTX 5060: herói 28,5 MB, Emeth 19,4 MB, normal da rocha
5,3 MB e as 21 peças do KayKit carregadas numa descida **112,0 MB** (cada `.glb` traz a sua cópia da mesma paleta de
15 KB: as 69 PNG de `dungeon/` e `dungeon_r/` têm o mesmo md5 `1fa0d4f3...`). No notebook do Daniel (iGPU, memória
compartilhada; Alta a 15 a 17 qps) isso pesa. No pacote, o herói e a Emeth somam 13,2 MB só de textura.
Correção técnica (sem mudar o desenho): `compress/mode=2` (VRAM) nos `.import` das texturas 3D (herói, Emeth, rocha
com `normal_map=1` para BC5, paleta do KayKit) e uma paleta só para as peças (`_subresources` do `.glb` apontando
para um material/textura comum, ou trocar a textura no `Arena._place`/`ArenaKit._kit_mesh`). Estimativa: herói e Emeth
de 48 MB para cerca de 6 MB de VRAM (DXT1 com mipmaps) e de 13,2 para cerca de 5,6 MB no pacote; KayKit de 112 MB para
5,6 MB (uma cópia) ou 0,7 MB (uma cópia DXT1). A paleta é de cores chapadas: conferir na captura que o DXT não suja as
bordas das células (se sujar, uma cópia sem perda já resolve 95%).

**P1-2. Fontes dos assados entram no pacote: 13,8 MB que o jogo nunca carrega.** Feito na C1.
`export_presets.cfg` exclui `enemy_*`, `hero_sombra`, `paladin_1` e `palettes`, mas não `assets/models/characters/*`
(11,38 MB no PCK: 7 bonecos do KayKit e texturas), `assets/models/anim/*` (2,18 MB: UAL 1 e 2) nem
`assets/models/weapons/*` (0,20 MB). Prova de que não têm uso em jogo: nenhum `grep` em `scripts/`, `data/` ou
`scenes/` (`characters/`, `weapons/`, `models/anim`, `ual_standard`, `Skeleton_`) e nenhum "Loading resource" deles
nas 29 partidas traçadas; só `tools/bake.gd` e `tools/bake_hero.gd` os leem (`RIGS`, `CHAR`, `held`). Também
`assets/baked/statue.res` (0,17 MB): nenhum `EnemyDef.model` é `statue`, a estátua é desenhada por
`Masonry._build_statue` (`masonry.gd:650`). Correção: somar
`assets/models/characters/*, assets/models/anim/*, assets/models/weapons/*, assets/baked/statue.res` ao
`exclude_filter` dos três presets (e tirar a entrada `statue` do `MODELS` do `bake.gd`, ou deixá-la só no modo
`-- kaykit`). PCK de 110,3 para cerca de 96,4 MB (exe 205,8).

**P1-3. Licença do Meshy sem registro.** O Meshy dá aos modelos do plano gratuito a licença CC BY 4.0 (com
crédito) e ao plano pago a posse do usuário. `tools/meshy/tasks.json` guarda prompts, ids e créditos, mas nenhum
documento diz em que plano cada modelo que vai no jogo (herói, Emeth, nove inimigos) foi gerado; o `CREDITOS.txt` diz
"modelos gerados com o Meshy" sem licença. Ação: o Daniel confirma o plano das tarefas de 2026-11-15 e anotamos no
`docs/steam-ia.md` e no `docs/art/asset_credits.md`; se algum foi do gratuito, o crédito ganha "CC BY 4.0".

## P2

**P2-1. `morvath.res` um commit atrás do `tools/bake.gd`.** Assado em `6338417`; `5aeee46` reassou os outros oito e
mudou o `COMMON_ANIMS.rise` (`"in_place": true`) e o `BakedModel.parts`. Para Morvath o efeito é nulo hoje: ele nasce
com `spawn(..., false)` (`boss.gd:240`), nunca toca `rise`, e não tem peça com nome. `tools/pose_drift.gd`: `rise` dele
0,25 m de desvio contra 0,23 do esqueleto reassado. Reassar no próximo ciclo que mexer nele (não reassei aqui para não
alterar assets). O herói está em dia (`hero_anims.res` e `bake_hero.gd` no mesmo `579ce02`; `Retarget` e `MeshSlim`
mais antigos que os dois assados).

**P2-2. Inimigos acima do orçamento de triângulos pelas armas do KayKit.** Corpo 3 900 (`BODY_TRIANGLES`), mas o assado
do feiticeiro tem 5 530, o ancião 5 557 e o Cavaleiro 4 956 (`asset_probe.gd -- baked`): o cajado do KayKit
(`Skeleton_Staff.gltf`, cena de 67 KB no PCK) soma ~1 600 triângulos. Cada vértice a mais custa 8 bytes por pose nas
imagens de pose. Proposta: reduzir as peças `held` no assado (o `MeshSlim` já existe) para ~300 triângulos.

**P2-3. Pé do sacerdote ancião 8 cm abaixo do chão no repouso** (`idle_floor=-0.081`; os outros entre -0,025 e +0,012).
Provável barra do manto, que pode ficar abaixo; conferir numa captura de perto (`tools/enemy_lab.gd priest_elder`)
antes de mexer no `height` ou no assento.

**P2-4. Herói com 30 741 triângulos**, oito vezes um inimigo, desenhado pelo corpo e pelos três passes do raio-x quando
coberto. Não é gargalo medido (um herói só); se o quadro na iGPU precisar, reduzir pelo `MeshSlim` para ~12 mil e
comparar numa captura de perto.

**P2-5. Peças do KayKit que nunca carregam.** 8 de 26 em `dungeon/` e 40 de 43 em `dungeon_r/` não aparecem em
nenhuma das 29 partidas traçadas (~2,0 MB no PCK, lista no inventário, seção 4). 18 peças são iguais byte a byte nas duas
pastas. O código ainda cita algumas (`ArenaKit.STONY`, `ArenaKit.portal` com `wall_doorway`): confirmar com o
environment-artist antes de excluir do pacote ou apagar.

**P2-6. Margem da música: 0,78 MB.** 17,22 MB no PCK contra o teto de 18 (o `CLAUDE.md` cita 16,6, que é o disco).
Uma peça nova não cabe sem tirar outra ou baixar a taxa (as do MacLeod estão a ~100 kbit/s, 10,56 MB no PCK).

**P2-7. Retrato do Livro de Ahk em 330 x 400 sem mipmaps**, desenhado com `TEXTURE_FILTER_LINEAR` e `EXPAND_IGNORE_SIZE`
(`hero_screen.gd:271`): se a página o mostra maior que 330 px a 1080, borra. Medir numa captura `--title --screen=hero`
a 1080 e, se for o caso, recortar maior da prancha.

**P2-8. Documentos de licença incompletos.**
- `docs/art/asset_credits.md` diz "Kenney Impact Sounds" como o som do jogo; hoje são cinco autores (está certo no
  `audio/LICENSES.md`). Apontar para lá.
- `CREDITOS.txt` (ARTE) cita "tela de título, retrato do herói e medalhões das Bênçãos"; faltam os medalhões dos
  eventos (Altar e Provação) e o retrato do Livro de Ahk (estão no `docs/steam-ia.md`).
- `docs/steam-ia.md`: a ambiência (`tools/make_ambience.gd`, código escrito por IA, como a música) e o `title_fill.png`
  (derivado da pintura de IA) não aparecem; a lista "Sem IA" esqueceu qubodup, rubberduck, Little Robot, Poly Haven e
  Kevin MacLeod.

**P2-9. Lixo pequeno no pacote e no repositório.**
- `.gutconfig.json` entra no PCK pelo `include_filter="*.json"` (190 bytes; nenhum `.json` do jogo precisa dele hoje).
- `assets/textures/seal/lion.svg` entra no PCK como textura (4 KB), só o `tools/make_seal_lion.gd` o lê.
- `addons/gut/menu_manager.gd.uid` sem o `.gd` (do GUT, fora do pacote).
- `hero_sombra/` (32 MB) e `paladin_1/` (28 MB) sem uso, com 4 cópias idênticas da mesma textura de 2048 em cada;
  `assets/models/palettes/priest.png` = `priest_elder.png`; as quatro texturas de esqueleto do KayKit e
  `weapons/skeleton_texture.png` iguais. Fora do pacote, mas 60 MB no repositório.

## HUB-D e Fatia 1 (technical-artist, 2026-11-19)

Entregue: gente do hub assada (`npc_vendor.res` 0,77 MB, `npc_smith.res` 0,85 MB, 8 237 triângulos juntos contra o
teto de 12 mil, solas a 0,000 m, paleta comprimida dentro do `.res` porque `assets/models/palettes/*` não é
exportado), `frame_yaw` na cantaria e nas lajes (global 0 fora do hub), `temper` na Emeth (padrão 0), selos dos anjos
em código. Achados:
- **P1** `HubPlan.SMITH_SPOT` (-23,4; -8,6), o círculo de colisão do Forjador, fica 1,7 m da bigorna; o martelo do
  `1H_Melee_Attack_Chop` alcança 0,79 m, então o Forjador é desenhado em (-22,66; -7,11) do quadro do hub (onde o
  martelo pousa na face da bigorna) e o círculo velho barra um lugar sem desenho. Mover `SMITH_SPOT` para esse ponto
  (dono: gameplay-engineer, `scripts/core/hub_plan.gd`).
- **P2** o Vendedor fica no chão andável atrás do balcão (u -23,9, o chão vai a -25): o herói pode contornar o balcão
  e atravessá-lo (não tem colisão própria). Se incomodar, um círculo `hub_vendor` de 0,4 m no `HubPlan`.
- **P2** o golpe da biblioteca desce em dois quadros (0,58 a 0,60 s do clipe): 12 poses em 0,555 s bastam para a tela,
  mas a cabeça do martelo só fica a 0,89 a 0,94 m no último quadro com o tronco 12 graus para trás (`bend` do clipe).
- **P2** `test_hub.gd` falha num teste que não é de asset (urna `hub_urn` em (-16; 1) a 1,2 m da rota até o
  Vendedor depois do `URN_R` 0,75 de outra frente).
- **P2** os selos ficaram com a Vigília em verde-oliva (`AngelSeal.TINT` mudado por outra frente depois da minha
  entrega; o meu era petróleo 0,3 / 0,62 / 0,6): conferir com o art-director qual vale. A alça da trombeta agora pende
  das duas braçadeiras (solta embaixo lia como um sorriso).

Evidência (RTX, Forward+): `docs/gallery/hub/d/` (`vendor_sty_720.jpg`, `arrival_sty_1080.jpg` e
`arrival_classic_1080.jpg` com a cantaria e as lajes no quadro do hub, `smith_sty_near_5.55.jpg` e
`smith_classic_near_5.55.jpg`, `smith_blow_strip_sty.png` com 5,1 / 5,55 / 5,75 s: braço erguido, martelo na face da
bigorna com a fagulha, fagulhas caindo); `docs/gallery/rj1/` (`angel_seals.png` de 36 a 168 px na tinta e no papel,
aceso e apagado; `emeth_temper_classic.jpg` e `_stylized.jpg` com os postos 0, 1, 2 e 1,5). Salas iguais com
`frame_yaw` 0 (`a13_*`, depois contra antes no HEAD): Salão clássico 1,10% e Cripta estilizada 1,35% dos pixels
mudam mais de 12, todos no HUD (que outras frentes mudaram), nas chamas e nas partículas; nenhuma pedra nem laje.

## Lote 2C e re-revisão do hub (technical-artist, 2026-11-19 noite)

- **DT-104** feito: `tests/test_asset_budget.gd` (4 testes, 0,8 s) falha com assado atrás da entrada do
  `tools/bake.gd` (cada `.res` guarda `bake_stamp`, `stamp()` com `PIPELINE`), assados acima de 70 MB, música do pacote
  acima de 18 MB (o `.oggvorbisstr` importado de cada `.ogg`) ou figura acima do teto. Falhava antes do reassado (Morvath
  e todos sem carimbo); passa depois.
- **Reassado de tudo** (nove inimigos e os dois do hub): 45,49 MB antes (com a `statue.res`) para 45,32 MB.
  `test_enemy_windup`, `test_boss_body` (Morvath `pose_drift` até 0,44 m fora da queda 0,52 e do levantar 0,41),
  `test_living_crowd`, `test_held_weapons`, `test_t5b_fight` passam. **QW-116**: o andar do feiticeiro já leva o cajado
  13,8 graus para trás e o trote sobe 0,15 (T5b); sem mudança. O clipe novo de Morvath do Q-09 a é do C19 (não existe).
- **DT-107**: saíram `hero_sombra/` (32 MB), `paladin_1/` (28 MB), `statue.res`, `tools/recolor_hero.gd`, `HeroGear`,
  o `.uid` órfão do GUT; `.gutconfig.json` e `lion.svg` fora do pacote (`include_filter` vazio, `lion.svg` no
  `exclude_filter`). **4 100 triângulos não cabe**: os níveis simples das armas do KayKit (`"lod"`, medidos: lâmina 457
  para 227, cajado 1 519 para 759, escudo 626 para 304) tiram a cabeça do cajado e a borda do escudo e quebram 6
  medidas do `test_enemy_windup` (média por vértice); ficaram de fora. Teto no teste 5 600 (feiticeiro 5 530, ancião
  5 557). Para 4 100: armas próprias. Peças do KayKit sem uso: não apagadas, falta o environment-artist confirmar.
- **DT-101** (sem Q-01): `CREDITOS.txt` com o retrato do Livro, medalhões do Altar e da Provação e as armas e a gente do
  KayKit; `asset_credits.md` com modelos, fontes (autores dos OFL) e sons apontando ao `audio/LICENSES.md`;
  `steam-ia.md` com `title_fill.png`/`title_bg.png`, a ambiência sintetizada, os selos dos anjos e a lista "Sem IA" com
  todos os sons gravados. **DT-108**: saldo do Meshy 546, inventário dos assados, `CLAUDE.md`.
- **(c)** `BossChamber._exit_tree`: a lua já liberada não vai mais a um parâmetro tipado (`is_instance_valid`);
  `test_room_style` sem SCRIPT ERROR.
- **(d)** água escura no Compatibility (`dark_water.gdshader`, `compat_body` 1,0, `compat_glow` 0,7): fonte do hub
  matiz 193 para 202, saturação 0 para 0,41, luma p90 102 para 109 (Forward+ 203, 0,39, 97). `docs/gallery/hub/d/water_*`.
- **(a) L-1** traços da preparação mais pintura (`EnemyFx`: tinta `INK_EDGE` 0,09 e `INK_ALPHA` 0,78, besta em osso
  `BOW_BODY` a `STROKE_TONE` 0,78, braços do Sacerdote a `RITUAL_ARM_DARK` 0,72): besta (caixa só dela, mesmos quadros,
  câmera Longe) luma p50 208 para 181 e 191 para 172, p90 220 para 189, saturação 0,05 para 0,2 (matiz 38), área igual
  (-6%); V do Sacerdote p50 137 para 117, saturação 0,45 para 0,51. `docs/gallery/lc/windup/l1_paint/`.
- **(b)** marcas de Prata e Memória no `RewardGem`: nenhum pedido do ui-ux-designer em arquivo; segue pendente.
- **T-1** NPCs do hub: `HubNpc.STYLE_LIGHT` 0,5, `STYLE_SCENE` 0,3, `STYLE_RIM` 0,35 (multidão 0,2 / 0,1 / 0,18), o
  Vendedor vezes `STYLE_VENDOR` 2,2. Câmera Perto em cada estação, pixels do corpo: Forjador p50 cerca de 55 para 79,
  Vendedor 45 para 76, herói 94 a 97. `docs/gallery/hub/d/t1_*`. Clássico igual (só uniforms `style_*`).
- **T-2** selo da Luz sem ponta: topo reto esmaecendo (alfa 0,2 a 0,9), largura de baixo 2,9 vezes a de cima, dois fios
  nas bordas. `docs/gallery/rj1/angel_seals.png` (24, 46, 96 e 140 px). T-3: oliva mantido.
- **Pendente (2B, em série com o C19 do gameplay-engineer)**: GF-15, VX-17, T5-17 a T5-19, T5b P2-2, corredor elite a
  259 passos por minuto, tira lateral do besteiro, Q-T5-6, Q-T5-7, B-b; reassar Morvath de novo quando o clipe do Q-09 a
  existir. `tools/walk_strip.gd` e `tools/rj1_lab.gd` (parte da Emeth) não compilam hoje sem os autoloads
  (`T` no `fx.gd`, `Audio` no `ui_kit.gd`).

## Lote 2B e TA-HB (technical-artist, 2026-11-20)

- **Ferramentas**: `enemy_lab`, `walk_strip`, `rj1_lab` (e o novo `edge_lab`) viraram calços que carregam
  `tools/lab/<nome>.gd` em tempo de execução (o `-s` compila antes dos autoloads); `Fx._gold_word()` tirou o `T` do
  caminho do `chamber_lab` e do `drawn_probe`. O `arena_lab` ainda imprime erros de `Controls` e `Audio` (do
  `player.gd` e do `horde.gd`, antigos) mas gera a imagem; `tools/hub_walk.gd` (não é meu) falha em `Controls`.
- **P1 golpe sofrido virava silhueta marfim** (combat_cadence 8.3 item 4): causa no `flash.gdshader` (cor morna chapada
  somada ao corpo inteiro). Corrigido: clarão pela pintura (`Player.HURT_FLASH_LIGHT`) e só borda no overlay
  (`flash_edge`). Pico da caixa do herói a 60 qps: 154 para 121 (repouso 105). `docs/gallery/c19/hurt_flash/
  hurt_flash_before_after_60fps.png` (em cima antes, embaixo depois, quadros 106 a 112), stills dos dois looks.
- **T5b P2-2** (`"centred"`): erguer 0,23 para 0,05 m no esqueleto; tabela no `CLAUDE.md`. Feiticeiro 0,21, Escudo 0,17
  e ancião 0,31 ficam pela pose final da guarda (não é deriva do erguer).
- **T5-17, T5-18** (Morvath): `curse_windup` (0,10 m de deriva) e `rain_wave` (0,14); `boss_probe` semente 5, 120 s:
  `CURSE/curse_windup` 44 quadros, `ERUPTIONS/rain_wave` 422, nenhum `rain:13` parado; os 7 quadros ruins são das Lâminas
  (`blades_windup`, 0,258 m: o recuo de 2 m em 0,25 s do Q-09 b, do C19). Pior pose de Morvath 0,44 m (teto 0,45).
- **T5-19**: `CROSSBOW_KICK` no tiro do besteiro. Tira de lado nova: `docs/gallery/lote2b/archer_walk.jpg`.
- **Corredor elite**: `runner_elite.res` a 199 passos por minuto (era 259), escorrega 4,6 cm;
  `docs/gallery/lote2b/runner_elite_walk.jpg` (antes, o assado comum a 2,01x) e `runner_elite_as_runner_elite_walk.jpg`
  (depois, 1,55x). Falta ligar no `make_data.gd` (gameplay).
- **Q-T5-6**: orbes do Redemoinho abaixo do glow (`Skills.ORB_*`, halo de 1,6 para 0,9 m). `qt56_victory_orbs_step1.png`
  é o primeiro passo (ainda globos); a captura do valor final na GPU ficou pendente (o Game Director suspendeu a GPU
  enquanto o Daniel joga). Os pontos esverdeados no fim de duas linhas da placa
  da laje não foram vistos: ficam com o ui-ux-designer (`door_sign.gd`).
- **Q-T5-7**: `--shot-on=boss:victory` com `--shot-at=0.5` capturou (antes travava).
- **`enemy_motion_probe`** semente 2, 40 s: avisos terminam no quadro do golpe (+0 f, um +1 e um -1 do Escudo), pose
  parada mais longa 0,22 s (teto 0,3). **Testes**: 1 321, 6 falhas todas de loja, Elo, Bênçãos por família e Forja
  (Fatia 2 em curso, não são de asset); `check.gd` ok.
- **TA-HB1** linha de tinta: RTX 1080 Alta GPU 2,37 para 2,41 ms (quadro 3,36 para 3,58); iGPU 720 Baixa GPU 15,02 para
  16,42 ms (58,6 para 52,6 qps, passa do limite de 3): **desligada na Baixa** (`ink_wanted(level)`). Desligada por padrão.
- **TA-HB2** `EdgeKit`: seção 8b do inventário. **TA-HB3** (figuras sobre o petróleo do Salão, ENV-HB1): medido em
  captura de CPU (`tools/shot.sh`, Vulkan no llvmpipe, 1280 x 720, `--stress=8` com os oito tipos, semente 5, herói em
  2,2; `docs/gallery/hb/hb3_hall_figures_cpu_classic.jpg` e `_stylized.jpg`). Luma p50 da figura contra o chão ao lado,
  clássico / estilizado: besteiro 32 contra 51 / 19 contra 40; feiticeiro 68 contra 73 / 55 contra 90; esqueleto junto
  ao herói 83 contra 56 / 69 contra 81. No estilizado o corpo é morno (matiz 5 a 23, saturação 0,31 a 0,41) sobre o chão
  petróleo (matiz 210 a 220): todas leem pelo matiz e pelo contorno, e as escuras pelo valor. O esqueleto claro perto do
  herói fica só 12 abaixo do chão iluminado por ele: lê pelo matiz e pela casca escura, não pelo valor. Nenhuma mudança
  pedida; conferir na GPU quando ela voltar.
- **Para o gameplay-engineer**: (1) `"model": &"runner_elite"` na elite do corredor (`_pair` do `make_data.gd`) e
  regerar `enemies`; (2) **B-b**: `player.gd:758` `_play(&"Dash", DASH_CLIP_SPEED)` mistura 0,08 s
  (`playback_default_blend_time`), então o primeiro quadro da esquiva ainda é quase a pose de antes; tocar a esquiva sem
  mistura (`_anim.play(&"Dash", 0.0, DASH_CLIP_SPEED)`); (3) **GF-15** e **VX-17** são desenho no `player.gd`: a UAL 1 e
  2 não têm clipe de arranque nem de parada (só `Jump_Start`, `Jump_Land`, `Slide_Start`); proposta: arranque e parada
  como mistura de 0,1 s com inclinação do tronco pelo `Player` e a pose final do finalizador segurando a última pose
  do clipe em vez de voltar à guarda (`recover_anim`).

## Passe de VFX, Lote 1 e fila do HB (technical-artist, 2026-11-20)
Evidência em `docs/gallery/vfx_pass/` (antes em `docs/art/shots/vfx_pass_before/`), `docs/gallery/hb/` e
`docs/gallery/hb/ink_crowd/`. RTX 1920 x 1080, estilizado, semente 5.
- P0 feito, luz sobre o que se pega (`RewardShaft`): colunas no matiz da tabela a até 3 graus, saturação p50 até 0,26,
  maior canal p99 159 (`shafts_sheet_stylized.png`, também `_classic` e `_compat`). Falta ligar no jogo
  (gameplay-engineer) e medir a poça contra um chão de sala (o chão do laboratório é claro demais, 105).
- P0 feito, partículas: nenhum `CPUParticles3D` no `Fx`, nenhum ponto redondo; teto premul de 226 nas lascas.
- P0 feito, orbe e virote com núcleo escuro: aro a 0,62 ia a 248 a 255 na tela (a curva satura o magenta); a 0,21,
  p99 180 a 185, nada acima de 210, matiz 313 (spec 320 a 355: cor do gameplay-engineer); anel de fumaça no golpe que cai.
- P0 feito, V-01 a V-05 e V-16 (ver CLAUDE.md). Fita do giro sem anel fechado (`h_spin.png`); estalo do contato visível
  (`s_hit.png`). A estocada saiu primeiro como lâmina da largura inteira do golpe (lia como folha verde) e foi afinada
  a 0,4 da largura (`s_omega.png` recapturada).
- Medido: fita do giro matiz p50 135 e p99 226; estalo até 225; foice e Ceifa matiz p50 250 a 254 sem ciano no setor.
  Falta: o corte comum sobre Morvath (as capturas pegaram o especial) e a explosão do corredor (`e_runner.png` pegou o aviso).
- HB3: verde na caixa do herói 0,61% para 1,00% (meta 1%), Emeth matiz 130.
- Tinta: com 12 inimigos na Perto, Alta e Média, nenhuma borda nas figuras nem sobre as barras.
- Santuário (pedido do Game Director): osso do esqueleto p50 85 para 74 contra o calcário 96 a 108 (corpo um quarto
  mais escuro no estilizado, `crowd.gdshader`).
- Sonda de sensação 41/41; GUT 1356 com `test_mix` instável (passa na segunda rodada, áudio).

## Passe de VFX, correções do Lote 1 e Lote 2 (technical-artist, 2026-11-20)
Evidência em `docs/gallery/vfx_pass/` (`fix_*`, `l2_*`), RTX 1920 x 1080, estilizado, semente 5. Maior canal na tela
(teto 226; p99 / máximo / acima de 226 / branco, todos os canais acima de 235):
- P1-1 estalo sobre Morvath (`fix_boss_contact.png`, caixa 80 x 80): máximo 209, nada acima de 226, branco 0%.
- P1-2 traço branco: era o talho somado visto de ponta; branco na multidão 6,7% (caixa do talho) para no máximo 0,03% do quadro.
- P1-3 aro do brilho fora do corpo (`fix_glint_ring.png`); P1-4 lascas de luz nunca acima de 1,9 m.
- P1-5 Morvath no golpe forte (`fix_boss_flash.png`): pisca violeta, matiz 281; o branco que sobra é a coroa clara dele,
  já em repouso (p99 239, 0,26%), da pintura do modelo.
- V-09 Corte do Juízo (`l2_ult_cleave.png`, caixa 800 x 350): p99 220, acima de 226 0,66% (os números de dano e o HUD
  dentro da caixa), branco 0,03%. V-10 Voragem (`l2_ult_vortex.png`): matiz do disco 174 para a faixa ciano 36% para
  0,2%, saturação p50 0,41 para 0,27 (meta 125 a 150 ainda não: o petróleo do chão puxa a média para 170). Tempestade de
  Morvath com as almas novas (`l2_storm_souls.png`): p99 217 a 230, branco 0,01%.
- Falta capturar: cada família com as Bênçãos (`--boon-ids=`), a elite surgindo na sala (a sala do guardião não tem elite
  nos primeiros 3 s), V-06 núcleo a 8 a 12 m.

## AP-2 "Combate que se lê" (technical-artist, 2026-11-21)
Evidência em `docs/gallery/ap2/`. Os quadros `*_cpu` saíram do Forward+ no lavapipe, a 1280 x 720, com a semente 5:
a GPU ficou ocupada pelas outras frentes. Os quadros sem sufixo são da RTX a 1920 x 1080. Vermelho é a faixa "red" do
`tools/frame_stats.py --hue --scene`.
- ART-05.2, erupções da fase 3 (`--start=boss --boss-hp=0.3 --boss-only=eruptions`, a cada 0,1 s). Antes, o vermelho
  da cena subia de 0,9 a 2,7% até 70% do aviso. Com `fill_early` 0,25 ficou entre 0,9 e 1,4% na primeira onda e até
  1,9% na segunda, que tem mais discos. Com `fill_early` 0,12 (o valor final), fica entre 0,8 e 1,1% fora dos últimos 30% nas duas ondas
  (`art05_2_eruption_before_after_cpu.jpg`; meta: abaixo de 1,5%). Nos últimos 30% do aviso o vermelho segue igual: 4,2 e 4,8% no pouso. Depois do pouso o vermelho some em
  0,2 s: 0,8% contra 1,9% antes. A cena sem aviso fica em 0,7 a 0,9% (velas e lanternas).
- ART-05.3: o herói atrás de Morvath aparece inteiro pelo raio-x, com o anel (`art05_3_*`, RTX).
- ART-09.1: elites na luta (estilizado, RTX, `art09_1_*`). Esqueleto elite com luma p50 82 e 51,4% de quente, contra o
  grupo comum com 45 a 51 e 16,6 a 31,5%.
- V-08: silhuetas de tinta na esquiva (`v08_dodge_ghosts_sty_cpu.jpg`). Quatro silhuetas cinza-tinta atrás do herói,
  sumindo em 0,12 s.
- Famílias com as Bênçãos (`family_*`): Chama com línguas e estalo âmbar, Geada com a casca facetada. As juntas da casca
  ficaram mais finas e mais fracas (`frost_seam` 0,22 / 0,36 / 0,46, `frost_seam_from` 0,455), porque a 720 a casca lia
  como rede branca. Luz e Vigília só com Bênçãos de dano não tingem o corte: o `Combat.color_of` olha só tags e
  estatísticas de fogo e gelo (gameplay-engineer).
- Elite surgindo na sala (`surge_guardian_room_sty_cpu.jpg`): o Cavaleiro se ergue no Santuário com o anel de fumaça
  fechando e a borda de ouro.

## P1-1, aquecimento dos shaders (technical-artist, 2026-11-21)
- Evidência: `tools/frame_spikes.gd` na iGPU, 1280 x 720 Baixa, robô, semente 5, `--smoke=420 --fast=2`.
- Antes (QA A8): entrada de sala até 17,6 s com o cache vazio e 0,5 a 1,9 s com ele quente; golpes de 0,5 a 3,3 s.
- Depois, cache vazio: aquecimento de 33,8 s (exe: 133 s); quadros de jogo acima de 50 ms só 4 (132, 106, 56, 55 ms).
- Depois, cache quente: aquecimento de 1,9 s; um quadro de 117 ms na Câmara.
- P1 que fica: o 1º quadro de cada sala, já na tela preta, é a montagem dela (0,16 a 0,77 s quente, 0,28 a 1,4 s frio,
  também ao voltar a uma sala já vista), do gameplay-engineer e do environment-artist.
- P1 que fica: no exe com o cache vazio o aquecimento leva 2 min 13 s na iGPU (só na primeira vez; o Shader Baker não
  muda isso, a compilação é do driver).
- Conjunto: `assets/warmup/warmup_set.res`, 31 KB.

## Melhorias propostas (maior ganho por esforço primeiro)

### Técnicas (posso fazer sem pedir; medir antes e depois, captura na GPU)
1. **Excluir do pacote as fontes dos assados** (P1-2): três linhas no `exclude_filter`. -13,8 MB no exe, nenhum risco
   visual. Esforço: minutos.
2. **Uma paleta do KayKit só, em VRAM** (P1-1): -106 a -111 MB de VRAM e -2,5 MB de pacote. Esforço: uma tarde
   (import ou troca da textura onde a peça é montada) mais captura de todas as arenas.
3. **Texturas do herói e da Emeth em VRAM (S3TC), a Emeth em 1024** (P1-1): de 48 para cerca de 4 a 6 MB de VRAM, -8 a
   -10 MB de pacote. Esforço: `.import` e reimport, mais captura de perto do herói (`--showcase`, `--shot-on=swing`).
4. **Normal da rocha em BC5 e altura em BC4**: de 6,6 para cerca de 2 MB de VRAM, -1,9 MB de pacote; conferir o
   relevo do chão e da cantaria na captura.
5. **Armas `held` reduzidas no assado** (P2-2): -1 600 triângulos no feiticeiro e no ancião, imagens de pose menores
   (~10% nesses dois). Reassar e comparar quadros.
6. **Reassar Morvath** junto com o próximo assado (P2-1) e tirar a estátua do `MODELS` (P1-2).
7. **Ferramenta de auditoria no fluxo**: rodar `tools/asset_probe.gd` e a tabela do PCK a cada entrega e comparar
   com este relatório (assados, música, exe).

Somando 1 a 4: exe de 219,7 para cerca de 192 MB; VRAM das texturas medidas de ~255 para ~95 MB (o maior que sobra são
as imagens de pose dos assados, 79 MB).

### Mudam a aparência (precisam do art-director)
1. **Medalhões pintados para as 25 Bênçãos que não têm** (7 de 32 hoje): a tela de cartas mistura pintado e
   desenhado. Recorte técnico pronto (`tools/cut_medallions.gd`, modo grade); falta a prancha aprovada.
2. **Herói reduzido** (P2-4) se o quadro na iGPU pedir: perda de detalhe a julgar de perto.
3. **Retrato do Livro de Ahk em resolução maior** (P2-7), se a captura a 1080 mostrar o borrão.
4. **Cenário do KayKit provisório**: o que ainda aparece dele (paredes, escadas, pilares, entulho, estandartes) é o
   próximo passo de fidelidade; os modelos que faltam estão em `docs/art/meshy_asset_plan.md`.

### Gastam créditos do Meshy (precisam do Daniel; sobram 546)
1. **Repintura das elites** (10 créditos cada, 6 tipos com elite = 60): hoje o ouro é por shader na mesma figura.
2. **Armas próprias dos inimigos** (cajado, besta, cutelo, foice de Morvath: ~4 x 20 a 30 créditos), no lugar das do
   KayKit repintadas, que são o paliativo do `SWATCHES` e o excesso de triângulos do P2-2.
3. **Peças de cenário do plano** (`docs/art/meshy_asset_plan.md`) para trocar o KayKit nas salas.

## Como repetir as medidas
- Pacote: `~/tools/godot/godot --headless --path . --export-release "Windows Desktop" build/windows/ASelagem.exe`
  (2,7 s com o cache), depois `python3 -I tools/pck_sizes.py build/windows/ASelagem.exe [--files]` (lê o PCK embutido
  e liga cada `.godot/imported/...` à fonte pelo `path=` do `.import`). Apagar o `build/` do worktree depois.
- Uso real: `~/tools/godot/godot --headless --verbose --path . --fixed-fps 60 -- --bot --nosave --smoke=25 --arena=X
  --variant=N` e `grep "Loading resource"`.
- Modelos: `~/tools/godot/godot --headless --path . -s tools/asset_probe.gd -- baked` e `-- scenes`.
- VRAM: `tools/gpu.sh run --rendering-driver vulkan -s tools/asset_probe.gd -- vram`.
- Som: `ffmpeg -nostats -i f.ogg -af ebur128=peak=true -f null -` (LUFS e dBTP); a mistura do jogo segue em
  `tools/mix_probe.gd`.

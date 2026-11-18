# Relatório de assets (artista técnico)

Auditoria inicial, 2026-11-18, HEAD `d458633` do `arpg-3d`. Inventário completo em `docs/art/asset_inventory.md`.
Nada foi apagado nem alterado nesta auditoria; as únicas adições são as ferramentas de medida `tools/asset_probe.gd`
(modelos, assados, VRAM) e `tools/pck_sizes.py` (o que entra no exe e quanto pesa).

Classificação: **P0** quebra o jogo, a licença ou a entrega; **P1** custa caro (memória, pacote, risco) e tem
correção técnica clara; **P2** limpeza, documentação ou ganho pequeno.

## Resumo dos números

| Medida | Valor | Teto | Como |
|---|---|---|---|
| Exe do Windows | **219,7 MB** (modelo da Godot 109,3 + PCK 110,4) | | export `"Windows Desktop"` no worktree, `ls -l` |
| PCK por família | assados 43,92; música 17,22; bonecos do KayKit 11,38; herói 8,27; Emeth 6,99; UI 6,19; texturas 3,91; ambiência 3,01; UAL 2,18; `dungeon_r` 2,17; `dungeon` 1,46; efeitos 1,30; scripts 1,24; fontes 0,35; shaders 0,28; armas 0,20 MB | | `python3 -I tools/pck_sizes.py build/windows/ASelagem.exe` |
| Assados | **43,92 MB** | 70 MB (63%) | `du -cb assets/baked/*.res` |
| Música no pacote | **17,22 MB** (16,57 no disco: o `.oggvorbisstr` soma 4%) | 18 MB (96%) | PCK |
| VRAM das texturas carregadas | herói 28,5; Emeth 19,4; relevo da rocha 5,3 + 1,3; título 8,8; medalhão de 512 1,3; **21 peças do KayKit 112,0**; assados 79,0 MB | | `tools/gpu.sh run --rendering-driver vulkan -s tools/asset_probe.gd -- vram` (RTX 5060, `RENDER_TEXTURE_MEM_USED`) |

## P0

Nenhum. O pacote não leva nada de origem desconhecida, toda música e todo efeito CC BY está no `CREDITOS.txt` e no
`audio/LICENSES.md`, a arte de IA que vai no jogo está no `docs/steam-ia.md`, todo efeito sonoro e todo shader têm
uso, e não há `.import` órfão.

## P1

**P1-1. As texturas 3D vão sem compressão de vídeo; 21 cópias da mesma paleta ocupam 112 MB de VRAM.**
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

**P1-2. Fontes dos assados entram no pacote: 13,8 MB que o jogo nunca carrega.**
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

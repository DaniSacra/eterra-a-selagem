# Assets, fim do ciclo de 2026-11-18 (artista técnico)

HEAD `dd1f5ba` (`arpg-3d`). Base: `docs/qa/asset_report.md` (auditoria e C1) e `docs/art/asset_inventory.md`.
Nada foi alterado nesta rodada; medidas novas só por `git log`, `stat`, `du` e leitura dos presets.

## Resumo
1. Nenhum P0. Resta um P1, a licença dos modelos do Meshy (P1-3), que só o Daniel resolve (plano gratuito ou pago em 2026-11-15).
2. A C1 entrou: exe de 219,7 para 197,2 MB, texturas 3D medidas de 161,4 para 10,0 MB de VRAM, sem diferença visível nas capturas na GPU.
3. Hoje o corredor foi reassado (`40d6618`, `Jog_Fwd` com pé travado, 3,2 cm de escorregamento). Os assados somam 43,91 MB (63% do teto de 70). Morvath ficou agora dois commits atrás do `tools/bake.gd`.
4. Livro de Ahk e etapa 1B não trouxeram imagem nova depois da auditoria. O único raster é `warrior_page.png` (330 x 400, já no P2-7); a 1B só acrescentou o shader `book_page.gdshader`, que está no inventário.
5. As 10 melhorias abaixo vão do maior ao menor ganho. As 5 primeiras são técnicas e eu faço sozinho em cerca de um dia; 3 dependem do art-director ou do environment-artist; 1 gasta créditos do Meshy (até 195 dos 546).

## O que mudou desde a auditoria
| Item | Antes | Agora | Evidência |
|---|---|---|---|
| `runner.res` | 3 646 644 B, `Running_B` do KayKit (no ar em 14 de 20 poses) | 3 639 463 B, `Jog_Fwd` da UAL com `RUNNER_JOG` (0 de 20 no ar, 171 passos por minuto) | `git show --stat 40d6618`; `docs/qa/t5b_boss_fight.md` 7; `docs/gallery/t5b/runner/` |
| Assados (soma) | 43,92 MB | 43,91 MB | `du -cb assets/baked/*.res` |
| Frescor dos assados | 8 em `5aeee46`, Morvath em `6338417` | o `bake.gd` está em `40d6618`. Ali só entrou o `RUNNER_JOG` e a linha do corredor, então os outros 8 continuam em dia. Morvath segue de fora (efeito nulo hoje: não usa `rise`) | `git log -1 -- assets/baked/*.res tools/bake.gd`, `git diff 1a6851f 40d6618 -- tools/bake.gd` |
| Inventário | linha do corredor com `5aeee46` e 5 304 vértices | desatualizada: o commit agora é `40d6618`; vértices e triângulos a reconferir pela `asset_probe.gd -- baked` | `docs/art/asset_inventory.md:50` |
| Exe | 197,2 MB (C1) | sem nova exportação; a variação estimada é de -7 KB | |

## Abertos
### P0
Nenhum.

### P1
- **P1-3. Licença do Meshy sem registro.** Herói, Emeth e nove inimigos vão no pacote. O `CREDITOS.txt:17` diz só "gerados com o Meshy", e nem o `docs/steam-ia.md` nem o `asset_credits.md` dizem em que plano foram gerados. No plano gratuito a licença é CC BY 4.0 e exige crédito; no pago, o modelo é do usuário. Precisa de uma resposta do Daniel, que eu anoto nos três documentos. Bloqueia a Steam se a resposta for "gratuito" e o crédito continuar faltando.

### P2
- **P2-1. Morvath atrás do `bake.gd`** (agora dois commits). O efeito é nulo hoje. Custa 5 minutos para reassar.
- **P2-2. Armas `held` acima do orçamento.** Feiticeiro com 5 530 triângulos, ancião 5 557, Cavaleiro 4 956, contra 3 900 do corpo. O cajado do KayKit soma cerca de 1 600.
- **P2-3. Pé do ancião 8 cm abaixo do chão** no repouso (`idle_floor` -0,081). Ainda não conferi numa captura de perto se é a barra do manto.
- **P2-4. Herói com 30 741 triângulos.** Não é gargalo medido; só mexer se a iGPU pedir.
- **P2-5. Peças do KayKit que nunca carregam.** São 8 de 26 em `dungeon/` e 40 de 43 em `dungeon_r/`, cerca de 2,0 MB no PCK, e 18 delas estão duplicadas entre as duas pastas. Depende do environment-artist.
- **P2-6. Margem da música: 0,78 MB.** O PCK leva 17,22 MB contra o teto de 18. O `CLAUDE.md` diz "16,6 hoje", que é o tamanho no disco (16,57 MB), não no PCK.
- **P2-7. Retrato do Livro de Ahk** em 330 x 400, sem mipmaps e com filtro linear. Ainda não medi se aparece maior que 330 px a 1080.
- **P2-8. Documentos de licença incompletos** (sem mudança desde a auditoria):
  - `asset_credits.md` ainda credita o som só a "Kenney Impact Sounds";
  - o `CREDITOS.txt` não cita os medalhões dos eventos nem o retrato do Livro de Ahk;
  - o `steam-ia.md` não lista a ambiência nem o `title_fill.png`, e a lista "Sem IA" está incompleta.
- **P2-9. Lixo** (confirmado no HEAD):
  - `.gutconfig.json` entra no PCK pelo `include_filter="*.json"`;
  - `lion.svg` entra no PCK como textura;
  - `addons/gut/menu_manager.gd.uid` ficou órfão;
  - `hero_sombra/` (32 MB) e `paladin_1/` (28 MB) estão no repositório sem uso, mas o `CLAUDE.md` diz que ficam guardados;
  - há paletas e texturas duplicadas fora do pacote.
- **Melhorias 5 a 7 da auditoria** (armas reduzidas, reassar Morvath, auditoria no fluxo): nenhuma foi feita. Estão nos itens 2, 3 e 4 abaixo.

## As 10 melhorias de maior ganho
| # | Melhoria | Quem | Custo | Ganho | Critério de aceite |
|---|---|---|---|---|---|
| 1 | Fechar a licença do Meshy (P1-3) e corrigir os créditos (P2-8) | Daniel responde; eu edito `CREDITOS.txt`, `audio/LICENSES.md`, `asset_credits.md`, `steam-ia.md` | 1 pergunta e 30 min | tira o único P1 e o risco na Steam | cada modelo do Meshy no pacote com plano e licença escritos; todo CC BY nos dois arquivos de crédito; toda arte e todo código de IA no `steam-ia.md`; grep cruzado entre pacote (`pck_sizes.py --files`) e créditos sem sobra |
| 2 | Armas `held` reduzidas no assado pelo `MeshSlim` (P2-2) | eu | 2 a 3 h, reassar 3 figuras | cerca de -1 600 triângulos no feiticeiro e no ancião; cerca de 10% a menos nas imagens de pose deles (cerca de -1 MB de assados) | toda figura com no máximo 4 100 triângulos (`asset_probe.gd -- baked`); `test_held_weapons.gd` e `test_living_crowd.gd` verdes; captura do `enemy_lab.gd mage priest_elder knight` antes e depois sem diferença de silhueta a 1080 |
| 3 | Reassar Morvath (P2-1) | eu | 5 min mais testes | assados todos em dia com o `bake.gd` | `test_boss_body.gd` verde; `tools/pose_drift.gd` com no máximo 0,45 m; data do `morvath.res` igual ou posterior ao último commit do `bake.gd` |
| 4 | Auditoria de assets no fluxo: um teste GUT que falha com assado mais velho que o `bake.gd`/`bake_hero.gd` ou com o modelo de origem, assados acima de 70 MB, música acima de 18 MB (contando os 4% do `.oggvorbisstr`) ou figura acima do teto de triângulos | eu | 2 h | impede regressão silenciosa (o caso de Morvath, o teto da música) | o teste falha no estado de hoje (Morvath) e passa depois do item 3; corre em menos de 2 s no `tools/test.sh` |
| 5 | Limpeza do pacote e do repositório (P2-9) | eu; a remoção de `hero_sombra/` e `paladin_1/` pede o sim do Game Director, porque o `CLAUDE.md` diz que ficam guardados | 30 min | PCK sem arquivo de fora (`.gutconfig.json`, `lion.svg`); até -60 MB no repositório | grep sem uso em `scripts/`, `data/`, `scenes/` listado no relatório; `pck_sizes.py --files` sem esses arquivos; `--import`, `test.sh` e `check.gd` verdes |
| 6 | Folga para música nova (P2-6): reencodar as faixas do MacLeod numa qualidade Vorbis um passo abaixo, ou tirar do pacote uma peça que ninguém escolhe | eu meço; o Daniel decide se alguma peça sai | 1 h | de 0,78 MB para cerca de 3 MB de folga | LUFS e dBTP iguais em até 0,2 (`ebur128`, `Loudness`); laço sem emenda (`test_mix.gd`); comparação às cegas sem diferença audível; música no PCK com no máximo 15,5 MB; corrigir o "16,6" do `CLAUDE.md` |
| 7 | Peças do KayKit sem uso fora do pacote; tirar as 18 duplicadas entre `dungeon/` e `dungeon_r/` (P2-5) | environment-artist confirma; eu faço | 1 h | cerca de -2 MB no PCK, menos confusão de qual peça usar | traço `Loading resource` de todas as arenas e variantes e do `--horde` sem nenhuma peça excluída; captura de cada arena igual antes e depois |
| 8 | Retrato do Livro de Ahk (P2-7) e pé do ancião (P2-3): medir e corrigir | eu meço; art-director aprova um recorte novo da prancha | 1 h para medir, mais 1 h se precisar recortar | nada borrado a 1080; pé no chão | captura `--title --screen=hero` a 1080 com o retrato desenhado em no máximo 1 vez o tamanho da fonte, com mipmaps se for reduzido; captura de perto do ancião com a sola visível a menos de 3 cm do chão (ou o manto justificando a medida) |
| 9 | Medalhões pintados das 25 Bênçãos que faltam (7 de 32 hoje) | art-director aprova a prancha (IA, registrar no `steam-ia.md`); eu recorto com `tools/cut_medallions.gd` | 1 a 2 pranchas e 2 h de recorte | a tela de cartas deixa de misturar pintado e desenhado | 32 de 32 com PNG de 384 px com mipmaps; aro e fundo limpos a 720 e 1080 (captura `ui_lab.gd --card-only`); só leão como símbolo do herói, nada de cruz nem sol; UI no PCK com menos de 3 MB a mais |
| 10 | Meshy, por ordem: estátua encapuzada do plano (15 créditos), armas próprias dos inimigos (cajado, besta, cutelo, gancho de Morvath, cerca de 4 x 30 = 120) e repintura das elites (6 x 10 = 60) | Daniel autoriza; art-director aprova a forma; eu preparo pelo pipeline do `bake.gd` | até 195 dos 546 créditos e 1 dia por lote | troca o paliativo dos `SWATCHES` e do ouro por shader; a estátua é a peça que mais aparece no salão | prompt e plano escritos antes em `tools/meshy/prompts.json` e `meshy_asset_plan.md` (o saldo de lá ainda diz 6 créditos, corrigir); cada modelo com no máximo 3 900 triângulos (figura) ou 300 (arma), atlas de 1024, licença anotada; assados abaixo de 50 MB; captura na GPU antes e depois |

Ficam fora da lista: o herói reduzido (P2-4), que só entra se a iGPU apertar, e o BC1 no herói, recusado na C1 por manchas de bloco.

## Pendências de documento para depois desta rodada
- Inventário: atualizar a linha do corredor com `40d6618` e os números da `asset_probe.gd`.
- `docs/art/meshy_asset_plan.md`: o saldo diz 6 créditos; o real é 546.
- `CLAUDE.md`: a música no pacote ocupa 17,2 MB, não 16,6.

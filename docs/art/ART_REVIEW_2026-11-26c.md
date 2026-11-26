# Revisão de arte: efeitos do Lote 1 e do GP-3 (2026-11-26c)

Revisor: art-director. Base: pacote `docs/design/packs_2026-11-26/vfx/` (direção "tinta em movimento", matriz Q01 a Q10),
`docs/art/art_direction.md` (cores reservadas, cruz e sol proibidos), `docs/reference/art_fx.md` (Lote 1 e GP-3).
Capturas reais da GPU (Forward+, estilizado, câmera Perto), `docs/gallery/lote1_2026-11-26/`:
`before_hit.png`, `after_hit.png`, `before_reward.png`, `gp3_families.png`, `gp3_boss_phase4.png`, `gp1_hud_720.png`,
`after_hub_arrive.png`. Nenhuma captura mostra as formas de chão novas (Véu, Maré, Marca, Peste, Trovão) nem um ataque
de Morvath: o que depende delas fica **pendente**, não aprovado.

## O que passa

| Item | Captura | Estado |
|---|---|---|
| Q01 contato sem disco branco | `before_hit` x `after_hit` | **corrigido**. O disco branco de cerca de 60 px (que estourava e lia como cruz com os traços horizontais) sumiu; no lugar, núcleo escuro pequeno e 3 a 5 traços verdes num leque para o lado da lâmina. Sem cruz. |
| Esmeralda só da Emeth | `after_hit`, `gp1_hud_720` | **confirmado**. Lâmina, corte e contato no mesmo verde; nenhum inimigo verde. |
| Herói legível no golpe sem Bênção | `after_hit`, `gp1_hud_720` | **confirmado**. O corte afasta o miolo do corpo (`SLASH_BODY_CLEAR` 1,0 m); cabeça e tronco visíveis. |
| Q08 facho de recompensa | `before_reward` | **passa** como leitura: coluna marfim difusa, quase sem borda, pousa no pedestal, nada parecido com nascimento de inimigo. Falta o "depois" (ver capturas). |
| Violeta só de Morvath (combate) | `gp3_boss_phase4` | **confirmado** na sala do chefe: manto, foice, barra e lanternas violeta; herói e Emeth sem violeta. |
| QW-1 números | `after_hit` | **passa**: "55" e "15" lado a lado, não empilhados. |
| Santuário | `after_hub_arrive` | fora do combate; o lilás do mar de nuvens e das glicínias foi aprovado no PM-2 e não concorre com Morvath (não há luta ali). Sem pedido. |

## O que reprova ou fica pendente

### P1 (corrigir antes do teste do Daniel)

**P1-1. O contato lia como retícula ou olho** (`after_hit`, e mais forte em `gp3_families` com a Marca, onde o anel dourado
em volta do ponto escuro vira mira). A direção pede "estalo angular assimétrico, núcleo escuro, sem anel perfeito", e a
Marca "nunca retícula". **Corrigido nesta revisão** (só constantes de tamanho, CLASSIC igual):
- `scripts/game/fx.gd` `CONTACT_INK_CORE` 0,14 para 0,10 m (o núcleo vira semente sob os traços);
- `assets/shaders/contact.gdshader`, ramo `ink`: aro fino até 1,12 do raio (era 1,25); raiz dos traços 0,075 m (era 0,05;
  o ramo clássico segue 0,05).
- Critério: na próxima captura `--shot-on=hit`, os traços dominam (mais área que o núcleo), o aro mede no máximo 2 px a
  1080p, e numa cópia em cinza ninguém descreve "alvo" nem "olho".

**P1-2. O corte com Bênção cobre a cabeça do herói** (`gp3_families`: a faixa amarelo-palha da Marca passa sobre a cabeça e o
ombro). O `SLASH_BODY_CLEAR` só vale para o corte sem família (`own` em `Fx.slash` limpa o miolo, mas a faixa clara e o
fio com cor de família continuam). Responsável: **technical-artist**. Mudar em `Fx.slash`: aplicar `body_clear_m` também
quando `family >= 0` e, no `slash_ink`, a mesma limpeza perto do herói. Critério: em `--boons=25 --shot-on=hit`, cabeça e
tronco do herói sem nenhuma faixa de efeito por cima em 3 quadros seguidos.

**P1-3. Cor da Marca no corte.** A Marca é bronze/oliva escuro (`Boon.FAMILY_COLOR` 0,70/0,62/0,30), mas o corte sai
amarelo-palha claro, perto da Luz (1,0/0,92/0,7): o fio branco e o pico de tela clareiam a cor de família. Responsável:
**technical-artist**, `Fx.slash`, `style_peak` com `lit.lerp(Color.WHITE, 0.3)` para família; usar 0,1 para Marca e Véu.
Critério: em cinza e em cor, a faixa da Marca mais escura que a da Luz na mesma captura (valor medido no miolo pelo menos
0,15 abaixo).

**P1-4. Trovão podia ler como sol** (código, sem captura): 6 raios a cada 60 graus, todos do mesmo tamanho, nascendo de um
anel, com clarão amarelo nos primeiros 0,05 s. Raios iguais em volta de um centro com amarelo é o sol, proibido mesmo em
glifo. **Mitigado nesta revisão** em `assets/shaders/family_mark.gdshader` (forma 8): espaçamento irregular (mais ou menos
0,8 rad em volta das sextas partes, era 0 a 0,8) e comprimento de 0,65 a 1,0 do raio por raio. Continua **pendente de
captura**. Critério: nos quadros de 0,02 s e 0,2 s da forma 8, nenhum par de raios opostos alinhado e nenhum leitor descreve
"sol" ou "estrela"; se descrever, cortar para 4 raios e trocar `TROVAO_FLASH` por um branco frio (exige mudar o teste
`test_gp3_families`, decisão do Game Director).

**P1-5. Trovão x raio da Maga** (identidade): a forma 8 é "zigue-zague segmentado com bifurcação", exatamente a gramática do
raio da Maga (`ElementLook.VOLT` 1,0/0,97/0,78), e o clarão `TROVAO_FLASH` (#F1E08A) é quase o mesmo amarelo. Quando a Maga
voltar, as duas leituras colidem. Pergunta ao Game Director: a família Trovão fica com o Guerreiro? Se sim, recomendo
Trovão em ardósia com faíscas que caem (de cima para o chão, peso) e reservar o zigue-zague horizontal e o amarelo para a Maga.

### P2

- **P2-1. Corte da Emeth chapado** (`after_hit`, `gp1_hud_720`): o leque verde é quase uniforme com fio branco contínuo, perto
  do "feixe uniforme e anel perfeito" proibido para a Emeth. Responsável: technical-artist, `SLASH_PAINT` 0,75 e textura de
  pincel em `slash.gdshader`. Critério: falhas e variação de valor visíveis no corpo do leque a 720p; o fio externo com
  pelo menos 2 interrupções no arco.
- **P2-2. Número de dano de família com pouco contraste** (`gp3_families`: o "15" oliva quase some no chão claro). Os números
  diretos não usam o contorno dos números de dano ao longo do tempo (`TICK_OUTLINE` 3). Responsável: ui-ux-designer ou
  technical-artist, `Fx.number`: contorno de 2 px também nos diretos com cor de família.
- **P2-3. Véu e a reserva da esmeralda**: `Fx.tick_color` troca cor de saturação abaixo de `TICK_MIN_SAT` 0,3 pelo verde
  `TICK_FALLBACK`. O Véu (0,76/0,70/0,64, saturação 0,16) cai nessa regra: um dano ao longo do tempo do Véu sairia verde
  da Emeth. Se o Véu tiver dano ao longo do tempo, o fallback dele deve ser âmbar apagado. Responsável: technical-artist.
- **P2-4. Selo dourado no chão da Câmara** (`gp3_boss_phase4`): estrela de 8 pontas com círculo, em ouro, em volta de Morvath.
  Não é efeito e não é desta frente (cenário), mas de cima lê perto de um sol. Pergunta ao Game Director para o
  environment-artist: manter (é o selo, já aprovado?) ou quebrar a simetria das pontas.

## O que esta captura não prova (Morvath fase 4, Q07)

`gp3_boss_phase4` mostra o chefe parado e o selo; não aparece meia-lua de alma, orbe com borda suja, foice corroída nem
aviso vermelho. **Pendente**: aviso vermelho legível na fase 4, meia-lua violeta distinta do corte verde, borda suja dos orbes.

## Capturas que faltam (sessão principal, uma por vez)

1. Contato depois da correção P1-1:
   `tools/gpu.sh shot <scratch>/hit_ink.png --bot --autopick --seed=5 --shot-at=5 --shot-on=hit --shot-after=0.02`
2. Morvath fase 4 com ataque e aviso:
   `tools/gpu.sh shot <scratch>/boss4_scythe.png --bot --start=boss --boss-hp=0.2 --shot-at=6 --shot-on=boss:scythe_strike`
   e `--shot-on=boss:blades_fire` (meias-luas e orbes). Repetir uma com `DRIVER=opengl3 tools/shot.sh` (Compatibility, Q07).
3. Recompensa depois do PM-1(b): `tools/gpu.sh shot <scratch>/reward_after.png --bot --autopick --seed=5 --shot-at=5 --shot-on=reward`.
4. Famílias no golpe: `tools/gpu.sh shot <scratch>/fam_hit.png --bot --boons=25 --seed=5 --shot-at=8 --shot-on=hit --shot-after=0.02`
   (repetir com 2 ou 3 sementes até aparecerem Véu, Maré e Marca).
5. **Peste e Trovão**: hoje não há como capturar. `Boon.Family` ainda não tem PESTE nem TROVAO (`Fx.form_of` dá -1 e cai no
   anel simples) e o `--lab` só congela um corte. Pedido ao technical-artist (só ferramenta de captura, sem gameplay): uma
   opção `--lab-form=N` no `_lab` de `game.gd` que chama `fx.form_mark(N, centro, 2.5, cor, Fx.FORM_TIME[N], dir, 360)` ao
   lado do herói e congela em `--lab-t`. Então, para cada forma 4 a 8:
   `tools/gpu.sh shot <scratch>/form8_t02.png --lab --lab-form=8 --lab-t=0.05 --lab-count=0 --shot-at=3`,
   o mesmo com `--lab-t=0.5` (meio da vida) e uma cópia de cada em cinza (`ffmpeg -i x.png -vf hue=s=0 x_gray.png`) para o
   critério "silhuetas distintas sem cor" (Q05). Peste: conferir que o miolo carvão não lê como poça de perigo e que o
   enxofre não lê como âmbar de perigo ambiental. Trovão: critério do P1-4.

## Veredito

Contato da Emeth, reserva do verde e do violeta, e o facho (antes) passam. **Não aprovado para teste do Daniel** ainda: o
corte com Bênção cobre o herói (P1-2) e a Marca não tem a cor dela (P1-3); as formas de chão novas e a fase 4 de Morvath
não têm captura que as mostre; Peste e Trovão precisam da opção de captura acima e da decisão sobre Trovão x raio da Maga.
Os efeitos são procedurais (shaders), não provisórios de asset; nenhum depende de modelo Meshy.

# Combate C1: leitura na tela (especificação do diretor de arte, 2026-11-22)

Base: código do lote C1 no disco (sem commit), `docs/art/review_2026-11-21b.md` (GR-5 a GR-7) e `docs/gallery/` (`review_2026-11-21b/`, `lote_visual/guard.jpg`,
`enemies_2026-11-19/`). Nenhuma captura nova: o que depende de ver em jogo está em "Aceite". Responsável: `technical-artist`, salvo indicação. Números são de partida. Régua: 0,04 m = 1,6 px a 1080 na câmera Perto. **Nada aqui muda dano, tempo ou RESULT**, salvo onde está escrito "gameplay decide".

## 1. Vocabulário (uma cor, um significado)
| Cor | Só quer dizer | Valor |
|---|---|---|
| Vermelho | área no chão que vai ferir; nunca luz, fio ou contorno de inimigo | `GroundLook.WARNING_COLOR` |
| Ouro velho | blindagem (elite, guardião, quem o sacerdote blinda) | `EnemyFx.OLD_GOLD`, `GILD_COLOR` |
| Aço neutro (novo) | guarda do Escudo, só de frente | `STEEL := Color(0.66, 0.69, 0.74)`, valor final até 0,75 (`EnemyFx.lit` e `toned`) |
| Brasa | corredor morto | `burn_color` e `coal_color` de `crowd.gdshader`, matiz 18 a 25 |
| Esmeralda | Emeth e o herói protegido | `Combat.EMETH` |
| Magenta / violeta | magia dos mortos / só Morvath e o portal | `DEAD_MAGENTA` / `rim_color` dele |

- **Conflito achado**: `DEAD_CRIMSON` (1,4; 0,16; 0,3) é vermelho e é `magic_color` do corredor e do besteiro. No corredor, a explosão usa a cor da seção 4. No besteiro, trocar
  por `Color(1.2, 0.5, 0.16)` (o laranja da prancha de 2026-11-14) em `make_data.gd`, só desenho. `PALE` (1,05; 0,78; 0,74) é rosado: não usar em fio, arco ou marca nova.
- **Ordem quando tudo se sobrepõe**: aviso vermelho no chão, herói, guarda e fio, figura, faísca. Marca nova nunca usa `over` (passa por trás de quem está na frente).
## 2. (a) Escudo: guarda fechada e aberta
Hoje só o estalo e a palavra "Guarda aberta!" contam; o escudo é quase preto sobre chão escuro e o dono dele nem aparece de costas (`fight_hall.jpg`).
- **Condição única**: `Horde.guard_up(e)` = as condições de `blocks_front` sem o ângulo. O desenho e a regra leem a mesma função (inclui RECOVER e desamparado).
- **Pose (distância)**. Fechada: `walk` e `idle` do `guard` em `tools/bake.gd` com `"hold"` de -14 para **-24** (escudo à frente do peito, a espada sai pelo lado). Aberta: clipes
  novos só no `guard.res`: `walk_open` (`Walking_A` + `BRUTE_STRIDE`, `"hold": 38`, escudo para fora, peito à vista) e `idle_open` (último terço de `Idle_Shield_Break`, em laço).
  `Horde.render` troca `walk`/`idle` por `*_open` com `open_t > 0`; a passagem usa o `_fade` de 0,12 s. Golpe e preparo não mudam de clipe. Só reassar `guard`.
- **Marca no chão (fechada)**: cinco `Shape.STREAK` deitados (`EnemyFx._floor`) tangentes a um arco de raio `def.radius + 0,55 m`, de -60 a +60 graus em volta de `face`
  (a regra cobre 75), cada um 0,50 x 0,07 m, `STEEL`, alfa **0,16** longe e **0,42** com o herói a menos de 6 m e dentro do arco. Altura 0,07 m. Lê "muro deste lado".
- **Aberta**: no instante, `tells.armor_break` (já existe) com cor `STEEL`, os cinco traços voam para fora 0,5 m em 0,15 s e somem. Enquanto aberta, nenhum traço. **No último 1,0 s
  eles voltam um a um**, do lado para o meio, a cada 0,2 s: o jogador vê a guarda fechando.
- **Golpe barrado**: `_ward_spark` usa hoje verde-água (`WARD_SPARK`, do ritual de Morvath). Com `front_block`, faísca `STEEL` (5, não 3), som `mat_shield`, número em cinza
  (0,62; 0,62; 0,66), tamanho comum, e o traço do meio acende a 0,8 por 0,12 s. Sem recuo e sem `squash` do corpo.
- **Aceite**: imagem parada de 720 px, Escudo a 8 m, de frente: dizer fechada ou aberta sem texto, 5 em 5. De costas para a câmera o arco ainda aparece à frente dele.
## 3. (b) Sacerdote que blinda: fio e brilho
Hoje o anel e os `wisps` duram menos de 1 s a cada 5 s: depois ninguém sabe quem é de quem. O anel em magenta também parece aviso.
- **Fio** (enquanto `warded_by` vive e `armor > 0`): `EnemyFx._stroke` da palma do sacerdote (`BakedModel.point("hand_l")`, alternando a mão por alvo) ao peito do blindado
  (1,2 x `size`), largura 0,045 m, ouro `toned(lit(OLD_GOLD), 0.55)`, alfa **0,30**, `part` 2 e `over` falso (a tinta só existe na passada por cima). Uma conta (`DOT` 0,18 m, alfa 0,8) corre do
  sacerdote ao alvo em 0,9 s e recomeça: o sentido diz quem dá. Nunca no chão (não confundir com a linha vermelha). Herói a menos de 4 m do sacerdote: fio a 0,55.
- **Brilho de quem está blindado, sem shader novo**: em `Horde.render`, `state.r` fica negativo (o "absorveu" que já existe) entre **-0,20 e -0,34**, seno a 1,2 Hz, e o golpe leva a -1,0
  por `FLASH_TIME`. Contorno e beiradas em ouro velho; a figura segue osso. A barra amarela já aparece sozinha.
- **Não virar elite**: elite tem aço dourado e contorno de 0,05 m parado; o blindado pulsa, tem 0,04 m, tem fio e não tem moldura dourada na barra.
- **Ao blindar**: `fx.ring` fino em ouro velho (0,35 s) no lugar do anel em `magic_color`. **Ao cair o sacerdote**: fios partem do meio para as pontas em 0,18 s e cada um solta o
  `armor_break` que já existe. **Ao quebrar só a blindagem**: o fio desse alvo parte; o sacerdote não reage.
- Teto: 6 fios na tela (2 sacerdotes); o conjunto custa até 12 quads de `EnemyFx.POOL` (320). **Aceite**: sala com 6 vivos e 3 blindados, apontar os 3 e o dono em uma imagem parada.
## 4. (c) Explosão do corredor morto
- **O corpo é o pavio**: em `dying`, com `death_burst > 0` e `dead_t` menor que ele, desenhar com `state.b = 1 + 0.5 * (dead_t / death_burst)` (brasas e beirada de fogo crescendo), tremor
  `windup_shake` de 0,02 a 0,06 m, inchaço `squash` até 1,12, sem afundar e **sem dissolver** (dissolução logo depois da explosão, não aos 0,85 s de sempre).
- **Chão**: o `add_warning` já posto, borda inteira no 1º quadro. Trocar `land_color` para cinza de brasa `Color(0.62, 0.34, 0.16)`; ao explodir `fx.burst(&"fire")`, `smoke_ring` e 8 `chips` de osso.
- **Som**: `tell_ember` no abate (agudo, sobe com o tempo). **Tempo**: 0,6 s é o aviso mais curto do jogo (o de 0,70 s foi queixa do Daniel); arte pede **0,75 s**; gameplay decide.
- **Não empilhar**: com mais de 3 círculos desses vivos, os corpos novos mantêm brasa e borda, com preenchimento a 60%. **Aceite**: ver o círculo inteiro sob 4 figuras; nenhum pixel do corpo vermelho.
## 5. (d) Herói com o Brado que absorve
Hoje: `SHIELD_GLOW` a 0,12, igual ao escudo da Vigília, some sob a maldição; e o golpe absorvido solta `burst(&"heal")`, que é **rosa e quer dizer cura** (erro de leitura, P1).
- **Anel dos pés** (`_ring_look` e `_ring_through`): `color` de `RING_COLOR` para esmeralda `Color(0.30, 0.78, 0.45)`, `open` 0,35 para 0,62, `band` 0,09 para 0,15, em 0,12 s. Vale também sob maldição.
- **Corpo**: brilho `Color(0.40, 1.0, 0.60, 0.20)` só com `gifts.ward > 0`; o escudo da Vigília fica em 0,12. **Último 1,0 s**: anel e brilho piscam a 4 Hz (70% a 100%, nunca apagam).
- **Absorveu**: anel `fx.ring` esmeralda 1,8 m fino 0,25 s, 10 `fx.chips` esmeralda em leque contra o golpe, `fx.blade_pulse`, sem `HurtTint`. "Absorvido!" fica. Anel volta a petróleo em 0,1 s.
- O selo do Q no HUD ganha um ponto esmeralda enquanto `ward > 0` (`ui-ux-designer`, no `BuffMark`). **Aceite**: com 8 inimigos em volta, saber se ainda há absorção olhando só os pés.
## 6. (e) Faixa que rastreia e o "travou"
Vale para esqueleto (`aim_lock` 0,25), Cavaleiro (0,2) e segunda flecha do besteiro (`shot_relock` 0,4).
- **Rastreando**: só mira. Linha comum (Cavaleiro) com `strength` 0,7; mira (esqueleto, besteiro) com `aim_light` 0,30, `aim_px` 3,5 e `fill_max` 0. Sem chevrons fortes: diz "ele te segue".
- **Travou** (`Ground.lock_line(z)`, chamado uma vez por golpe): em **0,07 s**, `strength` 0,7 para 2,2 e volta a 1,4; nas miras `aim_px` 3,5 para 9 e volta a 5, `aim_light` 0,9 e volta a 0,5,
  `fill_max` para `AIM_FILL` e `fill_late` de modo que o enchimento comece na trava. A faixa passa de "fio" a "peça". Um pulso só, sem piscar.
- **No corpo**: o brilho da lâmina (`GLINT_PEAK` 0,85) passa a terminar na trava: `1 - aim_lock / attack_windup` (0,72 no esqueleto, 0,80 no Cavaleiro). Ponta acende = saia. Escudo do Cavaleiro: traço `SHIELD` a 1,0 na trava.
- **Som**: o `tell` de cada um com um estalo curto e seco 0,02 s depois, volume de 3 dB acima, por `VoiceGate` (três esqueletos juntos soam um).
- **Aceite**: gravação a 60 fps, três esqueletos preparando: o pulso aparece em 4 quadros, com a faixa já parada no quadro seguinte; depois da trava ela não gira nem 1 grau. 0,2 s é curto: se o Daniel disser que não vê, subir para 0,25 antes de mexer na luz.
## 7. (f) Blindado que reage e estalo em 75, 50 e 25% (10A-1)
- **Golpe comum**: beirada de ouro (já existe) e 4 faíscas. **Onda e Ômega (`heavy`, `omega`)**: 10 faíscas, beirada por 0,18 s e recuo **só desenhado** (`HitRecoil`) de 0,06 m (guardião 0,04), nunca a pose `hit`. A pose, o preparo e o aviso não param: o F8 não muda.
- **Estalo** ao cruzar 75, 50 e 25% (uma vez cada; se cruzar dois, só o menor): `EnemyFx.armor_crack` = 6 `SHARD` do peito para o lado do herói (metade do `armor_break`, velocidade 70%), `-state.r` em 1,0
  por 0,18 s, som `mat_armor` (tom 1,0; 0,92; 0,84). Guardião: 10 lascas e `fx.kick` curto (0,15 m). Sem palavra na tela: a palavra é da quebra.
- **Desgaste que fica**: `CrowdRenderer.state` recebe o gasto de 0 a 1 no lugar do `broken` (0; 0,25; 0,55; 0,8; 1 nos degraus); `armored` do shader já é contínuo.
  Multiplicar por ele também o `gold_rim`: o ouro apaga em degraus. Atualizar `unpack` e o teste.
- **Barra** (`life_bar.gdshader`): três riscos de tinta de 1 px em 25, 50 e 75% da tira amarela, só em elite e guardião; no topo da tela, os mesmos riscos (`ui-ux-designer`).
- **Aceite**: vídeo de 10 s, sem HUD, no Ancião: contar os três estalos; nenhum parece atordoamento.
## 8. (g) GR-5, GR-6 e GR-7
**GR-5 soldado da cor do chão** (Escudo; a frente clara da foto de laboratório engana, as costas e o elmo são pretos). Luz não levanta textura preta: subir a **curva**. `EnemyDef.paint_lift` novo: no `guard`,
`paint_gamma` 0,70 para **0,52** e `style_light` 0,22 para **0,28**. Contraluz só no alto: `style_rim_top` novo (1 = peso por `smoothstep(0.2, 0.6, normal do mundo .y)`),
`style_rim` 0,50, cor (0,70; 0,78; 0,90). Pano vinho: `vivid` +0,12. Escudo fica escuro com o friso claro. Aceite: luma do corpo 60 ou mais e 15 acima do chão no Salão e no Jardim; `guard_elite` segue dourado.

**GR-6 contorno do Ancião** (o ouro chapado é a casca aberta, não a pintura; `guard.jpg` e `guardian.jpg`). Dicionário por modelo em `CrowdRenderer`: `priest_elder` e `knight` com `style_elite_color` (0,07; 0,06; 0,06),
`style_elite_width` **0,035**, `style_push` **0,60**. O ouro fica no friso e numa contraluz `style_elite_rim` 0,3. Manto: `paint_gamma` 0,52 só no Ancião (luma 36 para 55). Aceite: nenhum ouro chapado acima de
10 px; a barra dourada e a orbe dizem "guardião". Ele não pode escurecer na tela: se a luma do manto passar de 60, parar.

**GR-7 rosto de Morvath** (corpo 25, saia 20, chão 40; `boss.jpg`: só a beirada lilás e a coroa leem). Três valores:
- **Cabeça e coroa, o claro**: `crest` 0,5 para 0,8, `crest_from` de 0,80 para **0,86** da altura (sem os ombros), `crest_color` osso dourado (0,80; 0,72; 0,56). Alvo luma 95 a 125.
- **Braços e peito, o médio**: `style_light` **0,28** só nele, `style_rim_power` 3,5 para **5,0** (beirada fina), `BOSS_HERO_LIGHT` 0,25 para 0,32. Alvo 45 a 60. **Saia, o escuro**: `foot_shade` 0,55 para 0,40. Alvo 22 a 32.
- **Olhos**: marca `"head": ["Head"]` em `MODELS.morvath` (reassar só ele) e dois `DOT` de 0,10 m (4 px) em `EnemyFx`, (0,74; 0,55; 1,0) a 0,9, 0,05 m de cada lado e 0,14 m à frente, **sem `over`** (de costas somem). Apagam atordoado;
  sobem 20% no preparo. Nunca vermelhos, nunca acima do limiar do brilho (1,3).
- **Chão sob ele** (só se o resto não bastar): uma `OmniLight3D` sem sombra, (0,62; 0,66; 0,95), energia 1,2, alcance 4 m, a 3,5 m do chão. Aceite: na câmera do jogo, cabeça, braço e saia em três valores a 720 px;
  rosto visível de frente e de três quartos; a fase 3 não vira violeta chapado. Nada de capuz de luz em volta da cabeça.
## 9. (h) Dois inimigos novos (CB-7, lote C5; nomes **a aprovar**, sem lore, zero créditos)
Regra do herói: nenhum pede esperar o golpe. Os seis atuais pedem sair, matar e afastar, dar a volta, encostar ou aguentar, esquivar, escolher o alvo. Faltam: **derrubar juntos** e **andar com o perigo**.

**N1 "Trinca" (a aprovar): pede derrubar os três na mesma janela** (onda atravessando, Ômega em área, ultimate). Ninguém hoje pede juntar.
- Três figuras pequenas que andam em triângulo; quem cai vira um monte e se ergue em 3,5 s se outra ainda está de pé. As três no chão: acabou. Conta como 3 dos 20 vivos; elite de 4 figuras.
- **Silhueta**: baixa e curvada, **sem arma, braços pendurados**, sempre três. Modelo `skeleton` novo assado (`trio.res`) sem o cutelo, `size` 0,85, `bend` `Spine02` 24 e `Head` 18, clipes `Zombie_Idle`, corrida do corredor e `rise`.
- **Cor**: osso cinza-claro (`tint` (0,86; 0,87; 0,90), `vivid` -0,2), pano quase preto. Sem brasa e sem ouro. **Leitura**: fio curto na altura da cintura entre elas, branco-osso (0,80; 0,78; 0,72), alfa 0,22, pontilhado (3 contas paradas, não corre: o do sacerdote corre e é ouro). O monte caído fica na última pose de `death` (sem dissolver), com
  anel claro no chão que se fecha em 3,5 s (`EnemyFx._floor` `RING`, nunca vermelho) e poeira subindo no último 0,5 s.
- **Golpe**: bote curto do esqueleto com mira fina (`add_aim_warning`), uma de cada vez. Novo é só a regra de erguer (`_raise_dead` e o estado RISE já existem).

**N2 "Varredor" (a aprovar): pede acompanhar o giro e entrar no raio dele** (andar sem parar no sentido da volta; a Investida corta caminho). Ninguém hoje pede direção.
- Fincado no meio, varre uma faixa no chão de 5,5 m de alcance e 1,1 m de largura, 200 graus em 1,6 s, depois de 0,9 s de preparo que mostra **o sentido**; colado nele (até 1,6 m) não fere. Pausa de 1,4 s, abertura para bater.
- **Silhueta**: alta, magra e torta, com uma **haste longa na diagonal, apontando para onde a faixa está**: a ponta da arma e a faixa são a mesma linha, lidas de longe. Evitar braços abertos e T (leitura de cruz).
- **Modelo**: corpo `enemy_archer` (capuz) sem a besta, `size` 1,55 (2,98 m), `bend` `Spine01` 14; arma na mão direita: cilindro de madeira de 2,6 m (a mesma técnica da foice de Morvath) com a `w_cleaver` na ponta
  (nada do crescente da foice, que é de Morvath). Poses: `Sword_Idle` em duas mãos, golpe `2H_Melee_Attack_Spinning` esticado em 1,6 s, recuperação na última pose.
- **Cor**: capuz cinza-ardósia (`tint` (0,70; 0,76; 0,82)), lâmina clara. Sem magia: é peso, não feitiço. **Leitura**: faixa de `add_line_warning` que gira por `Ground.point_line`, com três chevrons na borda da frente mostrando o sentido (o miolo a menos de 1,6 m fica sem desenho: `root_clear_m`, já existe na tempestade). No fim da preparação, o
  mesmo pulso de "travou" da seção 6. Risco: virar perigo de sala ou repetir a varredura de Morvath; por isso um por sala, nunca com a corrente (RP-11) ativa.
- **Aceite dos dois**: em uma imagem parada, junto com os seis, um estranho aponta quem é quem; nenhum parece variação de cor de outro (silhueta preta no laboratório). Provisório: corpos reaproveitados com pose, escala e arma novas, não arte final.
- **Perguntas ao Daniel** (não bloqueiam C1): nomes; se a Trinca pode ser "três do mesmo osso" sem explicação de lore; os 2 ou 3 inimigos do SWORN que ele achou difíceis.
## 10. Ordem, dono e risco
1. Seções 5 e 6 (P, maior ganho: o botão novo e a faixa que segue). 2. Seção 2 (M, reassa `guard`). 3. Seções 3 e 4 (P). 4. Seção 7 (M). 5. Seção 8: GR-6, GR-5, GR-7 (M, reassa `morvath`). 6. Seção 9 só no C5.
Dependências: a guarda e o fio leem `Enemy.open_t`, `warded_by`, `Horde.blocks_front`, já no disco. Testes: `test_enemy_fx` (cores, arco, fio), `unpack` do `crowd_renderer`, teste novo de `lock_line`, `RESULT` igual com a mesma semente.
Provas que faltam (a sessão principal captura, uma por vez): Escudo fechado e aberto, sala com sacerdote, Brado, trava a 60 fps, Ancião e Morvath. Enquanto não houver imagem, nada disto está aprovado.

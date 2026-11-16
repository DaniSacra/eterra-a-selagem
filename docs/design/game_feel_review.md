# Game Feel Review oficial (Fase 1)

- **Data**: 2026-11-16 (noite). **Autor**: game-director. **Commit lido**: `71cb8cc` (HEAD de `arpg-3d`); o jogo é o do
  `beb6c27` (C12c), os três commits seguintes só trazem medidas, revisão e vídeos.
- **Pedido**: a etapa obrigatória da diretriz do Daniel (`docs/design/game_feel_directive.md`, prioridade máxima).
- **Junta três avaliações**: medidas técnicas contra o Hades II (`docs/design/game_feel_measures.md`, propostas A a L),
  revisão visual do `art-director` (`docs/design/visual_review.md`, itens V-*), vídeos do QA
  (`docs/gallery/game_feel/VIDEOS.md`) e o QA-02 do C12c (`docs/qa/latest_report.md`, `docs/gallery/cycle12c/AFTER.md`).
- **Rodado por mim**: `~/tools/godot/godot --headless --path . --fixed-fps 60 -s tools/feel_probe_run.gd -- --nosave
  --start=fountain` no `71cb8cc`: a saída bate com as tabelas do `game_feel_measures.md` (esquiva perdida nos quadros 1 a
  4 do golpe 1 e 1 a 6 da seta, ataque perdido nos quadros 1 a 13 da esquiva, buffer perdido nos quadros 1 a 3, 3 quadros
  congelados no abate do golpe 1, 17 quadros parados com `time_scale` 0,2 no giro que mata 3, toque do controle virtual
  perdido no hit stop, esqueleto acertado na preparação ataca no quadro 55 igual). Quadros tirados com `ffmpeg` de
  `g_combo_finalizador_0_25x`, `g_acertos_reacao_0_25x`, `d_especial_circulo_omegas`, `e_grupo_misto`,
  `f1_morvath_despertar` e `f4_morvath_ultimo_suspiro` (olhados).
- **Regras desta revisão**: D-39 vale (mecânicas e números do Hades II fielmente; nomes, personagens, UI e arte de
  Eterra). "Cópia errada" = o número ou a regra do Hades II foi copiado errado ou faltou: corrige-se sem perguntar.
  "Decisão do Daniel" = muda design ou dificuldade além da cópia, ou contraria algo que ele já pediu. O robô vencer não
  prova game feel; os vídeos (a) a (d) e (g) são roteiro fixo, não gente. O que só o Daniel jogando responde está marcado
  **pede teste humano**. O que é opinião minha está marcado **opinião**.

## Veredito geral

O combate **responde** (quase tudo no quadro do aperto, ritmo do combo dentro de 1 quadro do Hades II), mas **some
aperto** e **gruda no impacto**: a esquiva não sai durante a preparação de um golpe e o aperto é jogado fora, o ataque
apertado durante a esquiva some, o buffer é curto e contado do aperto, e o hit stop é um congelamento inteiro onde o Hades
II deixa o mundo andar e só depois desacelera. No visual, o que mais pesa na mão é a fita do corte (folha verde opaca longe
da lâmina), o brilho do finalizador por cima do herói, os avisos em linha empilhados num vermelho chapado e a multidão
animada aos saltos. Nada disso é falta de conteúdo: é acabamento do que existe. **A Fase 1 não está pronta pela diretriz.**

## 1. Movimentação

**Estado**: fiel e responsiva. Anda a 6,75 m/s no quadro do aperto e para no quadro em que solta (igual ao Hades II, sem
aceleração nos dados), corrida de 11,13 m/s (o teto do Hades), câmera que se adianta para onde ele anda.

| # | Problema | Evidência | Proposta | Tipo |
|---|---|---|---|---|
| 1.1 | A direção do herói vira a 18 por segundo (90% de 180 graus em 7 quadros) e o corpo desenhado em 11 quadros; o Hades vira a direção na hora e o corpo a 1340 graus/s (8 quadros) | `game_feel_measures.md` tabela 2; sonda `TURN` (f0 a f11) | direção instantânea, corpo a 1340 graus/s (GF-09) | cópia errada |
| 1.2 | No quadro do aperto de um golpe ele ainda anda um passo inteiro (0,11 m) antes de plantar; o Hades já está a 5% da velocidade na carga | tabela 2; sonda `WALK` (`walked 0:0.11` no golpe 1 e na seta) | ler os botões antes de andar (GF-09) | cópia errada |
| 1.3 | Sem animação curta de arrancar e parar: o Hades as tem (`MelinoeStart`, `MelinoeStop`) e elas dão peso sem atrasar a resposta | tabela 2; `a_movimento_esquiva.mp4` | clipes curtos do UAL só no desenho, resposta igual (GF-15) | cópia que faltou (visual) |

**Veredito**: bom; acerto fino de direção e peso visual. Se a virada "pesada" se nota na mão: **pede teste humano**.

## 2. Ataque básico (golpes 1 e 2)

**Estado**: latência e números fiéis (golpe 1 dá dano no quadro 4, o Hades em 0,06 s; 20 e 25 de dano; arco 150 graus).
O problema é o que acontece no acerto.

| # | Problema | Evidência | Proposta | Tipo |
|---|---|---|---|---|
| 2.1 | **Hit stop copiado errado**: 25, 65, 70 e 50 ms são as esperas (`ScreenPreWait`) do Hades antes da lentidão, e aqui viraram congelamento total que começa no quadro seguinte ao acerto. No Hades o mundo anda 25 a 70 ms, depois cai a 6% por 10 ms (50 com abate) e volta em 20 ms | medidas, tabela 7 e problema 1; sonda `KILL` (quadros 5, 6, 7 com `stepped=false`); o golpe 2 nunca para (cai na recarga de 0,3 s) | GF-01 (proposta A) | cópia errada |
| 2.2 | O primeiro quadro do clarão e do empurrão fica congelado; clarão do inimigo 0,14 s, 4 vezes o do Hades (0,03 s) | tabela 7; sonda `ATTACK 1 tap on a dummy` (f4 `flash_t` 0,12, f5 `stepped=false`); `g_acertos_reacao_0_25x.mp4` 7,4 a 8,4 s: o esqueleto fica quase branco por várias amostras | duração 0,05 s, cor morna nossa (GF-10) | duração: cópia errada; cor: arte nossa |
| 2.3 | Tranco de câmera de 0,32 m (comum) e 0,56 m (forte), 6 a 11 vezes o tremor do Hades (0,05 m), mais tremor por cima; cerca de 7 a 15 px a 1080 em todo acerto | tabela 7; sonda (`kick=0.315m`, `shake=0.076m` no golpe 1) | comuns na escala do Hades; o que fica maior nos finalizadores, o `art-director` decide pelo vídeo (GF-10, D-43) | cópia errada nos comuns |
| 2.4 | Som só no contato; nada no disparo; nenhuma vibração no controle | tabela 7; vídeos (b) e (c) com som | som de lâmina no disparo, vibração por golpe (GF-11) | cópia que faltou |
| 2.5 | A fita do corte é uma folha verde saturada e opaca, nascendo até 2 a 3 m da lâmina, deitada no chão sobre tinta escura | `visual_review.md` V-E1; `g_combo_finalizador_0_25x.mp4` 4,5 a 6,5 s (olhado: a fita aparece longe do herói, à direita); `e_grupo_misto.mp4` por volta de 0:10 | VX-01 | arte (direção já aprovada no `estetica.md`) |

**Veredito**: os números estão certos e o golpe ainda não "estala": congela em vez de morder, e a fita lê como objeto.

## 3. Combo (três golpes e finalizador)

**Estado**: ritmo fiel (giro termina no quadro 72 no ar; o Hades dá cerca de 71); avanço que puxa até o inimigo e meia-lua
do finalizador funcionam.

| # | Problema | Evidência | Proposta | Tipo |
|---|---|---|---|---|
| 3.1 | Buffer de 0,15 s contado do aperto, inclusive na preparação: apertos nos quadros 1 a 3 do golpe 1 somem; no giro (40 quadros) só os 8 últimos valem | medidas tabela 4; sonda `BUFFER` (`d=1..3 LOST`; `tap 26..31` sem o golpe seguinte) | buffer contado de quando o golpe pode sair (trava de gatilho do Hades) (GF-04) | cópia errada |
| 3.2 | O giro congela 4 a 5 quadros (7 com abate): é o "peso grudento" do finalizador | tabela 7; sonda `COMBO mash on a dummy` (`frozen_frames=6`) | sai com GF-01 | cópia errada |
| 3.3 | O brilho de antecipação do finalizador (cruz, anel e risco) tem o anel maior que o herói, centrado no peito, por 5 a 6 quadros | V-E2; `finalizador_salao_a.jpg` 11 a 16; `g_acertos_reacao_0_25x.mp4` 7,4 a 8,4 s (olhado: o herói some dentro do anel) | VX-02 | arte |
| 3.4 | A meia-lua do finalizador nasce a uns 2 m do corpo | `VIDEOS.md`, observação do QA sobre (b) | conferir junto com VX-01 (a fita e a meia-lua presas ao arco da lâmina) | arte |
| 3.5 | O bônus de dano por sequência de golpes não existe no Hades II | `DamageCalc.combo_bonus`; D-10 | tirar (C13-07) | decisão do Daniel (D-10, já aberta) |

**Veredito**: o combo tem o ritmo certo e perde apertos; o finalizador pesa demais no tempo e cobre o herói na imagem.

## 4. Esquiva

**Estado**: distância (5,6 a 5,8 m), duração (0,2 s), recarga (0,74 s, 1 carga) e atravessar corpos fiéis. A corrida
segurando a esquiva sai no teto do Hades.

| # | Problema | Evidência | Proposta | Tipo |
|---|---|---|---|---|
| 4.1 | **A esquiva não corta a preparação e o aperto some**: golpe 1 quadros 1 a 4, seta 1 a 6, giro 1 a 22. O Hades deixa a esquiva cortar a carga. É a fonte mais provável de "apertei e não esquivou" | medidas problema 2; sonda `DODGE pressed d frames after an attack tap` (`dodge LOST`) e `first dodge f23` no giro | GF-02 (proposta B) | cópia errada |
| 4.2 | **Ataque apertado durante a esquiva some** (quadros 1 a 13); o Hades guarda e solta o golpe da esquiva. O `ComboRunner` sabe guardar (`locked`), mas o `Player` não lê botões no estado `DODGE` | problema 3; sonda `ATTACK tapped d frames after a dodge tap` (`LOST` até o 13) | GF-03 (proposta C) | cópia errada |
| 4.3 | O aperto no quadro em que a esquiva termina e todo aperto durante o golpe sofrido (11 quadros) se perdem | tabela 4; sonda `ATTACK right around the end of a dodge` (11 a 13 `LOST`), `HURT` | GF-03 | cópia errada |
| 4.4 | Proteção de 17 quadros desde o aperto; o Hades dá 19 (10 na carga e 16 no salto) | tabela 3 | 19 quadros (GF-09) | cópia errada |
| 4.5 | A esquiva sai no quadro 0; o Hades tem 3 quadros de carga (protegido) | tabela 3 | **opinião**: manter o quadro 0 (só deixa mais responsivo); registrar como diferença nossa | decisão do Daniel (D-44) |

**Veredito**: os números do salto estão certos; a esquiva **não é confiável** enquanto 4.1 e 4.2 existirem. É o item
mais urgente de toda a revisão.

## 5. Emeth (a espada na mão)

**Estado**: o modelo é o melhor objeto do jogo (cristal esmeralda com veios de ouro, guarda de chifres), lê na mão em
todas as salas; pulso da lâmina abaixo do glow; o Ômega do ataque é o melhor efeito do jogo (`omega_recorte.jpg`).

| # | Problema | Evidência | Proposta | Tipo |
|---|---|---|---|---|
| 5.1 | O corte não parece sair da lâmina (fita longe da ponta, opaca, saturação perto de 0,8) | V-E1 (medida de pixel em `crypt/vA_c_combate.jpg`, `rift/vA_c_combate.jpg`) | VX-01: corpo em tinta escura translúcida, borda de ataque marfim-menta fina, verde pálido; a fita começa na ponta da espada no quadro em que o golpe sai | arte |
| 5.2 | Lascas como pontos redondos brancos que ficam 10 ou mais quadros no ar | V-E3; `perto_cripta_b.jpg` 14 a 23 | VX-10 | arte |
| 5.3 | Lâmina muda: nenhum som de corte no ar, nenhum som de carga no giro e no Ômega | tabela 7, problema 11 | GF-11 | cópia que faltou |

**Veredito**: a espada é bonita parada e fraca em movimento; o rastro é o maior déficit visual da mão.

## 6. Especiais (Seta de Luz, círculo de luz, Ômegas)

**Estado**: as quatro ações se distinguem pela forma (dardo, aro no chão, feixe para frente e para trás, onda); o Ômega do
ataque fecha a câmera 8% na carga e tem o quadro de impacto raro (D-08).

| # | Problema | Evidência | Proposta | Tipo |
|---|---|---|---|---|
| 6.1 | A seta trava o ataque 35 quadros e solta as pernas na hora; o Hades libera o ataque em 18 quadros, tem recarga própria de 0,7 s e segura as pernas 0,71 s (só a esquiva corta). Dardo a 30 m/s contra 62,5 | medidas problema 7, tabela 5; sonda `SPECIAL tap` (golpe só no 42) | GF-07: trava de ataque 18, recarga 0,7 s, dardo 62,5 m/s | cópia errada |
| 6.2 | A parada das pernas de 0,71 s depois da seta | tabela 5 | **opinião**: copiar (o especial é o golpe de maior dano por aperto e o Hades cobra o compromisso); contraria o "mais dinâmico" do 1º teste | decisão do Daniel (D-44) |
| 6.3 | O Ômega do ataque acerta 0,14 s depois de a carga encher; o Hades dispara ao encher | problema 10; sonda `OMEGA attack` (lança no 47, acerto no 56) | GF-08 | cópia errada |
| 6.4 | Ômega do especial: onda de 22 m/s e 8,25 m de largura; o Hades usa projétil de 9,75 m/s com explosão de 4,1 m | tabela 10 | conferir os dados (`ProjectileStaffBallCharged`) e copiar (GF-09) | cópia a confirmar |
| 6.5 | O círculo dá 0,2 s de proteção e deixa atacar na hora; o Hades não protege e trava 8 quadros sem atacar | tabela 9 e 10; sonda `CAST tap` (`inv=true` em f15 a f35) | tirar a proteção e pôr os 8 quadros | cópia errada que deixa mais fácil: D-44 confirma |
| 6.6 | A seta e o Ômega do especial não dão hit stop, tranco nem tremor no acerto: o golpe de maior dano é o mais "leve" na mão | tabela 10 | regra do Hades para acerto de projétil **a confirmar** nos dados; até lá, o `art-director` decide o retorno visual no acerto (estrela furada mais visível, V-E4) | a confirmar |
| 6.7 | O aro do círculo é marfim grosso e opaco por 3 s, lê como interface por cima dos corpos | V-M1; `d_especial_circulo_omegas.mp4` 0:05 a 0:07, `e_grupo_misto.mp4` 0:01 e 0:11 a 0:13 (olhados) | VX-09 | arte |

**Veredito**: formas boas; o especial está rígido do lado errado (trava o golpe, solta as pernas) e leve no acerto.

## 7. Retorno dos inimigos

**Estado**: pisca morno abaixo do glow, inclinação para trás, empurrão (8, 10, 16 m/s), corpo arremessado ao morrer,
armadura com centelhas e atordoamento de 1,5 s ao quebrar (igual ao `ArmorBreakStun` do Hades).

| # | Problema | Evidência | Proposta | Tipo |
|---|---|---|---|---|
| 7.1 | **Inimigos não reagem ao golpe**: sem atordoamento, o clipe de recuo só toca se ele estiver andando e ele continua vindo; acertado na preparação, ataca no tempo de sempre. No Hades os comuns sem armadura tocam o atordoamento e a IA sai da espera; elite com armadura é imune até quebrar; alguns são imunes só durante o próprio ataque | medidas tabela 8; sonda `ENEMY hit during its windup` (ataque no 55 apesar do golpe no 11) | GF-12 (proposta F), por inimigo, com o campo de imunidade do Hades | cópia que faltou, mas muda muito a dificuldade: **decisão do Daniel (D-42)** |
| 7.2 | Multidão animada aos saltos: andar 10 poses por ciclo, golpe sofrido 4, parado 4, sem mistura (`crowd_renderer.gd:242`); ao lado do herói lê como stop motion | V-A1; `perto_cripta_b.jpg` | VX-04 | arte (técnica) |
| 7.3 | O recuo quase não se vê (0,2 rad e 4 poses de `hit`) | V-A3 | VX-06 junto com GF-12 | arte |
| 7.4 | Armas do KayKit nas mãos dos modelos do Meshy (cutelo listrado maior que o tronco) | V-P1; `perto_cripta_b.jpg` 0 a 23 | VX-07 paliativo no assado; final com Meshy (D-46) | arte |

**Veredito**: o golpe não muda o comportamento de ninguém. Com 7.1 e 7.2 juntos, acertar parece bater em boneco.

## 8. Grupos

**Estado**: o herói continua achável no meio de 8 a 10 (anel e raio-x, QA); números somados; o teto de inimigos por sala
(4 a 20) segura a tela.

| # | Problema | Evidência | Proposta | Tipo |
|---|---|---|---|---|
| 8.1 | Avisos em linha e retângulo em vermelho chapado com alfa alto, que se somam numa massa vermelha sob o herói | V-L1; `perto_cripta_a.jpg` 0 a 15; `d_especial_circulo_omegas.mp4` 0:01 a 0:02 e 0:10 a 0:15, `g_acertos_reacao_0_25x.mp4` 4,5 a 8 s (olhados) | VX-03: preenchimento até 0,35 que sobe nos últimos 30% do preparo, sobreposição pelo máximo | arte, sem mudar tempo nem área dos avisos |
| 8.2 | A câmera lenta de 3 abates ou 7 atingidos vira 0,28 s de tela congelada (o `Fx.tick` desconta o hit stop com o tempo já desacelerado) | problema 5; sonda `KILL 3 at once` (17 quadros `stepped=false` com `time_scale` 0,2) | GF-05 (proposta E) | erro nosso (bug) |
| 8.3 | A câmera lenta por vários abates não existe no Hades (só último abate e chefe) | tabela 11 | **opinião**: manter, corrigida pelo GF-05 (é a sensação do Ember & Blade, rara: 1 a cada 6 s) | decisão do Daniel (D-43) |
| 8.4 | O controle virtual perde apertos no quadro congelado: o robô que mede as lutas e o toque futuro | problema 9; sonda `HIT STOP` (`pad ... LOST`) | GF-06 | bug |

**Veredito**: a multidão se lê, os avisos não: em grupo o chão sob o herói vira vermelho. **Pede teste humano**: se o
jogador consegue escolher a saída dentro de três avisos sobrepostos.

## 9. Morvath

**Estado**: a sala mais forte (Câmara do Selo), avisos assinados, tempestade com cunhas e ordem de saída que leem bem
(`f4_morvath_ultimo_suspiro.mp4` 0:06 e 0:09, olhados), ritual com losangos e "Derrube os mortos", entrada sem coluna
(GP-01 passou). Robô com reação 0,25 vence 5 de 8 descidas (simulação; não é diversão).

| # | Problema | Evidência | Proposta | Tipo |
|---|---|---|---|---|
| 9.1 | Animado em poucas poses (parado 4, golpe 8), sem mistura, com clipes genéricos (`slash1`, `rain`, `roar`) | V-A1, V-A5 | VX-04 (mistura) e VX-14 (clipes CC0 mais pesados) | arte |
| 9.2 | Lâmina do KayKit com guarda em gancho amarelo vivo | V-P1; `boss_arena/03b_foice_golpe.jpg` | VX-07 (repintar no assado); final com Meshy (D-46) | arte |
| 9.3 | Queimando, o manto violeta vira laranja | V-M2; `morvath_queimando.jpg`; `f1_morvath_despertar.mp4` por volta de 0:07 e 0:08 (olhado) | VX-08 | arte |
| 9.4 | A fase 4 não aparece inteira nos vídeos (com 14% da vida cai em 10 s) | `VIDEOS.md`, observações | regravar com `--bot-kite` no QA do C12d | evidência |
| 9.5 | Gente apanha da foice; o robô da tempestade | registro humano antigo (foice 36 de 62 de dano), `METRICAS` | nada agora; o registro v2 (GP-02) mede `warn_s` por golpe | **pede teste humano** |

**Veredito**: leitura boa, presença fraca: ele se mexe como os esqueletos e muda de cor com o fogo.

## 10. O que só o Daniel jogando responde

1. Depois do GF-01 a GF-05: a esquiva e o combo "obedecem"? Ainda há "apertei e não saiu"?
2. O golpe pesa sem grudar? O tranco menor deixou o golpe fraco ou mais limpo?
3. A seta com a parada de 0,71 s (se D-44 aprovar) ficou rígida ou ganhou peso?
4. Inimigos atordoando (se D-42 aprovar): o jogo ficou fácil demais ou mais justo?
5. Dentro de três avisos sobrepostos dá para escolher a saída?
6. Latência sentida no teclado e no controle (GF-13 mede a ponta a ponta; a sensação é dele).

## 11. Resumo por tipo

- **Cópia errada, corrigir sem perguntar** (C12d): GF-01 hit stop, GF-02 esquiva corta a preparação, GF-03 apertos
  durante esquiva e golpe sofrido, GF-04 buffer pela trava, GF-07 travas e velocidade da seta, GF-08 Ômega ao encher,
  GF-09 direção, plantar, proteção da esquiva, Ômega do especial a conferir, GF-10 clarão e tranco dos comuns, GF-11 som
  do disparo e vibração.
- **Bug nosso**: GF-05 câmera lenta congelada, GF-06 controle virtual, VX-11 `PALADIN_4` na carta de dom.
- **Arte (direção já aprovada; `art-director` aprova, Daniel dá a palavra final)**: VX-01 a VX-17.
- **Decisão do Daniel**: D-42 atordoamento dos comuns, D-43 o que fica nosso no impacto, D-44 divergências que mexem na
  dificuldade (esquiva no quadro 0, proteção do círculo, parada da seta), D-46 créditos para armas.

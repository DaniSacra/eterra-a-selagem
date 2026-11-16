# Revisão de arte: C11 (Câmara do Selo) e C10 (Limpar e medir)

Autor: `art-director`, 2026-11-16. Material avaliado: capturas reais na placa de vídeo (RTX 5060, Forward+, 1920 x 1080)
desta pasta e de `docs/gallery/cycle10/`, os dois vídeos da luta (1280 x 720, sem som), o `CAPTURAS.md`, o `METRICAS.md`,
o relatório de QA (`docs/qa/latest_report.md`), a especificação (`docs/art/boss_chamber_spec.md`), o pedido do Daniel
(`docs/design/boss_arena_brief.md`), a conta do raio (`docs/design/boss_arena.md`) e a pintura de referência (só local,
`docs/art/ref/morvath/camara_do_selo.png`, feita por IA). Nenhuma imagem gerada por IA foi usada como evidência do jogo.
Medidas de cor feitas por mim nas capturas (mediana de recortes, ffmpeg); quadros dos vídeos extraídos para o scratchpad
da sessão, fora do repositório.

**A aprovação artística final é do Daniel.** Esta revisão diz o que as evidências mostram e o que falta.

## Aviso sobre as capturas

As últimas correções (`00dd13b`) refizeram só as oficiais `01_arena_vazia` e `10_vitoria_selagem` (e as provas em
`work/fix_*`). As capturas `02` a `09`, as variantes, `selo_estados`, `borda_e_camera`, os antes e depois e os dois
vídeos são do `6bab080`: mostram os sarcófagos leste e as velas da frente um pouco antes do ajuste final (a espada da
tampa ainda lendo como cruz, o nicho mais alto) e, no vídeo, Morvath ainda clareando nos golpes. A luta em si (ataques,
avisos, selo, câmera) é a mesma.

## Commits

| Commit | Ciclo | O quê |
|---|---|---|
| `b527ba5` | | backlog oficial do game-director; o brief da Câmara do Selo vira o C11 (raio 12 m) |
| `88f00c6` | C11 | especificação de arte da câmara (planta, câmera, paleta, cinco estados do selo, avisos com assinatura) |
| `8a8fed2` | C10 | arte: escudo do ritual sem pontos brancos, orbes com cor, cortina espectral, esmeralda corrompido, queimadura em brasas, clima da fase 4 |
| `dcf6632` | C10 | jogo: quadro P&B só em Ômega acertado e quebra de fase (no máximo 1 a cada 10 s), escudo cai com os 4 primeiros mortos, Morvath escurece no golpe final, registro de partidas |
| `196f33c` | C10 | interface: tingido de dano só nas bordas, opções de conforto, contador do ritual em losangos, "Derrotado por" |
| `6b16045` | C11 | jogo: chão circular de 12,5 m, avisos recortados e assinados, fases 3 e 4 abrem do centro, câmera fixa com a regra dos 18% |
| `482eb6f` | C11 | cenário: `BossChamber` com selo e leão, rachadura por fase, cinco estados, perímetro, fachada, escadaria, abismo |
| `6bab080` | C11 | polimento: ar azul-marinho, colunas de bruma violeta, correntes, sarcófagos maiores, veios da fase 4, dissolução em ouro velho |
| `72285ab` | C10 e C11 | evidências: capturas 01 a 10, variantes, montagens, vídeos, métricas (368 lutas), relatório de QA |
| `6801e87` | C11 | telas de fim sem a linha de nível; a sala do chefe se chama "A Câmara do Selo" |
| `00dd13b` | C11 | correções finais: Morvath não embranquece queimando, herói não parece de pé sobre sarcófago e velas, espada que não lê como cruz, rachadura fecha na vitória, pilaretes com mais pedra no pontilhado |

Decisões tomadas pela sessão (o Daniel dormia), seguidas aqui: o selo segue a geometria da pintura com o leão de pé do
cânone no meio; a espada erguida no lugar da cruz; as salas comuns continuam no salão; raio andável de 12 m; Morvath vai
ao centro ao abrir as fases 3 e 4. Todas a confirmar com ele.

## 1. Critérios

### 1.1 Do pedido do Daniel (brief)

| Critério | Estado | Evidência |
|---|---|---|
| Arena circular, raio justificado pela mecânica | SIM | `docs/design/boss_arena.md`; teste `test_the_floor_is_a_circle_of_eleven_to_thirteen_meters`; `01` |
| Cena própria e reaproveitável; salas comuns como estão | SIM | `BossChamber` (`482eb6f`); o salão segue nas salas 1 a 4 (`before_after_arena.jpg`) |
| Selo com cinco estados, vitória restaura e sela | SIM | `selo_estados.jpg`, `10`, `10a`, `10b`, `work/fix_o2_vitoria_depois.jpg` |
| Selo não bloqueia | SIM | colisão é o círculo; o herói anda sobre ele em `10` e no vídeo |
| Perímetro sem esquiva injusta, sem prender, sem esconder | SIM, com ressalva | 0 lutas presas em 136; pontilhado no pilarete (`work/fix_o3_pilarete125_depois.jpg`); velas da frente ainda por cima das pernas do herói (`work/fix_m2_se85_depois.jpg`) |
| Limite segue o círculo | SIM | avisos cortados na balaustrada em `04` e `09` |
| Quatro fases, centro usado, invocações no círculo | SIM | `05`, `06`, `09`, vídeo da vitória (fases em 32, 74 e 97 s) |
| Fase 4: sem canto, espaços seguros reconhecíveis, nada inevitável | SIM (regra) / PARCIAL (leitura) | `test_the_storm_has_a_way_out_of_both_waves`; em `09` as seis faixas se sobrepõem no centro num rosa quase branco (mediana R 243, L 124), que esconde os pontos de ordem e o próprio Morvath |
| Sem aumentar vida nem dano | SIM | `METRICAS.md` |
| Sem Meshy, só assets locais | SIM | nada gerado; peças procedurais e KayKit |
| Evidências (pasta, antes e depois, vídeo, condições) | SIM | `CAPTURAS.md` (antes e depois da investida com comandos diferentes, explicado); vídeos em 720p |
| Herói não preso, avisos legíveis, câmera mostra a luta | SIM | QA, seção 5; `borda_e_camera.jpg` |
| Identidade de Eterra | SIM, com ressalvas | seção 3 |

### 1.2 Da especificação (seção 10)

| # | Critério | Estado | Evidência e observação |
|---|---|---|---|
| 1 | Chão andável circular de 11 a 13 m, em dado | SIM | teste e `boss_arena.md` |
| 2 | Marcos da `02` a até 40 px da posição prevista (80 px na fachada) | NÃO MEDIDO | ninguém mediu os marcos; a olho, a fachada e o selo caem onde a tabela da seção 4 pede |
| 3 | Porta no terço de cima à direita, escadaria embaixo à esquerda, selo no meio, sarcófagos nas laterais com lanterna de cada lado, quatro pilaretes, dois braseiros | SIM | `01`, `02` |
| 4 | Nenhuma cruz; espada erguida lendo como espada | SIM depois do `00dd13b` | `01` e `work/fix_m2_*_depois` mostram a espada inclinada com ponta (lê como espada ou punhal); em `02` a `09` a tampa ainda lê como cruz. Os estandartes têm a espada pequena demais para ler a 1080 linhas. (O texto do critério fala em "leão nos sarcófagos"; vale a decisão D-17 do cabeçalho: leão só no selo) |
| 5 | Cinco estados distintos em miniatura | SIM | `selo_estados.jpg`: dourado parado, aro violeta, escudo verde, veios violeta, ouro aceso |
| 6 | Leão lê como leão; rachadura atravessa e cresce por fase | SIM | `01` (juba, patas, cauda); `08b` (ramo da fase 3); `fase4_clima` |
| 7 | Nada do selo acima do limiar do glow | PARCIAL | estados 1 a 4 sem halo; na vitória (`10`) a estrela de luz no centro (`victory_absorb`) estoura em branco dourado por um instante |
| 8 | Vitória: nenhum violeta no selo nem na porta; ouro sem amarelo saturado | SIM | `10` refeita: costura fechada, 0 pixel com R > 200 e B < 60 no miolo do selo; a cicatriz da rachadura sem cor |
| 9 | Herói, Morvath e avisos no quadro; 18% das bordas | SIM | QA, a olho; menor folga 21% |
| 10 | Herói pelo pontilhado atrás do pilarete e da balaustrada | SIM depois do `00dd13b` | `work/fix_o3_pilarete125_depois.jpg` |
| 11 | Avisos de Morvath, itens (a) a (f) | PARCIAL | (a) SIM: mediana R 146 a 171, B 37 a 75, luminância 52 a 68 (`03`, `04`, `09`; a investida fica um pouco abaixo de 60), juntas visíveis; (b) o fio violeta de 2 px não se distingue do aro nas capturas; (c) SIM, runas azuis por fora; (d) SIM, nada além da balaustrada; (e) pontos de ordem visíveis na raiz, o degrau do aro não foi medido e some no centro sobreposto; (f) não testado com gente |
| 12 | Nenhum clarão branco da câmara no vídeo | SIM para a câmara | selo, porta e véu sem branco; o branco que aparece no vídeo é do corpo de Morvath e de uma coluna de geada (seção 4) |
| 13 | Chão do meio: luminância 45 a 60, B - R 25 a 45 | NÃO | `01`: mediana R 11 a 18, B 45 a 62, luminância 16 a 19 (a pintura dá 53). O tom está certo, o valor está muito escuro |
| 14 | Abismo violeta nas laterais; azul no topo entre as correntes | PARCIAL | laterais SIM (R 95, G 35, B 174 à esquerda; R 42, G 16, B 111 à direita); topo NÃO (R 0, G 7, B 36: azul-marinho quase preto, a pintura tem azul claro com agulhas) |
| 15 | Quente estourado entre 0,2% e 1% | SIM | `01`: 0,46% |
| 16 | Esmeralda corrompido distinto da Emeth | PARCIAL | `fase4_clima`: o manto corrompido é verde-azulado escuro e a Emeth verde-menta clara; distinguem-se juntos, mas o verde dos orbes nas mãos dele chega perto da lâmina |
| 17 | p90 até 6,5 ms nas três cenas | SIM | 3,99 a 4,11 ms (máximo 4,78) |
| 18 | Navegador: câmara inteira, p50 perto do desktop | PARCIAL | `work/chamber_10_compat_opengl3_showcase.jpg` mostra a câmara inteira (do `482eb6f`); p50 não medido |

## 2. Fidelidade à referência, peça por peça

Comparação: `lado_a_lado_referencia.jpg` (pintura à esquerda, jogo à direita) e `01`. A pintura usa uma câmera mais
aberta (inclinação 27, distância 51); o jogo usa a câmera de luta (30, 54, alvo fixo), por isso o quadro corta o alto da
fachada.

| Peça | Bate | Difere |
|---|---|---|
| Composição geral | herói embaixo à esquerda na boca da escadaria, selo no meio, porta no alto à direita, abismo dos dois lados | a câmara ocupa mais o quadro; a fachada corta no topo (estandartes sem a parte de cima, sem o pináculo); a balaustrada da frente e a parede abaixo dela pesam no quarto de baixo da tela |
| Plataforma e chão | círculo de lajes, borda escura | chão muito mais escuro (luminância 18 contra 53) e de lajes irregulares; a pintura tem lajes regulares cinza-violeta |
| Selo | anel duplo, estrela de oito pontas, ouro velho, rachadura violeta | o miolo é o leão de pé (decisão) no lugar da cruz; o ouro é mais fino que na pintura |
| Balaustrada e velas | contínua, velas em grupos | velas sobem no ressalto, não no chão (decisão da especificação); arcadas ogivais sob a borda quase não aparecem |
| Lanternas violeta | quatro, ladeando os sarcófagos | menores na tela |
| Sarcófagos | dois pares nas laterais | na borda, encaixados na balaustrada: o par oeste lê como bloco da mureta, não como sarcófago; na pintura são caixas soltas sobre o chão |
| Pilaretes | quatro, com o painel de espada | sem diferença relevante |
| Fachada norte | escada curta, porta selada com costura violeta, duas estátuas encapuzadas, dois estandartes carmim, dois braseiros | a porta tem rosácea de ouro, não a roda com gema da pintura; as estátuas são escuras e perdem o capuz contra o fundo; braseiros mais claros que os da pintura |
| Torre a noroeste | presente | sem diferença relevante |
| Correntes | cruzam o alto do quadro | mais grossas e mais baixas, atravessam o céu à esquerda |
| Fundo | bruma violeta nas laterais | falta o anel distante de arcadas com janelinhas quentes e as agulhas na bruma azul; o topo é quase preto. A versão do navegador (`chamber_10`) tem céu azul com agulhas, mais perto da pintura |
| Morvath | coroa pálida, manto violeta | sem foice (o modelo aprovado tem lâmina); maior em relação ao herói do que na pintura |
| Herói | Explorador com a Emeth | sem diferença relevante |

O que depende de modelo que não existe: estátuas esculpidas, sarcófagos com tampa trabalhada, a foice de Morvath, a
porta com relevo. Hoje tudo é procedural ou KayKit: **provisório**.

## 3. Identidade de Eterra

- A cruz da pintura saiu de todas as peças. A espada erguida dos guardiões está nos pilaretes, sarcófagos e estandartes,
  e o leão de pé está só no selo. Depois do `00dd13b` a espada da tampa lê como espada. Os dois símbolos e a postura do
  leão precisam da confirmação do Daniel.
- A paleta é a do jogo: pedra fria, ouro velho no selo e nos debruns, violeta de Morvath, verde espectral da necromancia e
  verde cristalino da Emeth em papéis separados, braseiros e velas quentes. Nenhum vermelho além dos estandartes e dos
  avisos.
- A vitória diz a coisa certa em imagem: a corrupção volta ao selo, a porta se fecha, o ouro acende e Morvath é selado,
  não morto. A luz vem da Emeth (alegoria de Elun) e não de outra fonte.
- O que não vem da pintura nem de outro jogo: o leão, a espada, a porta como eco do selo. Nada copiado.

## 4. Legibilidade

- **Herói.** Sempre visível (anel petróleo, raio-x nas cores dele). Atrás do pilarete de 125° sai pelo pontilhado
  (`fix_o3`). Na borda leste ele agora fica à frente do sarcófago e não em cima (`fix_m2_e12_depois`). Na borda sul
  (`fix_m2_se85_depois`) a balaustrada abre em pontilhado, mas as chamas das velas da frente continuam desenhadas por
  cima das pernas dele.
- **Avisos com a assinatura nova.** Miolo vermelho que deixa ver as juntas, runas azuis correndo por fora, recorte na
  balaustrada: lê como "de Morvath" e diferente dos avisos dos mortos. Na foice (`03`) e na investida (`04`) funciona.
  Na tempestade (`09`) as seis faixas somam no centro um rosa quase branco que cobre os pontos de ordem e o selo; o
  vazio entre as faixas se lê, a ordem não. As erupções (`07`) ficaram só com o círculo de runas verde-azulado, sem o
  miolo vermelho de 0,35 que a especificação pedia: leem como "magia", menos como "perigo".
- **Morvath dentro do escudo.** Lê: a silhueta dele aparece inteira pelo vidro espectral (`05`, `escudo_ritual_zoom`),
  sem pontos brancos, com a barra do chefe trocando para o contador em losangos e "Derrube os mortos". A quebra (vídeo da
  vitória, 0:45) é limpa: o vidro se parte em cacos, nada de clarão.
- **O anel de luz do herói** (o círculo, aro marfim de 5,4 m) é a forma mais clara da tela em quase todo quadro com o
  robô (`03`, `04`, `09`, vídeo). É do herói, não da câmara, mas compete com o selo e com o aviso da foice.
- **Corpo de Morvath no vídeo (antes do `00dd13b`).** Com o kit de geada ele fica branco por um quadro em golpes fortes
  (vídeo da vitória, cerca de 0:15 e 0:46). O `00dd13b` tirou a borda da elite que ia ao branco com o pisca; confere com
  o fogo (`fix_m1_*`), mas a geada não tem captura depois da correção.
- **Coluna de geada sobre Morvath** (vídeo da vitória 0:46, da derrota 1:40): coluna azul quase branca da altura da tela,
  que cobre o corpo dele por meio segundo. O `BEAM_OVER_BOSS` (0,2) não parece valer para ela.

## 5. Os cinco estados do selo (`selo_estados.jpg`, `10`)

| Estado | O que se vê | Avaliação |
|---|---|---|
| 1. Normal | ouro velho parado, leão em traço, rachadura violeta acesa | SIM; lê em miniatura |
| 2. Preparo do ritual | anéis em violeta e azul, pontas acesas, runas | SIM; o anel marfim do herói cobre parte do quadro |
| 3. Ritual ativo | anel de runas verde-azuladas sob o escudo, selo mais escuro dentro | SIM; o verde do escudo domina o selo, o que é a intenção |
| 4. Transição final | veios violeta orgânicos saindo pelas juntas, ouro apagado, rachadura maior | SIM; os veios são o elemento mais forte da fase 4 e leem como corrupção |
| 5. Vitória | ouro aceso nos anéis e no leão, estrela de luz no centro, cicatriz sem cor | SIM na `10` refeita (rachadura fechada, `fix_o2`); a estrela central passa do limiar por um instante (critério 7) |

## 6. C10: Limpar e medir

| Item | Estado | Evidência |
|---|---|---|
| Clarões brancos (quadro P&B) | SIM | 4 quadros de impacto em 125 s, 0 com a opção desligada (`cycle10/folha_quadros_*`) |
| Golpe final sem Morvath branco | SIM | `cycle10/golpe_final_sem_branco.jpg`: ele escurece |
| Escudo do ritual sem pontos brancos | SIM | `cycle10/escudo_ritual_zoom.jpg`, `before_after_ritual.jpg`; cortina espectral na borda no lugar do feixe branco |
| Orbe do feiticeiro com cor, sem miolo branco | SIM | `cycle10/orbe_feiticeiro_zoom.jpg`: orbe violeta pequeno com halo; pequeno demais para ler longe, mas sem branco |
| Queimadura | SIM depois do `00dd13b` | no `6bab080` Morvath queimando ficava quase branco (`work/fix_m1_burn_t10_antes`); depois, brasa no manto e corpo na cor dele (`fix_m1_burn_t10_depois`, `t12`); no salão comum já estava certa (`queimadura_salao_comum.jpg`). Queimando ele fica alaranjado por inteiro e perde o violeta; aceitável enquanto dura a brasa |
| Fase 4 | SIM | `cycle10/fase4_clima.jpg`: ar violeta, fogo mais frio e baixo, veios, raio da porta azul; volta ao normal no selo |
| Interface | SIM | tingido de dano só nas bordas e curto (`golpe_sofrido_comum`, `_amaldicoado`, violeta quando amaldiçoado); opções de conforto (`opcoes.jpg`); contador do ritual em losangos (`contador_ritual.jpg`, `05`); "Derrotado por" (`derrotado_por.jpg`); nome da fase embaixo da barra |

Pendência do C10 que segue: Morvath branco na geada (seção 4, sem captura depois da correção) e a coluna de geada.

## 7. Pendências

| # | Pendência | Responsável | Pedido concreto e critério |
|---|---|---|---|
| P1 | Chão da câmara escuro demais (luminância 18 contra 45 a 60 pedidos; a pintura dá 53) | `environment-artist` | subir a exposição ou o albedo do chão só na câmara (ar próprio da câmara, `boss_chamber.gd` e `catacomb_floor.gdshader` por parâmetro) até a mediana do recorte do meio de `01` dar luminância 40 a 55 com B - R 25 a 45; conferir que os avisos de `03`, `04` e `09` mantêm R pelo menos 40 acima de B e as juntas visíveis |
| P2 | Tempestade: o centro sobreposto vira rosa quase branco e esconde a ordem e Morvath | `environment-artist` (desenho em `ground.gdshader`/`GroundLook`) com o `gameplay-engineer` | limitar a soma das faixas sobrepostas ao máximo de uma faixa (mistura por máximo, não por soma) e não desenhar as faixas dentro de 1,2 m de Morvath; critério: em `09` o recorte do centro com mediana de luminância até 90 e os pontos de ordem contáveis |
| P3 | Recapturar `02` a `09`, `selo_estados`, `borda_e_camera`, os antes e depois e o vídeo da vitória no `00dd13b` | `qa-performance` | mesmos comandos do `CAPTURAS.md`; acrescentar uma captura de Morvath com o kit de geada levando golpe forte (`--boon-ids=golpe_geada,toque_geada,circulo_geada,passo_geada,estilhaco,peso_inverno --shot-at=15`) para fechar o branco na geada |
| P4 | Coluna de geada quase branca sobre Morvath | `environment-artist` (`skills.gd` `_beam`, `beam.gdshader`) | aplicar `BEAM_OVER_BOSS` também à coluna da geada e limitar o miolo a 1,0; critério: nenhum quadro do vídeo com o corpo dele coberto por branco |
| P5 | Erupções sem o miolo vermelho de perigo | `environment-artist` | o miolo de 0,35 da assinatura dentro do círculo de runas (seção 8 da especificação); critério: em `07` a mediana dentro do círculo com R pelo menos 40 acima de B |
| P6 | Fundo: topo quase preto, falta o anel de arcadas com janelinhas e as agulhas em azul | `environment-artist` | levar o céu da câmara ao azul da pintura (critério 14: B pelo menos 50 acima de R e G pelo menos 20 acima de R no topo entre as correntes) e acender 10 a 20 janelinhas quentes no anel distante; a versão do navegador já chega perto |
| P7 | Velas da frente desenhadas por cima das pernas do herói | `environment-artist` | velas do arco de 100° a 190° entrando no pontilhado em volta do herói, como a balaustrada; critério: `--hero-at=8.5,8.5`, pernas do herói inteiras |
| P8 | Fio violeta dos avisos não se distingue | `environment-artist` | fio de 2 px com `Boss.VIOLET` x 0,8 visível entre o aro vermelho e as runas em `03` ampliada a 200% |
| P9 | Estrela da vitória passa do limiar do glow | `environment-artist` | máximo 1,0 no centro, como os traços dos raios (critério 7) |
| P10 | Medir os marcos da `02` contra a tabela da seção 4 | `art-director` | rodar a medida de `arena_reference.md` na `02` refeita (P3) |
| P11 | Sarcófagos oeste lendo como mureta; estandartes com a espada pequena | `environment-artist` | sarcófagos com tampa um passo mais clara e friso visível a 1080; espada dos estandartes com 1,2 m como na especificação |
| P12 | Perguntas ao Daniel (pelo Game Director) | Game Director | leão de pé (patas de trás) e só no selo; espada erguida no lugar da cruz; véu da entrada; o que é a porta; raio 12 m e o centro nas fases 3 e 4 |
| P13 | Gravação em 1280 x 720 | `gameplay-engineer` | opção de gravação a 1080 (B-2 do QA) |
| P14 | Modelos que faltam (estátuas, sarcófagos, foice, porta em relevo) | Daniel (Meshy) | entram no `docs/art/meshy_asset_plan.md`; nada gerado sem autorização |

## 8. Veredito

**Aprovado para o teste do Daniel**, como versão jogável completa do C10 e do C11, com ressalvas.

- A câmara cumpre o pedido na estrutura: círculo de 12 m sobre o abismo, selo com leão no meio, porta selada ao norte,
  escadaria a sudoeste, perímetro fora do chão andável, cinco estados do selo legíveis e a vitória que sela em vez de
  matar. A luta lê melhor que no salão e as regras foram validadas (testes, 368 lutas, nenhuma presa).
- O C10 tirou os brancos que a direção proibia (quadro P&B raro, escudo, orbe, golpe final, queimadura depois do
  `00dd13b`) e a interface nova está limpa.
- Não declaro fidelidade alta à pintura: o chão está muito mais escuro, o fundo azul e o anel de arcadas não estão lá, a
  fachada corta no topo da câmera de luta e várias peças são procedurais ou do KayKit (provisórias).
- As capturas `02` a `09` e o vídeo são de um commit antes das correções finais (P3). A geada sobre Morvath ainda não tem
  prova depois da correção.
- Nada disso impede jogar. As pendências P1, P2 e P3 deveriam entrar antes de uma versão para mostrar a outras pessoas.

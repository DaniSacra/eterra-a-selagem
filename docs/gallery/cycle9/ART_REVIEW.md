# Ciclo 9: revisão de arte (Morvath, a batalha definitiva)

Revisão do Art Director sobre capturas e vídeos reais do jogo (Godot 4.7.2 de Windows, NVIDIA GeForce RTX 5060 Laptop
GPU, Vulkan, Forward+, 1920 x 1080; vídeos gravados pela própria Godot em 1280 x 720). Nenhuma imagem desta pasta foi
gerada por IA nem retocada. Comandos e momento de cada captura: [CAPTURAS.md](CAPTURAS.md). Simulações do robô:
[METRICAS.md](METRICAS.md). QA: [latest_report.md](../../qa/latest_report.md). Design da luta:
[morvath_boss_fight.md](../../design/morvath_boss_fight.md). Revisão anterior: [ciclo 8](../cycle8/ART_REVIEW.md).

Abri cada imagem citada abaixo. Dos dois vídeos tirei folhas de quadros (luta inteira a cada 5,5 s; trechos de 0,25 s
e 0,42 s no começo do ritual, nos primeiros 30 s e na maldição) e medi quadro a quadro, por `ffmpeg signalstats`, os
quadros em preto e branco (saturação média abaixo de 4) e o matiz da tela durante a maldição. Os quadros extraídos
ficaram no scratchpad da sessão, fora do repositório. Não há percentual de semelhança aqui: só o que se vê. **A
aprovação artística final é do Daniel.**

## 1. Commits

| Item | Valor |
|---|---|
| Branch | `arpg-3d` |
| Commit inicial | `3b22cea` (começo do ciclo 9) |
| Commit final avaliado | `147b481` (HEAD) |
| Commits do ciclo | `ca7e97b` maldição, HUD do chefe e vitória; `9aff1fc` escudo, runas, portal da fase 4 e obelisco; `579ce02` pegada da Emeth; `b29e372` luta refinada (foice, lâminas, investida, transições, invocação, maldição, tempestade, vitória); `1f9d49c` agente game-director (só documentos); `2de07b0` evidências; `147b481` bloqueio de corpo como no Hades II |
| Versão capturada | `b29e372` (o `1f9d49c` e o `2de07b0` não mudam jogo). **O `147b481` (bloqueio de corpo) não tem captura nem medida de quadro**: só os testes abaixo |

## 2. Mudanças por fase

**Fase 1, O Despertar (100 a 66%)**
- Foice Sepulcral: lâmina erguida num preparo esticado até o fim do aviso; no golpe, um arco violeta com borda
  verde-azulada desenhado na malha do setor de dano, rastro curto, cinzas só de dentro do setor, recuperação legível
  ([02](02_foice_preparacao.jpg), [03](03_foice_ataque.jpg)). O aviso do preparo continua o vermelho comum.
- Lâminas das Almas: meia-lua com núcleo claro, fumaça do violeta ao espectral e rastro curto; colisão igual
  ([04](04_laminas_almas.jpg)).
- Investida: postura agachada, faixa violeta com bordas verde-azuladas revelada enquanto ele corre, impacto no fim da
  faixa ([05](05_investida.jpg)).
- Transições (todas): rugido de 1,6 s, anel fino violeta, almas na mão, nome da fase e dica sob a barra; o quadro
  branco e preto da troca saiu ([06](06_transicao_fase2.jpg), [10](10_transicao_fase3.jpg), [13](13_transicao_fase4.jpg)).

**Fase 2, O Ritual dos Mortos (66 a 33%)**
- Escudo translúcido esmeralda corrompido e violeta com faixas de runas girando e Morvath visível por dentro; quebra
  em estilhaços ([07](07_ritual_escudo.jpg), [08](08_ritual_invocacao.jpg)).
- Invocação: um morto por vez (0,45 s entre eles), cada um com círculo de runa, coluna espectral e animação de subir.
- Erupções: círculos de runa cujo aro é exatamente a área de dano, brilho crescente, pulso duplo e coluna espectral
  ([09](09_erupcoes.jpg), [comparação de perto](work/c9b_comparacao_escudo_erupcoes.jpg),
  [runa sob o herói](work/c9b_comparacao_runa_aviso.jpg)).
- Golpe no escudo não dá clarão, número, fogo nem gelo: só três faíscas espectrais (antes o corpo inteiro ficava
  dourado de fogo através do escudo, [antes](../morvath/04_ritual_escudo_erupcoes.jpg)).

**Fase 3, A Maldição dos Condenados (33 a 15%)**
- Preparo com a mão erguida, onda ao longo da faixa, aro fino roxo sob o herói ao pegar.
- No herói: aura violeta fraca, quatro runas pequenas fora do rosto, veios violeta na Emeth
  ([12](12_explorador_amaldicoado.jpg), [de perto](work/c9c_maldicao_heroi_zoom.jpg)).
- Na HUD: selo "Amaldiçoado / Mais lento e sem especial" com anel que esvazia, especial com cadeado, aro violeta no
  retrato ([11](11_maldicao_aplicacao.jpg)). Avisos ficam mais longos na proporção da lentidão.

**Fase 4, O Último Suspiro (15 a 0%)**
- Tempestade: seis meias-luas que saem uma por vez (0,08 s), cada uma com seu rastro e seu aviso
  ([14](14_tempestade_seis_almas.jpg)).
- Combinações só nesta fase, nunca dois ataques dele no chão ao mesmo tempo ([15](15_combate_final.jpg)).
- Portal instável (pulsa do espectral ao violeta), borda de Morvath no verde corrompido, 1,8 vez mais forte.

**Vitória**
- 3,6 s com controle: o brilho dele se apaga, a energia corre até o altar, o portal volta ao verde, a Emeth brilha,
  duas linhas de texto, depois a tela "Morvath foi selado" no estilo do título, com espólios, Continuar e Descer de novo
  ([16](16_morvath_derrota.jpg), [17](17_portal_selagem.jpg), [18](18_tela_vitoria.jpg)). Saíram as colunas brancas e as
  partículas amarelas do fim antigo.

**Fora da luta, no ciclo**
- Obelisco: círculo pontilhado em volta do herói atrás dele, no lugar do corpo desenhado em cima da pedra
  ([comparação](work/c9b_comparacao_obelisco.jpg)).
- Números: mais de 6 números comuns num quadro viram um total ([depois](work/c9c_numeros_horda_1080.jpg),
  [antes](work/c9c_antes_numeros_horda_1080.jpg)).
- Pegada da Emeth: a lâmina sai do lado do indicador, à frente do corpo, um pouco abaixo da horizontal
  ([depois](../hero/grip/depois_jogo_run_close.jpg), [antes](../hero/grip/antes_jogo_run_close.jpg)).
- Bloqueio de corpo como no Hades II (`147b481`): sem captura, julgado só pelos testes.

## 3. Capturas antes e depois

Mesmo comando e mesma semente em `3b22cea` e `b29e372`; os tempos dos ataques mudaram, então a pose não é a mesma.

| Montagem | O que mostra | Leitura |
|---|---|---|
| [before_after_foice](before_after_foice.jpg) | preparo e golpe | O golpe deixou de ser uma fita verde como a da Emeth e virou o arco violeta com borda espectral só no setor; o preparo ganhou a lâmina erguida. O aviso vermelho é o mesmo nas duas |
| [before_after_ritual](before_after_ritual.jpg) | ritual + 1,2 s e + 3 s | Escudo com runas e Morvath legível dentro; círculos vermelhos chapados viraram runas. Surgiu um ponto branco estourado no alto do escudo (B2) |
| [before_after_maldicao](before_after_maldicao.jpg) | 5,2 s depois da maldição | Antes não havia nada no herói nem na HUD; agora selo, cadeado e aro violeta no retrato. A tela está tingida de vermelho no quadro depois (B3) |
| [before_after_tempestade](before_after_tempestade.jpg) | `storm_fire` + 0,25 s | As seis saíam juntas, todas em verde-água igual ao da Emeth; agora saem em sequência, violeta com fio espectral, e Morvath tem a borda corrompida |
| [before_after_vitoria](before_after_vitoria.jpg) | queda e 1,5 s depois | Antes: partículas amarelas e duas colunas brancas enormes. Depois: câmera lenta curta, mas Morvath fica quase branco (B1); a tela de vitória é nova |

Capturas da luta antes do ciclo: [`../morvath/`](../morvath/) (por exemplo [maldição](../morvath/06_maldicao_heroi.jpg)
sem nenhum sinal no herói e [ritual](../morvath/04_ritual_escudo_erupcoes.jpg) com Morvath e um feiticeiro dourados
de fogo).

## 4. Comparação com a Hécate (Hades II)

**Limitação: as nove capturas da Hécate que o Daniel citou não chegaram a esta sessão. A comparação visual com elas não
foi feita.** O que segue compara com o que se sabe da Hécate pelos dados do jogo do Daniel, resumidos na seção 2 de
[morvath_boss_fight.md](../../design/morvath_boss_fight.md); nada de arte, nome ou figura da Hécate foi usado.

| Hécate (dados) | Morvath (ciclo 9) | Leitura |
|---|---|---|
| 6050 de vida, trocas em 66% e 33% | 6050, trocas em 66%, 33% e 15% (pedido de quatro fases do Daniel) | Estrutura mais longa no fim; a fase 4 é curta (15 a 20 s nas simulações) |
| Interlúdios com objetivo e invocações | Fase 2 abre num ritual com escudo que só cai derrubando os mortos | Mesma função (mudar o ritmo, dar alvo diferente); aqui não há interlúdio separado |
| Armas por fase, combos no fim | Cada fase abre no próprio padrão; combinações só na fase 4 | Mesma progressão |
| Transformar o jogador (interlúdio 2) | Maldição: mais lento e sem especial, controle mantido | Versão mais leve, com selo e duração na HUD |
| Todo ataque com aviso no chão | Todo ataque com aviso; erupções e invocação com runa própria; foice, maldição e tempestade com o vermelho comum | Parcial na identidade (B4) |

## 5. Fidelidade à identidade de Eterra

Paleta pedida: violeta profundo, azul espectral, esmeralda corrompido, ouro antigo, pedra escura; sem amarelo
saturado, clarões brancos, partículas sobre o herói, indicadores genéricos ou poluição constante.

**O que bate**
- Os efeitos dele são violeta e espectral em toda parte: foice, investida, lâminas, tempestade, anéis das transições,
  aura da maldição. O verde vivo deixou de ser dele e ficou da Emeth e do portal ([before_after_tempestade](before_after_tempestade.jpg)).
- Runas no chão dão o ar ritualístico pedido e o aro coincide com a área de dano.
- O fim ficou sóbrio: sem colunas brancas nem chuva de partículas amarelas; ouro antigo só no aro do ritual rompido e
  no texto.
- A HUD (selo, cadeado, marcas de fase na barra, tela de vitória) usa a mesma moldura e o ouro velho do resto.

**O que difere**
1. **Portal vermelho saturado nas fases 1 a 3** ([01](01_morvath_fase1.jpg) a [12](12_explorador_amaldicoado.jpg)): o
   terço superior direito da tela é vermelho vivo durante 80% da luta, cor que não está na paleta de Morvath. Só a fase 4
   e a vitória mudam o portal. Vem do ciclo 8; precisa de decisão do Daniel (pergunta abaixo).
2. **Clarões brancos que continuam**: Morvath quase branco no golpe final (B1); pontos brancos no escudo (B2); quadros
   de impacto em preto e branco dos finalizadores do herói a cada 5 s em média dentro da luta (N1); coluna de núcleo
   branco da Lança de Luz sobre Morvath (N2).
3. **Indicadores genéricos**: os avisos da foice, da maldição e da tempestade são o vermelho de qualquer inimigo (B4);
   na fase 4 as seis faixas vermelhas cruzam a sala inteira ([15](15_combate_final.jpg)).
4. **Amarelo saturado** na peça dourada em gancho do modelo de Morvath (na cintura e na mão, [02](02_foice_preparacao.jpg),
   [15](15_combate_final.jpg)); é pintura do modelo do Meshy, não efeito.
5. **Esmeralda corrompido pouco turvo**: o escudo e as colunas das erupções ([07](07_ritual_escudo.jpg),
   [09](09_erupcoes.jpg)) são verde-menta claro, perto do verde da Emeth, não "mais turvo e frio" como o design pede.

## 6. Problemas corrigidos

- Fogo dos dons atravessando o escudo (corpo dourado, [antes](../morvath/04_ritual_escudo_erupcoes.jpg)).
- Quadro branco e preto na troca de fase; colunas de luz brancas e partículas amarelas na vitória.
- Ataques de Morvath no mesmo verde-água da Emeth (foice e tempestade).
- Herói atrás do obelisco desenhado por cima da pedra (pendência do ciclo 8, item 7).
- Pilha de números ilegível com muitos alvos (pendência do ciclo 8).
- Maldição invisível no herói e na HUD.
- Erupções e invocações como círculos vermelhos chapados.
- Emeth segurada ao contrário (lâmina para trás).
- Tempestade com as seis saindo juntas (agora em sequência, cada uma com aviso próprio).

## 7. Pendências

Prioridade: **A** antes do teste do Daniel se for barato; **B** no próximo ciclo; **C** quando houver tempo ou créditos.

| # | Prioridade | Achado e meu veredito olhando as imagens | Responsável | Pedido concreto | Critério de aprovação |
|---|---|---|---|---|---|
| B1 | A | **Confirmo.** Em [16](16_morvath_derrota.jpg) e [before_after_vitoria](before_after_vitoria.jpg) o corpo inteiro de Morvath está marfim claro, quase silhueta branca, 0,4 s depois do golpe final. Contradiz "sem clarões brancos" e o próprio design ("o brilho dele se apaga"). Provável: o pisca de dano esticado pela câmera lenta | gameplay-engineer | No golpe final, sem pisca de dano (ou no máximo 1 quadro). Durante os 3,6 s, o corpo escurece: albedo multiplicado de 1,0 até 0,55, saturação até 0,5, `paint_glow` e borda a zero; nada passa de 0,8 de luminância | Captura `victory` + 0,4 s e + 1,0 s: Morvath em pedra escura violeta, com a mesma leitura de forma, nenhum pixel do corpo acima de 0,85 de luminância |
| B2 | A | **Confirmo e é maior do que o QA disse.** Em [07](07_ritual_escudo.jpg) há uma esfera branca estourada no alto do escudo; no vídeo, no começo do ritual, são duas a três ao mesmo tempo, girando em volta dele, maiores que a cabeça de Morvath. São as partículas que orbitam o escudo, ou o reflexo especular da esfera. O orbe violeta com miolo branco à esquerda em [c9b_comparacao_escudo_erupcoes](work/c9b_comparacao_escudo_erupcoes.jpg) é outro caso (ver N3) | environment-artist | Partículas do escudo: cor esmeralda corrompido ou espectral, energia máxima 1,2 (abaixo do limiar do brilho mais 20%), raio no máximo 0,12 m; material do escudo sem especular (`specular` 0, `roughness` 1) | Captura do ritual + 1,2 s e quadros do vídeo no começo do ritual: nenhum ponto branco; partículas visíveis como pontos verdes ou azuis menores que a mão dele |
| B3 | B | **Parcial.** Medi o matiz quadro a quadro no vídeo de ataques: cada golpe sofrido amaldiçoado tinge a tela por cerca de 0,3 s (63,1 a 63,4 s e 65,0 a 65,3 s), com separação de cores nas bordas ([11](11_maldicao_aplicacao.jpg)). Não é um tingido contínuo; é o vermelho de dano repetido a cada golpe da maldição, o que dá a sensação de tela vermelha longa. E é vermelho, não a cor da maldição | ui-ux-designer | Dano recebido amaldiçoado: tingido violeta (a cor da aura), alfa no máximo 0,2, 0,2 s, sem separação de cores; o tingido vermelho comum fica para golpes acima de 10 de dano | Quadros do vídeo na maldição: a sala nunca fica avermelhada; um tingido violeta curto e fraco a cada golpe |
| B4 | B | **Confirmo, e vale também para a maldição e a tempestade.** O aviso da foice é o setor vermelho comum ([02](02_foice_preparacao.jpg)); o da maldição são três faixas vermelhas com setas ([11](11_maldicao_aplicacao.jpg)); o da tempestade são seis faixas vermelhas largas ([15](15_combate_final.jpg)). O brief pede "sem indicadores genéricos". Não proponho tirar o vermelho: é o código de perigo do jogo inteiro e lê bem | environment-artist (aparência do aviso) e gameplay-engineer (passar a origem `Zone.source` ao desenho) | Avisos de Morvath: o mesmo vermelho de perigo, alfa do miolo 0,35 (hoje mais forte), com um aro violeta de 2 px na borda e uma faixa fina de runas espectrais correndo na borda externa (o mesmo desenho do `ritual_rune.gdshader`); a tempestade com as seis faixas numeradas pela ordem de saída, a próxima mais forte | Capturas de `scythe_warn` + 0,5 s, curse e storm: o aviso se reconhece como de Morvath sem ver ele, e o chão continua legível através das seis faixas |
| M1 | B | **Concordo; risco de arte também.** A investida nunca saiu em 80 lutas do robô, então o aviso e a faixa dela só foram vistos com `--boss-only=dash` ([05](05_investida.jpg)). Nenhuma captura mostra a investida numa luta real, com mortos ou combinação | gameplay-engineer | Um modo do robô que se afaste (por exemplo, a cada 20 s fica 2 s a mais de 10 m) ou um teste da investida em luta | Pelo menos uma investida por luta nas simulações; QA captura uma na fase 4 (combinação tempestade e investida) |
| B8 | B (Daniel) | **Simulação, não julgo diversão.** Com reação de 0,25 s o robô morre sobretudo na fase 4 (15 de 18 derrotas com dons de um estilo). Na arte, a fase 4 é a mais carregada: seis faixas vermelhas cruzando a sala ([15](15_combate_final.jpg)) mais as meias-luas e o portal pulsando. Parte da dificuldade pode ser leitura, não número | gameplay-engineer e Daniel | Teste com o Daniel antes de mexer em números; se ele achar injusto, primeiro o B4 (avisos legíveis por ordem), depois números | Daniel vence a fase 4 em até três tentativas e diz que viu de onde veio o golpe que o matou |
| N1 | A | **Novo.** Quadros de impacto em preto e branco (`Fx.impact_frame`, dos finalizadores do herói, ciclo 7) aparecem 24 vezes na luta gravada de 121 s, cada um com 4 quadros (cerca de 67 ms), uma vez a cada 5 s em média; outros 15 no vídeo de ataques. A tela inteira vira preto com manchas brancas e apaga os avisos por esse tempo. É um clarão de tela inteira repetido, o oposto do pedido | gameplay-engineer (decisão de identidade com o Daniel) | Na luta de Morvath: só no Ômega e no golpe que derruba uma fase, no máximo um a cada 10 s; opção nas Configurações para desligar (sensibilidade à luz) | Folha de quadros da luta inteira: no máximo 12 quadros de impacto em 2 min; com a opção desligada, nenhum |
| N2 | B | **Novo.** Uma coluna de núcleo branco desce sobre Morvath com a Lança de Luz do herói (vídeo da luta, 20,4 s e 29,6 s) e cobre o corpo dele. O design tirou o `Fx.beam` de Morvath porque o núcleo vai ao branco; no herói ele continua | gameplay-engineer | Núcleo do `beam` na cor do dom (marfim morno ou esmeralda), mistura com o branco no máximo 0,3, largura do núcleo no máximo 40% da coluna | Quadros da Lança de Luz sobre Morvath: a silhueta dele continua lida através da coluna |
| N3 | B | **Novo (o orbe do feiticeiro).** O projétil do feiticeiro é uma esfera violeta com miolo branco estourado e brilho grande ([horda](work/c9c_numeros_horda_1080.jpg): dezenas delas viram uma nuvem branca; [escudo](work/c9b_comparacao_escudo_erupcoes.jpg)). Nos mortos do ritual também aparece | environment-artist | Orbe do feiticeiro: violeta frio do `magic_color`, miolo no máximo 30% do raio e energia até 1,3, sem halo maior que 1,5 vez o raio | Captura com 6 feiticeiros atirando: orbes violeta distintos, nenhum ponto branco maior que a cabeça de um esqueleto |
| N4 | B | **Novo (queimadura dourada).** O fogo dos dons pinta o inimigo inteiro de dourado alaranjado ([antes](../morvath/04_ritual_escudo_erupcoes.jpg): o feiticeiro ao lado do escudo). No escudo foi corrigido; nos inimigos comuns continua, e nenhuma captura deste ciclo usa fogo, então o estado atual não foi visto. Amarelo saturado no corpo inteiro tira a leitura da forma e briga com o ouro velho das elites | environment-artist (`crowd.gdshader`) | Queimadura como brasas na borda (rim laranja, alfa até 0,5) e pontos de brasa, sem tingir o albedo; nunca amarelo puro | QA: capturas com `--boon-ids` de fogo na fase 1 e no ritual; o esqueleto queimando continua lido como esqueleto e diferente de uma elite |
| N5 | B | **Novo.** No começo do ritual a coluna espectral sobe sobre Morvath e o cobre por cerca de 0,75 s (vídeo da luta, cerca de 35,8 a 36,5 s; também em [c9c_fase_escudo_1080](work/c9c_fase_escudo_1080.jpg), da frente C). Critério do brief: "ritual sem esconder Morvath" | environment-artist | Coluna do escudo atrás e em volta dele, alfa até 0,4 na altura do corpo, ou a coluna só nos círculos dos mortos | Quadros a cada 0,1 s no começo do ritual: Morvath sempre lido |
| N6 | C | **Novo.** Pontos amarelos saturados em volta do herói (as partículas do círculo de luz ou do golpe, [c9b_comparacao_invocacao](work/c9b_comparacao_invocacao.jpg), [c9b_comparacao_runa_aviso](work/c9b_comparacao_runa_aviso.jpg)) | gameplay-engineer | Partículas perto do herói em ouro velho (`UiKit.OLD_GOLD`) ou marfim, energia até 1,1, e nunca entre a câmera e o tronco dele | Recorte do herói no círculo: nenhum ponto amarelo puro sobre o corpo |
| N7 | C (Daniel) | **Pergunta.** Portal vermelho nas fases 1 a 3 (seção 5, item 1) | Game Director pergunta ao Daniel; environment-artist executa | Proposta: violeta profundo apagado nas fases 1 a 3 (a corrupção dele), espectral instável na 4, verde na vitória | Daniel aprova a cor por captura de fase 1 |
| N8 | C (créditos) | Peça dourada em gancho no modelo de Morvath em amarelo saturado | Daniel (créditos do Meshy) | Repintura (`retexture`, cerca de 10 créditos) com o metal em ouro antigo apagado; sem crédito, nada | Captura de fase 1: nenhum amarelo saturado no corpo dele |
| N9 | C | Esmeralda corrompido claro demais no escudo e nas colunas (seção 5, item 5) | environment-artist | Escudo e colunas: verde-azulado mais frio e escuro (por exemplo, matiz 165 graus, saturação 0,55, valor 0,7 no máximo), deixando o verde-menta vivo só para a Emeth | Escudo e Emeth na mesma captura: os dois verdes se distinguem sem ler a forma |
| B5, B6, B7 | C | Dica do ritual sem ritual com `--boss-hp`, "Novo melhor tempo" com `--nosave`, métrica do ritual zerada: só em teste, sem efeito na arte | gameplay-engineer e ui-ux-designer | Como no QA | Como no QA |
| M2 | C | Desempenho com 2 rodadas em vez de 3 | QA | Repetir na tomada | Mediana de 3 por cena |

Dependem de modelo que não existe: a foice (Morvath golpeia com a lâmina do modelo aprovado, não com uma foice; o arco
resolve a leitura, a arma não); as caveiras nas meias-luas; a repintura do gancho (N8). Nada gerado no Meshy neste ciclo.

## 8. Avaliação das quatro fases

- **Fase 1**: a melhor. Foice com preparo, arco no setor e recuperação; lâminas com núcleo; investida com faixa
  revelada. Falta só a assinatura no aviso (B4).
- **Fase 2**: o ritual tem a cara pedida (escudo de runas, mortos subindo um a um, erupções como círculos precisos).
  Pontos brancos (B2), a coluna que o cobre no começo (N5) e o verde claro demais (N9) são o que separa do pedido.
- **Fase 3**: a maldição tem identidade (aura, runas, veios na Emeth, selo com duração, cadeado), mas em jogo a aura e as
  runas são pequenas; o que se nota primeiro é o vermelho de dano (B3). Ver [12](12_explorador_amaldicoado.jpg) e o
  [recorte](work/c9c_maldicao_heroi_zoom.jpg): de perto lê, a 54 m de câmera lê pelo selo da HUD.
- **Fase 4**: portal muda de cor, borda corrompida nele, seis meias-luas separadas e distinguíveis
  ([14](14_tempestade_seis_almas.jpg)). A atmosfera muda pouco além do portal
  ([comparação do portal](work/c9b_comparacao_portal_fase4.jpg) mostra pouca diferença no pulso); os avisos vermelhos
  dominam a tela ([15](15_combate_final.jpg)).
- **Transições**: curtas e claras (1,6 s, anel fino, nome da fase); na luta gravada a da fase 2 é limpa quadro a quadro.

## 9. Qualidade dos indicadores

- Precisos: todos coincidem com a área de dano (testado em `tests/test_boss_refine.gd`; nas capturas, o arco da foice
  fica dentro do setor e o aro da runa é a borda da erupção).
- Antecipáveis: o robô com 0,25 s de reação quase nunca leva a foice (0 golpes nas lutas a partir do chefe), sinal de
  que o preparo de 0,8 s se lê. A maldição e a tempestade ferem mais (seção 12).
- Identidade: runa nas erupções e na invocação, vermelho comum nos outros (B4).
- Poluição: na fase 4, as faixas da tempestade cobrem boa parte da sala por um momento; os quadros de impacto (N1) e os
  pontos brancos (B2) são a poluição que mais pesa.

## 10. Legibilidade do Explorador

- Lê em quase todas as capturas: cabelo laranja, capa verde, a Emeth à frente do corpo depois da correção da pegada
  ([depois](../hero/grip/depois_jogo_run_close.jpg)).
- Atrás do obelisco: o círculo pontilhado resolve o "em cima da pedra" do ciclo 8
  ([comparação](work/c9b_comparacao_obelisco.jpg)); o pontilhado fica áspero, mas lê.
- Colado em Morvath ([04](04_laminas_almas.jpg)) ou dentro da borda do escudo ([07](07_ritual_escudo.jpg)), o corpo dele
  se mistura com o de Morvath; o anel petróleo no chão o acha.
- Amaldiçoado, ele fica arroxeado ([recorte](work/c9c_maldicao_heroi_zoom.jpg)) e continua lido.
- Nenhuma partícula do chefe sobre ele; as do próprio herói em amarelo (N6) são as únicas.

## 11. Testes e desempenho (copiados do QA, mais os testes no HEAD)

- QA (`b29e372`): importação e `check.gd` com 0 `SCRIPT ERROR` e 0 `Parse Error`; 323 testes, 322 passando, 0
  falhando, 1 arriscado (o conhecido); fluxo do título ok; 80 simulações sem erro; as cinco partidas inteiras de
  regressão vencem Morvath.
- Rodei `tools/test.sh` no HEAD `147b481` (com o bloqueio de corpo): **28 arquivos, 338 testes, 337 passando, 0
  falhando, 1 arriscado** (`test_only_finishers_glint`, o conhecido), 38369 asserções.
- Quadro a 1920 x 1080 na RTX 5060, na tomada (2 rodadas por cena, não 3: o notebook foi para a bateria):

| Cena | Antes (`3b22cea`) | Depois (`b29e372`) | Diferença | p90 depois | Primitivas antes / depois |
|---|---|---|---|---|---|
| fase 1 | 5,16 ms | 5,50 ms (cerca de 182 FPS) | +0,34 | 6,08 a 6,35 | 738 mil / 737 mil |
| ritual | 5,44 ms (1 rodada) | 5,53 ms (cerca de 181 FPS) | +0,09 | 6,14 a 6,42 | 872 mil / 1,155 milhão |
| fase 4 | 5,28 ms (1 rodada) | 5,42 ms (cerca de 185 FPS) | +0,14 | 5,89 a 6,26 | 729 mil / 732 mil |

- O `147b481` não foi medido na placa de vídeo.

## 12. Balanceamento observado (simulação do robô, não diversão)

- Reação 0: 32 de 32 vitórias começando no chefe; 7 de 8 nas partidas inteiras. Não mede dificuldade.
- Reação 0,25 s: com seis dons de um estilo vence 2 (fogo), 3 (geada) e 1 (luz) de 8; com dons sorteados, 8 de 8;
  partida inteira (1 ou 2 dons), 1 de 8. Das 18 derrotas com estilo fixo, 15 na fase 4; nas partidas inteiras, 4 de 7
  no ritual.
- O que mais fere com 0,25 s: os mortos invocados (16 a 26 golpes de 4), a tempestade (6 a 12 golpes de 10), a
  maldição (7 a 9 golpes de 6). A foice quase nunca acerta. A investida nunca saiu (M1).
- Fases nas vitórias (mediana): 26 a 35 s, 40 a 56 s, 15 a 20 s, 15 a 20 s. Luta de 98 a 128 s, abaixo da meta de 2 a
  4 min do design, com o robô punindo 65 a 90% das janelas.
- A luta gravada (geada, semente 1, reação 0,25) venceu com 14 de vida em 121,3 s.

## 13. Critérios de aceite

| Critério | Veredito | Evidência |
|---|---|---|
| Quatro fases funcionando | SIM | [06](06_transicao_fase2.jpg), [10](10_transicao_fase3.jpg), [13](13_transicao_fase4.jpg); luta gravada com fases em 32,2 / 85,2 / 105,4 s; 80 simulações |
| Identidade por fase | PARCIAL | Cada fase tem nome, padrão de abertura e efeito próprio (ritual, maldição, portal da 4); a atmosfera da sala quase não muda entre 1 e 3, e o portal vermelho domina as três (N7) |
| Ataques antecipáveis | SIM | Todos com aviso e preparo; foice com 0 golpes nas lutas do robô com reação humana; tempestade e maldição ferem mais, mas com aviso |
| Efeitos sincronizados com a área real de dano | SIM | Arco da foice na malha do setor ([03](03_foice_ataque.jpg)), runas com aro na borda do dano ([c9b_comparacao_runa_aviso](work/c9b_comparacao_runa_aviso.jpg)), lâminas sem mudar colisão; testado em `test_boss_refine.gd` |
| Ritual sem esconder Morvath | PARCIAL | Lido dentro do escudo ([07](07_ritual_escudo.jpg), [08](08_ritual_invocacao.jpg)); coberto pela coluna por cerca de 0,75 s no começo (N5) e pelos pontos brancos (B2) |
| Maldição reconhecível | SIM | Selo, cadeado, aura e runas ([11](11_maldicao_aplicacao.jpg), [12](12_explorador_amaldicoado.jpg)); o tingido vermelho repetido atrapalha (B3) |
| Seis lâminas distinguíveis | SIM | [14](14_tempestade_seis_almas.jpg): seis meias-luas separadas, saindo em sequência, cada uma com rastro |
| Explorador visível | SIM | Seção 10; colado em Morvath só pelo anel |
| Sem travar | SIM | 0 `SCRIPT ERROR` em 80 simulações, 36 capturas, 9 gravações; luta inteira gravada sem cortes |
| Luta vencível | SIM (robô) | 32 de 32 com reação 0; 14 de 32 com 0,25 s e dons fixos ou sorteados; falta gente (B8) |
| Vitória satisfatória | PARCIAL | Curta, com selagem e tela no estilo do título ([17](17_portal_selagem.jpg), [18](18_tela_vitoria.jpg)); Morvath quase branco no golpe final (B1); a selagem em si é um fio de partículas pequeno. "Satisfatória" é julgamento do Daniel |
| Sem regressão grave de desempenho | SIM | +0,09 a +0,34 ms a 1080p, p90 abaixo de 6,5 ms; ressalva de 2 rodadas |
| Testes passando | SIM | 337 de 338 no HEAD, 0 falhando, 1 arriscado conhecido |
| Screenshots publicados | SIM | 18 capturas, 5 montagens, 2 vídeos e 50 de trabalho nesta pasta |
| Sem clarões brancos (brief) | NÃO | B1, B2, N1, N2 |
| Sem indicadores genéricos (brief) | PARCIAL | Runas nas erupções e invocação; vermelho comum na foice, maldição e tempestade (B4) |
| Sem amarelo saturado nem partículas sobre o herói (brief) | PARCIAL | Efeitos dele sem amarelo; gancho do modelo (N8), pontos amarelos do herói (N6), queimadura não verificada (N4) |

## 14. Veredito

**Aprovado para o teste do Daniel, com ressalvas.** A luta tem quatro fases que funcionam, cada ataque se lê pelo
preparo e pelo aviso, os efeitos cobrem exatamente a área de dano, a maldição se reconhece, as seis lâminas se
distinguem, o Explorador continua visível e nada travou. A identidade pedida (violeta, espectral, runas, fim sóbrio)
está clara nos efeitos dele e é uma melhora grande sobre o `3b22cea`.

Não declaro o brief cumprido em três pontos que se veem nas capturas: os clarões brancos (Morvath branco na vitória,
pontos brancos no escudo, quadros de impacto a cada 5 s, coluna da Lança de Luz), os avisos genéricos em vermelho
comum na foice, na maldição e na tempestade, e o portal vermelho que domina as fases 1 a 3. B1, B2 e N1 são baratos
e eu os faria antes de entregar; B4, B3 e o resto podem ir para o próximo ciclo. A dificuldade da fase 4 só se decide
com o Daniel jogando. A aprovação artística final é dele.

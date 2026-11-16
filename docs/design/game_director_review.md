# Revisão do Game Director: a Fase 1 como vertical slice

- **Data**: 2026-11-15. **Commit lido**: `6dbcec5` (o jogo é o do `147b481`). **Autor**: game-director, primeira revisão
  oficial, pedida pelo Daniel. Só análise: nenhum código, dado ou asset foi mudado.
- Backlog com todos os itens, prioridades e critérios: [`docs/backlog.md`](https://github.com/DaniSacra/eterra-a-selagem/blob/arpg-3d/docs/backlog.md).
- O que é opinião minha está escrito como opinião. O que é número veio de arquivo, captura, quadro de vídeo ou de uma
  simulação que rodei (comando ao lado). **Simulação do robô não é diversão**: o robô não erra mira, não usa a seta de
  longe e nunca se afasta.

## Atualização de 2026-11-16 (C10 e C11)

Commit lido: `552b55c`. Itens, evidências e critérios no [`docs/backlog.md`](../backlog.md). O que segue abaixo desta
seção é a revisão de 2026-11-15 (ciclo 9), mantida como histórico.

### Estado
- **Pronto para o Daniel jogar.** Morvath luta na Câmara do Selo: círculo de 12,5 m sobre o abismo, selo de ouro com o
  leão de pé e a rachadura que cresce por fase, porta selada ao norte, escadaria a sudoeste, câmera fixa que mostra a
  câmara inteira. As salas 1 a 4 seguem no salão.
- O C10 tirou os clarões e a confusão do ritual: quadro P&B raro (com opção para desligar), escudo, orbe e golpe final sem
  branco, escudo que cai com os 4 primeiros mortos (contador em losangos), dano tingindo só as bordas, "Derrotado por",
  registro de cada partida.
- Fechado pela rodada `552b55c` (medi nas capturas novas): chão da câmara mais claro (luminância 41 a 45, meta 40 a 55),
  céu azul no topo, erupções com miolo vermelho, faixas da tempestade sem somar entre si, coluna de geada e pisca de
  Morvath abaixo do marfim.
- **Ainda aberto**: o centro da tempestade continua claro (luminância 121, meta até 90; o aro do círculo do herói passa
  ali); só 8 janelinhas no anel distante (meta 10 a 20); velas da balaustrada sul sobre as pernas do herói; a estrela da
  vitória estoura (25% do miolo acima de 200). Nada disso impede jogar.

### Métricas (simulação do robô, não diversão)
| Medida | Câmara (`6bab080`) | Salão (C10) |
|---|---|---|
| Vitórias, reação 0,25, 4 kits com um dom de defesa | 57 de 64 | 43 de 64 |
| Partidas inteiras, reação 0,25 (chega com 1 a 3 dons) | 4 de 8 | 1 de 8 |
| Ritual, mediana nas partidas inteiras | 10,8 s | 10,3 s (ciclo 9: 20 s) |
| Investida com o robô se afastando | em 72 de 72 lutas, nunca acertou | |
| Robô preso | 0 em 136 lutas | não medido |
| Duração nas vitórias | 92 a 162 s (meta 2 a 4 min) | |
| Quadro a 1080p, p90 (RTX 5060) | 4,0 a 4,8 ms | 4,9 a 5,8 ms |

Onde o robô morre: fase 4 (tempestade e maldição) e os mortos invocados. Testes: 413 de 413, 0 arriscados.

### Roteiro da partida de hoje (cerca de 20 minutos)
Build de Windows da pasta de teste. Jogar **3 partidas seguidas, sem `--nosave`** (o registro só grava com save). Depois,
mandar o arquivo `%APPDATA%\EterraASelagem\runs.jsonl`. Anotar à mão o minuto de cada coisa abaixo, numa linha só.
1. **Partida 1, com tudo ligado.** Nas salas: o bloqueio de corpo (ficou preso? o combo parou num inimigo do meio?).
   Na câmara, ao entrar: a câmara inteira lê bem? Dá para ver o herói em todo canto, inclusive na borda de baixo?
2. **Morvath, fase a fase.** Fase 1: a investida aparece quando você se afasta; deu para ver chegando? Fase 2: sem ler a
   dica, você entendeu o que fazer para quebrar o escudo? Fase 3: percebeu a maldição (mais lento, especial travado)?
   Fase 4: achou o vão da tempestade ou foi sorte? O centro vermelho atrapalhou ver Morvath?
3. **Cada morte**: de 1 a 5, quanto você viu o golpe chegando? A tela "Derrotado por" bateu com o que você sentiu?
4. **Partida 2, com "Clarões de impacto" desligado nas Configurações**: fez falta? O quadro P&B, quando aparece, vale a pena?
5. **Partida 3, livre**: quantos minutos durou a luta e se pareceu longa ou curta; se deu vontade de descer de novo.
6. **Vitória**: o que entendeu que aconteceu com Morvath? A selagem (selo acendendo, porta fechando) diz isso?
7. **Olhar sem pressa** uma vez: o leão no selo, a espada erguida nos sarcófagos e pilaretes, a porta selada.

### Perguntas para o Daniel
1. Confirma as decisões da noite? Câmara só para Morvath, raio de 12,5 m, porta selada no lugar do portal, leão de pé
   (nas patas de trás) no selo, espada erguida no lugar da cruz, Morvath indo ao centro nas fases 3 e 4, o nome "A Câmara
   do Selo", o quadro P&B limitado com opção, a descida curta por enquanto.
2. O que é a porta selada ao norte e o véu de runas da escadaria? (Não inventamos: sem resposta, fica sem texto.)
3. Depois de jogar: a luta ficou fácil, justa ou difícil? Quantas tentativas você quer para a primeira vitória (D-11)?
4. Sentiu falta de Magia na luta (D-09) ou do bônus de sequência, que não existe no Hades (D-10)?
5. As quatro imagens de Morvath em `docs/art/ref/morvath/` são de IA? (Para o `docs/steam-ia.md`.)
6. Podemos voltar à descida inteira (10 salas e chefe na 11) como padrão no próximo ciclo, com a curta só para teste?


## 1. Diagnóstico

A Selagem tem hoje uma luta completa, do título à selagem, que funciona sem travar (0 erros de script em 80 simulações,
337 de 338 testes passando) e que, em captura, já tem cara de jogo: o salão das catacumbas sobre o abismo, o Explorador
com a Emeth à frente do corpo, a fita do corte, números somados, inimigos com papel, avisos exatos e um Morvath em quatro
fases com identidade violeta e espectral. Para um protótipo de poucas semanas, o combate está acima do esperado em
leitura de golpe e de aviso.

O que separa isso de uma vertical slice excelente não é mais conteúdo; é **prova**. Nada foi jogado por gente além dos
testes curtos do Daniel; a dificuldade, o ritmo e o bloqueio de corpo novo só existem nas métricas do robô; o som é
sintetizado e a música está desligada; e a descida encurtada para teste (5 salas) faz o jogador chegar a uma chefe com os
números da Hécate (6050 de vida) carregando 1 ou 2 dons. Há também quatro coisas que contradizem a direção e se veem nas
capturas: clarões brancos (quadro de impacto, golpe final, escudo, orbe), avisos de Morvath no vermelho genérico, o
portal vermelho dominando a luta e um efeito descrito como pronto que não existe (o brilho de antecipação dos
finalizadores).

### Os 5 problemas mais importantes
1. **Ninguém jogou a versão atual de ponta a ponta com registro.** Sem dado de gente, cada ajuste de dificuldade é chute
   (DT-002, QW-001).
2. **Clarões de tela inteira dentro da luta.** O quadro de impacto preto e branco sai em todo finalizador contra Morvath
   (`combat.gd:186-189` e `278-284`), 24 vezes em 121 s, e apaga os avisos por 67 ms; eu vi o setor da foice sumir no
   quadro de 0:18 do [vídeo da luta](https://github.com/DaniSacra/eterra-a-selagem/blob/arpg-3d/docs/gallery/cycle9/morvath_full_fight.mp4)
   (BUG-001). Mais o Morvath branco no golpe final ([16](https://github.com/DaniSacra/eterra-a-selagem/blob/arpg-3d/docs/gallery/cycle9/16_morvath_derrota.jpg)) e os pontos do escudo.
3. **O ritual promete uma coisa e faz outra.** "Derrube os mortos para quebrar o escudo!", mas os reforços a cada 6 s
   entram na conta (`boss.gd:717`, `795-796`): o escudo cai pelo relógio de 20 s em 6 de 8 partidas inteiras que rodei, e
   os mortos são a maior fonte de dano em todas as configurações (BUG-002).
4. **A descida curta distorce tudo.** Morvath foi feito para 6 a 8 dons e recebe 2 (DT-001). A diferença entre kits que o
   QA viu (fogo, geada e luz 1 a 3 de 8; sorteados 8 de 8) não é de estilo: os kits fixos não têm dom de defesa. Trocando
   um único dom do kit de luz (onda_maior por firmeza, +20 de vida) o robô 0,25 passou de 2 para 7 vitórias em 8
   (`tools/smoke.sh 600 --start=boss --bot-reaction=0.25 --seed=1..8 --boon-ids=golpe_radiante,pesado_radiante,circulo_radiante,passo_radiante,firmeza,consolo`).
   Com 30 de vida e reação humana, perde-se por pouco: sobravam 136 a 766 de Morvath nas derrotas.
5. **Falta som.** O "peso" do golpe do Ember & Blade é metade áudio; hoje só há receitas sintetizadas e nenhum vídeo com
   som (ART-002).

### As 5 melhores oportunidades
1. **Teste com gente, registrado** (QW-001 e o plano da seção 8): o maior ganho de informação por hora de trabalho.
2. **A Câmara do Selo** (pedido novo do Daniel, C11): resolve de uma vez o portal vermelho da luta, os cantos da fase 4,
   a investida que nunca sai e o enquadramento; e dá à luta o palco que a [imagem de referência](https://github.com/DaniSacra/eterra-a-selagem/blob/arpg-3d/docs/design/boss_arena_brief.md) promete.
3. **Avisos com assinatura de Morvath** (ART-001): o mesmo vermelho de perigo com aro violeta e runas; transforma o chefe
   mais legível do jogo no mais reconhecível.
4. **Progressão de dons do Hades** (C12: baralho, raridade em sequência, romã, loja em 3 grupos), já estudada em
   [`hades2_sistemas.md`](https://github.com/DaniSacra/eterra-a-selagem/blob/arpg-3d/docs/design/hades2_sistemas.md): é o
   que dá decisão e vontade de jogar de novo dentro da partida.
5. **Tela de derrota que ensina** (QW-003, "Derrotado por: Tempestade das Seis Almas"): o laço "morri, entendi, volto" é o
   coração de um roguelite, e hoje não existe nada entre partidas.

## 2. A experiência de combate

**O que está bom.** Os números do Hades II estão no lugar (ataque 20/25/60, especial 40, Ômega de 0,8 s, avanço de 0,2 s
com 16 quadros de proteção, vida 30; `tools/make_data.gd` `_feel` e combos). A leitura dos golpes inimigos melhorou muito
nos ciclos 7 e 8: avisos que crescem até o golpe, divisas na direção, papel de cada inimigo pela silhueta. Salas de 4 a 8
de pé, como no Hades, e não mais horda ([20 inimigos, ciclo 8](https://github.com/DaniSacra/eterra-a-selagem/blob/arpg-3d/docs/gallery/cycle8/05_combate_20_inimigos.jpg) é o teto de estresse).

**Onde estamos atrás do Hades II.**
- Progressão dentro da partida: sem romã de verdade por nível, sem lendários, sem martelo, sem baralho de recompensas
  ([comparativo](https://github.com/DaniSacra/eterra-a-selagem/blob/arpg-3d/docs/design/comparativo.md)). Com 5 salas,
  quase não se escolhe nada.
- Magia na luta do chefe: nos quadros do vídeo a barra fica em 0/50 (1:09, 1:51, 1:56). A Magia enche a cada sala
  (`rooms.gd:125`) e só por abate depois (`game.gd:714`); numa luta de uma sala só, o Ômega praticamente some depois dos
  primeiros segundos. Precisa de conferência no Hades II e de medida com gente (D-09).
- Bloqueio de corpo (`147b481`): a fidelidade é boa. Pelos dados do Hades II, inimigo comum com `StopsUnits` e losango
  de 1,6 x 0,8 m, a heroína com 1,2 x 0,6 m, e 15 tipos atravessáveis; os nossos círculos (0,45 a 0,75 m, herói 0,5)
  ficam um pouco menores se o eixo curto do Hades for o chão achatado pela vista (hipótese minha). Não há dano por contato
  (`horde.gd` só fere no golpe), então ficar encostado não machuca. O risco é outro: o avanço do golpe para em qualquer
  corpo (`player.gd:429-431`), e o `BodyBlock.EASE` de 3 m/s é número nosso. **Só o Daniel jogando responde** se o combo
  "morre" num grupo, se ele se sente preso entre dois esqueletos com a esquiva em recarga e se os guardiões (1,0 e 1,1) e
  Morvath (1,4) parecem paredes. Não há captura nem medida de quadro dessa mudança (REG-001).

**Ember & Blade.** A fita, a meia-lua dos finalizadores, o tranco de câmera e a câmera lenta no último abate estão lá. O que
falta para a sensação dele: som; o brilho de antecipação dos finalizadores, que está descrito no `CLAUDE.md` mas tem
`glint = 0` em todos os golpes (BUG-003; o teste que o cobre não verifica nada); e o quadro de impacto, que lá é raro e
aqui virou ruído (BUG-001).

**Controles.** Teclado e mouse e controle existem (`controls.gd`: X ataque, Y especial, B esquiva, RB círculo); o controle
físico nunca foi testado (QA seção 1). Não há botões de toque. A loja compra ao pisar, sem botão de interagir: risco de
compra sem querer, a observar no teste.

## 3. A direção artística

O salão reconstruído da pintura do Daniel é o ponto mais forte do projeto em captura; a paleta dos efeitos de Morvath
(violeta, espectral, runas) foi uma melhora grande no ciclo 9
([antes e depois da tempestade](https://github.com/DaniSacra/eterra-a-selagem/blob/arpg-3d/docs/gallery/cycle9/before_after_tempestade.jpg)).
Concordo com o [ART_REVIEW do ciclo 9](https://github.com/DaniSacra/eterra-a-selagem/blob/arpg-3d/docs/gallery/cycle9/ART_REVIEW.md)
em tudo; três pesos meus:
- **Clarões brancos primeiro** (B1, B2, N1, N2, N3): baratos e são exatamente o que a direção proíbe. O orbe do feiticeiro é
  pendência do ciclo 8 que ficou.
- **O portal vermelho** ocupa o terço superior direito da tela em 80% da luta
  ([fase 1](https://github.com/DaniSacra/eterra-a-selagem/blob/arpg-3d/docs/gallery/cycle9/01_morvath_fase1.jpg)); a
  Câmara do Selo resolve na luta.
- **Peças provisórias**: estátuas, portal e obeliscos de caixa e KayKit seguram a fidelidade à pintura
  ([plano do Meshy](https://github.com/DaniSacra/eterra-a-selagem/blob/arpg-3d/docs/art/meshy_asset_plan.md), 45 créditos
  para as três primeiras). Depois do teste humano.

O herói lê em quase todas as capturas; colado em Morvath só pelo anel no chão
([04](https://github.com/DaniSacra/eterra-a-selagem/blob/arpg-3d/docs/gallery/cycle9/04_laminas_almas.jpg)).

## 4. Morvath, fase por fase

Base: as 18 capturas e os dois vídeos do ciclo 9 (olhei uma folha da luta inteira a cada 6 s, uma da vitrine a cada 4 s e
os quadros de 0:18 a 0:20 a 10 por segundo), `METRICAS.md` e as minhas 24 simulações.

| | Fase 1, O Despertar | Fase 2, O Ritual dos Mortos | Fase 3, A Maldição | Fase 4, O Último Suspiro |
|---|---|---|---|---|
| Visual dos ataques | o melhor da luta: foice erguida, arco violeta no setor exato ([03](https://github.com/DaniSacra/eterra-a-selagem/blob/arpg-3d/docs/gallery/cycle9/03_foice_ataque.jpg)), lâminas com núcleo; a foice é a lâmina do modelo (ele não tem foice; a imagem da Câmara mostra uma) | escudo de runas com ele visível dentro ([07](https://github.com/DaniSacra/eterra-a-selagem/blob/arpg-3d/docs/gallery/cycle9/07_ritual_escudo.jpg)), mortos subindo um a um; pontos brancos e coluna que o cobre por 0,75 s | aura, runas e veios na Emeth; a 54 m de câmera lê pelo selo da HUD ([12](https://github.com/DaniSacra/eterra-a-selagem/blob/arpg-3d/docs/gallery/cycle9/12_explorador_amaldicoado.jpg)) | seis meias-luas distintas ([14](https://github.com/DaniSacra/eterra-a-selagem/blob/arpg-3d/docs/gallery/cycle9/14_tempestade_seis_almas.jpg)); as faixas vermelhas tomam a sala ([15](https://github.com/DaniSacra/eterra-a-selagem/blob/arpg-3d/docs/gallery/cycle9/15_combate_final.jpg)) |
| Avisos | exatos; vermelho genérico na foice | runa própria nas erupções e invocações | três faixas vermelhas | seis faixas vermelhas largas, sem ordem visível |
| Dificuldade (robô 0,25) | foice 0 golpes nas lutas do chefe: lê bem | maior fonte de dano: os mortos; 4 de 7 mortes das partidas inteiras | maldição: 7 a 9 golpes por 8 lutas | 15 de 18 derrotas com dons fixos |
| Janelas | recuperação de 1 s após a foice; 65 a 90% punidas pelo robô (gente pune menos) | o escudo cai e ele fica atordoado 2 s | "golpes pesados o atordoam" | descansos menores, combinações |
| Ritmo | 26 a 35 s | 40 a 56 s, ritual no limite de 20 s com frequência (BUG-002) | 15 a 20 s | 15 a 20 s |
| Opinião | pronta | regra a corrigir | leitura no corpo pequena demais, tingido vermelho errado (BUG-007) | difícil por leitura antes de por número |

- **Investida**: nunca saiu em 80 lutas. Pelos dados, a 10 m ou mais ela tem cerca de 22% das escolhas (pesos lâminas 4,4,
  investida 1,5, foice 1,05). **Um humano que usar a seta de longe ou fugir vai vê-la**; é limite do robô, não falha de
  design. Mas a combinação tempestade e investida nunca foi vista numa luta (QW-004).
- **Tempestade**: com 6 lâminas de 3 m a 48° no mínimo, o vão seguro para o centro do herói vale 0,81 d − 4 m a d metros
  dele: não existe perto (abaixo de 4,9 m) e passa de 2 m só a partir de 7,4 m. Quem fica colado nele, como o robô, não
  tem saída a não ser a esquiva; isso é desenho (a lição é "afaste-se quando ele erguer as almas"), mas só funciona se o
  aviso disser isso. Daí a numeração da ART-001.
- **Transições**: curtas e limpas (1,6 s, anel fino, nome da fase, sem quadro branco).
- **Duração**: 96 a 130 s para o robô, abaixo da meta de 2 a 4 min; gente pune menos janelas. Não mexer na vida antes do
  teste.
- **Vitória**: 3,6 s com controle, energia ao altar, portal que volta ao verde, Emeth brilhando, tela no estilo do título
  ([17](https://github.com/DaniSacra/eterra-a-selagem/blob/arpg-3d/docs/gallery/cycle9/17_portal_selagem.jpg),
  [18](https://github.com/DaniSacra/eterra-a-selagem/blob/arpg-3d/docs/gallery/cycle9/18_tela_vitoria.jpg)). Sóbria e
  correta; a selagem em si é pequena (um fio de partículas). Na Câmara, o selo do centro restaurado pode ser o momento.
- **Cânone**: o texto atual não inventa nada ("o poder de Morvath foi contido") e respeita "selado, não morto". Mas o cânone
  de 12/11 diz que cada selo foi fechado por **um** paladino do sangue do leão, que deu a vida, com **quatro guardiões
  Juramentados** nos cantos, e que **cada selo tem um leão de pé entalhado** (o de Valmor rachado de cima a baixo). O
  `premise` do jogo fala em quatro paladinos, o `ending_1` em quatro espadas (a espada erguida é o símbolo dos guardiões),
  e o título "o rei que traiu a luz" não está no cânone, que o chama de "o Lich-Rei do Sul", um dos Quatro Traidores, de
  domínio "a morte e o inverno sem fim". Perguntas D-01, D-02 e D-16.

## 5. A progressão roguelite

- **Dentro da partida**: 5 salas (luta, fonte, guardião, loja, Morvath), recompensas por pesos (`_stage`), 32 dons, 6 Elos,
  raridade em três níveis. Com a descida curta o jogador vê 1 a 3 escolhas de dom; os Elos quase nunca se formam numa
  partida real.
- **Entre partidas**: confirmei no código e no save que **não há nada**. `SaveData.defaults` guarda opções, até 5 melhores
  tempos, golpes vistos, vitórias e partidas; nada disso muda a partida seguinte. "Descer de novo" recarrega a cena.
- **Vontade de jogar de novo** (opinião): hoje vem só da luta em si e da variedade de dons. Para a vertical slice, eu não
  faria o hub do Hades; faria a descida inteira, a progressão de dons do Hades dentro da partida e a tela que ensina
  (QW-003). Juramentos (dificuldade por modificadores, sem hub) são o menor passo de meta progressão e vêm depois (D-07).

## 6. O pedido novo: a Câmara do Selo

Pedido em [`boss_arena_brief.md`](https://github.com/DaniSacra/eterra-a-selagem/blob/arpg-3d/docs/design/boss_arena_brief.md);
a imagem de referência fica só local (`docs/art/ref/morvath/camara_do_selo.png`) e eu a olhei: plataforma circular de pedra
escura sobre o abismo violeta e azul, balaustrada contínua com velas e lanternas violeta, pilaretes góticos com cruz, dois
pares de sarcófagos (noroeste e sudeste), escadaria a sudoeste, fachada ao norte com porta selada de ouro e violeta, duas
estátuas encapuzadas, estandartes, braseiros, torre e correntes, selo de ouro velho com estrela de oito pontas e uma
rachadura violeta no centro, Morvath com uma foice.

**Raio recomendado: 12 m de chão andável para o centro do herói (faixa de 11 a 13 m).** O cálculo, com os números de
`tools/make_data.gd`, está no C11 do backlog; em resumo: a investida exige poder ficar a 9 m dele (pelo menos 10,5 m); a
tempestade só dá vão seguro de 2 m a partir de 7,4 m dele (abaixo de 8 m vira roleta); o ritual põe os mortos num anel de
6,5 m (pelo menos 9 m); a câmera de 54 m mostra cerca de 32 m de chão, então a câmara inteira cabe com margem até 12 a 13
m; e a faixa de 9 a 12 m é onde a investida e as lâminas cobrem a fuga em círculo. A área cai de cerca de 800 m² andáveis
para cerca de 450 m².

**O que muda**: `BossRules.eruptions` deixa de receber um retângulo e passa a uma forma de chão testada (círculo ou
retângulo); a investida termina na borda; o anel do ritual vira dado; `BossDirector` com perto e longe relativos ao raio;
`Ground` recorta as faixas na borda e ganha o selo com cinco estados; `Arena.resolve` circular e a câmara como cena própria
reutilizável; `CamFrame` com limite circular e seguir curto; o robô com o modo que se afasta e a escolha do vão da
tempestade.

**Relação com o que está aberto**: resolve o portal vermelho na luta (vira a porta selada), dá espaço para a investida
existir (com o robô do QW-004), tira os cantos da fase 4 e é o lugar natural da ART-001. Piora um risco: no ritual, até 6
mortos e Morvath em pouco mais de metade da área, com corpos sólidos (REG-001). Medir antes de decidir os mortos
atravessáveis (D-19).

**Posição na ordem**: depois do C10. Os clarões brancos (BUG-001, BUG-004, BUG-005, BUG-006), o ritual de alvo móvel
(BUG-002), a métrica do ritual (BUG-009) e o robô que se afasta (QW-004) custam horas e, se ficarem, contaminam todas as
capturas, métricas e julgamentos da arena nova. Depois do C11, uma entrega única para o teste humano.

## 7. O próximo ciclo recomendado: C10 "Limpar e medir"

1. Quadro de impacto só no golpe que derruba fase e no Ômega, no máximo um a cada 10 s, com opção de desligar (BUG-001, QW-002).
2. Ritual: só os quatro primeiros contam para quebrar o escudo, com contador na barra (BUG-002, QW-005); métrica gravada na morte (BUG-009).
3. Morvath escurece no golpe final; escudo sem pontos brancos; orbe do feiticeiro violeta (BUG-004 a BUG-006).
4. Golpe amaldiçoado sem tela vermelha (BUG-007); "Novo melhor tempo" fora do `--nosave` (BUG-008).
5. Brilho de antecipação dos finalizadores ligado no dado, com teste que de fato verifica (BUG-003).
6. Registro de cada partida em `user://runs.jsonl` (QW-001) e "Derrotado por" na tela de fim (QW-003).
7. Robô `--bot-kite` para a investida aparecer nas métricas (QW-004).
8. Vídeo e quadro do bloqueio de corpo (REG-001); vazamento na saída (DT-005).
9. Fora: números de Morvath, dons novos, arena nova (é o C11), Meshy.
10. Aceite: 0 arriscados nos testes, no máximo 12 quadros P&B em 2 min, ritual abaixo de 15 s na mediana, 1 investida por luta com o robô que se afasta.

## 8. Plano de teste humano (depois do C11, numa entrega só)

**Quem**: o Daniel; uma pessoa que já jogou Hades ou Hades II; uma que nunca jogou roguelite de ação; uma que joga de
controle. Três é o mínimo para separar "eu errei" de "o jogo enganou"; cinco é melhor.

**Como**: build de Windows (com as instruções da Smart App Control, D-13); descida inteira se D-06 aprovar. Cada pessoa joga
3 partidas seguidas, sem ajuda; a primeira com quem observa anotando em silêncio (e, se ela topar, falando em voz alta o
que pensa). Gravar a tela com som (Xbox Game Bar basta). O `runs.jsonl` (QW-001) vem junto.

**O que observar** (anotar o minuto):
- Primeiros 5 minutos: achou o ataque, o especial, o círculo e a esquiva sem abrir o Como Jogar? Segurou para o Ômega?
- Cada morte: de onde veio o golpe e se a pessoa diz que viu chegando (pergunta de 1 a 5, logo depois).
- Bloqueio de corpo: ficou preso? O combo parou num inimigo do meio? Achou estranho encostar?
- Ritual: depois da fase, perguntar "o que precisava fazer para quebrar o escudo?".
- Maldição: percebeu que estava mais lento e sem especial? Leu o selo da HUD?
- Tempestade: achou o vão? Disse que era injusta?
- Clarões e câmera lenta: incomodaram? (Com a opção ligada e desligada, se houver tempo.)
- Loja: comprou algo sem querer ao pisar?
- Vitória: o que entendeu que aconteceu com Morvath? Quis descer de novo?

**O que medir** (do `runs.jsonl` e da gravação): tentativas até a 1ª vitória; tempo de cada luta e de cada fase; fase da
morte; dano por ataque (`hurt_by`); janelas punidas; Ômegas e esquivas por minuto; dons escolhidos; tempo total da partida.

**Só gente responde**: se a luta é divertida e justa; se 2 a 4 min parece longo ou curto; se o bloqueio de corpo é melhor
que empurrar; se o quadro de impacto, mesmo raro, vale a pena; se a Magia faz falta na luta; se o controle é bom; se dá
vontade de jogar de novo sem nada entre partidas.

## 9. Decisões que precisam do Daniel

| ID | Pergunta | Opções | Recomendação |
|---|---|---|---|
| D-01 | Título de Morvath | "O Rei que Traiu a Luz" (hoje no jogo, `enemy_morvath`); "Guardião das Catacumbas"; "o Lich-Rei do Sul" (o do cânone) | Não usar "Guardião": no cânone guardião é o Juramentado que segura o selo, e no jogo é o minichefe. Usar o do cânone, ou o Daniel levar "o Rei que Traiu a Luz" para o cânone (casa com os Quatro Traidores) |
| D-02 | Quem sela Morvath | quatro paladinos (spec antigo e `premise`); um paladino do leão com quatro guardiões (cânone de 12/11); a selagem fica fora da tela | O cânone; até lá, o texto neutro de hoje. Junto: a Selagem é a da guerra de Elun ou uma nova, depois do Velkor? |
| D-03 | As nove imagens da Hécate, que nunca chegaram | reenviar; desistir | Só se a meta for imitar a encenação; para mecânica os dados bastam. Há três imagens de Morvath só locais em `docs/art/ref/morvath/` |
| D-04 | Nomes de `PALADIN_1` a `PALADIN_4` e das famílias de dons | agora; depois de D-02 | Depois de D-02: se forem guardiões, as famílias mudam de dono |
| D-05 | Meshy (546 créditos segundo o `CLAUDE.md`) | cenário (45); Morvath e elites (cerca de 100); segurar | Segurar até o teste; depois cenário 1 a 3 e Morvath (55) |
| D-06 | Descida curta (5) ou região inteira (11) | manter; inteira como padrão com `--short` | Inteira como padrão antes do teste humano |
| D-07 | Algo entre partidas | nada; Juramentos; o hub (Vitrais e Obras) | Nada na slice de teste; Juramentos no C14 |
| D-08 | Quadro de impacto P&B | manter; limitar com opção; tirar | Limitar e dar opção |
| D-09 | Magia na luta do chefe | como está; Magia por janela punida ou pelos mortos do ritual | Medir no teste antes |
| D-10 | Bônus de sequência (não existe no Hades II) | manter; tirar | Tirar, se o teste não sentir falta |
| D-11 | Meta da primeira vitória | 1ª tentativa; até 3; até 10 | Até 3 para quem jogou Hades, com a descida inteira |
| D-12 | Som e música | só CC0; encomenda; IA (declarar) | CC0 para efeitos agora; música escolhida pelo Daniel |
| D-13 | Executável para testadores | certificado; instruções | Instruções agora; certificado antes da Steam |
| D-14 | Portal vermelho | manter; violeta apagado | Na luta a Câmara resolve; nas salas, violeta apagado |
| D-15 | Salas comuns no salão retangular? | sim (o brief); guardiões numa câmara menor; tudo redondo | Sim; guardiões depois do teste |
| D-16 | Desenho do selo | estrela de oito pontas rachada (a imagem); o leão de pé entalhado, rachado (o cânone de Valmor) | O leão dentro do anel duplo |
| D-17 | Cruz nos sarcófagos e pilaretes da imagem | manter; leão e espada erguida | Perguntar: o cânone tem três símbolos (leão, espada erguida, olho cortado) e não cita a cruz |
| D-18 | Raio da Câmara | 12 m; outro | 12 m, ajustável por dado depois do teste |
| D-19 | Mortos do ritual atravessáveis na Câmara | não; sim | Só se a medida de cerco pedir |

## 10. Evidências citadas

- Galeria do ciclo 9: [README](https://github.com/DaniSacra/eterra-a-selagem/blob/arpg-3d/docs/gallery/README.md),
  [ART_REVIEW](https://github.com/DaniSacra/eterra-a-selagem/blob/arpg-3d/docs/gallery/cycle9/ART_REVIEW.md),
  [CAPTURAS](https://github.com/DaniSacra/eterra-a-selagem/blob/arpg-3d/docs/gallery/cycle9/CAPTURAS.md),
  [METRICAS](https://github.com/DaniSacra/eterra-a-selagem/blob/arpg-3d/docs/gallery/cycle9/METRICAS.md),
  [vídeo da luta](https://github.com/DaniSacra/eterra-a-selagem/blob/arpg-3d/docs/gallery/cycle9/morvath_full_fight.mp4),
  [vídeo dos ataques](https://github.com/DaniSacra/eterra-a-selagem/blob/arpg-3d/docs/gallery/cycle9/morvath_attacks_showcase.mp4).
- Capturas: [02 foice preparo](https://github.com/DaniSacra/eterra-a-selagem/blob/arpg-3d/docs/gallery/cycle9/02_foice_preparacao.jpg),
  [11 maldição](https://github.com/DaniSacra/eterra-a-selagem/blob/arpg-3d/docs/gallery/cycle9/11_maldicao_aplicacao.jpg),
  [before_after_vitoria](https://github.com/DaniSacra/eterra-a-selagem/blob/arpg-3d/docs/gallery/cycle9/before_after_vitoria.jpg),
  [orbe do feiticeiro](https://github.com/DaniSacra/eterra-a-selagem/blob/arpg-3d/docs/gallery/cycle9/work/c9c_numeros_horda_1080.jpg).
- Revisões anteriores: [ciclo 8](https://github.com/DaniSacra/eterra-a-selagem/blob/arpg-3d/docs/gallery/cycle8/ART_REVIEW.md),
  [ciclo 7](https://github.com/DaniSacra/eterra-a-selagem/blob/arpg-3d/docs/gallery/cycle7/ART_REVIEW.md).
- QA: [latest_report.md](https://github.com/DaniSacra/eterra-a-selagem/blob/arpg-3d/docs/qa/latest_report.md).
- Design: [morvath_boss_fight.md](https://github.com/DaniSacra/eterra-a-selagem/blob/arpg-3d/docs/design/morvath_boss_fight.md),
  [comparativo.md](https://github.com/DaniSacra/eterra-a-selagem/blob/arpg-3d/docs/design/comparativo.md).
- Código e dados: [make_data.gd](https://github.com/DaniSacra/eterra-a-selagem/blob/arpg-3d/tools/make_data.gd),
  [combat.gd](https://github.com/DaniSacra/eterra-a-selagem/blob/arpg-3d/scripts/game/combat.gd),
  [boss.gd](https://github.com/DaniSacra/eterra-a-selagem/blob/arpg-3d/scripts/game/boss.gd),
  [boss_rules.gd](https://github.com/DaniSacra/eterra-a-selagem/blob/arpg-3d/scripts/core/boss_rules.gd),
  [body_block.gd](https://github.com/DaniSacra/eterra-a-selagem/blob/arpg-3d/scripts/core/body_block.gd),
  [test_combo.gd](https://github.com/DaniSacra/eterra-a-selagem/blob/arpg-3d/tests/test_combo.gd).
- Simulações desta revisão (Linux, sem tela, `--fixed-fps 60`; resultados aqui, saídas fora do repositório): luz sem defesa
  2 de 8, luz com `firmeza` 7 de 8 (reação 0,25, sementes 1 a 8); 8 partidas inteiras com reação 0,25: 2 vitórias, mortes
  nas fases 2 (3), 3 (1) e 4 (2), ritual de 20 s em 6 de 8, todas chegando com 1 ou 2 dons.

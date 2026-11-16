# Backlog de A Selagem

- **Data**: 2026-11-15. **Autor**: game-director (primeira revisão oficial). **Commit lido**: `6dbcec5` (jogo igual ao
  `147b481`; o `6dbcec5` só traz a revisão de arte do ciclo 9).
- **Fontes**: `CLAUDE.md`, `git log` (ciclos 7, 8 e 9), `docs/gallery/cycle7` a `cycle9` (ART_REVIEW, CAPTURAS,
  METRICAS, capturas e os dois vídeos, olhados quadro a quadro), `docs/qa/latest_report.md`, `docs/design/`, `docs/art/`,
  `docs/arte/estetica.md`, `docs/steam-ia.md`, o cânone, o código e os dados citados em cada item.
- **O que rodei nesta revisão** (sem mexer em nada do jogo): `tools/test.sh` (28 arquivos, 338 testes, 337 passando, 1
  arriscado), 16 lutas a partir do chefe e 8 partidas inteiras com `--bot-reaction=0.25` (comandos e números nos itens).
- Relatório executivo, com a avaliação fase por fase: [`docs/design/game_director_review.md`](design/game_director_review.md).

## Estado do jogo em 5 linhas

1. A Fase 1 é jogável do título à vitória: título cinematográfico, 4 salas encurtadas para teste (luta, fonte, guardião,
   loja) e Morvath em 4 fases na sala 5; 0 erros de script em 80 simulações, 337 de 338 testes passando.
2. O combate copia os números do Hades II (ataque 20/25/60, especial 40, Ômega, avanço 0,2 s, vida 30) e tem sensação de
   golpe acima da média para um protótipo; falta o som (sintetizado, sem música) e falta gente jogando.
3. Morvath é a parte mais trabalhada: ataques legíveis, avisos exatos, identidade violeta e espectral; ainda há clarões
   brancos (quadro de impacto, golpe final, escudo) e avisos no vermelho genérico.
4. Nunca houve teste com gente além dos testes curtos do Daniel; dificuldade, ritmo e o bloqueio de corpo novo (`147b481`)
   só foram medidos pelo robô, que não erra mira e nunca se afasta.
5. Não existe nada entre partidas (só melhores tempos, vitórias e golpes vistos no save); a descida curta faz o jogador
   chegar a Morvath com 1 ou 2 dons, o que explica a maior parte das derrotas nas simulações.

Legenda: **Tipo** = bug confirmado, risco, hipótese de design ou sugestão artística. **Esforço** P (horas), M (1 a 2
dias), G (vários dias). Responsáveis: `gameplay-engineer`, `environment-artist`, `ui-ux-designer`, `art-director`,
`qa-performance`; "Daniel" quando a decisão é dele.

---

## 1. Bugs críticos e regressões

Nenhum bug crítico confirmado (sem crash, sem travamento, sem regra que impeça vencer). Um risco de regressão:

### REG-001 Bloqueio de corpo sem captura, sem medida de quadro e sem ninguém jogando
- **Prioridade**: alta. **Tipo**: risco.
- **Evidência**: commit `147b481`; `docs/gallery/cycle9/ART_REVIEW.md` seção 1 ("não tem captura nem medida de quadro");
  `scripts/game/player.gd:429-431` (o herói para em qualquer corpo, inclusive no avanço do golpe), `scripts/core/body_block.gd`
  (`EASE` 3 m/s, número nosso); antes do `Bot._escape` o robô morria encurralado pelo Cavaleiro (relato do Daniel na tarefa).
- **Impacto no jogador**: muda a sensação de todo passo e de todo golpe. Riscos: ficar preso entre dois inimigos com a
  esquiva em recarga; o avanço do golpe (`lunge`) parar no corpo de um esqueleto que está entre ele e o alvo e o combo
  "morrer" no ar; guardiões de raio 1,0 e 1,1 e Morvath de 1,4 virando paredes.
- **Esforço**: P (medir). **Responsável**: `qa-performance` (capturas e quadro), Daniel (sensação).
- **Aceite**: 3 capturas ou um vídeo curto (herói contornando um grupo, herói encurralado saindo pela esquiva, combo de 3
  golpes num grupo de 4 esqueletos); quadro a 1080p na tomada sem piora acima de 0,2 ms contra `2de07b0`; o Daniel
  responde "travou ou ficou preso?" depois de 3 partidas (ver plano de teste no relatório).
- **Prova**: vídeo de 30 s em `docs/gallery/cycle10/`, linha de desempenho no relatório de QA, resposta do Daniel.
- **Comparação com o Hades II** (dados do jogo, só números): os inimigos comuns têm `StopsUnits` e um losango de 128 x 64
  unidades (1,6 x 0,8 m); a heroína um octógono de 96 x 48 (1,2 x 0,6 m); 15 tipos de inimigo são atravessáveis. Se o eixo
  menor do Hades é o chão achatado pela vista (hipótese minha), o losango equivale a um círculo de cerca de 0,8 m e a
  heroína a cerca de 0,6 m: nossos 0,45 a 0,75 m (herói 0,5) ficam um pouco menores, o que favorece passar entre corpos.
  Fidelidade boa. O que o Hades tem e nós não: tipos atravessáveis (sugiro o Corredor, papel "reação", e as almas
  invocadas no ritual, para não fecharem o herói), decisão depois do teste.

---

## 2. Bugs altos e médios

### BUG-001 Quadro de impacto preto e branco em todo finalizador contra Morvath
- **Prioridade**: alta. **Tipo**: bug confirmado (regra de identidade e de leitura quebrada).
- **Evidência**: `scripts/game/combat.gd:186-189` chama `fx.impact_frame()` quando `big_strike(struck)`; `combat.gd:278-284`
  devolve verdadeiro para qualquer alvo com `Behavior.BOSS`, sem recarga. Na luta gravada: 24 quadros em 121 s
  (ART_REVIEW N1); eu vi um aos 0:18 (quadros extraídos a 10 por segundo de `morvath_full_fight.mp4`: a tela inteira
  vira preto com manchas brancas e o setor vermelho da foice some).
- **Impacto**: a cada 5 s, em média, os avisos somem por cerca de 67 ms, justamente perto do chefe; é o clarão de tela
  inteira que a direção proíbe e é risco de fotossensibilidade (a Steam e o próprio jogador vão perguntar).
- **Esforço**: P. **Responsável**: `gameplay-engineer`.
- **Aceite**: contra chefe e guardião, quadro de impacto só no golpe que derruba uma fase e no Ômega, no máximo um a cada
  10 s (`Combat`, dado em `Feel`); opção "Clarões de impacto" nas Configurações (ver QW-002); teste GUT do limite.
- **Prova**: folha de quadros da luta inteira com no máximo 12 quadros P&B em 2 min (o método de `signalstats` do ART_REVIEW).

### BUG-002 O ritual é um alvo que foge: os reforços entram na conta do escudo
- **Prioridade**: alta. **Tipo**: hipótese de design com causa confirmada no código.
- **Evidência**: a dica promete "Derrube os mortos para quebrar o escudo!" (`data/text_pt.tres:134`); o ritual acaba
  quando todos os `_raised` caem ou em 20 s (`BossRules.ritual_over`, `scripts/core/boss_rules.gd:117`); a cada 6 s
  (`ritual_reinforce_every`) mais um esqueleto e um feiticeiro sobem com `ritual = true` (`scripts/game/boss.gd:795-796`)
  e entram em `_raised` (`boss.gd:717`). Para quebrar antes do limite o jogador precisa matar 4 (280 de vida, os
  feiticeiros fugindo a 9 m) antes de os próximos subirem. Resultado: ritual de 20 s na mediana das partidas inteiras
  (`METRICAS.md` tabela 4) e em 6 de 8 nas minhas (`tools/smoke.sh 900 --bot-reaction=0.25 --seed=1..8`); 4 das 7 mortes
  das partidas inteiras com reação 0,25 são na fase 2 (`METRICAS.md` seção 5).
- **Impacto**: o objetivo anunciado parece impossível, o jogador apanha dos mortos (a maior fonte de dano em todas as
  configurações: 16 a 26 golpes) e o escudo cai pelo relógio, não pelo mérito.
- **Esforço**: P. **Responsável**: `gameplay-engineer` (regra), `ui-ux-designer` (contador).
- **Aceite**: só os 4 primeiros contam para quebrar o escudo (reforços continuam vindo como pressão, sem contar), ou os
  reforços só começam depois de 10 s; contador "Mortos: 3/4" junto da barra do chefe; teste GUT; nas simulações com reação
  0,25 a mediana do ritual nas partidas inteiras fica abaixo de 15 s.
- **Prova**: `METRICAS` refeito (16 partidas inteiras), captura do contador.

### BUG-003 Brilho de antecipação dos finalizadores não existe (dado zerado) e o teste que o cobre não testa nada
- **Prioridade**: média. **Tipo**: bug confirmado.
- **Evidência**: `ComboNode.glint` (`scripts/core/combo_node.gd:49`) é 0 em todos os nós: `tools/make_data.gd` nunca o
  define (só `glint_scale`, linha 514) e `data/combos/paladin.tres` não tem `glint`; `git log -S"glint = "` vazio. O
  `CLAUDE.md` descreve o efeito como pronto. `tests/test_combo.gd:273` (`test_only_finishers_glint`) só afirma dentro de
  `if n.glint > 0`, por isso é o "arriscado" de todos os relatórios desde o ciclo 7.
- **Impacto**: o finalizador do Ember & Blade perde o "tchan" de antecipação (o brilho na ponta da Emeth) que os documentos
  dão como feito; um teste verde que não verifica nada.
- **Esforço**: P. **Responsável**: `gameplay-engineer` (dado e teste), `art-director` (valor).
- **Aceite**: os finalizadores do `make_data.gd` com `glint` entre 0,06 e 0,1 s (número do Ember & Blade medido em
  `docs/arte/estetica.md` seção 3, a confirmar pelo art-director); teste que exige pelo menos um nó com brilho e nenhum
  não finalizador com brilho; `tools/test.sh` com 0 arriscados.
- **Prova**: saída do `tools/test.sh`; captura `--shot-on=swing` de um finalizador com o brilho.

### BUG-004 Morvath quase branco no golpe final
- **Prioridade**: média. **Tipo**: bug confirmado (regra "nada de clarão branco").
- **Evidência**: `docs/gallery/cycle9/16_morvath_derrota.jpg` (corpo marfim inteiro), `before_after_vitoria.jpg`; QA B1,
  ART_REVIEW B1. Nos quadros do vídeo da luta ele também fica pálido a cada golpe pesado (0:20, 1:12, 1:24).
- **Impacto**: o momento mais importante da luta vira uma silhueta branca; contradiz o "brilho dele se apaga".
- **Esforço**: P. **Responsável**: `gameplay-engineer`.
- **Aceite e prova**: como o ART_REVIEW B1 (captura `victory` + 0,4 s e + 1,0 s, nenhum pixel do corpo acima de 0,85).

### BUG-005 Pontos brancos estourados no escudo do ritual
- **Prioridade**: média. **Tipo**: bug confirmado.
- **Evidência**: `07_ritual_escudo.jpg`; vídeo da luta aos 0:43 (esfera branca no alto do escudo, maior que a cabeça dele);
  QA B2, ART_REVIEW B2.
- **Esforço**: P. **Responsável**: `environment-artist`. **Aceite e prova**: ART_REVIEW B2.

### BUG-006 Orbe do feiticeiro com miolo branco (aberto desde o ciclo 8)
- **Prioridade**: média. **Tipo**: bug confirmado (pendência P3 do ciclo 8 que não foi feita).
- **Evidência**: `docs/gallery/cycle8/ART_REVIEW.md` F/P3; `docs/gallery/cycle9/work/c9c_numeros_horda_1080.jpg`; ART_REVIEW N3.
- **Impacto**: o projétil mais comum da região vira uma nuvem branca com 4 a 6 feiticeiros, e eles também entram no ritual.
- **Esforço**: P. **Responsável**: `environment-artist`. **Aceite e prova**: ART_REVIEW N3.

### BUG-007 Golpe amaldiçoado tinge a tela de vermelho
- **Prioridade**: média. **Tipo**: bug confirmado (leitura).
- **Evidência**: `11_maldicao_aplicacao.jpg`; quadro do vídeo da luta aos 1:55; medida do ART_REVIEW B3 (0,3 s por golpe,
  com separação de cores nas bordas).
- **Esforço**: P. **Responsável**: `ui-ux-designer`. **Aceite e prova**: ART_REVIEW B3.

### BUG-008 "Novo melhor tempo!" em partida sem save
- **Prioridade**: baixa. **Tipo**: bug confirmado (só em teste).
- **Evidência**: `18_tela_vitoria.jpg`; `scripts/save.gd:11` deixa `data` nos padrões com `--nosave` e
  `scripts/game/game.gd:753` compara com a lista vazia.
- **Esforço**: P. **Responsável**: `ui-ux-designer`. **Aceite**: com `Save.enabled == false` a tela não mostra o aviso.

### BUG-009 Métrica do ritual zerada quando o paladino morre no ritual
- **Prioridade**: baixa (mas atrapalha medir o BUG-002). **Tipo**: bug confirmado.
- **Evidência**: `stats.ritual` só em `_end_ritual` (`boss.gd:805`); QA B7 (sementes 3, 4 e 5).
- **Esforço**: P. **Responsável**: `gameplay-engineer`. **Aceite**: `record_death` (`boss.gd:970`) grava `ritual` e
  `ritual_raised` se o ritual estiver de pé; teste GUT.

### BUG-010 Dica do ritual sem ritual com `--boss-hp`
- **Prioridade**: baixa (só ferramenta). **Tipo**: bug confirmado. **Evidência**: `09_erupcoes.jpg`, QA B5.
- **Esforço**: P. **Responsável**: `gameplay-engineer`. **Aceite**: com `--boss-hp` abaixo de 0,66 o ritual roda ou a dica não aparece.

---

## 3. Quickwins de combate e UX

### QW-001 Registro de cada partida de gente, para o teste humano
- **Prioridade**: alta (pré-requisito do teste). **Tipo**: sugestão de ferramenta.
- **Evidência**: o `RESULT` com `boss` (`Game.result`, `scripts/game/game.gd:1024`) só sai no `--smoke`; nenhum dado de
  partida humana é guardado (`SaveData.defaults` só tem opções, tempos, golpes, vitórias e partidas).
- **Impacto**: sem isso o teste com o Daniel e outros vira opinião sem número (onde morreu, de quê, quanto tempo).
- **Esforço**: P. **Responsável**: `gameplay-engineer`.
- **Aceite**: ao fim de toda partida (vitória, morte ou sair), uma linha JSON em `user://runs.jsonl` com o mesmo
  dicionário do `RESULT`, mais os dons escolhidos, o controle usado (teclado ou controle), quantos Ômegas e esquivas, e o
  último ataque que feriu; nada sai do computador. Teste GUT do formato.
- **Prova**: um arquivo de exemplo de 3 partidas anexado ao relatório de QA.

### QW-002 Opções de conforto: clarões de impacto, câmera lenta, tremor já existe
- **Prioridade**: alta. **Tipo**: sugestão (acessibilidade e Steam).
- **Evidência**: `data/text_pt.tres:120-125` (opções: volumes, tela cheia, janela, tremor); nada para quadro de impacto,
  câmera lenta, separação de cores ou desfoque radial (`Fx.slow_mo`, `screen.gdshader`).
- **Esforço**: P. **Responsável**: `ui-ux-designer` (tela), `gameplay-engineer` (ligar em `Fx`).
- **Aceite**: "Clarões de impacto" e "Efeitos de tela" (câmera lenta, desfoque, separação) ligados e desligados nas
  Configurações, salvos; com os dois desligados a folha de quadros de uma luta não tem quadro P&B nem desfoque.
- **Prova**: captura da tela de opções; folha de quadros.

### QW-003 Na tela de derrota, o que matou
- **Prioridade**: média. **Tipo**: hipótese de design (opinião minha).
- **Evidência**: `EndScreen` mostra tempo, sequência, abates, ouro e dons (`scripts/ui/end_screen.gd:47`); o jogo já sabe
  a origem de cada golpe no chefe (`hurt_by`). O critério do ART_REVIEW B8 é "o Daniel diz que viu de onde veio o golpe".
- **Impacto**: aprendizado entre tentativas, o centro de um roguelite; ajuda o teste a separar injustiça de erro.
- **Esforço**: P. **Responsável**: `ui-ux-designer`, `gameplay-engineer` (nome do ataque).
- **Aceite**: "Derrotado por: Tempestade das Seis Almas" (nome do ataque ou do inimigo, texto em `text_pt.tres`).

### QW-004 Robô que às vezes se afasta, para a investida existir nas métricas
- **Prioridade**: média. **Tipo**: risco de cobertura.
- **Evidência**: `attacks.dash` = 0 em 80 lutas (QA M1). Pelos dados (`tools/make_data.gd:470-480`), a investida pede 9 m
  ou mais; a 10 m ou mais os pesos ficam lâminas 4,4, investida 1,5 e foice 1,05 (se até 11 m): cerca de 22% das
  escolhas. **Um humano verá a investida** sempre que usar a seta especial de longe ou fugir; é falha do robô, não do
  design. Mas a combinação tempestade e investida da fase 4 nunca foi vista em luta real.
- **Esforço**: P. **Responsável**: `gameplay-engineer` (`Bot`), `qa-performance` (captura).
- **Aceite**: `--bot-kite=0.2` (fração do tempo longe, a mais de 10 m); com ela, pelo menos 1 investida por luta em 8
  sementes; teste GUT da investida numa cena real.
- **Prova**: tabela de ataques no novo `METRICAS`; uma captura da investida na fase 4.

### QW-005 Contador do ritual e marcação de quem falta
- Junto com o BUG-002 (mesmo dono e mesma prova). Esforço P. `ui-ux-designer`.

---

## 4. Dívidas técnicas relevantes

### DT-001 A descida curta é o padrão e distorce todas as medidas
- **Prioridade**: alta. **Tipo**: risco.
- **Evidência**: `tools/make_data.gd:339-350` (`st.rooms = 4`, fonte na 2, guardião na 3, `elite_from_depth = 2` por causa
  disso). Nas partidas inteiras o robô chega com 1 ou 2 dons (`METRICAS.md` tabela 4). Minha simulação: trocar um único
  dom do kit de luz (onda_maior por firmeza, +20 de vida) leva de 2 para 7 vitórias em 8 com reação 0,25
  (`tools/smoke.sh 600 --start=boss --bot-reaction=0.25 --seed=1..8 --boon-ids=golpe_radiante,pesado_radiante,circulo_radiante,passo_radiante,firmeza,consolo`
  contra o mesmo com `onda_maior`). No Hades II o jogador chega à primeira chefe depois de cerca de 10 salas.
- **Impacto**: Morvath foi feito com a vida e o dano da chefe do Hades (6050) para um jogador com 6 a 8 dons e recebe um
  com 2; qualquer ajuste de dificuldade feito na descida curta sai errado.
- **Esforço**: P (o mapa já suporta 10 salas). **Responsável**: `gameplay-engineer`; decisão do Daniel (D-06).
- **Aceite**: `--short` mantém a descida de teste; o padrão volta às 10 salas e chefe na 11 do Hades II, elites da 3ª.
- **Prova**: 8 partidas inteiras do robô com dons na chegada (esperado 5 a 8).

### DT-002 O robô não mede dificuldade
- **Prioridade**: média. **Tipo**: risco de medida.
- **Evidência**: reação 0 vence 32 de 32 e perde 20 a 50 de vida em 8 lutas (`METRICAS.md` 1 e 2); não erra mira, não usa
  a seta de longe, nunca se afasta (QW-004); com dons sorteados vence 8 de 8, com estilo fixo 1 a 3 de 8. A causa da
  diferença não é o estilo: os kits fixos não têm nenhum dom de defesa (vida, escudo, esquiva extra), os sorteados
  trazem `firmeza` em parte das sementes (vida final de 50 e 55 só é possível com ela) e a minha troca de um dom acima
  confirma. Com 30 de vida e reação de 0,25, sobrar 136 a 766 de Morvath nas derrotas mostra que se perde por pouco.
- **Esforço**: M. **Responsável**: `qa-performance` (protocolo), `gameplay-engineer` (QW-001).
- **Aceite**: o relatório de balanceamento passa a ter três colunas: robô 0, robô 0,25, gente (QW-001); nenhuma mudança
  de vida ou dano de Morvath sem a coluna de gente.

### DT-003 Desempenho incompleto e nunca medido em máquina fraca
- **Prioridade**: média (caminho da Steam). **Tipo**: risco.
- **Evidência**: QA seção 3 (2 rodadas em vez de 3, notebook na bateria); `CLAUDE.md` "não medido em celular nem em placa
  de vídeo fraca"; `147b481` sem medida.
- **Esforço**: M. **Responsável**: `qa-performance`.
- **Aceite**: mediana de 3 rodadas na tomada (fase 1, ritual, fase 4, sala com 12 inimigos); uma rodada no Compatibility
  (`--rendering-driver opengl3`) e uma com 1280 x 720 e escala de render 0,67 como "máquina fraca simulada"; meta de 60
  FPS documentada para a Steam (requisitos mínimos).

### DT-004 Vídeos mudos e em 720p
- **Prioridade**: baixa. **Tipo**: dívida de ferramenta.
- **Evidência**: `CAPTURAS.md` (gravação no tamanho do projeto, 1280 x 720; o `--shot` silencia o jogo).
- **Esforço**: P. **Responsável**: `qa-performance`.
- **Aceite**: um vídeo de 60 s em 1920 x 1080 com som (janela em 1920 antes de gravar, `--shot` sem silenciar, ou captura
  do Windows), para o Daniel e para a página da Steam no futuro.

### DT-005 Vazamento na saída
- **Prioridade**: baixa. **Tipo**: dívida. **Evidência**: "2 ObjectDB instances were leaked" e "1 resources still in use"
  em toda execução (QA seção 1; minha saída do `tools/test.sh`). **Esforço**: P. **Responsável**: `gameplay-engineer`.
- **Aceite**: `tools/test.sh` e `tools/smoke.sh` sem as duas linhas.

### DT-006 `CLAUDE.md` descreve efeitos que não acontecem
- **Prioridade**: baixa. **Tipo**: dívida de documentação. **Evidência**: BUG-003 (brilho dos finalizadores). Toda revisão
  confia nesse arquivo. **Responsável**: a sessão principal, ao fechar cada ciclo. **Aceite**: cada efeito citado tem um
  teste que falha se o dado estiver zerado ou uma captura no ciclo.

---

## 5. Melhorias artísticas

| ID | Título | Prioridade | Tipo | Evidência | Esforço | Responsável | Aceite (prova) |
|---|---|---|---|---|---|---|---|
| ART-001 | Avisos de Morvath com assinatura (aro violeta e runas na borda, tempestade numerada) | alta | sugestão artística | `02_foice_preparacao.jpg`, `15_combate_final.jpg`, ART_REVIEW B4 | M | `environment-artist`, `gameplay-engineer` (`Zone.source`) | ART_REVIEW B4: o aviso se reconhece sem ver o chefe; o chão continua legível sob as seis faixas |
| ART-002 | Som de combate de verdade e música | alta | sugestão artística | `CLAUDE.md` "Som... provisórias", "Música desligada"; vídeos sem som | G | `art-director` (lista e direção), Daniel (fonte e licença) | lista de 40 sons do combate e da luta com origem; golpe, acerto, finalizador, esquiva, aviso de cada ataque do chefe e fase com som próprio; uma faixa por momento (salas, chefe, vitória) |
| ART-003 | Portal vermelho nas fases 1 a 3 | média | decisão do Daniel | `01_morvath_fase1.jpg` a `12`, ART_REVIEW N7 | P | `environment-artist` | captura de fase 1 aprovada pelo Daniel |
| ART-004 | Coluna branca da Lança de Luz sobre Morvath | média | bug de identidade | vídeo da luta 0:20 e 0:29 (ART_REVIEW N2) | P | `gameplay-engineer` | ART_REVIEW N2 |
| ART-005 | Coluna do escudo cobrindo Morvath por 0,75 s | média | sugestão artística | ART_REVIEW N5 | P | `environment-artist` | ART_REVIEW N5 |
| ART-006 | Verde corrompido mais frio e escuro que o da Emeth | média | sugestão artística | `07`, `09`, ART_REVIEW N9 | P | `environment-artist` | ART_REVIEW N9 |
| ART-007 | Queimadura em brasas na borda, não dourado no corpo todo | média | sugestão artística | `docs/gallery/morvath/04_ritual_escudo_erupcoes.jpg`, ART_REVIEW N4 (sem captura atual com fogo) | P | `environment-artist` | ART_REVIEW N4, capturas com dons de fogo |
| ART-008 | Fase 4 com atmosfera própria além do portal | média | sugestão artística | `work/c9b_comparacao_portal_fase4.jpg`, ART_REVIEW seção 8 | M | `environment-artist` | captura de fase 4 lado a lado com a 1: a diferença se vê em miniatura |
| ART-009 | Pontos amarelos perto do herói | baixa | sugestão artística | ART_REVIEW N6 | P | `gameplay-engineer` | ART_REVIEW N6 |
| ART-010 | Peças definitivas do cenário (estátua, moldura do portal, obelisco) | média | sugestão artística, depende de créditos | `docs/art/meshy_asset_plan.md` (prioridades 1 a 3, 45 créditos; saldo de 546 segundo o `CLAUDE.md`) | M | `art-director`, `environment-artist`; Daniel autoriza | capturas da vitrine contra a pintura de referência |
| ART-011 | Gancho amarelo no modelo de Morvath e ouro das elites por repintura | baixa | depende de créditos | ART_REVIEW N8; `CLAUDE.md` (elites por shader) | P | Daniel | captura de fase 1 sem amarelo saturado |

---

## 6. Próximos ciclos

Princípio: a Fase 1 tem de virar uma vertical slice excelente antes de qualquer Fase 2. Primeiro leitura do combate,
depois gente jogando, depois números, depois enfeite. Ordem recomendada: **C10** (limpeza barata e instrumentos de
medida) → **C11** (Câmara do Selo, pedido novo do Daniel) → **teste humano com a versão C10 + C11 numa entrega só**
(regra das versões MVP completas: o Daniel testa uma vez, no fim) → **C12** (progressão do Hades) → **C13** (som e
acabamento) → **C14** (caminho da Steam). Peças definitivas do Meshy ficam para depois do C14 ou entram no C13 se o
Daniel liberar créditos (D-05).

Por que C10 antes da Câmara: os clarões brancos, o ritual de alvo móvel e o robô que nunca se afasta contaminariam
todas as capturas, métricas e julgamentos da arena nova. São horas de trabalho e a Câmara depende de três deles
(QW-004 para validar a investida, BUG-002 e BUG-009 para medir o ritual no círculo, BUG-001 para os avisos não sumirem
nas capturas).

### C10 "Limpar e medir": clarões, ritual e instrumentos para o teste
- **Objetivo**: tirar da luta o que a direção proíbe e o que confunde, e dar ao projeto os instrumentos para medir gente e
  a arena nova.
- **Justificativa**: são os itens mais baratos com mais efeito na leitura (BUG-001 sozinho apaga a tela 24 vezes por luta)
  e são pré-requisito do C11.
- **Escopo**: BUG-001 a BUG-010, QW-001 a QW-005, DT-005, REG-001 (medir o bloqueio de corpo: vídeo e quadro), DT-001 só
  se o Daniel decidir em D-06.
- **Fora do escopo**: arena nova, números de vida e dano de Morvath, dons novos, meta progressão, Meshy, Fase 2.
- **Dependências**: D-08 (quadro de impacto). Nenhuma de crédito.
- **Agentes**: `gameplay-engineer` (regras, registro, robô, quadro de impacto), `ui-ux-designer` (opções, contador,
  derrota, aviso de recorde), `environment-artist` (escudo, orbe), `qa-performance` (capturas, quadro), `art-director`
  (revisão curta).
- **Aceite**: 0 erros de script; `tools/test.sh` sem arriscados; folha de quadros da luta com no máximo 12 quadros P&B em 2
  min (0 com a opção desligada); ritual com mediana abaixo de 15 s nas partidas inteiras do robô 0,25; pelo menos 1
  investida por luta com `--bot-kite`; `user://runs.jsonl` com 3 partidas de exemplo; captura de `victory` + 0,4 s sem
  Morvath branco; quadro a 1080p sem piora acima de 0,2 ms.
- **Evidências obrigatórias**: `docs/gallery/cycle10/` com o vídeo do bloqueio de corpo, as capturas de B1, B2, N3 e do
  contador, a folha de quadros; `METRICAS.md` novo; relatório de QA.
- **Riscos**: pequeno; o maior é o C10 crescer. Nada fora da lista entra.

### C11 "Câmara do Selo": a arena circular de Morvath (pedido do Daniel, `docs/design/boss_arena_brief.md`)
- **Objetivo**: Morvath luta numa câmara circular própria, com o raio calculado pela mecânica, o selo no centro com
  estados, e as quatro fases usando o círculo; as salas comuns continuam o salão retangular.
- **Justificativa**: o pedido do Daniel; e a sala retangular de hoje (32 x 30 m, `CatacombHall.HALF` 16 x 15) é grande
  demais para a luta: o robô nunca fica longe, um humano pode fugir para os cantos, a fase 4 tem cantos e o portal
  vermelho domina a tela (ART_REVIEW N7). A imagem de referência (`docs/art/ref/morvath/camara_do_selo.png`, só local,
  olhada nesta revisão) mostra plataforma circular, balaustrada contínua com velas e lanternas violeta, dois pares de
  sarcófagos (noroeste e sudeste), escadaria de entrada a sudoeste, fachada com porta selada de ouro e violeta ao norte,
  estátuas encapuzadas, estandartes, braseiros, torre e correntes, e o selo de ouro velho no centro com uma rachadura
  violeta.

**O raio, calculado pela mecânica** (todos os números de `tools/make_data.gd`; "do centro dele" = do centro de Morvath):

| Número | Valor | De onde |
|---|---|---|
| Andar do Explorador | 6,75 m/s (540 / 80) | `_feel`, `f.speed` |
| Corrida | 1,65 vez o andar (11,1 m/s) | `f.sprint_scale` |
| Esquiva | 5,6 m em 0,2 s, 1 carga, 0,74 s de recarga | `f.dodge_*` |
| Raio do herói | 0,5 m | `Player.RADIUS` |
| Raio de Morvath, velocidade | 1,4 m; 3,75 m/s, +8% por fase | `_enemies` (morvath), `boss.gd` CHASE |
| Foice | 5,0 m do centro dele, 180°, preparo 0,8 s, recuperação 1,0 s | `_bosses` |
| Lâminas | 3 m de largura, 11 m/s, alcance 26 m, 38° entre as duas | `_bosses` |
| Investida | só com o herói a 9 m ou mais; faixa de 16 x 2,8 m; preparo 0,8 s | `_bosses`, `_attack(&"dash")` |
| Erupções | círculos de 2 m, 2 ou 3, atraso 0,9 s, corredor de 120° livre | `_bosses` |
| Tempestade | 6 meias-luas de 3 m, nunca a menos de 48° entre si, 2 ondas giradas 30°, 1 s entre elas, preparo 0,9 s | `_bosses` |
| Ritual | escudo de 2,9 m; mortos num anel de 6,5 m em volta dele (`RITUAL_RING`, constante em `boss.gd:65`); até 6 de pé; feiticeiros atiram de 9 m | `_bosses`, `boss.gd`, `_enemies` (mage) |
| Diretor | perto 6 m, longe 10 m | `_bosses` (`near`, `far`) |
| Câmera | distância 54, campo 24°, inclinação 30°: cerca de 32 m de chão de lado a lado | `_feel` (comentário da linha 490) |

Contas (minhas; a conferir pelo `gameplay-engineer` com teste):
1. **Investida**: para existir, o herói precisa conseguir ficar a 9 m ou mais do centro de Morvath. Com ele no centro do
   selo, o raio útil do herói precisa passar de 9 m com folga para andar: **pelo menos 10,5 m**.
2. **Tempestade**: entre duas faixas vizinhas, a 48°, o espaço livre para o centro do herói a uma distância d dele é
   0,81 d − 3 (largura) − 1 (o corpo do herói) = 0,81 d − 4 m. Existe a partir de 4,9 m e passa de 2 m (uma esquiva
   segura sem precisão de pixel) a partir de **7,4 m**. A segunda onda gira 30°: a 10 m o herói anda 5,2 m em 1 s, dentro
   dos 6,75 m/s. Logo, abaixo de cerca de 8 m de raio a tempestade vira roleta.
3. **Foice**: sair dos 5 m (de 1,9 m, o contato, até 5,5 m) exige 3,6 m em 0,8 s, ou 4,5 m/s: andando dá. Pede só 7,5 m
   de raio com ele no centro.
4. **Ritual**: anel de 6,5 m mais o raio de um morto (0,5) e espaço para lutar fora dele: **pelo menos 9 m**.
5. **Câmera**: para mostrar a câmara inteira com margem para a HUD e a regra dos 18% de borda, o diâmetro com a balaustrada
   cabe em cerca de 26 m dos 32 visíveis: **no máximo 12 a 13 m de raio**.
6. **Não deixar fugir**: o herói anda 6,75 m/s e Morvath 3,75: em qualquer arena o herói corre em círculo para sempre
   (risco de "kite" infinito com a seta). O que o impede são as lâminas (peso 2,2 de longe) e a investida; um raio
   pequeno torna os dois inevitáveis de longe, um raio grande dá descanso. 12 m deixa uma faixa de 9 a 12 m onde a
   investida e as lâminas cobrem a fuga.

**Recomendação: raio do chão andável de 12 m para o centro do herói (cerca de 12,5 m até a balaustrada), faixa
aceitável de 11 a 13.** Área de cerca de 450 m², pouco mais da metade do chão de hoje (cerca de 800 m² andáveis). A
documentar em `docs/design/boss_arena.md` com estas contas e os testes que as provam.

- **O que muda no código** (planejamento; dono `gameplay-engineer` salvo indicação):
  - `BossRules`: `eruptions` recebe hoje um `Rect2` (`boss_rules.gd:89`, `boss.gd:175`): passa a receber a forma do
    chão (círculo ou retângulo, uma classe pura nova em `core/`, por exemplo `FloorShape`, com `contains`, `clamp` e
    `edge_distance`, testada); a investida termina na borda (fim da faixa recortado pelo círculo); os pontos de invocação
    (`_ring_spots`) e o `RITUAL_RING` viram dado no `BossDef` e se ajustam ao raio; um teste para cada padrão (foice,
    lâminas, investida, erupções, tempestade com as duas ondas, maldição) com Morvath em 12 posições e o herói em 12
    posições: sempre existe saída andando ou esquivando.
  - `BossDirector`: `near` e `far` relativos ao raio (dado do `BossDef`, não constante); a investida só quando a faixa
    cabe (comprimento livre até a borda acima de, por exemplo, 8 m); peso para voltar ao centro (`TO_CENTER` já existe)
    nas transições.
  - `Ground` e `GroundLook`: faixas de aviso (lâminas, investida, tempestade) recortadas na borda do círculo, sem pintar o
    abismo; o selo central como camada de chão com estados (normal, preparo do ritual, ritual ativo, transição final,
    vitória com o selo restaurado), ligados por `Boss.cue` (que já existe); dono `environment-artist` no desenho.
  - `Arena`: forma circular no `resolve` e no `_onto_floor` (hoje retângulo mais `walk`); entrada pela escadaria a
    sudoeste; colisão de sarcófagos, lanternas e pilaretes fora do círculo andável ou como círculos pequenos; nada de
    canto; transparência contextual (o pontilhado do obelisco, `see_through` no `masonry.gdshader`) para o que ficar entre
    a câmera e a luta; a câmara como cena própria e reutilizável (`BossChamber`, dono `environment-artist`), escolhida
    pelo `StageDef.boss_layout` (hoje `hall`).
  - Câmera: `CamFrame` com limite circular; com 12 m a câmara cabe quase inteira, então a câmera fica perto do centro da
    câmara com um seguir curto (proposta: no máximo 3 m de desvio), para o jogador ver sempre Morvath, as bordas e os
    avisos.
  - Robô: `--bot-kite` (QW-004) para a investida; escolher o vão da tempestade (hoje foge do aviso para onde há chão,
    `Bot._escape`); medir encurralamento na borda.
- **Relação com o que está aberto**:
  - **Avisos genéricos (B4, ART-001)**: fazer aqui, sobre o chão novo (o contraste do vermelho muda); a tempestade
    numerada pela ordem de saída.
  - **Portal vermelho (N7, ART-003, D-14)**: na câmara o norte é a porta selada de ouro e violeta: o portal vermelho sai
    da luta de Morvath; nas salas comuns a decisão D-14 continua.
  - **Investida que nunca sai (M1, QW-004)**: o círculo de 12 m com ele no centro deixa a faixa de 9 a 12 m; com o robô que
    se afasta, aceite de pelo menos 1 investida por luta.
  - **Fase 4 dura**: o círculo tira os cantos e a conta 2 dá vão seguro a partir de 7,4 m; o aceite é por teste de saída e
    por simulação, sem mexer em vida nem dano (pedido do brief).
  - **Bloqueio de corpo e encurralamento (REG-001)**: sem cantos, o herói sempre desliza pela borda; mas a área cai quase à
    metade e o ritual põe até 6 mortos e Morvath nela: **risco maior de cerco no ritual**. Medir; se o robô 0,25 ficar
    preso mais de 1 vez por luta, propor ao Daniel os mortos do ritual atravessáveis (`blocks_body = false`, como os 15
    tipos atravessáveis do Hades II) antes de mexer no teto.
  - **Ritual de alvo móvel (BUG-002)**: precisa estar resolvido antes, senão a medida do ritual no círculo não diz nada.
- **Escopo**: a câmara, o selo com estados, as regras no círculo, a câmera, o robô, ART-001, o documento do raio, as
  evidências pedidas no brief (`docs/gallery/boss_arena/`: arena vazia, Explorador com Morvath, foice, investida, ritual,
  invocação, erupções, maldição, tempestade, vitória com a selagem, antes e depois, vídeo da luta).
- **Fora do escopo**: Meshy e serviços pagos; mudar vida, dano ou preparo de Morvath; trocar a sala das salas comuns;
  modelos novos (sarcófagos, lanternas e pilaretes construídos com `Masonry` e `ArenaKit`, que já têm estátua, braseiro,
  estandarte e corrente).
- **Dependências**: C10 (BUG-001, BUG-002, BUG-009, QW-004); decisões D-15 (salas comuns), D-16 (desenho do selo) e D-17
  (símbolos do perímetro); o raio de 12 m aprovado ou corrigido pelo Daniel não bloqueia (é número de dado).
- **Agentes**: `art-director` (especificação a partir da imagem: medidas, paleta, selo e seus estados),
  `environment-artist` (câmara, selo, perímetro, luz, transparência), `gameplay-engineer` (forma do chão, `BossRules`,
  `BossDirector`, `Ground`, `Arena.resolve`, câmera, robô, testes), `qa-performance` (capturas, vídeo, quadro, simulações).
- **Aceite**:
  - Chão circular de raio entre 11 e 13 m, número em dado, contas em `docs/design/boss_arena.md`.
  - Teste GUT de saída para cada padrão nas 12 x 12 posições, passando.
  - 64 lutas do robô (4 kits com um dom de defesa em cada, reação 0 e 0,25): 0 erros; investida pelo menos 1 por luta com
    `--bot-kite`; robô 0,25 com taxa de vitória igual ou maior que na sala retangular com os mesmos kits; nenhuma morte
    "presa" (herói parado mais de 1 s encostado em corpo ou borda, contado pelo robô).
  - Capturas: o herói nunca a menos de 18% da borda da tela; Morvath e os avisos sempre dentro do quadro.
  - Quadro a 1080p na tomada até 6,5 ms no p90 nas três cenas (fase 1, ritual, fase 4).
  - Revisão do `art-director` sem clarão branco e com o selo nos cinco estados.
- **Evidências obrigatórias**: as do brief, mais o relatório de QA e a revisão de arte.
- **Riscos**: cerco no ritual (acima); "kite" em círculo; a câmara virar uma cópia da imagem de IA sem identidade (a imagem
  traz cruz nos sarcófagos e estrela de oito pontas no selo, ver D-16 e D-17); tempo: é um ciclo G, o maior da lista.

### Teste humano (entre o C11 e o C12)
- Build de Windows com C10 e C11; o Daniel e mais três pessoas; o protocolo está no relatório executivo
  (`docs/design/game_director_review.md`, seção "Plano de teste humano"). Nada de balanceamento antes dele.

### C12 "Combate do Hades por inteiro": economia, romã e raridade
- **Objetivo**: a partida ter a progressão de dons do Hades II (baralho de recompensas, raridade em sequência, romã por
  nível, loja em 3 grupos, ouro por inimigo) e a dificuldade ajustada pelo que o teste mostrou.
- **Justificativa**: `docs/design/hades2_sistemas.md` ("Ordem de implementação", itens 1 a 3, uma versão só) já estudou e
  propôs; sem isso a escolha de dons é rasa e a força na chegada a Morvath é sorte.
- **Escopo**: itens 1 a 3 do estudo; descida inteira (DT-001, D-06) se ainda não entrou; ajuste de Morvath só com dados de
  gente (duração alvo 2 a 4 min, D-11); bônus de sequência (D-10); Magia na luta (D-09).
- **Fora do escopo**: martelo, lendários, Caos, Selene, meta progressão.
- **Dependências**: o teste humano.
- **Agentes**: `gameplay-engineer`, `ui-ux-designer` (carta da romã, loja), `qa-performance`.
- **Aceite**: 32 dons migrados para `base` e `per_level` com teste; o robô chega a Morvath com 5 a 8 dons; o Daniel vence
  Morvath dentro da meta de D-11; nenhuma sala comum com mais de 8 de pé.
- **Evidências**: `METRICAS` com coluna de gente; capturas de loja, romã e carta.
- **Riscos**: mexer nos 32 dons quebrar Elos; mitigação: teste de cada Elo.

### C13 "Som e acabamento": a sensação que falta
- **Objetivo**: golpes e a luta de Morvath com som de verdade, e o restante do acabamento visual aberto.
- **Justificativa**: hoje o "peso" é só imagem; os vídeos não têm som e as receitas são sintetizadas. É a maior distância
  para o Ember & Blade que ninguém mediu.
- **Escopo**: ART-002 (fonte decidida em D-12), ART-003 a ART-009 que sobrarem, mixagem; ART-010 e ART-011 se D-05 liberar.
- **Fora do escopo**: Fase 2.
- **Dependências**: D-12; D-05 para modelos.
- **Agentes**: `art-director`, `environment-artist`, `gameplay-engineer` (gatilhos), `qa-performance` (vídeo com som).
- **Aceite**: cada ataque de Morvath com som de preparo distinto (no teste, o Daniel diz de olhos fechados qual ataque
  vem, 7 de 8); vídeo de 2 min com som em 1080p; `docs/steam-ia.md` e `docs/art/asset_credits.md` em dia.
- **Riscos**: licenças; tempo de produção.

### C14 "Caminho da Steam": controle, opções, salvamento, máquina fraca e motivo para voltar
- **Objetivo**: a vertical slice instalável por um estranho, jogável no controle, configurável, a 60 FPS numa máquina
  modesta e com uma razão para descer de novo.
- **Justificativa**: Steam é o alvo; nunca houve teste com controle físico (QA seção 1) e não há nada entre partidas
  (`SaveData.defaults`).
- **Escopo**: controle físico de Xbox e PlayStation (ícones, menus por foco), opções de vídeo (resolução, VSync, preset
  "baixo" do Forward+), salvamento robusto (versão, arquivo corrompido), DT-003, a meta progressão de D-07 (recomendo a
  menor: Juramentos, só modificadores, sem hub), executável assinado ou instruções (D-13).
- **Fora do escopo**: Android, toque, Fase 2.
- **Dependências**: D-07, D-13.
- **Agentes**: `ui-ux-designer`, `gameplay-engineer`, `qa-performance`.
- **Aceite**: fluxo inteiro só com controle, verificado por gente; 60 FPS no preset baixo numa máquina mais fraca que a do
  Daniel (ou a simulação do DT-003); teste de save corrompido.
- **Riscos**: falta de uma máquina fraca real.

---

## 7. Decisões pendentes do Daniel

Detalhes, opções e argumentos no relatório executivo, seção "Decisões". D-15 a D-19 vêm do pedido da Câmara do Selo.

| ID | Pergunta | Opções | Recomendação |
|---|---|---|---|
| D-01 | Título de Morvath | "o Rei que Traiu a Luz" (hoje no jogo); "Guardião das Catacumbas"; "o Lich-Rei do Sul" (o do cânone) | Não usar "Guardião": no cânone guardião é o Juramentado que segura o selo, e no jogo é o minichefe. Entre os outros dois, o do cânone ou levar "o Rei que Traiu a Luz" para o cânone |
| D-02 | Quem sela Morvath | quatro paladinos (spec original e texto `premise`); um paladino do leão e quatro guardiões (cânone de 12/11); o herói só contém e a selagem fica fora da tela | Seguir o cânone de 12/11; até lá, manter o texto neutro de hoje ("o poder de Morvath foi contido") |
| D-03 | As nove imagens da Hécate que não chegaram | reenviar; desistir da comparação visual | Reenviar só se a meta for imitar a encenação da luta; para mecânica, os dados bastam. Há três imagens de Morvath só locais em `docs/art/ref/morvath/` (`foice_laminas_1`, `_2`, `ritual_escudo_erupcoes`), que não são as da Hécate |
| D-04 | Nomes de `PALADIN_1` a `PALADIN_4` e das famílias de dons | definir agora; depois de D-02 | Depois de D-02 (se forem guardiões, as famílias mudam de dono) |
| D-05 | Créditos do Meshy (546) | peças do cenário (45); repintura de Morvath e elites (cerca de 100); segurar | Cenário prioridades 1 a 3 e Morvath (55) no C13, depois do teste humano; nada no C11 (o brief proíbe) |
| D-06 | Descida de teste (5 salas) ou região inteira (11) | manter curta; voltar à inteira como padrão com `--short` | Região inteira como padrão já no C10 |
| D-07 | Algo entre partidas | nada (cada partida é a mesma); Juramentos (só dificuldade); Vitrais e Obras (o hub do Hades) | Nada na slice de teste; Juramentos no C13; o hub só depois de provar a partida |
| D-08 | Quadro de impacto preto e branco | manter como está; limitar a fase e Ômega com opção de desligar; tirar | Limitar e dar opção |
| D-09 | Magia na luta do chefe (a barra fica em 0/50 quase a luta toda nos quadros do vídeo) | manter como o Hades; dar Magia por janela punida ou pelos mortos do ritual | Medir no teste (QW-001 conta Ômegas) antes de mudar |
| D-10 | Bônus de sequência (não existe no Hades II) | manter; tirar | Tirar para ficar fiel, se o teste não sentir falta |
| D-11 | Meta de dificuldade da primeira vitória | vencer na 1ª tentativa; em até 3; em até 10 | Em até 3 tentativas para quem já jogou Hades, com a descida inteira |
| D-12 | Origem do som e da música | só CC0; encomenda; IA (declarar) | CC0 para efeitos agora; música por encomenda ou CC0 escolhida pelo Daniel |
| D-13 | Assinatura do executável para testadores | certificado; instruções para liberar | Instruções no C10; certificado antes da página da Steam |
| D-14 | Portal vermelho nas fases 1 a 3 | manter; violeta apagado; outra cor | Na luta, a Câmara do Selo (C11) troca o portal pela porta selada; nas salas comuns, violeta apagado (ART_REVIEW N7) |
| D-15 | Salas comuns continuam no salão retangular? | sim, só Morvath na Câmara (o brief); guardiões também numa câmara redonda menor; tudo redondo | Sim: salão para as salas, Câmara só para Morvath; guardiões depois do teste |
| D-16 | Desenho do selo central | estrela de oito pontas com rachadura (a imagem); o leão de pé entalhado, rachado de cima a baixo (o cânone: "cada selo tem um leão de pé entalhado", o de Valmor rachado) | O leão do cânone dentro do anel duplo; confirmar com o Daniel antes do `art-director` especificar |
| D-17 | Cruz nos sarcófagos, pilaretes e estandartes da imagem | manter a cruz; trocar pelo leão ou pela espada erguida (símbolos do cânone) | Perguntar: o cânone fixa três símbolos que nunca se confundem (o leão de Hanokh e Elun, a espada erguida dos guardiões, o olho cortado da Irmandade) e não cita a cruz; sugiro o leão nos sarcófagos e a espada erguida nos pilaretes |
| D-18 | Raio da Câmara | 12 m (calculado); outro | 12 m, a corrigir depois do teste humano (é dado) |
| D-19 | Mortos do ritual atravessáveis na Câmara | não; sim, como os tipos atravessáveis do Hades II | Decidir só se a medida de cerco do C11 pedir |

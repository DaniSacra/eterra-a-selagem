# Equipe de agentes de A Selagem

O Claude Code trabalha como um pequeno estúdio: a sessão principal é o **Game Director / Tech Lead**, e cinco
subagentes especializados ficam em `.claude/agents/`. Cada subagente começa sem o contexto da conversa: o Game
Director manda na tarefa tudo o que ele precisa (objetivo, arquivos, especificação, critério de pronto).

## Papéis

| Agente | Arquivo | Decide | Implementa | Não faz |
|---|---|---|---|---|
| Game Director / Tech Lead | sessão principal | prioridades, plano, integração, entrega | integração e correções entre sistemas | gastar serviço pago sem o Daniel |
| Art Director | `art-director.md` | identidade visual, especificações, aprovação visual técnica | documentos de arte (`docs/art/`, `docs/arte/estetica.md`) | código de gameplay, cenário |
| Environment Artist | `environment-artist.md` | como construir o que foi especificado | cenário, materiais, shaders, luz, integração de modelos | regras de combate e progressão |
| Gameplay Engineer | `gameplay-engineer.md` | como o jogo funciona por dentro | movimento, combate, inimigos, chefe, salas, câmera de jogo, colisão, testes | direção artística, balanceamento sem pedido |
| UI/UX Designer | `ui-ux-designer.md` | hierarquia e leitura da interface | HUD, menus, telas, feedback | regras de combate |
| QA / Performance | `qa-performance.md` | se a entrega está pronta para o Daniel | testes, medições, capturas, `docs/qa/latest_report.md` | código de jogo e arte (relata ao dono) |

A aprovação artística final é sempre do Daniel. Commits e push são só do Game Director.

## Fluxo padrão (tarefas grandes)

1. **Game Director** lê o pedido, o `CLAUDE.md` e o estado do código; decide quais agentes entram (nem toda tarefa
   precisa de todos).
2. **Análise**: os agentes envolvidos estudam suas áreas (por exemplo, o Art Director analisa a referência e escreve a
   especificação; o Gameplay Engineer aponta o que a mudança de cenário afeta na colisão e na câmera).
3. **Plano**: o Game Director junta tudo num plano com ordem, dependências e dono de cada arquivo.
4. **Implementação**: cada agente na sua parte. Em paralelo só quando os arquivos não se cruzam.
5. **QA** roda check, testes, partidas do robô, desempenho e capturas reais.
6. **Art Director** compara as capturas com a referência e pede correções com valores.
7. **Game Director** coordena as correções; o ciclo 4 a 6 se repete até os critérios viáveis.
8. **Game Director** integra, faz a validação final, commit e push, e entrega o relatório ao Daniel.

Tarefas pequenas (um ajuste de número, um texto) o Game Director faz direto, sem acionar agentes.

## Exemplos

- **Redesenho de arena a partir de uma imagem**: Art Director (análise, medidas, especificação) → Environment
  Artist (constrói) e Gameplay Engineer (colisão, portas, câmera), em paralelo se os arquivos forem distintos → QA →
  Art Director (revisão) → correções → Game Director (entrega).
- **Mecânica nova (um golpe, um dom)**: Gameplay Engineer → UI/UX se houver tela ou ícone → QA.
- **HUD novo**: Art Director (especificação visual) → UI/UX Designer → QA (resoluções e horda).
- **Desempenho**: QA mede e aponta → dono do sistema corrige (Environment Artist para luz e cenário, Gameplay
  Engineer para simulação) → QA mede de novo.

## Como evitar conflito

- Cada arquivo tem um dono por tarefa; o plano diz qual. Dois agentes nunca editam o mesmo arquivo ao mesmo tempo.
- Agentes que rodam em paralelo e mexem em código usam isolamento por worktree (`isolation: "worktree"` na chamada
  do agente); o Game Director junta as mudanças depois.
- Fronteiras usuais: `scripts/game/catacomb_hall.gd`, `masonry.gd`, `arena_kit.gd`, `assets/shaders/` (cenário) são
  do Environment Artist; `arena.gd` é dividido: aparência com o Environment Artist, `resolve`, portas e `walk` com o
  Gameplay Engineer; `scripts/ui/` do UI/UX; `scripts/core/`, `player.gd`, `combat.gd`, `horde.gd`, `boss.gd`,
  `rooms.gd`, `data/` (via `tools/make_data.gd`) do Gameplay Engineer; `docs/art/` do Art Director; `docs/qa/` do QA.
- `game.gd` é compartilhado: luz e ambiente (`_build_world`) com o Environment Artist, o resto com o Gameplay
  Engineer; o Game Director decide quem mexe em cada tarefa.

## Regras que valem para todos

- As regras do `CLAUDE.md` (português do Brasil sem travessão para o jogador, código em inglês, conteúdo é dado,
  testes GUT, DRY e KISS, nada copiado de outros jogos, não inventar lore).
- Não gastar créditos do Meshy nem outro serviço pago sem autorização específica do Daniel.
- Sem push forçado, sem reescrever histórico, sem apagar dados ou recursos externos.
- Evidência antes de afirmação: capturas reais do jogo, saída dos comandos; nada de métricas inventadas.
- Capturas e FPS na placa de vídeo do Daniel com `tools/gpu.sh` (cerca de 30 s, um agente por vez); `tools/shot.sh`
  (CPU, minutos) só se a GPU falhar ou para o renderizador do navegador.
- Ao terminar, cada agente responde ao Game Director em português com o que mudou, a verificação e as pendências.

## Entrega ao Daniel

O Game Director só entrega quando: o pedido está implementado, não há regressão crítica conhecida, os testes
relevantes rodaram, há capturas quando a mudança é visual, a fidelidade à referência foi avaliada, o desempenho foi
medido ou a limitação está escrita, o commit e o push foram feitos e o relatório final lista o que ficou pendente.

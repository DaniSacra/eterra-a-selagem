# Revisões visuais

Registro das revisões do Art Director: capturas reais do jogo comparadas com a referência aprovada pelo Daniel.
Critérios e métricas da arena: `docs/art/arena_reference.md`, seção "Critérios de fidelidade".

## 2026-11-14: diagnóstico da arena para a missão de reprodução

- Capturas: `c0_showcase` (vitrine, `--showcase --seed=5`, 1672 x 941, Vulkan) e `c0_game` (em luta), no scratchpad da
  sessão; experimento de névoa e luz numa cópia do projeto (`x1` a `x4`), sem mudança no repositório.
- Bate: câmera, losango da sala, posição do medalhão, da escada, do portal, dos braseiros e dos obeliscos (erros de
  20 a 50 px); tamanho do herói.
- Difere (P0): faixa de valor estreita e azul por causa da névoa sobre a sala; abismo sem profundidade nem violeta;
  medalhão lido como círculo de ritual; portal fraco em forma de casinha, sem verde no chão.
- Difere (P1): chão em pranchas com serrilhado nas juntas; obeliscos finos e pontudos; balaustradas miúdas; estátuas
  do KayKit; estátua gigante cortada no topo; velas e potes pequenos e apagados; braseiros rasos; correntes fora do
  quadro; estandartes curtos; multidão cor de gesso.
- Depende de modelo: escultura das estátuas, relevos da fachada, herói e inimigos da pintura.
- Pedidos: Environment Artist, P0-1 a P1-9 com valores na seção de critérios; P1-10 com dono a definir; UI/UX remover
  a barra de 8 px do topo (`xp_back`).
- Veredito: não aprovado para teste do Daniel; refazer a captura depois dos P0.

## 2026-11-14: ciclo 1 (P0-1, P0-2, P0-3)

- Capturas: `c3/showcase` (Vulkan) e `c3/compat_1.25` (`DRIVER=opengl3`), 1672 x 941, `--showcase --seed=5`, no
  scratchpad da sessão.
- Feito: névoa só depois da sala e névoa de altura no abismo; ambiente petróleo; luz de chave malva sobre o medalhão;
  braseiros com poças menores; profundezas e muralha numa camada de luz própria (`ArenaKit.DEPTH_LAYER`), fora do fogo,
  com três fileiras de colunas e arcos a oeste, luzes violetas baixas só nas laterais, cartões de brilho violeta
  (`abyss_glow.gdshader`) e `FogVolume` violeta no desktop; foco do portal na escada mais forte; medalhão refeito como
  rosa dos ventos de 8 pontas com anéis duplos, 16 volutas, folhas nos vãos e roseta (sem linhas cruzando o miolo),
  pontas longas na horizontal da tela, brilho 0,1.
- Medidas (vitrine, desktop): p1/p5 0/3 (alvo 4 a 10 / 10 a 16), p50 38 (42 a 50), p95/p99 106/167 (>= 105 / >= 170),
  < 20: 27% (9% a 17%), chão azul dominante 40% (40% a 65%), violeta esquerda/direita 7% / 2,9% (>= 6% / >= 3%),
  quentes estourados 0,3% (>= 0,7%), verde no chão 5% (>= 8%).
- Falta: pretos ainda fundos demais nas profundezas e na muralha da frente (subir um pouco a bruma ou o tint); brilhos
  quentes fracos; verde do portal no chão (P0-4); lanterna do abismo como janela ogival (P0-2).
- Navegador: `COMPAT_EXPOSURE` 0,72 para 1,25 e `COMPAT_AMBIENT` 0,3 para 0,4 (p50 36); o violeta do abismo sai azul
  e o chão fica azul dominante 75%: a acertar.

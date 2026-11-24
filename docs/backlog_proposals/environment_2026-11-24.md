# Backlog de cenário, 2026-11-24 (`environment-artist`)

Só leitura de código e documentos; nenhuma captura nova. Não repete AD-09 e AD-10 (arte) nem RD-01 a RD-10 (salas): quando um item toca o mesmo
lugar, aponta para eles. Nenhum item gasta Meshy. Os que precisam de pintura do ChatGPT estão marcados. Contexto: crianças vão jogar o próximo
exe, e a imagem vende o jogo; salas 1 a 5 são as que elas mais veem.

| ID | Prio | Tam. | Dono |
|----|------|------|------|
| EA-01 | P0 | P | environment-artist (captura: sessão principal) |
| EA-02 | P0 | M | environment-artist |
| EA-03 | P1 | P | environment-artist |
| EA-04 | P1 | M | environment-artist + technical-artist |
| EA-05 | P1 | M | environment-artist |
| EA-06 | P1 | M | environment-artist (pede ChatGPT) |
| EA-07 | P2 | M | environment-artist + room-designer |
| EA-08 | P2 | P | environment-artist |
| EA-09 | P2 | M | environment-artist (pede ChatGPT) |
| EA-10 | P2 | P | environment-artist |

**EA-01 (P0, P) Fechar as capturas de cenário que faltam antes do exe das crianças.**
- Problema: Cripta B, Jardim B e Fendas (lab 2 do pacote 2026-11-23) e as casas dos guardiões (`GuardianLook`) entraram "sem medida em imagem"; o
  `ART_REVIEW_2026-11-23` lista laje armada, Suspensão, Trinca e portas como SEM CAPTURA. Hoje não se sabe se alguma sala nova tem vão preto
  como o do AD-09.
- Mudança: uma passada de capturas GPU (estilizado, Perto, uma por vez, só a sessão principal) das salas 1 a 5 e dos dois guardiões, com a medida de
  luma mínima e do vermelho saturado (mesma régua do ART_REVIEW N2). Achados viram ajuste no mesmo lote.
- Aceite: uma folha por sala em `docs/gallery/env_2026-11-24/`; nenhuma região de piso andável com luma abaixo de 30; nenhuma área vermelha cheia
  maior que o aro do aviso.
- Evidência: `docs/art/ART_REVIEW_2026-11-23.md` ("Capturas que faltam"), `docs/reference/art_rooms.md` ("laboratório 2", "Casas dos guardiões").

**EA-02 (P0, M) Leitura do perigo pela peça em todas as salas de criança (salas 1 a 5), com o piso calmo em repouso.**
- Problema: crianças morrem cedo (RD-02: perigos quase não aparecem). Antes do dano a faixa precisa se ler sem texto, e o AT-RA1 pede isso só nas Runas.
  O padrão "pedra em repouso, brasa âmbar no preparo, aro vermelho só nos últimos `Feel.bang_lead`" existe só na laje (`GroundLook.set_plate`).
- Mudança: estender essa gramática às outras faixas e peças (seteira, lâmina, respiração) com uma constante por estado em `GroundLook`, sem material
  novo por instância; valor de luma do aviso sempre acima do piso vizinho em pelo menos 25%.
- Aceite: teste GUT das três fases (repouso, preparo, golpe) por peça; captura de cada perigo armado mostrando contraste com o piso; Compatibility
  também legível (`DRIVER=opengl3`).
- Evidência: ART_REVIEW item 1; `art_rooms.md` SW-G7; backlog linhas 862 a 876 (AT-RA1).

**EA-03 (P1, P) Luz de entrada: a primeira sala acolhe, a sala do guardião avisa.**
- Problema: a luz e a paleta por sala existem (C1V N1 a N3), mas nenhuma regra liga a luz ao pedido de ritmo (calma na 1, tensa no guardião, quente
  na Câmara). AD-10 baixa o brilho do oeste na sala 1 só como correção.
- Mudança: uma tabela `ROOM_MOOD` (energia da luz de fundo, tom da névoa, vinheta) em um único lugar, lida por `ArenaRoom`, valores nomeados.
  AD-10 vira a primeira linha dela.
- Aceite: três capturas (sala 1, guardião, Câmara) em que a luma média cai e o tom esfria na ordem pretendida; sem luz nova por inimigo; `RESULT` igual.
- Evidência: `docs/art/identidade_c1v.md`; ART_REVIEW N3.

**EA-04 (P1, M) Raio-x do herói e do inimigo atrás de peça alta (GR-8) com medida.**
- Problema: o item está "FEITO em parte, sem captura com herói atrás de peça". Colunas, estátuas, estelas e balaustradas escondem o herói na Perto;
  com a Maga e o herói pequeno nas crianças isso é perda de leitura.
- Mudança: revisar a lista de peças que ocluem (`Masonry`/`ArenaKit`) e dar a cada uma a altura máxima de oclusão ou um corte por transparência perto
  do herói; sem peça que esconda inimigo de ataque a distância sem aviso.
- Aceite: teste que varre as peças das salas 1 a 5 e falha se alguma bloquear a linha câmera-herói acima de 1,6 m dentro do plano andável; captura
  do herói atrás de uma coluna.
- Evidência: ART_REVIEW itens 7 e 26; `art_core.md` (raio-x do herói).

**EA-05 (P1, M) Marcos de salas que as crianças vão lembrar: um objeto grande e único por sala.**
- Problema: o objetivo declarado é "os jovens se lembrarem do jogo". O Salão tem o leão e o portal; Cripta, Jardim, Fendas e as casas dos guardiões
  dependem de adereços de caixa e cilindro ("provisório").
- Mudança: um marco por sala em escala monumental (mais de 3 m), só com `Masonry`: Cripta B, o sarcófago-altar com tampa quebrada; Jardim, a árvore
  de pedra seca com luz própria; Fendas, a ponte-arco partida (AT-FB1); Cavaleiro, o brasão de armas gigante de pedra; Ancião, o vitral de luz no
  chão. Fora da colisão, atrás da borda, ou círculo de colisão.
- Aceite: `test_rooms.gd` verde; cada marco visível em captura da entrada da sala; silhueta lida em cinza.
- Evidência: `art_rooms.md` ("Provisório: adereços"); backlog marcos AT-FB1, AT-CS1.

**EA-06 (P1, M) Chão e paredes pintados à mão para as salas 2 a 5 (pede ChatGPT).**
- Problema: o Salão tem o kit pintado (`plano_pintado_a_mao.md`); as outras salas ainda usam cantaria triplanar procedural, que lê como protótipo
  em comparação com o Salão.
- Mudança: pedir ao ChatGPT, no molde do pedido de sala (pintura + vista de cima com medidas + lista de essencial e clima), o kit de textura de
  Cripta, Jardim e Fendas; entra por `masonry.gdshader` como textura por bioma, sem material novo por instância. Procedural segura até chegar.
- Aceite: antes e depois por sala em `docs/gallery/env_2026-11-24/`; mesmo `RESULT`; `tools/smoke.sh 300 --stress=300` sem queda de `fps` medível.
- Evidência: `docs/art/plano_pintado_a_mao.md`; `art_rooms.md` ("Salão, laboratório").

**EA-07 (P2, M) Santuário: a vida entre as estações (HV-D e HV-E, refinados).**
- Problema: o hub é onde a criança volta toda vez; HV-D (leitura de cada estação por silhueta e luz) e HV-E (evolução visual) estão no backlog sem
  uma ordem curta.
- Mudança: primeiro HV-D com a placa da tecla no pé do objeto e luz própria por estação (uma luz de cena por estação, cull sem `CROWD_LAYER`); só
  depois a evolução da Forja (E1) pelo `ForgeRank`, que é a mais visível.
- Aceite: captura do hub com as estações lidas pela silhueta em cinza; E1 muda a peça em duas capturas de `ForgeRank` diferentes.
- Evidência: backlog linhas 929 a 936 (HV-A a HV-E); `hv_santuario_vigilia_art.md`.

**EA-08 (P2, P) Teto de custo da luz e da névoa por sala.**
- Problema: cada olhar novo (AD-10, EA-03, marcos) soma luz e névoa; o cuidado "sem luz por inimigo" não tem número.
- Mudança: constante `MAX_ROOM_LIGHTS` e teste que conta `Light3D` com `light_cull_mask` correto por sala; relatório em `tools/smoke.sh --stress=300`.
- Aceite: teste GUT falha acima do teto; `step_ms` e `fps` anotados em `docs/reference/art_rooms.md` antes e depois do lote.
- Evidência: regras do projeto (desempenho do cenário); `engine.md`.

**EA-09 (P2, M) Vitrine e retrato da imagem do jogo (pede ChatGPT).**
- Problema: "que venda pela imagem": falta uma captura de vitrine estável para a loja e para o Daniel aprovar a direção sala a sala.
- Mudança: modo `--showcase` por sala (câmera fixa, herói em pose, luz de marca) e pedir ao ChatGPT as pinturas-alvo das salas 2 a 5 para comparar
  lado a lado (a de Cripta B, Jardim B e Fendas já existe em `docs/art/salas_pacote_2026-11-23_cripta_jardim_fendas.md`).
- Aceite: uma prancha com cinco salas, cada uma capturada e pintura-alvo ao lado, diferença anotada.
- Evidência: `art_rooms.md` (lab 2); `docs/art/ref/salas_2026-11-23/`.

**EA-10 (P2, P) Compatibility: paridade mínima de cenário no navegador.**
- Problema: Compatibility é secundário, mas AD-09, AD-10 e EA-02 mudam luz e aviso; sem checagem o navegador pode ficar sem o aviso do perigo.
- Mudança: ao fim do lote, rodar `DRIVER=opengl3 tools/shot.sh` das salas 1 e 3 e ajustar `Game.COMPAT_*` só se o aviso do perigo sumir.
- Aceite: aviso do perigo visível em ambas; sem erro de shader no log.
- Evidência: backlog "Compatibility quando muda luz ou material".

## Ordem sugerida
EA-01 antes de tudo (mede o que há), EA-02 e AD-09 no mesmo exe das crianças, depois EA-03/AD-10, EA-04, EA-05. Pedir ao ChatGPT já o kit do
EA-06 e as pinturas do EA-09 (o procedural segura até chegar). Nenhum item pede Meshy nem créditos.

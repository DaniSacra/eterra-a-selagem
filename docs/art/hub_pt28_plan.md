# PT28-11: plano para o Santuário (art-director, 2026-11-27)

Pedido do Daniel depois do exe bf27962f: "Santuário está muito feinho... tem que melhorar bastante, a gente vai ficar muito
tempo lá." Alvo: `docs/art/painted_gpt/hub/aprovacao/hub_aprovacao.png` (aprovada) e a versão de jogo já pronta
`docs/art/painted_gpt/hub/jogo/hub_jogo.png` (sem Videira, luz, água, chama da Vigília). Isto é plano, não implementação.

Evidência usada: `docs/gallery/hub/art_2026_11_27/hub_far_gpu.png` (GPU, commit 3b739624, chamada de "far" mas quase o
quadro Perto) e `hub_portal_cpu.png` (CPU, herói no Portão). Brilho médio do piso da praça (cinza 0 a 255): captura GPU
**139**, aprovada 108, versão de jogo **85**.

## 1. Diagnóstico franco (contra a arte aprovada)

A causa de fundo não é um item: são oito rodadas de ajuste de constantes às cegas (rodadas 1 a 6, Rodada 2 e 3, PM-2 e
PM-2 rodada 2, todas "SEM captura" em `docs/reference/hub/historico-refine-rounds.md`) sobre um cenário de caixas,
cartões e shader de toon. Esse caminho chegou no teto. As salas já são pintura (GP-8); o Santuário é o único lugar que
sobrou no visual antigo, e o contraste piorou a impressão.

| # | Aprovada | Captura de hoje (`hub_far_gpu.png`, `hub_portal_cpu.png`) |
|---|---|---|
| 1 Piso | Lajes variadas, tom médio, calor só nas poças de luz; caminhos lidos pelo desenho do piso | Campo bege claro e uniforme (139 contra 85), lajes de desenho animado com junta preta grossa; ocupa mais da metade da tela e briga com tudo. Contraria "o chão é o palco" |
| 2 Foco e composição | Portão no alto do eixo, escada de tapete vermelho, Videira no centro; tudo converge | Portão cortado na borda de cima, pequeno; o meio-baixo da tela é um bloco elevado vazio (jardineira da praça da rodada 3) com corrimões soltos: o olho cai no nada |
| 3 Videira | Tronco velho retorcido, copa larga com cachos, canteiro redondo baixo com flores: o ponto focal | Bolo de cubos verdes baixo, tronco invisível, canteiro octogonal; o vaso da `VineStation` na frente parece uma segunda Videira |
| 4 Arquitetura | Prédios de pedra clara com telhado, arcos, janelas, emolduram a praça | Caixas cortadas pelo quadro; muretas e parapeitos marrom-escuros lidos como madeira; portão trancado de baixo parece um baú com cadeado |
| 5 Entorno (PM-2) | Penhascos de rocha descendo de todas as bordas, cachoeiras, árvores densas, montanhas | Vazio lilás chapado à esquerda com cubos de pedra empilhados flutuando e a árvore vermelha num pedestal solto; sem penhasco sob a borda; sem cachoeira no quadro. A vila parece boiar num mar roxo |
| 6 Vegetação | Copas redondas e cheias, glicínias, canteiros | Ciprestes e hera como cartões ruidosos espetados; a folhagem deixou de ser preta mas virou ruído |
| 7 Luz | Fim de tarde quente, janelas e lanternas acesas, sombra fria | Luz chapada de meio-dia; lanternas minúsculas; poça branca forte na Vigília (círculos claros, parece holofote); o Portão estoura em branco (`hub_portal_cpu`) |
| 8 Texto na tela | Nenhum | Nomes sempre visíveis flutuando ("Forjador", "Portal da Descida", "A Videira"): poluem a vista |
| 9 Escala | A vila inteira lida de uma vez | O quadro Perto mostra cerca de um quarto do hub; o herói é pequeno contra o piso vazio |

O que já bate: a planta (Portão no alto do eixo, Videira no centro, Mirante a leste, Vigília sem chama, Forja e estufa à
esquerda, Mercador e Capela à direita, dois portões trancados embaixo), o toldo listrado, a árvore vermelha, as glicínias.

## 2. Alvo: o Santuário vira placa pintada (GP-8)? Sim

Recomendo **sim**, pelo mesmo método das salas: captura-base na GPU, pintura gpt-image-2 por cima, 3D só para o que se
mexe, muda de estado ou interage.
- A arte aprovada e a versão de jogo já existem e foram aprovadas: falta só repintar sobre a geometria real (a
  `hub_jogo.png` foi feita sobre a arte, não sobre uma captura, então não encaixa direto).
- A máquina existe (`PaintedHall`, `painted.gdshader`, `ROOMS` por chave, `KEEP_3D`, `PROPS`, planos ao fundo para o
  vazio). O hub entra como mais uma entrada.
- Resolve de uma vez os itens 1 a 7 (piso, arquitetura, Videira de fundo, entorno com penhasco e montanha, vegetação,
  luz quente pintada) e dá consistência com as salas. PM-2 deixa de ser rodada de constantes.
- Custo de API baixo (seção 3).

Riscos e como tratar:
- **O hub rola com o herói** (71 x 47 m; `CAM_REACH` 48). A projeção é sobre a malha real, então vale de qualquer ponto
  perto da pose (como nas salas: pintadas de 68 a 94 m, jogadas a 37 m). Uma placa só a cerca de 95 m dá ~22 px/m
  contra ~30 px/m da Sala 01: um pouco mais macia. Começar com uma placa (KISS, sem código novo); se ficar macia
  demais na captura Perto, dividir em duas placas oeste/leste a 68 m (exige projetor duplo no `PaintedHall`).
- **Telhados e paredes altas** só caem certo se houver malha com a altura certa embaixo; o que for alto e não tiver
  malha escorre no chão. Por isso o passo 2 (geometria) vem antes da pintura.
- **Estados do save** (Forja fria ou acesa, ferramentas, placas da Árvore, lombadas, pano do Mercador, portões das
  Áreas Futuras): a placa é o estado neutro e frio; tudo que muda é 3D por cima, como já é hoje.
- Aposento dos Heróis desligado: a placa não o pinta; quando o Daniel escolher o lugar, uma repintura (US$0,25).
- Navegador (Compatibility): projeção não medida lá; secundário.

## 3. Passos em ordem

| # | Dono | O quê | Critério de aprovação |
|---|---|---|---|
| 0 | Daniel | Aprovar a direção: Santuário pintado; nomes só ao chegar perto; câmera continua seguindo o herói | Resposta dele, antes do passo 1 |
| 1 | technical-artist | No hub: `--no-hero`, `--no-hud` (tira também os nomes flutuantes e os contadores), `--clear-air`, e confirmar que `--showcase --cam-at --cam-dist` enquadram o hub inteiro. Entrada `hub` em `PaintedHall.ROOMS` (desligada até haver placa) e lista do que vira pintura e do que fica 3D (`KEEP_3D`: Videira e vaso, fonte, cachoeiras, chamas e luzes, NPCs, peças de estado das estações, folhas dos portões trancados, brilho do Portão) | Captura-base sem herói, sem HUD, sem texto, hub inteiro no quadro; `--smoke` seed 5 com o mesmo `RESULT` |
| 2 | environment-artist | Acertar a geometria pela `hub_jogo.png` (sobreposição com `hub/overlay.sh` sobre a captura-base): tirar o bloco elevado e os corrimões do meio-sul (praça da rodada 3) e deixar o piso e os dois portões como na arte; canteiro da Videira redondo e baixo; vaso da `VineStation` encostado no canteiro (um objeto só no olho); penhasco sólido sob todas as bordas até cerca de 15 m abaixo (carrega a pintura); volumes dos prédios, Portão e muretas na altura da arte; tirar os cubos de pedra soltos e o pedestal da árvore vermelha | Sobreposição: Portão, prédios, escadas, portões de baixo e canteiro a no máximo 30 px (em 1536) da `hub_jogo.png` |
| 3 | sessão principal | Captura-base (seção 4, B) | Arquivo para o passo 4 |
| 4 | ai-art-producer | Placa de jogo: edição com imagem 1 = captura-base, imagem 2 = `hub_jogo.png`; pedido = regras de `hub/jogo/pedido.txt` (sem luz, água, Videira, chama da Vigília; piso ~35% de brilho; sem texto, figura, símbolo) + "manter a geometria da imagem 1" + encaixe em frações; mais um plano de fundo com penhascos e montanhas (PM-2) se o vazio ficar fora da placa. 1 a 3 tentativas; entregar lado a lado e encaixe em `Downloads\ASelagem-GP8\GPT-Hub2` | Encaixe dentro de 30 px nas peças do passo 2; brilho do piso da praça 70 a 90; nenhuma letra, figura ou emblema |
| 5 | Daniel | Aprovar a placa (lado a lado com a arte aprovada) | Resposta dele |
| 6 | technical-artist | Ligar: `assets/rooms/painted/hub.png`, pose na entrada `hub`, `PROPS` para o que a placa já tem; esconder o cenário estático 3D que a placa substitui (hera, ciprestes, flores em cartão, rochas, balaústres) | Captura Perto sem nada duplicado nem escorrido; mesmo `RESULT` |
| 7 | environment-artist | O vivo em 3D sobre a placa fria, nos pontos medidos na placa: Videira nova (tronco retorcido, copa larga, cachos, maior que hoje), água das cachoeiras nos leitos secos pintados, fogo da Forja, luzes das lanternas e janelas, luz do Portão sem estourar; luz da sala de fim de tarde (chave quente baixa, sombra fria). Vigília: só o patamar, sem poça branca | Capturas Perto (seção 4, C) com a Videira como foco, o Portão sem branco estourado, nenhuma chama na Vigília |
| 8 | ui-ux-designer | Nomes das estações só a cerca de 6 m ou no foco, menores, no estilo das placas do jogo | Captura Perto sem nome longe do herói |
| 9 | art-director, depois Daniel | Revisão em `docs/art/visual_review.md` com as capturas C; exe para o Daniel junto com o lote | Veredito escrito; aprovação final do Daniel no exe |

Passos 1 e 2 podem correr juntos (arquivos diferentes). Custo de API: placa 1 a 3 x US$0,25, fundo 0 a 2 x US$0,25,
divisão em duas placas se precisar 2 a 4 x US$0,25: **cerca de US$1 a 2,50** no total (exige crédito na chave da
OpenAI; registrar em `docs/steam-ia.md` e no README do `painted_gpt`).

## 4. Capturas na GPU (só a sessão principal, uma por vez)

`<s>` = scratchpad. O `gpu.sh` já sai estilizado e Perto. A pose do quadro inteiro é o centro do hub no mundo
((u 6,5; v 6,5) em `HubPlan.to_world` com giro 35 = x 1,6; z -9,1).

A. Agora não precisa: as capturas de 3b739624 bastam para o diagnóstico.

B. Captura-base (depois dos passos 1 e 2):
```
RES=2560x1440 tools/gpu.sh shot <s>/hub_base.png --hub --hub-open=all --no-hero --no-hud --clear-air --showcase --cam-at=1.6,-9.1 --cam-dist=95 --cam-yaw=35 --cam-pitch=30 --cam-fov=24 --shot-at=3
```
Se o Mirante (leste) ou o penhasco de baixo saírem do quadro, repetir só com `--cam-dist=105`.

C. Conferência depois do passo 7 (três, em sequência, nunca juntas):
```
tools/gpu.sh shot <s>/hub_chegada.png --hub --hub-open=all --shot-at=4
tools/gpu.sh shot <s>/hub_portao.png --hub --hub-open=all --hero-at=portal --shot-at=3
tools/gpu.sh shot <s>/hub_videira.png --hub --hub-open=all --hero-at=tree --shot-at=3
```
As três vão para `docs/gallery/hub/pt28/` e para `C:\Users\danie\Downloads` lado a lado com a `hub_aprovacao.png`.

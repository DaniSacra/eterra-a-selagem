# CRÔNICAS DE ETERRA: A SELAGEM
## Santuário da Vigília — direção de arte, layout construível e evolução | Rev. 02 | 20/11/2026

**Decisão de produto:** o Guerreiro retorna **sempre no canto sudeste** após a derrota ou ao carregar um save já iniciado; a área anteriormente prevista para expansão passa a abrigar o **Pátio do Retorno**, associado à escadaria sul/sudeste. A posição central **não é spawn**. A Fonte do Leão é o marco social e visual, sem função de cura presumida. Há uma sexta estação física reservada, **Alquimista**. As cinco estações existentes no jogo permanecem com suas funções e não são substituídas.

**Fonte da informação técnica:** branch `arpg-3d` revisada em `52fcbb1` (2026-11-20). `scripts/game/hub_look.gd` descreve as cinco estações, Fonte do Leão decorativa, moldura da câmera e materiais; o estudo `docs/design/oficios/README.md`, `02_visao_e_grafo.md`, `07_npcs_e_encomendas.md`, `09_receitas_e_ferramentas.md` distingue sistemas existentes de propostas e decisões pendentes. A inclusão do Alquimista é **nova diretriz do proprietário**, diferente da recomendação do estudo de adiar NPCs. **Não apresentar os sistemas de Alquimia como implementados.**

### Arquivos gráficos deste pacote

- `01_pintura_conceitual_isometrica.png`: **pintura de referência artística**, com o Guerreiro no retorno sudeste, Fonte central e estações ao redor. É uma aproximação visual da câmera solicitada; a correspondência matemática com 35°/30°/24° deve ser verificada na Godot.
- `02_planta_superior_medidas.png`: **planta técnica prevalece** sempre que houver contradição de proporção/posição com a pintura. Dimensões e pontos de uso aproximados em metros, áreas físicas e trajetos.
- `02_planta_superior_editavel.svg`: mesma planta, vetorial, para redimensionar e importar como guia.
- `06_closeups_estacoes_e_retorno.png`: recortes para silhueta e reconhecimento em câmera.
- `06_painel_referencial_estacoes.png`: painel artístico complementar ilustrado. **Não usar medidas ou posição de spawn desse painel**; desenhos de painéis conceptuais não têm precisão de coordenadas.

---

## 1. PINTURA CONCEITUAL — ÂNGULO, IDENTIDADE E TOM

**Câmera fixa**: yaw **35°**, pitch **30° para baixo**, FOV **24°**, distância **37–54 m**, projeção em losango quase isométrica. Herói **2,5 m de altura**. A pintura deve ser confrontada com captura real nessa câmera, 16:9, sem alterar os enquadramentos estabelecidos para combate. O cenário deve caber no quadro de referência; ao andar, a câmera pode acompanhar conforme o `HubPlan` existente, mas não substituir a perspectiva.

**Ambiente**: pátio aberto de calcário morno, ao entardecer, suspenso sobre penhasco com bruma profunda, arcarias arruinadas e duas ou três cascatas distantes. Não é templo de terror, mas refúgio de aventura: antigo, cuidado e habitado, com vegetação, fogo, sinais de uso, pequenas atividades de NPCs e luz de Elun. **Não incluir cruz, sol estilizado com raios, auréola, deuses, estrela como símbolo novo**. O leão é símbolo dominante, sobretudo no portal, fonte e pavimento.

**Linguagem de arte**: fantasia 3D ilustrada com materiais pintados, blocos de luz e sombra grandes, contornos controlados, textura perceptível nas bordas e piso central sereno. Não copiar geometria, personagens ou texturas de Hades II ou SWORN. Referências de leitura: Hades II (hub habitável, curiosidade e circuitos), SWORN (silhuetas e acabamento desenhado), Ravenswatch (ambiente narrativo) e Ember & Blade (sensação pintada).

**Composição de tela**: o PORTAL ao norte é o ápice focal da cena, mesmo quando o jogador aparece no sudeste. A FONTE organiza a praça. O retorno é secundário e acolhedor, não um monumento maior que o portal. A árvore de pedra e ouro, o fogo da forja, o toldo do Vendedor, a luz na biblioteca e a bancada de Alquimia distinguem-se pelas silhuetas.

---

## 2. PLANTA SUPERIOR CONSTRUÍVEL — MEDIDAS, PORTAS, HERÓI, COLISÃO E PERCURSOS

**Referencial local para a planta**: `x` cresce para leste (direita), `z` cresce para norte (alto). A conversão final para coordenadas da Godot precisa usar o `HubPlan` e a moldura girada pelo `HubLook`; NÃO mapear literalmente o norte desta folha ao `Vector3.z` positivo do mundo sem aplicar a transformação existente.

**Área bruta do piso** ~**50 × 32 m**, de x=-25 a +25 e z=-16 a +16. A área realmente andável é recortada por bordas, estações e fonte. Área útil central sugerida aproximadamente 44 × 28 m antes dos recortes. O limite do penhasco e as arcarias não são atravessáveis. As medidas são **proposta**, e não medidas aferidas da build.

| Objeto / estação | Centro visual (x,z) m | Ponto de uso / spawn (x,z) m | Ocupação aproximada / colisão | Função |
|---|---|---|---|---|
| **Retorno / nascimento sudeste** | (+18,-11,4) | **(+18,-11,4)** | selo de 3 m diâmetro, **não bloqueia**; escada 7 × 2,5 m na borda sudeste | spawn após derrota e retorno ao save; porta visível em perspectiva norte |
| **Portal das Catacumbas** | (0,+12,2) | (0,+10,1) | pórtico 7,5 × 2,4 m atrás da interação; escadaria 8,4 × 2,1 m | **E** inicia a descida; elemento mais alto/lido primeiro |
| **Forja / Forjador** | (-10,6,+7,1) | (-10,3,+5,2) | forno/bigorna em plataforma 6,6 × 3,7 m, colisão só nas peças reais | Temperar, Refinar, ferramentas, Oficina proposta |
| **Vendedor** | (-10,6,-7,1) | (-10,3,-5,2) | tenda/balcão 6,5 × 3,6 m; balcão bloqueia, toldo não | encomendas e Obras previstas; estado inicial pode ser fechado |
| **Árvore de Dons** | (+10,7,-7,3) | (+10,1,-5,1) | base 6 × 5 m; tronco e raízes/altar com footprint fiel | Dons / Maestria / Memória conforme jogo |
| **Biblioteca / Livro de Ahk** | (+10,6,+7,2) | (+10,1,+5,0) | arcada 6 × 3,6 m; estantes/atril colidem; tapete não | história, bestiário, capítulo Ofícios planejado |
| **Alquimista — NOVO** | (-18,4,0) | (-15,0,0) | bancada/toldo 4,3 × 5 m, nunca invadir trilho de circulação | reservar lugar e NPC; **alquimia ainda não é mecânica aprovada/implementada** |
| **Fonte do Leão** | (0,0) | sem interação obrigatória | cuba bloqueante raio ~3,1 m, água decorativa, não atravessável | orientação espacial, lugar de descanso e reunião |

**Fluxo inicial deliberado**: depois da derrota, a câmera revela o Guerreiro no selo sudeste; o Livro está logo adiante pela esquerda/nordeste, a Fonte aparece no centro e o Portal destaca-se ao fundo. Não teleportar do spawn para o centro, não acender 6 marcadores HUD simultaneamente. A caminhada breve até a Praça estimula perceber mudanças e NPCs sem transformar visitas repetidas numa penalidade.

**Rotas principais**: retorno -> Livro -> Fonte (contorno leste) -> Portal; retorno -> Árvore -> anel leste -> Portal. Rotas complementares: Portal -> Vendedor; Portal -> Forja; Forja -> Alquimista -> Vendedor; Vendedor -> contorno sul da Fonte -> Árvore -> Livro. **Nenhuma rota cruza a água da Fonte**. O anel oferece dois desvios, para evitar corredor único que obriga a atravessar todos os NPCs.

**Larguras livres sugeridas**: principal **4–5 m**, secundárias **3 m**, passagem em torno da Fonte pelo menos **3,5 m**; mínimo pontual de **2,8 m** para herói de 2,5 m somente após teste de colisão e câmera. **Até 4 segundos entre estações** é **meta de playtest**, não garantia: medir na velocidade real do herói, seguindo NavGrid, entre os pontos de interação. Se falhar, aproximar as bases ou redesenhar os acessos; não falsificar com teleporte e não alterar o ritmo do Guerreiro só para passar no teste.

**Obstáculos intencionais**: (a) Fonte raio 3,1 m; (b) balcões, bigorna, tronco e estantes dentro da ocupação informada; (c) colunas de 1,2–1,8 m nas bordas; (d) canteiros/bancos próximos às muretas, afastados das rotas. **Proibido bloquear**: spawn e a saída das escadas; avanço ao Portal; placa da tecla E; raio de aproximação de estação; laterais da Fonte; linha de visada do Portal desde o retorno. O penhasco deve ter bordo físico sem arestas atravessáveis.

---

## 3. PEÇAS — ESSENCIAIS E DE CLIMA

### (a) Essenciais; não cortar sem aprovar novo layout

| Peça | Tamanho aproximado | Material / cor | Exigência funcional |
|---|---|---|---|
| Piso pátio e contorno | 50×32 m; bordas 1–3 m | calcário bege quente e sombras petróleo | colisão/navmesh, contorno não rectangular, sem vãos invisíveis |
| Escadaria + selo retorno SE | 7×2,5 m / selo Ø3 m | calcário antigo e ouro velho apagado | spawn estável, câmera enquadra portal; não ocupar expansão futura genérica |
| Portal e escada norte | conjunto ~8×6×8 m alto | pedra escura, relevo do leão, verde-pálido interno | abertura/ação E identificáveis desde retorno; saída única da descida |
| Fonte do Leão | Ø6,2 m, altura 1–3 m | pedra creme, água petróleo/azulada | massa visual central e bloqueio físico correto; não é cura |
| Forja + bigorna e Forjador | 6,6×3,7 m; forno 2,5–3,5 alto | pedra cinza quente, ferro, brasa âmbar | acesso frontal à ação Forja/Oficina; NPC atrás do balcão |
| Vendedor e toldo | 6,5×3,6 m, altura 3–4 m | madeira, couro, vinho/ocre, lanternas | balcão estado fechado/aberto; venda/Obras não presumir implementadas |
| Árvore de Dons | base 6×5 m, copa alta ~8–10 m | tronco pétreo, veios ouro velho, folhas ocre | árvore distinta da vegetação e da Emeth; entrada clara à tela de Dons |
| Biblioteca / Livro de Ahk | 6×3,6 m, fachada 4–6 m | calcário, madeira escura, pergaminho iluminado | atril com livro ABERTO, espaço de leitura e acesso seguro |
| Espaço do Alquimista | 4,3×5 m, mesa 2×0,8 m | madeira escura, cerâmica, vidro verde amortecido | espaço reservado imediato; futuro NPC e função sem alterar corredor |
| Trilhas e anel da Fonte | 3–5 m de largura | lajes claras, juntas discretas, filete ouro velho | direcionamento por geometria e iluminação, não chão neon |

### (b) Clima; cortar, reduzir ou mover se atrapalhar

| Peça | Tamanho aprox. | Material / cor | Observação |
|---|---|---|---|
| Arcadas quebradas e colunas ao fundo | 2–4 m por vão, 3–8 m alto | pedra fria, musgo sutil | manter **fora do caminhar**; profundidade em camadas |
| Cascatas/penhasco sob bordas | 5–20 m de queda aparente | água fria e neblina petróleo | sem reflexo alto ou custo excessivo de partículas |
| Vasos e caixas decorativas | 0,35–1,0 m | cerâmica terrosa / madeira | apenas junto à parede; diferenciá-los de objetos quebráveis das runs |
| Braseiros auxiliares e lanternas | 0,6–2 m | ferro, fogo âmbar | luz pontual com limite de brilho |
| Flores, hera, canteiros | manchas 0,4–3 m | verde-oliva, violeta muito moderado | não competir com a árvore de ouro |
| Bandeiras com leão | 1×3 m | tecido vinho e ouro velho | sem iconografia nova |
| Bancos de repouso | 2×0,6×0,5 m | madeira envelhecida/pedra | perto da borda, nunca atalhos |
| Manuscritos, ferramentas e frascos | 0,1–0,8 m | pergaminho, ferro, vidro | reforçam profissão sem virar botão falso |
| NPCs de ambientação e gestos | ~2–2,5 m de altura | roupa de terra e couro | personagens do cânone a decidir; não inventar nomes |

---

## 4. LUZ — ORIGENS, CORES, ÁREAS E HIERARQUIA

| Fonte | Posição / direção | Cor / temperatura visual | Região iluminada / restrição |
|---|---|---|---|
| Entardecer baixo, fonte natural **fora do quadro** | vindo do oeste (x negativo), 15–25° acima do horizonte | pêssego/creme #EBC9A0 | penhasco, bordas das pedras, copa; **sem desenhar disco solar nem ícone com raios** |
| Ambiente / céu e bruma | difusa em todo o pátio | petróleo frio #263E45 | sombras legíveis, nunca fundo preto |
| Portal das Catacumbas | dentro do arco norte | verde-pálido #9FC8A1 / miolo mais claro | **área focal mais clara e distinta**, luz contida no vão/escadaria, não banhar a fachada inteira |
| Forja | forno inferior/esquerda | âmbar intenso #E8A15C | bigorna, mãos do Forjador e piso do uso; fogo controlado |
| Biblioteca | luminária e escrivaninha inferior/direita | dourado suave #F0C98C | livro aberto e mãos; uma poça legível |
| Vendedor | 2 lanternas sob toldo superior/esquerda | âmbar suave #DCA36E | balcão e produtos; não igualar intensidade do Portal |
| Árvore de Dons | veios internos no tronco e copa superior/direita | ouro velho #BEA66B | silhueta de copa, pé pouco emissivo; sem néon |
| Alquimista | pequenas lâmpadas e bancada lateral oeste | âmbar com verde desaturado #9BAE83 | área de trabalho, NÃO criar um segundo portal esmeralda |
| Fonte | reflexão indireta do céu | cinza-azul #5F8185 | água em valor médio, leão iluminado pelo poente |
| Spawn de retorno | lampião baixo e gravura de chão sudeste | âmbar baixo #BCA07B | herói visível sem competir com o portal |

**Valor geral**: Portal primeiro, fonte e leão em valor intermediário, estações contrastadas por pequenas poças, bordas, cascatas inferiores e volumes atrás do Alquimista mais escuros. O caminho central não deve ficar tão claro quanto os pontos de uso. Em Compatibility/OpenGL, controlar saturação do verde e exposição das chamas.

---

## 5. HIERARQUIA DE LEITURA — EM 3 SEGUNDOS

1. **Portal**: posição alta, abertura verde-pálida cercada de cantaria e leão em relevo. Deve ser achado imediatamente ao nascer no canto sudeste.
2. **Fonte do Leão**: referência central de percurso, forma larga e horizontal com jato de água. Não é estação funcional nem spawn.
3. **Estações**: Forja (forno e bigorna), Vendedor (toldo), Dons (árvore dourada), Ahk (livro aberto e arcada), Alquimista (frascos e mesa), nessa leitura de silhuetas; o retorno é uma **origem discreta**, identificável ao carregar.

Regra de UX: interação **E** só na distância apropriada do objeto, com placa no pé do objeto, sem seis ícones flutuando permanentemente. A posição de cada estação precisa ser lembrável pela silhueta e pela luz mesmo após múltiplas runs.

---

## 6. CLOSES — O QUE CADA ESTAÇÃO PRECISA MOSTRAR

No arquivo `06_closeups_estacoes_e_retorno.png` há recortes da pintura original. Use como **moodboard**, depois compare com a geometria e a iluminação reais.

| Estação | Silhueta obrigatória | Objetos próximos que contam a história | Reconhecimento de longe |
|---|---|---|---|
| **Portal** | arco alto com coroamento do leão e vazio luminoso | degraus, duas luminárias, pedras antigas | um só rasgo verde alto |
| **Forja** | forno baixo com chaminé, bigorna dianteira | martelo, metal, ferramentas pendentes, Forjador | fogo concentrado na parte baixa |
| **Vendedor** | toldo de duas águas, assimétrico | balcão, bolsas, baús, livro de encomendas | mancha ocre/vinho horizontal |
| **Árvore de Dons** | tronco pétreo largo e copa em ouro velho | placas de Dom, pedras fincadas, caminhos radiais | maior volume orgânico da cena |
| **Livro de Ahk** | atril diagonal com livro de grandes páginas iluminadas | estantes, mapas, pergaminhos, cadeira | retângulo claro de páginas dentro de arcada |
| **Alquimista** | bancada semicoberta com frascos altos | ervas penduradas, almofariz, frascos, balança | recipientes verticais em luz verde bem baixa |
| **Retorno** | pequeno selo de pavimento no canto SE e escada | dois braseiros menores, beiral, marcas gastas | o jogador nasce e reconhece o caminho, não monumento central |

---

## 7. EVOLUÇÃO DO SANTUÁRIO — ATÉ CINCO MUDANÇAS VISÍVEIS

**Separar mudanças visuais aprováveis de implementação de progressão**. O hub não deve acender tudo após a primeira morte.

1. **Forja cresce com Temperar/Refinar e ferramentas**: primeira melhoria acende um braseiro, depois armações e suportes recebem ferramentas restauradas; não multiplicar VFX.
2. **Vendedor ganha atividade quando encomendas/Obras forem aprovadas**: toldo se abre, bancada expõe mapas e mercadorias; refletir `Balcão fechado` -> `Tem um pedido` -> `Aberto` sem inventar comércio não implementado.
3. **Árvore de Dons revela ramificações conforme Maestria/Dons**: placas antes opacas ganham detalhes e luz sutil; progresso visual, não itens no chão.
4. **Livro de Ahk se expande com descobertas reais**: novas lombadas, fichas do Compêndio e uma prateleira de Ofícios (somente quando a mecânica existir). Não inventar diálogo direto de Ahk.
5. **Alquimista ocupa a área reservada progressivamente**: inicialmente bancada vazia e ervas secas; após aprovação do Roteiro C, entram bancada em uso, NPC, reagentes e encomendas interligadas; **sem receitas, bônus, drops, recursos ou preços inventados nesta entrega**.

**Conexão com Ofícios**: o estudo recomenda prototipar Picareta achada partida, restaurada no Forjador por Prata, Fendas/Runas com veio após o combate, Pedra Funda, encomenda do Vendedor e primeira Obra que amplia informação no mapa. É **proposta em discussão, não feature já implementada**. O Alquimista foi explicitamente pedido agora e pode coexistir como preparação de cenário, mas qualquer grafo de ervas/óleos deverá passar por decisão de design e não deve bloquear Dons, Forja, Portal ou a vitória.

---

## COMO A IA QUE IMPLEMENTAR DEVE PROCEDER

1. Inspecionar `HubPlan`, `HubLook`, cenas de Hub, portões de interação e persistência. Localizar a convenção da moldura antes de alterar posições.
2. Criar a planta como teste de geometria **sem trocar assets**: spawn sudeste, Portal norte, Fonte central, cinco estações atuais preservadas, Alquimista reservada à esquerda entre Forja e Vendedor. Ajustar navegação e encaixes usando o **mesmo dado** para desenhar e colidir.
3. Conferir **do spawn** se Portal está no enquadramento/campo de visão, sem câmera atravessando paredes; corrigir cânone da posição de spawn em todos os fluxos: morte, salvar, carregar, prólogo, hub, teste automatizado.
4. Fazer greybox das circulações com percurso registrado, não apenas imagem bonita. Percorrer 6 estações e Portal em sequência, testar dupla mais distante em tempo real e com colisão; meta 4s.
5. Aplicar materiais e luz como pintura, preservando recursos atuais, shaders STYLIZED e alternância `F7` CLASSIC sem quebra; sem Meshy.
6. Separar programação do Alquimista em **placeholder planejado**, sem NPC inventado, sem economia improvisada.
7. Capturar 1920×1080 na câmera **35°/30°/24°**, distância aplicada conforme limite do jogo, e 1280×720 Compatibility. Enviar **três provas**: vista do spawn sudeste, chegada ao Portal, voltas pelas estações. Ajustar antes de adicionar clima.
8. Criar testes para spawn correto, portal acessível, todas estações alcançáveis, obstáculos consistentes, câmera/oclusão, nenhum caminho bloqueado e `CLASSIC` reversível.
9. Entregar SHA, lista de alterações, tempos reais entre estações, galeria antes/depois por caminho, gargalos e itens ainda só previstos. O Game Director não deve afirmar implementação completa a partir de arte conceitual.

## Referências consultadas e limites

- [Hades II — Crossroads hub](https://hades-2.game-vault.net/wiki/The_Crossroads): retorno entre runs, áreas funcionais e personagens; referência de UX, não desenho a copiar.
- [Hades II — galeria de imagens oficiais republicadas](https://thegameextras.com/game/hades-ii/screenshots/): direção de arte e escala visual.
- [SWORN — página Steam](https://store.steampowered.com/app/1763250/SWORN/): direção de fantasia pintada e visão isométrica.
- [Ravenswatch — site do estúdio](https://www.passtechgames.com/ravenswatch/): atmosfera e clareza de personagens.
- [Repositório — commit analisado](https://github.com/DaniSacra/eterra-a-selagem/commit/52fcbb1e0a1742e46fc2546c61828049e1e6130e).

**Prioridades e limites**: a planta anexa prevalece sobre as pinturas; as proporções e a lente das pinturas não são metrologicamente verificadas; custos e mecânicas de Ofícios vêm de **documentos de proposta** e necessitam aprovação do proprietário antes de virar dados de jogo.

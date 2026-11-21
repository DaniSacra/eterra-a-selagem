# Eterra | Próximo ciclo de layout e interação das salas

Game Director de **Crônicas de Eterra: A Selagem**, use este prompt e o arquivo `Eterra-Atlas-das-Salas.pdf` como um único briefing. Leia os dois antes de planejar. Atualize o backlog por sala, implemente o primeiro lote jogável e valide-o na câmera normal do jogo.

## Base e direção

O atlas contém 20 pranchas. Elas cobrem as 18 vistas da descida, o encontro do Guardião e o Santuário da Vigília. As plantas usam o commit `9271e95`, e as capturas são da build `4098f7a`. Confira o estado atual da branch `arpg-3d`, os benchmarks já documentados e o backlog. Reaproveite os ajustes que já entraram. Fonte e Loja usam a base do Salão. O Guardião pode usar as variantes do Santuário Desmoronado. As manchas douradas do PDF indicam focos visuais aproximados. A página 2 reúne hipóteses de mudança no layout jogável.

Use Hades II como referência para a hierarquia entre piso, figuras e avisos. Use SWORN para variar a forma das salas, as coberturas e as travessias. Em Eterra, mantenha baixo o contraste de detalhes pequenos do piso e concentre a identidade de cada ambiente nas massas de luz, bordas e marcos reconhecíveis.

Para cada sala, registre quatro pontos no backlog: **marco visual, decisão de movimento, quebráveis e perigo, quando houver**. Toda sala deve ter objetos quebráveis. Reserve os perigos novos para salas onde eles criam uma escolha real. Em várias delas, a geometria já faz esse trabalho.

## Direção por sala

| Sala | Layout, movimento e interação |
|---|---|
| **Salão das Catacumbas** | Use o acesso sudoeste e o medalhão como eixo de leitura até o portal. Concentre alvenaria, sombra e luz âmbar nas bordas e no fundo. O centro amplo serve para experimentar a Emeth e enxergar o primeiro aviso de ataque. Inclua vasos, urnas menores ou bancos rachados. |
| **Cripta A** | Faça o sarcófago isolado dominar a composição. Deixe os dois flancos legíveis para quebrar a mira dos atiradores. Diferencie as lajes rachadas dos túmulos decorativos. Use cerâmica funerária nas áreas de chegada e contorno. |
| **Cripta B** | Faça o ossuário linear dominar a composição. Preserve a passagem ao sul e a diferença entre os flancos. Posicione o esqueleto de nicho onde a aproximação à parede seja uma escolha. Vasos menores e restos de bancos podem quebrar. |
| **Fendas A/B** | Em A, deixe as travessias disponíveis identificáveis pelo recorte do piso. Em B, faça a ruptura ao norte aparecer de relance. Nas duas, preserve a volta pelo sul. Use madeira solta e caixotes junto aos acessos, com silhueta distinta da estrutura das pontes. |
| **Jardim A/B** | Mostre como contornar o tronco e as raízes. Em B, dê identidade à borda úmida com água e pedra fria e inclua a planta hostil enraizada. Distribua galhos secos, mudas frágeis e vasos de água. |
| **Santuário Desmoronado A/B** | Em A, faça a nave aberta organizar o confronto. Em B, deixe o buraco e os desvios laterais legíveis antes da esquiva. Use recipientes de oferenda quebráveis e aplique o teste das lajes sem confundi-las com decoração. |
| **Ponte A/B** | Diferencie duas travessias com pausa no meio de uma travessia longa com patamar. Use fundo e luz baixa nas cabeças de ponte para reforçar a leitura. Coloque tábuas soltas e caixotes longe da linha principal de movimento. |
| **Runas A/B** | Em A, destaque a ameaça em faixas. Em B, destaque os ladrilhos ativos. Mantenha o repouso discreto e capture a preparação e a ativação. Use suportes ou recipientes quebráveis afastados dos estados do piso. |
| **Guardião** | Valide o encontro no Santuário Desmoronado A e B. Preserve a leitura do Guardião, das colunas e dos avisos. Ponha os quebráveis no acesso ou na periferia. |
| **Fonte** | Faça a água e o ponto de cura serem reconhecíveis na aproximação. Ponha os vasos quebráveis onde seus efeitos não se confundam com a cura. |
| **Loja** | Deixe ofertas, preços e saída legíveis com a fileira curta ou cheia. Use caixotes ou cerâmica periféricos, com distância dos pedestais de compra. |
| **Provação e Altar** | Dê a cada ambiente uma silhueta própria e deixe a ação e suas consequências legíveis antes da confirmação. Use oferendas quebráveis visualmente distintas do selo e do altar. |
| **Câmara do Selo** | Preserve o círculo de combate e o selo. Trabalhe a profundidade do anel externo. Posicione os quebráveis na periferia ou no acesso, respeitando as áreas seguras e os avisos de Morvath. |
| **Santuário da Vigília** | O eixo de chegada conduz ao Portal. Dê uma silhueta e um foco de luz próprios às estações. Reserve os quebráveis a espaços afastados dos pontos de uso. |

## Três protótipos de perigo

1. **Laje de pressão no Santuário Desmoronado.** Parta do sistema de lajes existente. Ao pisar, a laje afunda ou racha e anuncia a ativação. Coloque-a em um flanco útil com rota de contorno. Teste se o jogador consegue atrair um inimigo para ativá-la.
2. **Esqueleto no nicho da Cripta B.** Use uma mão exposta ou ossos que se mexem para identificar o nicho. Na aproximação, mostre o preparo com movimento e som de pedra. O esqueleto tenta agarrar em alcance curto, preso ao nicho. O jogador deve ter tempo de recuar ou esquivar.
3. **Planta hostil no Jardim B.** Use uma planta fixa na borda. As folhas se contraem antes da chicotada curta da raiz. A Emeth não causa dano à planta. Diferencie sua silhueta da vegetação frágil para que o jogador entenda a resposta esperada: esquivar ou contornar.

Use as Runas e as lajes como referências internas de aviso. Confira início do preparo, alcance, impacto e sobreposição com avisos de inimigos. Cada perigo precisa comunicar o que fará antes de causar dano, na câmera normal.

## Sistema de quebráveis

Comece com vasos, madeira e galhos reaproveitáveis. Varie a forma e o agrupamento conforme a sala. A resposta ao golpe precisa incluir quebra, som e fragmentos coerentes com o material. Um vaso de água pode espalhar água e cacos. Confira a circulação depois da quebra e a legibilidade da luta quando mais de um objeto quebra ao mesmo tempo.

Comece pela interação. Trate possíveis reagentes ou itens em objetos identificáveis junto com o backlog de coleta e Forja. Use a utilidade da descoberta para julgar a proposta, incluindo se o jogador se sente obrigado a quebrar tudo antes de prosseguir.

## Ordem da entrega

- **Lote jogável integrado.** Entregue Salão e Criptas A/B como o primeiro lote de layout do atlas. No mesmo pacote, inclua o Jardim B para testar a planta e valide a laje no Santuário Desmoronado. O Salão serve de referência para os quebráveis em uma luta sem perigo novo. Reuse os assets atuais e o EdgeKit.
- **Próximos lotes.** Leve o acabamento para as demais pranchas, distribua os quebráveis por todas as salas e use os resultados dos protótipos para decidir onde o perigo melhora a movimentação.
- **Mudanças na geometria.** Nas hipóteses em que piso, cobertura, saída ou nascimento precisarem mudar, compare a variante antes e depois e valide rota, esquiva, navegação e leitura do perigo.

## Evidências e aceite

Entregue o SHA da build, o backlog por sala e a lista de pranchas implementadas. Para o Salão e as Criptas, compare antes e depois na mesma seed, câmera e etapa do encontro. Inclua Criptas A e B lado a lado na câmera Perto.

Grave clipes em velocidade real mostrando o aviso, uma reação bem-sucedida e a consequência de ignorar o perigo. Nos quebráveis, mostre golpe, quebra e circulação depois dela. O aceite é reconhecer a sala pelo que se faz nela, entender por onde se mover durante a luta e distinguir o que o cenário oferece ou ameaça antes do impacto.

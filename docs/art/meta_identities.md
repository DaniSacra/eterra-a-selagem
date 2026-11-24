# Uma identidade por sistema de meta (art-director, 2026-11-23 noite)

Pedido do Daniel: "Quero os Dons, a Forja, a Loja, o Alquimista e a Videira totalmente diferentes entre si, e o Livro de
Ahk também; cada um vai ter uma identidade. Vamos começar pelos Dons." Ele não gosta de árvore de nós em página vazia e
gostou do códice de pergaminho para o Livro. Este documento **atualiza** `meta_screens_identity.md` (que continua valendo
para Encantos, Altar, Ofícios, Salmos, estandartes e Juramentos). Regra de cada linha: um objeto do mundo, uma forma, um
material, uma cor dominante, um gesto e um som que nenhum outro sistema usa. Paleta geral em `art_direction.md` 2; violeta
nunca (Morvath), esmeralda viva só na Emeth, vermelho vivo só no que fere. Nada de lore nova: os objetos são do Santuário
que já existe.

## 1. Dons: o medalhão do herói (novo; especificação em `dons_medallion_spec.md`)
- **Metáfora**: o herói visto por inteiro, e o que ele aprendeu gravado no aro em volta dele. É o retrato de quem ele é.
- **Forma**: o **círculo**. Medalhão grande no centro da tela, pintura do herói de pé dentro dele, nós no aro.
- **Material**: bronze dourado e esmalte (nós como pequenos medalhões de metal com fundo esmaltado na tinta do ramo).
- **Cor**: ouro quente da interface (`UiKit.GOLD` f5cc73 sobre `OLD_GOLD` 8e7444) e o brilho das tintas dos ramos; fundo
  pintado ao entardecer (âmbar, rosa ocre, azul ardósia).
- **Gesto**: tocar para equipar; **segurar** (1 s, a luz enche o anel do nó) para abrir um Dom com Memória.
- **Som**: sino de bronze pequeno ao equipar; nota longa que sobe enquanto se segura, e um "tom" de bronze ao abrir.
- **Nunca**: pergaminho, tinta sépia, velas, lacre de cera (são do Livro); folha, galho, tronco (Videira); linhas retas de
  grafo em fundo vazio (o que o Daniel recusou).
- **Muda**: o capítulo Dons sai do códice e vira tela própria. A estação do Santuário "Árvore de Dons" (`StoneTree`)
  deixa de ser árvore: recomendo um **medalhão de bronze em pé num pedestal de pedra**, com as placas do HV-E viradas em
  pequenos discos no aro (peça do `environment-artist`; tira o conflito "árvore" contra a Videira).

## 2. Livro de Ahk: o códice de pergaminho (fica, sem os Dons)
- **Metáfora**: o registro do escriba Ahk (cânone: anotava em papiros). Lê-se; não se compra nada nele.
- **Forma**: **retângulo duplo** (livro aberto, duas páginas), fitas de marcador saindo de cima.
- **Material**: pergaminho e couro; tinta ferro-gálica.
- **Cor**: pergaminho d8c8a8, sépia `Book.INK`, rubrica `RUBRIC` (0,47; 0,13; 0,09).
- **Gesto**: virar a página (PageUp/PageDown, LB/RB, rodinha).
- **Som**: papel virando, pena riscando.
- **Nunca**: metal brilhante, botões de compra, círculo de nós, plantas.
- **Muda**: perde o capítulo Dons (fitas, velas de Devoção e lacres vão embora com ele). Ficam Abertura, a página do herói
  (com a lista dos Dons equipados, só leitura) e o registro dos Ofícios. Velas e lacre viram decoração do próprio livro.

## 3. Forja: a arma na bancada (como em `meta_screens_identity.md` 2.1, com gesto próprio)
- **Forma**: **horizontal comprida** (a Emeth deitada no pano, 70% da largura). **Material**: ferro negro, pano, brasa.
- **Cor**: laranja de brasa (e07a2a) sobre fuligem (`UiKit.INK`). **Gesto**: **três toques** = três marteladas (um golpe
  por toque, a peça esquenta a cada um; segurar faz os três sozinho, por acessibilidade). **Som**: martelo na bigorna, chiado
  da têmpera. **Nunca**: pintura do herói, círculo, pergaminho, vidro.
- **Muda**: só o gesto (hoje é pergunta e Enter).

## 4. Loja da descida e Vendedor: a banca do mercador (uma família só)
- **Metáfora**: o comércio. A loja da descida é a banca no chão; o Vendedor do Santuário é o balcão com a **balança**.
- **Forma**: **baixa e larga** (pano estendido no chão, balcão); a balança de dois pratos é o centro da tela do Vendedor.
- **Material**: tecido listrado, couro costurado, madeira de balcão. **Cor**: listras terra e vinho apagado (6e2a2a), as
  do toldo do Vendedor que já existe. **Gesto**: **pôr no prato** (um toque escolhe, a balança pende, um segundo toque
  fecha a troca). **Som**: moedas, rangido da balança. **Nunca**: ouro brilhante como cor dominante (é dos Dons), pintura
  do herói, vidro, fogo.
- **Muda**: junta as duas linhas de antes (banca e balança) numa família: etiquetas de couro iguais nas duas.

## 5. Alquimista: a estante de frascos (só o quadro; função pendente)
- O Alquimista não tem NPC, receitas nem função decididos (Q-OF7 em `docs/design/oficios/22_decisoes_pendentes.md`).
  Reservo só a identidade para não colidir com as outras; nada de lore até o Daniel decidir.
- **Forma**: **vertical** (estante alta, frascos em prateleiras). **Material**: vidro e cobre. **Cor**: azul de vidro frio
  (5a8aa0) com cobre (b06a3a). **Gesto**: **verter** (escolher o frasco, inclinar até a marca). **Som**: vidro tilintando,
  borbulha. **Nunca**: caldeirão (Hades II), esmeralda, violeta, fogo de forja, pergaminho.
- **Muda**: hoje é só a bancada vazia do Santuário; a estante passa a ser o alvo do cenário dela.

## 6. Videira: a planta que cresce (como em `meta_screens_identity.md` 2.3)
- **Forma**: **crescimento de baixo para cima** (vaso, tronco, três ramos em leque na latada). **Material**: madeira viva,
  folha, barro (etiquetas). **Cor**: verde oliva e musgo (5f6b2e), flores âmbar pequenas como acento. **Gesto**: **regar**
  (um toque, a planta cresce sozinha em 0,6 s). **Som**: madeira rangendo, folhas. **Nunca**: metal, círculo de nós, linhas
  retas, ouro polido.
- **Muda**: nada além do gesto "regar" no lugar da pergunta.

## Tabela: nada se repete

| Sistema | Forma | Material | Cor dominante | Gesto | Som |
|---|---|---|---|---|---|
| Dons | círculo (medalhão) | bronze dourado e esmalte | ouro quente f5cc73 | tocar; segurar para abrir | sino de bronze |
| Livro de Ahk | retângulo duplo (livro aberto) | pergaminho e couro | pergaminho d8c8a8 e sépia | virar a página | papel, pena |
| Forja | horizontal comprida (arma deitada) | ferro, pano, brasa | laranja de brasa e07a2a | três marteladas | bigorna, chiado |
| Loja e Vendedor | baixa e larga (pano, balcão, balança) | tecido e couro | terra e vinho 6e2a2a | pôr no prato | moedas, balança |
| Alquimista | vertical (estante) | vidro e cobre | azul de vidro 5a8aa0 | verter | vidro, borbulha |
| Videira | de baixo para cima (planta) | madeira, folha, barro | verde oliva 5f6b2e | regar | madeira, folhas |

Ordem: Dons primeiro (esta noite, pedido ao ChatGPT pronto); depois a estação do Santuário em medalhão; as outras seguem a
ordem de `meta_screens_identity.md` 3.1.

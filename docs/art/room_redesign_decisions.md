# Redesenho das salas: decisões da noite de 2026-11-18

O Daniel pediu (2026-11-18, ao dormir) que o Game Director fizesse tudo pela própria decisão e que ele testasse de
manhã, mudando o que quiser. Estas são as decisões tomadas sem ele, todas **a revisar pelo Daniel**. Base: a diretriz
(`po_directive_room_redesign_2026-11-18.md`), o estudo do designer de salas (`docs/design/room_redesign_level_review.md`)
e a matriz do art-director (`room_redesign_matrix.md`).

## Perguntas do designer de salas (seção 3 do estudo)

| # | Pergunta | Decisão | Por quê |
|---|---|---|---|
| P-1 | Pedir os conceitos em 1920 x 1080 na câmera do jogo | Fica para o Daniel | Não dá para pedir à noite; seguimos com os recortes como clima |
| P-2 | Cada sala julgada na câmera do jogo, o chão como identidade | Sim | A diretriz proíbe mudar a câmera; 65 a 75% da tela é chão |
| P-3 | "Centro limpo" = nada novo no chão; as peças que barram ficam | Sim | Sarcófago do meio da Cripta, Ossuário, colunas, árvore são o jogo da sala; viram os marcos |
| P-4 | Círculo no chão só no Salão e na Câmara do Selo | Sim | Círculo no chão já é linguagem de combate (círculo de luz, erupções, invocações) e as Runas não têm nada redondo (D-29) |
| P-5 | Tabela de cores reservadas na diretriz | Sim | Verde Emeth, violeta dos inimigos e de Morvath, vermelho dos avisos e âmbar das Runas não viram cor de bioma perto do chão |
| P-6 | Repensar a vista das Fendas B | Sim | A B se lê pela ponte caída; o vórtice só como acento distante, longe do chão |
| P-7 | Jardim com folhagem morta e a árvore de pedra | Sim | A árvore de pedra fica (D-30); folhagem vermelha apagada só nas bordas |
| P-8 | Provação lilás, sem cara de arena | Sim | Coerente com o `TrialLook` e com a regra de não confundir com o vermelho dos avisos |
| P-9 | Altar sem figura alada nem auréola | Sim | Auréola raiada lê como sol e cruz (recusados) e o brilho era verde Emeth; o Altar continua com o leão em relevo e as velas |
| P-10 | Fonte e Loja como salas próprias ou o Salão vestido | O Salão vestido | Sala nova é mudança de jogo e de mapa; fica para o Daniel |
| P-11 | Bica de leão na fonte | Não por enquanto | O leão é o símbolo do herói (D-64 a D-71); na fonte a bica continua de pedra simples até o Daniel dizer |
| P-12 | O conceito de cada B mostra a regra da B | Sim | |
| P-13 | Ordem dos lotes | A do designer de salas, por exposição real | Ver abaixo |
| P-14 | Teste de aceite de jogo em todo lote | Sim | `fit_probe` sem piorar, `test_arenas.gd`, 8 sementes do robô sem `stuck` |

## Lotes (ordem desta noite)

1. **A**: Salão das Catacumbas (também Loja e Fonte) e Cripta A e B.
2. **B**: Santuário A e B e Fendas A e B.
3. **C**: Jardim A e B e Ponte A e B.
4. **D**: Runas A e B, Provação e Altar.
5. **E**: Câmara do Selo, só fundo e atmosfera (lógica das fases, avisos e colisão iguais).

Sem paradas para aprovação entre os lotes (pedido do Daniel desta noite). Sem perigo novo (os H-1 a H-7 do estudo
ficam como proposta para ele). Meshy: zero.

## Símbolos

- Estandartes com o leão: continuam (D-64 a D-71), em petróleo e ouro velho; estandartes vermelhos dos conceitos não.
- Nada de figura alada, auréola, sol, cruz (inclusive vela em cruz) nem estrela.
- "Símbolo central" da Provação: o selo rachado que já existe, sem círculo novo no chão.

## Look padrão

Se todas as salas ficarem prontas, o perfil estilizado vira o padrão do exe para o Daniel sentir a diferença descendo a
masmorra; F7 volta ao clássico a qualquer momento, e o clássico continua intacto.

Feito (2026-11-19): os cinco lotes entraram (A `d153434` e `081a82d`, B `b0ebc78`, C `ecc6c3d`, D `f3ef650`, E
`b2a7e20`) e o exe exportado abre no estilizado (`VisualProfile.default_look`); a Godot do editor, os testes e as
capturas seguem no clássico. Volta da descida (`--seed=5`, reação 0,25) e Câmara do Selo no estilizado sem erro de shader.

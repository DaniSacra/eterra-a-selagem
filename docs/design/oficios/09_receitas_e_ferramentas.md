# Ofícios e Descobertas: receitas e ferramentas

- 2026-11-20, `game-director`. Só planejamento. Legenda no `README.md`. Números de partida do `10_economia.md` 2.3,
  ajustados aqui; o `balance-designer` mede antes de virar dado. Dados como `Resource` (`FindDef`, `RecipeDef`,
  `OrderDef`, `ForgeRank` com `extra`) na parte `oficios` do `tools/make_data.gd` (`16_arquitetura.md` 1 e 2).

## 1. Regras do crafting enxuto [PROPOSTA NOVA]

1. **Ninguém fabrica do zero.** Ferramentas são achadas partidas e restauradas; Obras são compradas; Encantos são
   inscritos. Não há receita "material A + material B = material C".
2. **No máximo duas entradas contáveis por receita** (mais o achado único quando houver). Nunca três moedas na mesma
   compra.
3. **Instantâneo e um aperto**: sem fila, sem tempo de espera, sem quantidade a escolher (`10_ux.md` 10.5).
4. **Nada de consumível de combate e nada que vire Bênção.** A Bênção é da descida e dos anjos [APROVADO 2026-11-19].
5. **Força só pela Forja**: restauro, Obra e Inscrever dão opção, fonte ou informação. O Despertar é troca (uma ativa).
6. **Cada receita mostra o efeito, o custo, o que falta e onde achar**, lidos do dado (nunca número escrito no texto,
   `test_every_recipe_has_text_and_a_reachable_station`).
7. **Receitas `once`**: restauros e Obras uma vez; o grafo sem ciclo (`test_the_oficios_graph_has_no_cycle`).

## 2. Ferramentas

Todas em `heroes.warrior.tools` (uma lista só, `Forge.TOOLS` lido do catálogo). Nomes de trabalho [PENDENTE Q-OF5].

| Id (proposto) | Nome de trabalho | Como se acha | Restauro | O que abre | Roteiro | Estado |
|---|---|---|---|---|---|---|
| `tool_refine` | (sem nome no jogo hoje) | 1º guardião vencido | nenhum (vem pronta) | Refinar | | [EXISTENTE] |
| `tool_pick` | Picareta | a cabeça cai na sala marcada no mapa depois de ver um veio preso; piedade: o guardião a dá depois de 2 descidas sem ela | 20 Prata | veios de Pedra Funda nas Fendas e nas Runas | A | [PROPOSTA NOVA] |
| `tool_inscribe` | ferramenta do Inscritor (Buril) | 1ª Provação vencida (marco, Q-RJ9 a) | 40 Prata e 2 Esmeralda | trilha Inscrever da Forja | B | [APROVADO como ferramenta 3 da Fatia 3]; detalhe [PROPOSTA NOVA] |
| `tool_awaken` | ferramenta do Despertar (Cadinho) | fase 3 de Morvath alcançada (marco) | 30 Prata e 1 Esmeralda | trilha Despertar da Forja | B | [APROVADO como ferramenta 2 da Fatia 3]; detalhe [PROPOSTA NOVA] |

Migração para o save 8 (`16_arquitetura.md` 4.2): marco já provado no save dá o **achado** (não a ferramenta pronta):
quem já venceu uma Provação ou chegou à fase 3 encontra a ferramenta partida no Forjador e decide se restaura. Quem
venceu guardião e não tem `tool_refine` ganha a `tool_refine` (fecha a lacuna do `01_diagnostico.md` 2.4).

**Por que achada e não fabricada** (a "Primeira Picareta" do pedido fala em madeira e ferro): madeira não existe no
bioma e seria a 4ª moeda; ferro é Prata com outro nome; fabricar de componentes cria o risco de o componente vir de onde
a ferramenta abre (ciclo). A descoberta ("achei a cabeça") é o momento bom; a Prata é o gasto.

## 3. Item de ofício contável

| Id | Nome de trabalho | Fonte | Teto no save | Uso | Excedente | Estado |
|---|---|---|---|---|---|---|
| `stone_deep` | Pedra Funda | veio nas Fendas e nas Runas, só depois da camada do guardião e só com a Picareta; 1 por veio; no máximo 2 veios por descida | 10 | Encomenda do Vendedor (C2) e Obras | acima do teto, 2 de Prata na hora ("+2 Prata") | [PROPOSTA NOVA] [PENDENTE Q-OF4] |

Rejeitados no capítulo 1 (do `05_coleta_e_regioes.md` 2 e `10_economia.md` 2.2): Ferro de Corrente (redundante com a
Prata), Cera Velha e Fungo Pálido (pedem o Alquimista), Pó de Runa (pede as Runas medidas como perigo e um uso; candidato
ao Roteiro C), madeira (não há no bioma).

## 4. Receitas

| Id | Estação | Entradas | Saída | Precisa | Tipo | Roteiro |
|---|---|---|---|---|---|---|
| `restore_pick` | Forjador (Oficina) | Cabeça da Picareta, 20 Prata | `tool_pick` | | horizontal (fonte) | A |
| `order_counter` | Vendedor (encomenda C2) | 2 Pedra Funda, 30 Prata | Obras abertas e Obra 1 "Prévia dos anjos" | `tool_pick` (implícito, pela Pedra) | horizontal (informação) | A |
| `work_altar` | Vendedor (Obra 2) | 3 Pedra Funda, 40 Prata | o Altar aparece com 35% por camada (era 20%) | Obra 1 | horizontal (porta) | B |
| `work_psalm` | Vendedor (Obra 3) | 3 Pedra Funda, 50 Prata | porta de Salmo desde a sala 3 (era 4) | Obra 1 | horizontal (porta) | B |
| `restore_inscribe` | Forjador (Oficina) | achado, 40 Prata, 2 Esmeralda | `tool_inscribe` | | horizontal | B |
| `inscribe_4..6` | Forjador (Inscrever) | 20 Prata cada | Encanto 4, 5, 6 no sorteio | `tool_inscribe` | horizontal (variedade) | B |
| `restore_awaken` | Forjador (Oficina) | achado, 30 Prata, 1 Esmeralda | `tool_awaken` | | | B |
| `awaken_1..3` | Forjador (Despertar) | 3 Esmeralda cada | uma propriedade da lâmina, uma ativa (troca grátis) | `tool_awaken` | lateral (troca) | B |
| `decipher_1..3` | Livro (capítulo Ofícios) | 4 a 8 Memória cada, desde a 8ª descida | pista de Salmo, receita de Obra, linha do Compêndio | o manuscrito | horizontal (informação) | B, [PENDENTE Q-OF8] |

A "receita de duas entradas" do `16_arquitetura.md` 2.1 é o `ForgeRank` com `extra` (restauros) e o `RecipeDef`/`OrderDef`
para as Obras; o `Ledger` paga tudo ou nada.

## 5. A conta (gasto novo contra renda medida)

| Material | Gasto novo no Roteiro A | Gasto novo no A + B | Renda medida (`10_economia.md` 1.2) | Leitura |
|---|---|---|---|---|
| Prata | 50 (Picareta 20, balcão 30) | 270 (mais Obras 90, Inscritor 40, Inscrever 60, Despertar 30) | 17 por descida (r45), 30 (r25), gente 1,5 a 2 vezes | a Prata, que acabava na 12ª a 14ª descida r45, vai à 20ª a 24ª: dentro da meta E4 (18ª a 22ª) com folga a medir |
| Memória | 0 | 0 a 18 (decifrar, se aprovado, desde a 8ª descida) | 2 a 5 | não compete com os Dons no começo |
| Esmeralda | 0 | 12 (Inscritor 2, Despertar 1 + 9) | 0,8 por descida (r45) | gasta a Esmeralda à medida que chega, até a 15ª descida |
| Pedra Funda | 2 | 8 | perto de 1 por descida depois da Picareta (meta) | teto 10, sobra vira Prata |

O Roteiro A sozinho deixa a Esmeralda sem gasto (como hoje): é aceito porque A é o protótipo; o B resolve.

## 6. Equivalência com o Hades II (referência, não cópia)

- [HIPÓTESE, de memória do jogo; conferir nos dados do Daniel antes de usar números] No Hades II as ferramentas de
  coleta (picareta, pá, vara, tabuleta) são feitas no Caldeirão com reagentes e abrem pontos de coleta que já aparecem
  nas salas; a coleta é feita na sala, várias pancadas. Aqui o molde é o mesmo **em pequeno**: um tipo de ponto, um
  aperto, só depois da luta, e a ferramenta restaurada em vez de fabricada.
- As Obras são os Encantamentos do Caldeirão que mudam a Encruzilhada e a descida (já previstos na Fatia 3).

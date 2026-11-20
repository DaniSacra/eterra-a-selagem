# Ofícios e Descobertas: integração com os sistemas que existem

- 2026-11-20, `game-director`. Só planejamento. Legenda no `README.md`. Cada linha diz o que o sistema é hoje, o que
  os Ofícios fazem com ele, o que **não** fazem e o risco. Código e campos em `16_arquitetura.md`; o que existe em
  `01_diagnostico.md` 1.

## 1. Regra geral

[PROPOSTA NOVA] **O que se fabrica, restaura ou entrega no hub persiste; o que a descida usa é cópia lida no começo
dela** (como o `Game._equip_forge`). A descida nunca grava o save no meio; os achados vão ao save no `Game.log_run`,
junto com os materiais, pela mesma carteira (`MaterialPurse` estendida, `Game.banks_materials`).

## 2. Sistema por sistema

| Sistema | Hoje | Com os Ofícios | O que não muda (de propósito) | Risco | Roteiro |
|---|---|---|---|---|---|
| **Maestria** | [EXISTENTE] XP no fim de toda descida, primeiras vezes em `firsts` | primeiras vezes novas dão XP pequeno (`MasteryCurve`: veio preso visto 5, ferramenta restaurada 10, encomenda entregue 10) [PROPOSTA NOVA] | a curva (40 + 10 por nível) e o que cada nível revela | inflar a Maestria; manter abaixo de 1 nível no capítulo inteiro (cerca de 50 XP) | A |
| **Dons** | [EXISTENTE] Maestria revela, Memória abre, Devoção equipa (D-57) | nada abre Dom. Manuscrito pode dar **pista** de onde um Dom brilha (linha no painel), nunca portão | os dois portões, o Quarto Corte aberto | um terceiro portão atrasaria o começo: proibido | B (só pista) |
| **Devoção** | [EXISTENTE] 5 + nível, limita o equipado | nada | o teto | nenhum | |
| **Forja** | [EXISTENTE] Temperar I a III (Prata), Refinar com `tool_refine` | aba Oficina (restaurar ferramentas, `ForgeRank` com `extra`); trilhas Inscrever e Despertar abertas pelas ferramentas | Temperar e Refinar com os mesmos custos e números | a Prata disputada (desejado: escolha) | A (Oficina), B (trilhas) |
| **Encantos** | [PARCIAL] 3, todos aprendidos; `Enchants.learned` já lê `forge.inscribed` | Inscrever escreve `forge.inscribed`; Encantos 4 a 6 entram no sorteio só depois de inscritos | regra das portas de Encanto (2 por caminho, o 2º desde a sala 5) | Encanto novo pede combat-feel; o pool maior dilui a escolha (medir cada Encanto entre 20 e 45%) | B |
| **Bênçãos** | [EXISTENTE] dos anjos, por porta e loja | **nada é Bênção fabricada** [APROVADO]. A Obra 1 mostra o anjo das salas de Bênção da camada seguinte (informação) | raridade, troca, Elo, Salmo, baralho | prévia demais tira a surpresa: só uma camada além das portas | A |
| **Anjos** | [EXISTENTE] 4 anjos, selos, encontro | Compêndio conta escolhas por anjo (dado da aba Anjos da Fatia 3) | nomes e aparência [APROVADO Q-RJ4] | nenhum | B |
| **Salmos** | [EXISTENTE] 4, porta de Salmo desde a sala 4 | Obra 3 leva a porta de Salmo à sala 3; manuscrito pode dar a **pista** de um Salmo não visto (o `hint_key` do Compêndio ganha um texto melhor) | regras de quando um Salmo pode vir (`Psalms.met`) | nenhum de força (Salmo não pesa na vitória, `balance.md` 3.6) | B |
| **Juramentos** | [EXISTENTE] Peso, XP; Esmeralda por recorde de Peso só documentada | a Esmeralda por recorde alimenta o Despertar; Obras podem ser desligadas para quem quer a descida antiga [HIPÓTESE] | os nove votos | nenhum | B |
| **Ouro e loja da descida** | [EXISTENTE] some ao voltar | nada: ouro nunca paga ofício; material nunca compra na loja da descida (`auditoria.md` 3.2) | tudo | | |
| **Prata, Memória, Esmeralda** | [EXISTENTE] fontes por evento, Esmeralda sem gasto | gastos novos (`09_receitas_e_ferramentas.md` 5); portas de Prata desde a profundidade 4 e de Memória depois do guardião (anti-farming, [PENDENTE Q-OF3]) | as fontes e os tetos | mexer na porta de Memória atrasa a Memória do começo (medir contra D-57) | A (OF-05) |
| **Mapa** | [EXISTENTE] grafo com sal, portas que mostram a recompensa e o anjo | `Room.find` (achado marcado) e `Room.vein` (veio) com sal próprio depois do grafo; losango pequeno no `MapGraph` só do que já foi visto; nada na placa da porta | o grafo, o baralho, as arenas e o `fight_seed` da mesma semente | carta nova no baralho mudaria o mapa: proibido | A |
| **Salas e arenas** | [EXISTENTE] 6 arenas de luta, perigos | peça do veio nas Fendas e nas Runas (`RoomLayout.gather_spots`), sem colisão nova, fora de laje que fere, de boca de porta e dos 6 m da entrada | colisão, chão, perigos | o veio ler como perigo ou como recompensa errada: cor proibida âmbar, vermelho, violeta, esmeralda | A |
| **Hub** | [EXISTENTE] 5 estações; Vendedor fechado | o Vendedor abre pela encomenda; placas com "Tem um pedido"; nada de estação nova | planta, câmera, teste de 4 s | | A |
| **Livro de Ahk** | [EXISTENTE] [CÂNONE: Ahk] capítulos Abertura, O Guerreiro, Dons; três vagas seladas | 4º capítulo "Ofícios" (Recursos, Ferramentas, Pedidos; Descobertas no B) com "Onde achar" e ligações por link (`10_ux.md` 11) | Ahk, as vagas seladas, a Abertura | texto que fale por Ahk é lore: as pistas ficam em voz neutra até o Daniel [PENDENTE Q-OF9] | A (Recursos, Ferramentas, Pedidos) |
| **Compêndio** | [EXISTENTE] 8 abas, 6 seções no save | seção `codex.oficios` (achado, feito, entregue) contada no `progress`; nenhuma aba nova | as 8 abas e a largura a 720 | | A |
| **Save** | [EXISTENTE] versão 7, três espaços | versão 8: bloco `oficios` (itens, encomendas, receitas, piedade, `retired`), fixtures v6, v7, v8 | tudo de antes, idêntico ao abrir | duplicar ou perder: 17 regras e testes em `16_arquitetura.md` 5 | A |
| **Registro e RESULT** | [EXISTENTE] `RunLog` 5 | versão 6: `finds`, `gather` (com `gather_s`), `pity`; uma linha `hub` por volta (segundos, estações, compras) | o resto | sem a linha `hub` a meta E6 é chute | A |
| **Robô** | [EXISTENTE] escolhe portas, não guarda | usa o veio como usa a recompensa (desvio até 6 m), leva o achado, peso pequeno para a porta da sala marcada | nunca guarda (`--materials-keep` para medir) | o robô colher mais rápido que gente: medir também com gente | A |

## 3. O que fica fora de qualquer integração

- Combate: nenhum golpe, tempo, alcance ou aviso muda pelos Ofícios no Roteiro A. O Despertar (B) é o único que toca a
  sensação, e passa pelo combat-feel-director.
- HUD da luta: zero elementos novos.
- Cânone: nenhum coletável com o leão, a espada erguida, o olho partido, a Lâmpada, o Sopro (água viva) ou o sangue de
  Hanokh [CÂNONE]; nenhum NPC canônico; Ahk não fala sem o Daniel.

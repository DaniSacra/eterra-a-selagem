# RJ-0: auditoria do pacote de rejogabilidade

- **Data**: 2026-11-19. **Commit lido**: `c6d6aab` (branch `arpg-3d`; a árvore local tinha mudanças de cenário e do
  hub não commitadas, nenhuma nos sistemas auditados). **Autor**: `game-director`. **Só documento**: nenhuma linha de
  código, dado ou save foi mudada.
- **Lido**: o pacote inteiro em `docs/design/rejogabilidade/` (a diretriz `PROMPT_CLAUDE_CODE.md` é o roteiro desta
  auditoria), `docs/backlog.md` seção 10 (leitura prévia, respostas do Daniel de 2026-11-19 e a "Intenção do PO"),
  `warrior_spec.md`, `po_directive_guardian.md`, `hades2_sistemas.md` (seções 6, 7, 9 e 10), `e3_blessings.md`,
  `balance.md`, `hub_spec.md`, `comparativo.md`, o cânone `../dungeon-rpg/docs/mundo/canone.md`, e o código e os
  dados onde a matriz cita.
- **Decisões do Daniel que mandam aqui** (2026-11-19): (1) mecânicas primeiro, se alimentando das descidas, equilíbrio
  depois; (2) as Bênçãos são oferecidas por **anjos** inventados pelo projeto com os deuses do Hades II como benchmark,
  servos de Yah, nunca deuses, a luz vem de Elun, nada de Deus como NPC (isto **substitui a D-51**, que estava como "os
  três companheiros e o voto do herói"); (3) **a Forja deixa o herói mais forte** (substitui a D-H2, "aspectos sem
  somar dano"); (4) os Dons são o nosso Arcana e pedem um recurso além da Maestria e da Devoção (as Cinzas do Hades);
  (5) Emeth arma única, só o Guerreiro, sem bloqueio.

Legenda: **JÁ EXISTE** (está no jogo, com arquivo); **PARCIAL** (a base existe, falta a parte do pacote);
**PROPOSTA** (nada no jogo; cabe sem atrito); **CONFLITO** (choca com decisão, regra ou sistema existente: diz qual e
como resolver); **DEPENDE DO CÂNONE** (precisa do Daniel antes de virar texto ou arte).

---

## 1. O que o cânone diz e muda o pacote

| Ponto | Cânone (`canone.md`) | Efeito no pacote |
|---|---|---|
| Anjos | **Malahym**: "anjos imortais criados por Yah, que poderiam viver com o Criador e vislumbrar suas magníficas obras" (linha 303; glossário 476 e 508). A fonte B tem "um anjo de luz enfrentando o dragão" (306) | a **categoria** existe: os anjos das Bênçãos podem ser Malahym sem inventar o que é um anjo. **Cada anjo**, nome e aparência, é invenção nova e precisa do Daniel (ele já autorizou propor) |
| O Dragão | "a lenda verdadeira é a do Malahym que se rebelou contra Yah" (351) | cuidado de leitura: um anjo nosso nunca pode lembrar o Dragão (nada de asas negras, vermelho, escama). Os anjos são claramente servos |
| A luz | "A luz que guiará vocês não vem de dentro, mas de cima" (fonte B, 305); Elun é "o Filho da Luz" (307) | a Bênção é a luz de Elun **entregue** por um mensageiro (*mal'akh* = mensageiro); o anjo não é a fonte. Isso cabe no texto de cada encontro |
| O Sopro | o Espírito aparece como o Sopro, e "as fontes de luz são o sinal dele: água viva" (30) | nenhum anjo pode ser o Sopro nem ter a água como símbolo; a Fonte das salas já é o lugar disso |
| Fé no jogo | "Ninguém cita versículo, Deus não aparece como personagem" (25) | anjos falam pouco, sem sermão; ecos bíblicos só no desenho (como os Salmos, D-59) |
| Símbolos | três que nunca se confundem: leão (Hanokh e Elun), espada erguida (guardiões), olho cortado (Irmandade) (57) | nenhum anjo usa leão, espada erguida nem olho. A regra do jogo (nunca sol nem cruz, D-66) continua |
| Ahk | escriba de Elun; os papiros dele **são** o Livro Sagrado de Yah (339 a 342); grafia Ahk, não Akh (157) | o pacote escreve "Akh": corrigir. "Fragmentos de Memória" ligados a páginas de Ahk espalhadas nas catacumbas seria lore nova (onde estão os papiros) |
| A Lâmpada | Velkor levou de Valmor "a Lâmpada do paladino de Valmor, tirada do nicho sob o leão" (111 a 113) | objeto do cânone: **não** usar lâmpada ou candeia como símbolo de anjo nem como material, para não confundir |
| Forjador, Vendedor, ferramentas, materiais | nada no cânone | tudo é invenção do jogo: nomes provisórios, o Daniel decide (como D-H4 e Q-H3 do hub) |

---

## 2. Matriz por ideia do pacote

### 2.1 Progressão permanente

| Ideia | Situação | Onde está, ou o que falta | Decisões |
|---|---|---|---|
| Maestria (XP permanente, guardado na derrota) | **JÁ EXISTE** | `MasteryCurve` (`scripts/core/mastery.gd`), `data/heroes/warrior_mastery.tres`, `Game.award_mastery`; 20 níveis, `40 + 10 (n - 1)` | D-57 |
| Dons em árvore com pré-requisitos | **JÁ EXISTE** | 19 `TalentDef` em `data/talents/warrior/`, regras em `Talents` (`scripts/core/talents.gd`), tela `HeroScreen` + `TalentTree` | D-58, `warrior_spec.md` 4 |
| Devoção (capacidade para equipar) | **JÁ EXISTE** | `MasteryCurve.devotion` = 5 + nível; `Talents.check` | é o Fôlego (Grasp) do Hades II |
| "Livro dos Dons" (manuscrito com nós) | **JÁ EXISTE** | o Livro de Ahk: `BookSpread`, `HeroScreen` capítulo Dons (etapa 2 do pacote de arte) | grafia Ahk |
| Dons pedindo um recurso além da Maestria (Cinzas) | **PROPOSTA** | hoje um Dom destrava sozinho no nível (`TalentDef.unlock_level`) e custa só Devoção. Falta: o recurso, o passo "abrir" e a migração dos já destravados | pedido do Daniel (4); cuidado com D-57 (desbloqueios frequentes no começo) |
| Fragmentos de Memória | **PROPOSTA**, nome **DEPENDE DO CÂNONE** se ligado a Ahk | candidato natural às Cinzas (ver `sistemas.md` 1). Não duplica a Maestria se vier de **escolhas** (porta, guardião, Provação), não de jogar | RJ-11 deixa de ser opcional (backlog 10) |
| Forja da Emeth: Temperar | **PROPOSTA** | nenhum código; o efeito cabe nas estatísticas que já existem (`damage_pct` com tag em `Combat`, somadas por `BoonState.stat` como os Dons em `equip_talents`) | decisão (3) do Daniel substitui a D-H2 |
| Forja: Refinar | **PROPOSTA** | escolha exclusiva por ação (molde dos aspectos das Armas Noturnas): dado, como os Dons | |
| Forja: Despertar | **PROPOSTA** | precisa de efeito novo por Despertar (código pequeno, como um Dom ápice) | |
| Forja: Inscrever | **PROPOSTA**, só com Encantos | vira "aprender um Encanto" (põe o Encanto no sorteio das descidas) | o pacote já diz "só se houver integração clara" |
| Prata Antiga | **PROPOSTA** | nada | |
| Brasas da Forja | **CONFLITO** (nome) | "Brasas", "Rastro em Brasa", "Golpe em Brasa", "Peso em Brasa", "Círculo em Brasa", "Passo em Brasa" já são Bênçãos da família Chama (`data/text_pt.tres`), e o Ímpeto desenha "brasas" na lâmina. **Resolver**: cortar a Brasa como moeda e fundir o papel dela na Prata (menos moedas, o pacote proíbe dezenas) | |
| Fragmentos Esmeralda | **PROPOSTA** | cor: a Emeth é esmeralda cristalina; o "esmeralda corrompido" é de Morvath (`BossShield.COLOR`, matiz 165). O material tem de ler como o da Emeth | |
| Ferramentas perdidas do Forjador | **PROPOSTA**, nomes **DEPENDE DO CÂNONE** | nada; o "?" do mapa (`RunMap` `hidden`) e os marcos de primeira vez (`heroes.warrior.firsts`) dão onde ancorar | pacote: "nomes NÃO canônicos" |
| Forjador e Vendedor no hub | **PARCIAL** | estações, placas e páginas "a definir" existem (`HubPlan.SMITH`, `VENDOR`; `HubPanel` com `SealedMark`, HUB-B3); NPCs são do HUB-D | D-H1, D-H2 (agora substituída), Q-H3 |
| Materiais persistentes no save | **PROPOSTA** | save versão 5 sem recurso persistente; `SaveData.merged` **descarta** chave fora do `defaults()` (risco já anotado no `hub_spec.md`) | |
| Ouro só da partida | **JÁ EXISTE** | `GoldPurse`, `Rooms.gold`; some ao voltar | Hades II |
| Juramentos e Peso (risco e recompensa) | **JÁ EXISTE** | `Juramentos`, `JuramentoScreen`; Peso dá XP na vitória (`weight_xp`) | D-63 |

### 2.2 Dentro da descida

| Ideia | Situação | Onde está, ou o que falta | Decisões |
|---|---|---|---|
| Bênçãos com famílias, raridades, troca, Elos | **JÁ EXISTE** | `Boon` (`Family` CHAMA, GEADA, LUZ, VIGILIA, DUO), `BoonState`, 32 Bênçãos em `data/boons/`; cada família cobre as quatro ações | D-50, D-52, D-53, E3-01, E3-02 |
| Quatro identidades mecânicas por família | **PARCIAL** | os dados já são assim: Chama queima e cai do céu (pressão), Geada congela (controle), Luz dano direto e lâminas que voam (alcance e impacto), Vigília escudo, vida, velocidade e alcance (ritmo e sustento). Falta escrever a regra de cada uma e usá-la para as Bênçãos novas | |
| Quem oferece as Bênçãos | **CONFLITO resolvido pelo Daniel** | hoje o texto liga cada família a um paladino (`family_chama` "Chama[, Bênção de {P2}]", `family_vigilia` "Vigília[, voto de {P1}]"). Com os anjos, a família passa a ser do anjo e os marcadores `{P1}` a `{P4}` saem dessas chaves | D-51 substituída |
| Anjos (nomes, aparência, temperamento) | **DEPENDE DO CÂNONE** | categoria canônica (Malahym); indivíduos são proposta (`sistemas.md` 4) | autorizado propor |
| Encontro em duas etapas (2 anjos, depois até 3 Bênçãos) | **PROPOSTA** | hoje a sala dá 3 cartas direto (`Game.offer_cards`, `BoonChoice`). Cabe como filtro de família no sorteio, mais uma tela antes | Hades II tem no baralho "uma sala de duas divindades" (`hades2_sistemas.md`, achado do baralho) |
| Ver o anjo da sala na porta | **PROPOSTA** | as portas já mostram a recompensa por marca (`DoorGlyph.of_reward`) e o mapa mostra tudo (Q-25 a); falta a família na placa | é a regra normal do Hades II |
| Salmos como transformação | **JÁ EXISTE** | `PsalmDef`, `Psalms`, `PsalmPlay`, 4 Salmos; carta em 10% (5% no guardião) | D-59, D-60 |
| Salmo como porta | **PARCIAL** | o Salmo só vem como carta dentro da Bênção; porta própria é regra nova no baralho | |
| Encantos temporários (Martelos de Dédalo) | **PARCIAL** | estudados como **Lapidação da Emeth** (`hades2_sistemas.md` 6: `WeaponUpgrade` com `mods`, `node_overrides`, `excludes`, no máximo 2 por partida, loja 200), nunca implementados. **Um sistema só**: Encanto = Lapidação | |
| Os 6 Encantos do pacote | **CONFLITO** em 3, ajustáveis | ver 3 abaixo | |
| Porta de material | **PROPOSTA** | `RunMap.Reward` (BOON, POM, HEART, MAGICK, GOLD, HEAL, POM_SLICE) e o baralho `StageDef.reward_deck` aceitam carta nova sem refazer o grafo | |
| Porta de Encanto | **PROPOSTA** | a carta `R.HAMMER` já prevista no estudo | |
| Porta de vida, Magia, loja, Provação, Altar | **JÁ EXISTE** | HEART, HEAL, MAGICK, Fonte, loja na 10, `Trials`, `Altar` | |
| Elite como escolha de risco | **PARCIAL** | a placa diz "Difícil" (`Rooms.door_text`, `DoorGlyph`), mas o risco não paga nada a mais | |
| Bifurcações que trocam uma coisa por outra | **PARCIAL** | o grafo do DV-1 (`RunMap`, 2 a 4 salas por camada, ligações sem cruzar, recompensas sem repetir na camada) já faz escolha; nunca foi medido quanto das escolhas é de fato contrastante | |
| Sala "Magia cheia" | **NÃO FAZER** | a Magia já enche em toda sala | pacote e backlog concordam |
| Discernimento (reroll, prévia, substituição) | **PROPOSTA** | nada; o Hades I tem a Persuasão do Destino no espelho | |
| Ultimate e Fúria sem barra | **JÁ EXISTE** | `UltDef`, `UltCharge`; Fúria em cargas (`GiftState`) | D-54, D-70 |

### 2.3 Regras inegociáveis do pacote contra o jogo

| Regra | Situação |
|---|---|
| Só o Guerreiro; Emeth arma única | respeitada; a Forja muda a Emeth, nunca troca a arma |
| Sem bloqueio, aparo ou escudo | **atenção**: a Bênção "Escudo da Vigília" (`09_escudo.tres`) absorve um golpe sozinha e volta em segundos. É uma proteção passiva, não uma ação de bloqueio; não quebra a regra, mas nenhum Encanto, Forja ou anjo deve crescer nessa direção |
| Golpes plantados, esquiva cancela | todo Encanto tem de passar pela `combat-feel-director` (o pacote pede "mudar a sensação"; não pode mudar a regra do golpe parado, `warrior_spec.md` 2.2) |
| Não criar baralho de tarô | os Dons já são o Arcana |
| Seeds determinísticas | o mapa sai de `hash([semente, MAP_SALT])`; o encontro dos anjos precisa de sal próprio para não mexer no mapa |

---

## 3. Sobreposições que precisam de decisão

### 3.1 Encantos do pacote contra o que já existe

| Encanto do pacote | Sobrepõe | Proposta |
|---|---|---|
| Lâmina Tríplice (o giro solta 3 ondas em leque) | Dom **Corte Crescente** (o giro solta uma onda) e Salmo do **Pastor** (ondas a mais em leque) | manter, mas como **substituição** do Corte Crescente quando os dois estiverem: `excludes` com o Dom, ou o Encanto vira "o Corte Crescente solta 3" e só aparece com ele equipado (sinergia em vez de cópia) |
| Corte Sísmico (o pesado gera pulso) | o kit não tem "pesado": o especial é a onda (tag `heavy`) | refazer como "o giro do 3º golpe bate no chão: pulso de 3 m" |
| Eco da Verdade (golpe final repetido) | nenhum. Bom achado: "Emeth" é "verdade" em hebraico | manter; trava contra eco que ecoa (o pacote já pede) |
| Espiral de Emeth (a onda orbita o herói) | Bênção **Redemoinho de Fogo** (chamas giram em volta) | manter só se a órbita for curta e fina; risco de leitura sobre o herói (regra da arte: nada sobre o herói) |
| Fio Penetrante (a onda atravessa) | Dom ápice **Onda Atravessante** (já faz isso) | **cortar** ou trocar por outro efeito do especial |
| Retorno do Corte (depois do Corte Veloz o golpe amplia o arco) | Dons **Passo Encadeado** e **Fio do Passo**, Bênçãos de esquiva | manter com `excludes` claros; é o encanto mais "Guerreiro" (esquivar para dentro) |

### 3.2 Materiais contra custos que já existem

- **Ouro**: segue só da descida (loja, Altar). Nenhum material novo compra nada na loja da descida, senão vira ouro com
  outro nome.
- **Vida** paga a Provação e o Altar; nenhum material deve pagar essas salas (a troca de vida é a graça delas).
- **Devoção** limita quantos Dons se usa; o recurso novo **abre** Dons, não aumenta a Devoção (a Maestria já faz o
  papel da Psique).
- **XP da Maestria** vem de jogar; o recurso dos Dons tem de vir de **escolher** (porta, guardião, Provação), senão é a
  Maestria em dobro.

### 3.3 Equilíbrio

- O `balance.md` (item 7.4) propôs que todo ganho permanente do hub valha no máximo 5 a 10 pontos de vitória e só
  depois da 5ª descida. A decisão (3) do Daniel diz que a Forja **soma força** e entra na curva; a decisão (1) diz que o
  equilíbrio vem depois. Leitura: na Fatia 1 a primeira melhoria chega cedo (avaliar o laço) e com número pequeno; o
  `balance-designer` remede tudo junto depois e pode empurrar custos. Não é conflito, é ordem.
- A D-57 quer desbloqueios frequentes no começo: o recurso dos Dons não pode travar os primeiros Dons (ver
  `sistemas.md` 1.4).

---

## 4. O que NÃO fazer

1. Outros heróis, outra arma equipável, inventário de armas.
2. Escudo, aparo, bloqueio; nada que peça esperar o golpe do inimigo; Encanto que faça o golpe andar (golpe plantado).
3. Barra nova de Fúria ou qualquer barra nova no HUD para materiais (contador só no hub e na tela de fim).
4. Baralho de tarô; "vitrais" como sistema à parte dos Dons.
5. Mais de três materiais persistentes; a Brasa da Forja como moeda (nome já usado); materiais que compram na loja da
   descida.
6. Sala "Magia cheia"; refazer o grafo do `RunMap` (só cartas novas no baralho e regras de sorteio).
7. Anjo como deus, Deus como NPC, anjo que seja a fonte da luz, anjo com leão, espada erguida, olho, sol, cruz,
   lâmpada, água como símbolo; nomes de poder com Elun (D-68); qualquer anjo antes do Daniel aprovar nome e forma.
8. Fragmento de Memória ou ferramenta com história nova (de quem é a memória, por que o martelo se perdeu) sem o
   Daniel.
9. Encanto que repete um Dom ou um Salmo (Fio Penetrante como está).
10. Implementar tudo de uma vez: a Fatia 1 (`sistemas.md` 3) primeiro, teste do Daniel, depois o resto.
11. Meshy ou arte paga; retrato pintado de anjo feito por IA sem o Daniel e sem `docs/steam-ia.md`.

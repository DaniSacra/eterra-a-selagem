# RJ-1: os sistemas de rejogabilidade conversando (proposta para o Daniel)

- **Data**: 2026-11-19. **Commit lido**: `c6d6aab`. **Autor**: `game-director`. **Só documento.** Matriz do que já
  existe e conflitos em `auditoria.md` (RJ-0), que vale junto com este.
- **Pedido do Daniel**: entender como as mecânicas novas se conversam, como os materiais saem das descidas para elas
  ficarem ativas, e um começo mais simples para jogar e avaliar cedo.
- **Todo nome é provisório.** Todo número é ponto de partida para o `balance-designer` medir; "estimativa" marca o que
  não foi medido. O que é opinião minha está dito.

---

## 1. O laço da descida ao hub e de volta

### 1.1 A ideia em uma frase

**Cada descida traz duas ou três coisas que só servem no hub, e cada coisa do hub muda o que a próxima descida
oferece.** A porta deixa de ser só "que Bênção eu quero" e vira "o que eu levo para casa contra o que me ajuda agora".

### 1.2 Poucas moedas: três materiais e um achado

O pacote tinha cinco (Prata, Brasa, Esmeralda, Memória e as ferramentas). Proponho **três moedas**, cada uma com **um
gasto só**, mais as ferramentas como achados únicos (não são moeda). A Brasa sai: o nome já é de seis Bênçãos da Chama
e o papel dela cabe na Prata (`auditoria.md` 2.1).

| Material (provisório) | Equivale no Hades | De onde vem na descida | Quanto por descida (estimativa) | Gasto exclusivo | Teto | Persiste |
|---|---|---|---|---|---|---|
| **Ouro** (já existe) | Ouro de Caronte | inimigos (`GoldPurse`), porta de ouro 100 | 60 a 250 | loja e Altar da descida | nenhum | **não**, como hoje |
| **Prata Antiga** | os minérios das Armas Noturnas (prata, bronze...) | elite abatida 1; **porta de Prata** 10; guardião vencido 6; Morvath 2 por fase alcançada (até 8) e 10 na vitória | derrota antes de Morvath 6 a 18; derrota em Morvath 18 a 28; vitória 30 a 40 | **Forja** (Temperar, Refinar, aprender Encantos) | 999 no save | sim, também na derrota |
| **Fragmento de Memória** | as Cinzas do Arcana | **porta de Memória** 3; guardião vencido 2; Provação vencida 2; vitória sobre Morvath 3 | derrota 0 a 5 (média 2 a 3); vitória 5 a 10 | **Dons** (abrir e, depois, Discernimento no Livro) | 999 | sim |
| **Esmeralda** (Fatia 2) | Pesadelo (aspectos) e Sangue de Titã (Hades I) | Morvath na fase 3 alcançada 1, vitória 1; recorde de Peso nos Juramentos 1 (Fatia 3) | derrota 0 a 1; vitória 1 a 2 | **Despertar** da Emeth | 99 | sim |
| **Ferramentas do Forjador** (Fatias 2 e 3) | as ferramentas de coleta do Hades II e as chaves do Hades I | marcos de primeira vez (1º guardião vencido, 1ª fase 3 de Morvath, 1ª Provação vencida) | uma por marco, três no total | abrem uma função da Forja | 3 | sim |

Regras comuns:
- **Morrer guarda tudo** o que foi pego (como no Hades). Sair no meio também, como a Maestria hoje (`log_run("quit")`).
- O material aparece como a palavra "+10 Prata" onde cai (o molde do "+n ouro") e **não tem contador na HUD** da
  luta: o total aparece na tela de fim ("Trazidos: 24 Prata, 3 Memória") e no hub.
- Nada de material na loja da descida, no Altar ou na Provação como custo (`auditoria.md` 3.2).
- Por que a Memória não é a Maestria em dobro: a Maestria vem de jogar (toda sala dá XP); a Memória vem de **escolher**
  a porta dela no lugar de outra coisa, ou de vencer um desafio (guardião, Provação). Ela cria decisão, o XP não.
- Fim de jogo (quando tudo foi comprado): a Prata vai para os Encantos aprendidos e, na Fatia 3, para as Obras do
  Vendedor; a Memória para o Discernimento; a Esmeralda para os Juramentos. Teto no save evita acumular sem fim.

### 1.3 Como cada sistema puxa o outro

```
            HUB (Santuário)
   +-----------------------------------------------+
   | Forjador: Prata -> Temperar / Refinar          |
   |           Esmeralda -> Despertar               |
   |           ferramenta -> abre Refinar,          |
   |                         Despertar, Inscrever   |
   |           Prata -> aprender Encanto (Inscrever)|---+  o Encanto aprendido
   | Livro de Ahk: Maestria revela o Dom,           |   |  entra no sorteio
   |               Memória abre o Dom,              |   |
   |               Devoção equipa                   |---|--+  Dons equipados mudam
   | Vendedor (Fatia 3): Obras com os três          |   |  |  a luta e quais Bênçãos
   +-----------------------------------------------+   |  |  combinam (Elo, Salmo)
                |  Portal                              |  |
                v                                      v  v
   DESCIDA: cada sala vencida abre portas que mostram a recompensa
     porta de Bênção  -> Encontro: 2 anjos -> 1 anjo -> 3 Bênçãos da família dele
     porta de Encanto (Fatia 2) -> 3 Encantos aprendidos -> 1 (máx. 2 por descida)
     porta de Prata / de Memória -> material para casa
     porta Difícil -> mais elites -> mais Prata (1 por elite)
     guardião -> Bênção rara + Prata + Memória (+ ferramenta na 1ª vez)
     Provação -> Bênção forte + Memória quando vencida
     loja (ouro) -> Bênção, cura, romã, Encanto (Fatia 2)
     Morvath -> Prata por fase, Esmeralda na fase 3, vitória dá os três
                |  derrota ou vitória: tudo o que foi pego vai para o save
                v
            HUB (de novo)
```

As trocas que dão sentido ao mapa:

| Escolha | Agora contra depois |
|---|---|
| porta de Bênção **ou** porta de Prata/Memória | força nesta descida contra força nas próximas (o "Encanto contra material" do pacote, mais amplo) |
| porta comum **ou** porta Difícil | segurança contra 3 a 6 Prata a mais |
| Bênção **ou** Salmo (Fatia 2) | ganho previsível contra a transformação rara |
| Encanto **ou** cura (Fatia 2) | mudar o golpe contra chegar vivo |
| gastar Memória no próximo Dom **ou** no Discernimento (Fatia 3) | herói mais completo contra controle do sorte |

### 1.4 Os Dons com a Memória (o nosso Arcana)

- Hoje: a Maestria destrava um Dom por nível e a Devoção limita quantos se equipa.
- Proposta: a Maestria **revela** o Dom (ele aparece no Livro com o custo); a Memória **abre** (paga uma vez); a
  Devoção **equipa** (como hoje). Custo em Memória = o custo de Devoção do Dom (1 a 5; os 19 somam 57). O primeiro Dom
  (Quarto Corte, Maestria 1) vem aberto, para a primeira descida não ser mais pobre que hoje.
- Conta da D-57 (desbloqueios frequentes no começo): até a Maestria 5 (3ª ou 4ª descida) os Dons revelados pedem 2 + 3
  + 2 = 7 de Memória; com 2 a 3 por derrota, dá. Se o Daniel quiser **escolha** de verdade (qual Dom abrir primeiro), a
  Maestria precisa revelar mais de um por vez (por degrau); fica como pergunta (Q-RJ6), não na Fatia 1.

### 1.5 A Forja (o nosso aprimoramento das Armas Noturnas)

| Função | O que faz | Custo (ponto de partida) | Abre com | Fatia |
|---|---|---|---|---|
| Temperar I | ataque +10% de dano | 15 Prata | o Forjador | 1 |
| Temperar II | especial e Ômegas +10% de dano | 35 Prata | Temperar I | 1 |
| Temperar III | todo golpe da Emeth +5% | 60 Prata | Temperar II | 2 |
| Refinar | uma especialização por ação, **exclusiva** (troca grátis no hub): por exemplo ataque "Fio" (alcance), "Peso" (atordoa mais) ou "Pressa" (recuperação menor) | 25 Prata cada | ferramenta 1 | 2 |
| Despertar | uma propriedade nova da lâmina, uma ativa por vez (molde do aspecto) | 2 a 4 Esmeralda | ferramenta 2 | 3 |
| Inscrever | aprender um Encanto: ele passa a poder sair nas descidas | 20 Prata cada | ferramenta 3 (os 3 primeiros Encantos já vêm aprendidos na Fatia 2) | 3 |

- Tudo como dado: um `ForgeRank` (Resource com `mods: Array[BoonMod]`, custo e pré-requisito), somado ao
  `BoonState.stat` do mesmo jeito que os Dons (`equip_talents`). Temperar não pede código de combate: `damage_pct` com
  tag já existe em `Combat`.
- **Retorno visível**: cada posto da Forja muda a Emeth no jogo (veio de ouro mais aceso, fio mais claro, do
  `emeth.gdshader`), na estação do Forjador (forno que acende) e na página do Guerreiro no Livro.
- Equilíbrio: o `balance.md` pediu no máximo 5 a 10 pontos por coisa permanente. Temperar I e II juntos devem ficar
  nisso; o `balance-designer` mede depois da Fatia 1 (decisão 1 do Daniel: mecânica primeiro).

### 1.6 Os anjos e as Bênçãos

- Cada família de Bênção passa a ser **de um anjo** (seção 4). O Elo é dois anjos juntos (o duplo do Hades).
- **Encontro**: a recompensa de Bênção na sala vira o medalhão do encontro; tocá-lo mostra **dois anjos** (sorteados
  entre os que têm ao menos uma Bênção válida para a mão) e, escolhido um, **até 3 Bênçãos da família dele** com as
  regras de hoje: raridade em sequência, troca (10%), romã não, Elo que envolve a família dele (12%), Salmo (10%, até a
  Fatia 2 dar a porta própria).
- Fallback: um só anjo elegível, só ele aparece ("Só um anjo atende"); nenhum, a carta de Fôlego de hoje; menos de 3
  Bênçãos na família, as que houver. Nunca carta inválida.
- Sorteio com sal próprio (como o `MAP_SALT`): a mesma semente dá o mesmo mapa de antes e os mesmos pares de anjos.
- Hades II: a regra comum é "a porta mostra o deus"; a sala de dois deuses é uma carta do baralho. O Daniel pediu o
  Sworn (escolher entre dois). Proponho **as duas, em fatias**: na Fatia 1 toda sala de Bênção é encontro de dois (para
  sentir a mecânica pedida); na Fatia 2 a porta passa a mostrar **um** anjo na maioria das vezes (o "ver o anjo da sala"
  pedido) e o encontro de dois vira 2 das 6 cartas de Bênção do baralho. Isso devolve a decisão ao mapa.

### 1.7 Salmo, Encantos, Vendedor e Juramentos (Fatias 2 e 3)

- **Salmo como porta** (Fatia 2): carta SALMO no baralho, válida só quando algum Salmo já pode vir (`Psalms.met`);
  a porta garante uma carta de Salmo entre as 3. Fica contra a porta de Bênção.
- **Encantos** = a Lapidação da Emeth (`hades2_sistemas.md` 6): carta ENCANTO no baralho, no máximo 2 por descida (o 2º
  da metade da descida em diante), 3 opções entre os Encantos **aprendidos na Forja**, loja 200 de ouro. A Forja decide
  o que pode sair; a descida decide qual sai. Catálogo ajustado em `auditoria.md` 3.1.
- **Vendedor** (Fatia 3): as Obras do Santuário (o Caldeirão): gastos únicos que abrem sistemas na descida (o Altar
  aparece mais, a porta de Salmo, a 2ª romã da loja, a prévia do anjo no mapa) e a troca entre materiais com perda (o
  Corretor do Hades II). É o único lugar que mistura os três, como sumidouro de fim de jogo.
- **Juramentos**: vencer com Peso acima do recorde dá Esmeralda uma vez por patamar (as recompensas de Calor do Hades I).

---

## 2. Equivalências com o Hades II

| Hades II | Eterra | Onde difere |
|---|---|---|
| Arcana (cartas, Cinzas para abrir, Fôlego para equipar, Psique sobe o Fôlego, Pó Lunar melhora) | Dons no Livro de Ahk; **Memória** abre; **Devoção** equipa; a **Maestria** sobe a Devoção e revela os Dons | árvore com pré-requisitos (não grade de vizinhas); a Maestria faz o papel da Psique e não é coletada; sem Pó Lunar (um 2º posto dos Dons pagaria em Memória, Fatia 3 se fizer falta) |
| Armas Noturnas (6 armas, aspectos com níveis, pagos com Pesadelo e minérios) | **Forja da Emeth**: uma arma só, Temperar (níveis), Refinar (escolha exclusiva, o papel do aspecto) e Despertar | sem troca de arma; o aspecto vira especialização por ação; minérios viram Prata |
| Martelo de Dédalo (2 por noite, 3 opções, loja 200) | **Encantos** (a Lapidação) | os Encantos que podem sair são os aprendidos na Forja (o Hades II não tem esse passo); é a ligação Forja para descida |
| Reagentes, ferramentas de coleta, Caldeirão e Encantamentos | **ferramentas do Forjador** (achados de marco) e **Obras do Vendedor** | sem pontos de coleta nas salas (seria mais uma camada de arte e de ação; fica para depois, se o Daniel quiser "achados" no chão) |
| Psique | a Maestria | não coletada |
| Medo e Votos | Peso e Juramentos (já existem) | recompensa de Esmeralda por recorde, como o Calor do Hades I |
| Deuses do Olimpo e as portas com o deus à mostra; sala de dois deuses no baralho | **anjos**, servos de Yah, um por família; Encontro de dois (Sworn) | mensageiros, não fontes; nunca adorados; a luz é de Elun |
| Recompensas menores nas portas (Cinzas, Psique, ossos) competindo com dons | **portas de Prata e de Memória** | iguais no papel |
| Persuasão do Destino (espelho, Hades I) | **Discernimento** pago em Memória no Livro (Fatia 3) | sem garantia de montagem perfeita |

Onde estamos atrás do Hades II (opinião): o número de Bênçãos por família (6 a 7 contra cerca de 15 por deus).
Com o encontro filtrando por família, o anjo com poucas Bênçãos válidas repete rápido; a Fatia 2 precisa de 2 a 3
Bênçãos novas por família (dados, `make_data.gd`), começando por Geada e Vigília, que têm 6.

---

## 3. A Fatia 1: o menor laço que o Daniel já joga

### 3.1 O que entra

1. **Dois materiais**: Prata Antiga e Fragmento de Memória, no save, com as fontes da tabela 1.2 (elite, guardião,
   Morvath, Provação vencida para a Memória).
2. **Duas portas novas**: duas cartas no baralho (`StageDef.reward_deck` vai de 14 a 16: uma PRATA, uma MEMÓRIA, nada
   tirado), marcas próprias na placa e no mapa (`DoorGlyph`), o medalhão na sala (`RewardGem` com esmalte novo).
3. **A Forja com duas melhorias** no Forjador do hub (Temperar I e II), página de verdade no lugar de "a definir", com
   o custo, o que faz e a Emeth mudando.
4. **Dons pedindo Memória**: o passo "Abrir" no Livro (Maestria revela, Memória abre, Devoção equipa); migração abre de
   graça todo Dom que o save já tinha destravado.
5. **Encontro com dois anjos** em toda sala de Bênção e no guardião, usando as quatro famílias de hoje, com os anjos
   como **selos** (medalhão com o símbolo e a cor da família, nome e uma linha de temperamento), sem figura.
6. **Registro**: materiais e encontros no `RESULT` e no registro; a tela de fim mostra o que foi trazido.

### 3.2 O que fica de fora e por quê

| Fora | Por quê |
|---|---|
| Esmeralda, Refinar, Despertar, ferramentas | cada um pede efeito de combate novo ou um marco; o laço fecha sem eles |
| Encantos | código em `ComboNode` e revisão da `combat-feel-director`; é a Fatia 2 inteira |
| Porta com um anjo à mostra, porta de Salmo, Discernimento | mudam o baralho e a leitura do mapa; vêm depois de saber se o encontro agrada |
| Obras do Vendedor, troca | sumidouro de fim de jogo; sem fim de jogo ainda |
| Retratos ou figuras dos anjos | forma (auréola, asas) é do Daniel (seção 4); Meshy zero |
| Equilíbrio (B-1 a B-5) | decisão (1) do Daniel |

### 3.3 Critérios de aceite medíveis

| # | Critério | Como medir |
|---|---|---|
| A1 | save antigo (versão 5) abre com tudo de antes, os Dons destravados abertos, materiais em 0; nada se perde em 2 derrotas, 1 saída e 1 vitória seguidas | GUT com `tests/fixtures/save_v5.json` novo e o fluxo do HUB-C |
| A2 | material somado uma vez por descida (vitória, morte, saída), nunca pelo robô nem `--nosave` (salvo `--materials-keep` para medir) | GUT |
| A3 | mesma semente, mesmo mapa e mesmos pares de anjos; o mapa igual ao de antes nas camadas sem as cartas novas | GUT, 200 sementes |
| A4 | encontro: em 2000 sorteios nenhuma carta inválida; dois anjos diferentes sempre que há dois elegíveis; raridade, troca e Elo dentro de 2 pontos das taxas da E3 (`docs/qa/e3_metrics.md`) | GUT |
| A5 | robô 0,25 e 0,45, 48 sementes, R0 e M10: Prata por descida p50 de 6 a 18 na derrota e 28 a 40 na vitória; Memória p50 de 1 a 4 e 5 a 9 | `RESULT.materials`, `balance-designer` |
| A6 | em pelo menos 25% das salas com duas ou mais portas, uma é de material e outra de Bênção | `RESULT.map` |
| A7 | descidas até Temperar I: p50 até 2, p90 até 3; até Temperar II: p50 de 4 a 6 (soma das descidas do robô 0,45 em sequência de sementes) | `balance-designer` |
| A8 | cada anjo oferecido em 20 a 30% dos encontros; o robô escolhe por afinidade (a família de que mais tem) | `RESULT.angels` |
| A9 | sem regressão: `tools/test.sh` verde, sonda de sensação 40/40, `smoke 600` e `--start=boss --boons=25` sem erro; taxa de vitória do robô dentro do ruído do `balance.md` sem a Forja | ferramentas de sempre |
| A10 | a escolha do anjo custa ao jogador no máximo 2 apertos a mais que hoje (teclado, controle, mouse) | `tools/title_flow_check.gd` e um fluxo novo do encontro |

O que só o Daniel jogando responde: dá vontade de pegar a porta de Prata no lugar da Bênção? A primeira melhoria da
Forja se sente? Escolher o anjo é decisão ou só mais um clique? Abrir um Dom com Memória é bom ou atrasa?

### 3.4 Tarefas por agente

| Agente | Tarefa | Esforço |
|---|---|---|
| `gameplay-engineer` | `MaterialPurse` puro (somar, teto, fontes); `RunMap.Reward` SILVER e MEMORY no baralho e na `Rooms` (`_give_reward`); ganchos na elite abatida, guardião, fases de Morvath, Provação vencida; `ForgeRank` em `data/forge/emeth/` (parte `forge` do `make_data.gd`) somado ao `BoonState.stat`; `Talents` com "aberto" e custo em Memória; `AngelDef` em `data/angels/` (id, família, chaves de nome e linha, cor, símbolo) e `Encounter` puro (dois anjos por sal próprio, ofertas pelo `BoonState.draw` com filtro de família); robô (porta de material no `bot_door`, anjo por afinidade); save versão 6 e migração; `RESULT` e registro versão 5; opções `--materials=`, `--forge=`, `--angels=a,b`; testes | G |
| `ui-ux-designer` | página da Forja no Forjador (folha do Livro, como o `HubPanel`): melhorias, custo, o que falta, o que muda; passo "Abrir" e custo em Memória na árvore e no painel do Dom; tela do Encontro (dois selos, depois as 3 cartas, voltar ao par); marcas das duas portas na placa e no mapa; "Trazidos" na tela de fim; materiais no hub (canto da página do Forjador e do Livro) | M |
| `environment-artist` | medalhão da recompensa em prata e em pergaminho (`RewardGem.ENAMEL_*`); o forno do Forjador acende depois de uma melhoria | P |
| `technical-artist` | a Emeth por posto de Temperar (veio de ouro e fio, abaixo do glow, `emeth.gdshader`); os 4 selos dos anjos como desenho vetorial (sem IA, sem Meshy); inventário de assets | P |
| `balance-designer` | A5 a A8 em 48 sementes; proposta de custos e quantidades; quanto Temperar I e II valem em pontos de vitória | M |
| `art-director` | revisão dos selos e do medalhão (cor, nada de sol, cruz, leão) | P |
| `qa-performance` | relatório final e o exe para o Daniel | P |

Estimativa (opinião): um ciclo, com o `gameplay-engineer` como caminho crítico; a UI começa quando os dados
(`AngelDef`, `ForgeRank`, materiais no save) existirem.

### 3.5 Riscos

- **Mais uma tela por Bênção** (seis a oito por descida): pode cansar. Mitigação: a escolha do anjo é um aperto e a
  tela abre já com o foco no primeiro; se o Daniel achar lento, a Fatia 2 já reduz (anjo à mostra na porta).
- **Famílias curtas**: com o filtro, um anjo pode oferecer menos de 3; o fallback cobre, mas a Fatia 2 precisa de
  Bênçãos novas.
- **Memória atrasando os Dons** (contra a D-57): primeiro Dom aberto, migração generosa, custos baixos; medir a
  Maestria 5 com 4 Dons abertos até a 4ª descida.
- **Dois donos do save** (hub e partida): só chaves no `defaults()`; `merged` descarta o resto (risco do `hub_spec.md`).
- **Nomes dos anjos** saindo antes da aprovação: chaves de texto próprias, fáceis de trocar; se o Daniel preferir,
  marcadores `ANJO_CHAMA` como os `PALADIN_n` até ele nomear.
- **Robô não é gente**: A5 a A8 dizem se a economia corre, não se diverte.

### 3.6 Fatia 2 e Fatia 3

**Fatia 2, "a escolha do caminho"**: Esmeralda (Morvath); primeira ferramenta (no 1º guardião vencido) abre o
Refinar; Temperar III; os 3 primeiros Encantos (Lâmina Tríplice, Eco da Verdade, Retorno do Corte, revistos em
`auditoria.md` 3.1) com a carta ENCANTO e a loja; porta com **um** anjo à mostra e o encontro de dois como carta rara;
porta de Salmo; regras de bifurcação no baralho (RJ-2, RJ-3: duas portas da mesma sala nunca do mesmo grupo quando der);
porta Difícil anunciando a Prata a mais; 2 a 3 Bênçãos novas por família. Aceite: % de bifurcações contrastantes, cada
Encanto escolhido entre 20 e 45%, nenhum anjo abaixo de 3 ofertas válidas em 95% dos encontros.

**Fatia 3, "o fim de jogo"**: ferramentas 2 e 3 (Despertar e Inscrever), Encantos 4 a 6; Discernimento I e II pagos em
Memória no Livro; Obras e troca no Vendedor; Esmeralda por recorde de Peso; Compêndio com a aba Anjos; retratos ou
figuras dos anjos se o Daniel aprovar a forma. Aceite: a soma de todo progresso permanente dentro da curva do
`balance.md` (a diferença Maestria 1 para 20 entre 40 e 60 pontos).

---

## 4. Proposta inicial de anjos (tudo proposta, nada canônico)

Base no cânone: os anjos são **Malahym**, "anjos imortais criados por Yah" (`canone.md` 303). Cada anjo é um
**mensageiro** que leva ao Guerreiro uma parte da luz que vem de Elun; nunca é a fonte, nunca é adorado, fala pouco.
Nomes com o final "-el" dos anjos bíblicos, mas nenhum nome bíblico real (Miguel, Gabriel, Rafael ficam de fora).

| Família (hoje) | Bênçãos que ela tem | Nome provisório (alternativas) | Temperamento | Papel mecânico | Benchmark do Hades II | Forma visual sugerida | Símbolo sugerido |
|---|---|---|---|---|---|---|---|
| Chama (7) | Brasas, Redemoinho, Lâmina Ardente e o golpe, o especial, o círculo e a esquiva em brasa | **Sarael** (Ardiel, Ignael); do serafim, "os que ardem", eco da brasa que purifica em Isaías 6 | caloroso, impaciente, encoraja a avançar | **pressão**: dano ao longo do tempo, fogo que cai, finalizador que incendeia | Héstia (queimadura) | figura alta em manto vermelho-terra e ouro velho, nunca vermelho de Morvath nem do Dragão | brasa em losango com três pontas de chama |
| Geada (6) | Toque da Geada, Estilhaço, Peso do Inverno e o golpe, o círculo e a esquiva de geada | **Nivael** (Glacael, Shelgiel); da neve, eco dos "tesouros da neve" de Jó 38 | sereno, severo, poucas palavras | **controle**: congelar, quebrar o congelado | Deméter (congelamento) | manto azul-gelo apagado, cristais nas bordas, cabeça baixa | floco de seis braços curtos (nunca quatro: lê como cruz) |
| Luz (7) | Consolo, Maré de Luz, Flagelo dos Mortos e o golpe, o especial, o círculo e a esquiva radiantes | **Lumael** (Orael, Fanuel); a luz que ele leva é de Elun | alegre, direto, o mais próximo do herói | **alcance e impacto**: dano direto, lâminas que voam, pilares sobre os mortos, cura no abate | Apolo (área e luz) e Zeus nos pilares que caem | marfim e ouro velho, mãos abertas para baixo (a luz desce por ele) | feixe vertical estreito que desce sobre um losango (nunca raios em volta: lê como sol) |
| Vigília (6) | Escudo da Vigília, Passos Leves, Firmeza e o golpe, o especial e o círculo firmes | **Shomael** (Tsurael, Vigiel); de *shomer*, "o que vigia" | atento, calmo, protetor sem deter o herói | **ritmo e sustento**: carga de esquiva, velocidade, vida, alcance, o escudo passivo | Hermes (velocidade) e Atena do Hades I (proteção; no Hades II a confirmar) | petróleo e ouro velho (as cores do herói), em pé, olhar para longe | trombeta do vigia (eco de Ezequiel 33), nunca escudo nem olho |
| Elo (6) | Vapor, Aurora Gelada, Chama Viva, Bastião, Rastro em Brasa, Passo Frio | sem anjo próprio: **os dois anjos juntos** | | combinação de duas famílias | as Bênçãos duplas | os dois selos entrelaçados pela corrente de ouro do `EloLink` | |

Avisos:
- "Shomael" e o Salmo da Sentinela falam de vigiar; não conflitam (um é família, outro transformação), mas o texto
  não pode repetir as palavras.
- A família Vigília tem hoje no texto "voto de {P1}" (um paladino): com o anjo isso muda (D-51 substituída).
- Fala: uma linha curta ao escolher e outra ao recusar (o molde do Hades), sem citar versículo.

Perguntas para o Daniel sobre a forma (recomendação minha em negrito):
- **Auréola**: (a) nenhuma; (b) um aro fino de ouro velho atrás da cabeça, sem raios; (c) clássica. **(b)**: lê como
  anjo sem virar sol (a regra D-66).
- **Asas**: (a) asas cheias; (b) asas fechadas ou só sugeridas pelo manto; (c) sem asas. **(b)**: fica longe da
  leitura do Dragão (o Malahym caído) e da arte do pacote, que exagera.
- **Rosto**: (a) visível; (b) encoberto ou em luz. **(b)**: mistério e nenhum risco de parecer pessoa adorada.
- **Na Fatia 1**: só o selo (medalhão vetorial); figura e retrato depois da aprovação, sem Meshy e sem IA não declarada.

---

## 5. Save e registro

### 5.1 Save versão 6 (`SaveData`)

| Chave | Onde | Padrão | Observação |
|---|---|---|---|
| `materials` | raiz | `{"silver": 0, "memory": 0, "emerald": 0}` | compartilhado (no Hades os recursos são da casa); teto por `MaterialPurse` |
| `materials_total` | raiz | o mesmo, somado na vida do save | Compêndio e métricas |
| `opened` | `heroes.warrior` | `[]` | ids dos Dons abertos com Memória |
| `forge` | `heroes.warrior` | `{"temper": 0, "refine": {}, "awaken": "", "inscribed": []}` | a Emeth é do Guerreiro |
| `tools` | `heroes.warrior` | `[]` | ferramentas achadas (Fatia 2) |

Migração (5 para 6, uma vez): `opened` recebe todo Dom com `unlock_level` até o nível atual de Maestria (ninguém perde
um Dom); `equipped` continua válido; materiais em 0. Opção para o Daniel (Q-RJ8): um crédito retroativo de Prata pelas
descidas já feitas (5 por descida em `runs`, até 30), como a Maestria retroativa dos saves 1 e 2, para ele chegar ao
Temperar I no primeiro teste. Tudo pelo `defaults()` e `hero_defaults()`, senão `merged` descarta; arquivo
`tests/fixtures/save_v5.json` novo para o teste. Gravação pelo `SaveFile` atômico de sempre.

### 5.2 `RESULT` e registro (`RunLog.VERSION` 5)

- `materials`: `{"silver": {"elite": n, "door": n, "guardian": n, "boss": n}, "memory": {"door": n, "guardian": n,
  "trial": n, "boss": n}}` e o total.
- `forge`: os postos no começo da descida (para separar o efeito da Forja na taxa de vitória).
- `talents_opened`: quantos Dons abertos no começo.
- `angels`: uma entrada por encontro, `{"room": n, "offered": [a, b], "chose": a, "cards": [ids], "fallback": ""}`.
- Os eventos `door` e `reward` de hoje já levam as recompensas novas pelo `RunMap.Reward`.
- `RunLog.normalized` lê as linhas antigas com `materials` vazio e `angels` `[]`.

### 5.3 API para a UI (gameplay-engineer, Fatia 1 implementada em 2026-11-19)

Tudo o que as telas do `ui-ux-designer` precisam já existe; as três telas provisórias (marcadas `PROVISIONAL` no código)
saem quando as dele entrarem. O comentário no topo de cada arquivo repete isto.

**Materiais** (`MaterialPurse`, `scripts/core/material_purse.gd`, puro):
- Ids `MaterialPurse.SILVER`, `MEMORY`, `EMERALD`; nome `NAME_KEY[id]` ("Prata Antiga", "Fragmento de Memória",
  "Esmeralda") e curto `SHORT_KEY[id]` ("Prata", "Memória", "Esmeralda") no `text_pt.tres`; tetos em `CAP`.
- No save: `MaterialPurse.amount(Save.data, id)`, `can_pay`, `spend`, `give`; `Save.data.materials_total` para o Compêndio.
- Na descida: `game.materials` (um `MaterialPurse`): `total(id)`, `totals()`, `report()` (fonte por fonte); o que foi
  guardado no fim fica em `game.materials_banked` ({id: n}, vazio para o robô e sem save): é o "Trazidos" da tela de fim.
- Achado na sala: `Rooms.found(material, source, n, at)` mostra a palavra "+n Prata" de hoje (a tela pode ouvir o
  `game.materials` ou trocar isso).
- Portas: `RunMap.Reward.SILVER` e `MEMORY`, chaves `reward_silver`/`reward_memory`, cor `Rooms.SILVER_COLOR`/
  `MEMORY_COLOR`. `DoorGlyph.of_reward` e `RewardGem.mark_of` ainda caem em NONE para elas (marcas novas: da UI e do
  technical-artist).

**Forja** (`Forge`, `scripts/core/forge.gd`; postos `ForgeRank` em `data/forge/emeth/`, parte `forge` do `make_data.gd`):
- `var f := Forge.new(Forge.load_catalog())`; `f.track(Forge.TEMPER)` (os postos em ordem); `f.state(Save.data, posto)`
  (`OWNED`, `NEXT`, `LOCKED`); `f.problem(Save.data, posto)` (`OK`, `OWNED`, `NEEDS` o anterior, `SHORT` de Prata,
  `UNKNOWN`); `f.buy(Save.data, id)` gasta e grava no bloco (a tela chama `Save.write()` depois); `Forge.temper(data)`.
- Texto: `posto.name_key`, `posto.desc_key`, `posto.cost`, `posto.material`; frases `forge_have`, `forge_next`,
  `forge_buy`, `forge_short`, `forge_done`.
- Hub: `Hub.forged(rank)` sai depois de cada compra (a forja e a Emeth podem reagir). A página provisória é
  `Hub._open_forge` (um `HubPanel` com o posto seguinte e Voltar).

**Dons com Memória** (`HeroLoadout`, `Talents`):
- `HeroLoadout.State.SEALED` (revelado pela Maestria, ainda não aberto); `open_cost(t)`, `memory()`, `can_open(t)`
  (`Talents.Problem` `OK`, `OPENED`, `SHORT`, `LOCKED`), `open(id)` (gasta; a tela grava o save); `next_step(t)` dá
  `hero_step_open` ({cost, have}) e `why(t)` dá `hero_why_sealed`.
- Provisório: `toggle` num Dom selado que se pode pagar abre e equipa num aperto só; com o passo "Abrir" da tela, tirar.

**Encontro** (`Encounters`, `scripts/game/encounters.gd`, em `game.encounters`; regras puras em `Encounter`):
- `signal opened(angels)`: um encontro precisa de escolha. Se alguém estiver ligado no sinal, a `AngelChoice`
  provisória não abre e a tela nova faz tudo.
- `angels_now` (o par à mostra), `cards_of(anjo)` (as cartas daquele anjo, sempre as mesmas: dado próprio; serve para
  voltar ao par sem sortear de novo), `choose(anjo)` (abre as cartas na `BoonChoice`).
- `meetings`: o registro (`RESULT.angels`).
- Anjo: `AngelDef` (`id`, `family`, `name_key`, `line_key`, `color`, `symbol`); selo `AngelSeal.new().setup(family, px)`.
- Textos `encounter_title`, `encounter_alone`, `encounter_hint`.

**Opções de teste**: `--materials=silver:30,memory:5` (o save da sessão, nada gravado), `--forge=N` (Temperar N na
sessão e na descida, também a do robô), `--angels=a,b` (o par forçado), `--no-angels` (o sorteio de antes),
`--materials-keep` (o robô guarda o que traz, para medir A7 com save).

#### Fatia 2 (gameplay-engineer, implementada em 2026-11-20)

Mesma regra: a lógica está pronta e testada (`tests/test_fatia2.gd`); a única tela provisória nova é a `EnchantChoice`
(`scripts/ui/enchant_choice.gd`, marcada `PROVISIONAL`), que só abre quando ninguém ouve o `Game.enchant_offered`.

**Portas e mapa** (`RunMap`):
- Recompensas novas `RunMap.Reward.ENCHANT` e `PSALM` (chaves `reward_enchant`, `reward_psalm`; cores provisórias
  `Rooms.ENCHANT_COLOR`, `PSALM_COLOR`; `DoorGlyph.of_reward` e `RewardGem.mark_of` caem em NONE para elas: marcas
  novas são da UI e do technical-artist). Baralho de 21 cartas (16 + 2 Encantos + 1 Salmo + 2 Bênçãos, para a Bênção
  manter a fatia de 6 em 16).
- Grupos (RJ-2): `RunMap.group_of(reward)` dá `Group.POWER` (Bênção, romã, Encanto, Salmo), `BODY` (coração, Magia,
  ouro, cura) ou `HOME` (Prata, Memória). O gerador prefere, porta a porta, uma carta de grupo que as portas irmãs ainda
  não mostram (`RewardDeck.draw_prefer`): em 1000 grafos, 93,2% das bifurcações mostram dois grupos ou mais (77,8%
  antes), 9,5% os três (3,8%), nenhuma com a mesma recompensa duas vezes (`tools/door_forks.gd`).
- Encanto no máximo `StageDef.enchant_max` 2 em qualquer caminho, o segundo desde a sala `enchant_second_from` 5; Salmo
  desde a sala `psalm_from_depth` 4. Ao abrir as portas, `RunMap.settle(portas, pode_romã, pode_salmo, pode_encanto)`
  troca por Bênção o que não pode vir agora (nenhum Salmo elegível, dois Encantos já tomados).
- Porta de Salmo sem promessa falsa (2026-11-20): a carta de Salmo do baralho cai no mapa como Bênção com
  `Room.psalm` verdadeiro (nunca encontro de dois) e só vira `PSALM` ao abrir as portas, se um Salmo pode vir então
  (`settle(..., pode_salmo)`, padrão `false`). O mapa e a placa nunca mostram um Salmo que a porta não dá. Medido: nas
  72 descidas do robô (sem Dons) nenhum Salmo ficou elegível, então a porta de Salmo só aparece para quem tem Dons ou a
  mão certa; a frequência é do balance-designer.
- Anjo à mostra: cada sala de Bênção tem `Room.meeting` (encontro de dois; a sala 1, o guardião e duas de cada seis
  das outras, `StageDef.angel_deck`) ou, ao abrir as portas, `Room.angel` (o id do anjo que espera ali,
  `game.encounters.door_angel(sala)`). `door_info(i)` e `RunMap.view()` trazem `meeting` e `angel`;
  `Rooms.door_text` já escreve o nome do anjo ou "Dois anjos" embaixo da recompensa (`door_angels_two`).
- Porta Difícil com a Prata a mais: "Difícil, +N Prata" (`door_hard_silver`, `{n}`), N = `Rooms.elite_heads(sala)` x
  `StageDef.silver_elite`.

**Encontro** (`Encounters`): a sala com `angel` abre direto nas cartas daquele anjo (sem a tela do par;
`meetings[].fallback` = `"door"`); se ele não tiver mais carta para a mão, volta o par. O resto da API não mudou.

**Encantos** (`Enchants`, `scripts/core/enchants.gd`, puro; `EnchantDef` em `data/enchants/`, parte `enchants`):
- `Game.enchant_offered(options)` sai quando uma escolha abre (porta de Encanto, loja); `game.enchant_options` (até 3
  `EnchantDef`: `id`, `name_key`, `desc_key`, `slot`, `mods`, `excludes`); `game.take_enchant(e)` toma (a tela fecha
  com `game.close_screen()` antes ou depois); `Game.enchant_taken(e)` sai depois. `game.enchant_offers()` diz o que
  viria agora (vazio com dois tomados); `game.boons.enchants` os da descida.
- Os três: Lâmina Tríplice (o giro solta três ondas em leque, nunca com o Dom Corte Crescente), Eco da Verdade (o giro
  golpeia de novo 0,3 s depois com metade, tag `echo` no `dealt_by`), Retorno do Corte (1 s depois do Corte Veloz o
  próximo golpe alcança 30% mais longe e mais largo; nunca com Passo Encadeado nem Fio do Passo). Textos
  `enchant_<id>`, `enchant_<id>_desc`, `enchant_title`, `enchant_hint`.
- Loja: o Encanto (200) está no grupo da Magia e da romã (`Rooms.shop()` traz `item` = `RunMap.Reward.ENCHANT`), só
  quando `enchant_offers()` não está vazio.

**Salmo pela porta**: `Game.open_psalm_choice(chances)` abre a `BoonChoice` de sempre com três cartas, a primeira um
Salmo que já pode vir (`card_chosen` como antes).

**Forja**:
- `Forge.TEMPER` com três postos (Temperar III, 60 Prata, +5% em todo golpe).
- Refinar (`Forge.REFINE`): `f.refine_slots()` (`attack`, `special`), `f.refine_options(slot)` (três por ação: Fio,
  Peso, Pressa; Onda Larga, Onda Pesada, Onda Pronta; 25 Prata cada, `posto.slot`, `posto.tool`), `f.state`/`problem`
  (`Problem.NO_TOOL` sem a ferramenta, texto `forge_no_tool`), `f.buy` (o primeiro de cada ação já entra), `f.is_on`,
  `f.put_on(data, id)` (troca de graça entre os comprados), `f.take_off(data, slot)`, `f.refines_on(data)`,
  `f.ranks_for(data)` (o que a descida leva). Textos `forge_track_refine`, `forge_refine_slot_<slot>`,
  `forge_refine_<id>`, `forge_refine_<id>_desc`, `forge_temper_3`.
- Ferramentas: `Forge.TOOLS`, `Forge.has_tool(data, tool)`; na descida `game.tools_found` (o primeiro guardião
  vencido acha `tool_refine`), sinal `Game.tool_found(tool)`, aviso `tool_found`; guardadas no fim como os materiais
  (`game.tools_banked`). Nome `tool_<id>`.

**Esmeralda**: `MaterialPurse.EMERALD`, fonte `boss` (fase 3 de Morvath alcançada 1, vitória 1).

**`RESULT` e registro**: `enchants` (ids), `tools`, `forge.refine` (ids), `materials` com `emerald`.

**Loja de rota (DV-2, MAP-09)**: `RunMap.is_route_shop(sala)`; a mesma `Rooms.shop()` com 3 itens (um de cada grupo);
`RESULT.route_shop` (ouro ao entrar, comprado, gasto) à parte do `shop`.

**Aceite medido** (72 sementes, robô 0,25): Encantos 28 / 36 / 36%; nenhum encontro com menos de 3 cartas em 384;
bifurcações contrastantes 93,2%. Detalhes e a queda de vitórias do robô (vida em Morvath) no `balance.md`.

**Opções de teste**: `--refine=refine_fio,refine_onda_larga` (o Refinar na descida, também a do robô).

---

## 6. Perguntas para o Daniel (curtas, com a minha recomendação)

| Id | Pergunta | Opções | Recomendação |
|---|---|---|---|
| Q-RJ1 | Começar pela Fatia 1 como está em 3.1? | (a) sim; (b) sem o encontro de anjos (só materiais, Forja e Dons); (c) só o encontro | **(a)**: é o menor conjunto em que tudo conversa |
| Q-RJ2 | Quantas moedas | (a) três (Prata, Memória, Esmeralda) mais ferramentas; (b) as cinco do pacote | **(a)**; a Brasa colide com seis Bênçãos |
| Q-RJ3 | Nomes dos materiais | Prata Antiga, Fragmento de Memória, Esmeralda; ou outros seus. Memória pode ser "Página de Ahk"? (seria lore nova: onde estão os papiros) | **os neutros** até você decidir; nada com Ahk sem o cânone |
| Q-RJ4 | Anjos | os quatro da seção 4, nomes, temperamentos e símbolos | aprovar ou trocar os nomes; **auréola fina sem raios, asas fechadas, rosto encoberto** |
| Q-RJ5 | Toda sala de Bênção com dois anjos (Fatia 1) e depois a porta com um anjo à mostra (Fatia 2)? | (a) sim; (b) sempre dois; (c) sempre um, dois só às vezes | **(a)**: sente o Sworn agora e devolve a decisão ao mapa depois |
| Q-RJ6 | Dons: a Maestria revela um por nível (como hoje) ou um degrau inteiro por vez, para a Memória virar escolha de qual abrir? | (a) um por nível; (b) por degrau | **(a) na Fatia 1**, (b) a medir na Fatia 2 (mexe na D-57) |
| Q-RJ7 | A primeira melhoria da Forja chega cedo (até a 2ª descida) mesmo com o `balance.md` pedindo "depois da 5ª"? | (a) cedo e pequena; (b) depois da 5ª | **(a)**: para avaliar o laço; o equilíbrio vem depois (sua decisão 1) |
| Q-RJ8 | Crédito retroativo de Prata pelas descidas já feitas | (a) sim, 5 por descida até 30; (b) não | **(a)**: você testa a Forja na primeira partida |
| Q-RJ9 | Ferramentas: achadas por marco (1º guardião, fase 3 de Morvath, 1ª Provação) ou num "?" escondido do mapa | (a) marco; (b) sala escondida | **(a)**: simples, sempre alcançável, e a página do Forjador diz o que falta ("vença um guardião") |
| Q-RJ10 | Os Encantos do pacote | cortar Fio Penetrante (é o Dom Onda Atravessante), refazer Corte Sísmico (não há "pesado"), ligar Lâmina Tríplice ao Corte Crescente | **sim** às três |
| Q-RJ11 | NPCs Forjador e Vendedor | quem são no mundo (nada no cânone) | nome de trabalho e só função até você decidir (como o hub, Q-H3) |

### 4.1 Três anjos novos para o MVP (2026-11-21, pedido do Daniel: "uns 7 anjos", inventados; nomes de trabalho)

Mesmas regras da seção 4 (Malahym, mensageiros da luz de Elun, alados como no cânone `canone.md` 476, final "-el",
nenhum nome bíblico real, nada de cruz, sem violeta de Morvath). Cada um traz uma família de Bênçãos nova (a criar
como dado depois que a arte existir; o `balance-designer` mede).

| Família | Nome | Temperamento | Papel mecânico | Benchmark | Forma visual | Símbolo |
|---|---|---|---|---|---|---|
| Véu | **Velael** (do véu que cobre) | discreto, gentil, fala em voz baixa | **enfraquecer**: o inimigo marcado bate menos (Fraqueza), cega por instantes | Afrodite (Weak), Clíona do SWORN | manto cinza-cinza de fumaça com bordas âmbar de entardecer, véu leve sobre os ombros, rosto sereno meio na sombra | véu dobrado em gota |
| Maré | **Galael** (de *gal*, onda) | forte, franco, ri alto | **empurrar**: golpes que arremessam, dano extra contra parede e entre inimigos | Poseidon (Slip, knockback) | azul-marinho profundo com espuma prateada, cabelo e manto em movimento como água | três ondas empilhadas |
| Marca | **Qeshael** (de *qeshet*, arco) | preciso, frio, observa antes de falar | **marcar e criticar**: marca inimigos, crítico nos marcados, bônus no golpe que finaliza | Ártemis (Marked, crítico) | bronze e verde-oliva escuro, arco curto nas costas, olhar fixo | ponta de flecha dentro de um anel |

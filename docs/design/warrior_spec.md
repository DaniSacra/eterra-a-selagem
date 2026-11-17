# O Guerreiro: especificação canônica do primeiro herói

- **Data**: 2026-11-16 (noite). **Autor**: Game Director (sessão principal).
- **Pedido**: correção oficial do Product Owner, "o primeiro herói jogável é o GUERREIRO" (não o Explorador, não o
  Guardião), com a prancha "Bíblia de Arte do Guerreiro de Eterra" (feita por IA, só local em
  `docs/art/ref/warrior_art_bible.png`).
- **Substitui**: `docs/design/guardian_spec.md` como especificação do herói. A auditoria técnica daquele arquivo (seção
  2: reuso, migração, saves, dependências) continua valendo e não é repetida aqui. Tudo o que mudou está na seção 12
  ("O que foi substituído").
- **Continua valendo**: `docs/design/po_directive_guardian.md` (D-50, D-54, D-56 a D-61) e a regra central **Dom define o
  herói. Bênção define a partida. Salmo transforma o poder.**
- **Como ler**: "Hades II" = número ou regra do estudo (`hades2_sistemas.md`, D-39); "nosso" = desenho da casa; todo
  nome é **proposta** até o Daniel aprovar. Número sem medida é ponto de partida, não definitivo.

---

## 1. Conferência no cânone (`../dungeon-rpg/docs/mundo/canone.md`)

O cânone é a fonte de verdade. O que ele diz e onde a prancha ou o pedido divergem dele. **Nada da história foi
mudado**; as divergências viram decisões D-64 a D-69 (seção 13).

| Ponto | O que o cânone diz | O que a prancha ou o pedido dizem | Divergência |
|---|---|---|---|
| "Punho de Elun" | É o título de **Hanokh**, personagem lendário: "o discípulo mais próximo de Elun, o guerreiro mais feroz e fiel", que "enfrentava diversos inimigos de uma só vez" (fonte A, linha 316). A cidade de Hanokh em Imladrin homenageia "Hanokh, o punho de Elun". Eco provável: Pedro, "o mais impetuoso" (suposição do cânone). O cânone de 12/11 também chama Hanokh de "rei fiel na guerra de Elun", fundador da Ordem e **origem da linhagem do leão**; a conciliação está em aberto (`em-aberto.md` item 9) | o Guerreiro é o "Punho de Elun" | **sim (D-64)**. Usar o título no herói de A Selagem diz que ele é Hanokh, ou herdeiro do título dele. Hanokh viveu na guerra contra o Dragão, séculos antes de Valmor. Herdeiro do título não existe no cânone e mexe com a linhagem do leão (só o sangue de Hanokh abre e sela; a Lara e o Aldo são desse sangue, "só o autor sabe") |
| Combate do Guerreiro | o perfil de Hanokh (feroz, fiel, impetuoso, muitos inimigos de uma vez) **combina** com o arquétipo pedido | guerreiro ofensivo, iniciativa, combos, pressão | nenhuma: a identidade de jogo é coerente com o título, seja qual for a decisão do nome |
| Consagração | "Consagrados **à Yah**" pelo Voto de Nazar (guerreiros que não cortam o cabelo, não comem carne vermelha, não bebem) | "consagrado **a Elun**" (texto da prancha) | **sim, pequena (D-65)**. Pela alegoria (Elun é Jesus) não é heresia, mas a fórmula do cânone é "à Yah". O cabelo longo e vermelho combina com o Voto de Nazar |
| Símbolo de Elun | **o leão** é o sinal de Hanokh e de Elun. "Três símbolos que nunca se confundem": leão (Hanokh e Elun), espada erguida (guardiões), olho cortado (Irmandade) | estrela de oito raios dourada como "Elun, a Luz da Aliança"; o mesmo sol no peito e no manto do herói | **sim (D-66)**. A estrela é símbolo novo para Elun e compete com o leão. Proposta: no jogo o herói usa o **leão** (já está nos estandartes, D-34); a estrela fica só como ornamento da luz, sem dizer que é Elun, ou sai |
| "Luz da Aliança", "Espada da Aliança", "Convênio" | Elun é "o Filho da Luz" (título de Ahk). A palavra "Aliança" no cânone é a **Aliança Negra** (Nekaren e Goblins, do lado do mal). Emeth não está no cânone (é do jogo) | Elun "A Luz da Aliança", Emeth "Espada da Aliança", Bênção "Lâmina do Convênio", ultimate "Ciclone da Aliança" | **sim (D-67)**. Epíteto novo para Elun e para a Emeth, e "Aliança" pode confundir com a Aliança Negra |
| Nomes com Elun | "Ninguém cita versículo no jogo, Deus não aparece como personagem"; a fé no mundo e nas escolhas, nunca em sermão | "Fúria de Elun", "Julgamento de Elun", "Magia: amplia o uso da energia de Elun" | **sim (D-68)**. Atribuir fúria, julgamento ou "energia" a Elun em nome de poder de jogo é interpretação nova de Elun. Proposta: nenhum nome de poder com Elun; a luz do herói "vem de cima" (ensinamento de Elun à beira do lago, fonte B) fica implícita |
| Guardião | os **guardiões** são os quatro Juramentados sem o sangue do leão que seguram cada selo; sinal: espada erguida; "os quatro de Valmor do Prólogo são esses guardiões" | o herói deixa de ser "Guardião" | resolvida pela correção: "Guardião" volta a ser só do cânone (e, no jogo, o nome da sala e dos inimigos de minichefe, que ficam) |
| Premissa | 12/11: um paladino do leão por selo e quatro guardiões em volta | `premise` do jogo: "Quatro paladinos descem às catacumbas" | já aberta (D-02, D-48); a correção não a resolve. O texto do jogo não muda até o Daniel decidir |

**Recomendação**: até a D-64, o jogo mostra **"O Guerreiro"** e não mostra "Punho de Elun". O arquétipo e o combate
são os de Hanokh e podem ser construídos já; o título é uma frase de história que o Daniel fecha com o cânone.

---

## 2. Identidade

**Uma frase**: o Guerreiro **toma a iniciativa**: vai até o inimigo, abre o grupo com combos e não para de atacar. Ele
se defende atacando e saindo pela esquiva, nunca esperando. **Ofensivo pela iniciativa e pela esquiva, com o golpe
parado** (E1c, teste do Daniel: "tem que atacar parado"): ele corre até o inimigo, planta os pés, golpeia e só volta a
correr quando o golpe termina; quem o leva até o inimigo são as pernas e a esquiva, nunca o golpe.

- **Arquétipo**: guerreiro ofensivo de espada. **Arma**: a Emeth, sem troca (decisões 9 e 10).
- **Sem bloqueio, sem aparo, sem ficar parado recebendo golpes.** Nenhuma ação, Dom ou ultimate do Guerreiro pede
  esperar o golpe do inimigo. Recompensas de defesa vêm de **entrar** (esquivar para dentro, matar, terminar combos).
- **Percebido no primeiro ataque, sem Dom nem Bênção**: os pés plantam com o golpe e cada golpe tem preparação, impacto
  e retorno; o combo ganha peso a cada golpe (rápido, mais lento, o giro o mais pesado), o giro final abre o grupo (60
  em volta, meia-lua gigante), a esquiva corta qualquer golpe e vira Corte Veloz (o único golpe que leva o corpo, pela
  própria esquiva). O golpe **gira** o corpo para o inimigo mais perto (5 m, arco de 130 graus, sem andar), como o
  Hades II. O avanço magnético da E1b (`lunge_toward`, `LUNGE_MAGNET`, `HeroDef.lunge_standoff`) saiu na E1c.
- **Referências**: Hades II (fluidez, resposta, impacto, números pela D-39); Ravenswatch (herói único, Maestria,
  talentos que mudam as próprias ações); Ember & Blade (apresentação e sensação de poder).
- **Leitura visual** (prancha): cabelo vermelho, cachecol e manto azul-petróleo, Emeth esmeralda, armadura escura com
  ouro velho, a silhueta já aprovada (o modelo `hero_explorer` fica). Toda luz do herói é esmeralda, marfim e ouro velho.

### 2.1 O kit visto pelo Guerreiro (o que muda e o que não muda)
Números do Hades II continuam (D-39). O que muda é a leitura e, em dois pontos, a proposta de apresentação.

| Ação | Hoje | Avaliação para o Guerreiro | Proposta |
|---|---|---|---|
| Ataque (3 golpes: 20, 25, giro 60) | **parado** do aperto ao fim da trava de pernas (E1c), tempos do cajado do Hades II, ver 2.2 | **centro da identidade**: o peso do golpe e o giro que abre | E1c: sem avanço; empurrão dos golpes 1 e 2 menor (2,5 e 3 m/s) para os três acertarem o mesmo alvo parado |
| Especial (seta de luz, 40) | dardo esmeralda a 62,5 m/s, pernas presas 0,71 s (só a esquiva corta), na pose do disparo, nunca correndo | ferramenta de alcance; para um guerreiro de espada lê melhor como **onda da lâmina** que como dardo | **W-1 (D-69)**: mesma regra e números, apresentação de **onda esmeralda curta saindo do corte** (molde `Fx.crescent` em pequeno), não dardo. Custo pequeno (só efeito) |
| Círculo de luz (prende 3 s) | zona de controle | serve ao Guerreiro se for **para combar quem está preso**, não para ficar dentro | sem mudança de número; o texto do Como Jogar e da Bênção falam em "prender para golpear". Os Dons de círculo saem do catálogo inicial (seção 4) |
| Esquiva e Corte Veloz | 5,6 m, 19 quadros protegido, ataque na esquiva vira estocada de 30 | **segundo centro da identidade**: esquivar para dentro | os Dons de Combo e Fúria usam a esquiva para atacar, nunca para fugir |
| Ômegas (lança 160, seta 80, círculo 150) | gastam Magia | o golpe grande que o combo paga | ligados à passiva e à ultimate |

### 2.2 Estados do golpe e janelas (E1c)

Estados (`ComboRunner.Stage`, lidos das fases do `ComboRunner`, sem segunda máquina): **IDLE** (livre) → **PREPARAÇÃO**
(`WINDUP`: antecipação, com o brilho no giro; a direção é ignorada) → **ATAQUE** (`STRIKE`: o passo em que o golpe acerta)
→ **RECUPERAÇÃO** (`RECOVERY`: trava de ataque e trava de pernas; o resto do clipe do golpe tocado ao longo da trava e,
se ele ficar parado, o clipe de volta à guarda, `Slash_A_Rec` e `Slash_B_Rec`; nunca um corte direto para a guarda) →
IDLE. Tempos do cajado do Hades II (`docs/design/hades2_feel_study.md`; dados em `tools/make_data.gd`):

| Golpe | Preparação | Ataque livre depois do acerto (trava de ataque, `recovery`) | Pernas presas depois do acerto (`move_hold`) | Aperto até andar |
|---|---|---|---|---|
| Golpe 1 | 0,08 s | 8 quadros (0,13 s) | 11 quadros (0,18 s) | 0,26 s |
| Golpe 2 | 0,13 s | 13 quadros (0,22 s) | 19 quadros (0,32 s) | 0,45 s |
| Giro | 0,36 s (0,28 + 0,08 de brilho) | 18 quadros (0,30 s) | 30 quadros (0,50 s) | 0,86 s |
| Especial | 0,1 s | 18 quadros (0,30 s) | 0,71 s | 0,81 s |
| Ômega do especial | 0,08 s (depois de 0,65 s segurando) | 0,45 s | 0,71 s | |
| Ômega do ataque | 0,06 s (dentro da carga de 0,8 s) | 0,78 s | 0,78 s | |
| Corte Veloz | 0,06 s (avança 3,2 m) | 14 quadros | 14 quadros | 0,29 s |

Janelas:
- **Próximo golpe (buffer)**: o aperto em qualquer quadro da preparação ou da recuperação fica guardado e sai no fim da
  trava de ataque (cadência: golpe 2 sai 13 quadros depois do 1, o giro 21 depois do 2); depois dela, a janela de
  emendar é 0,4 s (golpes 1 e 2) e 0,6 s (antes do giro); fora dela o aperto começa um combo novo.
- **Andar**: nunca corta o golpe. Só depois da trava de pernas a direção vale de novo; andar então corta o resto do
  clipe de retorno, com mistura de 0,08 s para a corrida. Nenhum quadro de corrida enquanto preso.
- **Esquiva**: corta qualquer estado (preparação, ataque, recuperação, trava de pernas) no quadro do aperto; um golpe
  cortado na preparação não acerta. Ataque apertado na esquiva vira Corte Veloz no fim dela. As travas duras do Hades
  (6, 3 e 9 quadros que nem a esquiva corta) ficaram de fora: a sonda do C12d pede a esquiva em qualquer quadro.
- O giro lê como finalizador: preparação 4,5 vezes a do golpe 1, brilho na lâmina, parada de 70 ms, tranco e meia-lua.
- Sonda: `tools/feel_probe.gd`, metas E1c-P1 a E1c-P6; testes em `tests/test_warrior_strike.gd`.

---

## 3. Passiva e ultimates

### 3.1 Passiva (D-56, aprovada provisória; nome e texto revistos)
- **Regra**: cada finalizador (giro, Corte Veloz que acerta, Ômega) que acerta pelo menos um inimigo devolve **2 de
  Magia**, uma vez por golpe. Número de partida, a validar (D-56).
- **Nome (opções, pendente)**: **Ímpeto da Emeth** / **Fio que Responde** / Brilho da Emeth (o nome antigo serve, mas
  descreve a espada, não o guerreiro).
- **Texto (proposta)**: "Cada combo que você termina devolve Magia à Emeth." Lê como "atacar mais gera golpes maiores",
  sem falar de defesa.

### 3.2 Ultimates (D-54: carga pela Magia gasta nos Ômegas, duas, uma escolhida antes da descida)
Regras comuns em `docs/design/ultimate_u2_proposals.md` seção 1 (ação `ultimate`, ativação 0,3 s protegida que corta o
golpe em curso, `UltCharge`, `UltDef` em `make_data.gd`, golpes da ultimate sem `finisher` nem `omega`).

| | **U-1, dano concentrado** | **U-2, pressão e controle ofensivo** |
|---|---|---|
| Fantasia | um corte descendente enorme da Emeth que racha o chão à frente | um turbilhão esmeralda que suga o grupo e o Guerreiro entra cortando |
| Regra (proposta) | gesto 0,3 s protegido; faixa de **12 x 4 m** à frente (Ômega do ataque tem 13,5 m): **300** no alvo central (faixa de 1,5 m) e **200** no resto da faixa; atordoa os comuns 1 s; tira o dobro da armadura; Morvath leva o dano | a **Voragem** da proposta A: área de 6 m a 4 m à frente por 4 s, tiques de 8 a cada 0,25 s e implosão de 120 em 3 m (248 em quem fica até o fim); espiral para o centro; elites 50%, guardiões 25%, Morvath só lento |
| Por que mudou | a U-1 do Guardião era um círculo em volta do herói ("abrir um grupo"). O pedido é "dano concentrado: grupos **ou** grande impacto em um alvo": a faixa faz as duas coisas e cria a decisão "para onde", que o círculo não tinha | é exatamente o "turbilhão que puxa e explode" da prancha e a recomendação do `gameplay-engineer` |
| Carga | 60 de Magia gasta (Sky Fall, Hades II) | 70 (Moon Water, Hades II) |
| Leitura | aviso de 0,3 s no chão da faixa (o próprio gesto), fenda esmeralda abaixo do glow, sem coluna branca; nunca cobre o herói (`hero_hole`) | véu esmeralda até 0,3 com três braços marfim em espiral e aro de ouro velho; implosão sem coluna |
| Nomes (pendentes, D-68) | Corte do Juízo / Lâmina Descendente / Golpe Fendente (nenhum com Elun) | Voragem / Turbilhão Esmeralda / Espiral da Emeth |
| Destrava | Maestria 2 | Maestria 6 (antes era 10: o Daniel quer desbloqueios que transformam cedo, D-57) |

A Ronda (proposta B do documento) fica de reserva, sem decisão.

**Implementado (E2-08 e E2-10, 2026-11-16, `gameplay-engineer`)**: `Ultimates` (`scripts/game/ultimates.gd`), carga
`UltCharge` (`core/ult_charge.gd`, lê `Magick.spent`; a stat `ult_charge_pct` das Bênçãos e Dons acelera), gesto no
`Player` (`State.ULT`, 0,3 s protegido, corta o golpe como a esquiva, aperto na esquiva ou ferido espera
`DODGE_BUFFER`), formas e arrasto puros no `UltDef` (`cleave_damage`, `vortex_pull`, `pull_share`, `vortex_at`), 5º
losango no HUD, robô usa quando enche e vale (`Ultimates.worth`), `--ultimate=id`, `--ult-full`, `--shot-on=ult`.
Testes em `tests/test_ultimate.gd`; sonda E2-U1 a E2-U3. Decisões tomadas pelas recomendações (anotar no backlog):
- Ação "Ultimate" no texto do jogador (como a descrição do Coração da Emeth já usa); tecla R, controle LB (o único
  botão de ombro livre; os gatilhos são eixos e ficam para o remapeamento de controle).
- Gesto de 0,3 s nas duas (a U-1 antiga tinha 0,35); a carga gasta no começo do gesto; fica de uma sala para a outra.
- Golpes da ultimate: `counts = false`, sem número esmeralda de finalizador, sem quadro de impacto (exceto o de quebra
  de fase do chefe, que é regra do golpe e não da origem), sem câmera lenta; hit slow de finalizador na U-1.
- Voragem: os comuns dentro ficam presos como no círculo (preparo cortado uma vez ao entrar); guardião = não chefe com
  `stun_time` 0. Visual provisório no estilo do círculo de luz em esmeralda com 3 marcas girando e partículas para o
  centro; os braços marfim em espiral e o aro de ouro velho da A.3 ficam para o `environment-artist`/`art-director`.
- U-1: aviso esmeralda da faixa durante o gesto (o estilo de aviso no verde da Emeth, força 0,7) e a fenda
  `ult_rift.gdshader` (pico abaixo do glow pelo `ScreenTone`, `hero_hole`).
- Risco de balanço: a Magia só volta por abate, então na sala de Morvath (sem a carga de antes) a U-1 enche no máximo
  com os 50 de Magia da sala mais os abates do ritual; medir na E6.

---

## 4. Dons: a árvore do Guerreiro (D-58)

### 4.1 Forma
- **Centro comum** (o nó 0, sempre ativo, sem custo): a passiva. Dele saem **quatro ramos**, um por família:
  **COMBO**, **FÚRIA**, **EMETH**, **MAGIA**. As famílias são **desenho de jogo**, não cânone.
- Cada ramo tem três degraus: **entrada** (precisa só do centro), **meio** (precisa da entrada do mesmo ramo), **ápice**
  (precisa do meio e de um Dom de um ramo vizinho). Entre ramos vizinhos há **pontes** (precisam da entrada dos dois).
  Vizinhança: Combo e Fúria, Fúria e Magia, Magia e Emeth, Emeth e Combo (a ordem da prancha, em losango).
- **Destravar** é pela Maestria (um Dom por nível; a ordem da seção 4.4). **Equipar** é antes da descida, pela
  **Devoção** (capacidade 5 + nível de Maestria, custo de 1 a 5 por Dom; Hades II, Arcana). Um pré-requisito só vale se
  estiver **equipado**, não só destravado: escolher o ápice é abrir mão de outros Dons. É aí que a escolha pesa.
- **Um Dom por ação**: o Dom que **troca** o que uma ação faz ocupa a ação (ataque, especial, círculo, esquiva); os que
  só reforçam não ocupam. Toda troca mantém as tags da ação (`light`, `heavy`, `cast`, `dash`, `finisher`, `omega`), para
  as Bênçãos continuarem valendo. Regra testável.
- **Fúria sem barra nova** (D-70): a prancha diz "gera e consome Fúria". Proposta: a família premia ritmo e abates em
  sequência com efeitos de duração curta (cargas que somem em 3 s), **sem** um recurso novo na HUD. Uma barra de Fúria é
  um sistema a mais ao lado da Magia; fica como opção do Daniel.

### 4.2 Conjunto inicial (E2): seis Dons, um efeito claro cada

| # | Ramo, degrau | Nome (opções, pendentes) | Efeito | Custo | O que muda no jogo | Sinergia com Bênçãos | Retorno visual | Teste e balanço |
|---|---|---|---|---|---|---|---|---|
| 1 | Combo, entrada | **Quarto Corte** / Sequência Longa | o combo ganha um 4º golpe, estocada de 30, antes do giro | 3 | combo mais longo, giro mais tarde: escolher entre ritmo e alcance | toda Bênção de `light` vale na estocada (tags) | estocada pálida já existe (`emeth_thrust`) | teste: tags; DPS do combo inteiro dentro de 10% do de hoje (troca, não aumento) |
| 2 | Combo, meio | **Passo Encadeado** / Corte Contínuo | o Corte Veloz conta como o 1º golpe: o próximo ataque é o 2º do combo | 2 | esquivar para dentro vira parte do combo | Bênçãos de esquiva (`passo_*`, `rastro`) | nenhum novo | teste do `ComboRunner`; sonda: aperto não se perde |
| 3 | Fúria, entrada | **Ímpeto** / Sem Recuo | cada abate dá uma carga (até 3, somem em 3 s sem abate): +6% de velocidade de golpe por carga | 2 | premia ir para o próximo inimigo | `brasas`, `estilhaco` (abates em cadeia) | três brasas esmeralda pequenas na lâmina, abaixo do glow | teste das cargas; robô 0,25 em 8 descidas |
| 4 | Fúria, meio | **Avanço Feroz** / Caçada | um abate com finalizador devolve a carga da esquiva na hora | 3 | fecha o laço "mata, avança, mata" | `passos`, `passo_frio` | anel fino no chão ao recuperar a carga | teste; nenhuma esquiva infinita (só finalizador que mata) |
| 5 | Emeth, entrada | **Corte Crescente** (o nome da prancha) / Onda do Giro | o giro solta uma onda esmeralda que corre 6 m à frente, 16 de dano | 3 | o finalizador alcança quem ficou fora | Bênçãos de `heavy` e de finalizador; `onda_maior` | onda no molde do `Fx.crescent`, abaixo do glow | teste; tempo por sala com e sem |
| 6 | Magia, entrada | **Lâmina Faminta** / Fio Pronto | um Ômega começado até 1 s depois de um finalizador que acertou custa metade da Magia | 2 | liga combo e Ômega: termine e solte o grande | todas de `omega`; passiva | brilho do finalizador fica 1 s mais na ponta (`Fx.glint`) | teste; Ômegas por sala antes e depois |

Por que estes: os seis mudam **quando** ou **para onde** se ataca (nenhum é só porcentagem), cobrem as quatro famílias e
as quatro ações de ataque, e quase tudo reusa código (`ComboNode`, `Fx.crescent`, `Magick`). Dons de vida e sustento
ficam fora do conjunto inicial (identidade ofensiva primeiro); continuam no catálogo.

### 4.3 Catálogo planejado (não implementar agora)

| Ramo | Entrada | Meio | Ápice |
|---|---|---|---|
| Combo | Quarto Corte | Passo Encadeado | **Golpe sem Fim**: o giro que acerta 3 ou mais reinicia o combo no 2º golpe (pede uma Fúria) |
| Fúria | Ímpeto | Avanço Feroz | **Fúria Plena**: com 3 cargas de Ímpeto, os finalizadores atordoam os comuns 0,5 s (pede um Combo) |
| Emeth | Corte Crescente | **Fio Longo**: golpes leves alcançam 15% mais | **Onda Atravessante**: a onda do especial atravessa até 3 (pede uma Magia) |
| Magia | Lâmina Faminta | **Reserva**: +20 de Magia máxima | **Coração da Emeth**: a ultimate carrega 25% mais rápido e a passiva devolve 3 (pede uma Emeth) |
| Pontes | Combo e Fúria: **Investida**, o Corte Veloz que mata não gasta a esquiva · Fúria e Magia: **Sangue Quente**, abate com Ômega dá 2 cargas · Magia e Emeth: **Onda Carregada**, Ômega do especial solta a onda do giro · Emeth e Combo: **Fio do Passo**, Corte Veloz solta uma onda curta | | |
| Fora dos ramos (sustento, no centro) | **Firmeza** (+10 de vida e de Magia), **Ainda de Pé** (levanta uma vez com metade da vida), **Respiro** (sala vencida cura 2) | | |

Os Dons do Guardião que eram de defesa parada (Postura, Círculo que Segue, Círculo Largo como Dom) **saem** (seção 12).

### 4.4 Ordem de destravar (Maestria; desbloqueios que transformam primeiro, D-57)
Nível 1: centro (passiva) e **Quarto Corte**. 2: U-1. 3: **Ímpeto**. 4: **Corte Crescente**. 5: **Lâmina Faminta**. 6:
U-2. 7: **Passo Encadeado**. 8: **Avanço Feroz**. 9 em diante: os meios e as pontes, depois os ápices (15, 18, 20) e o
sustento entre eles. Nas primeiras cinco partidas o jogador vê quatro Dons que mudam o combate e as duas ultimates.

---

## 5. Bênçãos (as três cartas; D-50 só texto)
- **Ficam todas as 32** (`data/boons/`), inclusive as de sustento e controle da Vigília (`escudo`, `bastiao`, `consolo`,
  `firmeza`): o Daniel pediu para não eliminar; elas criam builds diferentes. A identidade ofensiva vem do kit e dos Dons.
- **Revisão de texto** (E3): descrições ditas como ataque quando a regra deixa ("Seus golpes de geada..." em vez de "Você
  resiste..."), sem mudar número.
- **Raridades** (D-52, D-53 pendentes): comum, rara, épica, lendária. A prancha mostra exemplos; nomes com Elun e
  "Convênio" não entram (D-67, D-68). Mapeamento das três cartas da prancha para regras que já existem ou cabem em dado:
  "Batida Rápida" (comum, +10% de velocidade do combo: estatística a conferir), "Onda Furiosa" (épica, ataques soltam ondas
  extras: perto de `onda_maior`), "Lâmina Ascendente" (lendária: depois de um Ômega, o próximo combo causa muito dano e
  atordoa). Nomes provisórios.
- **Com Dons**: o Dom troca a ação, a Bênção colore e reforça (fogo, gelo, ouro, Vigília). Elo continua (BUG-017: sem
  raridade e sem nível, como no Hades II).

## 6. Salmos (D-59, D-60; um primeiro, prova de conceito)
- Regra igual (`guardian_spec.md` 11.1): transformam, três grupos de requisito (Dom, Bênção, Elo), raros, sem citar
  versículo, sem número na tela, tema musical original.
- **Revisão para o Guerreiro** (todos transformam algo **ofensivo**, e os de sustento ficam como opção de build):

| Tema (só para nós) | Nome (pendente) | Transforma | Efeito revisto |
|---|---|---|---|
| Sentinela que não dorme (Sl 121) | Salmo da Sentinela | a esquiva | esquivar através de um aviso inimigo deixa o próximo Ômega sem custo **e** o Corte Veloz seguinte é um finalizador |
| A rocha e a fortaleza (Sl 18) | Salmo da Rocha | o giro | golpeando, o Guerreiro não é empurrado; o giro abre uma onda de pedra de 4 m que derruba os comuns |
| A vitória (Sl 20, 98) | Salmo da Vitória (da prancha) | a ultimate | a próxima ultimate depois de 3 finalizadores seguidos sai ampliada (+50% de área) |
| O pastor (Sl 23) | Salmo do Pastor | os abates | abater cura 1 (no máximo 10 por sala), sustento por agressão |
| Refúgio (Sl 91) | Salmo do Refúgio | o Ômega | depois de um Ômega, um véu absorve o próximo golpe (sustento que pede atacar antes) |

- **Prova de conceito recomendada (E4): Salmo da Sentinela.** Transforma duas ações que todo jogador usa (esquiva e
  Ômega), premia entrar no golpe do inimigo (identidade), não depende da ultimate escolhida e os avisos já conhecem o tempo
  (`Ground.last_warn`). Alternativa: Salmo da Vitória, que depende das ultimates (E2). Decisão D-71.

## 7. Plano de arte (a prancha é referência, não asset final)
Sem Meshy nem serviço pago sem autorização. Arte 2D feita por IA só com o Daniel e declarada em `docs/steam-ia.md`.

| # | Peça | Entrega | Quem | Quando | Depende de |
|---|---|---|---|---|---|
| 1 | Retrato e apresentação | medalhão da HUD e retrato da tela do herói a partir da prancha (rosto, cabelo vermelho, cachecol petróleo); o símbolo no peito segue a D-66 | `art-director` (spec), `ui-ux-designer` | E2a | D-64, D-66; fonte da arte (IA com o Daniel ou pintura) |
| 2 | Tela de Maestria | nível em escudo de ouro velho, barra de XP, lista do que o próximo nível dá (molde da prancha) | `ui-ux-designer` | E2a | `HeroDef`, Maestria |
| 3 | Árvore de Dons | losango com centro e quatro ramos, nós com cadeado, painel do Dom com custo de Devoção | `ui-ux-designer`, `art-director` | E2a | seção 4 |
| 4 | Ícones das quatro famílias | Combo (lâminas cruzadas), Fúria (chama), Emeth (cristal), Magia (estrela de luz **sem** ser o símbolo de Elun, D-66) em ouro velho | `art-director`, `ui-ux-designer` | E2a | D-66 |
| 5 | Cartas de Bênção | moldura por raridade (comum metal, rara azul, épica violeta, lendária ouro velho, nunca amarelo vivo); medalhões pintados das outras 29 (ART-012) | `ui-ux-designer`, `art-director` | E3 | D-52 |
| 6 | Cartas e descoberta de Salmo | moldura própria (ouro velho com veio esmeralda), aviso "Salmo descoberto" sem pausar | `ui-ux-designer`, `art-director` | E4 | D-71 |
| 7 | Duas ultimates | fenda descendente e turbilhão, abaixo do glow, sem cobrir o herói, a 1x e 0,25x | `environment-artist`, `art-director` | E2b, E2c | seção 3.2 |
| 8 | VFX de combo, Emeth, Fúria e Magia | onda do giro, cargas de Ímpeto na lâmina, brilho da Lâmina Faminta, especial como onda (W-1) | `environment-artist`, `gameplay-engineer` | E2 | E1 aprovada |
| 9 | Compêndio | lista com "???" e pista, no molde da `MovesScreen` | `ui-ux-designer` | E2c (parte), E4 | D-62 |
| 10 | Eventos de exploração | baú, vendedor, camponês, santuário, altar corrompido: só depois do cânone dizer quem são (D-23, sem personagem novo) | `art-director`, `environment-artist` | E5 | cânone |

## 8. Cuidados técnicos
- **Nada é renomeado por cosmética**: `hero_explorer` (modelo, animações, assados), `Boon`, ids, save, registro,
  `guardian_spec.md` (fica como histórico). O nome técnico do herói em código e save, quando a E2 criar o `HeroDef`, é
  `warrior`; o caminho do modelo continua `hero_explorer` até uma migração segura.
- **Texto do jogador**: "o paladino" do Como Jogar virou "o Guerreiro" (`howto_move_desc`, `howto_cast_desc`). A
  premissa ("Quatro paladinos descem") fica até a D-02/D-48. Nenhum texto mostra "Punho de Elun" até a D-64.
- **"Guardião" não se troca às cegas**: no jogo é a sala e os inimigos de minichefe (`room_miniboss`, `knight`,
  `priest_elder`) e no cânone os quatro Juramentados. Só sai onde quer dizer o herói (documentos).
- **Saves e registro**: nada salvo usa o nome do herói hoje (conferido: `SaveData`, `RunLog`); a E2 cria `heroes.warrior`
  com a migração já planejada (DT-012, DT-015).
- **Testes**: nenhum teste lê "paladino" nem o nome do herói (conferido em `tests/`, `tools/`, `scripts/`).

## 9. Roadmap revisto (E1 a E6 pela prioridade da correção)
| Entrega | O que muda com o Guerreiro |
|---|---|
| **E1** game feel e visual | **sem mudança de escopo**: a E1a (inimigos vivos) está em andamento e é a entrega autorizada. A E1b ganha o **W-1** (especial lido como onda, só efeito, se a D-69 aprovar) e a medida do avanço magnético na sonda, porque "percebido no primeiro ataque" é critério de aceite do Guerreiro |
| **E2** Maestria e Dons | `HeroDef` `warrior`; árvore (seção 4) com os **seis Dons iniciais**; passiva com o nome novo; U-1 em faixa; U-2 Voragem na Maestria 6 |
| **E3** Bênçãos | igual, mais a revisão de texto ofensivo (seção 5) |
| **E4** Salmos | um Salmo (Sentinela recomendado, D-71) |
| **E5** exploração | eventos da prancha só com cânone |
| **E6** balanceamento | igual |

## 10. Critério de aceite do Guerreiro (vale para todas as entregas)
1. Sem Dom nem Bênção, um jogador novo descreve o herói como "vai para cima" depois de uma sala (pergunta do T3 e do T4).
2. Nenhuma ação, Dom, Bênção nova ou ultimate pede esperar o golpe do inimigo.
3. Cada Dom muda quando ou para onde se ataca; nenhum Dom inicial é só porcentagem.
4. Evidência por entrega: vídeo a 1x e 0,25x e as perguntas de game feel, visual e progressão da diretriz.

## 11. Testes previstos
Os da `guardian_spec.md` seção 16, com `test_talents.gd` estendido: pré-requisito só vale equipado, ápice pede vizinho,
ponte pede as duas entradas, um Dom por ação, tags mantidas; `test_ultimate.gd` com a faixa da U-1.

## 12. O que foi substituído (histórico)
| Antes (`guardian_spec.md`) | Agora | Por quê |
|---|---|---|
| Herói "Explorador/Guardião", D-48 | **O Guerreiro**; título "Punho de Elun" pendente (D-64) | correção do PO; Guardião é termo do cânone |
| Identidade "o Guardião segura o chão" | "o Guerreiro toma a iniciativa" | sem esperar, sem bloquear |
| Passiva P-A "Brilho da Emeth" | mesma regra, nomes novos propostos | D-56 aprovada, nome revisto |
| U-1 círculo de 6 m em volta (240) | faixa de 12 x 4 m à frente (300 e 200) | dano concentrado: grupo ou alvo |
| U-2 "Muralha de Luz" defensiva (Maestria 10) | Voragem ofensiva (Maestria 6) | D-54 e o pedido de desbloqueio cedo |
| Catálogo de 20 em cinco linhas (A, S, C, D, O, V) | árvore com centro, quatro famílias, pontes e ápices; seis iniciais | correção do PO |
| Dons de defesa parada (Postura, Círculo que Segue, Círculo Largo) | fora | identidade ofensiva |
| Salmos Sentinela, Abrigo, Pastor, Rocha (4 na E4) | um Salmo primeiro (Sentinela recomendado); efeitos revistos para o ataque | D-59, D-60 e a correção |

## 13. Decisões do Daniel (novas)

**Decididas em 2026-11-16: o Daniel mandou seguir a recomendação de todas (D-64 a D-71).** Ou seja: o jogo mostra só
"O Guerreiro" (o título fica para a história); consagração "à Yah"; leão como símbolo do herói, sol só ornamento; sem
"Aliança" nem "Convênio"; nenhum nome de poder com Elun; especial como onda na E1b; Fúria em cargas sem barra; o primeiro
Salmo é o da Sentinela.

| ID | Pergunta | Opções | Recomendação |
|---|---|---|---|
| D-64 | "Punho de Elun" é o título de Hanokh no cânone. Como o Guerreiro se liga a ele? | (a) o Guerreiro **é** Hanokh (muda a época do jogo: Hanokh é da guerra do Dragão); (b) é **do sangue de Hanokh** e herda o título (toca a linhagem do leão, "só o autor sabe" da Lara e do Aldo); (c) "Punho de Elun" vira título de uma ordem de guerreiros que segue Hanokh (cânone novo); (d) não usar o título no jogo, só "O Guerreiro" | **(d) agora**, e o Daniel escolhe entre (b) e (c) com a história. O combate não depende disso |
| D-65 | "Consagrado a Elun" ou "consagrado à Yah" (fórmula do Voto de Nazar) | (a) a do cânone; (b) a da prancha | **(a)**, se o texto for usado |
| D-66 | O símbolo do herói: o sol de oito raios da prancha ou o leão do cânone | (a) leão (sinal de Hanokh e Elun); (b) sol como ornamento sem dizer Elun; (c) sol como símbolo de Elun (cânone novo) | **(a)** no peito e no manto; o sol pode ser ornamento da luz (b) |
| D-67 | "Aliança", "Luz da Aliança", "Espada da Aliança", "Convênio" | (a) não usar (o cânone tem a Aliança Negra); (b) usar como epíteto novo | **(a)** |
| D-68 | Nomes de poder com Elun ("Fúria de Elun", "Julgamento de Elun") | (a) nenhum; (b) só na ultimate, aprovado um a um | **(a)** |
| D-69 | Especial do Guerreiro como **onda** da lâmina em vez de dardo (mesmos números) | (a) sim, na E1b; (b) como está | **(a)** |
| D-70 | Fúria como barra nova ou como cargas curtas sem barra | (a) cargas (sem HUD nova); (b) barra que enche e se gasta | **(a)** na E2 |
| D-71 | Primeiro Salmo | Sentinela, Vitória, Rocha, Pastor, Refúgio | **Sentinela** |

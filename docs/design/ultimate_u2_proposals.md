# U-2 ofensiva com controle: duas propostas (D-54)

Autor: `gameplay-engineer`, 2026-11-16. Documento de proposta, nada implementado. Nomes **pendentes** (D-55).

Contexto: o Daniel aprovou a carga pela Magia gasta nos Ômegas (regra A, `guardian_spec.md` 6.1) e duas ultimates
desbloqueáveis, uma escolhida antes da descida. A U-1 (o Guardião ergue a Emeth, 240 de dano num círculo de 6 m em volta
dele, 60 de Magia gasta) segue. A U-2 defensiva "Muralha de Luz" foi recusada: "As duas precisam ser ofensivamente
satisfatórias. [...] uma área luminosa que atinge repetidamente os inimigos, altera seu posicionamento e permite ao
Guardião continuar atacando. [...] Eterra é um hack and slash."

Critério das duas propostas abaixo: a ultimate fere de verdade (ordem do Ômega e da U-1), **mexe na posição** dos inimigos
a favor dos golpes do Guardião e **nunca o prende**: depois de um instante de ativação ele tem as quatro ações livres.
Nenhuma reduz dano recebido nem apaga tiros.

## 0. Régua comum

| Referência | Dano | Área | Custo |
|---|---|---|---|
| Ataque 1, 2, giro | 20, 25, 60 | 5,4 m em 150 graus; giro 3 m em volta | |
| Ômega do ataque | 160 | linha de 13,5 m para frente e para trás | 20 de Magia |
| Ômega do círculo | 150 na explosão | 5,4 m | 20 de Magia |
| U-1 | 240 de uma vez | 6 m em volta do Guardião | 60 de Magia gasta |
| Vida dos comuns | esqueleto 60, corredor 45, mago 80, besteiro 130, Escudo 255, sacerdote 290 | | |
| Armadura das elites | 80 (esqueleto) a 330 (Escudo) | | |
| Guardiões | Cavaleiro 450 de vida e 1220 de armadura; Sacerdote ancião 510 e 1450 | | |
| Morvath | 6050 | | |

Carga do Hades II (feitiços de Selene, `guardian_spec.md` 6.1): 50 a 130 de Magia gasta; Night Bloom e Sky Fall 60,
Moon Water 70, Total Eclipse 90. Com a passiva P-A (2 de Magia por finalizador que acerta), 60 de Magia gasta são três
Ômegas do ataque.

Meta das duas: **cerca de 250 de dano da própria ultimate num inimigo que fica a duração inteira** (1,5 Ômega, a ordem da
U-1), mais o que o Guardião bater no grupo enquanto ela dura. A U-1 é dano na hora; a U-2 troca parte do dano imediato
por posição e tempo.

Regras comuns às duas (valem também para a U-1, para não haver dois sistemas):
- **Entrada**: ação nova `ultimate` em `Controls` (teclado, controle, `VirtualPad` do robô e do toque). Losango novo no
  HUD (ui-ux-designer).
- **Ativação**: 0,3 s com proteção (a U-1 tem 0,35). Corta o golpe em curso como a esquiva corta
  (`ComboRunner.can_cancel`); o combo recomeça do golpe 1. Ataque e especial apertados na ativação ficam no buffer
  travado (`locked`) e saem no fim, como na esquiva. Pode ser usada no meio do avanço? Não: espera o avanço acabar
  (buffer de esquiva, `Player.DODGE_BUFFER`), para não somar proteção.
- **Carga** (`UltCharge`, lógica pura em `scripts/core/`): soma a Magia gasta nos Ômegas (ataque, especial, círculo);
  fica pronta no custo; usar zera. A Magia gasta enquanto a ultimate dura já conta para a próxima. Golpes da ultimate
  **não** devolvem Magia, não contam como finalizador para a P-A e não somam ao contador de golpes do HUD
  (`counts = false` no `Combat.hit_enemy`, como os tiques das zonas hoje).
- **Etiquetas**: cada ultimate é lida pelas Bênçãos de **uma** ação (seção de sinergias). Nunca `finisher` nem `omega`
  (sem quadro de impacto, sem P-A). Sempre `ultimate`, para Dons e Salmos futuros.
- **Dado, não código**: `UltDef` (Resource) em `data/ultimates/*.tres`, gerado por uma parte nova `ultimates` do
  `tools/make_data.gd`. Todos os números das tabelas abaixo são campos do `UltDef`.
- **Morvath no ritual** (invulnerável): só faísca, como hoje (`Combat.hit_enemy`, `WARD_SPARK`); os invocados do ritual
  são comuns e sofrem tudo.
- **Paredes e buracos**: todo arrasto passa por `Arena.sweep` (D-28): ninguém atravessa pedra nem cai em buraco; quem
  encosta numa peça fica lá, encostado. `Arena.resolve` no fim do passo, como hoje.
- **Círculo de luz manda sobre o arrasto**: inimigo dentro de uma zona `BIND` não é arrastado (o círculo prende). É uma
  escolha do jogador: segurar ou mover.

---

## Proposta A: a Voragem (área lançada que suga em espiral)

**Nomes (pendentes)**: Voragem de Luz / Espiral da Emeth / Turbilhão Esmeralda.

**Fantasia**: o Guardião crava a luz da Emeth no chão à frente e o bando inteiro é sugado em espiral para um ponto, onde
ele entra cortando.

### A.1 Regra exata

| Item | Valor de partida |
|---|---|
| Onde | ponto a 4 m à frente na mira (mouse: o cursor, até 8 m), preso ao chão (`FloorShape.clamp`, `Arena.walk`). O Guardião não fica preso a ele |
| Raio | 6 m (igual à U-1, para a escolha ser de forma e não de tamanho) |
| Duração | 4 s |
| Tique | a cada 0,25 s (`Ground.TICK`): 8 de dano em quem está dentro (32 por segundo, 128 em 4 s) |
| Implosão no fim | 120 de dano num raio de 3 m do centro; atordoa 0,8 s os comuns sem armadura (`stun_t`); empurrão curto de 2 m/s para fora (só para o corpo "assentar") |
| Total num inimigo que fica até o fim | 248 (1,55 Ômega do ataque; U-1 240) |
| Arrasto radial | para o centro a 3,5 m/s na borda, caindo linearmente até 0 a 1,2 m do centro (o miolo: a separação da `Horde` espalha o bolo em volta, ninguém se sobrepõe) |
| Arrasto tangencial | 2 m/s no sentido da espiral (anti-horário visto de cima), do mesmo jeito a 0 no miolo: o caminho é uma espiral, não uma linha reta |
| Comuns sem armadura | arrastados a 100%; enquanto dentro, sem começar preparo, como o círculo (`stun_t` renovado a cada tique); preparo já começado é cancelado ao entrar. Atiradores dentro não atiram |
| Elites com armadura | arrastadas a 50%; não são seguradas (preparam e golpeiam); tiques e implosão batem na armadura; a implosão tira o dobro da armadura (como a U-1). Armadura quebrada: viram comuns (atordoamento de `Horde.armor_broken`, depois arrastadas a 100%) |
| Guardiões (Cavaleiro, Sacerdote ancião) | arrastados a 25%, nunca segurados; dano normal |
| Morvath | não é arrastado (as faixas, a investida e os padrões dependem de onde ele está); fica lento como no círculo (`slow_t`) e leva tiques e implosão |
| Tiros inimigos em voo | nada (não é escudo) |
| Herói | não é arrastado; anda, golpeia e esquiva livre dentro e fora |

### A.2 Como o Guardião continua atacando
- **Plantado e alcance médio a favor**: o bando chega ao miolo de 1,2 m em cerca de 1,5 s; parado a 2 m do centro, o arco
  de 150 graus e 5,4 m pega o grupo inteiro e o giro de 3 m também. O avanço do golpe (`lunge_toward`) o leva ao bolo.
- **Ômega do ataque**: a lança de 13,5 m atravessa o grupo alinhado; com a espiral, pegar o bolo de lado acerta todos.
- **Círculo de luz**: lançado sobre o bolo depois da sucção, prende (o arrasto para) e o Ômega do círculo explode 150 em
  todos. É a combinação natural: Voragem junta, círculo segura, Ômega explode, a Magia gasta já carrega a próxima.
- **Especial**: a seta (40) e o Ômega do especial (80, atravessa) entram no grupo de longe enquanto ele chega.
- **Esquiva**: livre; o Corte Veloz (30, 8 m) cruza o bolo.
- A decisão que a Voragem cria: **onde** pôr o centro (contra uma parede, perto de um atirador, entre dois grupos). Isso
  a separa da U-1, que é sempre em volta dele.

### A.3 Leitura visual (proposta para o `art-director`)
- **Chão**: véu esmeralda fraco (alfa até 0,3, abaixo do glow) com três braços de fio marfim em espiral girando para dentro
  e aro fino de ouro velho. Molde: o estilo `CIRCLE` do `ground.gdshader` que o círculo de luz já usa (`circle_rim`,
  `circle_marks` girando, `circle_veil`), com dois uniforms novos (`spiral_arms`, `spiral_twist`). Diferente do círculo
  de luz (aro marfim parado com marcas) e longe dos avisos inimigos (miolo vermelho, fio violeta de Morvath).
- **Ar**: partículas marfim alongadas indo para o centro (`chip.gdshader`, `Fx.streak`, `MOTE_STREAK`), até 1,1.
- **Arrastados**: poeira nos pés (a poeira dos avisos do `EnemyFx`), sem pisca.
- **Implosão**: o aro se fecha em 0,15 s, `Fx.ring` para fora, explosão `&"light"` marfim, tranco de finalizador
  (`Fx.kick` 0,32) e tremor curto. **Sem coluna de luz** (nada sobe na frente do herói; se o `art-director` quiser uma,
  passa por `Game.column` com teto e `hero_hole`). Sem câmera lenta (reservada ao último abate).
- **Herói**: o chão é desenhado embaixo dele; o anel do herói e o raio-x continuam lendo. Os avisos inimigos se desenham
  por cima do véu (prioridade de desenho; a Voragem não usa o stencil 2 dos avisos).
- **Som**: receita nova `vortex` (sopro que gira) e `charged` na implosão.

### A.4 Sinergias
Etiquetas: `[ultimate, cast]`. A Voragem é lida pelas **Bênçãos do círculo**:
- `circulo_brasa` (Chama, `burn_dps` 8/12/16 em `cast`): cada tique acende o bolo.
- `circulo_geada` (Geada, `freeze_time` 1/1,4/1,8 em `cast`): congelados continuam sendo arrastados (deslizam no gelo);
  com `estilhaco` (`shatter_pct`), o primeiro golpe do Guardião no bolo congelado estilhaça e espalha dano entre vizinhos
  que estão colados: a combinação mais forte, a medir.
- `circulo_radiante` (Luz, `damage_pct` 0,3/0,45/0,6 em `cast`): sobe tiques e implosão. **O `cast_dps` dela não soma à
  Voragem** (dobraria o tique; é do círculo).
- `circulo_firme` (Vigília, `cast_size_pct` 0,25/0,4/0,55): raio maior, **com teto em 7,5 m** (sem teto chegaria a 9,3 m,
  quase a sala inteira).
- Agem sozinhas e ganham com o bolo: `brasas` e `peso_inverno` (caem no ponto mais denso, `Skills._densest`), `flagelo`
  (atordoa), `firmeza` (a consagração soma lentidão), `estilhaco` (a nova acerta o bolo inteiro), `consolo` (muitos
  abates juntos curam).
- Elos: `vapor` (fogo e gelo no bolo fazem vapor que cega os comuns), `aurora`, `chama_viva` (Luz com fogo).
- **P-A**: o bolo faz o giro e o Ômega acertarem sempre; a P-A paga uma vez por golpe, então o ganho é de ritmo, não de
  multiplicação. A Voragem em si não devolve Magia.

### A.5 Custo de implementação
Já existe: zonas com tique e `on_zone_hit` (`Ground`, `Combat._on_zone_hit`), o segurar do círculo (`stun_t`) e a
lentidão do chefe (`slow_t`), `Horde.in_circle`, `e.push` com o fator de pesado (`0,35`), `Arena.sweep`, `Horde.armor_broken`,
a explosão no fim de zona (`burst`, `Combat.cast_burst`, molde da implosão), `Fx.ring`, `Fx.burst`, `Fx.kick`, `Fx.streak`,
o estilo `CIRCLE` do chão.

Código novo:
1. `UltCharge` (core, puro) e `UltDef` (Resource) com a parte `ultimates` do `make_data.gd`: comum à U-1.
2. Ação `ultimate` em `Controls`, no `Player` (ativação, proteção, corte do golpe) e no robô (`Bot`: usar quando há 3 ou
   mais inimigos num raio de 6 m do ponto).
3. `Ground.Kind.VORTEX` com os campos do arrasto; o tique usa o caminho do `BIND` com o dano e as etiquetas da Voragem.
4. **Arrasto contínuo** (o `e.push` decai 7 por segundo e daria solavancos se posto só no tique): campo `Enemy.drag`
   (velocidade imposta) zerado a cada passo, somado ao andar do inimigo e varrido por `Arena.sweep` na `Horde`. A conta
   do vetor fica em lógica pura (`DragField.velocity(pos, center, radius, core, radial, tangential, factor)`), reaproveitada
   pela proposta B.
5. Dois uniforms da espiral no `ground.gdshader` (trabalho do `art-director`/`environment-artist` na revisão).
Estimativa: média. A maior parte é o comum às duas ultimates (itens 1 e 2).

### A.6 Riscos
- **Legibilidade**: um bolo de 6 a 8 corpos colados esconde quem vai golpear. Atenuantes: os comuns ficam sem preparo
  enquanto dentro; só elites e guardiões preparam, e os avisos deles ficam por cima do véu. Medir com captura de bolo
  com uma elite dentro.
- **Balanço**: juntar multiplica todo golpe de área (giro, Ômega, círculo, Bênçãos que caem no mais denso). Em sala
  comum (4 a 8 inimigos) a Voragem pode decidir a sala sozinha. Atenuantes: custo 70, só 4 s, raio com teto.
- **Ritual de Morvath**: juntar os 4 mortos do ritual encurta a fase 2. É o que um jogador hábil deveria conseguir; medir
  `phase_time` da fase 2 no `RESULT` com e sem Voragem.
- **Encostados em pedra**: puxados contra um obelisco, ficam presos atrás dele até o fim (o raio-x mostra o herói, mas
  o golpe pode não passar). Aceitável; o centro é escolhido pelo jogador.

### A.7 Custo de carga
**70 de Magia gasta** (o Moon Water do Hades II): 10 a mais que a U-1, porque além do dano ela segura os comuns por 4 s
e junta tudo para o resto do kit. Três Ômegas e meio.

---

## Proposta B: a Ronda (lâminas de luz em volta do Guardião que arrastam o bando com ele)

**Nomes (pendentes)**: Ronda das Lâminas / Roda da Emeth / Cortejo da Emeth.

**Fantasia**: seis lâminas de luz da Emeth giram em volta do Guardião, cortando sem parar e arrastando o bando num
carrossel que anda para onde ele anda, sempre na distância da espada.

### B.1 Regra exata

| Item | Valor de partida |
|---|---|
| Onde | presa ao Guardião (anda, corre e esquiva com ele) |
| Campo | 7 m em volta dele: quem entra é capturado |
| Anel das lâminas | 2,8 m (dentro do giro de 3 m e do arco de 5,4 m) |
| Lâminas | 6, uma volta a cada 1,2 s, a 1 m de altura |
| Duração | 6 s |
| Dano das lâminas | 7 por toque, cada inimigo no máximo uma vez a cada 0,25 s (28 por segundo, 168 em 6 s) |
| Fim | as 6 lâminas voam para fora pelos raios como a onda da `onda_maior` (`Projectiles.Kind.BLADE`, `fire_wave`): 40 cada, 10 m |
| Total num inimigo que fica até o fim | cerca de 208 (168 mais uma lâmina final; a U-1 dá 240 na hora). Menos dano próprio que a A, porque dura mais e anda com ele |
| Arrasto | fora do anel, puxado para ele a 4 m/s; dentro, empurrado para ele a 3 m/s (ninguém cola no corpo do herói); tangencial 2,5 m/s no sentido das lâminas. O bando gira em volta dele a 2,8 m e passa pelo arco da frente sem parar |
| Teto de captura | 8 inimigos (os mais perto). Os demais só levam o toque das lâminas se passarem nelas. Evita a bolha que segura a sala inteira |
| Comuns sem armadura | arrastados a 100%; ao serem capturados perdem o preparo em curso e ficam 1 s sem começar outro; **depois voltam a atacar** enquanto giram (o golpe sai na direção em que miraram, que já andou: erram mais, mas podem acertar). Atiradores capturados não atiram nesse 1 s |
| Elites com armadura | arrastadas a 50%, sem perder preparo; dano normal na armadura |
| Guardiões | arrastados a 25%, sem perder preparo |
| Morvath | não é arrastado; lento enquanto as lâminas passam (`slow_t`); leva os toques |
| Correr e esquivar | o arrasto tem velocidade máxima (4 m/s radial), então a corrida (11,13 m/s) e a esquiva (5,6 m em 0,2 s) deixam o bando para trás: quem fica a mais de 7 m é solto. Andar (6,75 m/s) leva o bando junto, atrasado |

### B.2 Como o Guardião continua atacando
- **O bando passa pela lâmina dele**: a 2,8 m girando a cerca de 50 graus por segundo, cada golpe do combo encontra um
  inimigo novo na frente; o giro (3 m) acerta o anel inteiro de uma vez.
- **Ômega do ataque**: a lança vai para frente e para trás; com o anel em volta, acerta os dois lados do carrossel.
- **Ir buscar**: o campo de 7 m anda com ele; andar até um besteiro ou um mago o captura e o traz para o anel. É a
  ultimate que caça atiradores.
- **Esquiva**: livre; esquivar para fora solta quem estava atrás, esquivar para dentro de outro grupo captura de novo
  (até o teto de 8).
- **Círculo**: quem está no círculo para de girar (o círculo manda); útil para segurar um pedaço do anel na frente dele.
- **Especial**: livre; a seta de 11 m pega quem ainda está sendo puxado.

### B.3 Leitura visual (proposta para o `art-director`)
- **Lâminas**: seis lascas de cristal esmeralda com miolo de ouro velho (molde do `emeth_dart.gdshader`, `vein_*`), num
  MultiMesh, abaixo do glow (até 1,0), com rastro fino da fita do corte (`slash.gdshader` com `blade` 0, alfa baixo).
- **Chão**: só um aro pontilhado fino de ouro velho a 2,8 m (não marfim nem petróleo, para não se confundir com o anel do
  herói, `hero_ring.gdshader`); a borda do campo de 7 m aparece só nos primeiros 0,3 s.
- **Não cobrir o herói**: as lâminas passam a 2,8 m, fora do corpo; quando uma passa entre ele e a câmera, ela apaga em
  volta dele (o `hero_hole` com o global `hero_pos`, como a coluna de luz já faz).
- **Arrastados**: poeira nos pés; nada de pisca extra (os toques usam o clarão normal de 0,05 s).
- **Fim**: as lâminas saem pelos raios com a cor da Emeth; tranco de finalizador.
- **Som**: zumbido de lâminas girando (receita nova) e `blade_spin` no fim.

### B.4 Sinergias
Etiquetas: `[ultimate, light]`. A Ronda é lida pelas **Bênçãos do ataque**:
- `golpe_brasa` (`burn_dps` 4/6/8 em `light`): o anel inteiro queima.
- `golpe_geada` (`freeze_time` 0,3/0,45/0,6 em `light`): a 4 toques por segundo, congela quase sem parar; congelados
  seguem girando. Com `estilhaco`, o golpe do Guardião estilhaça e espalha no anel. **Risco alto**: talvez a geada só
  pegue uma vez por inimigo a cada 1 s na Ronda.
- `golpe_radiante` (`damage_pct` 0,25 a 0,55 em `light`): toques e lâminas finais.
- `golpe_firme` (`reach_pct` 0,12 a 0,25 em `light`): anel e campo maiores (2,8 vira até 3,5 m; o campo até 8,75 m).
- Agem sozinhas: `redemoinho` (as órbitas de fogo somam às lâminas; **conflito visual**, ver riscos), `flagelo`,
  `onda_maior` (o leque da Luz soma à saída das lâminas), `consolo`.
- Vigília: `passos` (`dodge_charges`, `move_speed_pct`): mais cargas de esquiva = mais controle de quem solta e quem
  pega. Elos: `rastro` (brasas da esquiva dentro do anel), `passo_frio` (gelo na esquiva), `chama_viva`.
- **P-A**: cada giro que acerta o anel paga 2 de Magia; o ritmo de finalizadores sobe porque sempre há alguém na frente.

### B.5 Custo de implementação
Já existe: o `ORBIT` do `Skills` (órbitas em volta do herói, toque por raio, `_step_orbit`), o leque `FAN`
(`Projectiles.fire_wave`, `Kind.BLADE`) para a saída, `Horde.in_circle`, o segurar curto (`stun_t`), `slow_t`, o fator de
pesado, `Arena.sweep`, o `hero_hole` da coluna.

Código novo:
1. O comum da seção 0 (`UltCharge`, `UltDef`, ação `ultimate`, ativação, robô).
2. O arrasto contínuo (`Enemy.drag`, `DragField`, igual ao da A), com alvo no anel e não no centro, e velocidade máxima.
3. A captura com teto de 8, a soltura a mais de 7 m e o atraso de 1 s dos comuns capturados.
4. Cadência por inimigo (uma vez a cada 0,25 s, de qualquer lâmina): um dicionário por inimigo, não o tique fixo do
   `ORBIT` de hoje.
5. As seis lâminas desenhadas (MultiMesh novo com o material do dardo) e o aro pontilhado no chão.
Estimativa: média para alta. Mais código próprio que a A (a zona que segue o herói, a captura e o desenho das lâminas
não existem).

### B.6 Riscos
- **Legibilidade (o maior)**: herói, seis lâminas, até oito corpos girando, os cortes dele e os avisos de elites, tudo num
  raio de 3 m em volta dele. É o oposto do pedido do ciclo 8 (poucos inimigos, cada um lido). Os avisos de quem gira
  também giram, difíceis de ler.
- **Vira bolha**: comuns presos em volta dele são uma proteção disfarçada, o que o Daniel recusou. O teto de 8, a volta
  ao ataque depois de 1 s e as elites livres atenuam, mas o efeito pode ser lido como "ficar dentro da proteção".
- **Repete a U-1**: as duas giram em volta do Guardião; a escolha entre elas fica menos clara.
- **Conflito com `redemoinho`**: a Bênção de Chama já é "coisas girando em volta dele" (esferas de fogo a 3 a 3,6 m).
- **Tontura**: um carrossel na tela por 6 s, com a câmera seguindo o herói, pode cansar a vista.
- **Balanço**: com `golpe_geada`, o anel inteiro fica congelado o tempo todo.

### B.7 Custo de carga
**60 de Magia gasta** (Night Bloom e Sky Fall do Hades II), igual à U-1: menos dano próprio e o controle solta sozinho.

---

## Comparação rápida

| | U-1 (segue) | A, Voragem | B, Ronda |
|---|---|---|---|
| Forma | em volta dele, na hora | ponto escolhido, 4 s | presa a ele, 6 s |
| Dano próprio (inimigo que fica) | 240 | 248 | cerca de 208 |
| Mexe na posição | não (atordoa) | junta num ponto em espiral | gira em volta dele a 2,8 m |
| Decisão que cria | quando | onde | para onde andar |
| Bênçãos que a leem | (a definir) | do círculo (`cast`) | do ataque (`light`) |
| Custo | 60 | 70 | 60 |
| Código próprio | pequeno | médio | médio a alto |
| Risco de leitura | baixo | médio | alto |

## Testes GUT previstos

Comuns às duas (`tests/test_ultimate.gd`):
- `UltCharge`: soma só a Magia gasta nos Ômegas (ataque, especial, círculo); fica pronta no custo do `UltDef`; usar zera;
  Magia gasta durante a ultimate conta para a próxima; a devolução da P-A não conta como gasto.
- Golpes da ultimate não devolvem Magia, não contam para a P-A nem para o contador de golpes; nunca levam `finisher` nem
  `omega` (sem quadro de impacto).
- Ativação: 0,3 s protegido, corta o golpe em curso, ataque apertado na ativação sai no fim; com o avanço em curso, espera.
- `DragField.velocity`: zero no miolo (A) ou no anel (B), aponta para dentro fora e para fora dentro (B), componente
  tangencial no sentido certo, fator 0,5 para elite com armadura, 0,25 para guardião, 0 para Morvath, teto de velocidade.
- Arrasto numa cena real em cada arena e variante: 200 pontos de partida, ninguém termina dentro de pedra
  (`Arena.overlaps`) nem fora do chão (`Arena.walk`, buracos).
- Morvath nunca se move pelo arrasto; no ritual (invulnerável) só faísca, sem número nem queimadura.
- O círculo de luz manda: inimigo dentro de `BIND` não se move pelo arrasto.

Da A (`tests/test_ult_vortex.gd`): esqueleto a 5,5 m chega a menos de 2 m do centro em até 2 s; comum dentro não começa
preparo; elite com armadura prepara e golpeia; implosão tira o dobro da armadura e atordoa só comuns sem armadura; tiques
somam 128 em 4 s sem Bênçãos; `circulo_firme` respeita o teto de 7,5 m; `cast_dps` de `circulo_radiante` não entra.

Da B (`tests/test_ult_ronda.gd`): capturados vão para 2,8 m e giram; no máximo 8 capturados; quem fica a mais de 7 m é
solto (correr solta, andar leva); cada inimigo leva no máximo um toque a cada 0,25 s; comum capturado volta a preparar
depois de 1 s; as seis lâminas finais saem pelos raios.

Smoke: `tools/smoke.sh 300 --seed=5` com o robô usando a ultimate (chega em Morvath, `RESULT` com usos e dano da
ultimate) e `tools/smoke.sh 120 --start=boss --boons=25 --seed=5` (fase 2: `phase_time` com e sem).

## Recomendação

**A Voragem (proposta A).** Motivos:
1. **É o pedido do Daniel ao pé da letra**: uma área de luz que acerta várias vezes, muda a posição dos inimigos e deixa o
   Guardião atacando; o herói não fica dentro dela parado, ele a lança e entra no bolo.
2. **Diferente da U-1 de verdade**: a U-1 é "em volta de mim, agora"; a Voragem é "ali, daqui a pouco, todos juntos". A
   escolha antes da descida vira uma escolha de estilo (explodir ou montar a jogada), não de tamanho.
3. **Casa com a identidade "segura o chão"** e com o kit: junta para o giro, o Ômega e o círculo; o laço Voragem, círculo,
   Ômega do círculo, Magia gasta, próxima Voragem é o laço da regra A com a P-A.
4. **Menor risco de leitura e de virar bolha**: o centro é longe do herói, os avisos de elites ficam por cima de um véu
   fraco, e nada gira em volta do corpo dele.
5. **Menor custo**: reaproveita o `BIND` (tique, segurar, lentidão do chefe), a explosão no fim de zona e o estilo de
   chão do círculo; o código novo (carga, entrada, arrasto) é quase todo comum às duas ultimates.

A Ronda fica como reserva: ela é a fantasia mais "poderosa" na tela, mas repete o "em volta dele" da U-1, briga com a
`redemoinho` e arrisca a legibilidade que os ciclos 8 a 10 conquistaram. Uma ideia para depois, sem decisão: a Ronda pode
virar a transformação de um Salmo sobre a Voragem (a Voragem que segue o Guardião), quando a E4 chegar.

Números para medir antes de fechar: custo 70 da A contra 60 da U-1 (usos por partida no `RESULT`), o teto do raio com
`circulo_firme`, e se a A decide salas comuns sozinha (tempo por sala com e sem).

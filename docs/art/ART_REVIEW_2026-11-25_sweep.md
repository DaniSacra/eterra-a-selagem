# Revisão de arte, pente fino de 2026-11-25 (depois das fases 1 a 5 do Plano SWORN)

Revisor: art-director. Capturas reais na GPU (Forward+, estilizado, câmera Perto, 1672x941), nenhuma gerada por IA.
Abreviações: `S/` = `docs/gallery/cycle_2026-11-25_sweep/`, `S4/` = `..._sworn4/`, `S3/` = `..._sworn3/`, `S1/` = `..._sworn1/`.
Prioridade: P0 quebra, P1 feio ou ilegível, P2 polimento. Nada aqui foi medido com `frame_stats.py`; são observações de
olho, com a captura de cada uma. Não há código alterado.

## Já conhecidos (conferência)

| Item | Veredito | Captura |
|---|---|---|
| Obelisco do Salão na frente da base do anel da chegada | **Confirmado.** O pedestal em degraus fica logo abaixo do anel na tela e cobre a borda de baixo do anel e o pé do facho; o herói nasce atrás dele | `S3/chegada_v2.png` (quadros 2 a 4), `S/first_00.png` |
| Cristais verde chapado | **Confirmado.** Na chegada são pirâmides de um verde só, sem aresta acesa; no Jardim (sala 8) os cristais da raiz são ciano-verde chapado, sem o `crystal_edge` | `S3/chegada_v2.png`, `S/run_09.png`, `S/run_10.png` |
| `--vine-zoom=vida` abrindo na Espada | **Confirmado** (se a captura foi pedida com `vida`): o título diz "A Espada" e o painel diz "Perseverança · 2ª raiz" com raízes de colheita. Título e painel discordam entre si, o que também é defeito no jogo se a Espada não for a figura da Perseverança | `S4/vine_zoom.png` |
| Dica do rodapé da tela de Bênção encostando a 720 | **Confirmado.** A 720 o rodapé fica a cerca de 19 px da carta de baixo e em cima da barra de ações apagada; a 1080 o texto passa por cima dos rótulos fantasmas "Shift" e "Espaço" da barra | `S4/bless_1280x720.png`, `S4/bless_1920x1080.png` |

## Lista priorizada

### P0

1. **A "descida guiada" não aparece nas capturas.** Os 12 quadros `first_00` a `first_11` (4 minutos) mostram o herói
   parado na Antessala, relógio em 0:00, sem dica nenhuma na tela. Duas leituras: a captura rodou sem o robô (e então a
   evidência da fase 3 não existe), ou a Antessala não mostra a primeira dica a quem não se mexe. Deve ser: dica de
   movimento visível nos primeiros segundos e a sequência chegada, Antessala, primeira porta registrada em quadros.
   Provável: `scripts/core/first_tips.gd`, o fluxo da primeira vez e a opção de captura. Dono: `gameplay-engineer`
   (conferir), `ui-ux-designer` (dica). Recapturar antes de pedir teste ao Daniel.

### P1

2. **Retângulos escuros translúcidos flutuando no ar** na ponte da sala 12 (um atrás do número "18", outros perto da
   cascata). Parecem quads de neblina ou de oclusão sem textura. Deve ser: invisível, ou névoa com borda suave.
   `S/run_18.png`. Provável: cartões de névoa ou cascata do bioma da ponte (`art_rooms`). Dono: `technical-artist`.
3. **Fundo além da sala em cinza-azulado claro e liso** (sala 5, sala 10, borda da sala 6): a regra diz "mais escuro que o
   chão, nunca cinza liso". Na sala 8 o vazio é um plano verde-oliva aceso; na sala 6 e 11 são lascas brancas de pedra.
   Deve ser: vazio escuro no matiz do ar da sala, com profundidade (gradiente para baixo). `S/run_06.png`, `S/run_15.png`,
   `S/run_16.png`, `S/run_09.png`, `S/run_07.png`, `S/run_17.png`. Provável: o vazio/abismo por bioma (`art_rooms.md`, "vazio").
   Dono: `environment-artist`.
4. **Medalhões das portas grandes demais e encavalados.** Dois medalhões de cerca de 200 px se sobrepõem (aro de um sobre
   o outro), o rótulo do primeiro passa por baixo do segundo, e o selo de dificuldade fica no meio dos dois. No
   `medalhao_v2` o selo é um **disco preto vazio** (ícone faltando). Na Provação o nome aparece duas vezes ("Provação"
   no medalhão e no rótulo) e o medalhão sai pelo topo da tela. Deve ser: medalhões a no mínimo 24 px um do outro,
   selo sempre com glifo (ou sem selo), rótulo abaixo do próprio medalhão sem tocar o vizinho, nada cortado na borda.
   `S1/medalhao_v2.png`, `S/run_02.png`, `S/run_07.png`, `S/run_17.png`, `S1/capitao.png` (quadro 8). Provável: medalhão
   da porta (`door` / `RewardShaft`) e o selo de risco. Dono: `ui-ux-designer` (rótulo e selo), `environment-artist` (escala
   e posição no mundo).
5. **Rosa-magenta fora da paleta.** O halo da porta "Mais Vida" é rosa saturado; os projéteis do Sacerdote e dos
   conjuradores de Morvath são anéis magenta com miolo preto. A regra: "rosa só da maldição", violeta só de Morvath
   (253 a 265). Magenta (cerca de 320) não tem dono e briga com o vermelho do perigo. Deve ser: Mais Vida no esmalte da
   família (vermelho-coração apagado, sem halo rosa); projéteis inimigos no violeta de Morvath ou no verde espectral
   conforme a origem, com forma de projétil (não "rosca"). `S/run_02.png`, `S/run_07.png`, `S/run_08.png`,
   `S/run_14.png`, `S/run_23.png`. Provável: cor do esmalte da recompensa e o material do projétil inimigo
   (`enemy_shots` / `boss.gd`). Dono: `technical-artist`; registrar o dono da cor em `art_direction.md` 2.1 depois.
6. **Quadrado vermelho chapado no chão** (sala 5, Cavaleiro), sem borda nem preenchimento progressivo, parece quad de
   depuração. Se for o aviso da investida, falta o desenho da faixa (o mesmo aviso na sala 7 e no `capitao` é faixa com
   gradiente e lê bem). `S/run_06.png`. Provável: aviso do Cavaleiro em `ground_look.gd`. Dono: `technical-artist`.
7. **Avisos e herói tapados pela mureta da frente.** Na sala 4 o círculo vermelho de aviso e as pernas do herói ficam
   atrás da balaustrada mais perto da câmera; na sala 12 inimigos ficam atrás dos ícones do HUD (Salmo, moedas). Deve
   ser: aviso desenhado por cima da geometria de borda (ou a mureta some/fica translúcida como o raio-x) e nenhum
   inimigo ativo atrás do HUD. `S/run_04.png`, `S/run_14.png`, `S/run_18.png`. Provável: ordem de desenho do aviso
   (`ground_look.gd`) e a margem de câmera. Dono: `technical-artist`.
8. **Peças que parecem provisórias**: (a) a gaiola de arame dourado da sala 9 (linhas finas sem volume, lê como
   gizmo); (b) as lajes claras em xadrez da mesma sala (clareiras brancas demais, luma alta); (c) os pilares com riscas
   brancas verticais; (d) a água da sala 8 (preto com rabiscos brancos); (e) o Cavaleiro como mancha marrom sem leitura de
   armadura; (f) os "cotocos" de vela cor de areia chapados das salas 1 e Antessala. `S/run_11.png`, `S/run_12.png`,
   `S/run_13.png`, `S/run_09.png`, `S/run_05.png`, `S/run_00.png`. Dono: `environment-artist` (a, b, c, d, f);
   (e) depende de modelo (Meshy, autorização do Daniel).
9. **Orbes de fogo do "Redemoinho de Fogo" como pílulas laranja chapadas**, sem brilho nem rastro, parecem cápsulas de
   depuração soltas no chão (aparecem em quase toda luta depois da sala 2). Deve ser: brasa com rastro curto e núcleo
   âmbar, abaixo do limiar de glow (`vfx_pass_spec.md` 5.3 já pede isso). `S/run_17.png`, `S/run_18.png`,
   `S/run_19.png`, `S/run_21.png`, `S1/ratos_de_osso.png`. Arquivo: `scripts/game/skills.gd` (`_step_orbit`,
   `ORB_EMBER`, material sem sombreamento). Dono: `technical-artist`.
10. **Dons: "Vagas 6 de 6" contra "Vagas 3, livres 6".** O topo lê como "cheio" e o painel diz "livres 6". O rótulo
    "Maestria 11" cobre o nó 2, e "COMBO" passa por cima do cabelo do retrato. Deve ser: "Vagas livres 6 de 6" (ou
    "usadas 0 de 6"), rótulo flutuante fora dos nós, título do setor fora do rosto. `S4/dons.png`. Dono: `ui-ux-designer`.
11. **Título e aviso do salão do Cavaleiro em cima da cena**: "Salão do Cavaleiro" e "Cavaleiro esqueleto entrou nas
    catacumbas" ficam sobre o próprio Cavaleiro, logo abaixo da barra de vida, com o estandarte cortando "Sala 5 de 14".
    E a frase diz que ele "entrou nas catacumbas" quando o herói é quem entra no salão dele. `S/run_05.png`. Dono:
    `ui-ux-designer` (posição e texto, pelo Game Director).
12. **Interface da chegada sem ponto de vista**: o rótulo da porta fora da tela ("Bênção / Sarael") sai cortado na
    borda direita, sem a seta inteira. `S/first_00.png`, `S1/capitao.png` (quadro 6, "Mai..."). Dono: `ui-ux-designer`.

### P2

13. Número de dano empilhado (15 sobre 60, 36 sobre 13) e por cima do "!" de aviso. `S/run_12.png`, `S/run_23.png`,
    `S1/capitao.png`. Dono: `ui-ux-designer`.
14. Tela de Bênção: "0,8 / s." quebra a linha e deixa "s." sozinho (as duas resoluções). Usar espaço inquebrável entre
    número e unidade. `S4/bless_*.png`. Dono: `ui-ux-designer`.
15. Videira: o rosto do Leão é um emoji (dois traços e um triângulo); o Cálice em violeta usa a cor de Morvath; as plaquinhas
    de pergaminho bege caem em cima da linha da constelação ("Colheita Farta" sobre a lâmina); "Raízes crescidas" solto
    no canto; o botão repete "Enter" que o rodapé já diz. `S4/vine.png`, `S4/vine_zoom.png`. Dono: `ui-ux-designer`.
16. Bloco de primeiro plano grande no meio de baixo (pedestal da sala 1 e da Antessala, braseiro da sala 6) cobre chão
    andável e encosta na barra de ações. `S/run_00.png`, `S/run_07.png`, `S/run_17.png`. Dono: `environment-artist`.
17. Sala 4 com o ar violeta saturado (o violeta é de Morvath); conferir com `frame_stats.py` contra o limite de 5%.
    `S/run_04.png`. Dono: `environment-artist`.
18. Cabelo do herói com contorno branco serrilhado parado na Antessala (luz de borda ou raio-x ligado sem oclusor).
    `S/first_00.png`. Dono: `technical-artist`.
19. Facho da chegada como cilindro laranja liso, sem gradiente nem poeira. `S3/chegada_v2.png`. Dono: `technical-artist`.
20. Título com cruzes (clérigo e estandarte): já é a Q-07, espera arte nova do Daniel. `S/title.png`. Sem dono até ele decidir.
21. `run_03.png` é tela preta: captura caiu na troca de sala (sala montada no preto). Não é defeito do jogo; a próxima
    varredura deve pular quadros de transição.

## O que está bom (não mexer)

- Herói legível em todas as salas: cabelo, cachecol e Emeth; anel petróleo sempre visível; raio-x atrás de pilar funciona
  (`S/run_11.png`, `S/run_13.png`).
- Runas âmbar da sala 9 seguem a gramática SW-G7 (`S/run_13.png`).
- Faixa de investida com gradiente e linha de mira do atirador leem bem (`S/run_08.png`, `S/run_09.png`).
- Câmara do Selo: leão no chão, escudo esmeralda corrompido, colunas espectrais, barra de fase "Derrube os mortos"
  (`S/run_20.png` a `S/run_23.png`).
- Tela de Bênção: hierarquia clara, palavra-chave colorida e quadro de habilidades ao lado; Livro de Ahk limpo (`S/book.png`).

## Depende de modelo que não existe

Cavaleiro (forma marrom), Sacerdote Ancião, cristais finais, arte do título sem cruzes. Nada disso foi pedido ao Meshy.

## Veredito

Não aprovado para teste do Daniel ainda: o item 1 (descida guiada sem evidência) precisa de recaptura, e os itens 2 a 7
são visíveis em quase toda partida. Depois deles, uma varredura nova (mesmas sementes) para eu reconferir.

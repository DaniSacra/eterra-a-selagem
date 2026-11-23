# Salão do Cavaleiro (`knight_hall`), plano de cena (2026-11-23)

Look: `GuardianLook`, variante `&"armory"` (`scripts/game/guardian_look.gd`), id de look em `data/stages/catacombs.tres`.
Geometria de jogo inalterada (chão, obstáculos, portas, spawns, perigos: `tools/make_data.gd` `_knight_hall`).

## Vista de cima (metros; x para a direita, z para baixo; N é o fundo da imagem)

```
 z=-11  NW +--[alc][alc][alc]--[B]=(porta N x=4.3)=[B]----+ cortado NE (2.5 m)
        |  rack arm. rack   galeria x -10.2..0.2        / (parede alta diagonal)
        |  [pedras+placa NW]        [placa NE x8.4,z-5.6]
 z=0    (entrada oeste: arco, 6 degraus, braseiros z=+-3.6)   meio livre (investida)   -> porta L (x=11,z=0)
        |  alc.(z=-7.6)                 boss (7.5,0)
        |  [pedras+placa SW]  [placa S x3.6,z8]  [pedras+placa SE]
 z=+11  SW +---------------------- porta S (x=1) ---------+ SE   (paredes S e L baixas, cortadas a 0,8 m)
        x=-11                                          x=+11
```
- Salão 22 x 22 m, canto NE cortado em 2.5 m. Paredes altas (7,6 m) ao norte, oeste e no corte NE; sul e leste baixas.
- Quatro cantos: pedras da abóbada (zonas 3,8 x 3,8 m) e uma placa de espinhos de 2,4 m ao lado (a peça de `HazardPiece.grate`, grade de ferro com pontas).
- Meio livre: nada desenhado no chão fora dos cantos.

## Essencial (lê como sala e ajuda o combate)
- Nichos no norte (x -8.6, -5.4, -2.2) e no oeste (z -7.6, +7.6): rack de armas, manequim de armadura com escudo; piso do nicho a 0,2 m.
- Galeria elevada sobre os nichos do norte (laje a 3,75 m, balaustrada, mísulas), tudo acima de 2,6 m ou atrás da borda.
- Braseiros quentes: os dois do layout (x=1.5 e 7.1, recuados na parede) e dois na entrada (z=+-3.6), contra a pedra azul acinzentada.
- Estandartes do leão (norte x -8.6, -5.4, -2.2, 1.5, 7.1; oeste z -3.6, 3.6), topo a 7,3 m.
- Pontas de ferro nos pés das paredes dos 4 cantos (moldura de perigo, ferro cinza, nunca vermelho).
- Arco da entrada oeste com soleira de ouro velho fina (único toque de ouro).

## Só clima (pode cair se pesar)
- Luz quente de cada nicho norte (sem sombra), pedras caídas fora das paredes baixas, o corte NE alto.

## Paleta e luz
- Pedra azul ardósia (cru 0,9/0,94/1,02; pintado 0,235/0,27/0,315), chão frio de lajes de 1,1 m, juntas escuras.
- Quente só em fogo: braseiros e velas (luz laranja); chave suave quente (0,86/0,8/0,74) e preenchimento só no chão; sombra azul.
- Reservadas livres: vermelho só no aviso, esmeralda e violeta ausentes, ouro velho só na soleira.
- Luzes com sombra: 4 braseiros (cap 8). Sem luz por inimigo.

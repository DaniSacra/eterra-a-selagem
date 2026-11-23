# Câmara do Ancião (`elder_hall`), plano de cena (2026-11-23)

Look: `GuardianLook`, variante `&"chapel"` (`scripts/game/guardian_look.gd`). Geometria de jogo inalterada (`_elder_hall`).

## Vista de cima (metros)

```
 z=-12  NW +--[ABSIDE x -8.6..-2.4, 2,6 m]--[B]=(porta N x=4.3)=[B]----+ cortado NE
        |   altar+atril+velas, 3 lancetas      
        |        (C)(-4.5,-4.5)        (C)(4.5,-4.5)      C = coluna alta, r 0,9, h 5,2 (bloqueia corpos e tiros)
 z=0    (entrada oeste: arco, velas em pé z=+-3.4)         meio livre            boss (7,0) -> porta L (x=12)
        |        (C)(-4.5, 4.5)        (C)(4.5, 4.5)
 z=+12  SW +---------------------- porta S (x=1) ---------+ SE
```
- Salão 24 x 24 m, canto NE cortado em 2.5 m; paredes altas (8,6 m) ao norte (3,4 m de espessura por causa da abside), oeste e corte NE.

## Essencial
- As quatro colunas (peça do layout) inteiras, com capitel redondo (`round_column`): nobres e legíveis como abrigo.
- Abside no norte com arco, piso próprio, dais de dois degraus, altar com pano petróleo, atril, velas altas.
- Três lancetas na parede do fundo da abside e o feixe colorido que entram (azul claro; âmbar ao meio nos vidros).
- Entrada oeste com arco e soleira de ouro velho fina; braseiros dos dois lados da porta norte (do layout).

## Só clima
- Velas em grupos nas soleiras (norte x -10.6, -0.4, 9.2; oeste z -10.4, -6.8, 6.8, 10.4) e os dois suportes de velas na entrada.
- Quatro molduras de lanceta cegas na parede oeste (z -8, -5.6, 5.6, 8).

## Paleta e luz
- Mármore cinza claro frio (cru 0,98/0,98/1,0; pintado 0,315/0,322/0,34), chão de lajes de 1,4 m; calmo e solene.
- Feixe da janela azul claro (0,66/0,8/1,0), luz quente só sobre o altar e nas velas; sem violeta (Morvath), sem esmeralda (Emeth), vermelho livre para o aviso.
- Luzes com sombra: braseiros (2) e o feixe (1).

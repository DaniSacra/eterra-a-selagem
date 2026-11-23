# Pacote de arte 2026-11-23: Cripta B, Jardim B, Fendas (laboratório 2)

Referência: `docs/art/ref/salas_2026-11-23/` (03 Cripta B, 02 pôster). Geometria de jogo intacta (pisos, obstáculos, portas,
spawns, perigos); só o que o estilizado desenha. Sem capturas nesta entrega (sem GPU): números de aparência a ajustar pela
imagem. Regras: nenhum círculo no chão (só o Morvath), sem folhagem vermelha, vermelho = aviso, esmeralda = Emeth,
violeta = Morvath, ouro velho = elite (só filete).

## Cripta B (`crypt_look.gd`, variante B = ossário com o muro divisório)
Vista de cima aproximada (x leste, z sul; sala de uns 24 x 20 m, entrada oeste, muro divisório ao sul-meio):
```
 N  [nicho][nicho-estátua]  ...  [porta N]            ledge 0,9 m com urnas, velas apagadas, pilhas de fêmures
 W  [nicho]   . . . . . . . . . . . . . .            meio da sala livre (~14 x 10 m)
    [nicho]     [moldura LEÃO 1,9 m][moldura 1,9 m]   z = +3, x = -1,45 e +0,55 (entre os dois sarcófagos do sul)
 S  sarcófagos + lajes de túmulo em duas fileiras (z = -8,3 e +8,3), muro divisório com nichos
```
- **Veio da pintura:** o emblema do leão no chão, e a intimidade (nichos, sarcófagos esculpidos, velas, urnas) que a sala já tinha.
- **Adaptado:** o medalhão redondo com louros virou uma moldura QUADRADA com o leão (mesmo mecanismo do Salão,
  `ArenaKit.framed_slab` GRAVE com marca); a primeira das duas molduras elevadas da B (`STY_LION_FRAME_B`). O cordeiro do
  nicho não entrou (símbolo novo no cânone: perguntar ao Daniel). Heras e folhas carmim da pintura não entraram (vermelho é aviso).
- **Essencial:** meio livre, nichos do perigo do esqueleto legíveis, lajes que golpeiam, quebráveis (urnas e vasos já existentes).
- **Só clima:** moldura do leão, urnas, velas apagadas, ossos, neblina além dos muros cortados.
- **Paleta/luz:** pedra petróleo (STYLE), sombra `STY_SHADOW_GLOW`, chave morna `key_pool` no meio, fachos frios sobre o
  vulto coberto; luz quente só na entrada (AT-CB1) e nas velas acesas. Luzes novas: nenhuma.
- **Casas dos guardiões (`look = crypt`):** a mudança só roda se `_divider() != null` (muro do ossário da variante B). Se uma
  casa de guardião pedir um muro divisório de ossário, herdaria a moldura do leão; sem muro (variante A) nada muda.

## Jardim B (`garden_look.gd`)
Planta aproximada: salão largo ao redor do tronco de pedra petrificado; muro norte com recesso da porta, lago no oeste na B
(`_lake`), cascatas nas janelas (`_fall`), abismo a leste e sul.
- **Veio da pintura:** flores pequenas claras (creme e amarelo suave) onde a natureza retoma a ruína: no pé do muro norte
  (`BLOSSOM_WALL_EVERY` 3,6 m, fora do recesso) e em volta das raízes do tronco (`BLOSSOM_TRUNK`).
- **Adaptado:** as glicínias roxas e flores vermelhas da pintura ficaram de fora (violeta é do Morvath, vermelho é aviso);
  sem cor nova, musgo escuro e âmbar seco já existiam.
- **Essencial:** planta hostil fixa, raízes grossas que bloqueiam, tronco, meio livre.
- **Só clima:** flores (`Masonry.blossoms`, malha pequena, sem colisão, sem sombra, mais baixas que 0,3 m), folhas, fungos, cascatas, lago.
- **Paleta/luz:** verde musgo e cinza, feixe frio pelo tronco, luz filtrada pelas janelas (já existentes). Sem luz nova.

## Fendas (`rift_look.gd`)
Planta: duas pontes de pedra (9 x 5 m) sobre a fenda x -8 a 3; na B a ponte norte caiu. Abismo, aquedutos ao fundo, correntes e arco quebrado já existentes.
- **Veio da pintura (Ponte da Vigília):** estandarte do leão em haste fina sobre o pilar norte da cabeça oeste de cada ponte
  de pé (`HEAD_POLE`, `HEAD_BANNER`), fora do piso andável, junto do braseiro que já existia.
- **Adaptado:** só uma haste por ponte e no lado norte (o sul taparia o convés para a câmera). Tocha e estátua de leão da pintura: braseiros já existem; o leão fica para um modelo (não há peça de leão em pedra sem Meshy).
- **Essencial:** convés livre e legível, bordas do abismo. **Só clima:** estandartes, estilhaços, aquedutos, névoa.
- **Paleta/luz:** azul-violáceo frio e névoa; estandarte ouro velho só no filete, tecido petróleo no estilizado. Sem luz nova.

## Verificação
`--smoke=30 --seed=5 --nosave` e `smoke.sh 100 --arena=crypt|garden|rift --variant=1 --seed=3`: RESULT idêntico (menos fps/step_ms)
antes e depois. Testes: `tests/test_rooms_artpack.gd`; `test_room_style` ajustado (B tem uma moldura elevada e uma do leão).

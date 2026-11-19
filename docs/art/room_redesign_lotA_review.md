# Revisão do Lote A do redesenho das salas (commit d153434)

- **Data**: 2026-11-19. **Autor**: art-director. **Para**: environment-artist (depois do Lote B), via Game Director.
- **Spec**: `docs/art/room_redesign_lotA_spec.md`. Conceitos só locais: `docs/art/ref/redesign_2026-11-18/conceitos/01`,
  `02`, `03`, `16`, `17`.
- **Capturas** (RTX, 1920 x 1080, semente 5, as do environment-artist; nenhuma captura nova nesta revisão, a GPU estava
  com o Lote B): depois em `docs/gallery/redesign/lotA/*_stylized.jpg` e `*_classic.jpg`; antes em
  `docs/gallery/rooms_2026-11-18/estilizado/` e `atual/`. Medidas com
  `python3 -I tools/frame_stats.py <img> --hue --scene --box=...` nas caixas das tabelas 2.1 e 3.1 da spec.
- Tudo aqui é do perfil estilizado. O clássico das cinco vistas mede igual à galeria (luma, saturação média e p90,
  violeta idênticos): **clássico intacto, aprovado**.

## Veredito por vista

| Vista | Veredito | Em uma linha |
|---|---|---|
| 02 Cripta A | **Aprovada com correções** | Virou um lugar: petróleo frio, bruma embaixo, efígie lida, velas nos nichos. Fria e saturada demais, pouca vela quente. |
| 03 Cripta B | **Aprovada com correções** | Igual à A; a figura sobre o Ossuário some na parede (luma 39 contra 34) e as velas da tampa estouram o chão oeste. |
| 01 Salão | **Aprovado** | Ardósia azul e abismo azul na faixa; perdeu calor (parte quente da cena 6,5% para 1,8%). Correção leve. |
| 16 Loja | **Não aprovada ainda** | Tapetes e lanternas existem mas a sala não lê "loja": fria como o Salão, lanternas sem luz, relicário cru. |
| 17 Fonte | **Aprovada com correções** | Achada em 1 s, água clara (luma 200 contra laje 69). O musgo lê como anel verde chapado; flores invisíveis. |

## O que ficou bom (não mexer)

- **Cripta**: a troca de umbra lavada (matiz 250 a 264) para petróleo (matiz 200 a 203) é a maior melhora de imersão
  do lote. Fora da sala deixou de ser cinza chapado (desvio 0) e virou profundidade fria com variação (p10 13, p90 39,
  matiz 197). Chão leste luma 66 (antes 80) e oeste 69 (antes 93), parede norte 34: todos no alvo. Efígie no túmulo
  grande lida como corpo amortalhado, sem cruz nem espada. Grupos de velas nos nichos e urnas dão o ritmo da faixa norte.
  Estandartes petróleo conversam com a pedra.
- **Salão**: chão do meio matiz 220, saturação 0,12, luma 74; norte 220 / 0,13 / 65; abismo matiz 208, saturação 0,41:
  as três caixas na faixa. O quadro tem leitura de lugar alto sobre o abismo azul. Portal e braseiros seguem os marcos.
- **Fonte**: a água é o ponto mais claro do chão e a única coisa assim no quadro; não confunde com o relicário.
- **F7 e ar**: o teste de troca dupla existe e o clássico voltou idêntico. Nenhuma cruz, nenhum vermelho novo, nenhum
  verde fora do portal e do musgo.

## O que difere (por prioridade)

1. **Cripta fria e saturada**: na cena, saturação p50 0,33 (antes 0,15); parede norte 0,34, chão 0,24 e 0,22 (alvo do
   chão 0,10 a 0,20; o risco 3 da spec pedia pedra até 0,2 para separar do cachecol do herói). O ciano na cena subiu a
   2,2% (antes 0). O conceito tem petróleo, mas com o quente das velas segurando: aqui a parte quente da cena é 1,1%
   (alvo 2,5 a 7). Sem esse contraste a sala fica "filtro azul", não "cripta à luz de vela".
2. **Loja sem cara de loja**: parte quente da cena 4,2% (antes 8,5%; o conceito 16 é quase todo âmbar). As lanternas
   ficam ao lado do medalhão e não fazem poça visível; o pedestal do relicário sai cru e claro (luma p50 121, matiz
   puxado ao rosa pelo halo da Vida) contra a laje de 69.
3. **Figura velada da B** (o marco do conceito 03): luma p50 39 sobre a parede de 34; o `statue_glow` frio não aparece.
   O brilho frio da porta norte (A e B) mede 38 a 40, quase a parede (alvo do conceito: "luz distante" visível, teto 120).
4. **Velas das tampas na B**: chão oeste luma p50 89, p90 139 (alvo 60 a 78).
5. **Salão sem calor**: parte quente 6,5% para 1,8%. O medalhão do chão segue cinza (S-Q6 em aberto); o conceito 01 tem
   ouro velho no medalhão e poças de vela mais largas.
6. **Fonte**: o musgo é um anel de borda regular (lê como decalque), as flores de 4 a 7 cm não aparecem a esta distância.
7. **Compatibility** (navegador, secundário): figuras quase pretas na Cripta estilizada (relato do environment-artist,
   sem captura nesta revisão).

## Depende de asset (não é correção deste lote)

- Loja de mercador do conceito 16 (balcões, prateleiras, cortinas): não existe modelo; o lote só veste o Salão. Fica
  para o plano do Meshy, com autorização do Daniel.
- Bica com cabeça de leão do conceito 17: decisão P-11 (bica simples). Não pedir.

## Correções pedidas (para o environment-artist, depois do Lote B; só estilizado, clássico igual)

Ordem = impacto na imersão do teste do Daniel.

1. **Cripta, calor das velas** (`scripts/game/crypt_look.gd`, `STYLE.fire` e `STYLE`):
   `candle_gain` 1,3 para **1,8**; `pool_gain` 1,1 para **1,4**; `bowl_gain` 1,0 para **1,3** e `bowl_range` 3,5 para
   **4,5** (o do Salão). Aceite: parte quente da cena (`--scene`, `warm`) **2,5 a 7%** nas capturas A e B; chão leste
   continua luma p50 60 a 75.
2. **Cripta, menos saturação** (`crypt_look.gd`, `STYLE`): `stone` (0,285; 0,32; 0,347) para **(0,30; 0,325; 0,345)**;
   `floor_stone` (0,278; 0,296; 0,312) para **(0,285; 0,296; 0,306)**; `shadow` (0,88; 0,94; 0,98) para
   **(0,90; 0,94; 0,97)**; `air.ambient` (0,72; 0,75; 0,78) para **(0,74; 0,76; 0,78)**. Aceite: saturação p50 do chão
   leste e oeste **0,12 a 0,19**, parede norte **até 0,25**, matiz 200 a 215 (não deixar cair abaixo de 198), ciano na
   cena **até 1%**.
3. **Loja, luz das lanternas e calor** (`scripts/game/catacomb_hall.gd`): `SHOP_LAMP` energia 1,3 para **2,2** e
   alcance `STY_CANDLE_RANGE` (3,5) para **4,5** (só a lâmpada da loja, constante própria `SHOP_LAMP_RANGE`); lanterna
   em **todos** os vãos entre itens, não a cada dois (4 para 5 itens; a regra "nunca na frente da placa" fica); vidro
   da lanterna com o maior canal até 1,0 na tela. Aceite: parte quente da cena **6 a 10%**, poça âmbar visível sobre
   cada tapete, `DoorSign.contrast` 4,5:1 mantido.
4. **Relicário pintado** (`scripts/game/reward_gem.gd`, material do `_reliquary`): passar a pedra pelo
   `masonry_paint` com o `STYLE` da sala (ou meta `ArenaKit.PAINT_OWN`), `RELIQUARY_TINT` (0,78; 0,78; 0,8) para
   **(0,62; 0,63; 0,66)** no estilizado. Aceite: pedestal luma p50 121 para **85 a 100** (até 30 acima da laje), matiz
   210 a 230 fora do halo. Vale para loja e recompensas de todas as salas.
5. **Figura velada da B** (`crypt_look.gd`): `VEILED_GLOW` (1,2; 6; 35) para **(2,0; 7; 30)**; o `STATUE_VALUE` da
   figura **1,15** do da parede. Aceite: caixa `1190,110,50,120` luma p50 **55 a 75** (hoje 39), sem passar de 110 no
   p90.
6. **Brilho frio da porta norte** (`crypt_look.gd`): `DOOR_GLOW_FOOT` (0,10; 0,17; 0,21) para **(0,16; 0,25; 0,30)**;
   `DOOR_GLOW_FOOT_B` (0,16; 0,24; 0,28) para **(0,22; 0,32; 0,36)**. Aceite: caixa `1345,190,90,90` luma p90
   **80 a 120** (hoje 62 e 65), saturação p50 até 0,35.
7. **Velas das tampas da B** (`crypt_look.gd`): `STY_LID_POOL` 0,7 para **0,45**. Aceite: chão oeste `576,432,192,108`
   luma p50 **até 78** (hoje 89), p90 até 120. Conferir com o item 1 juntos (as duas mexem nas velas).
8. **Salão, um pouco de calor de volta** (`catacomb_hall.gd`): `STY_CANDLE_GAIN` 1,2 para **1,5** (velas só; braseiros
   iguais, a poça do leste continua 100 a 150). Aceite: parte quente da cena **3 a 5%** (hoje 1,8), chão do meio luma
   p50 até 78 e matiz 215 a 235.
9. **Musgo da fonte** (`assets/shaders/floor_decal.gdshader` e `catacomb_hall.gd`): borda de fora quebrada por ruído
   de 0,4 a 0,6 m de amplitude (hoje quase círculo), raio de fora variando 2,6 a 3,4 com o lado norte mais denso
   (`FOUNTAIN_MOSS` (1,95; 3,2) vira o raio médio); cor um passo mais escura, **(0,17; 0,20; 0,15)**. Flores de 4 a 7 cm
   para **9 a 14 cm**, até 40, em tufos de 3 a 6. Aceite: na captura `--start=fountain`, nenhum trecho reto ou de arco
   regular maior que 1 m na borda; flores contáveis (pelo menos 10 pontos claros).
10. **Compatibility na Cripta** (`crypt_look.gd`): `STY_COMPAT_AMBIENT` 0,7 para **0,85**; se o chão passar de 78, só
    as figuras pelo `crowd.gdshader` (technical-artist). Aceite: `DRIVER=opengl3 tools/shot.sh`, figuras luma p50 **45
    ou mais**, chão 60 a 78. Prioridade baixa (o desktop é o que conta).

Ainda pendentes e fora desta lista: S-Q6 (ouro do medalhão no estilizado; o conceito 01 o pede, decisão do Daniel) e a
captura na GPU de cada item acima (o environment-artist entrega com as caixas desta página).

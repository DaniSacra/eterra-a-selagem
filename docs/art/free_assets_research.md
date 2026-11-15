# Assets 3D gratuitos para o Explorador e a Emeth: pesquisa

Pesquisa de 2026-11-14. Nada foi baixado, comprado nem cadastrado. Cada licença foi lida na página indicada nessa data;
o que não deu para abrir está marcado **não verificado**. Critério: pode ser modificado e vendido num jogo comercial
(CC0 de preferência; CC-BY aceito com crédito). Rejeitados: NC, ND, "editorial", uso pessoal, licença ausente ou
ambígua, arte de fã de outra marca e modelos extraídos de jogos.

Alvo (resumo da seção 1 de `docs/art/hero_explorer.md`): homem jovem adulto, cerca de 7,5 cabeças, tronco em V,
cabelo cobre bagunçado, cachecol e manto curto azul-petróleo, colete de couro escuro sem mangas com braços nus,
correias cruzadas, cinto largo com fivela de latão, ombreiras de aço, braçadeiras e luvas, botas até o joelho.
Fantasia sombria estilizada (Hades II, Ember & Blade). Hoje: "Sombra" do Meshy (24 ossos, pose A) animado com a
Universal Animation Library 1 e 2 da Quaternius pelo nosso `Retarget`.

Dado medido no projeto (não na web): os arquivos da UAL em `assets/models/anim/` têm esqueleto de **53 ossos**
(`ual_standard.glb`, 46 clipes) e **65 ossos** (`ual2_standard.glb`, 43 clipes).

## 1. Personagens base com rig

### 1.1 Universal Base Characters (Quaternius)
- URL: https://quaternius.com/packs/universalbasecharacters.html e https://quaternius.itch.io/universal-base-characters
- Licença: no site, "Free to use in personal, educational and commercial projects. (CC0 License)"; no itch.io,
  campo License: "Creative Commons Zero v1.0 Universal". Verificado.
- Gratuito x pago: o itch.io diz "2 base models and 5 hairstyles completely free"; o pacote Source (US$ 19,99,
  .blend com rig, shaders, projetos Godot 4.3, Unity e Unreal) tem todos os corpos e 20 penteados. **Quais 2 corpos
  são gratuitos: não verificado** (o site fala em 6 modelos: Superhero, Regular e Teen, homem e mulher).
- Formato: FBX, OBJ, glTF (gratuito); .blend no Source. Cerca de 13 mil triângulos em média (site).
- Rig: "Humanoid Rig" para redirecionar em qualquer motor; o site diz que é compatível com a Universal Animation
  Library. Número de ossos: não informado (se for o mesmo esqueleto da UAL, 53 a 65 ossos; não verificado).
- Animações: nenhuma no pacote (vêm da UAL, que já usamos).
- Estilo: **MÉDIA a ALTA**. Proporção "Superhero" é heroica adulta, não cabeçuda; o acabamento é limpo e liso, mais
  "jogo indie estilizado" do que pintado à mão. Corpo nu (só base), roupa vem do pacote abaixo.
- Trabalho: escolher o corpo masculino (Superhero se estiver no gratuito), penteado mais perto do bagunçado, tingir
  de cobre; vestir com o 1.2 e peças próprias; cores da paleta do `hero_explorer.md` nas texturas.
  Ganho grande: mesmo esqueleto das animações, o `Retarget` fica quase identidade e somem os problemas de pose A.

### 1.2 Modular Character Outfits - Fantasy (Quaternius)
- URL: https://quaternius.com/packs/modularcharacteroutfitsfantasy.html e
  https://quaternius.itch.io/modular-character-outfits-fantasy
- Licença: site "Free to use in personal, educational and commercial projects. (CC0 License)"; itch.io License:
  "Creative Commons Zero v1.0 Universal". Verificado.
- Gratuito: o itch.io diz "Ranger and Peasant models completely for free". O Source (US$ 20 ou mais) tem todas as
  roupas ("82 total modular parts"; o site diz 12 roupas e 62 peças, com 3 variações de textura cada). O changelog
  cita Peasant_Male, Male_Noble, Male_Wizard.
- Formato: FBX, OBJ, glTF; .blend no Source. Polígonos: não informado.
- Rig: o mesmo humanoide dos Universal Base Characters, compatível com a UAL (site). Cabeças trocáveis.
- Peças: a página não lista capa, capuz, cachecol, ombreira nem bota em separado (**não verificado** o conteúdo do
  Ranger; pela foto de divulgação é roupa de couro de patrulheiro).
- Estilo: **ALTA** para o Ranger (couro, cinto, botas, ar de explorador), dentro do mesmo traço do 1.1.
- Trabalho: tirar o que não é do Explorador, tornar o colete sem mangas, recolorir, acrescentar cachecol, manto
  curto e ombreiras (modelados ou do Meshy), conferir se o pano tem peso de osso que segura no giro do golpe.

### 1.3 Modular RPG Characters (System G6, OpenGameArt)
- URL: https://opengameart.org/content/modular-rpg-characters
- Licença: "License(s): CC0"; aviso: "You don't need to credit me, but if you like you can mention me as System G6
  or Qoma." Verificado (texto da página).
- Formato: .blend em 7z (16,6 MB) e um rig IK separado. Polígonos: não informado (low poly).
- Rig: esqueleto próprio com ossos de controle; o autor diz "around 45 animation each", mas um comentário relata que
  só aparece a parada; as armaduras deram trabalho para animar na Unity (comentários).
- Peças: knight, wizard, ranger, merchant, blacksmith, innkeeper (tags), modulares.
- Estilo: **BAIXA a MÉDIA**. Low poly antigo, proporção ok, pouco detalhe para uma câmera que mostra o herói perto.
- Trabalho: refazer pesos, redirecionar para a UAL, retexturizar quase tudo. Útil como fonte de peças, não de herói.

### 1.4 RPG Character Pack (Quaternius, 2020)
- URL: https://quaternius.com/packs/rpgcharacters.html
- Licença: "CC0", "personal and commercial projects" (site). Verificado.
- 6 personagens de fantasia, animados; FBX, OBJ, Blend, glTF. Rig: não informado.
- Estilo: **BAIXA**. Low poly de cor chapada e proporção mais curta; não chega no nível do 1.1.

### 1.5 KayKit Adventurers (Kay Lousberg)
- URL: https://kaylousberg.itch.io/kaykit-adventurers
- Licença: campo "Creative Commons Zero v1.0 Universal"; texto "Free for personal and commercial use, no
  attribution required." Verificado.
- Gratuito: Knight, Mage, Ranger, Rogue (com capuz), Barbarian; FBX e glTF; atlas de 1024. Rig e animações básicas.
- Estilo: **BAIXA**. Chibi e cabeçudo, o oposto da proporção aprovada (por isso já existe o `Slender`). Fica para a
  multidão, como hoje.

### 1.6 Blender Studio: Human Base Meshes e rigs de filme
- Human Base Meshes: CC0 segundo a CG Channel ("available free under a Creative Commons CC0 licence",
  https://www.cgchannel.com/2023/06/download-blender-studios-free-human-base-meshes); 17 malhas, homem e mulher,
  versão realista e estilizada, quads limpos, sem rig. A página oficial (blender.org/download/demo-files) recusou o
  acesso automático: **licença na fonte oficial não verificada**.
  Estilo **MÉDIA** como ponto de partida para esculpir; não é um personagem pronto.
- Rigs do Blender Studio (Snow, Vincent, Huginn...): CC-BY, com crédito pedido ("Snow Rig (CC) Blender Foundation |
  studio.blender.org", https://studio.blender.org/characters/snow/). São rigs de animação de filme, pesados, com
  controles e chaves de forma; **BAIXA** para jogo. Rejeitados como herói.

### 1.7 Base Character (Shyr, itch.io)
- URL: https://shyr.itch.io/base-character
- Licença: "Creative Commons Zero v1.0 Universal" (campo da página). Verificado.
- FBX e .blend com IK; humanoide "specifically tested for compatibility with Mixamo"; Idle, Walk, Run.
- Estilo: **BAIXA**. Low poly simples, protótipo.

### Outros vistos e descartados
- MakeHuman: a página de licença diz "All core assets are shared under Creative Commons, CC0"; não fala dos assets
  da comunidade nem das roupas (https://static.makehumancommunity.org/about/license.html). Estilo realista,
  **BAIXA**; exigiria refazer tudo. Licença das exportações: não verificado.
- Mixamo (Adobe): não é licença aberta; a FAQ da Adobe recusou acesso, **termos não verificados**. Não usar como base.
- Kenney Animated Characters: CC0, mas bonecos de blocos retrô; **BAIXA**.
- Sketchfab "Stylized Male Character - Rigged" (your3dcharacter): é "Buy Royalty Free", pago. Rejeitado. No
  Sketchfab em geral muita coisa marcada CC-BY é extraída de jogo ou gerada por IA; só vale com autor conhecido.
- OpenGameArt "Base Human" com rig do Mixamo: CC-BY-SA 3.0 (segundo a busca, não aberto); o compartilhamento pela
  mesma licença complica o uso comercial do modelo derivado. Rejeitado.

## 2. Peças separadas (cabelo, cachecol, manto, ombreira, cinto, botas)

| Peça | Melhor opção gratuita encontrada | Licença | Situação |
|---|---|---|---|
| Cabelo | Penteados dos Universal Base Characters (5 grátis, 20 no Source) | CC0 (verificado) | Feitos para a mesma cabeça; tingir de cobre |
| Cabelo (alternativa) | OpenGameArt "long_flat_hair", cerca de 253 triângulos, .blend | CC0 (só pela busca, não verificado) | Low poly demais |
| Couro, cinto, botas | Ranger do Modular Character Outfits | CC0 (verificado) | Peças exatas não listadas; não verificado |
| Cachecol e manto curto | Nada gratuito com licença clara | | Capas grátis achadas eram pagas, de avatar VRChat ou sem licença |
| Ombreiras | Nada gratuito com licença clara | | Modelar (forma simples) ou gerar no Meshy |
| Bolsas e fivelas | Fantasy Props MegaKit (Quaternius, CC0 pela busca) | não verificado | Só como adereço estático |

Conclusão da seção: o que não vem pronto é justamente o que dá a silhueta do Explorador (cachecol e manto
azul-petróleo, ombreiras). Essas peças precisam ser feitas (Blender ou Meshy) e pesadas nos ossos do peito e ombro;
o manto pede osso de pano ou um balanço simples em código.

## 3. Espada para fazer as vezes da Emeth

| Candidata | Autor e URL | Licença (onde) | Estilo | Trabalho |
|---|---|---|---|---|
| Fantasy Sword | TCCDev, https://opengameart.org/node/175218 | "License(s): CC0"; "CC0: Public Domain - Use as needed, no attribution required." (página) | **MÉDIA**: uma mão, fantasia, texturas 1K; o autor diz "likely best used as a placeholder" | FBX, glTF, GLB; trocar lâmina por material verde emissivo, dourar a guarda, pôr gema |
| Sword Diamond | Quaternius, https://poly.pizza/m/WPj4nM1PFL | "Public Domain (CC0)" (Poly Pizza) | **BAIXA a MÉDIA**: low poly de cor chapada | FBX, glTF; lâmina de cristal combina com "lâmina de luz", falta guarda dourada |
| Medieval Weapons Pack | Quaternius, https://quaternius.itch.io/lowpoly-medieval-weapons | "CC0 License" (itch.io) | **BAIXA**: 22 armas simples, sem guarda ornamentada descrita | FBX, OBJ, Blend; base de forma apenas |
| Espadas do KayKit Adventurers | Kay Lousberg (1.5) | CC0 (verificado) | **BAIXA**: grossas, de chibi | Já é o que a Emeth substituiu |

Rejeitadas: "Sword of Legend" (Brandon Evans, Poly Pizza, CC-BY 3.0, mas com a tag #zelda: arte de fã de marca
alheia), "Master Sword" (Poly Pizza, idem), "Cyan Crystal Fantasy Longsword" (Summer Engine: página sem licença e
gerada por texto para 3D).

Observação honesta: a `EmethSword` de formas simples que já existe (`scripts/render/emeth_sword.gd`) tem a cor e a
leitura certas na câmera de 60 m. Nenhuma das gratuitas tem guarda dourada com esmeralda pronta; qualquer uma pede
retrabalho igual ou maior que modelar a Emeth direto (cerca de 300 a 800 triângulos bastam nessa câmera).

## 4. Recomendação (as 3 melhores)

1. **Universal Base Characters + Modular Character Outfits - Fantasy (Ranger), da Quaternius, CC0.** É o único
   caminho gratuito com proporção adulta e o **mesmo esqueleto da UAL** que já anima o herói: corta o maior risco
   do Meshy (rig automático de 24 ossos, pose fechada, sem dedos). Custo: Blender para vestir, recolorir e
   acrescentar cachecol, manto e ombreiras. Se o corpo "Superhero" ou mais penteados não estiverem no gratuito, o
   Source custa US$ 19,99 (pedir ao Daniel antes). Sem obrigação de crédito; vale citar a Quaternius nos créditos
   como já se faz com a UAL.
2. **Fantasy Sword (TCCDev, OpenGameArt, CC0)** como base de forma para a Emeth, se quiserem um modelo em vez das
   formas simples; senão, manter a `EmethSword` e modelar a final.
3. **Blender Studio Human Base Meshes (CC0, licença oficial não verificada)** como base de escultura, caso o Daniel
   prefira um herói próprio feito à mão em vez de kitbash: topologia limpa para depois rigar com o esqueleto da UAL.
   Alternativa mais rápida e mais pobre: peças do Modular RPG Characters (System G6, CC0).

Pendência de licença antes de baixar: abrir os pacotes e ler o `License.txt` de dentro; confirmar quais corpos e
penteados vêm no gratuito; conferir a licença oficial dos Human Base Meshes em blender.org.

## 5. O que asset gratuito não dá (comparado a um modelo sob medida)

- **Identidade**: os pacotes da Quaternius estão em milhares de jogos; o herói pareceria genérico ao lado de Hades
  II e Ember & Blade, que vivem de silhueta própria. As peças que tornam o Explorador reconhecível (cachecol e manto
  azul-petróleo, ombreiras, cabelo cobre em mechas) **não existem prontas** em licença aberta.
- **Traço pintado**: o visual de referência é textura pintada com luz e sombra desenhadas; os pacotes CC0 usam cor
  chapada ou PBR simples. Repintar a textura é quase o trabalho de texturizar do zero.
- **Pano**: nenhum gratuito traz manto com ossos de pano pensados para giro de espada e esquiva.
- **Fidelidade à folha aprovada**: kitbash chega a "parecido"; os critérios de fidelidade da seção 3 do
  `hero_explorer.md` (paleta, camadas, proporção medida) só se cumprem com modelo feito para a folha.
- **Vantagem real do gratuito**: rig e animação. Mesmo um herói sob medida ganha muito se for rigado com o esqueleto
  da UAL (53 a 65 ossos) em vez do rig automático do Meshy.
- Lembrete Steam: se alguma peça vier do Meshy ou de outra IA, registrar em `docs/steam-ia.md`; os assets CC0 acima
  são feitos à mão pelos autores (a espada do Summer Engine, rejeitada, era de IA).

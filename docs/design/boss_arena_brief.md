# Câmara do Selo: pedido do Daniel para a arena de Morvath (2026-11-15)

Pedido registrado para o backlog do game-director. Ainda não implementado. A imagem de referência ("Câmara circular do
Selo de Morvath") fica só local, em `docs/art/ref/morvath/camara_do_selo.png`.

## O que a imagem mostra
- Plataforma circular de pedra escura suspensa sobre um abismo violeta e azul espectral, com arcadas sob a borda.
- Balaustrada contínua na borda, com velas, lanternas de chama violeta, pilaretes góticos com cruz e dois pares de
  sarcófagos (noroeste e sudeste).
- Escadaria longa entrando pelo sudoeste: o herói entra por ali.
- Ao norte, uma fachada gótica com escada curta, porta selada de ouro e violeta com um raio violeta, duas estátuas
  encapuzadas, estandartes vermelhos e braseiros.
- Torre ao noroeste e correntes monumentais ligando a câmara à arquitetura distante.
- Selo de ouro velho no centro: anel duplo e estrela de oito pontas, com uma rachadura violeta.
- Morvath parado no centro.

## O pedido, resumido do brief
- **Agentes:** game-director, art-director, environment-artist, gameplay-engineer e qa-performance, coordenados pela
  sessão principal.
- **Arena:**
  - Trocar a arena retangular da luta de Morvath por uma circular. É uma cena ou configuração própria, com uma
    arquitetura reutilizável para outros chefes, e as salas comuns ficam como estão.
  - O raio vem da mecânica, não da estética: corrida e esquiva do Explorador, alcance da foice e das lâminas, a
    investida, as erupções, as invocações, a tempestade e o espaço para contra-atacar. O cálculo fica documentado.
    A arena é compacta o bastante para não deixar o jogador fugir, mas com rotas de esquiva justas.
- **Selo no centro:**
  - Estados: normal, preparo do ritual, ritual ativo, transição final e vitória. Na vitória o selo é restaurado e
    Morvath é selado, não morto.
  - Não bloqueia o movimento.
- **Perímetro:**
  - Colunas, estátuas, sarcófagos, correntes e braseiros, sem esquiva injusta, sem prender o herói e sem esconder
    ninguém.
  - Transparência contextual onde for preciso. O limite segue o círculo, nunca um retângulo invisível.
- **Luta:**
  - As quatro fases preservadas. O centro é usado nas transições e as invocações se adaptam ao círculo.
  - Na fase 4 a forma circular deve importar: nada de canto para fugir, espaços seguros reconhecíveis, nenhum ataque
    inevitável.
  - Sem aumentar a vida nem o dano para compensar.
- **Restrições:** sem Meshy e sem serviços pagos; só assets locais.
- **Evidências e entrega:**
  - Pasta `docs/gallery/boss_arena/` com: arena vazia, Explorador com Morvath, foice, investida, ritual, invocação,
    erupções, maldição, tempestade e vitória com a selagem.
  - Antes e depois, condições de captura e o vídeo da luta.
  - Relatório de QA, revisão de arte e backlog atualizado.
  - Commit e push em `arpg-3d`. O Daniel testa só no fim, sem aprovações no meio.
- **Aceite:**
  - A arena é circular e o raio é justificado.
  - O centro é usado, as quatro fases funcionam e a tempestade pressiona sem ataque inevitável.
  - O herói não fica preso, os avisos são legíveis e a câmera mostra a área de combate.
  - A identidade de Eterra se mantém, os testes passam e as evidências estão publicadas.
  - Capturas bonitas não bastam: as regras dos ataques também precisam ser validadas.

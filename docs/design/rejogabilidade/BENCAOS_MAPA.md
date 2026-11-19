# Bênçãos, RNG e escolhas de caminho

## Encontro celestial 2 → 3
1. Mostrar 2 entidades distintas elegíveis (identidades dependem de cânone).
2. Escolher 1.
3. Oferecer até 3 bênçãos válidas da escolhida.
4. Aplicar raridade, pré-requisitos, slots, Elo e exclusões.
5. Se pool insuficiente, fallback legível, sem cartas inválidas.

**Não afirmar que quatro famílias = quatro anjos.** Estudo do repo trabalha com Chama, Geada, Luz e Vigília. Possíveis estilos mecânicos: Chama pressão, Geada controle, Luz alcance/impacto, Vigília ritmo/sustentação ofensiva. Nomear entidades apenas após ler cânone; D-51 segue pendente.

## Discernimento (RNG reduzido)
I: um reroll/run. II: revelar entidade de sala futura. III: substituição limitada de entidade. IV: leve peso por sinergia. Não garantir build perfeita; medir diversidade por seed.

## Mapa
O código `scripts/game/rooms.gd` já contempla COMBAT, MINIBOSS, FOUNTAIN, SHOP, TRIAL, ALTAR, BOSS; `MAP_SALT` preserva mapa por seed; Magia já enche ao entrar em cada sala. **Não adicionar sala 'mana cheia' redundante**. Preferir melhoria de capacidade/recuperação.

### Recompensas propostas
Bênção, Encanto, Vida, Magia, Salmo, Loja, Material, Elite, Provação/Altar.

### Bifurcações que criam decisão
- Bênção **vs** cura: poder vs sobrevivência.
- Encanto **vs** material: benefício nesta run vs progresso permanente.
- Elite **vs** loja: risco alto vs controle pelo ouro.
- Salmo **vs** bênção: transformação rara vs incremento previsível.

### Regras
Recompensas anunciadas por ícone antes da escolha; portas com funções distintas; sem ofertas inúteis; piso de oportunidades essenciais antes de Morvath; RNG determinístico; testar `--short` e `--medium`; não refatorar RunMap sem evidência.

### Métricas
% de bifurcações contrastantes, taxa de recompensas válidas, builds distintas, ouro gasto, materiais por run, runs até upgrade, vitória/derrota por seed.

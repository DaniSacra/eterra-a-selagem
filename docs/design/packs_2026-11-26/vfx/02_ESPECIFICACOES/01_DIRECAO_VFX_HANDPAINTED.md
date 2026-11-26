# Linguagem de VFX — tinta em movimento

## Princípio
Eterra usa personagens e cenário 3D, mas o VFX deve ler como *pinceladas que ganharam volume*. Não é simplesmente pôr Kuwahara sobre uma partícula; a forma precisa ser pictórica **antes** do pós-processamento.

## Anatomia de qualquer efeito
1. **Fonte** — mão, Emeth, cajado, arma inimiga, chão, recompensa. Deve haver conexão física aparente.
2. **Antecipação** — acumulação de pigmento/luz pequena e controlada, sem fingir que bateu.
3. **Gesto principal** — a mancha dirigida pela ação; aresta controlada e parte interna de pigmento irregular.
4. **Contato** — forma curta, dura e assimétrica no ponto REAL do dano.
5. **Resíduo** — tinta fragmentada, lascas, poeira ou fiapo; some com lógica física/ilustrativa.

## Gramáticas visuais
| Emissor | Silhueta | Borda | Cor dominante | Movimento | Proibido |
|---|---|---|---|---|---|
| Emeth, Guerreiro | arco que afina, estilhaço angular | fio externo limpo e miolo escuro | esmeralda do código + marfim moderado | rápido, com resíduo curto | feixe uniforme e anel perfeito |
| Maga, fogo | línguas assimétricas | brasa/franja | laranja definido em `ElementLook.FIRE` | sobe, deforma | mesmo laranja do perigo ambiental |
| Maga, frio | cristais quebrados, placas | faceta | `ElementLook.COLD` | parte e cai | bolinhas redondas |
| Maga, raio | zigue-zague com bifurcações | fio agudo | `ElementLook.VOLT` | estalo segmentado | círculo branco contínuo |
| Inimigos comuns | massa escura e fumaça rasgada | borda escura, centro quente | carmim / magenta dos mortos, verificar HEAD | concentra, estoura, desfaz | roxo exclusivo do chefe |
| Morvath | alma/meia-lua corroída | franja roída | violeta canônico | desenrola e deixa cauda | fio ciano do herói |
| Recompensa | feixe vertical difuso + poça | quase sem borda | marfim matizado pelo item | pousa, respira, recolhe | pilar agressivo de spawn inimigo |

## Famílias de Bênçãos (efeitos, não ícones)
- **Sarael / Chama:** línguas de tinta e fragmentos de carvão; impacto queimando curto.
- **Nivael / Geada:** facetas, gelo que trinca e fiapos de geada; nunca o mesmo anel da Chama.
- **Lumael / Luz:** lâminas verticais marfim-ouro; geometria estreita e descendente, sem símbolo de cruz.
- **Shomael / Vigília:** rastros curtos de esquiva, pó mineral e resposta ágil; não escudo verde da Emeth.
- **Velael / Véu:** bruma cinza com borda âmbar apagada, interrupção visual breve; não colorir de violeta.
- **Galael / Maré:** fita fluida com espuma prateada, gotas alongadas, impulso direcional.
- **Qeshael / Marca:** marca oblíqua de precisão em bronze/oliva escuro, gatilho de finalizador; nunca retícula militar longa.

Ao implementar, mapear cada família nos recursos atuais. Não presumir que cada família possui o mesmo número de skills ativas; usar `data/boons/` e os modificadores reais.

## Continuidade com a técnica existente
Reusar `Fx`, `slash_ink`, `contact`, `emeth_wave`, `emeth_thrust`, `reward_shaft`, `wisp`, `soul_crescent` conforme existirem. Reusar `FxBudget`; evitar explosão de materiais únicos; compatibilidade OpenGL. O brilho compõe luz, não substitui desenho. Medir o limite `ScreenTone.SAFE` no estado atual antes de usar 226 como referência.

## Limites artísticos de aceite
- Numa imagem em cinza, o jogador identifica a fonte do golpe pelo contorno/forma.
- Ataques não ocultam a cabeça ou tronco do herói quando ele recebe o golpe.
- Contato aparece no quadro do dano; jamais um flash de contato para um golpe que errou.
- O aviso vermelho de perigo permanece legível, inclusive em Fase 4 de Morvath.
- Textura e silhueta continuam bem definidas em 1280×720 e Compatibility.
- Uma mesma habilidade não pode trocar de identidade por mudança de renderizador.

## Identidade cromática
O arquivo `docs/art/art_direction.md` do HEAD é a fonte de verdade. Em 26/11 ele reserva: Emeth esmeralda, anel do Guerreiro azul-petróleo, perigo vermelho, perigos ambientais âmbar, Morvath violeta, fogo/frio/raio da Maga próprios; Supremo do Guerreiro Corte do Juízo, Supremo da Maga Convergência Elemental. Não reutilizar paletas de estudos anteriores sem reconciliar o código.

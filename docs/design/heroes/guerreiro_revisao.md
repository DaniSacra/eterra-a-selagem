# Guerreiro: revisão de identidade e fraquezas

- **Data**: 2026-11-21. **Autor**: `hero-designer`. Proposta; nada implementado. Números de partida para o `balance-designer`.
- Base lida: `guerreiro.md`, `warrior_spec.md` (resumo do pedido), e os kits propostos de Maga, Ladina e Paladino.

## 1. Diagnóstico

O Daniel tem razão: o Guerreiro é o único herói com resposta em todas as colunas, e as quatro respostas são boas.

| Necessidade | Guerreiro hoje | Quem deveria ter |
|---|---|---|
| Perto, combo | combo 20, 25, giro 60 | Guerreiro (certo) |
| Longe | onda 40 em ~8,8 m a cada 0,7 s, quase sem custo | **Maga** (8 a 14 m) |
| Controle (prender) | Círculo de Luz prende 3 s, recarga 6 s | **Maga** (Campo) e **Paladino** |
| Controle (atordoar) | Brado atordoa comuns 0,5 s, recarga 14 s | **Paladino** (Golpe de Escudo) |
| Área | giro 60, Brado, Ômega onda larga 80 | Guerreiro (certo, no meio do grupo) |
| Chefe e alvo único | Ômega estocada 160, Corte do Juízo 300/200 | **Ladina** (burst em alvo) |
| Defesa | esquiva 5,6 m a cada 1,1 s, sem custo de Magia | **Paladino** (camadas); aqui o Guerreiro está certo em não ter guarda |

Invasões: onda longa e barata é o ataque da Maga; Círculo prender 3 s com recarga 6 s é controle total (Maga e Paladino); Ômega estocada 160 e ultimate 300 em faixa cobrem o burst da Ladina. Resultado: nenhuma fraqueza e nenhum motivo para escolher outro.

## 2. Identidade proposta

**"O lutador de perto que cresce no meio do grupo": fraco isolado e de longe, imparável cercado.**
Fraquezas desejadas:
1. **Longe é ruim**: sem dano relevante além de ~5 m; quem o kita o vence.
2. **Sem controle duro**: empurra e abala, não prende nem atordoa em série.
3. **Burst de alvo único fraco**: bom em chefe só com Fúria cheia (tempo), nunca num estouro.
4. **Dependente de Fúria e de posição**: perde ritmo ao recuar; vida e esquiva não substituem escudo.
5. **Magia escassa**: Ômegas são a exceção, não o ciclo.

## 3. Caminhos

### A. Cortar o longe e o controle (recomendado)
- Onda do direito: alcance 8,8 m para **4,5 m**, dano cai de 100% para 50% com a distância (linear); recarga 0,7 s para 1,5 s. Fica um "arco de espada" de médio alcance, mantém D-64 (especial como onda).
- Círculo de Luz: deixa de prender; vira **Chão do Leão** 5,4 m, 4 s: +25% de velocidade de golpe e -20% de dano recebido **só dentro** (zona onde ele luta, nada de controle). Recarga 10 s. Segurar: explode 150 por 100 (Magia 25).
- Brado: **empurra 2 m e abala (-20% de velocidade de ataque dos comuns, 2 s) sem atordoar**; recarga 12 s; continua dando 2 cargas de Fúria.
- Ômegas +30% de custo de Magia (estocada 26, onda larga 13). Corte do Juízo 300/200 vira 240/160; Voragem sem mudança (já é de perto).
- Fúria: cada carga também dá +4% de dano; cargas decaem em 4 s sem acertar (premia ficar colado).
- **Código**: M. Alcance e recarga são dados; queda de dano com a distância e decaimento da Fúria pedem 2 estatísticas novas; Chão do Leão pede uma zona de buff (verificar se a Bênção de zona existente serve; se sim, P).
- **Risco**: ficar fraco demais contra atiradores e magos; mitigar com esquiva boa e mais arremesso de Fúria. Pode ficar sem resposta a chefes de longe: teste obrigatório na Câmara do Selo.

### B. Só números (barato, menos identidade)
- Onda: 40 para 28, alcance 6 m, recarga 1,2 s. Círculo: prende 1,5 s, recarga 10 s. Brado: atordoa 0,3 s, recarga 16 s. Ômegas +20% de custo. Ultimate 105 de Magia fixo.
- **Código**: P (tudo é dado). **Risco**: continua com tudo, só mais fraco; o Daniel provavelmente volta a dizer que "faz de tudo". Boa como primeiro ajuste de teste.

### C. Cobrar pelo poder (risco/recompensa)
- Mantém números do kit, mas cada Ômega e a ultimate **custam 8% da vida** (ou deixam a Fúria zerada) e o Guerreiro recupera Magia só por abate de perto (sem abate de onda). Pico forte, pagando.
- **Código**: M a G (custo em vida, origem do abate). **Risco**: punitivo, quebra a leitura de "ofensivo" que o Daniel pediu, e mexe em testes de Magia.

**Recomendo A**, aplicada em duas rodadas: B agora (só dados, mede-se em 12 sementes), depois A completo se ele ainda "faz de tudo".

## 4. Efeito nos outros heróis (se A)
- **Maga**: dona do longe; a Rajada e a Lança de Luz deixam de competir com a onda; sem mudança de números.
- **Ladina**: dona do alvo único; a Marca ganha valor porque o Guerreiro deixa de matar chefes sozinho; nada a mudar.
- **Paladino**: dono do controle e da defesa; o Guerreiro não prende nem atordoa, então Golpe de Escudo e Guarda ficam exclusivos; revisar o empurrão do Brado para não repetir o do 3º golpe da maça.

## 5. Perguntas ao Daniel
1. Aceitar que o "especial como onda" (D-64) fique de curto alcance, tipo arco de espada, e perca força com a distância?
2. Tirar o Círculo de Luz como prisão e usá-lo como zona de buff do Guerreiro (muda o poder, não o nome)?
3. O Brado pode perder o atordoamento e só empurrar e abalar?
4. Prefere começar só com números (B) e ver, ou já ir ao caminho A?

## 6. Proposta do Daniel (2026-11-21)

Kit: Esq combo; Dir = rajada de espada que gasta Magia; E = investida (Corte Veloz) com recarga; Q = Brado sem atordoar, com dano e buff; Shift ultimate; Espaço esquiva pura.

**Opinião.** Boa: resolve de uma vez o "faz de tudo" porque tira o longe grátis (o direito passa a ter custo) e o controle (some o stun e o Círculo). Perto e cresce no grupo fica claro: combo + investida + Brado/buff + Fúria. Riscos: (a) sem controle de grupo, a sala cercada machuca; a esquiva e o buff de defesa do Brado têm de compensar; (b) direito pagando Magia só dá ritmo se a Magia voltar rápido; (c) investida + esquiva pura são duas travessias, evitar que a investida vire fuga. Recomendo **clique simples** (sem segurar, mais legível e mais "ofensivo"), custo 8 de Magia por rajada, e o Ômega de segurar some.

**Números de partida**
| Botão | Dano | Alcance | Custo | Recarga |
|---|---|---|---|---|
| Esq (combo) | 20, 25, giro 60 | corpo a corpo | 0 | 0 |
| Dir: Rajada de espada | 60, atravessa | 6 m | 8 Magia | 0,5 s (limite por Magia) |
| E: Investida (Corte Veloz) | 35, 4 m de avanço | 4 m | 0 | 5 s |
| Q: Brado de Guerra | 15, empurra 1,5 m, sem stun | 4 m | 0 | 12 s; buff 5 s: +20% velocidade de golpe, +1 carga de Fúria, -15% dano recebido |
| Shift: ultimate | como hoje | | 90/105 Magia | |
| Espaço: esquiva | | 5,6 m | 0 | 1,1 s, sem ataque |
Magia: manter +1 por abate, +2 por finalizador, e acrescentar +3 por acerto da investida, para o direito render ~1 rajada a cada 3 a 4 s lutando.

**Círculo de Luz e onda simples.** O Círculo some do kit base (a prisão era o controle que sobrava); volta como **Bênção/Dom** de outra família (ex.: o Brado deixa uma zona de 4 s) ou fica para o Paladino. A onda simples e as Ômegas de segurar são substituídas pela rajada; a onda larga 80 pode virar Dom do direito (rajada em leque).

**Custo de código: M.** Dados: rajada, investida, Brado, números. Código: separar a investida da esquiva (botão E com recarga), Brado com buff temporário (pode reutilizar a Fúria; verificar), remover o segurar do direito e a prisão do Q; testes `test_combo` e `test_t5_ultimate` precisam acompanhar. Controles: E hoje é Brado, então o mapeamento muda (decisão de 2026-11-21 pôs o Brado no E).

**Perguntas ao Daniel**
1. O direito sem segurar (clique, 8 Magia) está bom, ou ele quer manter o segurar para uma versão cara?
2. A esquiva do Espaço fica sem ataque mesmo, e o Corte Veloz só existe na investida do E?
3. O Círculo de Luz some do Guerreiro (vira Dom ou vai para o Paladino)?

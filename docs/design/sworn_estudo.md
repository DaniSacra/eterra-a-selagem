# Estudo de design: lutas do SWORN, para usar como princípio em A Selagem

Fonte: só `global-metadata.dat` (IL2CPP v29, sem criptografia, 22,6 MB, sha256 83714d2d...). Lidos nomes de tipos, campos e enums,
mais lista de textos internos. NÃO lidos: números, curvas, tempos (ficam nos dados serializados, ver seção b). Nada foi copiado,
executado nem escrito na pasta do jogo. Nenhuma instrução foi encontrada nos dados lidos.

## (a) O que foi visto e com que certeza
Legenda: OBS = observado no metadado (nome existe); INF = inferido de nomes; DESC = desconhecido (sem número).

| Tema | Achado | Certeza |
|---|---|---|
| Botões do herói | Enum de slots: ataque leve, ataque pesado, magia (spell), esquiva (dash), ultimate, companheiro, poção; mais slots de "espírito" (forma alternativa com ataque leve, pesado e transição). Ou seja 5 botões de combate + poção + 1 extra por herói | OBS (nomes); a ligação slot-botão é INF |
| Heróis | Cada herói tem pasta própria de habilidades (adaga e sombra, gancho e correntes, arma de arremesso, torre/comandante, forma espiritual, feitiços arcanos) e há mais de 20 armas, cada uma com seu conjunto (leve, pesado, preparo) | OBS |
| Preparo do golpe do herói | Armas têm habilidades "Windup" separadas do golpe (leve e pesado), com timeline de preparo. Pesado é carregável (Charging/Activate). Existe golpe em cadeia indexado (combo por índice) e "branching" (ramifica por entrada) | OBS; durações DESC |
| Esquiva | Habilidade própria com alcance base e máximo, curva de movimento, camada de colisão "esquiva" (atravessa), cargas máximas (`BaseMaxCharges`), tempo entre cargas, redução de recarga, variantes (corpo a corpo, teletransporte, corrida natural). Invulnerabilidade tem campo de duração e existe "graça após dano" no jogador (`baseHitGracePeriod`) | OBS; números DESC |
| Recarga | Recarga por habilidade com multiplicador, redução percentual e fixa, "buffer de recarga"; flag `ignoreAttackSpeed` por habilidade (algumas não escalam com velocidade de ataque). Cargas existem em habilidades (acumulam, carregam com o tempo, por impacto ou por morte) | OBS |
| Hitstop | Não havia campo com nome de hit stop, mas existe `freezeDuration` por golpe (0,075 a 0,3 s, 0,2 s nos golpes grandes de espada e maça): é a parada de impacto | OBS (nome), INF (uso); ver `sworn_numeros.md` |
| Cancelamento | Há `CancelAbility`, cancelar por esquiva em habilidades específicas e "canReRun" na esquiva | OBS; regras DESC |
| Dano e tipos | 12 tipos de dano (gelo, veneno, fogo, costas, vento, morte, luz, espírito, crítico, escudo, coragem, neutro). Ultimates por família de tipo (8 famílias) | OBS |
| Inimigos: tamanho | Enum de ~130 tipos de mob, incluindo ~8 chefes nomeados, uma classe "Major" (versão maior, minichefe) de ~14 inimigos comuns e uma classe "Corrupted" (modificador) de ~25 | OBS |
| Atributos de mob | Por mob: `poise` (stagger), `hitsToFreeze` (quantos golpes de gelo congelam), imunidade a hitstun, a knockback e a congelar, `knockback`, `canWallSlam` (dano ao bater na parede), multiplicadores de poise, gelo e knockback. Barra de poise visível (`ApplyPoiseDamage`, `DrainPoiseBar`, `StaggerResolver`); dano de vida pode virar dano de poise (`healthToPoiseDamage`) | OBS; valores DESC |
| Famílias de comportamento do inimigo | Corpo a corpo simples; investida (dash); salto; mergulho; projétil linear, em leque (volley), em barragem, múltiplo, balístico (curva); morteiro (área marcada), morteiro múltiplo, morteiro de raio; raio contínuo; anel (slam em círculo); invocação (comum e "major"); teletransporte e reposicionar; armadilha e rastro de veneno; bomba; boomerang (lançar e voltar); totem que dá buff; escudo/invulnerável (grupo); fugir do combate; ignorar knockback | OBS |
| IA | Árvore de comportamento (Behavior Designer) com tarefas por habilidade; cada habilidade de mob é um objeto com timeline (preparo, ataque) e `MobHold`/`SetMobLookDirection` (trava de mira). Estados de preparo/ataque/recuperação são INF; tempos DESC | OBS (estrutura), INF (estados) |
| Chefes | Habilidades próprias por chefe, fases ("TwoPhaseBossInvulnerable"), invulnerável na troca, fúria (modo raiva), invocar ajudantes, clones, morte própria. Chefes escolhidos sofrem "corrupções" | OBS |
| Modificadores de inimigo | "Corrupções": mais dano, mais velocidade de ataque, buff ao morrer, área de dano, ciclone, terremoto; chance de corrupção sobe por faixa (`corruptionChanceBonus` com limite e intervalo); chefes têm chance própria | OBS |
| Bênçãos | Raridades: comum, incomum, rara, épica, lendária, mais "dupla" e uma de modo especial. Bênçãos são por arma e por habilidade (nomes como "bênção de recarga da pesada", "da esquiva", "cadeia de raios por fúria"); alteram cargas, recarga, alcance, número de projéteis, dano por pilha | OBS |
| Curva de dano | Nenhum número de começo a fim | DESC |
| Dificuldade | 6 espaços de dificuldade (5 usados por nome), cada um um objeto de configuração; "dificuldade dinâmica" existe como modo; a dificuldade é escolhida em altar e muda a chance de corrupção | OBS; multiplicadores DESC |
| Co-op | Até N jogadores; três fatores de escala por quantidade de jogadores: vida de inimigo, vida de chefe e "intensidade" (provavelmente quantos inimigos). Revive por espírito (jogador morto vira espírito que pode ser revivido). Há também bots | OBS (nomes), INF (uso) |

## (b) O que NÃO deu para ver
- **Atualização (2026-11-22): os números foram lidos com o UnityPy autorizado pelo Daniel; ver `docs/design/sworn_numeros.md`.** Falta ver só
  o intervalo entre ataques dos inimigos, o dano real dos projéteis e os pesos de sorteio por região (seção (d) de lá). O texto abaixo é da
  primeira passada (só nomes).
- (primeira passada) Todos os números: vida, dano, poise, tempos de preparo e recuperação, cooldowns, cargas iniciais, velocidade, janelas de combo. Moram
  em ScriptableObjects e prefabs nos bundles de Addressables (StreamingAssets/aa, 4,6 GB). Não há leitor de Unity já instalado
  (UnityPy ausente) e instalar algo estava fora do combinado. Também seriam dados de arte e design, não só números.
- Tempo de hitstop, janelas de cancelamento, buffer de entrada, i-frames em segundos, curva de dano por bênção.
- Que botão físico liga a cada slot, quantas cargas de esquiva cada herói começa, vida inicial.
- Rotas de IA reais (ordem de ataques, tempos de espera entre eles). A lista de famílias acima é só o conjunto de peças.
- Código nativo (GameAssembly.dll) não foi aberto; não foi necessário para nomes.

## (c) Princípios para A Selagem (ideias de mecânica, sem copiar nada)
Onde o nosso jogo difere hoje: ver `comparativo.md` (ataque 3 golpes, especial onda, círculo, avanço com 19 quadros), `gameplay.md`
(esqueleto e corredor quase nunca ferem; 9 inimigos com papéis), e a seção COMBATE do backlog (CB-0 a CB-7, lote C1).

1. Ataque pesa pouco contra o resto porque o inimigo exige resposta de outro botão. SWORN dá a cada inimigo um atributo de
   stagger e de imunidade (poise, imune a knockback, congela em N golpes): o ataque básico não resolve tudo. Sugestão: dar a cada
   inimigo comum uma "regra de dano" (frontal quase imune, só cai com onda; ou só aceita dano depois de abrir a guarda). Hoje o
   `CB-4` já propõe isso em Escudo; falta torná-lo campo de dado (`EnemyDef.poise`, `hit_immunities`), não código por inimigo.
2. Todo preparo de inimigo pede uma resposta diferente. Famílias distintas hoje presentes no jogo deles: investida, área marcada,
   projétil que se espalha, raio, anel, invocar, buff de grupo, fugir. A Selagem tem 6 papéis; as peças que faltam e são baratas:
   anel (círculo que o jogador sai de dentro), projétil curvo (pede se mover, não esquivar) e buff de grupo (já em CB-4).
3. Barra de poise visível no inimigo dá meta ao jogador: golpes comuns enchem, habilidade grande quebra. Hoje o nosso atordoamento
   só existe na elite (barra amarela). Sugestão: poise em todo inimigo, só nas elites e Major visível, e a quebra abre janela
   de dano (como o Hades II faz com armadura) sem o herói atordoar de graça (regra F8).
4. **Corrigido pelos números:** a esquiva deles também começa com **1 carga** (a segunda vem de uma melhoria de meta), recarga 0,8 s e clipe
   de 0,2 s; a nossa tem 1 carga, recarga 1,1 s, 0,2 s e 18 quadros. O que difere é a **graça após dano: 0,2 s lá contra 1,3 s aqui**
   (`hurt_invuln`). Proposta 1 de `sworn_numeros.md`: 0,5 s; nada de 2 cargas de base.
5. Habilidades com recarga real e cargas que enchem por acerto ou por abate (não só por tempo). **Corrigido:** o nosso Q é o Brado de
   Guerra, recarga de 12 s, **sem custo de Magia**; quem gasta Magia é a onda do especial (12), o Ômega do ataque (20) e o Ômega do
   avanço. Lá a magia gasta 1 barra que enche com o dano causado (0,9% por ponto). Ideia: Brado voltar em 12 s ou 120 de dano.
6. Ataque pesado carregável (segurar) e leve rápido como dois botões com papéis distintos. **Corrigido:** lá o pesado é grátis, com
   recarga de 0,7 a 1,5 s (mediana 0,9 s) e 2 a 3 vezes o dano do leve; o nosso pesado (onda) custa 12 Magia e tem 0,5 s entre
   disparos, e o Ômega do ataque (segurar 0,8 s) custa 20. Os leves deles levam 0,67 s por golpe e os nossos 0,4 s.
7. Minichefe como variante de inimigo comum ("Major"): mesma família, mais vida, uma habilidade a mais. Mantém conteúdo como dado
   (nosso princípio) e dá picos de dificuldade sem inventar inimigo novo. Hoje temos 2 guardiões únicos; sugestão: elites já
   fazem isso, vale ter a "versão major" de 2 comuns em salas tardias.
8. Corrupção é modificador de dificuldade escolhido ou sorteado, com chance que sobe por faixa de sala. Equivale aos nossos Votos
   (não existe) e à maldição do lote C5: sugestão de lista de 4 a 6 modificadores de inimigo (mais dano, mais velocidade de ataque,
   explode ao morrer, área ao morrer) com chance que cresce por sala.
9. Co-op: três escalas por contagem de jogadores (vida de inimigo, vida de chefe, intensidade). Se um dia houver 2 jogadores,
   separar estas três, não uma só.
10. Faixas gerais (da experiência com ARPGs, NÃO medidas no SWORN): janela de reação de aviso 0,5 a 0,8 s para ataque comum,
    0,9 a 1,3 s para ataque grande; recuperação do inimigo (janela de punição) 0,8 a 1,5 s; ficar mais de 3 s sem ameaça é lento.
    Quando o Daniel quiser números reais, o próximo passo viável é ler os bundles com uma ferramenta de Unity (precisa instalar,
    pedir ao Daniel) ou mapear por jogo manual com cronômetro, em vez de tabela.

Resumo para o lote C1: o que falta nos nossos inimigos não é número, é resposta única por inimigo (regra de dano, anel, projétil
curvo, buff de grupo). Fazer com campos de dado em `EnemyDef` e deixar os números para o teste do Daniel.

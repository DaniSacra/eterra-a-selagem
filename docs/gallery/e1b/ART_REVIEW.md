# Revisão de arte da E1b (2026-11-16, art-director)

Revisão rápida antes do teste do Daniel. Só o que bloqueia o teste fica como bloqueio; o resto vai para o backlog.
Evidência: o material desta pasta (tiras, vídeos e capturas na GPU feitas pelos implementadores). Nenhuma captura nova:
as existentes cobrem os pontos pedidos. Folhas de quadros tiradas dos vídeos `morvath/storm_after.mp4` e
`morvath/scythe_after.mp4` no scratchpad da sessão (não versionadas).

## Veredito por item

| Item | Veredito | Observação |
|---|---|---|
| Andar do Escudo (`walk/guard_*`) | Aprovado | Pés plantados, passo curto e pesado, cabe no papel de bloqueio. |
| Andar do Cavaleiro (`walk/knight_*`) | Aprovado | Peso bom; capa e espada não atravessam o corpo de forma visível nas tiras. |
| Andar de Morvath (`walk/morvath_*`) | Aprovado | O manto esconde quase tudo; deslizar some. Mão esquerda a até 40 cm nos giros não aparece nas tiras: backlog. |
| Andar do mago (`walk/mage_*`) | Aprovado com ressalva | Melhor que antes (antes flutuava com o corpo deitado). Ainda há meio pulo em 3 a 4 quadros do ciclo (pés acima da sombra). Na distância do jogo (personagem com uns 80 px) lê como trote apressado, aceitável para quem foge. Backlog. |
| Andar do besteiro (`walk/archer_*`) | Aprovado com ressalva | Mesmo meio pulo, mais leve; o braço com a besta erguido acima da cabeça é pose de mira mantida no andar e parece estranho de perto. Backlog (não é da E1b). |
| Estalos de joelho do IK | Não visto nas tiras a 30 qps | Sem evidência de estalo; se o Daniel notar, voltar com quadro a quadro. Não bloqueia. |
| Foice de cima com duas mãos (`morvath/scythe_*`) | Aprovado com ressalva | O golpe vertical sobre a meia-lua lê como "golpe pesado que cai na frente"; o aviso no chão continua mandando na leitura e bate com a área. A diferença entre arco vertical e área horizontal é perceptível parado, não em movimento. Backlog: um rastro curto da lâmina deitando no fim do golpe casaria o gesto com a meia-lua. |
| Tempestade com arremesso (`morvath/storm_*`) | Aprovado | Gesto de arremesso antes de cada leva, faixas e meias-luas legíveis, herói visível em todas as levas. |
| Especial como onda esmeralda, D-69 (`vfx/especial_*`, `jogo_especial_em_voo.jpg`) | Aprovado com ressalva | Lê como meia-lua verde saindo do corte, mais coerente com o Guerreiro que o dardo. A onda é pequena em voo a 1080 e o fio de ouro some (só verde lê). Não bloqueia: o especial continua visível e com acerto claro. Backlog: onda uns 30% maior ou fio de ouro mais largo (ou aceitar só o verde). |
| Ômega do especial (`vfx/omega_especial_*`) | Aprovado | Meia-lua larga com veio claro, números esmeralda, bem separada do comum. |
| Velas do salão (`env/vitrine_velas_antes_depois.jpg`) | Aceito com -22% de pixels quentes | O que importa na leitura é a quantidade de focos e esses caíram à metade; o resto do quente são braseiros, que a referência tem. Os tocos apagados leem como velas apagadas (verde-oliva escuro). Não pedir mais corte. |
| Luz de chão da Cripta, M-1 (`env/cripta_M1_*`, `cripta_compatibility_depois.jpg`) | Aprovado | Ganho pequeno e localizado, paredes continuam escuras. O recorte A oeste em 19 de propósito está aceito (baía de sombra entre nichos é intencional). |

## Fora da E1b, notado de passagem (backlog)
- No `scythe_after.mp4`, num quadro após levar golpe, o Guerreiro aparece quase todo marfim claro (folha de quadros, 1ª
  linha de baixo). A regra é clarear morno por 0,05 s, nunca silhueta clara. Pode ser o quadro do clarão capturado no
  pico; conferir `Player.HURT_*` com quadro a quadro. Responsável: environment-artist ou gameplay-engineer (dono do
  `Player`). Não bloqueia.

## O que bloqueia o teste do Daniel
Nada. Veredito: aprovado para o teste do Daniel. A aprovação artística final é dele.

## Para o backlog (por prioridade)
1. Meio pulo do trote do mago e do besteiro: pés na sombra em todos os quadros de apoio (ou reduzir o sobe e desce do quadril no assado). Dono: quem assa (`tools/bake.gd`).
2. Especial: onda maior ou fio de ouro legível a 1080 (critério: o ouro visível numa captura 1920x1080 do jogo com a onda no meio do voo).
3. Foice: rastro da lâmina deitando sobre a meia-lua no fim do golpe.
4. Besteiro: braço da besta abaixado no andar (mira só no preparo).
5. Mão esquerda de Morvath nos giros: conferir de perto quando houver tempo; invisível na distância do jogo.
6. Clarão do golpe sofrido no herói (ver acima).

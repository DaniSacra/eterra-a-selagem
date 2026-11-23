# C1b: combate que cobra resposta (2026-11-22, pedido do Daniel: "focar no combate para deixar tão interessante quanto no SWORN")

Só princípio, nada copiado (`sworn_numeros.md`). Hipótese: o comum morre em 1,5 s e quase nada do que ele faz custa caro, então basta apertar.
O herói continua 15, 15, 20 e 30 de vida. A regra do F8 (golpe comum não atordoa ninguém) continua: **só a Quebra atordoa**.

## Frente 1: a Quebra (poise) e o preço do erro
- **Invulnerável após dano**: 1,3 para 0,7 s.
- **Aviso**: esqueleto 0,9 para 0,75; corredor 1,0 para 0,85 (abaixo de 0,8 já foi reprovado pelo Daniel no C17); `aim_lock` fica.
- **Vida do comum**: 1,6 vez (esqueleto 95, corredor 70, feiticeiro 115, besteiro 180); Trinca, Escudo, Sacerdote, Varredor, elites e chefes ficam.
- **Quebra**: campo de dado `EnemyDef.poise` (0 = não tem) em todo comum que não é elite, guardião nem chefe. Cada golpe tira poise conforme o
  **botão**, não só o dano: ataque pouco, onda muito, Investida médio, Ômega muito, Brado muito em área, ultimate tudo; dano no tempo e
  efeitos que agem sozinhos não tiram. Pesos como dado em um lugar só. Meta: só com ataque leva uns 7 golpes (o comum morre quase junto); com um
  golpe dos outros botões, 1 ou 2. Ao quebrar: atordoado 1,2 s, o preparo dele cai, leva +40% de dano, e o poise volta cheio depois.
  Elite, guardião e Morvath continuam com a blindagem de hoje (que já atordoa ao quebrar).
- **Leitura**: medidor pequeno sob a barra de vida (claro, que esvazia), só depois do primeiro golpe que tira poise; som e clarão próprios na quebra,
  reaproveitando o que existe; nenhuma cor reservada (vermelho, esmeralda, violeta, ouro dos elites).
## Frente 2: salas e comuns maiores
- **Versão maior** de dois comuns (esqueleto, corredor) como dado: vida cerca de 5 vezes, maior no tamanho, aviso próprio, uma habilidade a mais feita só
  de comportamentos que já existem, no máximo uma por luta, da sala 4 em diante. Nome provisório em `text_pt.tres` (o Daniel aprova).
- **Grupos menores e com respiro**: menos vivos ao mesmo tempo (3 a 6 no começo) e curva de orçamento por sala com vale (sala fácil depois de difícil), sem mudar
  as 14 salas nem os minichefes. Mistura sempre com dois papéis ou mais da sala 3 em diante.
## Aceite (12 sementes por linha, novato e evoluído; robô 0,25)
Comum cai em 2,5 a 3,5 s de ataque; só mouse chega a Morvath no máximo metade das vezes de todas as teclas; ataque até 40% do dano do evoluído; comuns
passam a ferir; novato morre antes de Morvath na maioria, evoluído vence 20 a 40%; nenhuma luta comum passa de 60 s.

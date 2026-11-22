# Revisão de jogabilidade, 2026-11-21 (combat-feel-director, só leitura e medida)

Método: 12 partidas sem tela do novato (`tools/smoke.sh 600 --bot-reaction=0.25 --seed=1..12`, `--nosave`, NONE, 30 de vida, commit
896d1c7), lidas por `rooms[].hurt_by/hits_by/shots/hp_in`, mais os `st_evoluido_*` da sessão principal. O robô mede dano e taxa de acerto, não sensação.
Números do jogo: `tools/make_data.gd` (MD) e os scripts citados. Hades II só como princípio; memória marcada.

## Medidas-base (novato, 12 sementes)
- Guardião enfrentado em 10 de 12. Morreu **dentro** da sala do guardião: Ancião 4 de 4, Cavaleiro 0 de 6. Os 6 que passaram
  pelo Cavaleiro morreram 1 a 3 salas depois (nenhum passa da sala 7; nenhum chega a Morvath). Vida ao entrar no guardião:
  13, 30, 8, 8, 18, 19, 25, 30, 39, 11 (mediana 18,5 de 30). Duração da partida 122 a 307 s (média 189 s).
- Dano sofrido (12 partidas, 355 de vida perdida): mago 118 (33%), Ancião 88, guarda 38, Cavaleiro 36, arqueiro 32, padre 24.
- Taxa de acerto no herói (acertos / tiros, `rooms[].shots`): arqueiro 7/374 (2%), mago 21/257 (8%), **Ancião 9/55 (16% por
  orbe, mas 9 acertos em 11 leques: 82% dos leques acertam)**, padre 3/6.
- Dano causado (`dealt_by`, 70,8 mil): ataque 60%, especial 12%, investida 8%, Ômega 6%, Brado 3%, resto 11%.
  Ômegas começados 55, cortados 13 (24%). Ultimate: 0 usos (trancada).
- Evoluído (12 sementes, sessão principal): Bênçãos ao entrar em Morvath 4 a 9, Elos 4 no total (0 em 9 de 12), Salmo em 2 de 12,
  loja em 9 de 12 com compra de cura (50 de ouro) em 8, fonte usada em 6.

## GP-1 (P0) Ancião: o leque rastreia até soltar e quase não deixa fresta
- **Evidência**: 4 mortes em 4 lutas, hp_in 8, 18, 19, 39; 2 a 4 orbes por luta (8 a 39 de dano); 82% dos leques acertam. O leque
  gira com o herói até o quadro do tiro (`horde.gd:897`, `FAN_THREADS` 5 linhas de 0,7 m, 5 orbes em 70°, 7 m/s, 12 de dano
  base, ciclo de 4,4 s ou 8,8 s quando levanta esqueletos, `horde.gd:933`).
- **Geometria** (cálculo, não medida): a distância entre orbes é 0,304 d; herói (0,5) + orbe (0,45) pedem 0,95 de folga de cada lado,
  então só há fresta a mais de 6,25 m. O Ancião recua se o herói chega a menos de 5,4 m e atira de até 9 m: **de 5,4 a 6,25 m o leque é
  uma parede**; a 9 m a folga é de 0,42 m. A orbe central vem sempre no herói parado. Sair de lado pelo aviso é impossível (o aviso
  gira junto); sobra a esquiva de 0,3 s de proteção (`feel.gd`, 1 carga, volta em 1,1 s) cronometrada na chegada da orbe, e os golpes
  plantados (`move_hold` 0,26 a 0,86 s) tiram o herói do lugar de qualquer jeito. Uma orbe custa 40% da vida (12 de 30).
- **Causa**: confirmada. O Morvath já trava o aviso (`boss.gd:131`, `FOLLOW_LOCK` 0,3 s); o Ancião não.
- **Proposta**: trava a mira nos últimos 0,35 s da preparação (`horde.gd:896`: parar de copiar `toward` quando
  `state_t >= attack_windup - 0.35`); `shot_spread` 70 para 84 (fresta a partir de 5,2 m); dano da orbe 12 para 10. Mantém o rastreio
  que o Daniel pediu, devolve a leitura. Só dado e uma linha.
- **Aceite**: 24 sementes, novato: leques que acertam 82% para no máximo 35%; mortes no Ancião no máximo 1 de 3 (o Cavaleiro é 0 de 6, ver GP-12).
- Tamanho P. Do Daniel: aceitar a trava curta (ele pediu "persegue até soltar").

## GP-2 (P1) O guardião chega sem cura e deixa o herói morrer nas salas seguintes
- **Evidência**: vida mediana 18,5 de 30 ao entrar no guardião; os 6 sobreviventes do Cavaleiro saíram com 7 a 13 e morreram até a sala 7.
  Cura só em: coração 0,24 a 0,31 por descida (`balance.md`, "Renda"), romã, fonte nas camadas 5 a 8 (MD `fountain_depth_min` 5) e
  loja na 10. O guardião fica na 4 a 6: **a primeira cura garantida vem depois da primeira parede**. Evoluído passa (hp 36 a 96) porque
  Vigor e Fôlego da Sala pagam a falta; o novato não tem isso. (Memória, a conferir: no Hades I a câmara antes do chefe tem fonte.)
- **Causa**: confirmada (`run_map.gd:381`, camadas da fonte). Hipótese: o ouro (32 a 152 na morte) não serve a ninguém antes da sala 10.
- **Proposta**: a sala imediatamente antes do guardião oferece a Fonte como uma das duas portas (cura 50% da vida máxima, 15),
  na 1ª e 2ª descidas sempre; depois, 60%. Com DM-1 (duas portas) é trocar uma recompensa, sem mapa. Alternativa se o Daniel não quiser
  cura certa: coração com 25% de vida (hoje cura menos) subindo de 0,3 para 0,6 por descida.
- **Aceite**: 12 sementes novato: hp_in do guardião mediana 24 ou mais; morte no guardião 25 a 40%; 6 de 12 passam da sala 8.
- Tamanho P a M. Depende do Daniel: cura garantida antes do guardião (choca com "mais difícil sem upgrades"?).
## GP-3 (P1) Textos antigos mentem sobre o kit e sobre o atordoar
- **Evidência** (`data/text_pt.tres`): `howto_heavy_attack_desc` (463) diz 60 de dano e 8 de Magia, o dado é 35 e 12 (MD 139);
  `howto_rush_desc` (469) "devolve 3 de Magia", é 2; `howto_shout_desc` (466) "20% mais rápidos", é 15%. Quatro cartas ainda
  prometem atordoar e não fazem nada: `boon_vigia_firme_desc` (843), `forge_refine_peso_desc` (794), `forge_refine_onda_pesada_desc`
  (800), `talent_furia_plena_desc` (494); `boss_phase_3` e `gloss_armor_text` seguem verdadeiros.
- **Causa**: confirmada. **Proposta**: corrigir os 3 números e ler do dado (`{dmg}`); as 4 cartas em GP-4. **Aceite**: teste que compara
  o Como Jogar com o dado. Tamanho P. Sem decisão do Daniel.
## GP-4 (P1) Cartas mortas com NONE (fora Fúria Plena e Refinar Peso, já no backlog)
- **Evidência**: `StunRule.stuns` fecha `horde.gd:1302`; `stun_pct` (Vigília `vigia_firme`, Refinar Onda Pesada) só age aí
  (`combat.gd:658`). `vigia_firme` é 1 das 9 Bênçãos de Vigília: perto de 11% das ofertas de Shomael são vazias, e o jogador só descobre jogando.
- **Proposta (só dado)**: `vigia_firme` vira `damage_reduction` 6% [+3%, +3%] (a estatística do Brado já existe);
  Refinar Onda Pesada vira `wave_size_pct` +25% no especial (existe na Luz, `onda_clara`). Se NONE voltar a `STRONG`, não precisa desfazer.
  **Aceite**: nenhuma carta com "atordoa" que dependa de `StunRule` (varredura). Tamanho P.

## GP-5 (P1) O golpe sem atordoar: o inimigo blindado não reage
- **Observado/medido no código**: o empurrão do combo é 2,5 e 3,0 (MD 52), decaimento 7: 0,36 e 0,43 m; o giro 16 (2,3 m). Guardião
  empurra ×0,35 (`horde.gd:1307`) e blindado nem isso (`horde.gd:1275`: "no push, no flinch"). O que sobra é o recuo desenhado de
  0,24 m (leve) e **0,15 m (pesado)** (`hit_recoil.gd:8`), clarão de 0,05 s (`horde.gd:17`), número cinza, parada de 25, 65 e 70 ms e
  40 ms no abate. Contra o Cavaleiro e o Ancião (1670 e 1960 de blindagem+vida, 25 a 35 s de luta) o herói bate sem corpo responder.
  Sensação (inferência): o acerto lê pelo som e pelo número, não pelo corpo; a barra amarela cai devagar sem marco.
- **Proposta**: (a) reação só desenhada em blindado e guardião: inclinar 4 a 6 graus por 0,12 s e voltar, sem mudar estado (o
  mesmo princípio do recuo, `hit_recoil.gd`); (b) estalo da blindagem em 75, 50 e 25% (som e fagulha no peito, `tells.armor_hit`);
  (c) parada +20 ms em guardião no giro e no Ômega; (d) na quebra da blindagem, parada de 3 para 6 quadros. Nada corta golpe de ninguém.
- **Aceite**: vídeo a 60 f lado a lado, 3 golpes no Cavaleiro (antes e depois); o PO diz "sinto o golpe" no Ancião. A sonda de sensação
  (`feel_probe_run.gd`) 41/41 sem mudar quadros de ataque do herói. Tamanho M. Depende do Daniel: ver o vídeo.
## GP-6 (P1) Mago: maior fonte de dano e não pode mais ser interrompido
- **Evidência**: 118 de 355 de dano em 12 partidas (33%), até 3 acertos numa sala (s4: 18). Dano 6, 3 orbes a cada 0,17 s, homing
  0,8 s, `max_attackers` 6 (MD 301 a 307). Antes ele parava ao ser batido; agora atira enquanto apanha.
- **Proposta**: `max_attackers` 6 para 3; elite 7 orbes mantém. **Aceite**: parcela do mago no dano sofrido de 33% para 20 a 25% em 12
  sementes; mortes antes do guardião não sobem. Tamanho P.

## GP-7 (P1) Brado sem motivo para apertar
- **Evidência**: 3,3% do dano; o resto é o buff: -15% de dano (12 vira 10: 2 de vida por golpe levado), blows +15% e Ímpeto só com o Dom.
  Sem controle nem corte de ataque, o botão não responde a nada que dói; a ultimate (Shift) está trancada na 1ª descida.
- **Proposta**: o Brado arma 1 absorção (o `shield_ready` do Escudo, `player.gd:170`) por 5 s, além do buff; recarga 12 s mantida.
  É a resposta ao "levei um golpe de 40%": dá um quase-erro. **Aceite**: robô novato aperta o Brado antes de leque ou investida em 50% das
  vezes (hoje o gancho não existe: instrumentar `Bot`); vida perdida por sala cai uns 10%. Tamanho P. Depende do Daniel (identidade do kit, `guerreiro_revisao.md`).

## GP-8 (P1) Ritmo da build: a build chega depois da parede
- **Evidência**: até o guardião o novato tem 2 a 4 Bênçãos (cada porta antes dele dá uma), **0 Elos** (0,17 por partida) e **0 Salmos**; o
  evoluído chega a Morvath com 4 a 9, Elo em 4 de 12 e Salmo em 2 de 12 (meta `balance.md`: Elo 35%, Salmo 15%). O guardião ficou na sala 4 em 6 de 12.
- **Proposta**: (a) o guardião nunca antes da sala 5 (MD `miniboss_depth_min` 4 para 5): +1 Bênção antes da parede, sem número de combate;
  (b) a 3ª Bênção oferecida tem 50% de chance de ser a que completa um Elo com as já levadas (quando houver); (c) fica a conta do Salmo
  em dois grupos, já no backlog do balance. **Aceite**: 24 sementes novato: Bênçãos ao guardião 3 a 5; Elo em pelo menos 35% das partidas
  que chegam à sala 6. Tamanho P (a) e M (b). Depende do Daniel: (a) alonga a descida em 1 sala (uns 40 s).

## GP-9 (P1) Primeiros 5 minutos: o que o novato não entende
Não há dica na partida (só `notice_room`, `notice_elite`, `hud_ult_locked_tip`); o Como Jogar fica no título e a 1ª descida abre direto.
- **Não ensinado (inferência do código, a testar com gente)**: (1) segurar o ataque 0,8 s faz o Ômega e custa Magia; (2) a barra amarela
  é blindagem e o Ancião e o Cavaleiro só levam vida depois dela (1220 e 1450); a quebra atordoa 2,5 s e é a janela de bater; (3) a
  esquiva só protege 0,3 s e tem 1 carga (1,1 s); levar um golpe te trava 0,18 s e derruba o combo; (4) o aviso no chão é quem
  manda e a linha do Ancião gira junto até o fim (GP-1); (5) a fonte e a loja existem, mas só depois do guardião; (6) a Magia sobe
  com finalizador e investida; (7) o que é Elo.
- **Proposta**: 4 dicas de 3 s, uma vez só por save, no gatilho e não no tempo: 1ª luta (golpe, esquiva), 1º Ômega disponível (segurar),
  1º elite blindado (quebrar a barra), 1ª Bênção com par (Elo). Dado em `text_pt.tres` e uma fila no HUD (`show_notice` já existe).
- **Aceite**: 3 pessoas novas, 5 minutos, perguntar "o que a barra amarela faz?" e "como se joga o Ômega?": 2 de 3 respondem. Tamanho M.

## GP-10 (P1) Morvath: maldição não se esquiva, adendos machucam mais que o chefe
Só o evoluído chega (novato 0 de 12): leitura de 9 lutas de `st_evoluido_*`, robô de 0,25 s.
- **Evidência**: maldição acerta 7 de 7 lançadas (homing 75°/s por 1,4 s, 7 m/s, 10 de dano mais 3 s lento e sem especial; MD 1461);
  foice 5% (3 de 55), ceifa dupla 6% (3 de 54), lâminas 11% (3 de 26), tempestade 3 de 8 (cada uma com 18 crescentes), erupções 2 de ~14.
  Adendos (esqueleto e mago, 8 a 18 por luta) dão 23 acertos: 36% do dano em Morvath, mais que qualquer golpe do chefe. O rastreio novo
  (`FOLLOW_TURN` 160°/s, `FOLLOW_LOCK` 0,3 s, `boss.gd:130`) deixou foice e ceifa justas; elas mal acertam.
- **Hipótese de causa** (a maldição): a orbe vira de modo igual ao do mago antigo que o PO achou o golpe mais injusto
  (`make_data.gd` 295 a 297); só trava depois de 1,4 s.
- **Proposta**: `curse_homing` 1,4 para 0,9 s e `curse_turn` 75 para 55; adendos: `adds_cap` fase 2 a 4 de 4 para 3 e o mago adendo
  com `max_attackers` 2. **Aceite**: 12 sementes evoluído: maldição acerta no máximo 50%; parcela do dano dos adendos abaixo de 25%; as
  vitórias não caem mais de 2 de 12. Tamanho P.
- **Decisão pendente**: na fase 3 três golpes pesados (o especial) em 4 s atordoam Morvath por 2,6 s (`boss.gd:1409` a `1416`,
  MD `stagger_hits` 3), fora da regra NONE, e o texto da fase 3 anuncia isso. 11 a 26 janelas de punição por luta. Daniel diz "não pode
  interromper ninguém": mantenho a favor de deixar, é a única janela do chefe e premia o especial; confirmar com ele.

## GP-12 (P2) Cavaleiro mole, guarda curto, arqueiro inofensivo
- **Ômega**: 24% das cargas cortadas por golpe levado (13 de 55, 0,8 s a 3% de velocidade): o botão que o NONE mais pune; teste 0,25 de
  velocidade com orbe a menos de 6 m (Daniel: pés plantados). **Cavaleiro**: 0 a 1 acerto por luta, 0 mortes em 6 (investida de 12,6 m com 1,0 s de aviso, `make_data.gd:340`). Não reforçar: o Ancião
  (GP-1) é a diferença. Se depois do GP-1 ele continuar mole, encadear a pancada de perto (3,2 m, 0,8 s) logo após a investida quando o herói
  está dentro, em vez de 0,8 s parado. Medir antes.
- **Guarda** (`make_data.gd` 322): pancada de perto com 0,65 s de aviso, o menor do jogo (o PO reclamou de 0,7 no corredor: C17); 4 acertos
  de 11 a 14 de dano (37%). Proposta 0,65 para 0,85. Tamanho P.
- **Arqueiro**: 7 acertos em 374 tiros (2%): não ameaça; só mexer se a sala ficar fácil depois do GP-6.

## Ordem e dependências
1. GP-1, GP-3; 2. GP-4, GP-6; 3. GP-2, GP-8 junto da DM-1 (mesma mexida no `RunMap`; o RESULT muda); 4. GP-5, GP-7 (vídeo e decisão);
5. GP-9 (3 testadores); 6. GP-10, GP-12. Medir cada lote com 12 sementes (erro de uns 14 pontos; 24 se a decisão for fina). Do Daniel: GP-1
trava curta, GP-2 cura certa, GP-8(a) sala 5, GP-7 Brado, GP-10 janela do especial em Morvath, GP-5 aprovar o vídeo.

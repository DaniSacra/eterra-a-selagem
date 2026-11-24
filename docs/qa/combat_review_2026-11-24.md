# Revisão de cadência e sensação do combate (2026-11-24)

Passada de melhoria do combat-feel-director. Fontes: leitura de `tools/make_data.gd`, `scripts/game/combat.gd`, `scripts/core/stun_rule.gd`;
sonda `tools/feel_probe_run.gd` (headless, 60 f fixos, rodada hoje: 33/41 ok); capturas de `docs/gallery/review_2026-11-23/` (guardiao, maga_bastao).
Nada foi implementado. "Confirmado" = causa vista no código ou na sonda; "Hipótese" = falta medir ou ver na GPU.

## P1 (sente errado)
1. **Golpe 2 do Guerreiro perde o hit stop (hipótese forte, causa no código).** `Combat.HIT_SLOW_COOLDOWN = 0.3 s` (combat.gd:29, usado em `_hit_slow`)
   e o corte 2 acerta 13 f (0,217 s) depois do corte 1 (sonda E1c-P6: 13 f). O hit stop de 65 ms do corte 2 (`make_data.gd` ~l.125) só toca se
   o do corte 1 já passou do cooldown, o que numa corrente apertada não acontece. Efeito: os golpes 1 e 2 sentem igual; o 2 devia ser "intermediário".
   Medir: sonda com `GF-01` no corte 2 (ritmo de quadros desde o acerto). Correção: cooldown por golpe do combo (ou 0,15 s) em vez de 0,3 s global.
   Critério: corte 2 mostra 1 a 3 quadros a 6% em toda corrente de 3. Dono: `gameplay-engineer`.
2. **Projéteis não têm hit stop nem tranco de câmera (confirmado).** `_hit_slow` só é chamado em `Combat.strike` (l.316); a Seta/dardo do especial do
   Guerreiro (35 de dano, 12 Magia), os tiros e a Explosão da Maga passam por `Projectiles` e `hit_stop_ms` é 0 neles. O acerto só tem flash e som.
   O especial é o golpe mais caro e o único sem peso no contato. Correção: ao dano de projétil, hit stop de 2 f (o do corte 1, 25 ms) no especial e
   na Explosão; nada nos tiros 1 e 2 da Maga. Dono: `gameplay-engineer`.
3. **Maga: os três tiros soam e pesam igual (hipótese).** `_maga_tree`: mesmo som `dart`, tremor 0,2 a 0,4, sem hit stop, sem brilho no 3º (`shot3.glint = 0`),
   tempos 0,21 / 0,23 / 0,34 s; o 3º dá 12 contra 8 sem sinal. Pedir à GPU uma captura de 3 tiros em sequência para o art-director ver o 3º. Correção
   provável: som próprio no 3º (o `dart` mais grave) e tiro maior (`effect_size` 0,9 já existe; somar 4 f de recuo da mão). Dono: `technical-artist` (som e brilho), `gameplay-engineer` (dados).
4. **"!" do PT-1 acende só 0,35 s antes (`Feel.bang_lead`) e os avisos comuns valem 0,5 a 0,64 s (hipótese).** O sinal chega com 0,15 a 0,29 s já gastos
   e sobram 0,35 s: abaixo do tempo de reação do robô "criança" (R 0,6, `balance.md`). Se a morte dos novatos continuar em golpe sem marca no chão,
   subir `bang_lead` para 0,45 (o painel F1 já mexe; é um número em `_feel`). Medir com o robô R 0,6 em 12 sementes antes e depois. Dono: `balance-designer`.
5. **Esquiva do Guerreiro com 1 carga e 0,8 s para voltar (`_hero`, make_data l.2050) contra avisos de 0,5 s em grupo (hipótese).** Dois inimigos com
   golpes escalonados em menos de 0,8 s deixam a segunda esquiva fora. A Maga tem 2 cargas e 1,0 s. O Daniel gosta da esquiva (memória); antes de mexer,
   contar nas partidas do `runs.jsonl` quantos golpes levados vieram com 0 carga. Dono: `balance-designer` (instrumentar: `gameplay-engineer`, uma linha no RunLog).
6. **Segundo avanço do Cavaleiro com aviso de 0,45 s (confirmado no doc §11, abaixo do piso de 0,5 s dos comuns).** O dano caiu para 10, mas é o aviso mais
   curto do jogo contra um golpe forte, com linha que segue o herói até 0,15 s antes (então trava a 0,30 s). Hipótese: é a causa de parte das mortes da
   sala 5 de quem lê tarde. Teste: robô R 0,6 só com `--guardian=knight`, contar mortes na 2ª investida. Se passar de 1/3, voltar para 0,55. Dono: `balance-designer`.

## P2 (polimento)
7. **A regra padrão "ninguém é interrompido" (`StunRule.DEFAULT = NONE`) não tem teste de sonda (confirmado).** A sonda GF-12 mede o contrário (atordoa e
   corta o aviso) e falha: "acerto f16, ataque f38". Hoje o esqueleto acertado na preparação ataca 22 f depois, de propósito; o que falta é um critério
   do novo desenho (o golpe leve dá só flash e empurrão; a reação precisa ser lida mesmo assim). Capturar um esqueleto levando 3 golpes na preparação
   para o art-director avaliar o empurrão (`COMBO_PUSH`). Dono: `gameplay-engineer` (reescrever GF-12).
8. **Armadilheiro: o disco cai onde a última esquiva terminou (até 3 s depois), 10 de dano = 25% da vida 40 (hipótese de cadência).** Pune a
   esquiva boa; 1,0 s de aviso é justo, mas sem o "pagamento" (vulnerabilidade do Armadilheiro ao reposicionar). Medir quantas placas pegam o herói por
   partida (`dealt_by.plates` está no RESULT; numa partida de teste hoje: 120 de dano a inimigos, 60 do `trap`). Dono: `balance-designer`.
9. **Os 6 `FEEL falha` restantes são alvos velhos, não bugs (confirmado, ver os comentários do `make_data`):** GF-09d (esquiva 13 f, decisão C1e), D-44a
   (esquiva sai em f-1, melhor que o alvo), GF-03a (sem golpe saindo da esquiva desde 2026-11-21), GF-07b (especial de 0,5 s, não 0,8), D-44c
   (Brado), GF-05 (câmera lenta só com a opção), E1c-P1 ("burst" não existe mais). Atualizar os alvos para a sonda voltar a ser regressão (33/41 hoje).
   Dono: `gameplay-engineer`. Quickwin de uma hora.

## Quickwins / dúvidas para o Daniel
10. Capturas hoje (`guardiao.png`) mostram `30/30` de vida no HUD do Guerreiro: é de antes da subida para 40 (`_hero` já tem 40). Refazer na próxima GPU para não
    confundir a revisão da arte.
11. A Maga segue com 30 de vida e o Guerreiro com 40; o balance diz que não mexeu. Com 2 cargas de esquiva a conta fecha, mas valida com o robô da Maga
    (`--hero=maga`, 12 sementes). Dono: `balance-designer`.

## Limites desta passada
Não rodei GPU nem capturas CPU (sem pedido de capturas novas); Morvath e o Ancião não foram remedidos: os números de §10 a §12 do `combat_cadence.md` seguem
os últimos. Itens 1, 2 e 7 pedem uma sonda ou captura GPU antes de fechar, comando sugerido para a sessão principal:
`tools/gpu.sh shot cadence_combo.png --bot --shot-at=9 --look=stylized --cam=near` na sala 1 (Guerreiro) e outra com `--hero=maga`.

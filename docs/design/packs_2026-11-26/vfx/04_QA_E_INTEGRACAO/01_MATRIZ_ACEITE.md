# Critérios de aceite / provas

| ID | Cenário | Evidência exigida | Passa se | Regressão proibida |
|---|---|---|---|---|
| Q01 | Combo / contato | captura antes/depois 3 frames + vídeo | contato no hit, nunca no miss; sem cruz branca; Emeth verde próprio | dano, hitbox, hitstop |
| Q02 | Especial / onda | vídeo de trajetória + hit | onda e impacto diferentes do corte e do chefe em cinza | velocidade e alcance |
| Q03 | Ômegas e Supremo Guerreiro | vídeo com HUD | sem corpo encoberto, contraste com cenário, faixas coerentes | mana, carga, tempo |
| Q04 | Maga gelo-fogo-raio | 3 vídeos, grayscale | distinguíveis sem cor; Convergência por fase | custo e duração |
| Q05 | 7 famílias | conjunto de 7 vídeos + miniaturas em cinza | 7 silhuetas / movimentos próprios | sem mudança de efeitos mecânicos |
| Q06 | Comuns/elites | vídeo com 12 inimigos e mensagens HUD | aviso inimigo sempre legível; elite distinto | IA, aviso, dano |
| Q07 | Morvath fase 4 | vídeo temp. completa com dois renderizadores | setor / projétil não confundidos com Emeth; aviso vermelho legível | fases e hitboxes |
| Q08 | Recompensa | pós-sala, loja com ouro alto/baixo, fonte | facho persistente e não igual a spawn inimigo | economia, pickup |
| Q09 | Performance | iGPU 720 Baixa e RTX 1080 Alta; cold/warm | sem regressão material de FPS nem pausas por novos shaders | `--look`, F7, Compatibility |
| Q10 | Compatibilidade | 720/1080 e Classic/STYLIZED | gestos preservam contorno e cor; F7 reversível | visual classic |

Referências numéricas HISTÓRICAS para comparar apenas quando fizer sentido no HEAD: `ScreenTone.SAFE` 226 e limite absoluto 235 (`vfx_pass_spec.md`); shader `RewardShaft` até 6 fachos, 2 draws/facho + partículas compartilhadas; corpo até 210 na caixa em 1080; perda prevista <=1 fps na iGPU loja, <=3 fps nos VFX intensivos. Medir métricas reais com `tools/frame_stats.py`, logs da engine e comparar antes/depois nas mesmas condições.

## Testes mínimos
- `tools/check.gd` e import sem Parse Error.
- Testes existentes em `tests/` para orçamento de VFX, combate, Boons, Rewards e Boss; não inventar nome de teste sem conferir arquivo.
- `--smoke=...` com seeds determinísticas para garantir que gameplay e progressão não mudaram.
- GPU screenshot `--shot-on=hit`, `--shot-on=omega`, `--shot-on=special`; chefe `--start=boss --boss-only=<nome real>` após confirmar CLI atual.
- Uma sequência de quadro a quadro do último golpe da Emeth e de Morvath.
- Conferência de bordas no Compatibility, F7 ida/volta, 1280x720.

## Questões que o Game Director precisa resolver sem inventar
- O que do lote 1 de 20/11 já foi fechado e testado?
- Qual é o shader de contato e qual é a versão atual de RewardShaft no HEAD?
- Há concorrência de edição de arquivos entre trabalhos de VFX e Salas?
- Os efeitos e as 7 famílias que aparecem no catálogo atual correspondem aos 7 selos aprovados?
- A skin do Guerreiro e da Maga está alinhada ao cânone atual e à altura real de jogo?

Entregue evidências no HEAD, marcando `confirmado`, `corrigido`, `pendente` ou `não reproduzido` para cada item.

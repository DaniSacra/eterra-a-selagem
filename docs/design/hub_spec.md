# HUB-01: plano de execução do hub (Santuário, nome provisório)

Base: diretriz do PO `docs/design/hub/po_directive_hub01.md`, auditoria `docs/design/hub_audit.md`, arte e planta
`docs/design/hub_spec_art.md`. Meshy 0. Nome do lugar e dos NPCs: provisórios até o Daniel decidir (D-H4, Q-H3).

## Fluxo
Título → Iniciar → hub (D-H5) → Portal (interagir, confirmação curta; Juramentos depois da 1ª vitória como hoje) →
`Game` (descida inteira, igual) → derrota ou vitória (save e `log_run` como hoje, selagem e `EndScreen` iguais) →
"Voltar ao Santuário" (sinal `end.menu` do `Game._open_end`, hoje para `boot.tscn`) → hub. "Descer de novo" fica
como atalho (D-H6). Pausa "Sair para o menu" → hub; no hub, Esc abre um menu com Configurações e Voltar ao título.
Opções de teste (`--bot`, `--smoke`, `--start`, `--stress`, `--play`, `--shot`) continuam pulando título e hub;
`--hub` entra direto no hub para capturas.

## Decisões do PO (recomendação em negrito)
**2026-11-19: o Daniel mandou seguir todas as recomendações; o nome do lugar (D-H4) e dos NPCs (Q-H3) ele decide
depois (até lá, nome de trabalho e só função). Q-H2 fica céu aberto ao entardecer, como as referências; Q-H5 sim.**

- D-H1 Vendedor: **personagem com loja "a definir" no MVP**; economia persistente decidida à parte.
- D-H2 Forjador: **"a definir" no MVP**; proposta futura de aspectos da Emeth sem somar dano (molde do Hades).
- D-H3 Livro: **Guerreiro mais três silhuetas seladas sem nome e sem seleção** (pedido novo do PO) ou só o Guerreiro.
- D-H4 Nome do lugar: "Santuário da Vigília" não está no cânone e colide com a família de Bênçãos "Vigília".
- D-H5 Primeiro acesso: **Iniciar sempre leva ao hub**, chegada perto do portal.
- D-H6 Atalhos: **manter "Descer de novo"; pausa e tela de fim voltam ao hub**.
- Q-H1 fonte **no meio da praça (a)**; Q-H2 céu aberto ao entardecer ou salão subterrâneo; Q-H3 quem são os NPCs;
  Q-H4 **câmera do jogo, distância 54**; Q-H5 folhas da Árvore acendendo com os Dons (só desenho); Q-H6 **Meshy 0**.

## Marcos e donos
| Marco | Conteúdo | Donos | Aceite |
|---|---|---|---|
| HUB-B1 fundação | ação `interact` (E, A; remapeável; Como Jogar e Controles), `Player` em paz (sem ataque, especial, círculo, esquiva de combate, ultimate; anda e corre), câmera e ar do mundo fora do `Game` (peça comum), anfitrião de telas comum ao título e ao hub (Esc/B, `open_screen`/`close_screen`, `Controls.clear_presses`), cena `hub.tscn` com `HubLook` sobre `ArenaRoom` e `RoomLayout` próprio fora do `StageDef`, `--hub` | gameplay-engineer | GUT: nada de golpe no hub, nenhum aperto vaza para telas e para a descida; título e descida sem regressão |
| HUB-B2 cenário base | planta da `hub_spec_art.md`, `frame_yaw` nos shaders de pedra e chão (salas iguais com 0), portal no alto com escada e leões de relevo, praça, fonte, cinco estações em peças existentes | environment-artist, technical-artist (`frame_yaw`) | A1 a A13 da spec de arte em captura real, `fit_probe`, iGPU 720 Baixa |
| HUB-B3 interação | foco por estação (2,2 m entra, 2,8 sai), uma placa `DoorSign` com nome, descrição curta e a tecla real, luz da estação +25% | ui-ux-designer, gameplay-engineer | uma placa por vez, teclado, mouse e controle |
| HUB-C sistemas | Árvore → `HeroScreen` capítulo Dons; Livro → `HeroScreen`/`CodexScreen` (D-H3); Portal → `boot._start` (Juramentos) e `Game`; Vendedor e Forjador com estado honesto "a definir"; fim de partida e pausa voltam ao hub; save: só chaves novas em `SaveData.defaults()` se precisar (hoje nenhuma) | gameplay-engineer, ui-ux-designer | 2 derrotas e 1 vitória seguidas sem perder nem duplicar XP, Dons, Compêndio; nova descida limpa; `title_flow_check` e testes da tela de fim atualizados |
| HUB-D acabamento | NPCs do KayKit assados e repintados (Vendedor encapuzado, Forjador com martelo e fagulhas), Árvore de Dons dourada (`StoneTree` em escala), luz, ambiência e música do lugar, transições | technical-artist, environment-artist, art-director (revisão) | revisão de arte com capturas 720 e 1080 |
| HUB-E QA | GUT, saves antigos, controle, F7, Compatibility, desempenho, vídeo percorrendo as cinco estações | qa-performance | relatório em `docs/qa/` e exe para o Daniel |

Riscos (auditoria e spec de arte): `SaveData.merged` descarta chaves fora do `defaults()`; `log_run("quit")` no
fechamento da janela; ar do `ArenaRoom` e `VisualProfile` atravessando cenas (testar F7 e hub ↔ Câmara do Selo);
bonecos do KayKit fora da exportação (assar para `assets/baked/`); deslizar em volta da fonte redonda.

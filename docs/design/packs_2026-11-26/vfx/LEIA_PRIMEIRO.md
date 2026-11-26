# ETERRA — PACOTE DE DIREÇÃO ARTÍSTICA VFX | 26/11/2026

## Leia nesta ordem
1. `01_PROMPTS/00_PROMPT_MESTRE_CLAUDE_CODE.md`
2. `02_ESPECIFICACOES/01_DIRECAO_VFX_HANDPAINTED.md`
3. `02_ESPECIFICACOES/02_INVENTARIO_E_PRIORIDADES.md`
4. `02_ESPECIFICACOES/03_BRIEF_POR_EFEITO.md`
5. `03_REFERENCIAS_VISUAIS/` — pintura-alvo e diagramas de comportamento
6. `04_QA_E_INTEGRACAO/` — matriz, testes e critérios de aceite

## Como usar
Copie o prompt mestre para o Claude Code e entregue este diretório no repositório. Ele DEVE consultar o HEAD antes de modificar qualquer arquivo. **Não é um pedido de substituir toda a arte de uma vez.**

## Fonte verificada
GitHub `DaniSacra/eterra-a-selagem`, branch `arpg-3d`, HEAD observado `b2d234ef1a395608232c1296a404d5d76f294966` (26/11/2026). Fontes técnicas do próprio repo: `docs/art/vfx_pass_spec.md`, `docs/gallery/vfx_pass/ART_REVIEW.md`, `docs/art/art_direction.md`, `docs/art/stylized_spec.md`, `docs/design/heroes/redesign_2026-11-24/`, `docs/qa/qa_2026-11-26b.md`, `CLAUDE.md`. Alguns relatórios são de 20/11: seus itens são **hipóteses de regressão até reconfirmados no HEAD**.

## Escopo e exclusões
Este pacote trata de VFX de combate, coleta e leitura de poderes. A outra frente é dona de pisos, layouts, salas, perigos ambientais e portas altas próximas. Não abrir tarefas paralelas nem alterar sua geometria. Não modificar gameplay, dano, velocidade, avisos, colisões, câmera ou progressão. Não criar ícones de UI nem personagens 3D aqui.

## Status da imagem ilustrativa
`03_REFERENCIAS_VISUAIS/01_PINTURA_ALVO_VFX.png` é **conceito ilustrado**, não captura do jogo, não sprite pronto e não especificação de hitbox. É alvo de textura e silhueta de pincel, sujeito à câmera real. Há quatro quadrantes: Emeth, Maga, Inimigos/Morvath, Recompensa.

## Condições técnicas
Godot 4.7, perfis STYLIZED/CLASSIC e F7, Forward+ e Compatibility. Sem Meshy e sem push sem autorização. Cada alteração deve ser mensurável, reversível e validada na resolução 720p e 1080p. Se o HEAD divergir, registrar diferença e parar apenas o item em conflito; não reintroduzir versões antigas.

# ETERRA — HUB-01: SANTUÁRIO DA VIGÍLIA

## Papel e decisão do Product Owner
Você é o Game Director / Tech Lead de Crônicas de Eterra: A Selagem. Implementar um hub 3D isométrico jogável chamado **Santuário da Vigília**, para onde o jogador retorna após uma run, com atmosfera de fantasia estilizada pintada à mão, no mesmo universo das salas redesenhadas. As imagens em `referencias/` são conceitos artísticos, não screenshots do Godot nem blueprints para copiar literalmente.

**Objetivo do produto:** um lugar prazeroso de explorar, memorável e de orientação imediata, com circulação curta e cinco estações: Vendedor, Forjador, Árvore de Dons, Livro de Ahk e Portal da Descida. Priorizar o Guerreiro, único herói jogável nesta fase.

## 0. Auditoria obrigatória do HEAD antes de implementar
1. Ler `CLAUDE.md`, `docs/backlog.md`, `docs/design/warrior_spec.md`, `docs/art/art_direction.md`, `docs/art/stylized_spec.md`, `docs/art/asset_inventory.md`, `docs/design/rooms_progression.md`, `docs/development/agent_workflow.md` e a documentação atual do fluxo de menus, saves e runs.
2. Inspecionar **código real** da cena principal, entrada no jogo, título, tela de derrota/vitória, fim da run, reinício, persistência, HeroScreen/BookSpread, árvore de Dons, seleção de herói, loja/economia, forja/evolução de arma, controles e áudio. Não supor que uma funcionalidade exista só porque está no backlog.
3. Criar `docs/design/hub_audit.md`: para cada uma das cinco estações, informar sistema existente, arquivo/função que o implementa, dados persistidos, lacuna e decisão de reuso ou MVP. Identificar precisamente a transição de derrota/vitória e o momento seguro de salvar.
4. Verificar se a grafia canônica interna é `Ahk` e manter essa grafia nos textos do jogo, apesar do conceito artístico anterior ter usado `Akh`. Texto visível apenas por `T.t()` em `data/text_pt.tres`, sem travessões.
5. Não inventar lore: se o nome Santuário da Vigília ou seus personagens demandarem fatos novos do cânone, registrar como proposta e solicitar decisão do PO.

## 1. Direção de arte e espaço
A referência principal é `referencias/01_santuario_vigilia_layout_final.png`. O **portal de aventura fica NO ALTO, ao fundo e no eixo central**, entre dois leões de pedra; escadaria de acesso e luz esmeralda. O leão representa a identidade do Guerreiro/Elun, conforme o cânone, sem introduzir símbolos concorrentes.

Layout aproximado em perspectiva isométrica, com o herói chegando pela parte inferior:
- **Alto centro:** Portal da Descida, foco visual dominante, arcos, escadas, dois leões, vista misteriosa da aventura.
- **Alto esquerda:** Vendedor sob cobertura de tecido, lanternas, poções e objetos. NPC legível.
- **Baixo esquerda:** Forjador, fornalha, bigorna, armas, luz âmbar e animação de trabalho.
- **Alto direita:** Árvore de Dons dourada em pequeno santuário com pedras e raízes; evolução visual opcional.
- **Baixo direita:** Livro de Ahk em atril de pedra/madeira, biblioteca de pergaminhos e velas; abre a interface canônica.
- **Centro:** pequena fonte do leão e pavimento com marca dourada, sem obstruir caminho direto ao portal. O centro é praça de orientação, não corredor estreito.

Usar arquitetura em camadas, cantaria pintada, pedra morna, sombras azul-petróleo, plantas e flores coloridas com moderação, estandartes petróleo/ouro velho, iluminação cinematográfica e efeitos discretos. O Hub deve ser acolhedor, seguro e distinto da masmorra. Não reproduzir a imagem literalmente: respeitar câmera real, escala do herói, colisões, desempenho e navegação. Evitar saturação excessiva, partículas contínuas caras e UI sempre exposta.

## 2. UX e controles
- Jogador controla o Guerreiro normalmente, caminha livremente e visita estações em qualquer ordem.
- Ao aproximar-se, destacar discretamente a estação e exibir **um único prompt contextual** `E Interagir` (ou ação equivalente no controle). Mostrar nome e descrição curta somente da estação em foco.
- Suporte a teclado/mouse e gamepad, com foco navegável, confirmação, cancelar e retorno à posição do herói. Nunca vazar inputs de combate quando uma interface estiver aberta.
- Não exibir barras de HP/ultimate, mapa de descida, inimigos ou HUD de combate no Hub. Exibir apenas informações persistentes realmente relevantes e comprovadas pelo código, de modo discreto.
- Sem colisão bloqueando acessos, NPCs não impedem a passagem, caminho claro entre estações; não exigir caminhadas longas entre operações frequentes.
- A saída para a aventura exige interação consciente e pode mostrar uma confirmação breve de prontidão, mas sem fricção excessiva.
- Retorno ao Hub após derrota deve comunicar continuidade e progresso, não punir o jogador com animações longas obrigatórias. Vitória deve preservar sua apresentação narrativa atual antes de retornar ao Hub.

## 3. Cinco estações funcionais
**A. Vendedor:** reutilizar o sistema real de loja, caso adequado para o metajogo. Separar rigorosamente moeda temporária da run de recursos persistentes. Se a loja atual for exclusivamente da descida, não transferir seus itens para o Hub sem decisão de design. Nesse caso, entregar NPC e interação com estado honesto de 'a definir' e registrar proposta de economia, sem inventar compra falsa.

**B. Forjador:** verificar se existe sistema persistente de evolução da Emeth. Se não existir, propor um MVP de forja com recurso, custos, níveis, efeitos e limites para aprovação; não implementar inflação de dano ou progressão nova por suposição. O forjador deve ser um NPC reconhecível, com fornalha e animação.

**C. Árvore de Dons:** conectar ao sistema de Maestria, desbloqueio e equipagem de Dons do Guerreiro já documentado em `warrior_spec.md`. Respeitar capacidade de Devoção, pré-requisitos e salvamento. Não duplicar a árvore ou criar outra moeda.

**D. Livro de Ahk:** conectar à interface existente do Livro e HeroScreen. Exibir seleção/consulta dos quatro lugares previstos, mas **somente o Guerreiro é jogável**. Heróis futuros devem estar claramente indisponíveis, sem seleção que quebre a run. Preservar Compêndio e registros já implementados.

**E. Portal da Descida:** iniciar uma nova run usando a lógica atual de seed, mapa ramificado, personagem, Dons equipados e inicialização da sala 1. Garantir que não carregue buffs/recursos temporários da run anterior indevidamente. Se já houver tela de preparação, integrá-la, não substituí-la às cegas.

## 4. Fluxo de vida do jogador
1. Primeiro acesso: preservar introdução narrativa e título; definir ponto de entrada do Hub após a apresentação sem quebrar tutorial, saves antigos ou flags existentes.
2. No Hub: estado persistente seguro, sem inimigos, dano ou consumo de recursos da run.
3. Portal: preparar/confirmar personagem e começar run; preservar progressão da descida.
4. Derrota: finalizar e registrar resultado, XP/Maestria, recompensas permanentes permitidas, salvar de forma segura, apresentar derrota e então retornar ao Santuário.
5. Vitória: apresentar resultado e narrativa, registrar progresso e retornar ao Santuário sem perder desbloqueios.
6. Fechar e reabrir: recuperar o Hub e os dados permanentes sem duplicar recompensas nem reabrir a run finalizada.
7. Compatibilidade: migrar saves anteriores sem apagar progresso; considerar `--nosave`, testes automatizados, debug `--start`, bot e showcase.

## 5. Arquitetura técnica
- Preferir cena própria de Hub e controlador de estado simples, isolados do loop de combate; reusar controles, materiais, shaders, sistema de interação, transições, áudio e UI existentes.
- Não duplicar Game, Save, Book, HeroScreen, economia ou árvores de talentos.
- Dados configuráveis em Resources; não codificar custos, itens e nomes em GDScript se já há infraestrutura de dados.
- Preservar `VisualProfile` e comportamento do estilo clássico/estilizado quando aplicável; estilizado é a direção visual do Hub.
- Renderização Godot 4.7, teste em Forward+ e Compatibility, orçamento de desempenho comparado às salas existentes.
- Meshy: saldo 500, **0 créditos autorizados**. Qualquer uso futuro exige lista de modelos, custo estimado e aprovação explícita. Reaproveitar assets e gerar geometria procedural quando fizer sentido.

## 6. Entregas por marcos
**HUB-A — Auditoria e especificação:** `docs/design/hub_audit.md`, `docs/design/hub_spec.md`, mapa de estações, fluxograma derrota→hub→run, riscos e lacunas de economia/forja. Art-director, ui-ux-designer, gameplay-engineer e technical-artist revisam. Não iniciar implementações irreversíveis sem resolver as lacunas críticas.

**HUB-B — Vertical slice jogável:** praça e portal no alto, Guerreiro navegável, colisões, câmera, 5 estações com prompts, arte base, retorno funcional ao título e entrada/saída de uma run de teste. Capturas reais em 1080 e 720, vídeo percorrendo as cinco estações.

**HUB-C — Sistemas integrados:** Árvore de Dons, Livro, Portal e retorno de derrota/vitória completos. Vendedor e forja conectados somente aos sistemas realmente existentes ou aprovados. Save, testes e gamepad.

**HUB-D — Acabamento artístico:** iluminação, detalhes, NPCs, áudio ambiente, transições, animações, sinalização contextual e polimento. O ambiente precisa ser interessante sem se tornar visualmente confuso.

**HUB-E — QA e fechamento:** testes automatizados GUT, integração, controles, saves legados, 2 ciclos de derrota e 1 de vitória, reentrada, FPS/VRAM, colisões, legibilidade em 720/1080, screenshots e vídeo humano de navegação. Game Director integra backlog e entrega versão MVP completa para teste do PO, sem pedir testes a cada ajuste pequeno.

## 7. Critérios de aceite
- Portal aparece como foco dominante no topo, dois leões e escadaria; fonte central não bloqueia a passagem.
- Cinco estações são visíveis, alcançáveis e têm prompt contextual funcional; interfaces fecham e devolvem controle ao herói.
- Dons e Livro usam dados e telas existentes; não há dois sistemas concorrentes.
- Somente o Guerreiro inicia run; slots futuros não iniciam heróis incompletos.
- Derrota e vitória retornam ao Hub, sem perda ou duplicação de progressão permanente.
- Iniciar nova run limpa estado temporário e mantém equipamentos/Dons permitidos.
- Saves antigos, controles e debug não quebram; sem regressão na descida e Morvath.
- Arte comparável às referências em composição e linguagem, mas verificada com captura **real do Godot**, não com imagem gerada.
- Sem gasto Meshy e sem publicação/commit/push sem autorização do PO, conforme `CLAUDE.md`.

## 8. Resposta esperada do Game Director
Primeiro apresentar diagnóstico do código atual e matriz `já existe / reutilizar / falta / precisa de decisão`. Apontar dependências de loja e forja antes de inventar mecânicas. Depois entregar um plano de execução detalhado, com donos de arquivos, marcos e testes. Executar a versão jogável conforme autorização do PO e registrar evidências reais.

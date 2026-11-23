# PROMPT PARA CLAUDE CODE — A VIDEIRA

Você está implementando **A Videira** em **Eterra: A Selagem**, Godot 3D, repositório `DaniSacra/eterra-a-selagem`, branch de referência `arpg-3d`. Leia `CLAUDE.md`, `docs/reference/meta.md`, `docs/reference/hub.md`, `docs/design/hub_spec.md` e o código atual antes de editar. Este pacote contém direção aprovada pelo PO e imagens conceituais (não são screenshots nem especificações pixel-perfect).

## Objetivo aprovado
Substituir o sistema de progressão de conta atualmente chamado **O Preparo** por **A Videira**, uma **estação física, independente e interativa no Santuário da Vigília**, NÃO dentro do menu do Forjador. A Videira é uma planta viva com raízes e ramos, referenciando simbolicamente João 15. Não deve ser confundida com a Árvore dos Dons. Ela concede vantagens permanentes a TODOS os heróis do mesmo save. Apenas três ramos iniciais, com três nós cada: **Vida, Provisão, Perseverança**. Nenhum bônus de dano, ataque, velocidade ofensiva ou raridade de bênçãos na Videira.

## Primeiro: auditoria
1. Inspecione as implementações atuais de `Account`, `AccountNode`, `AccountSheet`, `Hub`, `HubPlan`, `HubGate`, `HubLook`, `HubEvolution`, `HubPanel`, `MaterialPurse`, `SaveData`, lojas/mercadores e gerador de dados.
2. Mapeie o que existe, o que precisa ser alterado e possíveis dependências de testes e saves. **Não crie outro sistema paralelo**: migre/renomeie o existente com compatibilidade de saves.
3. Preserve o funcionamento da Forja, da Árvore dos Dons, do Livro de Ahk, do Vendedor, do Portal e da bancada reservada do Alquimista.

## Estação no mundo
- A Videira precisa de um ponto de interação próprio, com placa `A Videira`, foco por proximidade, interação pela ação remapeável já usada no hub e câmera de apresentação seguindo o padrão do Santuário.
- Escolha a posição depois de inspecionar o layout e verificar colisões, fluxo de chegada e distâncias. NÃO sobreponha o ponto da Árvore dos Dons, a Forja ou o Alquimista. Respeite o hub isométrico e seus limites de câmera.
- Uma videira ancestral emerge de uma base de pedra, sobe por um arco/treliça e forma três ramos distintos. Folhas e cachos/frutos discretamente luminosos, textura de pintura à mão, pedra envelhecida, luz verde-dourada. Não usar neon intenso nem interface sci-fi.
- Evolução visual vinculada aos 9 nós comprados no save: início pequeno, cada nó acrescenta folhas/galhos/frutos no ramo correspondente. A transformação deve ser persistente e visível ao voltar ao hub. Não bloquear a navegação nem criar câmera abrupta.
- Tirar `O Preparo` das opções do Forjador; deixar somente as opções próprias da Forja. Nenhuma estação de Alquimista funcional nesta entrega.

## Fluxo UX — ao interagir
1. Herói se aproxima, vê `A Videira` e a indicação da tecla/botão contextual.
2. Ao interagir, abrir tela em estilo do Livro de Ahk, **sobreposta ao jogo** com escurecimento sutil e a Videira visível ao fundo. Congelar controles de movimento enquanto a tela estiver aberta; não iniciar descida nem mover o personagem.
3. Cabeçalho: `A Videira`; subtítulo breve `Raízes que fortalecem todas as jornadas`; saldo de Fragmentos de Memória em destaque e total de nós adquiridos `x/9`.
4. Três ramos visualmente conectados ao tronco: **Vida** (coração/folha), **Provisão** (bolsa/fruto), **Perseverança** (cacho/raiz). Cada um com 3 nós conectados sequencialmente; cada ramo pode ser evoluído independentemente dos outros.
5. Foco em um nó abre painel lateral: nome, descrição do benefício, custo, saldo, pré-requisito, estado (adquirido/disponível/bloqueado/sem recursos) e ação contextual.
6. Compra: usuário seleciona nó, clica `Desbloquear` ou confirma no controle; mostrar confirmação explícita `Gastar X Fragmentos de Memória para adquirir [nome]?` com Cancelar/Confirmar; deduzir uma vez, persistir, atualizar saldo, destacar nó, animar crescimento do ramo e emitir feedback curto `Melhoria adquirida`.
7. Nó já comprado: mostrar `Adquirido`, sem botão de compra. Nó bloqueado: mostrar pré-requisito. Saldo insuficiente: botão desabilitado e mensagem clara.
8. Fechar por Esc/Voltar sem perder progresso. Navegação por teclado, mouse e controle, com foco visível; reutilizar padrões de UI existentes e remapeamento de ações.
9. A compra deve ser atômica: impedir duplicidade e saldo negativo. Nunca conceder vantagem de outro save.

## Nove nós — primeira versão (números propostos, balancear e documentar)
VIDA: (1) `Raízes Firmes` +5 vida máxima; (2) `Seiva Vital` +5 vida máxima; (3) `Raízes Profundas` +5 vida máxima. Total +15 vida máxima ao completar ramo, em todos os heróis. Não duplicar por cena nem por carregamento.
PROVISÃO: (1) `O Viajante` garante encontro com mercador em um ponto de preparação antes do chefe, usando arquitetura de salas/loja já existente; (2) `Estoque Ampliado` acrescenta UMA opção à oferta desse mercador; (3) `Provisão Reservada` garante UMA opção de recuperação no estoque. Não dar itens de graça; compras durante a descida usam **Ouro**. Se já existe loja pré-chefe, transformar primeiro nó em garantia/ativação do encontro e não criar segunda loja. Verificar layout e gerador de encontros antes de codificar.
PERSEVERANÇA: (1) `Primeiros Frutos` +10% Prata Antiga obtida; (2) `Colheita Farta` +10% Fragmentos de Memória obtidos; (3) `Frutos Maduros` +10% adicional em materiais persistentes obtidos na descida (Prata e Memória; Esmeralda apenas se a implementação existente permitir sem quebrar sua raridade). Aplicar no ganho, com regra de arredondamento explícita, nunca ao saldo já guardado; respeitar tetos de bolsa e evitar multiplicação repetida. **Validar a economia com testes**, especialmente a progressão de Memória.

## Custos e economia
- Moeda aprovada como proposta inicial: **Fragmentos de Memória**, já existente no jogo. Não inventar moeda nova.
- Custos sugeridos, por degrau em cada ramo: 5 / 10 / 20 Fragmentos de Memória. Total 35 por ramo, 105 por Videira. São números de partida e devem ser verificados contra a taxa real de ganho e os custos dos Dons, que também consomem Memória. Se desbalanceados, registrar recomendação e ajustar com justificativa clara.
- Prata Antiga permanece na Forja; Ouro nas compras de loja durante a descida. Não misturar moedas de forma silenciosa.
- Os custos são por compra definitiva, não por partida; o efeito permanece em todas as descidas do mesmo save.

## Compatibilidade e arquitetura
- Migrar os nós antigos de `O Preparo` sem quebrar saves v10+; inspecionar IDs existentes e criar mapeamento explícito para novos nós, ou reembolso em Memória quando não houver correspondência segura. **Não apagar progresso nem conceder bônus de dano legado**. Documentar migração e testar com fixture real/antiga.
- `Account` pode continuar sendo o backend se fizer sentido; `A Videira` é o nome público. Evitar duplicação de regras e nomes hardcoded; atualizar strings e testes.
- Se a loja pré-chefe não estiver implementada ou tiver restrições, entregar plano e integração mínima funcional, sem prometer mecânica que não exista.
- Não mudar balanceamento dos Dons, da Forja ou dos chefes sem aprovação.

## Referências visuais
- `referencias/01_estacao_e_interface.png`: direção visual da estação e painel; **referência artística**, não copiar navegação lateral nem localização literalmente se conflitar com UX atual.
- `referencias/02_fluxo_interacao_compra.png`: aproximação → árvore de 3 ramos → detalhe do nó → confirmação → crescimento. **Os números desenhados são ilustrativos**; implementar os dados aprovados acima.

## Testes e critérios de aceite
- Hub mostra estação separada e Forjador não oferece `O Preparo`.
- Abrir/fechar tela sem perda de foco; navegar por mouse/teclado/controle; custo e saldo claros.
- Nove nós, três por ramo; pré-requisitos sequenciais; ramos independentes.
- Compra persistida por save; outro save não herda progresso; todos os heróis do mesmo save herdam efeitos.
- Vida +5 por nó aplicado uma vez; loja pré-chefe funcional conforme desbloqueios; ouro cobrado nas compras; materiais calculados corretamente e sem bônus retroativo.
- Visual da planta muda por nó e persiste após reiniciar o jogo.
- Testar migração de saves antigos, saldo insuficiente, compras repetidas, saldo exato, tetos e arredondamento.
- Executar suite relevante, testes Godot/headless e inspeção visual. Criar commit e push somente se isso for permitido pelo fluxo atual do projeto; relatar hash e limitações. **Não marcar como concluído sem testar**.

## Entrega esperada
Resumo de alterações, arquivos modificados, decisões técnicas, testes e resultados, screenshots da estação e tela, checklist de aceite, pendências e impactos de balanceamento. Se encontrar conflito com especificação canônica mais recente, explicitar antes de substituir uma decisão aprovada.

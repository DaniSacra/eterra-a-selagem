# A VIDEIRA — especificação de produto e direção artística

## 1. Visão e referência
A Videira é uma estação física no Santuário da Vigília. Inspirada simbolicamente na videira e nos ramos de João 15:1–5, comunica permanência, vida, cuidado e crescimento. Não é uma representação literal de uma figura religiosa. O jogador alimenta as raízes com Fragmentos de Memória coletados em descidas e vê a planta crescer no hub. Cada melhoria beneficia todos os heróis daquele save, não somente o herói que a comprou.

## 2. Decisões aprovadas pelo PO
- Nome público: **A Videira** (substitui **O Preparo**).
- Estação separada, não na Forja.
- Somente **Vida, Provisão e Perseverança**, três nós por ramo.
- **Não** conceder dano/força ofensiva pela Videira.
- A Videira cresce visualmente conforme os nós são adquiridos.
- Vida, lojas antes do chefe e progressão de recursos são a prioridade inicial.

## 3. Propostas para validar no balanceamento
- Números de vida (+5 por nó), bônus de recursos (+10%), custos de Memória (5/10/20 por ramo) e a regra exata da loja pré-chefe são **propostas de implementação**, não medições aprovadas em playtest.
- Usar Fragmentos de Memória aproveita recurso existente, mas concorre com Dons. Comparar ritmo de desbloqueio de ambos antes de congelar custos.

## 4. UX visual e funcional
A interação deve ser contextual, sem navegação por menu do Forjador. Ao abrir, o jogo apresenta a Videira sobreposta ao ambiente, mantendo a sensação de continuidade espacial. Três ramos saem de um tronco comum e cada um contém três nós conectados. Selecionar nó revela detalhes e custo; confirmar compra exige uma segunda ação explícita, após a qual a planta cresce, o saldo diminui e o save é atualizado. Estados distintos: comprado, comprável, bloqueado por pré-requisito, bloqueado por saldo. A tela não deve depender de mouse e deve ter legibilidade no controle e em resoluções menores.

## 5. Economia
- Fragmentos de Memória: compras permanentes da Videira e desbloqueio de Dons.
- Prata Antiga: Forja.
- Ouro: lojas durante a descida.
- Esmeralda: material persistente existente, função consolidada ainda não confirmada neste pacote.
- Pedra Funda: material/progressão associada ao Vendedor em docs do hub; verificar implementação antes de mudar.

## 6. Progressão visual por marcos
0 nós: broto antigo, tronco fino, poucos ramos. 1–3: surgem folhas e luz discreta no ramo correspondente. 4–6: ramos alongam-se, brotam cachos pequenos, raízes envolvem pedra. 7–8: copa mais cheia e brilho dourado suave. 9: planta madura com três ramos legíveis, frutos iluminados e raiz envolvente. Visual deve refletir quais ramos foram comprados, não só total.

## 7. O que NÃO fazer
Não incluir aumento de dano, bônus ofensivos, novas moedas, árvore de 20+ nós, NPCs aliados, regeneração complexa, alquimia, loja duplicada ou novas regiões nesta entrega. Não alterar a Árvore dos Dons. Não substituir a estação da Árvore dos Dons pela Videira. Não copiar literalmente a interface das imagens: são direção de arte.

## 8. Referências e limitações
Fonte técnica consultada: `docs/reference/meta.md` e `docs/reference/hub.md` da branch `arpg-3d` (novembro/2026). A documentação registra 12 nós de O Preparo, acessíveis pelo Forjador, com Vida, Cura, Ouro, Bênção e Força. A nova direção deliberadamente substitui esse escopo por 9 nós em 3 ramos. A implementação deve auditar o estado atual do código antes de editar. As imagens foram geradas como concept art; textos/ícones/valores nas artes podem não corresponder exatamente aos requisitos escritos. **O texto deste pacote prevalece sobre detalhes das imagens.**

# Testes e aceite

- Catálogo: 7 famílias, 9 poderes cada, 63 IDs únicos ativos, 35 slots principais e 28 complementares; nenhum Duo/companheiro no sorteio.
- Para cada um dos 63 poderes, testar elegibilidade, aquisição, efeito e limites em Guerreiro e Maga (126 combinações); testar todas as raridades.
- Slot ocupado nunca volta ao sorteio; complementares coexistem; dependências corretas; nenhuma duplicata; 0/1/2/3 opções; anjo esgotado; fallback; seed reproduzível.
- Q, E, esquiva, ataques carregados e Supremo não confundem tags; E permanece inalterado; sem bônus duplicados em múltiplos eventos.
- Crítico e Marca distintos; DOT e ecos sem recursão; status nativo da Maga inalterado; limites e imunidades de chefes.
- Comparar ações, atributos, controles e progressão sem bênçãos antes/depois; comportamento idêntico. Verificar saves existentes e migração de IDs; não apagar progresso.
- Rodar testes existentes e simulações de descida com ambos os heróis, registrar seeds, opções vazias, efeitos não acionados e erros. Não inventar resultados.
- Playtest normal: observar clareza das cartas, percepção de identidade de cada anjo, escolhas, dificuldade e vontade de experimentar outra build. Sem criar ferramenta nova.

Aceite: nenhuma alteração fora do escopo, catálogo completo ou bloqueios explicitamente reportados, testes de regressão e relatório de implementação.

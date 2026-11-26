# GP-8, pacote 1 para o Midjourney: leia primeiro

Preparado pelo art-director em 2026-11-26. Você (Daniel) gera; nada aqui gasta crédito sem você clicar.
Explicações em português; **os prompts ficam em inglês** (copie o bloco inteiro, com os parâmetros).

## O que tem nesta pasta

| Arquivo | O quê | Quantas imagens você guarda |
|---|---|---|
| `00_LEIA.md` | este passo a passo | |
| `01_referencia_estilo.md` | 6 prompts das imagens-chave que viram o estilo fixo da série (`--sref`) | 3 a 4 escolhidas |
| `02_sala01_cenario_A.md` | técnica A: pintura da Sala 01 no ângulo exato da câmera do jogo | 1 aprovada (mais 2 alternativas) |
| `03_kit_modular_B.md` | técnica B: 10 folhas de peças para virar 3D | 1 por peça |
| `04_personagens.md` | folhas de modelo do Guerreiro e de 3 inimigos para o Meshy/Rodin/Tripo | frente, lado e costas de cada |
| `05_criterios_aceite.md` | o que reprova uma imagem (vale para todas) | |

**Ordem obrigatória:** 01 primeiro (sem estilo fixo, o resto sai de pintores diferentes). Depois 02 (precisa das
capturas do jogo que a sessão principal vai te mandar), depois 04 e 03.

## Passo a passo no Midjourney (site midjourney.com, aba Create)

1. **Versão.** Use a versão mais nova que aparecer em Settings (hoje a V7; se houver V8, faça a primeira imagem do
   01 nas duas e fique com a que respeitar melhor a paleta). **A série inteira fica numa versão só**: trocar de
   versão no meio troca o pintor.
2. **Settings fixos para toda a série:** Personalization **desligada** (ela puxa para o seu gosto médio e muda com o
   tempo); Stylize e Variety pelos parâmetros do prompt (não pelos controles deslizantes); Speed: Fast para escolher,
   Relax para repetir variações, se o plano tiver.
3. **Parâmetros que os prompts usam** (já vêm escritos no fim de cada prompt; não apague):
   - `--ar 16:9` proporção do quadro (16:9 é a tela do jogo; folhas de personagem usam `--ar 3:2`, peças `--ar 1:1`).
   - `--stylize N` (ou `--s`): 0 a 1000; quanto o Midjourney "embeleza" por conta própria. Usamos baixo (50 a 150)
     para ele obedecer a composição e a paleta.
   - `--chaos N` (ou `--c`): 0 a 100; quanto as 4 imagens de uma rodada variam entre si. 10 a 25 na exploração do
     estilo; 0 a 5 quando já temos o que queremos.
   - `--seed N`: repete o mesmo ponto de partida. Quando gostar de uma imagem, anote a seed dela (no site: abrir a
     imagem, menu `...`, Copy, Seed) e use a mesma seed nas variações.
   - `--raw`: menos "estilo Midjourney", mais obediência ao texto. Os prompts de cenário e de personagem usam.
   - `--no a, b, c`: o que nunca pode aparecer (cruz, auréola, texto, violeta etc.). Não apague.
   - `--sref URL1 URL2 URL3` e `--sw N`: a **referência de estilo** (próximo item) e o peso dela (0 a 1000; padrão 100).
   - `--oref URL` e `--ow N`: referência de personagem/objeto (o "omni reference" da V7) para manter o mesmo Guerreiro
     entre frente, lado e costas. Só no 04.
   - `--iw N`: peso de uma imagem colada no começo do prompt (0 a 3). Usado só no plano B do 02.
4. **Referência de estilo fixa (o coração da série).**
   - Gere o `01_referencia_estilo.md` (6 prompts, 2 ou 3 rodadas cada). Escolha **3 ou 4 imagens** que tenham a mesma
     pincelada, a pedra, a vela e a paleta certas (critérios no próprio 01 e no 05).
   - Faça o **Upscale (Subtle)** de cada escolhida e baixe.
   - No site, arraste essas imagens para a barra do prompt e marque cada uma como **Style Reference** (o ícone de
     clipe/pincel). O Midjourney guarda cada uma com um endereço `https://s.mj.run/...`. Copie os endereços para o
     arquivo `gp8_sref.txt` (modelo abaixo). Se preferir, crie um **Moodboard** com elas e use o código dele; mas
     escolha um jeito só.
   - **Daqui em diante, todo prompt da série leva exatamente as mesmas URLs, na mesma ordem**, onde está escrito
     `--sref SREF_URLS`. Troque `SREF_URLS` pelas URLs (separadas por espaço). Nunca troque as imagens no meio da série;
     se precisar, é uma série nova e o cenário volta à estaca zero.
   - Peso: cenário `--sw 250`; peças do kit `--sw 200`; personagens `--sw 120` (mais alto pinta o rosto e a armadura
     do jeito da pedra).
5. **Upscale.** Só depois de escolher. Cenário da técnica A: **Upscale (Subtle)** (o Creative inventa detalhe e
   desalinha a pintura da geometria). Peças e personagens: Subtle também. Nunca use Vary (Strong) numa imagem já
   alinhada.
6. **Como salvar** (você não precisa abrir o Linux):
   - Pasta: `C:\Users\danie\Downloads\ASelagem-GP8\` com as subpastas `01_sref`, `02_sala01`, `03_kit`, `04_personagens`.
   - Nome: `gp8_<grupo>_<peca>_<NN>.png`, por exemplo `gp8_sref_pedra_01.png`, `gp8_sala01_A_03.png`,
     `gp8_kit_arco_02.png`, `gp8_char_guerreiro_frente_01.png`. `NN` sobe a cada imagem guardada; não reaproveite.
   - Baixe sempre o PNG do upscale (não a miniatura) e guarde junto, na mesma pasta, um `gp8_log.txt` com uma linha
     por imagem: `nome do arquivo | prompt completo (Copy > Prompt) | seed | link da imagem no site`.
   - A sessão principal copia a pasta para `docs/art/ref/gp8_midjourney/` (fora do repositório público, como as outras
     referências) e registra no `docs/steam-ia.md` que são imagens de IA.

Modelo do `gp8_sref.txt`:
```
versao: V7
sref: https://s.mj.run/AAAA https://s.mj.run/BBBB https://s.mj.run/CCCC
origem: gp8_sref_salao_02.png, gp8_sref_pedra_01.png, gp8_sref_vela_03.png
```

## Gasto estimado

Cerca de 70 a 90 rodadas (de 4 imagens) para o pacote inteiro: 6 x 3 para o estilo, uns 15 para a Sala 01, 10 x 2
para o kit, uns 25 para os personagens (vistas separadas), mais os upscales. Na V7 isso dá algo como 1,5 a 2 horas de
GPU rápida; o plano Standard cobre com folga (e tem Relax para repetir). O Basic aperta.

## Regras de Eterra que valem em todo prompt (já estão escritas neles)

- Aventura, não terror: nada de sangue, gore, cadáver aberto. Osso é pó de osso, limpo.
- **Nunca cruz, nunca auréola com raios, nunca sol/estrela de raios** como símbolo. O símbolo do herói é o leão.
- **Leão só em lugar amigo** (herói, Santuário). A Sala 01 é território inimigo: nenhum leão, nenhum emblema no
  chão, estandartes de carmim gasto sem insígnia.
- **Violeta só de Morvath** (nenhum cenário, peça ou inimigo comum violeta). **Esmeralda viva só da Emeth** (a espada).
- Nenhum nome, personagem, logotipo ou cena de outro jogo nos prompts e nas imagens que você colar como referência.
- Texto dentro da imagem não serve para nada (o Midjourney escreve errado): todos os prompts pedem sem texto.

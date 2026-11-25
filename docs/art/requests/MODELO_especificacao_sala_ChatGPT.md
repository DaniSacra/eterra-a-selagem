# Modelo: como o ChatGPT deve mandar uma sala para o Claude construir

Cole o bloco "PEDIDO" no ChatGPT e troque só o que está entre colchetes. Ele devolve **4 peças**. Com as 4, a sala sai fiel; com
só a pintura, o Claude tem de adivinhar medidas, e é aí que a sala fica diferente da imagem.

## O que o jogo já fixa (o ChatGPT precisa saber)
- Câmera: de cima, inclinada 30 graus, girada 35 graus (o canto de cima da tela é o nordeste da sala), lente fechada (FOV 24).
  Na câmera Perto a tela mostra cerca de 28 m de largura: a sala é maior que a tela e a câmera segue o herói.
- Escala: o herói mede 1,8 m; a esquiva anda 5,6 m; um inimigo comum tem 1,6 a 2 m; o Cavaleiro 2,4 m.
- Tamanho de uma sala de luta: 24 a 36 m de lado. Corredores e vãos com menos de 3 m viram gargalo.
- Portas de saída: sempre duas, juntas no canto nordeste (topo direito da tela), 4,2 m uma da outra, com o medalhão da
  recompensa flutuando sobre cada uma. A entrada vem do sul ou do oeste.
- Peças que o jogo já tem (reaproveitar é rápido; peça nova custa tempo ou Meshy): piso de lajes, paredes de pedra,
  balaustradas, colunas, arcos góticos, escadas, buracos (queda), raízes, lajes de runa, cristais, urnas, vasos, oferendas,
  velas, braseiros, estandartes, estátuas, árvore morta, água rasa.
- Estilo: pintado à mão, legível (Ember & Blade), aventura e não terror. A luz vem de Elun (dourada e quente); o mal é frio
  (verde-esmeralda doentio, roxo). Sem sangue: osso e pó.

## PEDIDO (colar no ChatGPT)
> Preciso da sala [NOME, ex.: Cripta B] para o jogo A Selagem, para o Claude Code construir em 3D na Godot o mais fiel possível.
> Siga as regras fixas abaixo [colar a seção "O que o jogo já fixa"]. Entregue exatamente estas 4 peças:
>
> **1. Pintura na câmera do jogo**: 16:9, de cima a 30 graus, canto nordeste no topo direito, o herói (1,8 m) visível no centro
> para dar a escala, as duas portas de saída no topo direito.
>
> **2. Planta vista de cima, com medidas** (a peça mais importante): grade de 1 m, norte para cima, com:
> - contorno do piso andável e o tamanho total em metros;
> - onde o herói entra e as duas portas de saída (coordenadas em metros, origem no centro da sala);
> - cada obstáculo com tamanho e altura (coluna 1x1 m, 4 m de altura; bloco 3x2 m, 1 m...), e se bloqueia passagem, tiro
>   ou só a visão;
> - buracos e quedas, água, áreas que machucam (perigos) e o que cada um faz;
> - quebráveis (vasos, urnas) e onde os inimigos nascem (2 a 4 pontos, de lados diferentes);
> - em cor diferente o que é só cenário fora do piso (paredes altas, abismo, fundo).
>
> **3. Tabela ESSENCIAL × SÓ CLIMA**: o que não pode faltar para a sala ser ela (forma do piso, obstáculos, perigo, ponto focal)
> e o que é só atmosfera e pode ser simplificado.
>
> **4. Paleta e luz**: 5 a 7 cores em hex (piso, parede, destaque, luz quente, luz fria, perigo), de onde vem cada luz
> (braseiro, feixe, cristal), o que brilha e o que fica escuro.
>
> Opcional: 2 ou 3 detalhes de perto (uma coluna, a porta, o perigo) e uma frase sobre o que o jogador sente nessa sala.

## Como o Claude usa cada peça
- A planta vira os dados da sala em `tools/make_data.gd` (piso, obstáculos, portas, nascimentos, perigos), com teste.
- A pintura e a paleta guiam materiais, luz e peças de cenário; a captura na placa de vídeo é comparada lado a lado com a
  pintura, na mesma câmera, e ajustada até bater.
- O ESSENCIAL é cobrado um por um; o SÓ CLIMA entra se couber.
- Uma sala por vez, na ordem do Daniel.

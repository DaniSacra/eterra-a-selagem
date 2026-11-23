# Medalhões pintados à mão, Rev. 02 (integração de 2026-11-23)

Pacote do diretor de arte do PO no ChatGPT (`Eterra_Pintura_Medalhoes_PARTE_1..3`), integrado pelos IDs reais, sem
mudar regras: `RewardIcon.texture(id)` lê `assets/ui/rewards/<id>.png`, `BoonArt.medallion(id)` lê
`assets/ui/boons/<id>.png`, o desenho procedural continua de reserva quando falta o arquivo. Capturas antes e depois em
`docs/gallery/medallions_rev02/` (cópia em `Downloads\ASelagem-medalhoes-2026-11-23`). Teste: `tests/test_painted_medallions.gd`.

## Aceitas
- **Portas, 25 de 25.** Leem bem a 64 px, cada recompensa com silhueta própria (romã, coração, moedas, livro, espadas,
  elmo, fonte, tenda, os 7 anjos). No jogo a moldura pintada fica dentro do aro de ouro do medalhão (aro duplo, aceitável).
  Única edição: apagado um texto solto ("DE ME") no alto de `trial.png`.
- **Bênçãos, 70 de 77**, todas as que só tinham o desenho procedural. A família lê bem (cor e cena), o acabamento pintado
  combina com as cartas.

## Mantidas (a de antes é melhor)
`aurora`, `brasas`, `escudo`, `onda_maior`, `redemoinho`, `toque_geada`, `vapor`. Cada uma tem um motivo central próprio
que lê a 64 e a 32 px; as novas repetem a cena da família e só mudam o selo (`7_antigas_x_novas.jpg`).

## Precisam de refino para 64 px (não aprovar às cegas)
A 64 px as Bênçãos de uma mesma família ficam iguais: muda só o selo do canto, ilegível a 32 px
(`bencaos_parecidas_64px_e_32px.jpg`, uma linha por grupo). Grupos medidos pela diferença de cor a 64 px:
- Luz: circulo_radiante, consolo, final_radiante, flagelo, golpe_radiante, onda_clara, pesado_radiante
- Vigília: circulo_firme, golpe_firme, passos, pesado_firme, vigia_firme, vigilia_longa; firmeza, guarda_atenta
- Geada: estilhaco, floco_errante, geada_final, omega_geada, passo_geada, peso_inverno; circulo_geada, golpe_geada, ultimo_geada
- Marca: flechas, golpe_certeiro, golpe_marca, olho_atento, omega_marca, pesado_marca; chuva_flechas, circulo_marca, passo_marca
- Chama: lamina_ardente, passo_brasa, pesado_brasa; chuva_brasas, circulo_brasa, golpe_brasa, omega_brasa, ultimo_brasa
- Maré: circulo_mare, espuma, passo_mare, pesado_mare, vaga; arrebentacao, golpe_mare, mare_cheia, omega_mare
- Véu: circulo_veu, entardecer, fios_cinza, golpe_veu, omega_veu; final_veu, nevoa, passo_veu, pesado_veu

Pedido sugerido ao ChatGPT: manter fundo e moldura da família, mas trocar o selo pequeno por um **pictograma central grande
(cerca de 45% do disco) da ação** (ataque, especial, Brado, Investida, esquiva, Ômega, passivo), legível em cinza a 64 px.

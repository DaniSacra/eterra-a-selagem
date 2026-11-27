# GP-8: rooms painted by gpt-image-2 over game captures (2026-11-27)

Each `<room>.png` (1536x1024) is the API's repaint of `base_<room>.png` (a 16:9 game capture, no hero, no HUD) in the
style of the approved ChatGPT art. The painting is the base frame STRETCHED to 3:2: scale it back to 16:9 and it lies
over the capture (overlay test passed for the three: walls, platform edge, door, pillars within a few px).
Requests: Downloads\ASelagem-GP8\GPT-<room>\PEDIDO-PARA-O-GPT.txt plus rule 8 (no symbols on banners). Cost ~US$0.25 each.

Painter's cameras (game flags, all --showcase --no-hero --no-hud --seed=5):
- sala01: --cam-at=2,1 --cam-dist=68 (yaw 35, pitch 30, fov 24: the "game" pose of painted_hall.gd), 1920x1080
- sala00: --start=sala00 --no-arrival --cam-at=0,0 --cam-yaw=35 --cam-pitch=30 --cam-fov=24 --cam-dist=52, 2560x1440
- antessala: --start=ante --no-arrival --cam-at=0,0 --cam-yaw=35 --cam-pitch=30 --cam-fov=24 --cam-dist=80, 2560x1440

In the game: `PaintedHall.ROOMS` (scripts/game/painted_hall.gd) names each file and its pose; to swap a painting replace its png in assets/rooms/painted (same 3:2 stretch of the 16:9 base, same pose).

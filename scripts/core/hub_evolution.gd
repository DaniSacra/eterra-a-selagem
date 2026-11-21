class_name HubEvolution
extends RefCounted
## The Santuário grows with the save (HV-E, backlog P.5; docs/art/hv_santuario_vigilia_art.md 6.3), pure: what each
## station shows, read from the save, nothing written. Five states, each behind a flag (a piece whose feature is not
## in the game stays hidden):
##   E1 Forja: the temper rank bought (0 to 3, HubLook.set_forge_rank) and the tools hung up, each once its track was
##     used (a tool found but never used does not show: the first death never changes the hub).
##   E2 Vendedor: CLOSED (cloth over the goods, the awning half drawn) until the first Pedra Funda, ORDER ("Tem um
##     pedido": the order book on the counter), OPEN once the order was delivered; with the Obras made.
##   E3 Árvore: the Gift plates round the dais (one per Gift bought with Memória), lit by those opened; the Maestria's
##     level as how warm they read (never lighting a plate by itself).
##   E4 Livro: the spines on the shelves, one per chapter of the Compêndio found near whole (BOOK_SHARE; Morvath only
##     sealed), and the Ofícios shelf (shown with the mechanic) holding what the Ofícios made (tools, Obras).
##   E5 Alquimista: always the empty bench (flag off until Roteiro C).
## Nothing lights on a first descent lost: every state rises only by something bought, opened, delivered or sealed.
##
## API (Hub calls it on arrival and after every change; the environment-artist paints each state in HubLook):
##   var s := HubEvolution.of(Save.data, Hub.codex_chapters(Save.data)) -> State
##   HubEvolution.apply(look, s): look.set_forge_rank(s.forge_rank) and, when HubLook has them,
##     set_forge_tools(Array[StringName]), set_vendor(Stall state int, obras int), set_tree_plates(lit, total,
##     mastery level), set_book(spines, shelf shown, shelf items), set_alchemist(stocked). A method HubLook lacks is
##     skipped (nothing drawn for it yet).

enum Stall { HIDDEN, CLOSED, ORDER, OPEN }

## The flags (backlog HV-E): the Lote C (Ofícios) exists, so the Vendedor's states and the Ofícios shelf are on; the
## Alquimista waits for Roteiro C.
const FLAGS := {
	&"forge": true,
	&"vendor": true,
	&"tree": true,
	&"book": true,
	&"oficios_shelf": true,
	&"alchemist": false,
}
## A spine of the Livro per Compêndio chapter found at least this share (and the chapter not empty).
const BOOK_SHARE := 0.8
## The Livro's most spines (chapters counted).
const BOOK_SPINES := 7
## The Forja's tools and the track whose first purchase hangs each one up.
const TOOL_TRACK := {&"tool_refine": &"refine", &"tool_awaken": &"awaken", &"tool_inscribe": &"inscribe"}


class State:
	extends RefCounted
	var forge_rank := 0
	var forge_tools: Array[StringName] = []
	var vendor: Stall = Stall.HIDDEN
	var obras := 0
	var tree_lit := 0
	var tree_total := 0
	var mastery := 1
	var book_spines := 0
	var shelf := false
	var shelf_items := 0
	var alchemist_shown := false
	var alchemist_stocked := false

	## Anything grown past a new save's hub (the first death keeps it false).
	func grown() -> bool:
		return forge_rank > 0 or not forge_tools.is_empty() or vendor > Stall.CLOSED or obras > 0 or tree_lit > 0 \
			or book_spines > 0 or shelf_items > 0 or alchemist_stocked


## The hub's state for a save. `chapters` is the Compêndio, a Vector2i(found, total) per chapter (Hub.codex_chapters; empty:
## no spines); `flags` overrides FLAGS (tests).
static func of(data: Dictionary, chapters: Array[Vector2i] = [], flags: Dictionary = FLAGS) -> State:
	var s := State.new()
	if flags.get(&"forge", false):
		s.forge_rank = Forge.temper(data)
		for tool: StringName in TOOL_TRACK:
			if Forge.has_tool(data, tool) and Forge.rank_of(data, TOOL_TRACK[tool]) > 0:
				s.forge_tools.append(tool)
		var od := _oficios()
		if od != null and Oficios.has_tool(data, od):
			s.forge_tools.append(od.tool)
	if flags.get(&"vendor", false):
		var od := _oficios()
		if od != null:
			match Oficios.order_state(data, od):
				Oficios.Order.LOCKED:
					s.vendor = Stall.CLOSED
				Oficios.Order.OPEN:
					s.vendor = Stall.ORDER
				_:
					s.vendor = Stall.OPEN
			s.obras = (Oficios.block(data).recipes as Array).size()
	if flags.get(&"tree", false):
		var hero := HeroDef.warrior()
		var block := SaveData.hero(data, String(hero.id))
		var opened := Talents.opened_of(block)
		for t in hero.talents().catalog:
			if t.memory_cost > 0:
				s.tree_total += 1
				if opened.has(String(t.id)):
					s.tree_lit += 1
		s.mastery = hero.mastery.level_of(int(block.get("mastery_xp", 0)))
	if flags.get(&"book", false):
		for c in chapters:
			if c.y > 0 and float(c.x) >= BOOK_SHARE * c.y:
				s.book_spines += 1
		s.book_spines = mini(s.book_spines, BOOK_SPINES)
	if flags.get(&"oficios_shelf", false):
		s.shelf = true
		var b := Oficios.block(data)
		s.shelf_items = (b.tools as Array).size() + (b.recipes as Array).size()
	s.alchemist_shown = true  # (the empty bench stands from HV-A on; E5: it stays empty, nothing stocks it before
	# Roteiro C, whose flag is off)
	return s


## Paints the state on the hub (HubLook): only methods it has are called.
static func apply(look: Object, s: State) -> void:
	if look == null:
		return
	if look.has_method(&"set_forge_rank"):
		look.call(&"set_forge_rank", s.forge_rank)
	if look.has_method(&"set_forge_tools"):
		look.call(&"set_forge_tools", s.forge_tools)
	if look.has_method(&"set_vendor") and s.vendor != Stall.HIDDEN:
		look.call(&"set_vendor", int(s.vendor), s.obras)
	if look.has_method(&"set_tree_plates"):
		look.call(&"set_tree_plates", s.tree_lit, s.tree_total, s.mastery)
	if look.has_method(&"set_book"):
		look.call(&"set_book", s.book_spines, s.shelf, s.shelf_items)
	if look.has_method(&"set_alchemist"):
		look.call(&"set_alchemist", s.alchemist_stocked)


static func _oficios() -> OficiosDef:
	return OficiosDef.live()

class_name AngelDef
extends Resource
## An angel who brings the Blessings of one family (Rejogabilidade, Fatia 1; proposal in
## docs/design/rejogabilidade/sistemas.md 4, approved by Daniel 2026-11-19 with working names: Q-RJ4). A Malahym, a
## servant of Yah who carries a part of the light that comes from Elun; never its source, never a god. In the Fatia 1
## an angel is a seal (a medallion with its symbol and the family's colour, its name and a line of temperament), no
## figure. Data in data/angels/, written by _angels in tools/make_data.gd. Encounter draws two of them in every room of
## a Blessing and at the guardian; the cards of the one chosen are its family's (Encounter.belongs).

@export var id: StringName
## The family it brings (Boon.Family: CHAMA, GEADA, LUZ, VIGILIA; an Elo is two angels together).
@export var family: Boon.Family = Boon.Family.LUZ
## Text keys: its name and its line of temperament.
@export var name_key: StringName
@export var line_key: StringName
## Its seal's colour (the family's, never Morvath's red nor the corrupted emerald) and symbol (the UI draws it by this
## index: 0 the ember in a lozenge, 1 the six-armed flake, 2 the narrow beam over a lozenge, 3 the watchman's trumpet;
## never sun, cross, lion, raised sword, eye, lamp nor water).
@export var color := Color.WHITE
@export var symbol := 0

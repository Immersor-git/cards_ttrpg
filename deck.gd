class_name Deck
extends Node3D

@export var contents: Array[Enums.ManaType]
@export var manaTotals: Dictionary = {'Knots': 0, 'Teeth': 0, 'Guts': 0}
@export var type: Enums.DeckType

@onready var contents_display = $ContentsDisplay

var cardCount: int = 0
var isOwnedMesh:bool = false

func _process(delta):
	if multiplayer.is_server():
		cardCount = contents.size()
	updateDeckDisplaySize()
	updateContentsDisplay()

func updateContentsDisplay():
	const displayText = 'Teeth: %s
Knots: %s
Gut: %s'
	contents_display.text = displayText % [manaTotals['Teeth'], manaTotals['Knots'], manaTotals['Guts']]

func updateDeckDisplaySize():
	var deck_mesh_3d = $StaticBody3D/DeckMesh3D
	if !isOwnedMesh:
		deck_mesh_3d.mesh = deck_mesh_3d.mesh.duplicate()
		isOwnedMesh = true
	if cardCount == 0:
		deck_mesh_3d.hide()
	else:
		deck_mesh_3d.show()
		deck_mesh_3d.mesh.size.y = cardCount * 0.01

# func spawn deck (mana amounts)
func setDeckContents(knots: int, teeth: int, guts: int):
	manaTotals['Knots'] = knots
	manaTotals['Teeth'] = teeth
	manaTotals['Guts'] = guts
	for i in knots:
		contents.push_back(Enums.ManaType.KNOT)
	for i in teeth:
		contents.push_back(Enums.ManaType.TEETH)
	for i in guts:
		contents.push_back(Enums.ManaType.GUT)
	shuffle()

func shuffle():
	contents.shuffle()
	return

func drawCard(caster: Caster) -> Enums.ManaType:
	var drawnCardType = contents.pop_back()
	if drawnCardType == null:
		print("YOU DIED!! (message sent from drawCard function)")
		return -1
	updateManaTotals(drawnCardType, false)
	return drawnCardType

func drawNCards(amount: int, caster: Caster) -> Array[Enums.ManaType]:
	var drawnCards: Array[Enums.ManaType] = []
	for i in amount:
		drawnCards.push_back(drawCard(caster))
	return drawnCards

func addCard(manaType: Enums.ManaType):
	contents.push_back(manaType)
	updateManaTotals(manaType, true)

func addCards(manaTypes: Array[Enums.ManaType]):
	for manaType in manaTypes:
		addCard(manaType)

func updateManaTotals(manaType: Enums.ManaType, wasAdded: bool) -> void:
	var amountAdded := 1 if wasAdded else -1
	match manaType:
		Enums.ManaType.KNOT:
			manaTotals['Knots'] += amountAdded
		Enums.ManaType.TEETH:
			manaTotals['Teeth'] += amountAdded
		Enums.ManaType.GUT:
			manaTotals['Guts'] += amountAdded

class_name Deck
extends Node3D

@export var contents: Array[Enums.ManaType]
@export var type: Enums.DeckType
var isOwnedMesh:bool = false

# Called when the node enters the scene tree for the first time.
func _ready():
	updateDeckDisplaySize()
	#shuffle
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	updateDeckDisplaySize()

func updateDeckDisplaySize():
	var deck_mesh_3d = $StaticBody3D/DeckMesh3D
	if !isOwnedMesh:
		deck_mesh_3d.mesh = deck_mesh_3d.mesh.duplicate()
		isOwnedMesh = true
	if contents.size() == 0:
		deck_mesh_3d.hide()
	else:
		deck_mesh_3d.show()
		deck_mesh_3d.mesh.size.y = contents.size() * 0.01
	

# func spawn deck (mana amounts)
func setDeckContents(knots: int, teeth: int, guts: int):
	for i in knots:
		contents.push_back(Enums.ManaType.KNOT)
	for i in teeth:
		contents.push_back(Enums.ManaType.TEETH)
	for i in guts:
		contents.push_back(Enums.ManaType.GUT)
	shuffle()
	updateDeckDisplaySize()

func shuffle():
	contents.shuffle()
	return

func drawCard(caster: Caster) -> Enums.ManaType:
	var drawnCardType: Enums.ManaType = contents.pop_back()
	updateDeckDisplaySize()
	return drawnCardType

func drawNCards(amount: int, caster: Caster) -> Array[Enums.ManaType]:
	var drawnCards: Array[Enums.ManaType] = []
	for i in amount:
		drawnCards.push_back(drawCard(caster))
	return drawnCards

func addCard(manaType: Enums.ManaType):
	contents.push_back(manaType)
	updateDeckDisplaySize()

func addCards(manaTypes: Array[Enums.ManaType]):
	for manaType in manaTypes:
		addCard(manaType)

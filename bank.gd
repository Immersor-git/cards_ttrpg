@tool
class_name Bank
extends Node3D
var  GUT_PACKEDSCENE = load("res://Cards/Mana/Gut.tscn")
var KNOTS_PACKEDSCENE = load("res://Cards/Mana/Knots.tscn")
var TEETH_PACKEDSCENE = load("res://Cards/Mana/Teeth.tscn")
@export var caster: Node

var manaPool : Array[Mana] = []

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass

func updateManaPool():
	manaPool = []
	for manaInstanceIndex in get_children().size():
		var manaInstance = get_child(manaInstanceIndex)
		manaInstance.position = Vector3(manaInstanceIndex * 1.3,0,0)
		for mana in manaInstance.get_children():
			if mana is Mana:
				manaPool.append(mana)

func removeManaOfType(type: Array[Enums.ManaType]) -> Enums.ManaType:
	for manaInstance in get_children():
		for mana in manaInstance.get_children():
			if mana is Mana && type.has(mana.manaType.type):
				var removedCardManaType = mana.manaType.type
				manaInstance.free()
				updateManaPool()
				return removedCardManaType
	return -1;

func removeNManaOfType(amount: int, type: Array[Enums.ManaType]) -> Array[Enums.ManaType]:
	var removedMana: Array[Enums.ManaType] = []
	for x in amount:
		removedMana.push_back(removeManaOfType(type))
	return removedMana

func addManaCard(manaType: Enums.ManaType, caster: Caster):
	var manaCardInstance = instantiateManaCardInstance(manaType, caster)
	add_child(manaCardInstance)
	updateManaPool()

func addManaCards(manaTypes: Array[Enums.ManaType], caster: Caster):
	for manaType in manaTypes:
		add_child(instantiateManaCardInstance(manaType, caster))
	updateManaPool()

func instantiateManaCardInstance(manaType: Enums.ManaType, caster: Caster) -> Node3D:
	var mana: PackedScene
	match manaType:
		Enums.ManaType.KNOT:
			mana = KNOTS_PACKEDSCENE
			print('matched knot')
		Enums.ManaType.TEETH:
			mana = TEETH_PACKEDSCENE
			print('matched teeth')
		Enums.ManaType.GUT:
			mana = GUT_PACKEDSCENE
			print('matched gut')
	var manaCardInstance = mana.instantiate()
	for child in manaCardInstance.get_children():
		if child is Mana:
			print(child.manaType, child.manaTitle)
			child.caster = caster
	return manaCardInstance

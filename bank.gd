@tool
class_name Bank
extends Node3D
var  GUT_PACKEDSCENE = load("res://Cards/Mana/Gut.tscn")
var KNOTS_PACKEDSCENE = load("res://Cards/Mana/Knots.tscn")
var TEETH_PACKEDSCENE = load("res://Cards/Mana/Teeth.tscn")
var caster: Node

var syncableManaPool : Array[Enums.ManaType]
var manaPool : Array[Mana] = []

func _process(delta):
	if !Engine.is_editor_hint():
		if multiplayer.is_server():
			syncronizeCardsToClients()
		else:
			syncronizeCardsFromServer()

func set_caster(caster: Caster):
	self.caster = caster

func syncronizeCardsToClients():
	if syncableManaPool.size() != manaPool.size():
		for mana in manaPool:
			syncableManaPool.append(mana.manaType.type)

func syncronizeCardsFromServer():
	if manaPool.size() == 0:
		addManaCards(syncableManaPool)

func updateManaPool():
	manaPool = []
	for manaInstanceIndex in get_children().size():
		var manaInstance: Node3D = get_child(manaInstanceIndex)
		var newPos = Vector3(((manaInstanceIndex-3) * 1.3) + (1.3/2), 0.0, 0.0)
		if self.is_node_ready():
			var tween = create_tween()
			tween.set_ease(Tween.EASE_IN_OUT)
			tween.tween_property(manaInstance, "position", newPos, 0.25)
		else:
			manaInstance.position = newPos
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

func addManaCard(manaType: Enums.ManaType):
	var manaCardInstance = instantiateManaCardInstance(manaType)
	add_child(manaCardInstance)
	updateManaPool()

func addManaCards(manaTypes: Array[Enums.ManaType]):
	for manaType in manaTypes:
		add_child(instantiateManaCardInstance(manaType))
	updateManaPool()

func instantiateManaCardInstance(manaType: Enums.ManaType) -> Node3D:
	var mana: PackedScene
	match manaType:
		Enums.ManaType.KNOT:
			mana = KNOTS_PACKEDSCENE
		Enums.ManaType.TEETH:
			mana = TEETH_PACKEDSCENE
		Enums.ManaType.GUT:
			mana = GUT_PACKEDSCENE
	var manaCardInstance = mana.instantiate()
	for child in manaCardInstance.get_children():
		if child is Mana:
			child.caster = caster
	return manaCardInstance

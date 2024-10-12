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
		syncableManaPool = []
		for mana in manaPool:
			syncableManaPool.append(mana.manaType.type)

func syncronizeCardsFromServer():
	if syncableManaPool.size() != manaPool.size():
			var manaTooAdd = []
			var diffMana = {Enums.ManaType.KNOT: 0, Enums.ManaType.TEETH: 0, Enums.ManaType.GUT: 0}
			for manaInServerPool in syncableManaPool:
				diffMana[manaInServerPool] += 1
			for manaInLocalPool in manaPool:
				diffMana[manaInLocalPool.manaType.type] -= 1
			fixDiffForManaOfType(diffMana, Enums.ManaType.KNOT)
			fixDiffForManaOfType(diffMana, Enums.ManaType.TEETH)
			fixDiffForManaOfType(diffMana, Enums.ManaType.GUT)


func fixDiffForManaOfType(diffMana: Dictionary, manaType: Enums.ManaType):
	if diffMana[manaType] > 0:
		var manaOfTypeToAdd: Array[Enums.ManaType] = []
		for i in diffMana[manaType]:
			manaOfTypeToAdd.append(manaType)
		addManaCards(manaOfTypeToAdd)
	elif diffMana[manaType] < 0:
		removeNManaOfType(-diffMana[manaType], [manaType])

func updateManaPool():
	manaPool = []
	var validManaInstances = get_children().filter(
		func (manaInstance):
			for mana in manaInstance.get_children():
				if mana is Mana && !mana.queued_free:
					return true
			return false)
	for manaInstanceIndex in validManaInstances.size():
		var manaInstance: Node3D = validManaInstances[manaInstanceIndex]
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
			if mana is Mana && type.has(mana.manaType.type) && !mana.queued_free:
				var removedCardManaType = mana.manaType.type
				manaInstance.queue_free()
				mana.queued_free = true
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

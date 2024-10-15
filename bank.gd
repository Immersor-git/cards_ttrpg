@tool
class_name Bank
extends Node3D
var  GUT_PACKEDSCENE = load("res://Cards/Mana/Gut.tscn")
var KNOTS_PACKEDSCENE = load("res://Cards/Mana/Knots.tscn")
var TEETH_PACKEDSCENE = load("res://Cards/Mana/Teeth.tscn")
var caster: Node

var syncableManaPool : Array[Enums.ManaType]
var manaPool : Array[Mana] = []

@onready var bank_spawner = $"../BankSpawner"

func _ready():
	bank_spawner.spawned.connect(serverAddManaToBank)
	bank_spawner.despawned.connect(serverRemoveManaFromBank)

func set_caster(caster: Caster):
	self.caster = caster

func serverAddManaToBank(node: Node):
	for child in node.get_children():
		if child is Mana:
			child.caster = caster
	updateManaPool()

func serverRemoveManaFromBank(node: Node):
	updateManaPool()

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

func getManaOfType(manaType: Enums.ManaType) -> Mana:
	for manaInstance in get_children():
		for mana in manaInstance.get_children():
			if mana is Mana && manaType == mana.manaType.type && !mana.queued_free:
				return mana
	return null

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
	manaCardInstance.name = "%s%s" % [manaCardInstance.name, manaCardInstance.get_instance_id()]
	for child in manaCardInstance.get_children():
		if child is Mana:
			child.caster = caster
	return manaCardInstance

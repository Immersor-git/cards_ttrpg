@tool
class_name Bank
extends Node3D

@export var bank : Array[PackedScene]
@export var caster: Node
var manaPool : Array[Mana] = []

# Called when the node enters the scene tree for the first time.
func _ready():
	spawnBank(bank)
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

func removeManaOfType(type: Array[String]) -> bool:
	for manaInstance in get_children():
		for mana in manaInstance.get_children():
			if mana is Mana && type.has(mana.manaType.title):
				manaInstance.free()
				updateManaPool()
				return true;
	return false;

func removeNManaOfType(amount: int, type: Array[String]):
	for x in amount:
		print("removing")
		print(get_children())
		print(removeManaOfType(type))

func instMana(pos, mana):
	var instance = mana.instantiate()
	instance.position = pos
	instance.get
	for child in instance.get_children():
		if child is Mana:
			child.caster = caster
			manaPool.append(child)
	add_child(instance)

func spawnBank(bank):
	#while count < hand.length:
		#instCard(Vector3(count * 1.3 - offset,0,4.75))
		#count = count + 1
	for card_index in bank.size():
		instMana(Vector3(card_index * 1.3,0,0), bank[card_index])

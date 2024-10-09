#@tool
extends Node3D

@export var bank : Array[PackedScene]
@export var caster: Node

# Called when the node enters the scene tree for the first time.
func _ready():
	spawnBank(bank)
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass

func instMana(pos, mana):
	var instance = mana.instantiate()
	instance.position = pos
	instance.get
	add_child(instance)

func spawnBank(bank):
	#while count < hand.length:
		#instCard(Vector3(count * 1.3 - offset,0,4.75))
		#count = count + 1
	for card_index in bank.size():
		instMana(Vector3(card_index * 1.3,0,0), bank[card_index])

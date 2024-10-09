@tool
extends Node3D

@export var hand : Array[PackedScene]
@export var caster: Node

# Called when the node enters the scene tree for the first time.
func _ready():
	spawnHand(hand)
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass

func instCard(pos, card):
	var instance = card.instantiate()
	instance.position = pos
	instance.get
	add_child(instance)

func spawnHand(hand):
	var offset = .65 * (hand.size() -1)
	#while count < hand.length:
		#instCard(Vector3(count * 1.3 - offset,0,4.75))
		#count = count + 1
	for card_index in hand.size():
		instCard(Vector3(card_index * 1.3 - offset,0,4.75), hand[card_index])

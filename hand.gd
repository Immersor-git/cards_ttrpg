@tool
extends Node3D

@export var handSize : int
var card = preload("res://card.tscn")

# Called when the node enters the scene tree for the first time.
func _ready():
	instHand(handSize)
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass

func instCard(pos):
	var instance = card.instantiate()
	instance.position = pos
	add_child(instance)

func instHand(handSize):
	var count = 0
	while count < handSize:
		instCard(Vector3(count * 1.3 - 3.25,0,4.75))
		count = count + 1

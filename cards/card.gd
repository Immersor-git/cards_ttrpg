@tool
class_name Card
extends Node3D

@export var card: AbilityCard
@onready var cardTitle = $CardTitle
var components : Array[Node]

# Called when the node enters the scene tree for the first time.
func _ready():
	updateCardTitle()
	var children : Array = self.get_children()
	for child in children:
		if child.name == "Components":
			components = child.get_children()
	pass # Replace with function body.

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if Engine.is_editor_hint():
		updateCardTitle()
	pass

func updateCardTitle():
	if card != null :
		cardTitle.text = card.title
	else:
		cardTitle.text = ''

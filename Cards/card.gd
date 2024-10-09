@tool
class_name Card
extends Node3D

@export var card: AbilityCard
@onready var cardTitle = $CardTitle
@onready var description = $Description

var components : Array[AbstractComponent] = []
var caster: Node

# Called when the node enters the scene tree for the first time.
func _ready():
	updateCardTitle()
	var children : Array = self.get_children()
	for child in children:
		if child.name == "Components":
			for component in child.get_children():
				if component is AbstractComponent:
					components.append(component)
					description.text += " " + component.castAbilityDescription()
	pass # Replace with function body.

func castEffect():
	for component in components:
		component.handleCastEffect(caster)

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

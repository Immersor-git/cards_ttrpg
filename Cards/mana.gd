@tool
class_name Mana
extends Node3D

@export var manaType: ManaType
@onready var manaTitle = $ManaTitle
@onready var material = $StaticBody3D/MeshInstance3D

var caster: Node

# Called when the node enters the scene tree for the first time.
func _ready():
	updateManaTitle()
	pass # Replace with function body.

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if Engine.is_editor_hint():
		#updateCardComponents()
		updateManaTitle()
	pass
	
func updateManaTitle():
	if manaType != null :
		manaTitle.text = manaType.title
		material.set_surface_override_material(0, manaType.color)
	else:
		manaTitle.text = ''

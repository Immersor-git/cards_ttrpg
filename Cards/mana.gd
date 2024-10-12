@tool
class_name Mana
extends Node3D

@export var manaType: ManaType
@onready var manaTitle = $ManaTitle
@onready var material = $StaticBody3D/MeshInstance3D

var components: Array[AbstractComponent] = []
var caster: Node

signal discard_mana(mana: Mana)

# Called when the node enters the scene tree for the first time.
func _ready():
	updateCardComponents()
	updateManaTitle()
	pass # Replace with function body.

func enterDiscard():
	for component in components:
		component.handleCastEffect(caster)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if Engine.is_editor_hint():
		updateManaTitle()

func updateCardComponents():
	var children : Array = self.get_children()
	for child in children:
		if child.name == "Components":
			for component in child.get_children():
				if component is AbstractComponent:
					components.append(component)
	
func updateManaTitle():
	if manaType != null :
		manaTitle.text = manaType.title
		material.set_surface_override_material(0, manaType.color)
	else:
		manaTitle.text = ''

func _on_card_click(camera, event: InputEvent, event_position: Vector3, normal, shape_idx):
	if event is InputEventMouseButton && event.is_action_pressed("left_click"):
		discard_mana.emit(self)

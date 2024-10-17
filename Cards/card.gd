@tool
class_name Card
extends Node3D

@export var card: AbilityCard
@onready var cardTitle = $CardTitle
@onready var description = $Description
@onready var hitbox = $StaticBody3D/CollisionShape3D
@onready var cardCost = $Cost

var currentState : Enums.CardState = Enums.CardState.DEFAULT
var components: Array[AbstractComponent] = []
var caster: Caster
var componentsQueue: Array[AbstractComponent]

signal cast_card(pathToCard: String)

# Called when the node enters the scene tree for the first time.
func _ready():
	updateCardComponents()
	updateCardText()
	pass

func cancelCast():
	self.currentState = Enums.CardState.DEFAULT
	componentsQueue = []

func castEffect():
	currentState = Enums.CardState.CASTING_IN_PROGRESS
	for component in components:
		componentsQueue.append(component)

func processComponentQueue():
	if currentState == Enums.CardState.CASTING_IN_PROGRESS:
		while componentsQueue.size() != 0:
			var componentToTryCastEffect = componentsQueue[0]
			var isBlocking = componentToTryCastEffect.handleCastEffect(caster)
			if isBlocking:
				return
			componentsQueue.pop_front()
		currentState = Enums.CardState.DEFAULT

func startTurnEffect():
	for component in components:
		component.handleStartTurn(caster)

func set_caster(caster: Caster):
	self.caster = caster

func _process(delta):
	if Engine.is_editor_hint():
		updateCardComponents()
		updateCardText()
	else:
		processComponentQueue()


func updateCardComponents():
	description.text = ""
	var children : Array = self.get_children()
	for child in children:
		if child.name == "Components":
			for component in child.get_children():
				if component is AbstractComponent:
					components.append(component)
					description.text += " " + component.castAbilityDescription()
	
func updateCardText():
	if card != null :
		cardTitle.text = card.title
		cardCost.text = card.costString()
	else:
		cardTitle.text = ''


func _on_card_click(camera, event: InputEvent, event_position: Vector3, normal, shape_idx):
	if event is InputEventMouseButton && event.is_action_pressed("left_click") && caster.caster_id == multiplayer.get_unique_id():
		cast_card.emit(self.get_path())

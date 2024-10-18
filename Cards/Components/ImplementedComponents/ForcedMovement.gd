@tool
extends AbstractComponent

## Should check for collision with casters/obstacles
@export var checkForCollision := true
## Number of spaces in a straight line
@export var spacesToMove := 1
var displayedCasterUI := false

func _process(_delta):
	if !Engine.is_editor_hint() && multiplayer.is_server():
		if card.caster.currentState == Enums.PlayerState.PLANNING_ATTACK:
			print("PLANNING ATTACK")
		else:
			displayedCasterUI = false


func handleCastEffect() -> bool:
	if !displayedCasterUI:
		updateCasterState.rpc_id(card.caster.caster_id)
	
	if displayedCasterUI && card.caster.currentState != Enums.PlayerState.PLANNING_ATTACK:
		card.cancelCast()
	return true

@rpc("any_peer", "call_local", "reliable")
func acknowledgeCasterDisplay():
	displayedCasterUI = true

@rpc("any_peer", "call_local", "reliable")
func updateCasterState():
	card.caster.currentState = Enums.PlayerState.PLANNING_ATTACK
	acknowledgeCasterDisplay.rpc()

func _client_click_board(clickedPosition: Vector2):
	setAttackDirection.rpc(clickedPosition)

@rpc("any_peer", "call_local", "reliable")
func setAttackDirection(_clickedPosition: Vector2):
	pass

func handleStartTurn():
	pass

func castAbilityDescription() -> String:
	return ""

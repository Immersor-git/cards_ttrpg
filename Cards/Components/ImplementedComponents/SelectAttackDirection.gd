@tool
class_name SelectAttackDirectionComponent
extends AbstractComponent

var displayedCasterUI := false
var selectedDireaction

func _process(_delta):
	if !Engine.is_editor_hint():
		var componentCaster = componentOwner.get('caster')
		if componentCaster:
			if componentCaster is Caster:
				if multiplayer.get_unique_id() == componentCaster.caster_id:
					if componentCaster.currentState == Enums.PlayerState.PLANNING_ATTACK:
						var piecePositionOnScreen = componentCaster.camera.unproject_position(componentCaster.board_piece.global_position)
						var mousePoisitonOnScreen = componentCaster.camera.get_viewport().get_mouse_position()
						var directionToMouse = piecePositionOnScreen.direction_to(mousePoisitonOnScreen)
						var cardinal_direction = int(4.0 * (directionToMouse.rotated(PI / 4.0).angle() + PI) / TAU)
						if cardinal_direction == 0:
							print("WEST")
						elif cardinal_direction == 1:
							print("NORTH")
						elif cardinal_direction == 2:
							print("EAST")
						elif cardinal_direction == 3:
							print("SOUTH")
					else:
						displayedCasterUI = false


func handleCastEffect() -> bool:
	var componentCaster = componentOwner.get('caster')
	if componentCaster:
		if componentCaster is Caster:
			if !displayedCasterUI:
				updateCasterState.rpc_id(componentCaster.caster_id)
			
			if displayedCasterUI && componentCaster.currentState != Enums.PlayerState.PLANNING_ATTACK:
				if componentOwner.has_method('cancelCast'):
					componentOwner.cancelCast()
	return true

@rpc("any_peer", "call_local", "reliable")
func acknowledgeCasterDisplay():
	displayedCasterUI = true

@rpc("any_peer", "call_local", "reliable")
func updateCasterState():
	var componentCaster = componentOwner.get('caster')
	if componentCaster:
		if componentCaster is Caster:
			componentCaster.currentState = Enums.PlayerState.PLANNING_ATTACK
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

@tool
class_name SelectAttackDirectionComponent
extends AbstractComponent

var attackIndicator = preload('res://BoardAttackHighlight.tscn')

var displayedCasterUI := false
var selectedDirection: Enums.CardinalDirection = Enums.CardinalDirection.NONE

var hasDebouncedLeftClick := false
func _process(_delta):
	if !Engine.is_editor_hint():
		var componentCaster = componentOwner.get('caster')
		if componentCaster:
			if componentCaster is Caster:
				if multiplayer.get_unique_id() == componentCaster.caster_id:
					if componentCaster.currentState == Enums.PlayerState.PLANNING_ATTACK:
						if !hasDebouncedLeftClick && !Input.is_action_just_pressed("left_click"):
							hasDebouncedLeftClick = true
						var piecePositionOnScreen = componentCaster.camera.unproject_position(componentCaster.board_piece.global_position)
						var mousePoisitonOnScreen = componentCaster.camera.get_viewport().get_mouse_position()
						var directionToMouse = piecePositionOnScreen.direction_to(mousePoisitonOnScreen)
						var cardinal_direction = int(4.0 * (directionToMouse.rotated(componentCaster.global_rotation.y).rotated(PI / 4.0).angle() + PI) / TAU)
						var boardAttackIndicator
						for child in componentCaster.board_piece.get_children():
							boardAttackIndicator = child
						if !boardAttackIndicator:
							var attackIndicatorInst = attackIndicator.instantiate()
							componentCaster.board_piece.add_child(attackIndicatorInst)
						var hoveringDirection: Enums.CardinalDirection
						if cardinal_direction == 0:
							hoveringDirection = Enums.CardinalDirection.WEST
							componentCaster.board_piece.global_rotation_degrees = Vector3(0, 90, 0)
						elif cardinal_direction == 1:
							hoveringDirection = Enums.CardinalDirection.NORTH
							componentCaster.board_piece.global_rotation_degrees = Vector3(0, 0, 0)
						elif cardinal_direction == 2:
							hoveringDirection = Enums.CardinalDirection.EAST
							componentCaster.board_piece.global_rotation_degrees = Vector3(0, 270, 0)
						elif cardinal_direction == 3:
							hoveringDirection = Enums.CardinalDirection.SOUTH
							componentCaster.board_piece.global_rotation_degrees = Vector3(0, 180, 0)
						if Input.is_action_just_pressed("left_click") && hasDebouncedLeftClick:
							print("SELECTED DIRECTION !!", hoveringDirection)
							setAttackDirection.rpc(hoveringDirection)
							boardAttackIndicator.queue_free()
				else:
					var boardAttackIndicator
					for child in componentCaster.board_piece.get_children():
							boardAttackIndicator = child
					if boardAttackIndicator:
						boardAttackIndicator.queue_free()


func handleCastEffect() -> bool:
	if multiplayer.is_server():
		var componentCaster = componentOwner.get('caster')
		if componentCaster:
			if componentCaster is Caster:
				if !displayedCasterUI:
					updateCasterState.rpc_id(componentCaster.caster_id, Enums.PlayerState.PLANNING_ATTACK)
				
				# if displayedCasterUI && componentCaster.currentState != Enums.PlayerState.PLANNING_ATTACK && selectedDirection == Enums.CardinalDirection.NONE:
				# 	if componentOwner.has_method('cancelCast'):
				# 		print("cancelling")
				# 		componentOwner.cancelCast()
				# 		return true
		#print("CASTING SELECT ATTACK DIR isBlocking --- ", selectedDirection == Enums.CardinalDirection.NONE)
		return selectedDirection == Enums.CardinalDirection.NONE
	return false

@rpc("any_peer", "call_local", "reliable")
func acknowledgeCasterDisplay():
	displayedCasterUI = true

@rpc("any_peer", "call_local", "reliable")
func updateCasterState(playerState: Enums.PlayerState):
	hasDebouncedLeftClick = false
	var componentCaster = componentOwner.get('caster')
	if componentCaster:
		if componentCaster is Caster:
			print(componentCaster.caster_id)
			if multiplayer.get_unique_id() == componentCaster.caster_id:
				print("UPDATING CASTER STATE !!! IMPORTANT")
				componentCaster.currentState = playerState
	acknowledgeCasterDisplay.rpc()

@rpc("any_peer", "call_local", "reliable")
func setAttackDirection(cardinalDirection: Enums.CardinalDirection):
	if multiplayer.is_server():
		print("setting dir - ", cardinalDirection)
		selectedDirection = cardinalDirection
		var componentCaster = componentOwner.get('caster')
		if componentCaster:
			if componentCaster is Caster:
				updateCasterState.rpc_id(componentCaster.caster_id, Enums.PlayerState.OBSERVING_BOARD)

func handleStartTurn():
	hasDebouncedLeftClick = false
	selectedDirection = Enums.CardinalDirection.NONE
	displayedCasterUI = false

func castAbilityDescription() -> String:
	return ""

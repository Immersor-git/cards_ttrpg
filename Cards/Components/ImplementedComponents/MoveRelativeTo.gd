@tool
extends AbstractComponent

enum RelativeDirection {FORWARD = 0, LEFT = -1, RIGHT = 1, BACK = 2, FORWARD_LEFT = 4, FORWARD_RIGHT = 5, BACK_LEFT = 6, BACK_RIGHT = 3}

@export var selectedAttackDirection: SelectAttackDirectionComponent
@export var relativeDirection: RelativeDirection
@export var squaresToMove := 1
var pieceFullyMoved = false
var pieceStartedMoving = false

func _ready():
	#TODO: Run when componentOwner is set
	#if !selectedAttackDirection:
		#var components = componentOwner.get('components')
		#if components:
			#for component in components:
				#if component is SelectAttackDirectionComponent:
					#selectedAttackDirection = component
	pass

func handleCastEffect() -> bool:
	if !pieceStartedMoving:
		pieceStartedMoving = true
		var componentCaster = componentOwner.get('caster')
		if componentCaster:
			if componentCaster is Caster:
				var moveDir: Vector2
				if [RelativeDirection.FORWARD, RelativeDirection.LEFT, RelativeDirection. RIGHT, RelativeDirection.BACK].has(relativeDirection):
					var cardinalMoveDirection = (selectedAttackDirection.selectedDirection as int + relativeDirection as int) % 4
					if cardinalMoveDirection < 0:
						cardinalMoveDirection +=  4
					print("CARDINAL MOVE DIR = ", cardinalMoveDirection)
					if cardinalMoveDirection == 0:
						moveDir = Vector2(-1, 0)
					if cardinalMoveDirection == 1:
						moveDir = Vector2(0, -1)
					if cardinalMoveDirection == 2:
						moveDir = Vector2(1, 0)
					if cardinalMoveDirection == 3:
						moveDir = Vector2(0, 1)
				else:
					var diagonalMoveDirection = (selectedAttackDirection.selectedDirection as int + (relativeDirection as int - 4)) % 4
					if [Enums.CardinalDirection.SOUTH, Enums.CardinalDirection.EAST].has(selectedAttackDirection.selectedDirection):
						diagonalMoveDirection = (selectedAttackDirection.selectedDirection as int - (relativeDirection as int - 4)) % 4
					if diagonalMoveDirection < 0:
						diagonalMoveDirection += 4
					#if [Enums.CardinalDirection.WEST].has(selectedAttackDirection.selectedDirection):
						#diagonalMoveDirection += 2
					#if [Enums.CardinalDirection.EAST].has(selectedAttackDirection.selectedDirection):
						#diagonalMoveDirection -= 2
					#diagonalMoveDirection = abs(diagonalMoveDirection % 4)
					print("selectedDirection ~ ", selectedAttackDirection.selectedDirection, '; relativeDirection ~ ', relativeDirection)
					print("DIAGONAL MOVE DIR = ", diagonalMoveDirection)
					var forwardRight = (selectedAttackDirection.selectedDirection == Enums.CardinalDirection.NORTH && relativeDirection == RelativeDirection.FORWARD_RIGHT) \
						|| (selectedAttackDirection.selectedDirection == Enums.CardinalDirection.EAST && relativeDirection == RelativeDirection.FORWARD_LEFT) \
						|| (selectedAttackDirection.selectedDirection == Enums.CardinalDirection.WEST && relativeDirection == RelativeDirection.BACK_RIGHT) \
						|| (selectedAttackDirection.selectedDirection == Enums.CardinalDirection.SOUTH && relativeDirection == RelativeDirection.BACK_LEFT)
					
					var forwardLeft = (selectedAttackDirection.selectedDirection == Enums.CardinalDirection.NORTH && relativeDirection == RelativeDirection.FORWARD_LEFT) \
						|| (selectedAttackDirection.selectedDirection == Enums.CardinalDirection.EAST && relativeDirection == RelativeDirection.BACK_LEFT) \
						|| (selectedAttackDirection.selectedDirection == Enums.CardinalDirection.WEST && relativeDirection == RelativeDirection.FORWARD_RIGHT) \
						|| (selectedAttackDirection.selectedDirection == Enums.CardinalDirection.SOUTH && relativeDirection == RelativeDirection.BACK_RIGHT)
					
					var backRight = (selectedAttackDirection.selectedDirection == Enums.CardinalDirection.NORTH && relativeDirection == RelativeDirection.BACK_RIGHT) \
						|| (selectedAttackDirection.selectedDirection == Enums.CardinalDirection.EAST && relativeDirection == RelativeDirection.FORWARD_RIGHT) \
						|| (selectedAttackDirection.selectedDirection == Enums.CardinalDirection.WEST && relativeDirection == RelativeDirection.BACK_LEFT) \
						|| (selectedAttackDirection.selectedDirection == Enums.CardinalDirection.SOUTH && relativeDirection == RelativeDirection.FORWARD_LEFT)
					
					var backLeft = (selectedAttackDirection.selectedDirection == Enums.CardinalDirection.NORTH && relativeDirection == RelativeDirection.BACK_LEFT) \
						|| (selectedAttackDirection.selectedDirection == Enums.CardinalDirection.EAST && relativeDirection == RelativeDirection.BACK_RIGHT) \
						|| (selectedAttackDirection.selectedDirection == Enums.CardinalDirection.WEST && relativeDirection == RelativeDirection.FORWARD_LEFT) \
						|| (selectedAttackDirection.selectedDirection == Enums.CardinalDirection.SOUTH && relativeDirection == RelativeDirection.FORWARD_RIGHT)
					if backRight:
						moveDir = Vector2(1, 1)
					if forwardLeft:
						moveDir = Vector2(-1, -1)
					if forwardRight:
						moveDir = Vector2(1, -1)
					if backLeft:
						moveDir = Vector2(-1, 1)
				var moves: Array[Vector3] = []
				for _moveNum in squaresToMove:
					var locationToMoveTo = componentCaster.boardPosition + moveDir
					var boardSize = componentCaster.board.size - Vector2(1, 1)
					if locationToMoveTo.x > boardSize.x || locationToMoveTo.y > boardSize.y || locationToMoveTo.x < 0 || locationToMoveTo.y < 0:
						break
					var boardOccupiers = get_tree().get_nodes_in_group('boardOccupying')
					for boardOccupier in boardOccupiers:
						if boardOccupier != componentCaster && boardOccupier.boardPosition == locationToMoveTo:
							movePiece(moves)
							return !pieceFullyMoved
					componentCaster.boardPosition = locationToMoveTo
					moves.append(componentCaster.board.boardToWorldCoord(componentCaster.boardPosition))
				movePiece(moves)
	return !pieceFullyMoved

func movePiece(moveArray: Array[Vector3]):
	if multiplayer.is_server():
		if moveArray.size() == 0:
			pieceFullyMoved = true
			return

	var componentCaster = componentOwner.get('caster')
	if componentCaster:
		if componentCaster is Caster:
			print("STARTING TWEEN MOVE")
			var tween = create_tween()
			tween.tween_property(componentCaster.board_piece, "global_position", moveArray.pop_front(), 0.5)
			get_tree().create_timer(0.5).timeout.connect(func(): movePiece(moveArray))

func handleStartTurn():
	pieceStartedMoving = false
	pieceFullyMoved = false
	pass

func castAbilityDescription() -> String:
	return "Move %s" % squaresToMove

@tool
extends AbstractComponent

enum RelativeDirection {FORWARD = 0, LEFT = -1, RIGHT = 1, BACK = 2}

@export var selectedAttackDirection: SelectAttackDirectionComponent
@export var relativeDirection: RelativeDirection
@export var squaresToMove := 1
var pieceFullyMoved = false
var pieceStartedMoving = false

func _ready():
	if !selectedAttackDirection:
		var components = componentOwner.get('components')
		if components:
			for component in components:
				if component is SelectAttackDirectionComponent:
					selectedAttackDirection = component

func handleCastEffect() -> bool:
	if !pieceStartedMoving:
		pieceStartedMoving = true
		var componentCaster = componentOwner.get('caster')
		if componentCaster:
			if componentCaster is Caster:
				var cardinalMoveDirection = selectedAttackDirection.selectedDirection as int + relativeDirection as int % 4
				var moveDir: Vector2
				if cardinalMoveDirection == 0:
					moveDir = Vector2(-1, 0)
				if cardinalMoveDirection == 1:
					moveDir = Vector2(0, -1)
				if cardinalMoveDirection == 2:
					moveDir = Vector2(1, 0)
				if cardinalMoveDirection == 3:
					moveDir = Vector2(0, 1)
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

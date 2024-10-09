@tool
extends Node3D

@export var boardPosition : Vector2 = Vector2(0, 0)
@export var board: Board

func _ready():
	global_position = board.boardToWorldCoord(boardPosition)

func _process(delta):
	if Engine.is_editor_hint():
		global_position = board.boardToWorldCoord(boardPosition)

func heal(healAmount: int):
	print("Would Add %d Cards to Deck" % healAmount)

func move(moveToBoardPosition: Vector2):
	boardPosition = moveToBoardPosition

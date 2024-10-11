@tool
class_name Caster
extends Node3D

@export var boardPosition : Vector2 = Vector2(0, 0)
@export var board: Board
@export var hand: Hand
@export var bank: Bank
@export var manaTotals: Dictionary = {'Knots': 11, 'Teeth': 11, 'Guts': 11}
@export var deck: Deck
@export var discard: Deck
@export var camera: Camera3D
var basicMovesAvailable: int = 0
var currentState: Enums.PlayerState = Enums.PlayerState.SITTING_NEUTRAL

func _ready():
	setupBoardstate()
	global_position = board.boardToWorldCoord(boardPosition)
	InputMap.load_from_project_settings()

func _process(delta):
	if Engine.is_editor_hint():
		if board != null:
			global_position = board.boardToWorldCoord(boardPosition)
	else:
		updateCurrentState()
		for card in hand.cards:
			if !card.is_connected(card.cast_card.get_name(), self.try_cast_card):
				card.cast_card.connect(self.try_cast_card)
		if !board.is_connected(board.send_clicked_square.get_name(), self.try_move):
				board.send_clicked_square.connect(self.try_move)
		

func heal(healAmount: int):
	healAmount = min(healAmount, discard.contents.size())
	var healedCards: Array[Enums.ManaType] = discard.drawNCards(healAmount, self)
	deck.addCards(healedCards)
	deck.shuffle()
	pass

func try_cast_card(card: Card):
	print("casting %s" % card.card.title)
	print(card.card.costType)
	var validMana = bank.manaPool.filter(func(mana: Mana): return card.card.costType.has(mana.manaType.type))
	print(validMana)
	if validMana.size() >= card.card.costAmount:
		var removedManaTypes = bank.removeNManaOfType(card.card.costAmount, card.card.costType)
		discard.addCards(removedManaTypes)
		card.castEffect()

func try_move(targetSquare):
	var distanceVector: Vector2 = abs(targetSquare - boardPosition)
	var movesNeeded = max(distanceVector.x, distanceVector.y)
	if currentState == Enums.PlayerState.MOVING_PIECE:
		if movesNeeded <= basicMovesAvailable:
			boardPosition = targetSquare
			global_position = board.boardToWorldCoord(boardPosition)
			basicMovesAvailable -= movesNeeded
			print("you have %s basic moves remaining" % basicMovesAvailable)
		else:
			print("You Don't Have Enough Moves!")
	pass

func setupBoardstate():
	deck.setDeckContents(manaTotals.get('Knots'), manaTotals.get('Teeth'), manaTotals.get('Guts'))
	var drawnCards := deck.drawNCards(6, self)
	bank.addManaCards(drawnCards, self)

func updateCurrentState():
	if Input.is_action_just_pressed("move_back"):
		currentState = Enums.PlayerState.SITTING_NEUTRAL
		print("currentState is", currentState)
		camera.global_position = Vector3(0, 5.409, 10.632)
		camera.global_rotation_degrees = Vector3(-24.2, 0, 0)
	if Input.is_action_just_pressed("move_forward") && currentState == Enums.PlayerState.SITTING_NEUTRAL:
		currentState = Enums.PlayerState.MOVING_PIECE
		print("currentState is", currentState)
		camera.global_position = Vector3(0, 5.409, 5.632)
		camera.global_rotation_degrees = Vector3(-50, 0, 0)

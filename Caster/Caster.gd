@tool
class_name Caster
extends Node3D

@export var boardPosition : Vector2 = Vector2(0, 0)
@export var board: Board
@export var hand: Hand
@export var bank: Bank
@export var manaTotals: Dictionary = {'Knots': 11, 'Teeth': 11, 'Guts': 11}
@export var abilityCards : Array[PackedScene]
@export var deck: Deck
@export var discard: Deck
@export var camera: Camera3D
@export var is_casters_turn := false

var basicMovesAvailable: int = 0
var currentState: Enums.PlayerState = Enums.PlayerState.SITTING_NEUTRAL
var caster_id := 1:
	set(id):
		caster_id = id
var team_id := 0

@onready var board_piece = $MeshInstance3D
@onready var seated_neutral = $SeatedNeutral
@onready var observing_board = $ObservingBoard

func _ready():
	bank.set_caster(self)
	hand.set_caster(self)
	board = get_tree().get_current_scene().get_node("World/Board/Checkerboard")
	if multiplayer.is_server():
		setupBoardstate()
		board_piece.global_position = board.boardToWorldCoord(boardPosition)
	if multiplayer.get_unique_id() == caster_id:
		camera.make_current()
	else:
		camera.queue_free()
	InputMap.load_from_project_settings()

func _process(delta):
	if Engine.is_editor_hint():
		if board != null:
			board_piece.global_position = board.boardToWorldCoord(boardPosition)
	else:
		updateCurrentState()
		for card in hand.cards:
			if !card.is_connected(card.cast_card.get_name(), self._client_try_cast_card):
				card.cast_card.connect(self._client_try_cast_card)
		for manaCard in bank.manaPool:
			if is_instance_valid(manaCard) && !manaCard.is_connected(manaCard.discard_mana.get_name(), self._client_discard_mana):
				manaCard.discard_mana.connect(self._client_discard_mana)
		if !board.is_connected(board.send_clicked_square.get_name(), self._client_try_move):
				board.send_clicked_square.connect(self._client_try_move)

func set_player_number(player_num: int):
	self.team_id = player_num
	if player_num == 1:
		self.global_rotation_degrees = Vector3(0, 180, 0)
		boardPosition = Vector2(0, 0)
	elif player_num == 2:
		self.global_rotation_degrees = Vector3(0, 90, 0)
	elif player_num == 3:
		self.global_rotation_degrees = Vector3(0, 270, 0)

func heal(healAmount: int):
	healAmount = min(healAmount, discard.contents.size())
	var healedCards: Array[Enums.ManaType] = discard.drawNCards(healAmount, self)
	deck.addCards(healedCards)
	deck.shuffle()
	pass

func _client_try_cast_card(pathToCard: String):
	try_cast_card.rpc(pathToCard)

@rpc("any_peer", "call_local", "reliable")
func try_cast_card(pathToCard: String):
	if isCastersTurn():
		var card = get_tree().get_current_scene().get_node(pathToCard)
		if multiplayer.is_server():
			var validMana = bank.manaPool.filter(func(mana: Mana): return card.card.costType.has(mana.manaType.type))
			if validMana.size() >= card.card.costAmount:
				var removedManaTypes = bank.removeNManaOfType(card.card.costAmount, card.card.costType)
				discard.addCards(removedManaTypes)
				card.castEffect()

func _client_discard_mana(manaType: Enums.ManaType):
	discard_mana.rpc(manaType)
	
@rpc("any_peer", "call_local", "reliable")
func discard_mana(manaType: Enums.ManaType):
	if multiplayer.is_server():
		if isCastersTurn():
			var mana = bank.getManaOfType(manaType)
			mana.enterDiscard()
			var removedManaTypes = bank.removeManaOfType([mana.manaType.type])
			discard.addCard(removedManaTypes)

func _client_try_move(targetSquare: Vector2):
	try_move.rpc(targetSquare)

#@rpc("any_peer", "call_local", "reliable")
#func try_move(targetSquare: Vector2):
	#if isCastersTurn():
		#var distanceVector: Vector2 = abs(targetSquare - boardPosition)
		#var movesNeeded = max(distanceVector.x, distanceVector.y)
		#if currentState == Enums.PlayerState.MOVING_PIECE:
			#if movesNeeded <= basicMovesAvailable:
				#boardPosition = targetSquare
				#var tween = create_tween()
				#tween.tween_property(board_piece, "global_position", board.boardToWorldCoord(boardPosition), (distanceVector.x + distanceVector.y) * 0.25)
				#basicMovesAvailable -= movesNeeded

var dictionaryOfPossiblePaths : Dictionary
@rpc("any_peer", "call_local", "reliable")
func try_move(targetSquare: Vector2):
	if isCastersTurn():
		if currentState == Enums.PlayerState.MOVING_PIECE:
			board.clearHighlights()
			print("player trying to move to ", targetSquare)
			var distanceVector: Vector2 = abs(targetSquare - boardPosition)
			var validEndSquares := dictionaryOfPossiblePaths.keys()
			print("valid end squares: ", validEndSquares)
			print("dictionary of possible paths: ", dictionaryOfPossiblePaths)
			if str(targetSquare) in validEndSquares:
				print("the target square is valid")
				for square in dictionaryOfPossiblePaths[str(targetSquare)]:
					print(square)
					var tween = create_tween()
					tween.tween_property(board_piece, "global_position", board.boardToWorldCoord(boardPosition), (distanceVector.x + distanceVector.y) * 0.25)
					basicMovesAvailable -= 1
		if currentState == Enums.PlayerState.OBSERVING_BOARD && targetSquare == boardPosition:
			currentState = Enums.PlayerState.MOVING_PIECE
			print("player can now move piece")
			var arrOfCasters := getCastersInRadius(7)
			var arrOfInvalidSquares : Array[Vector2] = []
			for caster in arrOfCasters:
				arrOfInvalidSquares.append(caster.boardPosition)
			getPathsToPossibleSquares()

## returns a dictionary with all possible ending squares as keys and the shortest series of 1-square moves to get there as the value
#func getPathsToPossibleSquares(arrOfCasterPositions: Array[Vector2], currentSquare := boardPosition, pathToCurrentSquare := [], movesRemaining := basicMovesAvailable, dictionaryOfPaths := {}) -> Dictionary:
	#var newPathToCurrentSquare = [currentSquare]
	#newPathToCurrentSquare.append_array(pathToCurrentSquare.duplicate())
	#if !dictionaryOfPaths.has(str(currentSquare)):
		#dictionaryOfPaths[str(currentSquare)] = [newPathToCurrentSquare]
		#board.highlightSquare(currentSquare)
	#if dictionaryOfPaths[str(currentSquare)].size() > newPathToCurrentSquare.size():
		#dictionaryOfPaths[str(currentSquare)] = newPathToCurrentSquare
	#if movesRemaining > 0:
		#var validAdjacentSquares : Array[Vector2] = []
		#for targetRelativeX in range(-1, 2):
			#for targetRelativeY in range(-1, 2):
				#var adjacentSquare := currentSquare + Vector2(targetRelativeX, targetRelativeY)
				#if adjacentSquare.x >= 0 && adjacentSquare.x <= 7 && adjacentSquare.y >= 0 && adjacentSquare.y <= 7 && !adjacentSquare in arrOfCasterPositions:
					#validAdjacentSquares.append(adjacentSquare)
					#getPathsToPossibleSquares(arrOfCasterPositions, adjacentSquare, newPathToCurrentSquare, movesRemaining - 1, dictionaryOfPaths)
	#print(dictionaryOfPaths)
	#return dictionaryOfPaths

#func exploreAdjacentSquares(startingSquare: Vector2, arrOfInvalidSquares: Array[Vector2]) -> Array[Vector2]:
	##return array of valid and not yet explored squares that are adjacent to startingSquare
	#var validAdjacentSquares : Array[Vector2] = []
	#for targetRelativeX in range(-1, 2):
		#for targetRelativeY in range(-1, 2):
			#var adjacentSquare := startingSquare + Vector2(targetRelativeX, targetRelativeY)
			#if adjacentSquare.x >= 0 && adjacentSquare.x <= 7 && adjacentSquare.y >= 0 && adjacentSquare.y <= 7 && !arrOfInvalidSquares.has(adjacentSquare):
				#validAdjacentSquares.append(adjacentSquare)
	#return validAdjacentSquares
#
#func getPathsToPossibleSquares(arrOfInvalidSquares: Array[Vector2], unexploredSquares = {str(boardPosition): {'vector': boardPosition, 'depth': 0}}, currentDepth = 0) -> Dictionary:
	#var dictionaryOfPaths := {}
	#while unexploredSquares.keys().size() > 0:
		#var squaresAtCurrentDepth: Array[Vector2]
		#for key in unexploredSquares:
			#squaresAtCurrentDepth.append(unexploredSquares[key].vector)
			#print(unexploredSquares[key])
		#for square in squaresAtCurrentDepth:
			#board.highlightSquare(square)
			#var depthOfCurrentSquare = unexploredSquares[str(square)].depth
			#unexploredSquares.erase(str(square))
			#if depthOfCurrentSquare < basicMovesAvailable:
				#arrOfInvalidSquares.append(square)
				#for returnedSquare in exploreAdjacentSquares(square, arrOfInvalidSquares):
					#if !unexploredSquares.keys().has(str(returnedSquare)):
						#unexploredSquares[str(returnedSquare)] = {'vector': returnedSquare, 'depth': depthOfCurrentSquare + 1}
#	return dictionaryOfPaths

var arrOfInvalidSquares: Array[Vector2]
func getPathsToPossibleSquares(startingSquare := boardPosition, currentDepth := 0, maxDepth := basicMovesAvailable):
	arrOfInvalidSquares.append(startingSquare)
	if currentDepth < maxDepth:
		var validAdjacentSquares : Array[Vector2] = []
		for targetRelativeX in range(-1, 2):
			for targetRelativeY in range(-1, 2):
				var adjacentSquare := startingSquare + Vector2(targetRelativeX, targetRelativeY)
				if adjacentSquare.x >= 0 && adjacentSquare.x <= 7 && adjacentSquare.y >= 0 && adjacentSquare.y <= 7 && !arrOfInvalidSquares.has(adjacentSquare):
					validAdjacentSquares.append(adjacentSquare)
					#print("depth: ",currentDepth , updatedInvalidSquares)
					board.highlightSquare(adjacentSquare)
					getPathsToPossibleSquares(adjacentSquare, currentDepth + 1)
	pass

func setupBoardstate():
	if multiplayer.is_server():
		hand.spawnHand(abilityCards)
		deck.setDeckContents(manaTotals.get('Knots'), manaTotals.get('Teeth'), manaTotals.get('Guts'))

func isCastersTurn() -> bool:
	return is_casters_turn

func startTurn():
	if multiplayer.is_server():
		is_casters_turn = true
		draw()

func endTurn():
	if multiplayer.is_server():
		is_casters_turn = false

func draw():
	if multiplayer.is_server():
		if bank.manaPool.size() < 6:
			var drawnCards := deck.drawNCards(6-bank.manaPool.size(), self)
			bank.addManaCards(drawnCards)

@rpc("any_peer", "call_local", "reliable")
func updateState(state: Enums.PlayerState):
	currentState = state

func updateCurrentState():
	if multiplayer.get_unique_id() == caster_id:
		if Input.is_action_just_pressed("move_back"):
			currentState = Enums.PlayerState.SITTING_NEUTRAL
			board.clearHighlights()
			var tween = create_tween()
			tween.parallel().tween_property(camera, "global_position", seated_neutral.global_position, 0.25)
			tween.parallel().tween_property(camera, "global_rotation_degrees", Vector3(-24.2, camera.global_rotation_degrees.y, 0), 0.25)
		if Input.is_action_just_pressed("move_forward") && currentState == Enums.PlayerState.SITTING_NEUTRAL:
			currentState = Enums.PlayerState.OBSERVING_BOARD
			var tween = create_tween()
			tween.parallel().tween_property(camera, "global_position", observing_board.global_position, 0.25)
			tween.parallel().tween_property(camera, "global_rotation_degrees", Vector3(-50, camera.global_rotation_degrees.y, 0), 0.25 )
		updateState.rpc(currentState)

func _client_pass_turn():
	passTurn.rpc()

@rpc("any_peer", "call_local", "reliable")
func passTurn():
	if multiplayer.is_server():
		if isCastersTurn():
			basicMovesAvailable = 0
			GameManager.passTurn()

func _on_pass_turn_collider_input_event(camera, event, event_position, normal, shape_idx):
	if event is InputEventMouseButton && event.is_action_pressed("left_click"):
		_client_pass_turn()

## Returns an array of other casters that are within the given radius of this caster. Results include this caster. 
func getCastersInRadius(radiusInclusive: int) -> Array[Caster]:
	var listOfCasters = get_tree().get_current_scene().get_node("World/Casters").get_children()
	var listOfCastersInRadius : Array[Caster] = []
	for caster in listOfCasters:
		if caster is Caster:
			var distanceToPiece : Vector2 = abs(caster.boardPosition - self.boardPosition)
			var distanceInSquaresToPiece = max(distanceToPiece.x, distanceToPiece.y)
			if distanceInSquaresToPiece <= radiusInclusive:
				listOfCastersInRadius.append(caster)
	return listOfCastersInRadius

## Returns total number of cards milled
func recieveWounds(woundAmount: int) -> int:
	print("recieve wounds is running %s" %woundAmount)
	var gutCardsMilled := 0
	var totalCardsMilled := 0
	while gutCardsMilled != woundAmount:
		var milledCard := deck.drawCard(self)
		if milledCard == -1:
			print("YOU DIED!!! D:")
			return totalCardsMilled
		if milledCard == Enums.ManaType.GUT:
			gutCardsMilled += 1
		totalCardsMilled += 1
		discard.addCard(milledCard)
	return totalCardsMilled

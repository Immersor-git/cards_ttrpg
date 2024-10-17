@tool
class_name Caster
extends Node3D

@export var boardPosition : Vector2 = Vector2(0, 0)
@export var board: Board
@export var hand: Hand
@export var bank: Bank
@export var manaTotals: Dictionary = {'Knots': 11, 'Teeth': 11, 'Guts': 11}
@export var abilityCards : Array[AbilityCard]
@export var deck: Deck
@export var discard: Deck
@export var camera: Camera3D
@export var is_casters_turn := false
@export var casterMaterial: Array[Material]
@export var currentState: Enums.PlayerState = Enums.PlayerState.SITTING_NEUTRAL

var basicMovesAvailable: int = 0
var caster_id := 1:
	set(id):
		caster_id = id
		$PlayerInput.set_multiplayer_authority(id)
var team_id := 0
var isReadyToDraw := false
var arrOfInvalidSquares : Array[Vector2] = []

@onready var board_piece = $MeshInstance3D
@onready var seated_neutral = $SeatedNeutral
@onready var observing_board = $ObservingBoard

func _ready():
	bank.set_caster(self)
	hand.set_caster(self)
	board = get_tree().get_current_scene().get_node("World/Board/Checkerboard")
	if multiplayer.is_server():
		board_piece.global_position = board.boardToWorldCoord(boardPosition)
	if multiplayer.get_unique_id() == caster_id:
		camera.make_current()
	else:
		camera.queue_free()
	set_player_number(team_id)
	
	InputMap.load_from_project_settings()

func _process(delta):
	if Engine.is_editor_hint():
		if board != null:
			board_piece.global_position = board.boardToWorldCoord(boardPosition)
	else:
		updateCurrentState()
		set_board_piece_color(team_id)
		for card in hand.cards:
			if !card.is_connected(card.cast_card.get_name(), self._client_try_cast_card):
				card.cast_card.connect(self._client_try_cast_card)
		for manaCard in bank.manaPool:
			if is_instance_valid(manaCard) && !manaCard.is_connected(manaCard.discard_mana.get_name(), self._client_discard_mana):
				manaCard.discard_mana.connect(self._client_discard_mana)
		if !board.is_connected(board.send_clicked_square.get_name(), self._client_try_move):
				board.send_clicked_square.connect(self._client_try_move)

var isOwnedMesh := false
func set_board_piece_color(player_num: int):
	if !isOwnedMesh:
		isOwnedMesh = true
		board_piece.mesh = board_piece.mesh.duplicate()
	board_piece.mesh.material = casterMaterial[player_num]

func set_player_number(player_num: int):
	self.team_id = player_num
	set_board_piece_color(player_num)
	if player_num == 1:
		self.global_rotation_degrees = Vector3(0, 180, 0)
		self.boardPosition = Vector2(0, 0)
	elif player_num == 2:
		self.global_rotation_degrees = Vector3(0, 90, 0)
		self.boardPosition = Vector2(0, 7)
	elif player_num == 3:
		self.global_rotation_degrees = Vector3(0, 270, 0)
		self.boardPosition = Vector2(7, 0)

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
	if isCastersTurn() && multiplayer.is_server():
				var card = get_tree().get_current_scene().get_node(pathToCard)
				card.castEffect()

func _client_discard_mana(manaPath: NodePath):
	discard_mana.rpc(manaPath)
	
@rpc("any_peer", "call_local", "reliable")
func discard_mana(manaPath: NodePath):
	if multiplayer.is_server():
		if isCastersTurn():
			var mana = get_node(manaPath)
			mana.enterDiscard()
			var removedManaTypes = bank.removeManaAtNodePath(manaPath)
			discard.addCard(removedManaTypes)

func _client_try_move(targetSquare: Vector2):
	try_move.rpc(targetSquare)
	if currentState == Enums.PlayerState.OBSERVING_BOARD && targetSquare == boardPosition:
		currentState = Enums.PlayerState.MOVING_PIECE
		updateArrOfInvalidSquares()
		dictOfPreviousSquaresGlobalTemp = getPathsToPossibleSquares(arrOfInvalidSquares)
	elif currentState == Enums.PlayerState.MOVING_PIECE:
		if dictOfPreviousSquaresGlobalTemp.has(str(targetSquare)):
				board.clearHighlights()
				if !multiplayer.is_server():
					var pathToTargetSquare := findPathToSquare(targetSquare, dictOfPreviousSquaresGlobalTemp)
					await get_tree().create_timer((0.35 + 0.18) * pathToTargetSquare.size()).timeout
					updateArrOfInvalidSquares()
					dictOfPreviousSquaresGlobalTemp = getPathsToPossibleSquares(arrOfInvalidSquares)

var dictOfPreviousSquaresGlobalTemp: Dictionary
@rpc("any_peer", "call_local", "reliable")
func try_move(targetSquare: Vector2):
	if isCastersTurn():
		if currentState == Enums.PlayerState.OBSERVING_BOARD && targetSquare == boardPosition:
			currentState = Enums.PlayerState.MOVING_PIECE
			updateArrOfInvalidSquares()
			dictOfPreviousSquaresGlobalTemp = getPathsToPossibleSquares(arrOfInvalidSquares)
		elif currentState == Enums.PlayerState.MOVING_PIECE:
			if basicMovesAvailable >= 1 && dictOfPreviousSquaresGlobalTemp.has(str(targetSquare)):
				var pathToTargetSquare := findPathToSquare(targetSquare, dictOfPreviousSquaresGlobalTemp)
				var speedModifier := pathToTargetSquare.size()
				while pathToTargetSquare.size() > 0:
					var nextStep: Vector2 = pathToTargetSquare.pop_back()
					if nextStep != boardPosition:
						boardPosition = nextStep
						var tween = create_tween()
						tween.tween_property(board_piece, "global_position", board.boardToWorldCoord(boardPosition), 0.35)
						basicMovesAvailable -= 1
						await tween.finished
						await get_tree().create_timer(.18).timeout
				updateArrOfInvalidSquares()
				dictOfPreviousSquaresGlobalTemp = getPathsToPossibleSquares(arrOfInvalidSquares)

func updateArrOfInvalidSquares():
	arrOfInvalidSquares.clear()
	for caster in getCastersInRadius(7):
		arrOfInvalidSquares.append(caster.boardPosition)

func getNeighbors(startingSquare: Vector2)-> Array[Vector2]:
	var validAdjacentSquares : Array[Vector2] = []
	var cardinalNeighbors : Array[Vector2] = []
	var diagNeighbors :Array[Vector2] = []
	for targetRelativeX in range(-1, 2):
		for targetRelativeY in range(-1, 2):
			var adjacentSquare := startingSquare + Vector2(targetRelativeX, targetRelativeY)
			if adjacentSquare.x >= 0 && adjacentSquare.x <= 7 && adjacentSquare.y >= 0 && adjacentSquare.y <= 7:
				if adjacentSquare.x == startingSquare.x || adjacentSquare.y == startingSquare.y:
					cardinalNeighbors.append(adjacentSquare)
				else:
					diagNeighbors.append(adjacentSquare)
	validAdjacentSquares.append_array(cardinalNeighbors)
	validAdjacentSquares.append_array(diagNeighbors)
	return validAdjacentSquares

func findPathToSquare(targetSquare: Vector2, dictOfPreviousSquares: Dictionary)-> Array[Vector2]:
	var pathToSquare: Array[Vector2] = [targetSquare]
	var currentSquare := targetSquare
	while currentSquare != boardPosition:
		currentSquare = dictOfPreviousSquares[str(currentSquare)]
		pathToSquare.append(currentSquare)
	return pathToSquare

func getPathsToPossibleSquares(arrOfInvalidSquares)-> Dictionary:
	var queue: Array[Vector2] = [boardPosition]
	#every key in this dictionary will represent a square. It's value will represent the square that you can enter that square FROM.
	var dictOfPreviousSquares: Dictionary
	var currentSquare := boardPosition
	while queue.size() != 0:
		currentSquare = queue.pop_front()
		if findPathToSquare(currentSquare, dictOfPreviousSquares).size() <= basicMovesAvailable:
			var neighbors = getNeighbors(currentSquare)
			for nextSquare in neighbors:
				if !arrOfInvalidSquares.has(nextSquare):
					queue.append(nextSquare)
					arrOfInvalidSquares.append(nextSquare)
					dictOfPreviousSquares[str(nextSquare)] = currentSquare
					if !multiplayer.is_server() || caster_id == 1:
						board.highlightSquare(nextSquare)
	return dictOfPreviousSquares

func spawnHand():
	if multiplayer.is_server():
		hand.spawnHand(abilityCards)

func spawnMana():
	deck.setDeckContents(manaTotals.get('Knots'), manaTotals.get('Teeth'), manaTotals.get('Guts'))
	isReadyToDraw = true

func isCastersTurn() -> bool:
	return is_casters_turn  && (multiplayer.get_remote_sender_id() == self.caster_id || multiplayer.is_server())

func startTurn():
	if multiplayer.is_server():
		is_casters_turn = true
		for card in hand.cards:
			card.startTurnEffect()
		draw()

func endTurn():
	if multiplayer.is_server():
		is_casters_turn = false

func draw():
	if multiplayer.is_server():
		if bank.manaPool.size() < 6:
			var drawnCards := deck.drawNCards(6-bank.manaPool.size(), self)
			bank.addManaCards(drawnCards)

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
		if basicMovesAvailable == 0 && currentState == Enums.PlayerState.MOVING_PIECE:
			currentState = Enums.PlayerState.OBSERVING_BOARD

func _client_pass_turn(card_pass: bool):
	passTurn.rpc(card_pass)

@rpc("any_peer", "call_local", "reliable")
func passTurn(card_pass: bool):
	if multiplayer.is_server():
		if is_casters_turn && (multiplayer.get_remote_sender_id() == caster_id || (multiplayer.is_server() && card_pass)):
			basicMovesAvailable = 0
			GameManager.passTurn()

func _on_pass_turn_collider_input_event(camera, event, event_position, normal, shape_idx):
	if event is InputEventMouseButton && event.is_action_pressed("left_click"):
		_client_pass_turn(false)

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

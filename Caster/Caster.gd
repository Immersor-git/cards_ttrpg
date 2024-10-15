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

var basicMovesAvailable: int = 0
var currentState: Enums.PlayerState = Enums.PlayerState.SITTING_NEUTRAL
var caster_id := 1:
	set(id):
		caster_id = id
var team_id := 0
var isReadyToDraw := false

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
		self.boardPosition = Vector2(7, 7)
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
	if isCastersTurn():
		var card = get_tree().get_current_scene().get_node(pathToCard)
		if multiplayer.is_server():
			var validMana = bank.manaPool.filter(func(mana: Mana): return card.card.costType.has(mana.manaType.type))
			if validMana.size() >= card.card.costAmount && card.canCastEffect():
				var removedManaTypes = bank.removeNManaOfType(card.card.costAmount, card.card.costType)
				discard.addCards(removedManaTypes)
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

@rpc("any_peer", "call_local", "reliable")
func try_move(targetSquare: Vector2):
	if isCastersTurn():
		var distanceVector: Vector2 = abs(targetSquare - boardPosition)
		var movesNeeded = max(distanceVector.x, distanceVector.y)
		if currentState == Enums.PlayerState.MOVING_PIECE:
			if movesNeeded <= basicMovesAvailable:
				boardPosition = targetSquare
				var tween = create_tween()
				tween.tween_property(board_piece, "global_position", board.boardToWorldCoord(boardPosition), (distanceVector.x + distanceVector.y) * 0.25)
				basicMovesAvailable -= movesNeeded

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

@rpc("any_peer", "call_local", "reliable")
func updateState(state: Enums.PlayerState):
	currentState = state

func updateCurrentState():
	if multiplayer.get_unique_id() == caster_id:
		if Input.is_action_just_pressed("move_back"):
			currentState = Enums.PlayerState.SITTING_NEUTRAL
			var tween = create_tween()
			tween.parallel().tween_property(camera, "global_position", seated_neutral.global_position, 0.25)
			tween.parallel().tween_property(camera, "global_rotation_degrees", Vector3(-24.2, camera.global_rotation_degrees.y, 0), 0.25)
		if Input.is_action_just_pressed("move_forward") && currentState == Enums.PlayerState.SITTING_NEUTRAL:
			currentState = Enums.PlayerState.MOVING_PIECE
			var tween = create_tween()
			tween.parallel().tween_property(camera, "global_position", observing_board.global_position, 0.25)
			tween.parallel().tween_property(camera, "global_rotation_degrees", Vector3(-50, camera.global_rotation_degrees.y, 0), 0.25 )
		updateState.rpc(currentState)

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

extends Node

const PORT = 27523
var SERVER_IP = "127.0.0.1"

var CASTER = load("res://Caster/Caster.tscn")

var _caster_spawn_node
var alreadyJoined = false;

func _process(delta):
	if !alreadyJoined && Input.is_action_just_pressed("host_server"):
		alreadyJoined = true
		host_game()
	elif !alreadyJoined && Input.is_action_just_pressed("join_server"):
		alreadyJoined = true
		join_hosted_game()

func host_game():
	print("Hosting Server")
	_caster_spawn_node = get_tree().get_current_scene().get_node("World/Casters")
	
	var server_peer = ENetMultiplayerPeer.new()
	server_peer.create_server(PORT, 4)
	
	multiplayer.multiplayer_peer = server_peer
	
	multiplayer.peer_connected.connect(_add_new_caster)
	multiplayer.peer_disconnected.connect(_remove_caster)
	_add_new_caster(1)
	_remove_single_player_caster(1)

func join_hosted_game():
	var client_peer = ENetMultiplayerPeer.new()
	client_peer.create_client(SERVER_IP, PORT)
	
	multiplayer.multiplayer_peer = client_peer
	_remove_single_player_caster(multiplayer.get_unique_id())
	
func _set_server_ip(ip: String):
	SERVER_IP = ip

var player_num := 0
func _add_new_caster(caster_id: int):
	var caster: Caster = CASTER.instantiate()
	caster.caster_id = caster_id
	caster.name = str(caster_id)
	_caster_spawn_node.add_child(caster)
	caster.set_player_number(player_num)
	player_num += 1
	print("Caster %s joined the game!" % caster_id)

func _remove_caster(caster_id: int):
	print("Caster %s left the game!" % caster_id)

func _remove_single_player_caster(caster_id: int):
	var caster_to_remove: Caster = get_tree().get_current_scene().get_node("World/Caster")
	if multiplayer.is_server():
		for caster: Node in _caster_spawn_node.get_children():
			if caster is Caster:
				if caster.caster_id == 1:
					caster.abilityCards = caster_to_remove.abilityCards
					caster.spawnHand()
					caster.manaTotals = caster_to_remove.manaTotals
					caster.spawnMana()
	caster_to_remove.queue_free()

@rpc("any_peer", "reliable")
func _client_set_hand(hand: Array[String]):
	if multiplayer.is_server():
		var resourceHand : Array[AbilityCard] = []
		for cardName in hand:
			resourceHand.append(Enums.CardNameToCardResource[cardName])
		for caster: Node in _caster_spawn_node.get_children():
			if caster is Caster:
				if caster.caster_id == multiplayer.get_remote_sender_id():
					caster.abilityCards = resourceHand
					caster.spawnHand()

@rpc("any_peer", "reliable")
func _client_set_mana_totals(manaTotals: Dictionary):
	if multiplayer.is_server():
		for caster: Node in _caster_spawn_node.get_children():
			if caster is Caster:
				if caster.caster_id == multiplayer.get_remote_sender_id():
					caster.manaTotals = manaTotals
					caster.spawnMana()

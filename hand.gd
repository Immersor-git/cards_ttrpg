@tool
class_name Hand
extends Node3D

var caster: Caster
var syncableAbilityCards : Array[String] = []
var cards : Array[Card] = []

@onready var multiplayer_synchronizer = $"../MultiplayerSynchronizer"
@onready var hand_spawner = $"../HandSpawner"

func _ready():
	if !multiplayer.is_server():
		if !hand_spawner.is_connected("child_entered_tree", updateHand):
			hand_spawner.spawned.connect(updateHand)

func set_caster(caster: Caster):
	self.caster = caster

func updateHand(node: Node):
	for card in node.get_children():
		if card is Card:
			print("runing")
			card.caster = caster
			cards.append(card)
	var OFFSET = .65 * (self.get_child_count() -1)
	for child_index in self.get_child_count():
		var child = self.get_child(child_index)
		child.position = Vector3(child_index * 1.3 - OFFSET,0,0)

func instantiateAbilityCardInstance(pos: Vector3, card: PackedScene):
	var instance = card.instantiate()
	instance.position = pos
	add_child(instance)
	for child in instance.get_children():
		if child is Card:
			child.caster = caster
			cards.append(child)

func spawnHand(hand: Array[AbilityCard]):
	self.caster = caster
	var OFFSET = .65 * (hand.size() -1)
	for card_index in hand.size():
		instantiateAbilityCardInstance(Vector3(card_index * 1.3 - OFFSET,0,0), load(Enums.CardNameToCardResource.get(hand[card_index].title).scenePath))

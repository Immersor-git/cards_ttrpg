@tool
class_name Hand
extends Node3D

var caster: Caster
var syncableAbilityCards : Array[String] = []
var cards : Array[Card] = []

func _process(delta):
	if !Engine.is_editor_hint():
		if multiplayer.is_server():
			syncronizeCardsToClients()
		else:
			syncronizeCardsFromServer()

func set_caster(caster: Caster):
	self.caster = caster

func syncronizeCardsToClients():
	if syncableAbilityCards.size() != cards.size():
		syncableAbilityCards = []
		for card in cards:
			syncableAbilityCards.append(card.card.title)

func syncronizeCardsFromServer():
	if cards.size() == 0:
		var ability_card_scene : Array[PackedScene] = []
		for syncableAbilityCard in syncableAbilityCards:
			var cardPackedScene: PackedScene = load(Enums.CardNameToCardResource.get(syncableAbilityCard).scenePath)
			ability_card_scene.append(cardPackedScene)
		spawnHand(ability_card_scene)

func instantiateAbilityCardInstance(pos: Vector3, card: PackedScene):
	var instance = card.instantiate()
	instance.position = pos
	for child in instance.get_children():
		if child is Card:
			child.caster = caster
			cards.append(child)
	add_child(instance)

func spawnHand(hand: Array[PackedScene]):
	self.caster = caster
	var offset = .65 * (hand.size() -1)
	for card_index in hand.size():
		instantiateAbilityCardInstance(Vector3(card_index * 1.3 - offset,0,0), hand[card_index])

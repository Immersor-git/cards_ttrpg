extends Control

# HostJoin UI
@onready var host_join_ui = $"."
@onready var host_join_buttons = $"TabContainer/Host Join/HostJoinButtons"
@onready var join_config = $"TabContainer/Host Join/JoinConfig"
@onready var server_address = $"TabContainer/Host Join/JoinConfig/ServerAddress"

# Deck Management UI
@onready var cards = $"TabContainer/Edit Deck/HBoxContainer/Cards"
@onready var caster = $"../World/Caster"
@onready var teeth_count = $"TabContainer/Edit Deck/HBoxContainer/Mana/Teeth/TeethCount"
@onready var knots_count = $"TabContainer/Edit Deck/HBoxContainer/Mana/Knots/KnotsCount"
@onready var gut_count = $"TabContainer/Edit Deck/HBoxContainer/Mana/Gut/GutCount"

const MAX_HAND_SIZE = 6

var abilityCardsInDeck: Array[AbilityCard] = []
var cardToToggle: Dictionary = {}

func _ready():
	abilityCardsInDeck = caster.abilityCards
	for card: AbilityCard in Enums.CardNameToCardResource.values():
		var hBoxContainer := HBoxContainer.new()
		var card_label := Label.new()
		card_label.text = card.title
		card_label.custom_minimum_size = Vector2(250, 0)
		hBoxContainer.add_child(card_label)
		var checkbutton := CheckButton.new()
		checkbutton.button_pressed = abilityCardsInDeck.has(card)
		hBoxContainer.add_child(checkbutton)
		cardToToggle[card.title] = checkbutton
		checkbutton.toggled.connect(func(state: bool): add_card_toggle(state, card))
		cards.add_child(hBoxContainer)

func add_card_toggle(button_pressed: bool, card: AbilityCard):
	abilityCardsInDeck.push_back(card)
	if button_pressed && abilityCardsInDeck.size() > MAX_HAND_SIZE:
		var toggledCard = abilityCardsInDeck.pop_front()
		cardToToggle[toggledCard.title].button_pressed = false

func manaTotals() -> Dictionary:
	return {'Knots': int(knots_count.text), 'Teeth': int(teeth_count.text), 'Guts': int(gut_count.text)}

func _on_host_game_pressed():
	host_join_ui.hide()
	caster.abilityCards = abilityCardsInDeck
	caster.manaTotals = manaTotals()
	MultiplayerManager.host_game()

func _on_join_game_pressed():
	host_join_buttons.hide()
	join_config.show()

func on_connect_pressed():
	host_join_ui.hide()
	var server_address = server_address.text
	if server_address != "":
		MultiplayerManager._set_server_ip(server_address)
	MultiplayerManager.join_hosted_game()
	var abilityCardNames: Array[String] = []
	for card in abilityCardsInDeck:
		abilityCardNames.append(card.title)
	multiplayer.connected_to_server.connect(func(): MultiplayerManager._client_set_hand.rpc(abilityCardNames))
	multiplayer.connected_to_server.connect(func(): MultiplayerManager._client_set_mana_totals.rpc(manaTotals()))

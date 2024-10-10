@tool
class_name Caster
extends Node3D

@export var boardPosition : Vector2 = Vector2(0, 0)
@export var board: Board
@export var hand: Hand
@export var bank: Bank

func _ready():
	global_position = board.boardToWorldCoord(boardPosition)

func _process(delta):
	if Engine.is_editor_hint():
		global_position = board.boardToWorldCoord(boardPosition)
	for card in hand.cards:
		if !card.is_connected(card.cast_card.get_name(), self.try_cast_card):
			card.cast_card.connect(self.try_cast_card)

func heal(healAmount: int):
	print("Would Add %d Cards to Deck" % healAmount)

func move(moveAmount: int):
	print("Would Move Caster %d" % moveAmount)

func try_cast_card(card: Card):
	print("casting %s" % card.card.title)
	var validMana = bank.manaPool.filter(func(mana: Mana): return card.card.costType.has(mana.manaType.title))
	print(validMana)
	if validMana.size() >= card.card.costAmount:
		bank.removeNManaOfType(card.card.costAmount, card.card.costType)
		card.castEffect()

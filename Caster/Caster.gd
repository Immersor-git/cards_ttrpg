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

func _ready():
	setupBoardstate()
	global_position = board.boardToWorldCoord(boardPosition)

func _process(delta):
	if Engine.is_editor_hint():
		if board != null:
			global_position = board.boardToWorldCoord(boardPosition)
	else:
		for card in hand.cards:
			if !card.is_connected(card.cast_card.get_name(), self.try_cast_card):
				card.cast_card.connect(self.try_cast_card)

func heal(healAmount: int):
	healAmount = min(healAmount, discard.contents.size())
	var healedCards: Array[Enums.ManaType] = discard.drawNCards(healAmount, self)
	deck.addCards(healedCards)
	deck.shuffle()
	pass

func move(moveAmount: int):
	print("Would Move Caster %d" % moveAmount)

func try_cast_card(card: Card):
	print("casting %s" % card.card.title)
	print(card.card.costType)
	var validMana = bank.manaPool.filter(func(mana: Mana): return card.card.costType.has(mana.manaType.type))
	print(validMana)
	if validMana.size() >= card.card.costAmount:
		var removedManaTypes = bank.removeNManaOfType(card.card.costAmount, card.card.costType)
		discard.addCards(removedManaTypes)
		card.castEffect()

func setupBoardstate():
	deck.setDeckContents(manaTotals.get('Knots'), manaTotals.get('Teeth'), manaTotals.get('Guts'))
	var drawnCards := deck.drawNCards(6, self)
	bank.addManaCards(drawnCards, self)

@tool
extends AbstractComponent

var card: Card

func _ready():
	var c = self.get_parent().get_parent()
	if c is Card:
		self.card = c

func setCard(lCard: Card):
	self.card = lCard

func simpleCardCost(cardCost: Dictionary) -> bool:
	var cardCostKeys = cardCost.keys().filter(func (key): return !Enums.BasicManaCost.has(key))
	for cardCostKey in cardCostKeys:
		if cardCost[cardCostKey] != 0:
			return false
	return true

func handleCastEffect(cardOwner: Caster) -> bool:
	var cardCost = card.card.cost
	if simpleCardCost(cardCost):
		for simpleManaType in Enums.BasicManaCost:
			if !cardOwner.bank.hasNManaOfType(cardCost[simpleManaType], Enums.manaStringToEnum(simpleManaType)):
				card.cancelCast()
				return true
		for simpleManaType in Enums.BasicManaCost:
			var removedManaCards := cardOwner.bank.removeNManaOfType(cardCost[simpleManaType], [Enums.manaStringToEnum(simpleManaType)])
			cardOwner.discard.addCards(removedManaCards)
	return false

func handleStartTurn(_cardOwner: Caster):
	pass

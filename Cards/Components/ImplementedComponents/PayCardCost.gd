@tool
extends AbstractComponent

var card : Card

func _ready():
	var c = self.get_parent().get_parent()
	if c is Card:
		self.card = c

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
			if !cardOwner.bank.hasNManaOfType(cardCost[simpleManaType], simpleManaType):
				card
	return false

func handleStartTurn(_cardOwner: Caster):
	pass

func castAbilityDescription() -> String:
	return ""

func canCast(_cardOwner: Caster) -> bool:
	return true

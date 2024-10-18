@tool
class_name AllocateCardCostAmount
extends AbstractComponent

var allocatedManaCards: Array[Enums.ManaType] = []

func simpleCardCost(cardCost: Dictionary) -> bool:
	var cardCostKeys = cardCost.keys().filter(func (key): return !Enums.BasicManaCost.has(key))
	for cardCostKey in cardCostKeys:
		if cardCost[cardCostKey] != 0:
			return false
	return true

func handleCastEffect() -> bool:
	allocatedManaCards = []
	var cardCost = card.card.cost
	if simpleCardCost(cardCost):
		for simpleManaType in Enums.BasicManaCost:
			var manaAmount:int = cardCost[simpleManaType]
			if !card.caster.bank.hasNManaOfType(manaAmount, Enums.manaStringToEnum(simpleManaType)):
				card.cancelCast()
				return true
			for _manaIndex in manaAmount:
				allocatedManaCards.push_back(Enums.manaStringToEnum(simpleManaType))
	return false

func handleStartTurn():
	pass

func castAbilityDescription() -> String:
	return ""

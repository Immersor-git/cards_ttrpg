@tool
extends AbstractComponent

@export var allocatedCardCostAmount: AllocateCardCostAmount

func simpleCardCost(cardCost: Dictionary) -> bool:
	var cardCostKeys = cardCost.keys().filter(func (key): return !Enums.BasicManaCost.has(key))
	for cardCostKey in cardCostKeys:
		if cardCost[cardCostKey] != 0:
			return false
	return true

func handleCastEffect() -> bool:
	var cardCost = card.card.cost
	if simpleCardCost(cardCost):
		for manaCard in allocatedCardCostAmount.allocatedManaCards:
			var removedManaCards := card.caster.bank.removeManaOfType([manaCard])
			card.caster.discard.addCard(removedManaCards)
	return false

func handleStartTurn():
	pass

func castAbilityDescription() -> String:
	return ""

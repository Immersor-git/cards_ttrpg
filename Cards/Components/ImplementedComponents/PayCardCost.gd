@tool
extends AbstractComponent

@export var allocatedCardCostAmount: AllocateCardCostAmount

func _ready():
	if !allocatedCardCostAmount:
		var components = componentOwner.get('components')
		if components:
			for component in components:
				if component is AllocateCardCostAmount:
					allocatedCardCostAmount = component

func simpleCardCost(cardCost: Dictionary) -> bool:
	var cardCostKeys = cardCost.keys().filter(func (key): return !Enums.BasicManaCost.has(key))
	for cardCostKey in cardCostKeys:
		if cardCost[cardCostKey] != 0:
			return false
	return true

func handleCastEffect() -> bool:
	var componentOwnerCard = componentOwner.get('card')
	var componentCaster = componentOwner.get('caster')
	if componentOwnerCard && componentCaster:
		if componentCaster is Caster:
			var cardCost = componentOwnerCard.get('cost');
			if cardCost:
				if simpleCardCost(cardCost):
					for manaCard in allocatedCardCostAmount.allocatedManaCards:
						var removedManaCards: Enums.ManaType = componentCaster.bank.removeManaOfType(manaCard)
						componentCaster.discard.addCard(removedManaCards)
	return false

func handleStartTurn():
	pass

func castAbilityDescription() -> String:
	return ""

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
	var componentOwnerCard = componentOwner.get('card')
	var componentCaster = componentOwner.get('caster')
	if componentOwnerCard && componentCaster:
		if componentCaster is Caster:
			var cardCost = componentOwnerCard.get('cost');
			if cardCost:
				allocatedManaCards = []
				if simpleCardCost(cardCost):
					for simpleManaType in Enums.BasicManaCost:
						var manaAmount:int = cardCost[simpleManaType]
						if !componentCaster.bank.hasNManaOfType(manaAmount, Enums.manaStringToEnum(simpleManaType)):
							if componentOwner.has_method('cancelCast'):
								componentOwner.cancelCast()
							return true
						for _manaIndex in manaAmount:
							allocatedManaCards.push_back(Enums.manaStringToEnum(simpleManaType))
	return false

func handleStartTurn():
	pass

func castAbilityDescription() -> String:
	return ""

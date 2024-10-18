@tool
extends AbstractComponent

## The amount of health to heal the caster
@export var healAmount := 1

func handleCastEffect() -> bool:
	var componentCaster = componentOwner.get('caster')
	if componentCaster:
		if componentCaster is Caster:
			var maxHealAmount = min(healAmount, componentCaster.discard.contents.size())
			var healedCards: Array[Enums.ManaType] = componentCaster.discard.drawNCards(maxHealAmount)
			componentCaster.deck.addCards(healedCards)
			componentCaster.deck.shuffle()

	return false

func handleStartTurn():
	pass

func castAbilityDescription() -> String:
	return "Heal %d" % healAmount

@tool
extends AbstractComponent

## The amount of health to heal the caster
@export var healAmount := 1

func handleCastEffect() -> bool:
	var maxHealAmount = min(healAmount, card.caster.discard.contents.size())
	var healedCards: Array[Enums.ManaType] = card.caster.discard.drawNCards(maxHealAmount)
	card.caster.deck.addCards(healedCards)
	card.caster.deck.shuffle()

	return false

func handleStartTurn():
	pass

func castAbilityDescription() -> String:
	return "Heal %d" % healAmount

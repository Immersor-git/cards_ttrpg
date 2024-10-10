@tool
extends AbstractComponent

@export var healAmount := 1

func handleCastEffect(cardOwner: Caster):
	cardOwner.heal(healAmount)

func castAbilityDescription() -> String:
	return "Heal %d" % healAmount

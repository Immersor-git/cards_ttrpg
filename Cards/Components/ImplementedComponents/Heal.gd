@tool
extends AbstractComponent

@export var healAmount := 1

func handleCastEffect(cardOwner: Caster) -> bool:
	cardOwner.heal(healAmount)
	return false

func handleStartTurn(cardOwner: Caster):
	pass

func castAbilityDescription() -> String:
	return "Heal %d" % healAmount

func canCast(cardOwner: Caster) -> bool:
	return true

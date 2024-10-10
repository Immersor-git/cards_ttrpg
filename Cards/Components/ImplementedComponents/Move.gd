@tool
extends AbstractComponent

@export var moveAmount := 1

func handleCastEffect(cardOwner: Caster):
	cardOwner.move(moveAmount)

func castAbilityDescription() -> String:
	return "Move %d" % moveAmount

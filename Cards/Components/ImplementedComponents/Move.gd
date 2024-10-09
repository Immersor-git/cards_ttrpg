@tool
extends AbstractComponent

@export var moveAmount := 1

func handleCastEffect(cardOwner: Node):
	cardOwner.move(moveAmount)

func castAbilityDescription() -> String:
	return "Move %d" % moveAmount

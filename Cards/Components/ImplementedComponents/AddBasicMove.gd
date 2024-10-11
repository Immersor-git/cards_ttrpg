@tool
extends AbstractComponent

@export var moveAmount := 1

func handleCastEffect(cardOwner: Caster):
	cardOwner.basicMovesAvailable += moveAmount
	print(cardOwner.basicMovesAvailable, " moves are available")

func castAbilityDescription() -> String:
	return "Gain %d Moves" % moveAmount

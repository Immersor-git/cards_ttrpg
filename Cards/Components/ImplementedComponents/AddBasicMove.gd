@tool
extends AbstractComponent

@export var moveAmount := 1

func handleCastEffect(cardOwner: Caster) -> bool:
	cardOwner.basicMovesAvailable += moveAmount
	return false

func handleStartTurn(cardOwner: Caster):
	pass

func castAbilityDescription() -> String:
	return "Gain %d Moves" % moveAmount

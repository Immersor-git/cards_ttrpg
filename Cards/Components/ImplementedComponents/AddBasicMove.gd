@tool
extends AbstractComponent

@export var moveAmount := 1

func handleCastEffect() -> bool:
	card.caster.basicMovesAvailable += moveAmount
	return false

func handleStartTurn():
	pass

func castAbilityDescription() -> String:
	return "Gain %d Moves" % moveAmount

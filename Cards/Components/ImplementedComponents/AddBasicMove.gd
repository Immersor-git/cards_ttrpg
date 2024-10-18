@tool
extends AbstractComponent

@export var moveAmount := 1

func handleCastEffect() -> bool:
	var componentCaster = componentOwner.get('caster')
	if componentCaster:
		if componentCaster is Caster:
			componentCaster.basicMovesAvailable += moveAmount
	return false

func handleStartTurn():
	pass

func castAbilityDescription() -> String:
	return "Gain %d Moves" % moveAmount

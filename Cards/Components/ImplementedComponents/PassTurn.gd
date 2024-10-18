@tool
extends AbstractComponent

func handleCastEffect() -> bool:
	var componentCaster = componentOwner.get('caster')
	if componentCaster:
		if componentCaster is Caster:
			componentCaster.passTurn(true)
	return false

func handleStartTurn():
	pass

func castAbilityDescription() -> String:
	return "Ends Turn"

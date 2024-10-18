@tool
extends AbstractComponent

func handleCastEffect() -> bool:
	card.caster.passTurn(true)
	return false

func handleStartTurn():
	pass

func castAbilityDescription() -> String:
	return "Ends Turn"

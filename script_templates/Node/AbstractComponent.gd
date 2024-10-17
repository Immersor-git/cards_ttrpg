@tool
extends AbstractComponent

func handleCastEffect(cardOwner: Caster) -> bool:
	return false

func handleStartTurn(cardOwner: Caster):
	pass

func castAbilityDescription() -> String:
	return ""

func canCast(cardOwner: Caster) -> bool:
	return false

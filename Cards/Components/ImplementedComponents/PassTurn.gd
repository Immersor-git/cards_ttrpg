@tool
extends AbstractComponent

func handleCastEffect(cardOwner: Caster) -> bool:
	print("passing turn")
	cardOwner._client_pass_turn()
	return false

func handleStartTurn(cardOwner: Caster):
	pass

func castAbilityDescription() -> String:
	return "Ends Turn"

func canCast(cardOwner: Caster) -> bool:
	return true

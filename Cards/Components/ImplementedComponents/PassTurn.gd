@tool
extends AbstractComponent

func handleCastEffect(cardOwner: Caster):
	cardOwner._client_pass_turn()

func castAbilityDescription() -> String:
	return "Ends Turn"

class_name AbstractComponent
extends Node

func handleCastEffect(cardOwner: Caster) -> bool:
	assert("Abstract Method must be Overridden")
	return false

func handleStartTurn(cardOwner: Caster):
	assert("Abstract Method must be Overridden")

func castAbilityDescription() -> String:
	assert("Abstract Method must be Overridden")
	return ""

func canCast(cardOwner: Caster) -> bool:
	assert("Abstract Method must be Overridden")
	return false

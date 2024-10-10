class_name AbstractComponent
extends Node

func handleCastEffect(cardOwner: Caster):
	assert("Abstract Method must be Overridden")

func castAbilityDescription() -> String:
	assert("Abstract Method must be Overridden")
	return ""

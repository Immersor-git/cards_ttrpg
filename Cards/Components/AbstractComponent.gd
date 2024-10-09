class_name AbstractComponent
extends Node

func handleCastEffect(cardOwner: Node):
	assert("Abstract Method must be Overridden")

func castAbilityDescription() -> String:
	assert("Abstract Method must be Overridden")
	return ""

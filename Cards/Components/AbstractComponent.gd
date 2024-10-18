class_name AbstractComponent
extends Node

var componentOwner: Node

func setComponentOwner(componentOwnerToSet: Node):
	self.componentOwner = componentOwnerToSet

func handleCastEffect() -> bool:
	assert(false, "Abstract Method must be Overridden")
	return false

func handleStartTurn():
	assert(false, "Abstract Method must be Overridden")

func castAbilityDescription() -> String:
	assert(false, "Abstract Method must be Overridden")
	return ""

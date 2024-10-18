class_name AbstractComponent
extends Node

var card: Card

func setCard(cardToSet: Card):
	self.card = cardToSet

func handleCastEffect() -> bool:
	assert(false, "Abstract Method must be Overridden")
	return false

func handleStartTurn():
	assert(false, "Abstract Method must be Overridden")

func castAbilityDescription() -> String:
	assert(false, "Abstract Method must be Overridden")
	return ""

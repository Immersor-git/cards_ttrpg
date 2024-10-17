@tool
extends AbstractComponent

var card: Card

func _ready():
	var c = self.get_parent().get_parent()
	if c is Card:
		self.card = c

func handleCastEffect(cardOwner: Caster) -> bool:
	return false

func handleStartTurn(cardOwner: Caster):
	pass

func castAbilityDescription() -> String:
	return ""

func canCast(cardOwner: Caster) -> bool:
	return false

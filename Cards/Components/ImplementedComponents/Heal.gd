extends AbstractComponent

@export var healAmount := 1

func handleCastEffect(cardOwner: Node):
	cardOwner.heal(healAmount)

func castAbilityDescription() -> String:
	return "Heal %d" % healAmount

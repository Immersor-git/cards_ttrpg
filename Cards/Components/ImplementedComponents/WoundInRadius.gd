@tool
extends AbstractComponent

## The amount of wounds dealt to opponents in the radius
@export var woundAmount := 1
## The radius where wounds are dealt to opponents
@export var woundRadius := 1

func handleCastEffect(cardOwner: Caster):
	var castersInRadius := cardOwner.getCastersInRadius(woundRadius)
	print("castersInRadius is ", castersInRadius.size())
	for caster in castersInRadius:
		if caster.team_id != cardOwner.team_id:
			caster.recieveWounds(woundAmount)

func castAbilityDescription() -> String:
	var properlyPluralizedWounds := "wound" if woundAmount == 1 else "wounds"
	if woundRadius == 0:
		return "Deal %s %s to enemy in affected square" % [woundAmount, properlyPluralizedWounds]
	return "Deal %s %s to all enemies within %s squares" % [woundAmount, properlyPluralizedWounds, woundRadius]

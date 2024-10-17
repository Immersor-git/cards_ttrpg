@tool
extends AbstractComponent

@export var manaTypeToCreate: Enums.ManaType
@export var amountToCreate: int

func handleCastEffect(cardOwner: Caster) -> bool:
	var mana: Array[Enums.ManaType] = []
	for i in amountToCreate:
		mana.append(manaTypeToCreate)
	cardOwner.bank.addManaCards(mana)
	return false

func handleStartTurn(cardOwner: Caster):
	pass

func castAbilityDescription() -> String:
	var manaType = "Knots"
	if manaTypeToCreate == Enums.ManaType.TEETH:
		manaType = "Teeth"
	elif manaTypeToCreate == Enums.ManaType.GUT:
		manaType = "Gut"
	return "Create %s %s in your bank" % [amountToCreate, manaType]

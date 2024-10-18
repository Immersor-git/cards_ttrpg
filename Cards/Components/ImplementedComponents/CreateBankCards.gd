@tool
extends AbstractComponent

@export var manaTypeToCreate: Enums.ManaType
@export var amountToCreate: int

func handleCastEffect() -> bool:
	var componentCaster = componentOwner.get('caster')
	if componentCaster:
		if componentCaster is Caster:
			var mana: Array[Enums.ManaType] = []
			for i in amountToCreate:
				mana.append(manaTypeToCreate)
			componentCaster.bank.addManaCards(mana)
	return false

func handleStartTurn():
	pass

func castAbilityDescription() -> String:
	var manaType = "Knots"
	if manaTypeToCreate == Enums.ManaType.TEETH:
		manaType = "Teeth"
	elif manaTypeToCreate == Enums.ManaType.GUT:
		manaType = "Gut"
	return "Create %s %s in your bank" % [amountToCreate, manaType]

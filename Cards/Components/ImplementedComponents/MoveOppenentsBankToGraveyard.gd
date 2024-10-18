@tool
extends AbstractComponent

func handleCastEffect() -> bool:
	var componentCaster = componentOwner.get('caster')
	if componentCaster:
		if componentCaster is Caster:
			for caster in get_tree().get_current_scene().get_node("World/Casters").get_children():
				if caster is Caster:
					if caster.caster_id != componentCaster.caster_id:
						for manaCard in caster.bank.manaPool:
							var manaCardToRemove: Array[Enums.ManaType] = [manaCard.manaType.type]
							var discardedMana = caster.bank.removeManaOfType(manaCardToRemove)
							caster.discard.addCard(discardedMana)
	return false

func handleStartTurn():
	pass

func castAbilityDescription():
	return "Opponents Discard their Bank"

@tool
extends AbstractComponent

var card: Card

func _ready():
	var c = self.get_parent().get_parent()
	if c is Card:
		self.card = c

func handleCastEffect(cardOwner: Caster) -> bool:
	for caster in get_tree().get_current_scene().get_node("World/Casters").get_children():
		if caster is Caster:
			if caster.caster_id != cardOwner.caster_id:
				for manaCard in caster.bank.manaPool:
					var manaCardToRemove: Array[Enums.ManaType] = [manaCard.manaType.type]
					var discardedMana = caster.bank.removeManaOfType(manaCardToRemove)
					caster.discard.addCard(discardedMana)
	return false

func handleStartTurn(cardOwner: Caster):
	pass

func castAbilityDescription():
	return "Opponents Discard their Bank"

func canCast(cardOwner: Caster) -> bool:
	return false

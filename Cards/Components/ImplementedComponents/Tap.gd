@tool
extends AbstractComponent

var tapped := false

func tap(tapped: bool):
	var tween = create_tween()
	if tapped:
		self.tapped = true
		tween.tween_property(self.get_parent().get_parent(), "rotation_degrees", Vector3(0, 90, 0), 0.5)
	else:
		self.tapped = false
		tween.tween_property(self.get_parent().get_parent(), "rotation_degrees", Vector3(0, 0, 0), 0.5)

func handleCastEffect(cardOwner: Caster) -> bool:
	if tapped:
		return true
	tap(true)
	return false

func handleStartTurn(cardOwner: Caster):
	tap(false)

func castAbilityDescription() -> String:
	return "Tap. "

func canCast(cardOwner: Caster) -> bool:
	return !tapped

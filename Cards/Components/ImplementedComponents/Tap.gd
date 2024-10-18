@tool
class_name Tap
extends AbstractComponent

var tapped := false

var t = 0
func _process(delta):
	if multiplayer.is_server() && delta < 10 && card.currentState != Enums.CardState.CASTING_IN_PROGRESS:
		t += delta * 0.4;
		if tapped:
			card.rotation_degrees = card.rotation_degrees.lerp(Vector3(0, 90, 0), t)
		else:
			card.rotation_degrees = card.rotation_degrees.lerp(Vector3(0, 0, 0), t)

func handleCastEffect() -> bool:
	if tapped:
		card.cancelCast()
		return true
	t = 0
	self.tapped = true

	return false

func handleStartTurn():
	t = 0
	self.tapped = false

func castAbilityDescription() -> String:
	return "Tap. "

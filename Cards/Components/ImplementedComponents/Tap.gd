@tool
class_name Tap
extends AbstractComponent

var tapped := false

var t = 0
func _process(delta):
	var currentState = componentOwner.get('currentState')
	if currentState:
		if multiplayer.is_server() && delta < 10 && currentState != Enums.CardState.CASTING_IN_PROGRESS:
			t += delta * 0.4;
			if tapped:
				componentOwner.rotation_degrees = componentOwner.rotation_degrees.lerp(Vector3(0, 90, 0), t)
			else:
				componentOwner.rotation_degrees = componentOwner.rotation_degrees.lerp(Vector3(0, 0, 0), t)

func handleCastEffect() -> bool:
	if tapped:
		if componentOwner.has_method("cancelCast"):
			componentOwner.cancelCast()
		return true
	t = 0
	self.tapped = true

	return false

func handleStartTurn():
	t = 0
	self.tapped = false

func castAbilityDescription() -> String:
	return "Tap. "

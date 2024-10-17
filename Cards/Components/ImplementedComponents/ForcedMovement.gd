@tool
extends AbstractComponent

@export var checkForCollision := true
@export var spacesToMove := 1

func handleCastEffect(cardOwner: Caster) -> bool:
	cardOwner.currentState = Enums.PlayerState.PLANNING_ATTACK
	registerClickListener.rpc_id(cardOwner.caster_id, cardOwner)
	return false

@rpc("any_peer", "call_local", "reliable")
func registerClickListener(cardOwner: Caster):
	if !cardOwner.board.is_connected("send_clicked_square", self.boardSquareClicked):
		cardOwner.board.send_clicked_square.connect(self.boardSquareClicked.rpc)

@rpc("any_peer", "call_local", "reliable")
func boardSquareClicked(pos: Vector2):
	pass

func handleStartTurn(cardOwner: Caster):
	assert("Abstract Method must be Overridden")

func castAbilityDescription() -> String:
	assert("Abstract Method must be Overridden")
	return ""

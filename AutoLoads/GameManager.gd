extends Node

var gameStarted := false
var casterTakingTurn: Caster

func _process(_delta):
	if !gameStarted:
		pickStartTurn()

func pickStartTurn():
	if multiplayer.is_server():
		var casters = get_tree().get_current_scene().get_node("World/Casters").get_children()
		if casters.size() >= 2:
			for caster in casters:
				if caster is Caster:
					if !caster.isReadyToDraw:
						return
			gameStarted = true
			casters.shuffle()
			var caster = casters.pop_back()
			if caster is Caster:
				casterTakingTurn = caster
				caster.startTurn()

func passTurn():
	if multiplayer.is_server():
		var casters = get_tree().get_current_scene().get_node("World/Casters").get_children()
		for caster_index in casters.size():
			var caster = casters[caster_index]
			if caster is Caster:
				if caster.caster_id == casterTakingTurn.caster_id:
					casters[caster_index].endTurn()
					if caster_index + 1 == casters.size():
						casters[0].startTurn()
						casterTakingTurn = casters[0]
					else:
						casters[caster_index+1].startTurn()
						casterTakingTurn = casters[caster_index+1]
					return

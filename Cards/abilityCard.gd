@tool
class_name AbilityCard
extends Resource

@export var title: String
@export var costType: Array[Enums.ManaType]
@export var costAmount: int
@export_file(".tscn") var scenePath: String
@export var cost: Dictionary = {
	"TEETH": 0,
	"KNOTS": 0,
	"GUT": 0,
	"TEETH_KNOT_GUT": 0,
	"TEETH_KNOT": 0,
	"TEETH_GUT": 0,
	"KNOT_GUT": 0
}

func costString() -> String:
	match costType[0]:
		Enums.ManaType.KNOT:
			return 'Knots %d' % costAmount
		Enums.ManaType.TEETH:
			return 'Teeth %d' % costAmount
		Enums.ManaType.GUT:
			return 'Gut %d' % costAmount
	return 'something broke'

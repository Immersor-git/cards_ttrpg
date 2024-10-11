@tool
class_name AbilityCard
extends Resource

@export var title: String
@export var costType: Array[Enums.ManaType]
@export var costAmount: int

func costString() -> String:
	match costType[0]:
		Enums.ManaType.KNOT:
			return 'Knots %d' % costAmount
		Enums.ManaType.TEETH:
			return 'Teeth %d' % costAmount
		Enums.ManaType.GUT:
			return 'Gut %d' % costAmount
	return 'something broke'

@tool
class_name AbilityCard
extends Resource

@export var title: String
@export var costType: Array[String]
@export var costAmount: int

func costString() -> String:
	return costType[0] + " %d" % costAmount

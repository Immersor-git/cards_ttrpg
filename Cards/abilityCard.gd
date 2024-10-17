@tool
class_name AbilityCard
extends Resource

@export var title: String
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
	var costString = ""
	if cost["TEETH"] > 0:
		costString += "%s Teeth" % cost["TEETH"] 
	if cost["KNOTS"] > 0:
		costString += "%s Knot%s" % [cost["KNOTS"], "" if cost["KNOTS"] == 1 else "s"]
	if cost["GUT"] > 0:
		costString += "%s Gut" % [cost["GUT"]]
	## TODO: FINISH ALL THE TYPES ONCE WE HAVE NAMES ?
	return costString

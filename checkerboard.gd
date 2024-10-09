@tool
class_name Board
extends Node3D

@export var size : Vector2 = Vector2(0,0):
	set(value):
		size = value
		update_board(value)
		
var WhiteSquare : CSGMesh3D
var BlackSquare : CSGMesh3D
var generated = false
var planes = []

func _ready():
	WhiteSquare = get_node("WhiteSquare")
	BlackSquare = get_node("BlackSquare")
	generated = true
	update_board(size)

func boardToWorldCoord(boardPos: Vector2) -> Vector3:
	return Vector3(boardPos.x - size.x/2.0 + 0.5, 0.0, boardPos.y - size.y/2.0 + 0.5)

func update_board (size):
	if generated == false: return
	print("Updated size")
	var boardSize = scale
	for square : CSGMesh3D in planes:
		square.queue_free()
	planes.clear()
	var alternate = 0
	for x in size.x:
		alternate = (alternate + 1) % 2
		for y in size.y:
			if alternate == 0:
				var square : CSGMesh3D = WhiteSquare.duplicate()
				self.add_child(square)
				square.owner = self
				square.position = Vector3(x - size.x/2.0 + 0.5,0,y - size.y/2.0 + 0.5)
				square.visible = true
				self.add_child(square)
				planes.append(square)
			else:
				var square : CSGMesh3D = BlackSquare.duplicate()
				self.add_child(square)
				square.owner = self
				square.position = Vector3(x - size.x/2.0 + 0.5,0,y - size.y/2.0 + 0.5)
				square.visible = true
				
				planes.append(square)
				
			alternate = (alternate + 1) % 2
		
	

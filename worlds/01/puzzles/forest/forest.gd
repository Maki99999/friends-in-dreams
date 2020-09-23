extends Node2D


onready var scenery = {0: [$"YSort/00"]}

var current_pos = 0

const teleport_pos = {	"N": Vector2(-1096, -472), "E": Vector2(-952, -392),\
						"S": Vector2(-1096, -328), "W": Vector2(-1256, -392)}
#const directions = ["N", "E", "S", "W"]
const correct_way = "EWNEWNNWSNESW_"
const correct_way_reversed = "WESWESSENSWNE_"
const id = "01forest01"

func _ready():
	pass

func maybe_teleport(var to):
	if to == correct_way_reversed[current_pos]:
		current_pos += 1
		teleport(to)
		change_scenery(current_pos - 1, current_pos)
	else:
		current_pos = 0
		teleport_out()

func change_scenery(var old_depth, var depth):
	for obj in scenery[old_depth]:
		obj.pos = Vector2(-320, 0)
	for obj in scenery[depth]:
		obj.pos = Vector2(0, 0)

func teleport_out():
	Utils.player.try_teleport(Vector2(1592, -776), "down", get_node("/root/World01/Main/Entities"), Vector2(-10000000, 10000000), Vector2(-10000000, 10000000))
	SaveLoad.save_game()

func teleport(var to):
	SaveLoad.save_game()
	Utils.player.try_teleport(teleport_pos[to], null, null, Vector2(-1264, -944), Vector2(-496, -316))

func save():
	var saved_data = {"current_pos": current_pos}
	return([id, saved_data])

func restore(var saved_data):
	var data = saved_data[id]
	
	current_pos = data["current_pos"]
	change_scenery(0, current_pos)

func _on_Up_area_entered(_area):
	maybe_teleport("S")

func _on_Down_area_entered(_area):
	maybe_teleport("N")

func _on_Left_area_entered(_area):
	maybe_teleport("E")

func _on_Right_area_entered(_area):
	maybe_teleport("W")

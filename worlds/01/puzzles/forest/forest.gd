extends Node2D


onready var scenery = {0: [$"YSort/00"], 1: [$"YSort/01"], 2: [$"YSort/02", $"02"], \
		3: [$"YSort/03"], 4: [$"YSort/04"], 5: [$"YSort/05"], 6: [$"YSort/06", $"06"], \
		7: [$"YSort/07", $"07"], 8: [$"YSort/08"], 9: [$"YSort/09", $"09"], \
		10: [$"YSort/10", $"10"], 11: [$"YSort/11"], 12: [$"YSort/12"], 13: [$"YSort/13"]}
onready var timer = $Timer

var current_pos = 0
var is_teleporting = false

const teleport_pos = {	"N": Vector2(-1096, -472), "E": Vector2(-952, -392),\
						"S": Vector2(-1096, -328), "W": Vector2(-1256, -392)}
#const directions = ["N", "E", "S", "W"]
const correct_way = "EWNEWNNWSNESW_"
const correct_way_reversed = "WESWESSENSWNE_"
const id = "01forest01"

func _ready():
	reset_scenery()
	yield(get_tree(), "idle_frame")
	restore({id:{"current_pos": 4}})

func maybe_teleport(var to):
	is_teleporting = true
	if to == correct_way_reversed[current_pos]:
		current_pos += 1
		teleport(to)
		yield(change_scenery(current_pos - 1, current_pos), "completed")
	else:
		change_scenery(current_pos, 0)
		current_pos = 0
		yield(teleport_out(), "completed")
	is_teleporting = false

func change_scenery(var old_depth, var depth):
	timer.start(Utils.player.teleport_cooldown)
	yield(timer, "timeout")
	if old_depth < scenery.size():
		for obj in scenery[old_depth]:
			obj.position = Vector2(8, 8) + Vector2(-320, 0)
	if depth < scenery.size():
		for obj in scenery[depth]:
			obj.position = Vector2(8, 8) + Vector2(0, 0)

func reset_scenery():
	for one_scenery in scenery.values():
		for obj in one_scenery:
			obj.position = Vector2(8, 8) + Vector2(-320, 0)
	change_scenery(100000, 0)

func teleport_out():
	SaveLoad.save_game()
	yield(Utils.player.try_teleport(Vector2(1592, -776), "down", get_node("/root/World01/Main/Entities"), Vector2(-10000000, 10000000), Vector2(-10000000, 10000000)), "completed")

func teleport(var to):
	SaveLoad.save_game()
	yield(Utils.player.try_teleport(teleport_pos[to], null, null, Vector2(-1264, -944), Vector2(-496, -316)), "completed")

func save():
	var saved_data = {"current_pos": current_pos}
	return([id, saved_data])

func restore(var saved_data):
	var data = saved_data[id]
	
	current_pos = data["current_pos"]
	change_scenery(0, current_pos)

func _on_Up_area_entered(_area):
	if !is_teleporting:
		maybe_teleport("S")

func _on_Down_area_entered(_area):
	if !is_teleporting:
		maybe_teleport("N")

func _on_Left_area_entered(_area):
	if !is_teleporting:
		maybe_teleport("E")

func _on_Right_area_entered(_area):
	if !is_teleporting:
		maybe_teleport("W")

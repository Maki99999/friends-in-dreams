extends Area2D


var in_use = false
const new_parent = "/root/World01/PuzzleForest/YSort"
const new_position = Vector2(-1096, -344)
const new_direction = "up"
const border_x_after_tp = Vector2(-1264, -944)
const border_y_after_tp = Vector2(-496, -316)

func _ready():
	pass

func _on_ForestEntrance_area_entered(area):
	if area.get_parent() != null && area.get_parent().get_groups().has("Player"):
		in_use = true
		Utils.player.try_teleport(new_position, new_direction, get_node(new_parent), border_x_after_tp, border_y_after_tp)

func _on_ForestEntrance_area_exited(area):
	if area.get_parent() != null && area.get_parent().get_groups().has("Player"):
		in_use = false

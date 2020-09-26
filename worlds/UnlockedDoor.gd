extends StaticBody2D


export(NodePath) var new_parent
export(Vector2) var new_position
export(String, "up", "down", "left", "right") var new_direction
export(Vector2) var border_x_after_tp = Vector2(-10000000, 10000000)
export(Vector2) var border_y_after_tp = Vector2(-10000000, 10000000)

var in_use = false

onready var fx_open = $AudioStreamPlayer
onready var new_parent_node = null

func _ready():
	if new_parent != null && !new_parent.is_empty():
		new_parent_node = get_node(new_parent)

func use():
	teleport()

func _process(_delta):
	if in_use:
		teleport()

func _on_Area2D_area_entered(area):
	if area.get_parent() != null && area.get_parent().get_groups().has("Player"):
		in_use = true
		teleport()

func teleport():
	if Utils.player.try_teleport(new_position, new_direction, new_parent_node, border_x_after_tp, border_y_after_tp):
		fx_open.play()

func _on_Area2D_area_exited(area):
	if area.get_parent() != null && area.get_parent().get_groups().has("Player"):
		in_use = false

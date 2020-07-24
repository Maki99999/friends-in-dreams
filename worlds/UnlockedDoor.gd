extends StaticBody2D


export(NodePath) var new_parent
export(Vector2) var new_position
export(String, "up", "down", "left", "right") var new_direction

var in_use = false

onready var player = get_tree().get_nodes_in_group("Player")[0]
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
	if player.teleport(new_position, new_direction, new_parent_node):
		fx_open.play()

func _on_Area2D_area_exited(area):
	if area.get_parent() != null && area.get_parent().get_groups().has("Player"):
		in_use = false

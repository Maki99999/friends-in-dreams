extends Node


signal scene_change

func _ready():
	pass

func change_scene(var scene):
	if get_tree().change_scene(scene) != OK:
		push_error("Can't load scene!")
	
	yield(get_tree(), "idle_frame")
	emit_signal("scene_change")

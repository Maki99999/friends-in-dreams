extends Area2D


export(String, FILE, "*.json") var dialogue_path
export(Vector2) var moveto_after_dialogue
export(bool) var moveto_is_relative
export(bool) var is_enabled = true

onready var player = get_tree().get_nodes_in_group("Player")[0]
onready var dialogue = get_tree().get_nodes_in_group("dialogue")[0]

func _on_area_entered(area):
	if !is_enabled:
		return
		
	if area.get_parent() != null && area.get_parent().get_groups().has("Player"):
		dialogue.start_dialogue(dialogue_path,\
		{"Rembry": "res://characters/mc/faces/"}, false)
		if moveto_after_dialogue != Vector2.ZERO:
			while dialogue.is_in_dialogue:
				yield(get_tree(), "idle_frame")
			yield(player.move_to(moveto_after_dialogue, moveto_is_relative), "completed")
		player.unfreeze()

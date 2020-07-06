extends StaticBody2D


export(String, FILE, "*.json") var dialogue_path

func use():
	get_tree().get_nodes_in_group("dialogue")[0].start_dialogue(\
	dialogue_path,\
	{"Rembry": "res://characters/mc/faces/"}, true)

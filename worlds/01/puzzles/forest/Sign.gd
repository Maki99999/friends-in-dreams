extends StaticBody2D


func use():
	Utils.dialogue.start_dialogue(\
	"res://worlds/01/puzzles/forest/sign00.json",\
	{"Rembry": "res://characters/mc/faces/"}, true)

extends StaticBody2D


onready var dialogue = get_tree().get_nodes_in_group("dialogue")[0]

var state = "wait"
var has_apples = []

const wants_apples = ["green", "red", "purple"]
const id = "01Kaori"

func _ready():
	pass

func use():
	match state:
		"wait":
			dialogue_wait_apple()
		_:
			pass

func dialogue_wait_apple():
	match Utils.intersection(wants_apples, Utils.player.inventory).size():
		0:
			dialogue.start_dialogue("res://worlds/01/dialogue/KaoriWait01.json", \
				{"Rembry": "res://characters/mc/faces/", \
				"Kaori": "res://worlds/01/characters/Kaori/faces/"})
		1:
			dialogue.start_dialogue("res://worlds/01/dialogue/KaoriWait01.json", \nexttodo
				{"Rembry": "res://characters/mc/faces/", \
				"Kaori": "res://worlds/01/characters/Kaori/faces/"})

func save():
	var saved_data = {"state": state,
					"has_apples": has_apples}
	return([id, saved_data])

func restore(var saved_data):
	var data = saved_data[id]
	
	state = data["state"]
	has_apples = data["has_apples"]
	
	match state:
		_:
			pass

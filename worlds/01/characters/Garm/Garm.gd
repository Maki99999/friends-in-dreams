extends StaticBody2D


onready var machine_anim = $"../Machine".anim
onready var dialogue = Utils.dialogue

var state = "init"

const id = "01Garm"

func _ready():
	pass

func use():
	match state:
		"init":
			yield(dialogue.start_dialogue("res://worlds/01/dialogue/Garm01.json", \
				{"Rembry": "res://characters/mc/faces/", \
				"Garm": "res://worlds/01/characters/Garm/faces/"}), "completed")
			state = "idle"
			SaveLoad.save_game()
		"idle":
			yield(dialogue.start_dialogue("res://worlds/01/dialogue/GarmIdle01.json", \
				{"Rembry": "res://characters/mc/faces/", \
				"Garm": "res://worlds/01/characters/Garm/faces/"}), "completed")

func save():
	var saved_data = {"state": state}
	return([id, saved_data])

func restore(var saved_data):
	var data = saved_data[id]
	
	state = data["state"]
	
	match state:
		_:
			pass

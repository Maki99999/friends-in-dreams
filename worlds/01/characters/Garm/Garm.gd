extends StaticBody2D


onready var machine = $"../Machine"
onready var machine_anim = $"../Machine".anim

var state = "init"

const id = "01Garm"

func _ready():
	pass

func use():
	match state:
		"init":
			yield(Utils.dialogue.start_dialogue("res://worlds/01/dialogue/Garm01.json", \
				{"Rembry": "res://characters/mc/faces/", \
				"Garm": "res://worlds/01/characters/Garm/faces/"}), "completed")
			state = "idle"
			SaveLoad.save_game()
		"idle":
			if !machine.minigame_completed:
				yield(Utils.dialogue.start_dialogue("res://worlds/01/dialogue/GarmIdle01.json", \
					{"Rembry": "res://characters/mc/faces/", \
					"Garm": "res://worlds/01/characters/Garm/faces/"}), "completed")
			else:
				pass #TODO dialogue: haste gut gemacht, dafür darfste die maschine 1 mal benutzen; gib sachen und ich mach das für dich
				state = "items"
				SaveLoad.save_game()
		"items":
			pass #TODO dialogue: gib sachen und ich mach das für dich

func save():
	var saved_data = {"state": state}
	return([id, saved_data])

func restore(var saved_data):
	var data = saved_data[id]
	
	state = data["state"]
	
	match state:
		_:
			pass

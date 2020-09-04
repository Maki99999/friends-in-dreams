extends StaticBody2D


onready var dialogue = get_tree().get_nodes_in_group("dialogue")[0]

var state = "wait"
var has_apples = []

const wants_apples = ["green", "red", "purple"]
const id = "01Kaori"

func _ready():
	state = "wait" #TODO: DEBUG
	pass

func use():
	match state:
		"wait":
			yield(dialogue_wait_apple(), "completed")
		"back1":
			var remaining = Utils.complement(wants_apples, Utils.player.inventory)
			yield(dialogue.start_dialogue("res://worlds/01/dialogue/KaoriGive1.json", \
				{"Rembry": "res://characters/mc/faces/", \
				"Kaori": "res://worlds/01/characters/Kaori/faces/"}, true, self, \
				{"#1": remaining[0]}, "res://worlds/01/dialogue/ApplesNamesN.json"), "completed")
			state = "wait"
			var tree = get_node("/root/World01/Main/Tree")
			tree.state = "2apples"
			tree.tree_after_block.is_enabled = false
		_:
			pass

func dialogue_wait_apple():
	var remaining = Utils.complement(wants_apples, Utils.player.inventory)
	if remaining.has("green"):
		yield(dialogue.start_dialogue("res://worlds/01/dialogue/KaoriWaitGreen.json", \
			{"Rembry": "res://characters/mc/faces/", \
			"Kaori": "res://worlds/01/characters/Kaori/faces/"}), "completed")
	elif remaining.has("red"):
		yield(dialogue.start_dialogue("res://worlds/01/dialogue/KaoriWaitRed.json", \
			{"Rembry": "res://characters/mc/faces/", \
			"Kaori": "res://worlds/01/characters/Kaori/faces/"}), "completed")
	elif remaining.has("purple"):
		yield(dialogue.start_dialogue("res://worlds/01/dialogue/KaoriWaitRed.json", \
			{"Rembry": "res://characters/mc/faces/", \
			"Kaori": "res://worlds/01/characters/Kaori/faces/"}), "completed")
	yield(get_tree(), "idle_frame")

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

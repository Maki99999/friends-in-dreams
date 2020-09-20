extends StaticBody2D


onready var machine = $"../Machine"
onready var machine_anim = $"../Machine".anim

var state = "init"

const id = "01Garm"

func _ready():
	restore({id: {"state": "items"}}) #TODO Debug
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
				yield(Utils.dialogue.start_dialogue("res://worlds/01/dialogue/Garm02.json", \
					{"Rembry": "res://characters/mc/faces/", \
					"Garm": "res://worlds/01/characters/Garm/faces/"}), "completed")
				state = "items"
				SaveLoad.save_game()
		"items":
			try_giving_items()
		"idle02":
			yield(Utils.dialogue.start_dialogue("res://worlds/01/dialogue/GarmIdle02.json", \
				{"Rembry": "res://characters/mc/faces/", \
				"Garm": "res://worlds/01/characters/Garm/faces/"}), "completed")

func try_giving_items():
	if Utils.player.inventory.has("gold") && Utils.player.inventory.has("mold"):
		use_machine()
	elif !Utils.player.inventory.has("gold") && !Utils.player.inventory.has("mold"):
		yield(Utils.dialogue.start_dialogue("res://worlds/01/dialogue/GarmItemIdle01.json", \
			{"Rembry": "res://characters/mc/faces/", \
			"Garm": "res://worlds/01/characters/Garm/faces/"}), "completed")
	
	elif Utils.player.inventory.has("gold") && !machine.has_gold:
		yield(Utils.dialogue.start_dialogue("res://worlds/01/dialogue/GarmItem01.json", \
			{"Rembry": "res://characters/mc/faces/", \
			"Garm": "res://worlds/01/characters/Garm/faces/"}), "completed")
		machine.has_gold = true
		machine.anim.play("Gold")
		SaveLoad.save_game()
	elif Utils.player.inventory.has("mold") && !machine.has_mold:
		yield(Utils.dialogue.start_dialogue("res://worlds/01/dialogue/GarmItem02.json", \
			{"Rembry": "res://characters/mc/faces/", \
			"Garm": "res://worlds/01/characters/Garm/faces/"}), "completed")
		machine.has_mold = true
		machine.anim.play("Mold")
		SaveLoad.save_game()
	
	elif Utils.player.inventory.has("gold"):
		yield(Utils.dialogue.start_dialogue("res://worlds/01/dialogue/GarmItem04.json", \
			{"Rembry": "res://characters/mc/faces/", \
			"Garm": "res://worlds/01/characters/Garm/faces/"}), "completed")
	elif Utils.player.inventory.has("mold"):
		yield(Utils.dialogue.start_dialogue("res://worlds/01/dialogue/GarmItem03.json", \
			{"Rembry": "res://characters/mc/faces/", \
			"Garm": "res://worlds/01/characters/Garm/faces/"}), "completed")

func use_machine():
	Utils.player.freeze()
	yield(Utils.dialogue.start_dialogue("res://worlds/01/dialogue/Garm03.json", \
		{"Rembry": "res://characters/mc/faces/", \
		"Garm": "res://worlds/01/characters/Garm/faces/"}), "completed")
	if !machine.has_mold:
		machine.anim.play("Mold")
		yield(machine.anim, "animation_finished")
	if !machine.has_gold:
		machine.anim.play("Gold")
		yield(machine.anim, "animation_finished")
	machine.anim.play("Pour")
	yield(machine.anim, "animation_finished")
	yield(Utils.dialogue.start_dialogue("res://worlds/01/dialogue/Garm04.json", \
		{"Rembry": "res://characters/mc/faces/", \
		"Garm": "res://worlds/01/characters/Garm/faces/"}), "completed")
	state = "idle02"
	SaveLoad.save_game()
	Utils.player.inventory.append("coin")
	Utils.player.unfreeze()

func save():
	var saved_data = {"state": state}
	return([id, saved_data])

func restore(var saved_data):
	var data = saved_data[id]
	
	state = data["state"]
	
	match state:
		_:
			pass

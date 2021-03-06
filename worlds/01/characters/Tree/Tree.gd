extends StaticBody2D

onready var player = get_tree().get_nodes_in_group("Player")[0]
onready var dialogue = get_tree().get_nodes_in_group("dialogue")[0]
onready var tree_after_block = $"../Entities/TreeAfterBlock"
onready var cutscenes = $"/root/World01/Cutscenes"
onready var sprite = $Sprite
onready var apple_fall_fx = $appleFall
onready var apples = {"red": $RedApple, "green": $GreenApple, "purple": $PurpleApple}

var state = "3apples"

const id = "01Tree"

func _ready():
	sprite.modulate = Color(1, 1, 1, 0)
	
	#yield(get_tree(), "idle_frame")
	#restore({id: {"state": "2applesIdle2"}}) #TODO: DEBUG

func use():
	match state:
		"3apples":
			cutscenes.cutscene_tree_01(self)
		"2applesIdle":
			dialogue.start_dialogue("res://worlds/01/dialogue/TreeIdle.json", \
					{"Rembry": "res://characters/mc/faces/", \
					"Tree": "res://worlds/01/characters/Tree/faces/"})
		"2apples":
			yield(dialogue.start_dialogue("res://worlds/01/dialogue/TreeDenied01.json", \
					{"Rembry": "res://characters/mc/faces/", \
					"Tree": "res://worlds/01/characters/Tree/faces/"}), "completed")
			state = "2applesIdle2"
			SaveLoad.save_game()
		"2applesIdle2":
			if !Utils.player.inventory.has("coin"):
				dialogue.start_dialogue("res://worlds/01/dialogue/TreeIdle2.json", \
						{"Rembry": "res://characters/mc/faces/", \
						"Tree": "res://worlds/01/characters/Tree/faces/"})
			else:
				var remaining = Utils.complement(["green", "red", "purple"], Utils.player.inventory)
				yield(dialogue.start_dialogue("res://worlds/01/dialogue/Tree04.json", \
						{"Rembry": "res://characters/mc/faces/", \
						"Tree": "res://worlds/01/characters/Tree/faces/"}, false, \
						self, {"#1": remaining[0], "#2": remaining[1]}, \
						"res://worlds/01/dialogue/ApplesColorsNamesCaps.json"), "completed")
				state = "3applesIdle"
				SaveLoad.save_game()
		"3applesIdle":
			pass

func apple_fall(var color):
	Utils.change_parent(apples[color], player.get_parent())
	apple_fall_fx.play()
	yield(Utils.move_pos(apples[color], Vector2(apples[color].global_position.x, 208), 1), "completed")
	cutscenes.cutscene_tree_01b(self, color)

func apple_fall2(var color):
	apple_fall_fx.play()
	yield(Utils.move_pos(apples[color], Vector2(apples[color].global_position.x, 208), 1), "completed")
	Utils.change_parent(apples[color], player.get_parent())
	cutscenes.cutscene_tree_02b(self, color)

func apple_take(var color):
	apples[color].modulate = Color(1, 1, 1, 0)

func save():
	var saved_data = {	"state": state}
	return([id, saved_data])

func restore(var saved_data):
	var data = saved_data[id]
	
	state = data["state"]
	
	match state:
		"3apples":
			tree_after_block.is_enabled = true
			sprite.modulate = Color(1, 1, 1, 0)
		"2applesIdle", "2apples", "2applesIdle2":
			sprite.modulate = Color(1, 1, 1, 1)
			apple_take(Utils.intersection(apples.keys(), player.inventory)[0])
			continue
		"2apples", "2applesIdle2":
			tree_after_block.is_enabled = false #TODO

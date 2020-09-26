extends StaticBody2D


onready var anim = $Sprite/AnimationPlayer
onready var anim_steam = $SpriteSteam/AnimationPlayer
onready var anim_emote = $SpriteEmote/AnimationPlayer
onready var walk_fx = $walk_fx
onready var sprite = $Sprite
onready var tween = $Tween
onready var player = get_tree().get_nodes_in_group("Player")[0]
onready var dialogue = get_tree().get_nodes_in_group("dialogue")[0]

var current_volume = -80
var desired_volume = -80
var max_volume = -15
var state = "idle"

const id = "01robot"

func _ready():
	anim_steam.play("steam_normal")
	anim.play("busy 01")
	
	walk_fx.volume_db = -INF
	walk_fx.play()
	
	#restore({id: {"state": "idle02"}})	#TODO DEBUG

func _process(delta):
	if current_volume == -INF:
		current_volume = -80

	if current_volume > desired_volume:
		current_volume -= 600.0 * delta
	if current_volume < desired_volume:
		current_volume += 600.0 * delta
	
	if current_volume <= -80:
		current_volume = -INF
	
	walk_fx.volume_db = current_volume

func move_to(var new_position, var end_dir = null, var speed = 3.0, var pref_updown = false):
	desired_volume = max_volume
	yield(Utils.move_to(self, new_position, anim, \
		{"left": "go_left", "right": "go_right", \
		"up": "go_up", "down": "go_down"}, speed, pref_updown), "completed")
	if end_dir != null:
		desired_volume = -80
		anim.play(end_dir)

func teleport_instant(var new_position, var new_parent = null):
	if new_parent != null:
		get_parent().remove_child(self)
		new_parent.add_child(self)
	global_position = new_position

func teleport(var new_position, var new_parent = null, var fade_in = false, var fade_out = false):
	if fade_out:
		yield(Utils.sprite_disappear(sprite, 0.15), "completed")
	teleport_instant(new_position, new_parent)
	yield(get_tree(), "idle_frame")
	if fade_in:
		yield(Utils.sprite_appear(sprite, 0.15), "completed")

func emote(var name):
	anim_emote.play(name)
	yield(anim_emote, "animation_finished")

func animation(var name):
	anim.play(name)

func move_with_player(var points):
	var max_distance_sqr = 3600
	for point in points:
		while global_position.distance_squared_to(player.global_position) > max_distance_sqr && \
				player.global_position.x < global_position.x:
			yield(get_tree(), "idle_frame")
		
		while global_position.distance_squared_to(point) >= 64:
			while global_position.distance_squared_to(player.global_position) > max_distance_sqr && \
					player.global_position.x < global_position.x:
				yield(get_tree(), "idle_frame")
			if point.distance_squared_to(player.global_position) < max_distance_sqr:
				yield(move_to(point, "down", 3.0), "completed")
			else:
				yield(move_to(global_position + (point - global_position).clamped(16) , "down", 2.5), "completed")

func walk_to_gate01():
	state = "to_gate01"
	SaveLoad.save_game()
	
	yield(move_to(Vector2(-1208, 472), "down", 3.0), "completed")
	yield(teleport(Vector2(600, 648), get_node("/root/World01/Main/Entities"), true, true), "completed")
	yield(move_with_player([Vector2(600, 520), \
							Vector2(952, 520), \
							Vector2(952, 440), \
							Vector2(1544, 440), \
							Vector2(1544, 376)]), "completed")
	state = "gate01"
	SaveLoad.save_game()

func walk_to_tree01():
	state = "tree01"
	SaveLoad.save_game()
	yield(move_to(Vector2(1528, 376), null, 3.0), "completed")
	yield(move_to(Vector2(1528, 216), null, 3.0), "completed")
	yield(move_to(Vector2(1560, 216), "down", 3.0), "completed")

func use():
	match state:
		"gate01":
			dialogue.start_dialogue("res://worlds/01/dialogue/RobotStartGate01.json", \
					{"Rembry": "res://characters/mc/faces/", \
					"Robot": "res://worlds/01/characters/Robot/faces/"})
		"tree01":
			dialogue.start_dialogue("res://worlds/01/dialogue/RobotTree01.json", \
					{"Rembry": "res://characters/mc/faces/", \
					"Robot": "res://worlds/01/characters/Robot/faces/"})
		"idle02":
			dialogue.start_dialogue("res://worlds/01/dialogue/RobotIdle02.json", \
					{"Robot": "res://worlds/01/characters/Robot/faces/"})

func save():
	var saved_data = {"state": state}
	return([id, saved_data])

func restore(var saved_data):
	var data = saved_data[id]
	
	state = data["state"]
	
	match state:
		"gate01", "to_gate01":
			state = "gate01"
			global_position = Vector2(1544,376)
			anim.play("down")
		"tree01":
			global_position = Vector2(1560, 216)
			anim.play("down")
		"idle02":
			Utils.change_parent(self, $"/root/World01/House/Entities")
			global_position = Vector2(-1112, 392)
			anim.play("down")
		"idle", _:
			pass

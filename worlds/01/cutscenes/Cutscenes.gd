extends Node2D


onready var player = get_tree().get_nodes_in_group("Player")[0]
onready var anim = $Cutscenes01
onready var dialogue = get_tree().get_nodes_in_group("dialogue")[0]
onready var music01 = $Music01
onready var timer = $Timer
onready var take_fx = $takeFx

var finished_cutscenes = []
var current_cutscene = ""

const id = "01Cutscenes01"

func _ready():
	#finished_cutscenes = ["Start"] #TODO DEBUG
	yield(get_tree(),"idle_frame")
	if !("Start" in finished_cutscenes):
		cutscene_start()
	else:
		start_music()

func start_cutscene(var name, var save_pos):
	current_cutscene = name
	player.pos_before_cutscene = save_pos
	player.cam_before_cutscene = [player.cam.limit_left, player.cam.limit_right, player.cam.limit_top, player.cam.limit_bottom]

func end_cutscene(var name):
	finished_cutscenes.append(name)
	current_cutscene = ""
	player.pos_before_cutscene = null
	player.cam_before_cutscene = null
	SaveLoad.save_game()

func cutscene_start():
	var start_pos = Vector2(632, 136)
	
	start_cutscene("Start", start_pos)
	player.freeze()
	player.teleport_instant(start_pos)
	anim.play("CutsceneStart")
	yield(anim, "animation_finished")
	dialogue.start_dialogue("res://worlds/01/dialogue/start.json", \
		{"Rembry": "res://characters/mc/faces/"}, true, self)
	player.unfreeze()
	end_cutscene("Start")

func _on_RobotStart_area_entered(area):
	if area.get_parent() != null && area.get_parent().get_groups().has("Player")\
	&& can_start_cutscene("RobotStart"):
		cutscene_robot_start()

func cutscene_robot_start():
	start_cutscene("RobotStart", Vector2(360, 616))
	player.freeze()
	$RobotStart.queue_free()
	var robot = get_node("/root/World01/Main/Entities/Robot")
	var door = get_node("/root/World01/Main/Entities/KaoriDoorOutside")
	
	yield(player.move_cam_to(robot.global_position, 1.0), "completed")

	robot.animation("left")
	yield(robot.emote("exclamation_mark"),"completed")
	player.reset_cam(1.0)

	var left
	if player.global_position.x > 350:
		left = Vector2.LEFT * 16
	else:
		left = Vector2.RIGHT * 16

	yield(robot.move_to(player.global_position + Vector2.DOWN * 16, "up"), "completed")
	yield(dialogue.start_dialogue("res://worlds/01/dialogue/RobotStart01.json", \
		{"Rembry": "res://characters/mc/faces/", \
		"Robot": "res://worlds/01/characters/Robot/faces/"}), "completed")

	player.move_to(Vector2.UP * 16, true)
	yield(robot.move_to(player.global_position + left, null, 9.0), "completed")
	yield(robot.move_to(player.global_position + Vector2.UP * 16, "down", 9.0, true), "completed")

	yield(dialogue.start_dialogue("res://worlds/01/dialogue/RobotStart02.json", \
		{"Rembry": "res://characters/mc/faces/", \
		"Robot": "res://worlds/01/characters/Robot/faces/"}), "completed")

	player.move_to(Vector2.DOWN * 16, true)
	yield(robot.move_to(player.global_position + left, null, 9.0), "completed")
	yield(robot.move_to(player.global_position + Vector2.DOWN * 16, "up", 9.0, true), "completed")
	timer.start(0.7)
	yield(timer, "timeout")

	player.move_to(Vector2.UP * 16, true)
	yield(robot.move_to(player.global_position + left, null, 9.0), "completed")
	yield(robot.move_to(player.global_position + Vector2.UP * 16, "down", 9.0, true), "completed")
	timer.start(0.05)
	yield(timer, "timeout")

	player.move_to(Vector2.DOWN * 16, true)
	yield(robot.move_to(player.global_position + left, null, 9.0), "completed")
	yield(robot.move_to(player.global_position + Vector2.DOWN * 16, "up", 9.0, true), "completed")

	yield(dialogue.start_dialogue("res://worlds/01/dialogue/RobotStart03.json", \
		{"Rembry": "res://characters/mc/faces/", \
		"Robot": "res://worlds/01/characters/Robot/faces/"}), "completed")
	
	robot.move_to(robot.global_position + Vector2.DOWN * 16 + Vector2.RIGHT * 16, null, 3.0, true)
	yield(player.move_to(Vector2.DOWN * 32, true, false), "completed")
	var p = player.move_to(Vector2(488,648))
	yield(robot.move_to(Vector2(488,648), "up", 3.0), "completed")
	yield(robot.teleport(Vector2(-1208, 392), get_node("/root/World01/House/Entities"), false, true), "completed")
	robot.sprite.modulate = Color(1, 1, 1, 1)
	robot.move_to(Vector2(-1112, 392), "down", 3.0)
	yield(p, "completed")

	door.in_use = true
	yield(player.teleport(Vector2(-1208,456), "up", get_node("/root/World01/House/Entities")), "completed")
	door.in_use = false
	yield(player.move_to_mult([Vector2(-1208,392), Vector2(-1128,408), Vector2(-1112,408)]), "completed")
	
	yield(dialogue.start_dialogue("res://worlds/01/dialogue/KaoriStart01.json", \
		{"Rembry": "res://characters/mc/faces/", \
		"Robot": "res://worlds/01/characters/Robot/faces/", \
		"Kaori": "res://worlds/01/characters/Kaori/faces/"}, true, robot), "completed")
	
	player.unfreeze()
	end_cutscene("RobotStart")

func cutscene_tree_01(var tree):
	start_cutscene("Tree01", Vector2(1528, 216))
	player.freeze()
	
	yield(player.move_cam_to(Vector2(1528, 140), 0.85), "completed")
	timer.start(1.0)
	yield(timer, "timeout")
	yield(player.reset_cam(0.85), "completed")
	
	yield(dialogue.start_dialogue("res://worlds/01/dialogue/Tree01.json", \
					{"Rembry": "res://characters/mc/faces/", \
					"Robot": "res://worlds/01/characters/Robot/faces/"}), "completed")
	yield(Utils.sprite_appear(tree.sprite, 1), "completed")
	yield(dialogue.start_dialogue("res://worlds/01/dialogue/Tree02.json", \
					{"Rembry": "res://characters/mc/faces/", \
					"Tree": "res://worlds/01/characters/Tree/faces/"}, true, \
					tree, {"#1": "green", "#2": "red", "#3": "purple"}, \
					"res://worlds/01/dialogue/ApplesColorsNamesCaps.json"), "completed")

func cutscene_tree_01b(var tree, var color):
	var robot = get_node("/root/World01/Main/Entities/Robot")
	var kaori = get_node("/root/World01/House/Entities/Kaori")
	robot.move_to(Vector2(1544, 344), "down", 3.0)
	
	yield(dialogue.start_dialogue("res://worlds/01/dialogue/Tree03.json", \
					{"Rembry": "res://characters/mc/faces/"}), "completed")
	
	timer.start(0.2)
	yield(timer, "timeout")
	tree.apple_take(color)
	take_fx.play()
	
	robot.teleport(Vector2(-1112, 392), get_node("/root/World01/House/Entities"), false, true)
	robot.state = "idle02"
	player.inventory.append(color)
	tree.state = "2applesIdle"
	kaori.state = "back1"
	
	player.unfreeze()
	end_cutscene("Tree01")
	
func cutscene_tree_02b(var tree, var color):
	var kaori = get_node("/root/World01/House/Entities/Kaori")
	
	yield(dialogue.start_dialogue("res://worlds/01/dialogue/Tree03.json", \
					{"Rembry": "res://characters/mc/faces/"}), "completed")
	
	timer.start(0.2)
	yield(timer, "timeout")
	tree.apple_take(color)
	take_fx.play()
	
	player.inventory.append(color)
	kaori.state = "back2"
	
	player.unfreeze()

func can_start_cutscene(var cutscene_name):
	return !finished_cutscenes.has(cutscene_name) \
		&& current_cutscene != cutscene_name

func start_music():
	music01.play()

func save():
	var saved_data = {"finished_cutscenes": finished_cutscenes}
	return([id, saved_data])

func restore(var saved_data):
	var data = saved_data[id]
	finished_cutscenes = data["finished_cutscenes"]

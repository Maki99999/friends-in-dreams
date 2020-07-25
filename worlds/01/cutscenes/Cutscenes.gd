extends Node2D


onready var player = get_tree().get_nodes_in_group("Player")[0]
onready var anim = $Cutscenes01
onready var dialogue = get_tree().get_nodes_in_group("dialogue")[0]
onready var music01 = $Music01

var finished_cutscenes = ["Start"]
var current_cutscene = ""
var start_pos = Vector2(632, 136)
var dialogue_path_prefix = "res://worlds/01/dialogue/"

const id = "01Cutscenes01"

func _ready():
	if !("Start" in finished_cutscenes):
		cutscene_start()
	else:
		start_music()

func cutscene_start():
	player.freeze()
	player.teleport_instant(start_pos)
	anim.play("CutsceneStart")
	yield(anim, "animation_finished")
	dialogue.start_dialogue(dialogue_path_prefix + "/start.json", \
		{"Rembry": "res://characters/mc/faces/"}, true, self)
	player.unfreeze()
	finished_cutscenes.append("Start")

func _on_RobotStart_area_entered(area):
	if area.get_parent() != null && area.get_parent().get_groups().has("Player")\
	&& can_start_cutscene("RobotStart"):
		cutscene_robot_start()

func cutscene_robot_start():
	$RobotStart.queue_free()
	player.freeze()
	var robot = get_node("/root/World01/Main/Entities/Robot")
	var door = get_node("/root/World01/Main/Entities/KaoriDoorOutside")
	var timer = Timer.new()
	get_tree().root.add_child(timer)
	
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
	yield(dialogue.start_dialogue(dialogue_path_prefix + "/RobotStart01.json", \
		{"Rembry": "res://characters/mc/faces/", \
		"Robot": "res://worlds/01/characters/Robot/faces/"}), "completed")

	player.move_to(Vector2.UP * 16, true)
	yield(robot.move_to(player.global_position + left, null, 9.0), "completed")
	yield(robot.move_to(player.global_position + Vector2.UP * 16, "down", 9.0, true), "completed")

	yield(dialogue.start_dialogue(dialogue_path_prefix + "/RobotStart02.json", \
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

	yield(dialogue.start_dialogue(dialogue_path_prefix + "/RobotStart03.json", \
		{"Rembry": "res://characters/mc/faces/", \
		"Robot": "res://worlds/01/characters/Robot/faces/"}), "completed")
	
	robot.move_to(robot.global_position + Vector2.DOWN * 16 + Vector2.RIGHT * 16, null, 3.0, true)
	yield(player.move_to(Vector2.DOWN * 32, true, false), "completed")
	var p = player.move_to(Vector2(488,648))
	yield(robot.move_to(Vector2(488,648), "up", 3.0), "completed")
	yield(Utils.sprite_disappear(robot.sprite, 0.15), "completed")
	robot.teleport_instant(Vector2(-1208, 392), get_node("/root/World01/House/Entities"))
	robot.sprite.modulate = Color(1, 1, 1, 1)
	robot.move_to(Vector2(-1112, 392), "down", 3.0)
	yield(p, "completed")

	door.in_use = true
	yield(player.teleport(Vector2(-1208,456), "up", get_node("/root/World01/House/Entities")), "completed")
	door.in_use = false
	yield(player.move_to_mult([Vector2(-1208,392), Vector2(-1128,408), Vector2(-1112,408)]), "completed")
	
	yield(dialogue.start_dialogue(dialogue_path_prefix + "/KaoriStart01.json", \
		{"Rembry": "res://characters/mc/faces/", \
		"Robot": "res://worlds/01/characters/Robot/faces/", \
		"Kaori": "res://worlds/01/characters/Kaori/faces/"}), "completed")
	
	player.unfreeze()
	timer.queue_free()
	finished_cutscenes.append("RobotStart")

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

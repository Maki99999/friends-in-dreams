extends Area2D


onready var car = $Car
onready var player = get_tree().get_nodes_in_group("Player")[0]
onready var black = get_node(black_path)
onready var timer = $Timer
onready var fx_horn = $horn
onready var fx_wheels = $wheels
onready var fx_crash = $crash
onready var music = $music

export(NodePath) var black_path

var last_delta = 0

func _ready():
	car.visible = false
	black.visible = false
	music.play()

func _process(delta):
	last_delta = delta

func _on_area_entered(area):
	if area.get_parent() != null && area.get_parent().get_groups().has("Player"):
		player.freeze()
		fx_horn.play()
		
		timer.start(0.3)
		yield(timer, "timeout")
		var car_func = move_car()
		fx_wheels.play()
		
		yield(car_func, "completed")
		black.visible = true
		fx_crash.play()
		fx_wheels.stop()
		music.stop()
		yield(fx_crash, "finished")
	
		if get_tree().change_scene("res://worlds/01/scene01.tscn") != OK:
			push_error("Can't load game!")

func move_car():
	car.global_position.x = player.global_position.x + 20 * 16
	car.visible = true
	while car.global_position.x > player.global_position.x:
		yield(get_tree(), "idle_frame")
		car.global_position += (60 * 16 * Vector2.LEFT * last_delta)

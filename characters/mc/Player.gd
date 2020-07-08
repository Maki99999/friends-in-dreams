extends Node2D


const id = "Player0"

onready var tile_size = get_parent().tile_size
onready var animation_player = $AnimationPlayer
onready var raycast_moving = $RayCast2DMoving
onready var raycast_using = $RayCast2DUsing
onready var tween = $Tween
onready var not_teleporting = $NotTeleporting
onready var timer = $Timer
onready var footsteps = $NotTeleporting/Footsteps
onready var footstep_area = $NotTeleporting/Footsteps/FootstepArea
onready var fade_anim = get_tree().get_nodes_in_group("fade_anim")[0]
onready var facing = start_dir

export(float) var use_cooldown = 1
export(float) var teleport_cooldown = 0.5
export(String, "down", "up", "left", "right") var start_dir

var inputs = {	"right"	: Vector2.RIGHT,
				"left"	: Vector2.LEFT,
				"up"	: Vector2.UP,
				"down"	: Vector2.DOWN}
var speed = 3.0
var dir_min_press_time = 80
var dir_last_pressed_button
var dir_last_pressed_time = -1000.0
var use_on_cooldown = false
var proc_sem = 1
var is_teleporting = false

func _ready():
	animation_player.play(start_dir)
	freeze()
	yield(get_tree(), "idle_frame")
	unfreeze()

func _process(_delta):
	try_moving()
	try_using()

func try_using():
	if use_on_cooldown:
		return
	if Input.is_action_just_pressed("ui_accept"):
		raycast_using.cast_to = inputs[facing] * tile_size
		raycast_using.force_raycast_update()
		if !raycast_using.is_colliding():
			return
		
		var use_result = raycast_using.get_collider().use() # true = with cooldown
		if use_result == null || use_result:
			timer.start(use_cooldown)
			use_on_cooldown = true
			yield(timer, "timeout")
			use_on_cooldown = false

func try_moving():
	for dir in inputs.keys():
		if Input.is_action_pressed("ui_" + dir):
			if dir_last_pressed_button == null || dir_last_pressed_button != dir:
				dir_last_pressed_time = OS.get_ticks_msec()
				dir_last_pressed_button = dir
				
			if OS.get_ticks_msec() <= dir_last_pressed_time + dir_min_press_time:
				facing = dir
				animation_player.play(dir)
				return
				
			freeze()
			
			raycast_moving.cast_to = inputs[dir] * tile_size
			raycast_moving.force_raycast_update()
			if !raycast_moving.is_colliding():
				yield(move(dir), "completed")
				if !Input.is_action_pressed("ui_" + dir) || proc_sem < 0:
					animation_player.play(facing)
			else:
				facing = dir
				animation_player.play(dir)
				yield(animation_player, "animation_finished")
			
			unfreeze()
			return
	
	animation_player.play(facing)

func move(var dir):
	facing = dir
	animation_player.play("walk_" + dir)

	position = position - Vector2.ONE * (tile_size / 2) + inputs[dir] * tile_size
	position = position.snapped(Vector2.ONE * tile_size) + Vector2.ONE * (tile_size / 2)
	var start_position_local = - inputs[dir] * tile_size
	not_teleporting.position = start_position_local
	
	tween.interpolate_property(not_teleporting, "position", start_position_local, Vector2.ZERO, 1.0/speed, Tween.TRANS_LINEAR)
	
	tween.start()
	yield(tween, "tween_completed")
	
func freeze():
	proc_sem -= 1
	if proc_sem <= 0:
		set_process(false)
	
func unfreeze():
	proc_sem += 1
	if proc_sem >= 1:
		set_process(true)

func teleport(var new_parent, var new_position, var new_direction):
	if is_teleporting:
		return false
	is_teleporting = true
	freeze()
	
	fade_anim.play_backwards("fade_in")
	yield(fade_anim, "animation_finished")
	
	get_parent().remove_child(self)
	new_parent.add_child(self)
	position = new_position - new_parent.global_position
	get_parent().snap_to_grid(self)
	facing = new_direction
	animation_player.play(new_direction)
	
	fade_anim.play("fade_in")
	
	timer.start(teleport_cooldown)
	yield(timer, "timeout")
	unfreeze()
	is_teleporting = false
	return true

func move_to(var new_position, var is_relative = false):
	if is_relative:
		new_position = global_position + new_position
	new_position = new_position - Vector2.ONE * (tile_size / 2)
	new_position = new_position.snapped(Vector2.ONE * tile_size) + Vector2.ONE * (tile_size / 2)

	while new_position.x > global_position.x:
		yield(move("right"), "completed")
	while new_position.x < global_position.x:
		yield(move("left"), "completed")
	while new_position.y > global_position.y:
		yield(move("down"), "completed")
	while new_position.y < global_position.y:
		yield(move("up"), "completed")

func play_footstep_sound():
	var current_areas = footstep_area.get_overlapping_areas()
	if current_areas == null || current_areas.empty():
		footsteps.play("void")
	else:
		var area_name = current_areas[0].name
		footsteps.play(area_name)

func save():
	var saved_data = {	"x": global_position.x, 
						"y": global_position.y, 
						"facing": facing}
	return([id, saved_data])

func restore(var saved_data):
	var player_data = saved_data[id]
	global_position = Vector2(player_data["x"], player_data["y"])

	facing = player_data["facing"]
	animation_player.play(facing)

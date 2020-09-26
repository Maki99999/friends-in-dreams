extends Node2D


const id = "Player0"

onready var tile_size = get_parent().tile_size
onready var animation_player = $AnimationPlayer
onready var raycast_moving = $RayCast2DMoving
onready var raycast_using = $RayCast2DUsing
onready var tween = $Tween
onready var not_teleporting = $NotTeleporting
onready var timer = $TimerFreeze
onready var timer_use = $TimerFreeze/TimerUse
onready var footsteps = $NotTeleporting/Footsteps
onready var footstep_area = $NotTeleporting/Footsteps/FootstepArea
onready var cam = $NotTeleporting/Camera2D
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
var pos_before_cutscene = null
var inventory = []

func _ready():
	#inventory = ["green", "gold", "mold", "coin", "red"] #TODO DEBUG
	
	animation_player.play(start_dir)
	
	timer.start(1.0)
	freeze()
	yield(timer, "timeout")
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
			timer_use.start(use_cooldown)
			use_on_cooldown = true
			yield(timer_use, "timeout")
			use_on_cooldown = false

func add_use_cooldown():
	timer_use.start(use_cooldown)
	use_on_cooldown = true
	yield(timer_use, "timeout")
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
	if Input.is_action_pressed("ui_cancel"):
		animation_player.play("walk_" + dir + "_fast")
	else:
		animation_player.play("walk_" + dir)

	global_position = global_position - Vector2.ONE * (tile_size / 2) + inputs[dir] * tile_size
	global_position = global_position.snapped(Vector2.ONE * tile_size) + Vector2.ONE * (tile_size / 2)
	var start_position_local = inputs[dir] * -tile_size
	not_teleporting.position = start_position_local
	
	var current_walk_speed = speed
	if Input.is_action_pressed("ui_cancel"):
		current_walk_speed *= 1.8
	tween.interpolate_property(not_teleporting, "position", start_position_local, Vector2.ZERO, 1.0/current_walk_speed, Tween.TRANS_LINEAR)
	
	tween.start()
	yield(tween, "tween_all_completed")
	
func freeze():
	proc_sem -= 1
	if proc_sem <= 0:
		set_process(false)
	
func unfreeze():
	proc_sem += 1
	if proc_sem >= 1:
		set_process(true)

func teleport_instant(var new_position, var new_direction = null, var new_parent = null):
	if new_parent != null:
		get_parent().remove_child(self)
		new_parent.add_child(self)
		position = new_position - new_parent.global_position
		get_parent().snap_to_grid(self)
	else:
		global_position = new_position
	if new_direction != null:
		facing = new_direction
		animation_player.play(new_direction)

func try_teleport(var new_position, var new_direction = null, var new_parent = null, \
		var border_x = Vector2(-10000000, 10000000), var border_y = Vector2(-10000000, 10000000)):
	if is_teleporting:
		return false
	yield(teleport(new_position, new_direction, new_parent, border_x, border_y), "completed")
	return true

func teleport(var new_position, var new_direction = null, var new_parent = null, \
		var border_x = Vector2(-10000000, 10000000), var border_y = Vector2(-10000000, 10000000)):
	is_teleporting = true
	freeze()
	
	fade_anim.play_backwards("fade_in")
	yield(fade_anim, "animation_finished")
	
	teleport_instant(new_position, new_direction, new_parent)
	change_fixed_cam(border_x, border_y)
	
	fade_anim.play("fade_in")
	
	timer.start(teleport_cooldown)
	yield(timer, "timeout")
	unfreeze()
	is_teleporting = false

func move_to(var new_position, var is_relative = false, var stop_after = true):
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
	if stop_after:
		animation_player.play(facing)
	yield(get_tree(), "idle_frame")

func move_to_mult(var new_positions):
	for i in range(new_positions.size() - 1):
		yield(move_to(new_positions[i], false, false), "completed")
	yield(move_to(new_positions[-1], false, true), "completed")

func move_cam_to(var new_position, var cam_speed): #cam_speed in percent
	if tween.is_active():
		yield(tween, "tween_all_completed")

	tween.interpolate_property(cam, "global_position", cam.global_position, new_position, 1.0/cam_speed, Tween.TRANS_LINEAR)
	tween.start()
	yield(tween, "tween_all_completed")

func reset_cam(var cam_speed):
	if tween.is_active():
		yield(tween, "tween_all_completed")
	
	tween.interpolate_property(cam, "position", cam.position, Vector2.ZERO, 1.0/cam_speed, Tween.TRANS_LINEAR)
	tween.start()
	yield(tween, "tween_all_completed")

func change_fixed_cam(var border_x = Vector2(-10000000, 10000000), var border_y = Vector2(-10000000, 10000000)):
	var diff = border_x.y - border_x.x
	if diff < 320:
		cam.limit_left = border_x.x - ((320 - diff) / 2)
		cam.limit_right = border_x.y + ((320 - diff) / 2)
	else:
		cam.limit_left = border_x.x
		cam.limit_right = border_x.y
	
	diff = border_y.y - border_y.x
	if diff < 180:
		cam.limit_top = border_y.x - ((180 - diff) / 2)
		cam.limit_bottom = border_y.y + ((180 - diff) / 2)
	else:
		cam.limit_top = border_y.x
		cam.limit_bottom = border_y.y

func play_footstep_sound():
	var current_areas = footstep_area.get_overlapping_areas()
	if current_areas == null || current_areas.empty():
		footsteps.play("void")
	else:
		var area_name = current_areas[0].name
		footsteps.play(area_name)

func save():
	var pos = global_position
	if pos_before_cutscene != null:
		pos = pos_before_cutscene
	var saved_data = {	"x": pos.x,
						"y": pos.y,
						"parent": get_parent().get_path(),
						"cam.limit_left": cam.limit_left,
						"cam.limit_right": cam.limit_right,
						"cam.limit_top": cam.limit_top,
						"cam.limit_bottom": cam.limit_bottom,
						"facing": facing,
						"inventory": inventory}
	return([id, saved_data])

func restore(var saved_data):
	var player_data = saved_data[id]
	
	inventory = player_data["inventory"]

	cam.limit_left = player_data["cam.limit_left"]
	cam.limit_right = player_data["cam.limit_right"]
	cam.limit_top = player_data["cam.limit_top"]
	cam.limit_bottom = player_data["cam.limit_bottom"]

	facing = player_data["facing"]
	animation_player.play(facing)

	var new_parent = get_node(NodePath(player_data["parent"]))
	get_parent().remove_child(self)
	new_parent.add_child(self)
	
	global_position = Vector2(player_data["x"], player_data["y"])

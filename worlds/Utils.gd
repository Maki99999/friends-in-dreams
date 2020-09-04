extends Node2D


onready var player = get_tree().get_nodes_in_group("Player")[0]
onready var dialogue = get_tree().get_nodes_in_group("dialogue")[0]

var tween

const tile_size = 16
const tile_size_half = 8
const anim_names_default = {"left": "left", "right": "right", "up": "up", "down": "down"}
const inputs = {"right"	: Vector2.RIGHT,
				"left"	: Vector2.LEFT,
				"up"	: Vector2.UP,
				"down"	: Vector2.DOWN}

func _ready():
	tween = Tween.new()
	get_tree().get_root().call_deferred("add_child", tween)

func move_to(var obj, var new_position, var anim,
		var anim_names = anim_names_default, var speed = 3.0, \
		var pref_updown = false, var is_relative = false):
	
	if is_relative:
		new_position = global_position + new_position
	new_position = new_position - Vector2.ONE * tile_size_half
	new_position = new_position.snapped(Vector2.ONE * tile_size) + Vector2.ONE * tile_size_half
	
	if(pref_updown):
		while new_position.y > obj.global_position.y:
			anim.play(anim_names["down"])
			yield(move(obj, "down", speed), "completed")
		while new_position.y < obj.global_position.y:
			anim.play(anim_names["up"])
			yield(move(obj, "up", speed), "completed")
		
	while new_position.x > obj.global_position.x:
		anim.play(anim_names["right"])
		yield(move(obj, "right", speed), "completed")
	while new_position.x < obj.global_position.x:
		anim.play(anim_names["left"])
		yield(move(obj, "left", speed), "completed")
		
	if(!pref_updown):
		while new_position.y > obj.global_position.y:
			anim.play(anim_names["down"])
			yield(move(obj, "down", speed), "completed")
		while new_position.y < obj.global_position.y:
			anim.play(anim_names["up"])
			yield(move(obj, "up", speed), "completed")
	
func move(var obj, var dir, var speed):
	var old_position = obj.global_position
	var new_position = old_position - Vector2.ONE * (tile_size / 2.0) + inputs[dir] * tile_size
	new_position = new_position.snapped(Vector2.ONE * tile_size) + Vector2.ONE * (tile_size / 2.0)
	
	tween.interpolate_property(obj, "global_position", old_position, new_position, 1.0/speed, Tween.TRANS_LINEAR)
	tween.call_deferred("start")
	yield(tween, "tween_completed")

func move_pos(var obj, var new_position, var speed):
	var old_position = obj.global_position
	
	tween.interpolate_property(obj, "global_position", old_position, new_position, 1.0/speed, Tween.TRANS_LINEAR)
	tween.call_deferred("start")
	yield(tween, "tween_completed")

func sprite_disappear(var sprite, var duration):
	
	tween.interpolate_property(sprite, "modulate", \
			Color(1, 1, 1, 1), Color(1, 1, 1, 0), duration, \
			Tween.TRANS_LINEAR, Tween.EASE_IN)
	tween.call_deferred("start")
	yield(tween, "tween_completed")

func sprite_appear(var sprite, var duration):	
	tween.interpolate_property(sprite, "modulate", \
			Color(1, 1, 1, 0), Color(1, 1, 1, 1), duration, \
			Tween.TRANS_LINEAR, Tween.EASE_IN)
	tween.call_deferred("start")
	yield(tween, "tween_completed")

func intersection(var array1, var array2):
	var intersection = []
	for item in array1:
		if array2.has(item):
			intersection.append(item)
	return intersection
	
func complement(var array1, var array2):
	var complement = array1
	for item in array2:
		if array1.has(item):
			complement.remove(complement.find(item))
	return complement

func change_parent(var obj, var new_parent):
	var old_pos = obj.global_position
	obj.get_parent().call_deferred("remove_child", obj)
	new_parent.call_deferred("add_child", obj)
	obj.global_position = old_pos

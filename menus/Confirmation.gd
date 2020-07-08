extends ColorRect


var active = false
var main_button_current = 2

onready var buttons = [$ButtonYes, $ButtonNo]
onready var parent = get_parent()

export(Texture) var texture_normal
export(Texture) var texture_selected
export(ShaderMaterial) var shader_selected

func _ready():
	visible = true
	close()

func _input(event):
	if !(event is InputEventKey) || !active:
		return
	if event.is_action_pressed("ui_left"):
		change_button(true)
	elif event.is_action_pressed("ui_right"):
		change_button(false)
	elif event.is_action_pressed("ui_accept"):
		get_tree().set_input_as_handled()
		press_button()

func open():
	change_button(false, false)
	anchor_left = 0
	anchor_right = 1
	active = true

func close():
	anchor_left = 2
	anchor_right = 3
	active = false

func change_button(var left, var with_sound = true):
	var prev = main_button_current
	var unselected
	if left:
		main_button_current = 0
		unselected = 1
	else:
		main_button_current = 1
		unselected = 0
	
	if prev != main_button_current:
		if with_sound:
			get_parent().play_sound_select()
		buttons[unselected].material = null
		buttons[unselected].texture = texture_normal
		buttons[unselected].get_child(0).material = null
	
		buttons[main_button_current].material = shader_selected
		buttons[main_button_current].texture = texture_selected
		buttons[main_button_current].get_child(0).material = shader_selected
	
func press_button():
	get_parent().play_sound_press()
	match main_button_current:
		0:
			active = false
			parent.fade.play_backwards("fade_in")
			yield(parent.fade, "animation_finished")
			if get_tree().change_scene("res://worlds/00/scene00.tscn") != OK:
				push_error("Cannot load first scene!")
		1:
			parent.close_confirmation()

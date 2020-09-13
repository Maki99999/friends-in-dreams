extends Control


export(Texture) var texture_normal
export(Texture) var texture_selected
export(ShaderMaterial) var shader_selected

onready var main_buttons_parent = $Main
onready var options_menu = $Options
onready var confirmation_menu = $Confirmation
onready var fade = $Fade/AnimationPlayer
onready var fx_select = $SelectSound
onready var fx_press = $PressSound
onready var main_button_count = main_buttons_parent.get_child_count()

var options_open = false
var main_button_current = -1
var locked = false
var skip_load = false

func _ready():
	change_button(0, false)
	skip_load = !SaveLoad.save_exists()
	if skip_load:
		var button = main_buttons_parent.get_child(1)
		button.material = null
		button.texture = texture_normal
		button.get_child(0).material = null
		button.get_child(0).bbcode_enabled = true
		button.get_child(0).bbcode_text = "[color=#999999]" + button.get_child(0).text + "[/color]"

func _input(event):
	if !(event is InputEventKey) || locked:
		return
	if event.is_action_pressed("ui_debug"):
		SceneManager.change_scene("res://worlds/01/scene01.tscn") #TODO DEBUG
	if event.is_action_pressed("ui_menu") && options_open:
		play_sound_press()
		close_options()
		close_confirmation()
	elif !options_open:
		if event.is_action_pressed("ui_down"):
			change_button(false)
		elif event.is_action_pressed("ui_up"):
			change_button(true)
		elif event.is_action_pressed("ui_accept"):
			press_button()

func play_sound_select():
	fx_select.play()

func play_sound_press():
	fx_press.play()

func show_menu():
	main_buttons_parent.anchor_left = 0.5
	main_buttons_parent.anchor_right = 0.5

func hide_menu():
	main_buttons_parent.anchor_left = 2.5
	main_buttons_parent.anchor_right = 2.5

func open_options():
	hide_menu()
	options_open = true
	options_menu.open()

func close_options():
	options_menu.close()
	show_menu()
	options_open = false

func open_confirmation():
	options_open = true
	hide_menu()
	confirmation_menu.open()

func close_confirmation():
	confirmation_menu.close()
	show_menu()
	options_open = false

func change_button(var up, var with_sound = true):
	if with_sound:
		play_sound_select()
	if up is int:
		main_button_current = up
	elif up:
		main_button_current = posmod(main_button_current - 1, main_button_count)
		if main_button_current == 1 && skip_load:
			main_button_current = posmod(main_button_current - 1, main_button_count)
			
	else:
		main_button_current = posmod(main_button_current + 1, main_button_count)
		if main_button_current == 1 && skip_load:
			main_button_current = posmod(main_button_current + 1, main_button_count)
		
	var buttons = main_buttons_parent.get_children()
	for i in buttons.size():
		var button = main_buttons_parent.get_children()[i]
		if skip_load && i == 1:
			continue
		button.material = null
		button.texture = texture_normal
		button.get_child(0).material = null
	
	var sel_button = main_buttons_parent.get_child(main_button_current)
	sel_button.material = shader_selected
	sel_button.texture = texture_selected
	sel_button.get_child(0).material = shader_selected

func press_button():
	play_sound_press()
	match main_button_current:
		0:
			open_confirmation()
		1:
			SaveLoad.load_game()
		2:
			open_options()
		3:
			get_tree().quit()
		_:
			pass


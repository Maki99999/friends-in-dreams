extends Control


export(Texture) var texture_normal
export(Texture) var texture_selected
export(ShaderMaterial) var shader_selected

onready var main_buttons_parent = $Main
onready var options_menu = $Options
onready var fade = $Fade/AnimationPlayer
onready var main_button_count = main_buttons_parent.get_child_count()

var options_open = false
var main_button_current = -1
var locked = false

func _ready():
	change_button(0)

func _input(event):
	if !(event is InputEventKey) || locked:
		return
	if event.is_action_pressed("ui_menu") && options_open:
		close_options()
	elif !options_open:
		if event.is_action_pressed("ui_down"):
			change_button(false)
		elif event.is_action_pressed("ui_up"):
			change_button(true)
		elif event.is_action_pressed("ui_accept"):
			press_button()

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

func change_button(var up):
	if up is int:
		main_button_current = up
	elif up:
		main_button_current = posmod(main_button_current - 1, main_button_count)
	else:
		main_button_current = posmod(main_button_current + 1, main_button_count)
		
	for button in main_buttons_parent.get_children():
		button.material = null
		button.texture = texture_normal
		button.get_child(0).material = null
	
	var sel_button = main_buttons_parent.get_child(main_button_current)
	sel_button.material = shader_selected
	sel_button.texture = texture_selected
	sel_button.get_child(0).material = shader_selected

func press_button():
	match main_button_current:
		0:
			#newgame, vllt noch ne warnung, wenn noch anderes vorhanden ist
			locked = true
			fade.play_backwards("fade_in")
			yield(fade, "animation_finished")
			if get_tree().change_scene("res://worlds/00/scene00.tscn") != OK:
				push_error("Cannot load first scene!")
		1:
			#loadgame
			pass
		2:
			open_options()
		3:
			#save
			get_tree().quit()
		_:
			pass


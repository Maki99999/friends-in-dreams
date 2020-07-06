extends Control


export(Texture) var texture_normal
export(Texture) var texture_selected
export(ShaderMaterial) var shader_selected

onready var main_esc_menu = $Main
onready var options_menu = $Options
onready var main_button_count = main_esc_menu.get_child_count()

var menu_open = false
var options_open = false
var main_button_current = -1

func _ready():
	main_esc_menu.visible = true
	close_menu()

func _input(event):
	if !(event is InputEventKey):
		return
	if event.is_action_pressed("ui_menu"):
		if !menu_open:
			open_menu()
		elif !options_open:
			close_menu()
		else:
			close_options()
	elif !options_open && menu_open:
		if event.is_action_pressed("ui_down"):
			change_button(false)
		elif event.is_action_pressed("ui_up"):
			change_button(true)
		elif event.is_action_pressed("ui_accept"):
			press_button()

func open_menu():
	menu_open = true
	get_tree().paused = true
	anchor_left = 0
	anchor_right = 1
	change_button(0)

func close_menu():
	anchor_right = 3
	anchor_left = 2
	get_tree().paused = false
	menu_open = false

func open_options():
	main_esc_menu.visible = false
	options_open = true
	options_menu.open()

func close_options():
	options_menu.close()
	main_esc_menu.visible = true
	options_open = false

func change_button(var up):
	if up is int:
		main_button_current = up
	elif up:
		main_button_current = posmod(main_button_current - 1, main_button_count)
	else:
		main_button_current = posmod(main_button_current + 1, main_button_count)
		
	for button in main_esc_menu.get_children():
		button.material = null
		button.texture = texture_normal
		button.get_child(0).material = null
	
	var sel_button = main_esc_menu.get_child(main_button_current)
	sel_button.material = shader_selected
	sel_button.texture = texture_selected
	sel_button.get_child(0).material = shader_selected

func press_button():
	match main_button_current:
		1:
			open_options()
		2:
			#save
			get_tree().quit()
		_:
			close_menu()

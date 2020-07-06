extends VBoxContainerVarWidth


export(Texture) var selected_texture

var current_values = {
	"audio": {
		"volume_main": 100,
		"volume_fx": 100,
		"volume_music": 100
	},
	"graphics": {
		"fullscreen": false
	}
}
var active = false
var current_setting = -1
# var pressing = [false, false]
var first_press = [false, false]
var last_time_pressed = [-1.0, -1.0]
var config_file = ConfigFile.new()

const save_path = "user://config.cfg"

onready var settings_count = get_child_count()

func _process(_delta):
	if active:
		if Input.is_action_just_pressed("ui_down"):
			change_setting(false)
		elif Input.is_action_just_pressed("ui_up"):
			change_setting(true)
		
		if Input.is_action_just_pressed("ui_left"):
			first_press[0] = true
		elif Input.is_action_just_pressed("ui_right"):
			first_press[1] = true
		
		if Input.is_action_pressed("ui_left"):
			value_change_pressing(0)
		elif Input.is_action_pressed("ui_right"):
			value_change_pressing(1)

func value_change_pressing(var index):
	var change
	if index == 0:
		change = true
	else:
		change = false
	if first_press[index]:
		change_setting_value(change)
		first_press[index] = false
		last_time_pressed[index] = OS.get_ticks_msec() + 320
	elif last_time_pressed[index] + 80 < OS.get_ticks_msec():
		change_setting_value(change)
		last_time_pressed[index] = OS.get_ticks_msec()

func _ready():
	visible = true
	load_settings()
	close(false)

func change_setting(var up):
	if up is int:
		current_setting = up
	elif up:
		current_setting = posmod(current_setting - 1, settings_count)
	else:
		current_setting = posmod(current_setting + 1, settings_count)
		
	for setting in get_children():
		if !(setting is Control):
			continue
		setting.texture = null
	
	get_child(current_setting).texture = selected_texture

func change_setting_value(var left):
	var new_value_change
	if left:
		new_value_change = -1
	else:
		new_value_change = 1
	
	if current_setting < 3:
		change_audio(current_setting, new_value_change)
	elif current_setting < 4:
		change_graphics(current_setting, left)

func change_audio(var which_setting, var value_change, var relative = true):
	var old_value = current_values["audio"].values()[which_setting]
	var new_value
	if relative:
		new_value = clamp(old_value + value_change, 0, 100)
	else:
		new_value = value_change
	current_values["audio"][index_to_audio_name(which_setting)] = new_value
	
	var db_value = linear2db(new_value / 100.0)
	AudioServer.set_bus_volume_db(AudioServer.get_bus_index(index_to_audio_bus_name(which_setting)), db_value)
	
	var value_text = "< " + String(new_value) + " >"
	if new_value == 0:
		value_text = "  0 >"
	elif new_value == 100:
		value_text = "< 100"
	
	get_child(which_setting).get_node("Value").bbcode_text = value_text

func index_to_audio_name(var index):
	if index == 0:
		return "volume_main"
	if index == 1:
		return "volume_fx"
	if index == 2:
		return "volume_music"

func index_to_audio_bus_name(var index):
	if index == 0:
		return "Master"
	if index == 1:
		return "FX"
	if index == 2:
		return "Music"

func change_graphics(var which_setting, var value_change):
	if which_setting == 3:
		if (!value_change) == current_values["graphics"]["fullscreen"]:
			return
		current_values["graphics"]["fullscreen"] = !value_change
		if !value_change:
			OS.set_borderless_window(true)
			OS.set_window_size(OS.get_screen_size())
			OS.set_window_position(Vector2(0, 0))
			get_child(which_setting).get_node("Value").bbcode_text = "< On"
		else:
			OS.set_borderless_window(false)
			OS.set_window_size(Vector2(1280,720))
			OS.set_window_position(Vector2(300,200))
			get_child(which_setting).get_node("Value").bbcode_text = "Off >"

func open():
	active = true
	anchor_left = 0
	anchor_right = 1
	change_setting(0)

func close(var save = true):
	anchor_left = 2
	anchor_right = 3
	active = false
	if save:
		save_setings()

func load_settings():
	var error = config_file.load(save_path)
	if error != OK:
		print("Failed loading settings file: " + String(error))
		return

	change_audio(0, config_file.get_value("audio", "volume_main", current_values["audio"]["volume_main"]), false)
	change_audio(1, config_file.get_value("audio", "volume_fx", current_values["audio"]["volume_fx"]), false)
	change_audio(2, config_file.get_value("audio", "volume_music", current_values["audio"]["volume_music"]), false)
	change_graphics(3, !config_file.get_value("graphics", "fullscreen", current_values["graphics"]["fullscreen"]))
	

func save_setings():
	for section in current_values.keys():
		for key in current_values[section]:
			config_file.set_value(section, key, current_values[section][key])
	
	config_file.save(save_path)

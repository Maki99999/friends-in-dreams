extends Node2D


var save_anim = null

const save_path = "user://save.game"
const excluded_scenes = ["MainMenu"]

func _ready():
	if SceneManager.connect("scene_change", self, "_on_scene_change") != OK:
		push_error("Can't connect to SceneManager!")
	ready_scene()

func ready_scene():
	save_anim = get_tree().get_nodes_in_group("save_anim")
	if save_anim.empty():
		save_anim = null
	else:
		save_anim = save_anim[0]

func _notification(what):
	if what == MainLoop.NOTIFICATION_WM_QUIT_REQUEST:
		save_game()
		get_tree().quit()

func _on_scene_change():
	ready_scene()

func save_game():
	var current_scene = get_tree().current_scene.filename
	for excluded_scene in excluded_scenes:
		if current_scene.count(excluded_scene) > 0:
			return

	var current_save = {"scene": current_scene}
	for component in get_save_components():
		var data = component.save() # returns [id, data]
		current_save[data[0]] = data[1]
	write_file(save_path, current_save)
	if save_anim != null:
		save_anim.play("disappear")

func load_game():
	var saved_data = read_file(save_path)
	
	SceneManager.change_scene(saved_data["scene"])
	
	yield(get_tree(), "idle_frame")
	for component in get_save_components():
		component.restore(saved_data)

func save_exists():
	return File.new().file_exists(save_path)

func get_save_components():
	return get_tree().get_nodes_in_group("Saving")

func read_file(var file_path):
	var data_file = File.new()
	if data_file.open(file_path, File.READ) != OK:
		push_error("Can't open save file!")
		return
	var data_text = data_file.get_as_text()
	data_file.close()
	var data_parse = JSON.parse(data_text)
	if data_parse.error != OK:
		push_error("Invalid save file!")
		return
	return data_parse.result

func write_file(var file_path, data):
	var data_file = File.new()
	if data_file.open(file_path, File.WRITE) != OK:
		push_error("Can't save save file!")
		return
	data_file.store_string(to_json(data))
	data_file.close()

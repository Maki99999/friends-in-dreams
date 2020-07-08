extends Node2D


const save_path = "user://save.game"

func _notification(what):
	if what == MainLoop.NOTIFICATION_WM_QUIT_REQUEST:
		save_game()
		get_tree().quit()

func save_game():
	var current_save = {"scene": get_tree().current_scene.filename}
	for component in get_save_components():
		var data = component.save() # returns [id, data]
		current_save[data[0]] = data[1]
	write_file(save_path, current_save)

func load_game():
	var saved_data = read_file(save_path)
	
	if get_tree().change_scene(saved_data["scene"]) != OK:
		push_error("Can't load game!")
	
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

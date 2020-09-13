extends StaticBody2D


export(NodePath) var ui_path

onready var anim = $AnimationPlayer
onready var ui = get_node(ui_path)
onready var timer = $Timer

var has_gold = false
var has_mold = false
var minigame_completed = false
var maze_nesw
var maze_names
var maze_actives
var maze_corrects
var selected_x = 0
var selected_y = 0
var in_minigame = false

const maze_width = 8
const maze_height = 5
const id = "01CaveMachine"
const maze_pregenerated = \
[["EWN", "WN", "EN", "WS", "WSN"], ["SE", "NSW", "NE", "SN", "WSN"], ["NS", "NSE", "WSE", "WN", "EN"], ["WS", "N", "EW", "SW", "SE"], ["WS", "SN", "NE", "NE", "NE"], ["SE", "EW", "WE", "WSE", "WE"], ["WSE", "WS", "EN", "EW", "SWE"], ["NS", "WNS", "NE", "EN", "NE"]]
#[["WE", "", "", "", ""], ["WS", "NS", "NE", "", ""], ["", "", "WS", "NE", ""], ["", "SE", "SN", "WN", ""], ["", "WE", "", "ES", "NE"], ["", "WS", "NS", "NW", "WE"], ["SE", "EN", "SE", "SN", "WN"], ["WE", "SW", "WN", "", ""]]

func _ready():
	anim.play("idle")
	ui.visible = false
	init_maze()

func _input(event):
	if !(event is InputEventKey) || !in_minigame:
		return
	if event.is_action_pressed("ui_debug"): #TODO DEBUG
		minigame_complete()
	if event.is_action_pressed("ui_left"):
		if selected_y == -10:
			selected_x = 0
		else:
			selected_x = posmod(selected_x - 1, maze_nesw.size())
	elif event.is_action_pressed("ui_right"):
		if selected_y == -10:
			selected_x = 0
		else:
			selected_x = posmod(selected_x + 1, maze_nesw.size())
	elif event.is_action_pressed("ui_up"):
		selected_y = posmod(selected_y - 1, maze_nesw[0].size())
	elif event.is_action_pressed("ui_down"):
		if selected_y == maze_nesw[0].size() - 1:
			selected_x = 0
			selected_y = -10
			ui.select_button()
		elif selected_y == -10:
			selected_y = 0
		else:
			selected_y = posmod(selected_y + 1, maze_nesw[0].size())
	elif event.is_action_pressed("ui_accept"):
		if selected_y == -10:
			hide_minigame()
		else:
			rotate_selected()
	if selected_y != -10:
		ui.select(selected_x, selected_y)

func use():
	if minigame_completed:
		return
	show_minigame()

func rotate_selected():
	maze_names[selected_x][selected_y] = maze_names[selected_x][selected_y].left(2) + \
			str((int(maze_names[selected_x][selected_y].right(1)) + 1) % 4)
	
	var new_nesw = ""
	for dir in Utils.string_to_array(maze_nesw[selected_x][selected_y]):
		new_nesw += clockwise_dir(dir)
	maze_nesw[selected_x][selected_y] = new_nesw
	
	ui.rotate(selected_x, selected_y)

	update_actives()
	ui.activate_maze(maze_actives)
	update_corrects()
	ui.correct_maze(maze_corrects, maze_actives)
	
	var has_won = true
	for x in maze_corrects.size():
		for y in maze_corrects[0].size():
			if maze_corrects[x][y] != 1 || maze_actives[x][y] != 1:
				has_won = false
	
	if has_won:
		minigame_complete()

func minigame_complete():
	minigame_completed = true
	in_minigame = false
	anim.play("LEDs")
	
	$MachineStart.play()
	timer.start(1.8)
	yield(timer, "timeout")
	$MachineLoop.play()
	timer.start(0.5)
	yield(timer, "timeout")
	hide_minigame()

func show_minigame():
	Utils.player.freeze()
	ui.visible = true
	in_minigame = true
	selected_x = 0
	selected_y = 0
	ui.select(selected_x, selected_y)

func hide_minigame():
	Utils.player.add_use_cooldown()
	Utils.player.unfreeze()
	ui.visible = false
	in_minigame = false

func init_maze(var gen_maze = true):
	if gen_maze:
		maze_nesw = maze_pregenerated
		#random_maze_fill(maze_nesw)
		#shuffle_maze(maze_nesw)
		#maze_gen()
		#enhance_maze()
		#print(maze_nesw)

	gen_maze_names()
	
	yield(get_tree(), "idle_frame")
	ui.init_tiles(maze_names)
	
	update_actives()
	ui.activate_maze(maze_actives)
	update_corrects()
	ui.correct_maze(maze_corrects, maze_actives)

func update_actives():
	maze_actives = Utils.new_2d_array(maze_nesw.size(), maze_nesw[0].size(), 0)
	var c = [[maze_nesw.size() - 1, 0]]
	if maze_nesw[c[0][0]][c[0][1]].count("E") == 0:
		c = []
	
	while c.size() > 0:
		var curr = c.pop_front()
		maze_actives[curr[0]][curr[1]] = 1
		
		for dir in Utils.string_to_array(maze_nesw[curr[0]][curr[1]]):
			var nx = curr[0]
			var ny = curr[1]
			match dir:
				"N":
					ny -= 1
				"E":
					nx += 1
				"S":
					ny += 1
				"W":
					nx -= 1
			if nx >= 0 && ny >= 0 && nx < maze_nesw.size() && ny < maze_nesw[0].size() && maze_actives[nx][ny] == 0:
				if maze_nesw[nx][ny].count(opposite_dir(dir)) != 0:
					c.push_back([nx, ny])

func update_corrects():
	maze_corrects = Utils.new_2d_array(maze_nesw.size(), maze_nesw[0].size(), 0)
	
	for x in maze_nesw.size():
		for y in maze_nesw[0].size():
			var correct = true
			for dir in Utils.string_to_array(maze_nesw[x][y]):
				var nx = x
				var ny = y
				match dir:
					"N":
						ny -= 1
					"E":
						nx += 1
					"S":
						ny += 1
					"W":
						nx -= 1
				if nx >= 0 && ny >= 0 && nx < maze_nesw.size() && ny < maze_nesw[0].size() && \
						maze_nesw[nx][ny].count(opposite_dir(dir)) == 0:
					correct = false
					break
			if correct:
				maze_corrects[x][y] = 1
			else:
				maze_corrects[x][y] = 0

func opposite_dir(var dir):
	match dir:
		"N":
			return("S")
		"E":
			return("W")
		"S":
			return("N")
		"W":
			return("E")

func clockwise_dir(var dir):
	match dir:
		"N":
			return("E")
		"E":
			return("S")
		"S":
			return("W")
		"W":
			return("N")

func gen_maze_names():
	var m = maze_nesw
	
	maze_names = []
	maze_names.resize(m.size())
	
	for x in m.size():
		maze_names[x] = []
		maze_names[x].resize(m[x].size())
		for y in m[0].size():
			maze_names[x][y] = nesw_to_name(m[x][y])

func nesw_to_name(var cell_string):
	var cell = Utils.string_to_array(cell_string)
	match cell.size():
		0:
			return "0a0"
		1:
			if cell.has("N"):
				return "1a0"
			elif cell.has("E"):
				return "1a1"
			elif cell.has("S"):
				return "1a2"
			elif cell.has("W"):
				return "1a3"
		2:
			if cell.has("N") && cell.has("S"):
				return "2b0"
			elif cell.has("E") && cell.has("W"):
				return "2b1"
			elif cell.has("N"):
				if cell.has("E"):
					return "2a0"
				elif cell.has("W"):
					return "2a3"
			elif cell.has("S"):
				if cell.has("E"):
					return "2a1"
				elif cell.has("W"):
					return "2a2"
		3:
			if !cell.has("N"):
				return "3a1"
			elif !cell.has("E"):
				return "3a2"
			elif !cell.has("S"):
				return "3a3"
			elif !cell.has("W"):
				return "3a0"
		4:
			return "4a0"
	return "error"

func enhance_maze():
	var m = maze_nesw
	# start + end
	if m[0][0].count("W") == 0:
		m[0][0] += "W"
	if m[-1][0].count("E") == 0:
		m[-1][0] += "E"
	# border
	randomize()
	for x in m.size():
		if randf() < 0.25:
			m[x][0] += "N"
		if randf() < 0.25:
			m[x][-1] += "S"
	for y in m[0].size() - 1:
		if randf() < 0.25:
			m[0][y + 1] += "W"
		if randf() < 0.25:
			m[-1][y + 1] += "E"
	# delete singles
	for x in m.size():
		for y in m[0].size():
			if m[x][y].length() == 1:
				m[x][y] += Utils.shuffle_array(Utils.complement(["N", "E", "S", "W"], \
						Utils.string_to_array(m[x][y])))[0]
	return m

func maze_gen():
	var width = maze_width
	var height = maze_height
	var matrix = Utils.new_2d_array(width, height, 0)
	var matrix_dir = Utils.new_2d_array(width, height, "")
	
	randomize()
	var c = [[randi() % width, randi() % height]]
	
	while !c.empty():
		var new_cell
		if randi() % 2 == 1:
			new_cell = c[randi() % c.size()]
		else:
			new_cell = c[c.size() - 1]
		
		var no_neighbors = true
		var rand_dirs = ["N", "E", "S", "W"]
		rand_dirs.shuffle()
		for dir in rand_dirs:
			var nx = new_cell[0]
			var x = new_cell[0]
			var ny = new_cell[1]
			var y = new_cell[1]
			match dir:
				"N":
					ny -= 1
				"E":
					nx += 1
				"S":
					ny += 1
				"W":
					nx -= 1
			
			if nx >= 0 && ny >= 0 && nx < width && ny < height && matrix[nx][ny] == 0 && matrix_dir[x][y].count(dir) == 0:
				no_neighbors = false
				matrix[nx][ny] = 1
				matrix_dir[x][y] += dir
				matrix_dir[nx][ny] += opposite_dir(dir)
				c.append([nx, ny])
		
		if no_neighbors:
			c.remove(c.find(new_cell))
	
	maze_nesw = matrix_dir

func random_maze_fill(var m):
	randomize()
	for x in m.size():
		for y in m[0].size():
			while m[x][y].length() < 2:
				var rand_dirs = Utils.complement(["N", "E", "S", "W"], Utils.string_to_array(m[x][y]))
				rand_dirs.shuffle()
				if rand_dirs.size() > 0:
					m[x][y] += rand_dirs[0]
			if randf() < 0.2:
				var rand_dirs = Utils.complement(["N", "E", "S", "W"], Utils.string_to_array(m[x][y]))
				rand_dirs.shuffle()
				if rand_dirs.size() > 0:
					m[x][y] += rand_dirs[0]
			if randf() < 0.1:
				var rand_dirs = Utils.complement(["N", "E", "S", "W"], Utils.string_to_array(m[x][y]))
				rand_dirs.shuffle()
				if rand_dirs.size() > 0:
					m[x][y] += rand_dirs[0]

func shuffle_maze(var m):
	randomize()
	for x in m.size():
		for y in m[0].size():
			var rotations = randi() % 4
			for i in rotations:
				var new_nesw = ""
				for nesw in Utils.string_to_array(m[x][y]):
					new_nesw += clockwise_dir(nesw)
				m[x][y] = new_nesw

func save():
	var saved_data = {	"has_gold": has_gold,
						"has_mold": has_mold,
						"minigame_completed": minigame_completed,
						"maze_nesw": maze_nesw}
	return([id, saved_data])

func restore(var saved_data):
	var data = saved_data[id]
	
	has_gold = data["has_gold"]
	has_mold = data["has_mold"]
	minigame_completed = data["minigame_completed"]
	maze_nesw = data["maze_nesw"]
	
	init_maze(false)
	
	if has_gold:#&& noch nicht eingepourt
		anim.play("Gold")
		yield(anim, "animation_finished")
	if has_mold:
		anim.play("Mold")
		yield(anim, "animation_finished")
	if minigame_completed:
		anim.play("LEDs")
		$MachineLoop.play()
		yield(anim, "animation_finished")

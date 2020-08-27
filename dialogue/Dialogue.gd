extends Control


class_name DialogueManager


export(NodePath) var player_path
export(float) var time_btwn_letters
export(float) var time_btwn_letters_fast
export(float) var time_btwn_letters_long_mult
export(float) var cooldown
export(float) var cooldown_before_answers
export(int) var letters_btwn_sound
export(int) var letters_btwn_sound_fast
export(AudioStream) var voice_normal
export(AudioStream) var voice_robot
export(AudioStream) var voice_wood

onready var animator = $DialogueBox/AnimationPlayer
onready var text_label = $DialogueBox/MarginContainer/HSplitContainer/Text
onready var face_image = $DialogueBox/MarginContainer/HSplitContainer/Face
onready var small_arrow_anim = $SmallArrow/AnimationPlayer
onready var answers = $Answers
onready var timer = $DialogueBox/Timer
onready var audio01 = $Voice01
onready var audio02 = $Voice02
onready var skip_progress = $Skip/TextureProgress
onready var skip_anim = $Skip/AnimationPlayer
onready var voice_dictionary = {"normal": voice_normal, "robot": voice_robot, "wood": voice_wood}
onready var rng = RandomNumberGenerator.new()
onready var player = get_tree().get_nodes_in_group("Player")[0]
var is_in_dialogue
var initiator
var unfreeze_at_end
var people_in_conversation	# Paths to the directory of the faces of the people, one path per person
var dialogue_file_content
var bb_regex
var is_choosing_answer = false
var current_answer = 0
var answer_count = 1
var time_btwn_letters_current
var letters_btwn_sound_current
var accept_pressed_during_wait = false
var can_skip = false
var is_skipping = false
var is_holding_skip = false
var skip_start_time = 0.0
var dynamic_words_translated = {}
var dynamic_words = {}

const skip_time = 3500.0

signal pressed_accept

func _process(_delta):
	if is_in_dialogue && can_skip:
		if Input.is_action_just_released("ui_cancel"):
			is_holding_skip = false
			update_skip(true)
		elif Input.is_action_pressed("ui_cancel"):
			if is_holding_skip:
				if OS.get_ticks_msec() > skip_start_time + skip_time:
					is_skipping = true
			else:
				is_holding_skip = true
				skip_start_time = OS.get_ticks_msec()
			update_skip()

func _ready():
	visible = true
	reset()
	animator.play("idle")
	skip_anim.play("idle")
	
	bb_regex = RegEx.new()
	bb_regex.compile("\\[[^\\]]*\\]")

func _input(event):
	if !(event is InputEventKey) || !is_in_dialogue:
		return
	if event.is_action_pressed("ui_accept"):
		emit_signal("pressed_accept")
		accept_pressed_during_wait = true
	if is_choosing_answer:
		if event.is_action_pressed("ui_down"):
			current_answer = posmod(current_answer + 1, answer_count)
			answers.highlight(current_answer)
		if event.is_action_pressed("ui_up"):
			current_answer = posmod(current_answer - 1, answer_count)
			answers.highlight(current_answer)

func update_skip(var stop = false):
	if stop:
		skip_anim.play_backwards("fade_in")
		return
		
	var new_val = (OS.get_ticks_msec() - skip_start_time) /  skip_time
	skip_progress.value = new_val * 100
	if new_val < 0.01:
		skip_anim.play("fade_in")
	elif new_val > 0.99:
		skip_anim.play_backwards("fade_in")

func reset():
	text_label.bbcode_text = ""
	text_label.visible_characters = 0
	face_image.texture = null
	unfreeze_at_end = true
	small_arrow_anim.play("idle")
	answers.reset()
	can_skip = false
	is_skipping = false
	is_holding_skip = false
	skip_start_time = 0.0
	dynamic_words = {}

func process_node(var node_name):
	var node = dialogue_file_content[node_name]
	match node["type"]:
		"normal", "branching":
			audio01.stream = voice_dictionary[node["sound"]]
			audio02.stream = voice_dictionary[node["sound"]]
			
			if node.has("face"):
				face_image.texture = load(people_in_conversation[node["char_name"]] + node["face"])
			else:
				face_image.texture = null
			
			yield(type_sentences(node), "completed")
			
		"execute":
			if initiator != null:
				if node.has("parameters"):
					for word in dynamic_words.keys(): # replace #A with dynamic_words["A"]
						for i in range(node["parameters"].size()):
							node["parameters"][i] = node["parameters"][i].replace(word, dynamic_words[word])
					initiator.callv(node["function"], node["parameters"])
				else:
					initiator.call(node["function"])
		"end":
			pass
		_:
			push_error("Unsupported dialogue node type: " + node["type"] + ".")
			yield(end_dialogue(), "completed")

	var next_node = null
	
	if node["type"] == "branching":
		is_choosing_answer = true
		current_answer = 0
		answer_count = node["answers"].size()
		
		for word in dynamic_words.keys(): # replace #A with dynamic_words["A"]
			for i in range(node["answers"].size()):
				node["answers"][i] = node["answers"][i].replace(word, dynamic_words_translated[word])
		answers.init(node["answers"])
		
		timer.start(cooldown_before_answers)
		yield(timer, "timeout")
		
		yield(self, "pressed_accept")
		is_choosing_answer = false
		answers.choosen()
		next_node = node["next"][current_answer]
	elif node.has("next"):
		if node["next"] is String:
			next_node = node["next"]
		elif node["next"] is Array:
			next_node = node["next"][0]
		else:
			next_node = null

	if next_node != null:
		yield(process_node(next_node), "completed")
	else:
		yield(end_dialogue(), "completed")

func type_sentences(var node):
	var sentences
	if node["text"] is String:
		sentences = [node["text"]]
	else:
		sentences = node["text"]
	
	for sentence in sentences:
		time_btwn_letters_current = time_btwn_letters
		letters_btwn_sound_current = letters_btwn_sound
		
		for word in dynamic_words.keys(): # replace #A with dynamic_words["A"]
			sentence = sentence.replace(word, dynamic_words_translated[word])
		
		var new_bbcode_text = sentence.replace("|", "")
		if node.has("subtype"):
			if node["subtype"] == "thinking":
				new_bbcode_text = "[color=#CCCCCCCC]" + new_bbcode_text + "[/color]"
		text_label.bbcode_text = new_bbcode_text
		var text_without_extras = bb_regex.sub(sentence, "", true)
		var pauses = []
		for c in text_without_extras.length():
			if text_without_extras[c] == "|":
				pauses.append(c - pauses.size())
		text_without_extras = text_without_extras.replace("|", "")

		var sound_letter = -1

		for i in range(text_without_extras.length() + 1):
			if i > 1 && accept_pressed_during_wait:
				time_btwn_letters_current = time_btwn_letters_fast
				letters_btwn_sound_current = letters_btwn_sound_fast
			if is_skipping:
				break
		
			sound_letter = (sound_letter + 1) % letters_btwn_sound_current
			if sound_letter == 0:
				var audio = audio01
				if audio01.playing:
					audio = audio02

				var pitch = node["sound_pitch"] + rng.randf_range(-node["sound_pitch_randomness"], node["sound_pitch_randomness"])
				audio.pitch_scale = pitch
				audio.play()
		
			text_label.visible_characters = i
			if i in pauses:
				timer.start(time_btwn_letters_current * time_btwn_letters_long_mult)
			else:
				timer.start(time_btwn_letters_current)
			accept_pressed_during_wait = false
			yield(timer, "timeout")
		
		text_label.visible_characters = text_without_extras.length() + 1
		yield(get_tree(), "idle_frame")
		
		if !is_skipping:
			small_arrow_anim.play("blink")
			yield(self, "pressed_accept")
			small_arrow_anim.play("idle")

func start_dialogue(var dialogue_file_path, var people_in_this_conversation, \
		var will_unfreeze_at_end = true, start_initiator = null, \
		dynamic_wordlist = {}, dynamic_translations_path = null):
	
	if is_in_dialogue:
		return
	is_in_dialogue = true
	player.freeze()
	for node in get_tree().get_nodes_in_group("cutscene_freeze"):
		node.freeze()
		
	reset()
	can_skip = true
	animator.play("open_dialogue")
	
	people_in_conversation = people_in_this_conversation
	unfreeze_at_end = will_unfreeze_at_end
	initiator = start_initiator
	
	read_dynamic_file(dynamic_wordlist, dynamic_translations_path)
	read_file(dialogue_file_path)
	
	yield(animator, "animation_finished")
	yield(process_node("Start"), "completed")
	yield(get_tree(), "idle_frame")

func end_dialogue():
	animator.play_backwards("open_dialogue")
	update_skip(true)
	can_skip = false
	if unfreeze_at_end:
		for node in get_tree().get_nodes_in_group("cutscene_freeze"):
			node.unfreeze()
		player.unfreeze()
		timer.start(cooldown)
		yield(timer, "timeout")
	else:
		yield(animator, "animation_finished")
	is_in_dialogue = false

func read_file(var dialogue_file_path):
	var data_file = File.new()
	if data_file.open(dialogue_file_path, File.READ) != OK:
		push_error("Can't find dialogue file!")
		return
	var data_text = data_file.get_as_text()
	data_file.close()
	
	var data_parse = JSON.parse(data_text)
	if data_parse.error != OK:
		push_error("Invalid dialogue file!")
		return
	dialogue_file_content = data_parse.result
	
func read_dynamic_file(var dynamic_wordlist, var dynamic_file_path):
	if dynamic_wordlist.empty() || dynamic_file_path == null:
		return
		
	var data_file = File.new()
	if data_file.open(dynamic_file_path, File.READ) != OK:
		push_error("Can't find dynamic word list file!")
		return
	var data_text = data_file.get_as_text()
	data_file.close()
	
	var data_parse = JSON.parse(data_text)
	if data_parse.error != OK:
		push_error("Invalid dynamic word list!")
		return
	
	for word in dynamic_wordlist.keys():
		dynamic_words_translated[word] = data_parse.result[dynamic_wordlist[word]]["translation"]
	
	dynamic_words = dynamic_wordlist

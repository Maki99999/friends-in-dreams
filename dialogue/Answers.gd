extends MarginContainer


export(Texture) var normal_texture
export(Texture) var highlight_texture

onready var animator = $AnimationPlayer
onready var answers = [$VBoxContainer/Answer]
onready var answers_container = $VBoxContainer

var active_count = 1

const answer_scene = preload("res://dialogue/Answer.tscn")

func reset():
	animator.play("idle")
	for answer in answers:
		answer.get_node("Background").texture = normal_texture

func init(var answers_string):
	active_count = answers_string.size()
	while answers.size() < active_count:
		var new_answer_scene = answer_scene.instance()
		answers_container.add_child(new_answer_scene)
		answers.append(new_answer_scene)

	for answer in answers:
		answer.visible = false

	for i in range(active_count):
		answers[i].visible = true
		answers[i].get_node("Background/MarginContainer/RichTextLabel").bbcode_text = answers_string[i]

	animator.play("open_answers")
	highlight(0)

func highlight(var node_i):
	for i in range(active_count):
		if i != node_i:
			answers[i].get_node("Background").texture = normal_texture
		else:
			answers[i].get_node("Background").texture = highlight_texture

func choosen():
	animator.play_backwards("open_answers")

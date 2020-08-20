extends StaticBody2D


onready var rand = RandomNumberGenerator.new()
onready var tween = $Tween
onready var sprite = $Sprite
onready var anim = $Sprite/AnimationPlayer
onready var dialogue = get_tree().get_nodes_in_group("dialogue")[0]

var random_flicker = true
var next_flicker = 0

func _ready():
	anim.play("down")

func _process(_delta):
	if random_flicker:
		random_flicker = false
		tween.interpolate_property(sprite, "modulate", \
			Color(1, 1, 1, 1), Color(1, 1, 1, 0.7), rand.randf_range(10.0,20.0), \
			Tween.TRANS_LINEAR, Tween.EASE_IN)
		tween.start()
		yield(tween, "tween_completed")
		tween.interpolate_property(sprite, "modulate", \
			Color(1, 1, 1, 0.7), Color(1, 1, 1, 1), rand.randf_range(10.0,20.0), \
			Tween.TRANS_LINEAR, Tween.EASE_IN)
		tween.start()
		yield(tween, "tween_completed")
		random_flicker = true

func use():
	#bis jetzt nur debug
	get_tree().get_nodes_in_group("dialogue")[0].start_dialogue(\
	"res://characters/side_characters/test_npc/testnpc_dialogue02.json",\
	{"Test NPC": "res://characters/side_characters/test_npc/"})
	
	

extends StaticBody2D


var random_flicker = true
var next_flicker = 0
onready var rand = RandomNumberGenerator.new()
onready var tween = $Tween
onready var sprite = $Sprite
onready var anim = $Sprite/AnimationPlayer

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

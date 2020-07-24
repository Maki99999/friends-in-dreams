extends StaticBody2D


onready var anim = $Sprite/AnimationPlayer
onready var anim_steam = $SpriteSteam/AnimationPlayer
onready var anim_emote = $SpriteEmote/AnimationPlayer
onready var walk_fx = $walk_fx
onready var sprite = $Sprite
onready var tween = $Tween

var current_volume = -80
var desired_volume = -80

func _ready():	
	anim_steam.play("steam_normal")
	anim.play("busy 01")
	
	walk_fx.volume_db = -INF
	walk_fx.play()

func _process(delta):
	if current_volume == -INF:
		current_volume = -80

	if current_volume > desired_volume:
		current_volume -= 600.0 * delta
	if current_volume < desired_volume:
		current_volume += 600.0 * delta
	
	if current_volume <= -80:
		current_volume = -INF
	
	walk_fx.volume_db = current_volume

func move_to(var new_position, var end_dir = null, var speed = 3.0, var pref_updown = false):
	desired_volume = 0
	yield(Utils.move_to(self, new_position, anim, \
		{"left": "go_left", "right": "go_right", \
		"up": "go_up", "down": "go_down"}, speed, pref_updown), "completed")
	if end_dir != null:
		desired_volume = -80
		anim.play(end_dir)

func emote(var name):
	anim_emote.play(name)
	yield(anim_emote, "animation_finished")

func animation(var name):
	anim.play(name)

func sound_fade(var fade_in):
	if tween.is_active():
		tween.stop_all()
	
	if fade_in:
		walk_fx.volume_db = -80
		tween.interpolate_property(walk_fx, "volume_db", null, 0, 0.05, Tween.TRANS_EXPO, 2)
		tween.start()
		walk_fx.play()
		yield(tween, "tween_completed")
	else:
		tween.interpolate_property(walk_fx, "volume_db", null, -80, 0.01, Tween.TRANS_EXPO, 2)
		tween.start()
		yield(tween, "tween_completed")
		#walk_fx.stop()

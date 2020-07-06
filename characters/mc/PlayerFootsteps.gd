extends Node2D


export(Array, AudioStream) var fx_solid
export(Array, AudioStream) var fx_grass

onready var audio1 = $Audio1
onready var audio2 = $Audio2

var solid = ["stone", "solid", "hard"]
var grass = ["grass"]

var possible_sounds = {"solid": solid, "grass": grass}
onready var fx_sounds = {"solid": fx_solid, "grass": fx_grass}

var rng = RandomNumberGenerator.new()
var audio_one = false

func _ready():
	rng.randomize()

func play(var tile_name):
	if tile_name == "void":
		return
	for sound in possible_sounds.keys():
		for surface in possible_sounds[sound]:
			if surface.to_lower() in tile_name.to_lower() || tile_name.to_lower() in surface.to_lower():
				play_sound(sound)
				return
	play_sound("solid")

func play_sound(var sound_name):
	var random_num = rng.randi_range(0, fx_sounds[sound_name].size() - 1)
	
	audio_one = !audio_one
	if audio_one:
		audio1.stream = fx_sounds[sound_name][random_num]
		audio1.play()
	else:
		audio2.stream = fx_sounds[sound_name][random_num]
		audio2.play()

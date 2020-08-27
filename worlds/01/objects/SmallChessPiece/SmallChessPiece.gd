extends StaticBody2D


export(String, "empty", "queen", "bishop", "rook", "knight") var current_statue = "empty"
export(String, "empty", "queen", "bishop", "rook", "knight") var correct_statue = "empty"

onready var player = get_tree().get_nodes_in_group("Player")[0]
onready var dialogue = get_tree().get_nodes_in_group("dialogue")[0]
onready var sprite = $Sprite
onready var wall_gate = $"../WallGate"
onready var sound = $putSound

var locked = false

const dialogue_path = "res://worlds/01/objects/SmallChessPiece/dialogue/"
const empty_suffix = "InInv.json"
const not_empty_suffix = "Take.json"
const dynamic_words_suffix = "ChessPiecesNames.json"
const dynamic_words_articles_suffix = "ChessPiecesNamesArticles.json"
const sprite_frames = ["empty", "queen", "bishop", "rook", "knight"]

var id = "01" + get_name()

func _ready():
	id = "01" + get_name()
	sprite.frame = sprite_frames.find(current_statue)

func use():
	if locked:
		return
	
	if current_statue == "empty":
		var intersection = Utils.intersection(["queen", "bishop", "rook", "knight"], player.inventory)
		
		var dynamic_words = {}
		for i in range(intersection.size()):
			dynamic_words["#" + str(i + 1)] = intersection[i]
		dialogue.start_dialogue(dialogue_path + str(intersection.size()) + empty_suffix, null, true, self, \
		dynamic_words, dialogue_path + dynamic_words_suffix)
	else:
		dialogue.start_dialogue(dialogue_path + not_empty_suffix, null, true, self, \
		{"#1": current_statue}, dialogue_path + dynamic_words_articles_suffix)

func place(var figure):
	player.inventory.erase(figure)
	current_statue = figure
	sprite.frame = sprite_frames.find(figure)
	sound.play()
	
	if current_statue == correct_statue:
		wall_gate.check()
	
func take():
	player.inventory.append(current_statue)
	current_statue = "empty"
	sprite.frame = sprite_frames.find("empty")
	sound.play()
	
func save():
	var saved_data = {"locked": locked,
						"current_statue": current_statue}
	return([id, saved_data])

func restore(var saved_data):
	var data = saved_data[id]
	
	locked = data["locked"]
	current_statue = data["current_statue"]
	sprite.frame = sprite_frames.find(current_statue)

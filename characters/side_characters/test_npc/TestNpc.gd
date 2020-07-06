extends StaticBody2D


func use():
	get_tree().get_nodes_in_group("dialogue")[0].start_dialogue(\
	"res://characters/side_characters/test_npc/testnpc_dialogue01.json",\
	{"Test NPC": "res://characters/side_characters/test_npc/"}, true, self)
	
func freeze():
	set_process(false)

func unfreeze():
	set_process(true)

func test_dialogue_function():
	print("Eine Funktion im TextNpc!")

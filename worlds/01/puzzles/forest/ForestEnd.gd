extends StaticBody2D


var has_been_used = false
const id = "01forestEnd01"

func use():
	if !has_been_used:
		has_been_used = true
		yield(Utils.dialogue.start_dialogue(\
				"res://worlds/01/puzzles/forest/end_pickup.json",\
				{"Rembry": "res://characters/mc/faces/"}, true), "completed")
		Utils.player.inventory.append("gold")

func save():
	var saved_data = {"has_been_used": has_been_used}
	return([id, saved_data])

func restore(var saved_data):
	var data = saved_data[id]
	
	has_been_used = data["has_been_used"]

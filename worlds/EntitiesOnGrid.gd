extends Node2D


var tile_size = 16

func _ready():
	for child in get_children():
		child.position = (child.position - Vector2.ONE * (tile_size / 2)).snapped(Vector2.ONE * tile_size) + Vector2.ONE * (tile_size / 2)

func snap_to_grid(var node):
	node.position = (node.position - Vector2.ONE * (tile_size / 2)).snapped(Vector2.ONE * tile_size) + Vector2.ONE * (tile_size / 2)

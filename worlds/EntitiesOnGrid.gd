extends Node2D


export(Vector2) var offset = Vector2(0, 0)

var tile_size = 16

func _ready():
	for child in get_children():
		child.global_position = offset + (child.global_position - Vector2.ONE * (tile_size / 2)).snapped(Vector2.ONE * tile_size) + Vector2.ONE * (tile_size / 2)

func snap_to_grid(var node):
	node.global_position = offset + (node.global_position - Vector2.ONE * (tile_size / 2)).snapped(Vector2.ONE * tile_size) + Vector2.ONE * (tile_size / 2)

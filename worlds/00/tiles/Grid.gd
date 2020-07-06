extends TileMap


func _ready():
	for child in get_children():
		set_cellv(world_to_map(child.position), child.type)

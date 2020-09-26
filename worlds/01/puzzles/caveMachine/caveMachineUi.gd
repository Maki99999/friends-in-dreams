extends Control


export(Array, Texture) var tiles_not_active #0a, 1a, 2a, 2b, 3a, 4a
export(Array, Texture) var tiles_active
export(Texture) var tile_not_correct
export(Texture) var tile_correct
export(Texture) var texture_normal
export(Texture) var texture_selected
export(ShaderMaterial) var shader_selected

onready var tiles_node = $Tiles
onready var selected_tile = $Selected
onready var back_button = $BackButton

var maze = null
var tiles = null

const tile_size = Vector2(32, 32)
const tile_start = Vector2(33, 1)

func init_tiles(var m):
	if tiles != null:
		delete_tiles()
	
	maze = m
	var draw = tile_start
	tiles = []
	tiles.resize(m.size())
	for x in m.size():
		draw.y = tile_start.y
		tiles[x] = []
		tiles[x].resize(m[x].size())
		for y in m[0].size():
			tiles[x][y] = init_tile(draw, m[x][y])
			draw.y += tile_size.y
		draw.x += tile_size.x
	select(0, 0)

func init_tile(var pos, var tile_str):
	var node = TextureRect.new()
	
	node.margin_left = 0
	node.margin_top = 0
	node.margin_right = 0
	node.margin_bottom = 0
	
	node.rect_pivot_offset = tile_size / 2
	node.rect_rotation = 90 * int(tile_str.right(1))
	
	node.texture = tiles_not_active[get_texture_index(tile_str)]
	
	var node_overlay = TextureRect.new()
	
	node_overlay.margin_left = pos.x
	node_overlay.margin_top = pos.y
	node_overlay.margin_right = tile_size.x
	node_overlay.margin_bottom = tile_size.x
	
	node.texture = tile_not_correct
	
	tiles_node.add_child(node_overlay)
	node_overlay.add_child(node)
	
	return node

func delete_tiles():
	for tiles_x in tiles:
		for tile in tiles_x:
			tile.queue_free()

func select_button():
	selected_tile.visible = false
	back_button.material = shader_selected
	back_button.texture = texture_selected
	back_button.get_child(0).material = shader_selected

func unselect_button():
	selected_tile.visible = true
	back_button.material = null
	back_button.texture = texture_normal
	back_button.get_child(0).material = null

func select(var x, var y):
	unselect_button()
	selected_tile.margin_left = tile_start.x + (x * tile_size.x) - 1
	selected_tile.margin_top = tile_start.y + (y * tile_size.y) - 1
	selected_tile.margin_right = selected_tile.margin_left + tile_size.x + 1
	selected_tile.margin_bottom = selected_tile.margin_top + tile_size.y + 1

func rotate(var x, var y):
	tiles[x][y].rect_rotation += 90

func activate_maze(var m):
	for x in tiles.size():
		for y in tiles[0].size():
			if m[x][y]:
				tiles[x][y].texture = tiles_active[get_texture_index(maze[x][y])]
			else:
				tiles[x][y].texture = tiles_not_active[get_texture_index(maze[x][y])]

func correct_maze(var m, var m_actives):
	for x in tiles.size():
		for y in tiles[0].size():
			if m[x][y] && m_actives[x][y]:
				tiles[x][y].get_parent().texture = tile_correct
			else:
				tiles[x][y].get_parent().texture = tile_not_correct

func get_texture_index(var name):
	match name.left(2):
		"0a", "1a", "2a":
			return int(name.left(1))
		"2b", "3a", "4a":
			return int(name.left(1)) + 1

func draw_maze(var m):
	var draw = Vector2(50, 50)
	for x in m.size():
		draw.y = 50
		for y in m[0].size():
			if m[x][y].count("N") > 0:
				draw_line(draw, draw + Vector2(0, -4), Color.aqua)
			if m[x][y].count("E") > 0:
				draw_line(draw, draw + Vector2(4, 0), Color.aqua)
			if m[x][y].count("S") > 0:
				draw_line(draw, draw + Vector2(0, 4), Color.aqua)
			if m[x][y].count("W") > 0:
				draw_line(draw, draw + Vector2(-4, 0), Color.aqua)
			draw += Vector2(0, 10)
		draw += Vector2(10, 0)

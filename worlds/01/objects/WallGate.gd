extends StaticBody2D


onready var pieces = [$"../SmallChessPiece0", $"../SmallChessPiece1", \
		$"../SmallChessPiece2", $"../SmallChessPiece3"]
onready var coll = $CollisionShape2D
onready var sprite = $Sprite
onready var timer = $Timer
onready var sound = $openSound
onready var player = get_tree().get_nodes_in_group("Player")[0]

var opened = false

const id = "01BigWallGate"

func check():
	var check = true
	for piece in pieces:
		if piece.current_statue != piece.correct_statue:
			check = false
			break
	
	if check:
		for piece in pieces:
			piece.locked = true
		open()

func open():
	player.freeze()
	yield(player.move_cam_to(global_position, 1.0), "completed")
	
	timer.start(0.8)
	yield(timer, "timeout")
	
	opened = true
	coll.shape = null
	sprite.visible = false
	SaveLoad.save_game()
	sound.play()
	
	timer.start(0.6)
	yield(timer, "timeout")
	
	$"../Robot".walk_to_tree01()
	
	yield(player.reset_cam(1.0), "completed")
	player.unfreeze()
	
func save():
	var saved_data = {"opened": opened}
	return([id, saved_data])

func restore(var saved_data):
	var data = saved_data[id]
	
	opened = data["opened"]
	
	if opened:
		opened = true
		coll.shape = null
		sprite.visible = false

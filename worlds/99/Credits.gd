extends Control


func _ready():
	$AnimationPlayer.play("t")
	$Timer.start(20)
	yield($Timer, "timeout")
	SceneManager.change_scene("res://menus/mainMenu.tscn")

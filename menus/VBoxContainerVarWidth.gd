tool
extends VBoxContainer


class_name VBoxContainerVarWidth


export(bool) var centered = false


func _notification(_what):
	if centered:
		for node in get_children():
			if !(node is Control):
				continue
			node.set_size(Vector2(node.get_custom_minimum_size().x, node.get_custom_minimum_size().y))
			node.margin_left = node.get_custom_minimum_size().x / 2
			node.margin_right = node.get_custom_minimum_size().x
	else:
		for node in get_children():
			if !(node is Control):
				continue
			node.set_size(Vector2(node.get_custom_minimum_size().x, node.get_custom_minimum_size().y))

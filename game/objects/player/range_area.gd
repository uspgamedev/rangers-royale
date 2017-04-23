extends Area2D

signal removed_from_tree()

func _ready():
	pass

func set_radius(r):
	get_child(0).get_shape().set_radius(r)

func _exit_tree():
	emit_signal("removed_from_tree")
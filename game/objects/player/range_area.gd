extends Area2D

func _ready():
	pass

func set_radius(r):
	get_child(0).get_shape().set_radius(r)
	print("area radius: " + var2str(get_child(0).get_shape().get_radius()))

extends "res://objects/body.gd"

var color = Color(1,1,1,1)

func _ready():
	var material = load("res://objects/player/player.tres").duplicate(true)
	material.set_shader_param("col", color)
	sprite.set_material(material)
	print(color)

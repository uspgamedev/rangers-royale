extends Node

const TYPE = preload("res://definitions/item_enums.gd")

var type #Type of item
var name #Name of item
var power = 14 #Damage weapon deals when attacking
var range_radius = 15 #Radius of weapon range

func _ready():
	type = TYPE.WEAPON
	name = "axe"
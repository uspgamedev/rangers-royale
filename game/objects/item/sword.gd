extends Node

const TYPE = preload("res://definitions/item_enums.gd")

var type #Type of item
var name #Name of item
var power = 20 #Damage weapon deals when attacking
var range_radius = 100 #Radius of weapon range

func _ready():
	type = TYPE.WEAPON
	name = "long_sword"
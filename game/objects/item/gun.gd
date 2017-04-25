extends Node

const TYPE = preload("res://definitions/item_enums.gd")

var type #Type of item
var name #Name of item
var power = 8 #Damage weapon deals when attacking
var range_radius = 50 #Radius of weapon range

func _ready():
	type = TYPE.WEAPON
	name = "gun"
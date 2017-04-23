extends Node

const TYPE = preload("res://definitions/item_enums.gd")

var type #Type of item
var name #Name of item
var defense = 5 #Damage armor blocks from attacks

func _ready():
	type = TYPE.ARMOR
	name = "strong helmet"
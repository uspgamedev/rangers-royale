extends Node

const TYPE = preload("res://definitions/item_enums.gd")

var type #Type of item
var name #Name of item

func _ready():
	type = TYPE.CONSUMABLE
	name = "med_kit"

func activate(player, ai):
	ai.heal(20)
	ai.drop_consumable()
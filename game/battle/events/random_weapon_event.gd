
extends "res://battle/events/event_base.gd"

const EQUIPMENTS = [
	preload("res://objects/item/sword.tscn"),
	preload("res://objects/item/helmet.tscn"),
]

func _use(pos, zone):
	queue_free()
	var weapon = EQUIPMENTS[randi() % EQUIPMENTS.size()].instance()
	self.map.drop_item(weapon, pos)


extends "res://battle/events/event_base.gd"

const EQUIPMENTS = [
	preload("res://objects/item/sword.tscn")
]

func _use(pos, zone):
	queue_free()
	var medkit = EQUIPMENTS[randi() % EQUIPMENTS.size()].instance()
	self.map.drop_item(medkit, pos)

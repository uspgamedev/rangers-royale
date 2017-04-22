
extends "res://battle/events/event_base.gd"

const MEDKIT = preload("res://objects/item/med_kit.tscn")

func _use(pos, zone):
	queue_free()
	var medkit = MEDKIT.instance()
	self.map.drop_item(medkit, pos)

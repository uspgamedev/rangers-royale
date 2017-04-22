
extends "res://battle/events/event_base.gd"

const MEDKIT = preload("res://objects/item/med_kit.tscn")

func _use(pos, zone):
	queue_free()
	var medkit = MEDKIT.instance()
	medkit.set_pos(pos)
	self.map.get_node("Items").add_child(medkit)

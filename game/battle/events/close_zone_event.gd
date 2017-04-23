
extends "res://battle/events/event_base.gd"

const DEATH_TIMER = preload("res://battle/zones/death_zone_timer.tscn")

func _use(pos, zone):
	var timer = DEATH_TIMER.instance()
	timer.zone = zone
	zone.add_child(timer)
	queue_free()

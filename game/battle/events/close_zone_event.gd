
extends "res://battle/events/event_base.gd"

const DEATH_TIMER = preload("res://battle/zones/death_zone_timer.tscn")
onready var global_state = get_node("/root/GlobalState")

func _use(pos, zone):
	var timer = DEATH_TIMER.instance()
	timer.zone = zone
	zone.add_child(timer)
	global_state.shortcuts["newsticker"].queue_msg("A zone is collapsing!")
	queue_free()

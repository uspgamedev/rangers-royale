
extends "res://battle/events/event_base.gd"

const DEATH_TIMER = preload("res://battle/zones/death_zone_timer.tscn")
onready var global_state = get_node("/root/GlobalState")

onready var msgs = [
	"Warning!! A zone is collapsing!",
	"The map is getting smaller! Rangers, watch your step!",
]

func _use(pos, zone):
	var timer = DEATH_TIMER.instance()
	timer.zone = zone
	zone.add_child(timer)
	global_state.shortcuts["newsticker"].queue_msg(msgs[randi()%msgs.size()])
	queue_free()


extends "res://battle/events/event_base.gd"

const MEDKIT = preload("res://objects/item/med_kit.tscn")
onready var global_state = get_node("/root/GlobalState")

onready var msgs = [
	"A medkit is landing on the battlefield! Will the tide of battle turn?",
	"Health is literally falling from the sky!",
	"Keep your eyes open Rangers, a medkit has appeared!",
]

func _use(pos, zone):
	queue_free()
	var medkit = MEDKIT.instance()
	if randf() < .5:
		global_state.shortcuts["newsticker"].queue_msg(msgs[randi()%msgs.size()])
	self.map.drop_item(medkit, pos)

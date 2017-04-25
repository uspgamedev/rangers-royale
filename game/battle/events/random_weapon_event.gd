
extends "res://battle/events/event_base.gd"
onready var global_state = get_node("/root/GlobalState")

const EQUIPMENTS = [
	preload("res://objects/item/sword.tscn"),
	preload("res://objects/item/helmet.tscn"),
	preload("res://objects/item/axe.tscn"),
	preload("res://objects/item/arrow.tscn"),
	preload("res://objects/item/gun.tscn"),
]


func _use(pos, zone):
	queue_free()
	var index = randi() % EQUIPMENTS.size()
	var weapon = EQUIPMENTS[index].instance()
	var w_name
	if index == 0:
		w_name = "long sword"
	elif index == 1:
		w_name = "helmet"
	elif index == 2:
		w_name = "axe"
	elif index == 3:
		w_name = "bow"
	elif index == 4:
		w_name = "gun"
	else:
		w_name = "item"
	var prefix_lower = "a "
	var prefix_upper = "A "
	if w_name == "axe":
		prefix_lower = "an "
		prefix_upper = "An "
	var msgs = [
		prefix_upper + w_name+ " has appeared on the battlefield! Run for it Rangers!",
		"Reinforcements were send to the Ranger. What will happen now?",
		"I hope you are ready Rangers, "+ prefix_lower + w_name + " just appeared!",
	]
	if randf() < .5:
		global_state.shortcuts["newsticker"].queue_msg(msgs[randi()%msgs.size()])
	self.map.drop_item(weapon, pos)

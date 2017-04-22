extends Node2D

const DROP = preload("res://battle/map/drop.tscn")

onready var zones = get_node("Zones")
onready var items = get_node("Items")
onready var players = get_node("Players")

func drop_item(item, pos):
	var drop = DROP.instance()
	drop.item = item
	drop.target_pos = pos
	add_child(drop)
	yield(drop, "item_dropped")
	items.add_child(item)

func players_in_zone(zone):
	var result = []
	for player in self.players.get_children():
		if self.zones.get_zone_at(player.get_pos()) == zone:
			result.append(player)
	return result

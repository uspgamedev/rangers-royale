extends Node2D

const PLAYER = preload("res://objects/player.tscn")
const DROP = preload("res://battle/map/drop.tscn")

onready var zones = get_node("Zones")
onready var items = get_node("Items")
onready var players = get_node("Players")

func _ready():
	randomize()

func drop_item(item, pos):
	var drop = DROP.instance()
	drop.item = item
	drop.target_pos = pos
	add_child(drop)
	yield(drop, "item_dropped")
	items.add_child(item)

func drop_player():
	var player = PLAYER.instance()
	var all_zones = self.zones.get_children()
	var zone = all_zones[randi() % all_zones.size()]
	var tiles = zone.get_used_cells()
	var tile = tiles[randi() % tiles.size()]
	var pos = zone.map_to_global_world(tile)
	player.set_pos(pos)
	players.add_child(player)

func players_in_zone(zone):
	var result = []
	for player in self.players.get_children():
		if self.zones.get_zone_at(player.get_pos()) == zone:
			result.append(player)
	return result

func all_players(reject = {}):
	var result = []
	for player in players():
		if not reject.has(player):
			result.append(player)
	return result

func closest_player(pos, reject = {}):
	var valid = all_players(reject)
	var mindist = 1024 * 1024
	var closest = null
	for player in valid:
		var dist = player.get_pos().distance_to(pos)
		if dist < mindist:
			mindist = dist
			closest = player
	return closest

extends Node2D

const PLAYER = preload("res://objects/player.tscn")
const DROP = preload("res://battle/map/drop.tscn")
const BLOOD = preload("res://objects/player/death.tscn")

onready var global_state = get_node("/root/GlobalState")
onready var zones = get_node("Zones")
onready var items = get_node("Items")
onready var players = get_node("Players")
onready var camera = get_node("Camera")

onready var drop_sfx = get_node("DropSFX")
onready var close_sfx = get_node("CloseSFX")
onready var dead_players = 0;
var spawn_points = {}

func _ready():
	randomize()
	

func drop_item(item, pos):
	var drop = DROP.instance()
	drop.item = item
	drop.target_pos = pos
	add_child(drop)
	drop_sfx.play()
	yield(drop, "item_dropped")
	items.add_child(item)

func drop_player():
	var player = PLAYER.instance()
	player.get_node("AI").map_node = self
	var all_zones = self.zones.get_children()
	var zone = all_zones[randi() % all_zones.size()]
	var pos = zone.random_pos()
	while spawn_points.has(pos):
		zone = all_zones[randi() % all_zones.size()]
		pos = zone.random_pos()
	spawn_points[pos] = true
	player.set_pos(pos)
	player.color = Color(0.2+randf()*0.5, 0.2+randf()*0.5, 0.2+randf()*0.5)
	player.get_node("AI").connect("died", self, "_player_died")
	players.add_child(player)

func _player_died(player):
	var blood = BLOOD.instance()
	blood.set_pos(player.get_parent().get_pos())
	add_child(blood)
	dead_players += 1
	print("hue")

func play_close_zone_sfx():
	close_sfx.play()

func players_in_zone(zone):
	var result = []
	for player in self.players.get_children():
		if self.zones.get_zone_at(player.get_pos(), false) == zone:
			result.append(player)
	return result

func items_in_zone(zone):
	var result = []
	for item in self.items.get_children():
		if self.zones.get_zone_at(item.get_pos(), false) == zone:
			result.append(item)
	return result

func all_players(reject = {}):
	var result = []
	for player in players.get_children():
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

class DistanceComparator:
	var ref
	func _init(ref):
		self.ref = ref
	func _compare(lhs, rhs):
		return ref.distance_to(lhs) < ref.distance_to(rhs)

func find_items_by_distance(pos):
	var mindist = 1024 * 1024
	var result = []
	for item in items.get_children():
		result.append(item)
	result.sort_custom(DistanceComparator.new(pos), "_compare")
	return result

func get_closest_wall(pos):
	var valid = zones.get_used_cells()
	var mindist = 1024 * 1024
	var closest = null
	for wall in valid:
		var wallpos = zones.map_to_world(wall) + Vector2(32,24)
		var dist = wallpos.distance_to(pos)
		if dist < mindist:
			mindist = dist
			closest = wallpos
	return closest

func closest_safer_tile(pos, ref_danger):
	var valid = []
	for zone in zones.get_children():
		if zone.danger < ref_danger:
			for tile in zone.get_used_cells():
				valid.append(zone.map_to_global_world(tile))
	var mindist = 1024 * 1024
	var closest = null
	for target in valid:
		var dist = target.distance_to(pos)
		if dist < mindist:
			mindist = dist
			closest = target
	return closest

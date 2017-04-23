extends Timer

var zone

func _ready():
	assert(zone != null)
	zone.shake(get_wait_time())
	zone.set_danger(10)

func _activate():
	var map = zone.get_parent().get_parent()
	for player in map.players_in_zone(zone):
		player.get_node("AI").kill()
	for item in map.items_in_zone(zone):
		item.queue_free()
	var zones = map.get_node("Zones")
	for tile in zone.get_used_cells():
		var pos = zones.get_tile_at(zone.map_to_global_world(tile), false)
		zones.set_cellv(pos, 0)
	zone.clear()
	zone.queue_free()
	queue_free()

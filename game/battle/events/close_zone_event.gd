
extends "res://battle/events/event_base.gd"

func _use(pos, zone):
	var map = zone.get_parent().get_parent()
	for player in map.players_in_zone(zone):
		player.get_node("AI").kill()
	var zones = map.get_node("Zones")
	for tile in zone.get_used_cells():
		var pos = zones.get_tile_at(zone.map_to_global_world(tile), false)
		zones.set_cellv(pos, 0)
	zone.queue_free()
	queue_free()

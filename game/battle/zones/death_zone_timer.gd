extends Timer

var zone

func _ready():
	assert(zone != null)
	zone.shake(get_wait_time())
	zone.set_danger(10)

func _activate():
	var map = zone.get_parent().get_parent()
	map.play_close_zone_sfx()
	for player in map.players_in_zone(zone):
		player.get_node("AI").kill()
	for item in map.items_in_zone(zone):
		item.queue_free()
	var zones = map.get_node("Zones")
	zone.clear()
	zone.queue_free()
	queue_free()

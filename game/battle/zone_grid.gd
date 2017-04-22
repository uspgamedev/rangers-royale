extends TileMap

func _ready():
	var zone = get_child(0)
	var pos = zone.get_pos()
	var tile = world_to_map(pos)
	print("%d %d" % [tile.x, tile.y])
	pos = map_to_world(tile)
	print("%d %d" % [pos.x, pos.y])
	pos = pos - zone.get_pos()
	tile = zone.world_to_map(pos)
	print("%d %d" % [pos.x, pos.y])
	print("%d %d" % [tile.x, tile.y])
	set_process_input(true)

func _input(event):
	if event.is_action_pressed("ui_click"):
		for zone in get_children():
			zone.unfocus()
		var zone = get_zone_at(event.pos)
		if zone:
			zone.focus()

func get_zone_at(point):
	var space = get_world_2d().get_direct_space_state()
	for coll in space.intersect_point(point):
		if coll.collider extends TileMap:
			return coll.collider

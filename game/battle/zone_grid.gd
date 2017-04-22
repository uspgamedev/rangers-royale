extends TileMap

func _ready():
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

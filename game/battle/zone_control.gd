extends TileMap

onready var camera = get_node('../Camera')
onready var zone = null

func _ready():
	pass

func generate_border():
	clear()
	for zone in get_children():
		var off = Vector2(0,0)
		for border in zone.trace_border():
			var point = zone.get_pos() + zone.map_to_world(border) + Vector2(32,24)
			var tile = world_to_map(point)
			if get_zone_at(point, false) == null:
				set_cellv(tile + off, 0)

func get_tile_at(pos, fix=true):
	if fix:
		pos = screen_to_map(pos)
	return world_to_map(pos)

func screen_to_map(point):
	return point + camera.get_pos() - OS.get_window_size()/2

func get_zone_at(point, fix=true):
	if fix:
		point = screen_to_map(point)
	var space = get_world_2d().get_direct_space_state()
	for coll in space.intersect_point(point):
		if coll.collider extends TileMap and coll.collider != self:
			return coll.collider
	return null

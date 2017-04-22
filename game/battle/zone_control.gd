extends TileMap

onready var camera = get_node('../Camera')
onready var zone = null

func _ready():
	for zone in get_children():
		for border in zone.trace_border():
			var point = zone.get_pos() + zone.map_to_world(border)
			var tile = world_to_map(point)
			set_cellv(tile, 0)
	for zone in get_children():
		for tile in zone.get_used_cells():
			var point = zone.get_pos() + zone.map_to_world(tile)
			set_cellv(get_tile_at(point), -1)
	set_process_input(true)

func _input(event):
	if event.is_action_pressed("ui_click"):
		var pos = event.pos + camera.get_pos() - OS.get_window_size()/2
		for zone in get_children():
			zone.unfocus()
		self.zone = get_zone_at(pos)
		if self.zone:
			self.zone.focus()

func get_tile_at(pos):
	return world_to_map(pos + camera.get_pos() - OS.get_window_size()/2)

func get_zone_at(point):
	var space = get_world_2d().get_direct_space_state()
	for coll in space.intersect_point(point):
		if coll.collider extends TileMap and coll.collider != self:
			return coll.collider
	return null

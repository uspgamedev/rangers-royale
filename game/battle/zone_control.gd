extends TileMap

onready var camera = get_node('../Camera')
onready var zone = null

func _ready():
	set_process_input(true)

func _input(event):
	if event.is_action_pressed("ui_click"):
		var pos = event.pos + camera.get_pos() - OS.get_window_size()/2
		print(pos)
		print(world_to_map(pos))
		print(map_to_world(world_to_map(pos)))
		print(world_to_map(map_to_world(world_to_map(pos))))
		for zone in get_children():
			zone.unfocus()
		self.zone = get_zone_at(pos, null)
		if self.zone:
			self.zone.focus()
			var tile = world_to_map(self.zone.get_pos() + self.zone.map_to_world(Vector2(0,0)))
			print(tile)
			set_cellv(tile, 0)

func get_zone_at(point, zone):
	var space = get_world_2d().get_direct_space_state()
	for coll in space.intersect_point(point):
		if coll.collider extends TileMap and coll.collider != self:
			return coll.collider
	return null

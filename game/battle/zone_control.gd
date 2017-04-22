extends TileMap

onready var camera = get_node('../Camera')
onready var zone = null

func _ready():
	set_process_input(true)

func _input(event):
	if event.is_action_pressed("ui_click"):
		for zone in get_children():
			zone.unfocus()
		self.zone = get_zone_at(event.pos + camera.get_pos() - OS.get_window_size()/2, null)
		if self.zone:
			self.zone.focus()

func get_zone_at(point, zone):
	var space = get_world_2d().get_direct_space_state()
	for coll in space.intersect_point(point):
		if coll.collider extends TileMap and coll.collider != zone:
			return coll.collider
	return null

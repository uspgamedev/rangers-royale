extends TileMap

onready var camera = get_node('Camera')
onready var zone = null

func _ready():
	set_process_input(true)

func _input(event):
	if event.is_action_pressed("ui_click"):
		if zone == null:
			zone = get_zone_at(event.pos + camera.get_pos() - OS.get_window_size()/2, null)
			if zone:
				zone.focus()
				zone.grab()
				zone.set_scale(Vector2(1, 1))
				self.move_child(zone, get_child_count() - 1)
		else:
			var target = get_zone_at(event.pos + camera.get_pos() - OS.get_window_size()/2, zone)
			if target == null:
				zone.unfocus()
				zone.release()
				
				zone = null

func get_zone_at(point, zone):
	var space = get_world_2d().get_direct_space_state()
	for coll in space.intersect_point(point):
		if coll.collider extends TileMap and coll.collider != zone:
			return coll.collider
	return null

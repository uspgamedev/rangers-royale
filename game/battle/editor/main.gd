extends Control

const ZONES = [
	preload("res://battle/zones/field_A.tscn"),
	preload("res://battle/zones/volcano_A.tscn"),
	preload("res://battle/zones/lake_A.tscn"),
	preload("res://battle/zones/forest_A.tscn"),
]

onready var zones = get_node("Map/Zones")

var placements
var current_zone

func _ready():
	update_placements_view()
	self.current_zone = ZONES[3].instance()
	zones.add_child(self.current_zone)
	set_process_input(true)
	yield(get_tree(), "fixed_frame")
	yield(get_tree(), "fixed_frame")
	self.current_zone.focus()

func _input(event):
	if event.type == InputEvent.MOUSE_MOTION:
		var pos = zones.screen_to_map(event.pos)
		var nearest = null
		var mindist = 1024 * 1024
		for tile in self.placements:
			var target = zones.map_to_world(tile)
			var dist = target.distance_to(pos)
			if dist < mindist:
				mindist = dist
				nearest = target
		if nearest != null:
			self.current_zone.set_pos(nearest)

func local_to_global(zone, tile):
	return zones.get_tile_at(zone.get_pos())

func update_placements_view():
	self.placements = valid_placements()
	for placement in self.placements:
		zones.set_cellv(placement, 0)

func valid_placements():
	var placements = {}
	var invalid = []
	var minpos = Vector2()
	var maxpos = Vector2()
	for zone in zones.get_children():
		for cell in zone.get_used_cells():
			invalid.append(cell)
			if cell.x < minpos.x:
				minpos.x = cell.x
			if cell.y < minpos.y:
				minpos.y = cell.y
			if cell.x > maxpos.x:
				maxpos.x = cell.x
			if cell.y > maxpos.y:
				maxpos.y = cell.y
	for x in range(minpos.x-1,maxpos.x+2):
		for y in range(minpos.y-1, maxpos.y+2):
			placements[Vector2(x,y)] = true
	for tile in placements.keys():
		if int(tile.y) % 2 != 0:
			invalid.append(tile)
	for tile in invalid:
		placements.erase(tile)
	return placements.keys()
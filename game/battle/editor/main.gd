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
var at_valid_tile

func _ready():
	randomize()
	update_placements_view()
	set_process_input(true)
	grab_zone()

func grab_zone():
	var i = randi() % ZONES.size()
	if self.current_zone != null:
		self.current_zone.unfocus()
		self.current_zone = null
	self.current_zone = ZONES[i].instance()
	zones.add_child(self.current_zone)
	yield(get_tree(), "fixed_frame")
	yield(get_tree(), "fixed_frame")
	self.current_zone.focus()

func _input(event):
	if event.type == InputEvent.MOUSE_MOTION:
		var pos = zones.screen_to_map(event.pos)
		var nearest = null
		var mindist = 1024 * 1024
		# Find valid placement closest to cursor
		for tile in self.placements:
			var target = zones.map_to_world(tile)
			var dist = target.distance_to(pos)
			if dist < mindist:
				mindist = dist
				nearest = target
		self.at_valid_tile = (nearest != null)
		# Now disconsider positions that go into other zones
		if self.current_zone.get_pos() != nearest and self.at_valid_tile:
			var zone = self.current_zone
			for tile in zone.get_used_cells():
				var pos = nearest + zone.map_to_world(tile) + Vector2(32,24)
				var other = zones.get_zone_at(pos, false)
				if other != zone and other != null:
					self.at_valid_tile = false
					return
			var check = false
			for tile in zone.trace_border():
				var pos = nearest + zone.map_to_world(tile) + Vector2(32,24)
				var other = zones.get_zone_at(pos, false)
				if other != zone and other != null:
					check = true
			if check:
				self.current_zone.set_pos(nearest)
			else:
				self.at_valid_tile = false
	elif event.is_action_pressed("ui_click") and self.at_valid_tile:
		grab_zone()

func local_to_global(zone, tile):
	return self.zones.get_tile_at(zone.get_pos() + Vector2(1,1), false) + tile

func update_placements_view():
	self.placements = valid_placements()
	at_valid_tile = false

func valid_placements():
	var placements = {}
	var invalid = []
	for x in range(-20,20):
		for y in range(-20,20):
			placements[Vector2(x,y)] = true
	for tile in placements.keys():
		if int(tile.y) % 2 != 0:
			invalid.append(tile)
	for tile in invalid:
		placements.erase(tile)
	return placements.keys()
extends Control

const BATTLE = preload("res://battle/main.tscn")

const ZONES = [
	preload("res://battle/zones/field_A.tscn"),
	preload("res://battle/zones/volcano_A.tscn"),
	preload("res://battle/zones/lake_A.tscn"),
	preload("res://battle/zones/forest_A.tscn"),
	preload("res://battle/zones/ruins_A.tscn"),
	preload("res://battle/zones/ruins_B.tscn"),
]

onready var zones = get_node("Map/Zones")

var placements
var current_zone
var at_valid_tile

func _ready():
	randomize()
	set_process_input(true)
	grab_zone()

func grab_zone():
	var i = randi() % ZONES.size()
	if self.current_zone != null:
		self.current_zone.unfocus()
		self.current_zone = null
		if not self.at_valid_tile:
			self.current_zone.queue_free()
	self.current_zone = ZONES[i].instance()
	update_placements()
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
		# Now disconsider positions that go into other zones
		if self.current_zone.get_pos() != nearest and nearest != null:
			self.at_valid_tile = true
			self.current_zone.set_pos(nearest)
			self.current_zone.focus()
			self.current_zone.set_opacity(1)
			var zone = self.current_zone
			for tile in zone.get_used_cells():
				var pos = nearest + zone.map_to_world(tile) + Vector2(32,24)
				var other = zones.get_zone_at(pos, false)
				if other != zone and other != null:
					self.current_zone.unfocus()
					self.current_zone.set_opacity(0.2)
					self.at_valid_tile = false
					return
			var check = false
			for tile in zone.trace_border():
				var pos = nearest + zone.map_to_world(tile) + Vector2(32,24)
				var other = zones.get_zone_at(pos, false)
				if other != zone and other != null:
					check = true
			if check:
				pass
			else:
				self.current_zone.unfocus()
				self.current_zone.set_opacity(0.2)
				self.at_valid_tile = false
	elif event.is_action_pressed("ui_click") and self.at_valid_tile:
		grab_zone()

func _finish():
	self.current_zone.queue_free()
	self.current_zone = null
	set_process_input(false)
	yield(get_tree(), "fixed_frame")
	yield(get_tree(), "fixed_frame")
	var map = get_node("Map")
	remove_child(map)
	yield(get_tree(), "fixed_frame")
	yield(get_tree(), "fixed_frame")
	var battle = BATTLE.instance()
	battle.add_child(map)
	yield(get_tree(), "fixed_frame")
	yield(get_tree(), "fixed_frame")
	queue_free()
	get_parent().add_child(battle)

func local_to_global(zone, tile):
	return self.zones.get_tile_at(zone.get_pos() + Vector2(1,1), false) + tile

func update_placements():
	self.placements = valid_placements()
	self.at_valid_tile = false

func valid_placements():
	var placements = {}
	var invalid = []
	for x in range(-20,20):
		for y in range(-20,20):
			placements[Vector2(x,y)] = true
	#for tile in placements.keys():
	#	if int(tile.y) % 2 != 0:
	#		invalid.append(tile)
	for tile in invalid:
		placements.erase(tile)
	return placements.keys()
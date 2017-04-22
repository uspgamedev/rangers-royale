extends Node2D

onready var camera = get_node("../Camera")

onready var focused_player = null

func _ready():
	set_process_input(true)

func _input(event):
	if event.type == InputEvent.MOUSE_MOTION:
		var target_pos = screen_to_map(event.pos)
		var player = get_player_at(event.pos)
		if player != self.focused_player:
			if self.focused_player != null:
				print("nope2")
				self.focused_player.get_node("player_info").hide()
				self.focused_player.get_node("AI").disconnect("died", self, "_on_player_death")
			if player != null:
				player.get_node("player_info").show()
				player.get_node("AI").connect("died", self, "_on_player_death")
				print("connect")
			self.focused_player = player

func _on_player_death(player):
	
	self.focused_player.get_node("player_info").hide()
	self.focused_player.get_node("AI").disconnect("died", self, "_on_player_death")
	self.focused_player = null
	print("dead")

func screen_to_map(point):
	return point + self.camera.get_pos() - OS.get_window_size()/2

func get_player_at(point):
	point = screen_to_map(point)
	var space = get_world_2d().get_direct_space_state()
	for coll in space.intersect_point(point):
		if coll.collider.get_name() == "InfoHover":
			return coll.collider.get_parent()
	return null
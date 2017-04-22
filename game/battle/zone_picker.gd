extends Node

export(NodePath) var zones_path

onready var zones = get_node(zones_path)
onready var enabled = true
onready var zone = null

func enable():
	enabled = true
	zone = null
	set_process_input(true)

func disable():
	enabled = false
	zone = null
	set_process_input(false)

func _ready():
	enable()

func _input(event):
	if event.is_action_pressed("ui_click"):
		for zone in zones.get_children():
			zone.unfocus()
		self.zone = zones.get_zone_at(event.pos)
		if self.zone:
			self.zone.focus()
extends Node

var zones
var icon

var target_pos
var focused_zone

signal target_picked(pos, zone)
signal target_canceled()

func _ready():
	assert(zones != null and icon != null)
	Input.set_custom_mouse_cursor(icon, Vector2(16, 16))
	set_process(true)
	set_process_input(true)

func _input(event):
	if event.type == InputEvent.MOUSE_MOTION:
		self.target_pos = zones.screen_to_map(event.pos)
		var zone = zones.get_zone_at(event.pos)
		if zone != self.focused_zone:
			if self.focused_zone != null:
				self.focused_zone.unfocus()
			if zone != null:
				zone.focus()
			self.focused_zone = zone
	elif event.is_action_pressed("ui_click"):
		Input.set_custom_mouse_cursor(null)
		if self.focused_zone != null:
			self.focused_zone.unfocus()
			emit_signal("target_picked", self.target_pos, self.focused_zone)
		else:
			emit_signal("target_canceled")
		queue_free()

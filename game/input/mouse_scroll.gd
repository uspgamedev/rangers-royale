extends Node

onready var new_mouse_pos = Vector2(0, 0)

func _ready():
	set_fixed_process(true)

func _fixed_process(delta):
	if (Input.is_action_pressed('ui_scroll')):
		var diff = get_viewport().get_mouse_pos() - new_mouse_pos
		self.set_pos(self.get_pos() - diff)
	new_mouse_pos = get_viewport().get_mouse_pos()
	
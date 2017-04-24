extends Panel

const MSG = preload("res://battle/hud/flowing_text.tscn")

var queue = []

func queue_msg(msg):
	queue.append(msg)
	if queue.size() == 1:
		_next_text()

func _next_text():
	var msg = queue.front()
	queue.pop_front()
	var label = MSG.instance()
	label.set_text(msg)
	add_child(label)
	label.get_node("Tween").connect("tween_complete", self, "_next_text")

extends Label

const DURATION = 4

onready var tween = get_node("Tween")

func _ready():
	var width = get_size().x
	var time = DURATION + width/800.0 * DURATION
	var x = Vector2(1,0)
	set_pos(800*x)
	tween.interpolate_method(self, "set_pos", 800*x, -width*x, time, Tween.TRANS_LINEAR, Tween.EASE_IN_OUT)
	tween.start()
	yield(tween, "tween_complete")
	queue_free()

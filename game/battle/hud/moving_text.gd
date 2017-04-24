extends Label

onready var tween = get_node("Tween")

func _ready():
	var width = get_size().x
	var time = 10 + width/800.0 * 10
	var x = Vector2(1,0)
	tween.interpolate_method(self, "set_pos", 800*x, -width*x, time, Tween.TRANS_LINEAR, Tween.EASE_IN_OUT)
	tween.start()
	yield(tween, "tween_complete")
	queue_free()

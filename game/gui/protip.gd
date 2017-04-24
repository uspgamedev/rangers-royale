extends Panel

const PROTIP = preload("res://gui/protip.tscn")

onready var tween = get_node("Tween")
onready var timer = get_node("Timer")
onready var label = get_node("Message")

func _ready():
	var pos = get_pos()
	tween.interpolate_method(self, "set_pos", pos, pos - Vector2(200,0), 1, Tween.TRANS_QUAD, Tween.EASE_OUT)
	tween.start()
	yield(tween, "tween_complete")
	timer.start()
	yield(timer, "timeout")
	tween.interpolate_method(self, "set_pos", pos - Vector2(200,0), pos, 1, Tween.TRANS_QUAD, Tween.EASE_IN)
	tween.start()
	yield(tween, "tween_complete")
	queue_free()

static func show_protip(msg):
	var protip = PROTIP.instance()
	protip.get_node("Message").set_text(msg)
	return protip

extends Panel

onready var fade = get_node("Fader")
onready var tween = get_node("Tween")
onready var title = get_node("Title")

func _ready():
	fade.fade_in()
	var pos = title.get_pos()
	tween.interpolate_method(title, "set_pos", pos + Vector2(800,0), pos, 1.5, Tween.TRANS_QUAD, Tween.EASE_OUT)
	tween.start()

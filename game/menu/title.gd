extends TextureFrame

onready var fade = get_node("Fader")
onready var tween = get_node("Tween")

func _ready():
	fade.fade_in()
	var pos = get_pos()
	tween.interpolate_method(self, "set_pos", pos + Vector2(800,0), pos, 1.3, Tween.TRANS_QUART, Tween.EASE_OUT)
	tween.start()

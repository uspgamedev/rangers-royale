extends TextureFrame

const EDITOR = preload("res://battle/editor/main.tscn")

onready var fade = get_node("Fader")
onready var tween = get_node("Tween")

func _ready():
	fade.fade_in()
	var pos = get_pos()
	tween.interpolate_method(self, "set_pos", pos + Vector2(800,0), pos, 1.3, Tween.TRANS_QUART, Tween.EASE_OUT)
	tween.start()
	yield(tween, "tween_complete")
	set_process_input(true)

func _input(event):
	if event.is_action_pressed("ui_accept"):
		replace_by(EDITOR.instance())

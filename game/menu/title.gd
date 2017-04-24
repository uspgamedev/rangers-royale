extends TextureFrame

const EDITOR = preload("res://battle/editor/main.tscn")
const Protip = preload("res://gui/protip.gd")

onready var global_state = get_node("/root/GlobalState")

onready var fade = get_node("Fader")
onready var tween = get_node("Tween")

func _ready():
	fade.fade_in()
	var pos = get_pos()
	tween.interpolate_method(self, "set_pos", pos + Vector2(800,0), pos, 1.3, Tween.TRANS_QUART, Tween.EASE_OUT)
	tween.start()
	yield(tween, "tween_complete")
	set_process_input(true)
	if not global_state.flags.has("intro_msg"):
		get_parent().add_child(Protip.show_protip("Click with the mouse\nto begin!"))

func _input(event):
	if event.is_action_pressed("ui_click"):
		get_node("/root/BGM").stop()
		queue_free()
		get_parent().add_child(EDITOR.instance())

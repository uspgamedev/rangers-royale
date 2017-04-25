extends Panel

const MSG = preload("res://battle/hud/flowing_text.tscn")

var queue = []
var idle = true
var msgs = [
	"Let's have a good show tonight!",
	"Rangers, it's go time!",
	"The stage of battle is set. It's showtime!",
]

onready var global_state = get_node("/root/GlobalState")
onready var logo = get_node("Logo")

func _ready():
	global_state.shortcuts["newsticker"] = self
	queue_msg(msgs[randi()%msgs.size()])

func _exit_tree():
	global_state.shortcuts.erase("newsticker")

func queue_msg(msg):
	queue.append(msg)
	if idle:
		idle = false
		_next_text()

func _next_text(unused1=null, unused2=null):
	if not queue.empty():
		var msg = queue.front()
		queue.pop_front()
		var label = MSG.instance()
		label.set_text(msg)
		add_child(label)
		move_child(label, 0)
		label.get_node("Tween").connect("tween_complete", self, "_next_text")
	else:
		idle = true

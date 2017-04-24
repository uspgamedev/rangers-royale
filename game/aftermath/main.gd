extends Panel

const EDITOR = preload("res://battle/editor/main.tscn")

export(int) var total_time = 100.2
export(int) var num_survivors = 2
export(int) var audience_score = 75.4

onready var global_state = get_tree().get_root().get_node("GlobalState")

onready var time_display = get_node("Frame/TotalTime/Value")
onready var survivors_display = get_node("Frame/NumSurvivors/Value")
onready var audience_display = get_node("Frame/AudienceScore/Value")
onready var reputation_display = get_node("Frame/Reputation")

func _ready():
	var cases = [
		[survivors_display, num_survivors, "set_survivors", 1.5],
		[time_display, total_time, "set_time", 2],
		[audience_display, audience_score, "set_audience", 2.5],
		[reputation_display, calculate_reputation(), "set_reputation", 4]
	]
	for entry in cases:
		var tween = entry[0].get_node("Tween")
		tween.interpolate_method(self, entry[2], 0, entry[1], entry[3], Tween.TRANS_LINEAR, Tween.EASE_IN_OUT)
		tween.start()
	set_process_input(true)

func _input(event):
	if event.is_action_pressed("ui_click"):
		queue_free()
		get_parent().add_child(EDITOR.instance())

func set_time(mins):
	var hours = int(mins/60.0)
	var seconds = mins - int(mins)
	mins -= hours*60 + seconds
	time_display.set_text("%02d:%02d:%02d" % [hours, mins, int(60*seconds)])

func set_survivors(n):
	survivors_display.set_text(var2str(int(n)))

func set_audience(x):
	audience_display.set_text("%.1f%%" % [x])

func set_reputation(n):
	reputation_display.set_text(var2str(int(n)))

func calculate_reputation():
	var time_coef = 50*abs(total_time - 30)
	var survival_coef
	if num_survivors == 0:
		survival_coef = -1000
	else:
		survival_coef = 2000 - (num_survivors - 1)*500
	var audience_coef = (audience_score - 50) * 100
	global_state.reputation += (time_coef + survival_coef + audience_coef)*global_state.BLING_LEVEL
	return global_state.reputation

extends Panel

export(int) var total_time = 100.2
export(int) var num_survivors
export(int) var audience_score

onready var time_display = get_node("Frame/TotalTime/Value")
onready var survivors_display = get_node("Frame/NumSurvivors/Value")
onready var audience_display = get_node("Frame/AudienceDisplay/Value")
onready var reputation_display = get_node("Frame/Reputation")

func _ready():
	var time_tween = time_display.get_node("Tween")
	time_tween.interpolate_method(self, "set_time", 0, total_time, 2, Tween.TRANS_LINEAR, Tween.EASE_IN_OUT)
	time_tween.start()

func set_time(mins):
	var hours = int(mins/60.0)
	var seconds = mins - int(mins)
	print(int(60*seconds))
	mins -= hours*60 + seconds
	time_display.set_text("%02d:%02d:%02d" % [hours, mins, int(60*seconds)])

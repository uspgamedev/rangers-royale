extends ProgressBar

func _ready():
	set_fixed_process(true)

func _fixed_process(delta):
	check_status()

func check_status():
	pass
	
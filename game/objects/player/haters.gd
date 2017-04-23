extends Label

onready var player = get_node('../../../AI')

func _ready():
	set_fixed_process(true)

func _fixed_process(delta):
	set_text('Haters: ' + var2str(player.haters))
	pass

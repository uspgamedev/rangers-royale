extends Label

onready var player = get_node('../../../AI')

func _ready():
	set_fixed_process(true)

func _fixed_process(delta):
	set_text('Fans: ' + var2str(player.fans))
	pass

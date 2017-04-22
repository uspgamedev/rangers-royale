extends TileMap

export(int) var stealth_bonus = 0
export(int) var friction = 0
export(int) var armor = 0

onready var highlight = get_node("Highlight")
onready var animation = highlight.get_node("AnimationPlayer")

func _ready():
	for tile in get_used_cells():
		highlight.set_cellv(tile, 0)

func focus():
	animation.play("focused")

func unfocus():
	animation.play("unfocused")


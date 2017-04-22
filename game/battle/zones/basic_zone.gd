extends TileMap

export(int) var stealth_bonus = 0
export(int) var friction = 0
export(int) var armor = 0

onready var highlight = get_node("Highlight")
onready var animation = highlight.get_node("AnimationPlayer")
onready var new_mouse_pos = Vector2(0, 0)
onready var focused = false
onready var grabbed = false
onready var diff = Vector2(0, 0)

const NEIGHBORS = [
	[Vector2(0,1), Vector2(0,-1), Vector2(1,0), Vector2(-1,0), Vector2(-1,-1), Vector2(-1,1)],
	[Vector2(0,1), Vector2(0,-1), Vector2(1,0), Vector2(-1,0), Vector2(1,1), Vector2(1,-1)]
]

func _ready():
	for tile in get_used_cells():
		highlight.set_cellv(tile, 0)
	set_fixed_process(true)

func _fixed_process(delta):
	if grabbed:
		var mouse_pos = get_viewport().get_mouse_pos()
		diff = mouse_pos - new_mouse_pos
		self.set_pos(self.get_pos() + diff)
	new_mouse_pos = get_viewport().get_mouse_pos()

func trace_border():
	var visited = {}
	var border = []
	var queue = []
	queue.append(get_used_cells()[0])
	while !queue.empty():
		var tile = queue.back()
		queue.pop_back()
		if not visited.has(tile):
			visited[tile] = true
			if get_cellv(tile) == -1:
				border.append(tile)
			else:
				for offset in NEIGHBORS[int(tile.y) % 2]:
					queue.append(tile + offset)
	return border

func grab():
	grabbed = true

func release():
	grabbed = false

func focus():
	animation.play("focused")
	focused = true

func unfocus():
	animation.play("unfocused")
	focused = false

extends Node2D

var item
var target_pos

onready var package = get_node("Package")
onready var tween = get_node("Tween")

signal item_dropped(item)

func _ready():
	assert(self.item != null)
	package.set_texture(item.get_node("Sprite").get_texture())
	set_pos(target_pos + Vector2(0, -64))
	tween.interpolate_method(self, "set_pos", get_pos(), target_pos, 1, Tween.TRANS_QUAD, Tween.EASE_OUT)
	tween.start()
	yield(tween, "tween_complete")
	self.item.set_pos(target_pos)
	emit_signal("item_dropped", self.item)
	queue_free()

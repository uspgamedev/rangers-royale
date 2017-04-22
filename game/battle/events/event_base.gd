extends TextureButton

const TargetPickerScene = preload("res://battle/target_picker.tscn")

onready var icon = get_normal_texture()
var map

signal event_chosen()

func _choose():
	var picker = TargetPickerScene.instance()
	picker.zones = self.map.zones
	picker.icon = self.icon
	picker.connect("target_picked", self, "_use")
	add_child(picker)
	emit_signal("event_chosen")

func _use(pos, zone):
	queue_free()
	print(pos)
	if zone != null:
		print("zone: %s" % zone.get_name())

func _ready():
	assert(self.map != null)

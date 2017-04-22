extends Control

const TargetPickerScene = preload("res://battle/target_picker.tscn")

const TEST_ICON = preload("res://battle/events/medpack-icon.tres")

onready var zone_picker = get_node("ZonePicker")
onready var zones = get_node("Map/Zones")
onready var event_panel = get_node("HUD/EventPanel")

func _ready():
	set_process_input(true)

func _input(event):
	if event.is_action_pressed("ui_accept"):
		var picker = TargetPickerScene.instance()
		picker.zones = self.zones
		picker.icon = TEST_ICON
		picker.connect("target_picked", self, "_on_target_picked")
		add_child(picker)
		zone_picker.disable()

func _on_event_chosen():
	zone_picker.disable()

func _on_target_picked(pos, zone):
	print(pos)
	if zone != null:
		print("zone: %s" % zone.get_name())

func _draw_event_time():
	event_panel.draw_event(self)
extends Control

const TargetPickerScene = preload("res://battle/target_picker.tscn")

const TEST_ICON = preload("res://battle/events/medpack-icon.tres")

onready var zone_picker = get_node("ZonePicker")
onready var map = get_node("Map")
onready var zones = get_node("Map/Zones")
onready var event_panel = get_node("HUD/EventPanel")

func _ready():
	zones.generate_border()

func _on_event_chosen():
	zone_picker.disable()

func _draw_event_time():
	event_panel.draw_event(self)
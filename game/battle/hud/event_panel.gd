extends Panel

const DUMMY_EVENT = preload("res://battle/events/event_base.tscn")
const EVENTS = [
	preload("res://battle/events/medkit_event.tscn"),
	preload("res://battle/events/random_weapon_event.tscn"),
	preload("res://battle/events/close_zone_event.tscn")
]

onready var events = get_node("Events")

func draw_event(main):
	if get_child_count() < 10:
		var new_event = EVENTS[randi() % EVENTS.size()].instance()
		new_event.map = main.get_node("Map")
		events.add_child(new_event)
		new_event.connect("event_chosen", main, "_on_event_chosen")

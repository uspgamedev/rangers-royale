extends Panel

const DUMMY_EVENT = preload("res://battle/events/event_base.tscn")

onready var events = get_node("Events")

func draw_event(main):
	var new_event = DUMMY_EVENT.instance()
	new_event.map = main.get_node("Map")
	events.add_child(new_event)
	new_event.connect("event_chosen", main, "_on_event_chosen")

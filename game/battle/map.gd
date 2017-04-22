extends Node2D

onready var zones = get_node("Zones")
onready var items = get_node("Items")
onready var players = get_node("Players")

func _ready():
	# Called every time the node is added to the scene.
	# Initialization here
	pass

func players_in_zone(zone):
	var result = []
	for player in self.players.get_children():
		if self.zones.get_zone_at(player.get_pos()) == zone:
			result.append(player)
	return result

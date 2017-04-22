extends Node

const DIRS = preload("res://definitions/directions.gd")
const RANGE_AREA = preload("res://objects/player/range_area.tscn")

var player_node #Reference to the player
var max_life = 30 #Player maxlife
var damage_taken = 0 #Damage taken by player
var power = 30e-2 * randf() #Damage player inflicts when attacking
var nearby_bodies = [] #Number of players or monsters inside this player range_area

#PRIMITIVE CLASSES
class Action:
	func _init():
		pass
	func act(player, ai):
		pass

class Objective:
	func _init():
		pass
	#Returns an action for the player to act on
	func think_action(player, ai):
		return Action.new()

#ACTIONS

#Does nothing
class Idle:
	extends Action
	func act(player, ai):
		pass

#The player moves to given dir
class Move:
	extends Action
	var dir
	func _init(_dir):
		dir = _dir
	func act(player, ai):
		player.push_dir(dir)

#Attacks a target with player damage
class Attack:
	extends Action
	var target
	func _init(_target):
		target = _target
	func act(player, ai):
		target.get_node('AI').take_damage(ai.power)

#OBJECTIVES

#Moves randomly and if possible, tries to attack nearby players
class Move_Random_And_Attack:
	extends Objective
	var dir
	func _init():
		dir = DIRS.RIGHT+DIRS.DOWN
	func think_action(player, ai):
		#Attack nearby bodies if possible
		if ai.nearby_bodies.size() > 0:
			var random_body = ai.nearby_bodies[randi()%ai.nearby_bodies.size()]
			return Attack.new(random_body)
		#Small chance to change direction
		if randf()<.1:
			dir = DIRS.NONE
			if randf()< .5:
				dir += DIRS.RIGHT
			else:
				dir += DIRS.LEFT
			if randf()< .5:
				dir += DIRS.UP
			else:
				dir += DIRS.DOWN
		return Move.new(dir)

var cur_objective = Move_Random_And_Attack.new()

func _ready():
	randomize()
	set_fixed_process(true)
	player_node = get_parent()
	player_node.set_pos(Vector2(400*randf(), 300*randf()))
	create_new_range(100 + 50*randf())
	
func _fixed_process(delta):
	#Make one action of the current objective
	limit_movement()
	get_node('range_area').set_pos(player_node.get_pos())
	var action = cur_objective.think_action(player_node, self)
	action.act(player_node, self)

func limit_movement():
	if player_node.get_pos().x < 0:
		player_node.set_pos(Vector2(200*randf(), 150*randf()))
	if player_node.get_pos().x > 800:
		player_node.set_pos(Vector2(200*randf(), 150*randf()))
	if player_node.get_pos().y < 0:
		player_node.set_pos(Vector2(200*randf(), 150*randf()))
	if player_node.get_pos().y > 600:
		player_node.set_pos(Vector2(200*randf(), 150*randf()))

#Creates a new range_area with radius 'r'. Removes previously range_area
func create_new_range(r):
	print("creating a new range")
	var old_range_area

		#Remove previously range_area
	for child in self.get_children():
		if child.get_name() == "range_area":
			old_range_area = child
	if old_range_area:
		self.remove_child(old_range_area)

	self.nearby_bodies.clear() #Clear nearby players
	var area = RANGE_AREA.instance()
	area.set_radius(r)
	area.set_pos(player_node.get_pos())
	self.add_child(area) #Add new area_range
	area.connect("body_enter", self, "enter_neighbor")
	area.connect("area_enter", self, "area_neighbor")
	area.connect("body_exit", self, "leave_neighbor")

#Add a body to nearby_bodies array
#Called when a new body enters the player range_area
func enter_neighbor(body):
	if body extends KinematicBody2D:
		if body == player_node:
			return
		nearby_bodies.append(body) #For now only adds, but needs to check the body type

#Removes a body from nearby_bodies array
#Called when a body leaves the player range_area
func leave_neighbor(body):
	if body extends KinematicBody2D:
		var count = 0
		for b in nearby_bodies:
			if b == body:
				nearby_bodies.remove(count) #For now only removes, but needs to check the body type
			count += 1

#Make player take 'd' damage and checks for death
func take_damage(d):
	self.damage_taken += d
	if self.damage_taken >= self.max_life:
		self.kill()

#Handle player death
func kill():
	player_node.queue_free()

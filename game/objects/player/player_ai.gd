extends Node

const DIRS = preload("res://definitions/directions.gd")
const ITEM_TYPE = preload("res://definitions/item_enums.gd")
const RANGE_AREA = preload("res://objects/player/range_area.tscn")

var player_node #Reference to the player
var player_info #Reference to player info panel

var default_unarmed_range = 100 + 50*randf() #Ranged of "unarmed weapon"
var default_unarmed_power = 10 + randf()*5   #Power of "unarmed weapon"

var max_life = 30 #Player maxlife
var damage_taken = 0 #Damage taken by player
var name = "dummy" #Name of player
var afiliation = randi()%2 #Number of afiliation
var power = default_unarmed_power #Damage player inflicts when attacking
var weapon_equipped #Weapon player is holding
var armor_equipped #Armor player is holding
var item_holding #Item player is holding

var nearby_bodies = [] #Number of players or monsters inside this player range_area
var nearby_items = [] #Number of items inside this player item_area
var on_cooldown = 0 #Seconds the player can't make any action besides walking



#PRIMITIVE CLASSES
class Action:
	var cooldown
	func _init(_cd):
		cooldown = _cd
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
	func _init().(0):
		pass
	func act(player, ai):
		pass

#The player moves to given dir
class Move:
	extends Action
	var dir
	func _init(_dir).(0):
		dir = _dir
	func act(player, ai):
		player.push_dir(dir)

#Attacks a target with player damage
class Attack:
	extends Action
	var target
	func _init(_target).(3):
		target = _target
	func act(player, ai):
		print("attacking")
		target.get_node('AI').take_damage(ai.power)

#Pickup a given item and equip/hold it
class Pickup:
	extends Action
	var item
	func _init(_item).(2):
		item = _item
	func act(player, ai):
		print("picking item up")
		var item_info = item.get_node("info")
		if item_info.type == ITEM_TYPE.WEAPON:
			#Drop previously equipped weapon, if it exists
			if ai.weapon_equipped:
				ai.drop_weapon()
			ai.weapon_equipped = item
			ai.power = item_info.power
			ai.create_new_range = item_info.range_radius
		item.get_parent().remove_child(item) #Remove item from the map

#OBJECTIVES

#Moves randomly and if possible, tries to attack nearby players
class Move_Random_And_Attack:
	extends Objective
	var dir
	func _init():
		dir = DIRS.RIGHT+DIRS.DOWN
	func think_action(player, ai):
		#First tries to pickup nearby objects
		if ai.nearby_items.size() > 0 and ai.on_cooldown <= 0:
			var random_body = ai.nearby_items[randi()%ai.nearby_items.size()]
			return Pickup.new(random_body)
			
		#Attack nearby bodies if possible
		if ai.nearby_bodies.size() > 0 and ai.on_cooldown <= 0:
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

signal died(player)

func _ready():
	randomize()
	set_fixed_process(true)
	player_node = get_parent()
	player_info = player_node.get_node("player_info")
	
	#Setup lifebar
	var lifebar = player_info.get_node('lifebar')
	lifebar.set_max(max_life)
	lifebar.set_value(max_life)
	
func _fixed_process(delta):
	#If player doesn't have a range_area, create an unarmed range area
	if not player_node.get_node('range_area'):
		create_new_range(default_unarmed_range)
	
	#Keep player on the map
	limit_movement()
	
	#Update cooldown
	self.on_cooldown = max(self.on_cooldown-delta, 0)
	
	#Make one action of the current objective
	var action = cur_objective.think_action(player_node, self)
	action.act(player_node, self)
	self.on_cooldown += action.cooldown

#Limit player position to the map. TODO: change to map boundaries
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

	#Remove previously range_area
	var old_range_area = player_node.get_node('range_area')
	if old_range_area:
		player_node.remove_child(old_range_area)
		yield(old_range_area, 'removed_from_tree')
	
	self.nearby_bodies.clear() #Clear nearby players
	
	#Create new range_area
	var area = RANGE_AREA.instance()
	area.set_radius(r)
	area.set_pos(Vector2(0,0))
	player_node.add_child(area) #Add new area_range
	area.connect("body_enter", self, "enter_neighbor")
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

#Add an item to nearby_items array
#Called when a new item enters the player item_area
func enter_item(body):
	if body extends KinematicBody2D:
		print("entered item")
		nearby_items.append(body) #For now only adds, but needs to check the body type

#Removes a item from nearby_bodies array
#Called when a body leaves the player range_area
func leave_item(body):
	if body extends KinematicBody2D:
		var count = 0
		for item in nearby_items:
			if item == body:
				print("leaving item")
				nearby_items.remove(count) #For now only removes, but needs to check the body type
			count += 1

#Make player take 'd' damage and checks for death
func take_damage(d):
	var old_damage_taken = self.damage_taken
	self.damage_taken += d
	
	#Update lifebar with tween
	var tween = player_info.get_node('lifebar/change_life_tween')
	tween.interpolate_property(player_info.get_node('lifebar'), "range/value", old_damage_taken, (max(0,max_life - damage_taken)), .1, Tween.TRANS_LINEAR, Tween.EASE_IN_OUT)
	tween.start()
	
	if self.damage_taken >= self.max_life:
		self.kill()

#Make player heal 'd' damage 
func heal(d):
	var old_damage_taken = self.damage_taken
	self.damage_taken = max(self.damage_taken - d, 0)
	
	#Update lifebar with tween
	var tween = player_info.get_node('lifebar/change_life_tween')
	tween.interpolate_property(player_info.get_node('lifebar'), "range/value", old_damage_taken, (max(0,max_life - damage_taken)), .1, Tween.TRANS_LINEAR, Tween.EASE_IN_OUT)
	tween.start()
	
	if self.damage_taken >= self.max_life:
		self.kill()

#Make player drop current weapon
func drop_weapon():
	if not self.weapon_equipped:
		return
	
	#Set default values for power and range
	self.weapon_equipped = null
	self.power = self.default_unarmed_power
	self.create_new_range(default_unarmed_range)

#Handle player death
func kill():
	player_node.queue_free()
	emit_signal("died", self)

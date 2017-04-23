extends Node

const DIRS = preload("res://definitions/directions.gd")
const ITEM_TYPE = preload("res://definitions/item_enums.gd")
const SCORE = preload("res://definitions/score.gd")
const RANGE_AREA = preload("res://objects/player/range_area.tscn")
const PATCH = preload("res://objects/item/patch.tex")

var player_node #Reference to the player
var player_info #Reference to player info panel
var map_node #Reference to the game map (map sets when creating the player)
onready var audience_bar = get_node('../../../../HUD/AudienceBar')

var default_unarmed_range = 40 + 10*randf() #Ranged of "unarmed weapon"
var default_unarmed_power = 5 + randf()*3   #Power of "unarmed weapon"
var default_unarmed_defense = randf()*3   #Defense of "unarmed weapon"

var max_life = 30 #Player maxlife
var damage_taken = 0 #Damage taken by player
var name = "dummy" #Name of player
var afiliation = randi()%2 #Number of afiliation
var power = default_unarmed_power #Damage player inflicts when attacking
var defense = default_unarmed_defense #Damage armor from player blocks from attacks
var weapon_equipped #Weapon player is holding
var armor_equipped #Armor player is holding
var consumable_holding #Consumable item player is holding

var nearby_bodies = [] #Number of players or monsters inside this player range_area
var nearby_items = [] #Number of items inside this player item_area
var on_cooldown = 0 #Seconds the player can't make any action besides walking

var fans = 10 + int(90 * randf())
var haters = 110 - fans

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
		player.push(dir)

#Attacks a target with player damage
class Attack:
	extends Action
	var target
	var attacker
	func _init(_attacker, _target).(3):
		target = _target
		attacker = _attacker
		attacker.fans = max(0, attacker.fans + target.get_node('AI').haters/50)
		attacker.haters = max(0, attacker.haters + target.get_node('AI').fans/50)
	func act(player, ai):
		target.get_node('AI').take_damage(attacker, ai.power)

#Pickup a given item and equip/hold it
class Pickup:
	extends Action
	var item
	func _init(_item).(1):
		item = _item
	func act(player, ai):
		var item_info = item.get_node("Info")
		if item_info.type == ITEM_TYPE.WEAPON:
			#Drop previously equipped weapon, if it exists
			ai.drop_weapon()
			
			ai.weapon_equipped = item
			ai.power = item_info.power
			ai.create_new_range(item_info.range_radius)
			
			#Update player info weapon image
			ai.player_info.get_node("weapon").set_texture(item.get_node("Sprite").get_texture())
		if item_info.type == ITEM_TYPE.ARMOR:
			#Drop previously equipped armor, if it exists
			ai.drop_armor()
			
			ai.armor_equipped = item
			ai.defense = item_info.defense
			
			#Update player info armor image
			ai.player_info.get_node("armor").set_texture(item.get_node("Sprite").get_texture())
		elif item_info.type == ITEM_TYPE.CONSUMABLE:
			#Drop previously consumable its holding, if it exists
			ai.drop_consumable()
			
			ai.consumable_holding = item
			
			#Update player info consumable image
			ai.player_info.get_node("consumable").set_texture(item.get_node("Sprite").get_texture())
			
		item.get_parent().remove_child(item) #Remove item from the map

#Activate item player is holding
class Activate:
	extends Action

	func _init().(2):
		pass
	func act(player, ai):
		ai.consumable_holding.get_node("Info").activate(player, ai)

#USEFUL OBJECTIVE FUNCTIONS

#Action Stuff#

#Picks a nearby item if possible
func tries_to_pickup_nearby_items(ai):
	if ai.nearby_items.size() > 0 and ai.on_cooldown <= 0:
		var random_body = ai.nearby_items[randi()%ai.nearby_items.size()]
		audience_bar.item_pickup(self)
		return Pickup.new(random_body)
		
#Attack a random nearby body if possible
func tries_to_attack_nearby_bodies(ai):
	if ai.nearby_bodies.size() > 0 and ai.on_cooldown <= 0:
		var random_body = ai.nearby_bodies[randi()%ai.nearby_bodies.size()]
		audience_bar.attack(self)
		return Attack.new(self, random_body)

#Player heals itself if it has <= 'hp' of health left and has a healthpack
func tries_to_heal_if_dying(ai, hp):
	if ai.max_life - ai.damage_taken <= hp and ai.consumable_holding and ai.consumable_holding.get_node("Info").name == "med_kit" and ai.on_cooldown <= 0:
		return Activate.new()

#Movement Stuff#

#Returns a random normalized direction
func random_direction():
	var dir = Vector2(randf()*2 - 1,randf()*2 - 1)
	return dir.normalized()

#Given an initial positial, gives direction to target position
func direction_to_pos(ini, target):
	var dir = Vector2(target.x-ini.x, target.y-ini.y)
	return dir.normalized()

#Returns the direction to the closest player from a given player p. If there isn't, returns a random dir.
func direction_to_closest_player(p):
	var clos_p = map_node.closest_player(p.get_pos(), [p])
	if clos_p:
		return direction_to_pos(p.get_pos(), clos_p.get_pos())
	else:
		return random_direction()

#Searches for an item name on the map, and returns the direction to closest one if exists, given player p as start position.
func direction_to_item(item_name, p):
	var clos_p = map_node.closest_player(p.get_pos(), [p])
	if clos_p:
		return direction_to_pos(p.get_pos(), clos_p.get_pos())
	else:
		return random_direction()

#OBJECTIVES

#Moves randomly and if possible, tries to attack nearby players
class Default:
	extends Objective

	func _init():
		pass
	func think_action(player, ai):
		var action
		
		action = ai.tries_to_heal_if_dying(ai, ai.max_life - 1)
		if action:
			return action
		
		action = ai.tries_to_attack_nearby_bodies(ai)
		if action:
			return action
			
		action = ai.tries_to_pickup_nearby_items(ai)
		if action:
			return action
		
		var move
		if ai.on_cooldown <= 0:
			move = Move.new(ai.direction_to_closest_player(player))
		else:
			move = Move.new(-1*ai.direction_to_closest_player(player))
		
		var wallforce = (player.get_pos() - ai.map_node.get_closest_wall(player.get_pos()))
		wallforce /= wallforce.length()
		move.dir += wallforce
		move.dir = move.dir.normalized()
		
		return move

var cur_objective = Default.new()

signal died(player)

func _ready():
	randomize()
	set_fixed_process(true)
	player_node = get_parent()
	player_info = player_node.get_node("CanvasLayer").get_node("player_info")
	
	#Setup lifebar
	var lifebar = player_info.get_node('lifebar')
	lifebar.set_max(max_life)
	lifebar.set_value(max_life)
	
	#Setup Player Info
	player_info.get_node("name").set_text(self.name)
	
func _fixed_process(delta):
	#If player doesn't have a range_area, create an unarmed range area
	if not player_node.get_node('range_area'):
		create_new_range(default_unarmed_range)
	
	#Update cooldown
	self.on_cooldown = max(self.on_cooldown-delta, 0)
	
	#Make one action of the current objective
	var action = cur_objective.think_action(player_node, self)
	action.act(player_node, self)
	self.on_cooldown += action.cooldown
	
	#Fixes player info painel position
	var pos = player_node.get_pos()
	player_node.get_node("CanvasLayer").set_offset(pos)
	
	#player_info.get_node("health_text").set_text(var2str(player_info.get_node("lifebar").get_value()))
	
	#Checks for player health every frame
	if self.damage_taken >= self.max_life:
		self.kill()

#Creates a new range_area with radius 'r'. Removes previously range_area
func create_new_range(r):

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
func take_damage(attacker, d):
	var old_damage_taken = self.damage_taken
	d = max(0, d - self.defense)
	if d <= 0:
		return
	d = ceil(d)
	self.damage_taken += d
	
	#Update lifebar with tween
	var tween = player_info.get_node('lifebar/change_life_tween')
	tween.interpolate_property(player_info.get_node('lifebar'), "range/value", self.max_life - old_damage_taken, (max(0,max_life - damage_taken)), .1, Tween.TRANS_CUBIC, Tween.EASE_IN_OUT)
	tween.start()
	
	if self.damage_taken >= self.max_life:
		attacker.fans = max(0, attacker.fans + self.haters/30)
		attacker.haters = max(0, attacker.fans + self.fans/20)
		self.kill()

#Heal player
func heal(h):
	var old_damage_taken = self.damage_taken
	audience_bar.use_item(self)
	h = ceil(h)
	self.damage_taken = max(0, self.damage_taken - h)
	#Update lifebar with tween
	var tween = player_info.get_node('lifebar/change_life_tween')
	tween.interpolate_property(player_info.get_node('lifebar'), "range/value", (max_life-old_damage_taken), \
								max_life - damage_taken, .1, Tween.TRANS_CUBIC, Tween.EASE_IN_OUT)
	tween.start()

#Make player drop current weapon
func drop_weapon():
	if not self.weapon_equipped:
		return
	
	#Set default values for power and range
	self.weapon_equipped = null
	self.power = self.default_unarmed_power
	self.create_new_range(default_unarmed_range)
	
	#Update player info weapon image
	self.player_info.get_node("weapon").set_texture(PATCH)
	
#Make player drop current armor
func drop_armor():
	if not self.armor_equipped:
		return
	
	#Set default values for power and range
	self.armor_equipped = null
	self.defense = self.default_unarmed_defense
	
	#Update player info armor image
	self.player_info.get_node("armor").set_texture(PATCH)

#Make player drop current consumable
func drop_consumable():
	if not self.consumable_holding:
		return
	
	self.consumable_holding = null

	#Update player info consumable image
	self.player_info.get_node("consumable").set_texture(PATCH)

#Handle player death
func kill():
	player_node.queue_free()
	audience_bar.death(self)
	emit_signal("died", self)

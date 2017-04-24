
extends KinematicBody2D

const DIR = preload("res://definitions/directions.gd")
const CONST = preload("res://definitions/constants.gd")

const ACC = 8
const DEACC = 0.75
const SPEEDLIMIT = ACC * 5

signal speed_changed(speed)

var speed = Vector2()

onready var animation = get_node("Sprite/Animation")
onready var sprite = get_node('Sprite')

func _ready():
  set_fixed_process(true)
  var color = Color(randf(), randf(), randf())
  sprite.get_material().set_shader_param("col", color)
  print(color)

func _fixed_process(delta):
    pvt_apply_speed(delta)
    pvt_apply_speedlimit(delta)
    emit_signal("speed_changed", speed)

func push_dir(dir):
    push(DIR.dir2vec(dir))

func push(dir_vec):
    self.speed += dir_vec * ACC
    emit_signal("speed_changed", speed)

func pvt_apply_speed(delta):
  var motion_scale = self.speed * delta
  var motion = move(motion_scale)
  if is_colliding():
    var collider = get_collider()
    var normal = get_collision_normal()
    motion = normal.slide(motion)
    self.speed = normal.slide(self.speed)
    move(motion)

func pvt_apply_speedlimit(delta):
  self.speed *= DEACC
  if self.speed.length_squared() <= CONST.EPSILON*CONST.EPSILON:
    self.speed.x = 0
    self.speed.y = 0

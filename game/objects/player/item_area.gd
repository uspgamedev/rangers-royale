extends Area2D

#Area around player that can detect items, and pick them

func _ready():
	set_radius(10)
	
#Change radius of item_area
func set_radius(r):
	#Change radius of collision shape
	get_node('circle').get_shape().set_radius(r)


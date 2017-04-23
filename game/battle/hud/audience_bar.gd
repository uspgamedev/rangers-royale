extends ProgressBar

onready var players = get_node('../../Map/Players')
var enjoyment = 0
var amount
var end = false

func _ready():
	change_enjoyment(70)
	set_fixed_process(true)

func _fixed_process(delta):
	check_status(delta)
	if (players.get_child_count() <= 2 and !end):
		player_win(players.get_child(1).get_node('AI'))
		end = true

func check_status(delta):
	change_enjoyment(-delta)

func attack(attacker):
	amount = float(attacker.fans)/400
	print("attack ", amount)
	change_enjoyment(amount)

func death(player):
	amount = float(player.haters - player.fans)/5
	print("death ", amount)
	change_enjoyment(amount)

func player_win(winner):
	amount = float(winner.fans - winner.haters)
	print(winner.fans)
	print(winner.haters)
	print(winner.name, " ", amount)
	change_enjoyment(amount)

func item_pickup(player):
	amount = float(player.fans)/600
	print("pickup ", amount)
	change_enjoyment(amount)

func use_item(player):
	amount = float(player.fans*2 - player.haters)/800
	print("use item ", amount)
	change_enjoyment(amount)

func change_enjoyment(amount):
	var tween = get_node('ChangeStatus')
	tween.interpolate_property(self, "range/value", enjoyment, min(100, enjoyment + amount), .1, Tween.TRANS_LINEAR, Tween.EASE_IN_OUT)
	tween.start()
	enjoyment = min(100, enjoyment + amount)
	if (enjoyment <= 0):
		lose()

func lose():
	#print('you failed to amuse the crowd')
	pass

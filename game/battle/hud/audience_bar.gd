extends ProgressBar

var enjoyment = 0
var amount

func _ready():
	change_enjoyment(70)
	set_fixed_process(true)

func _fixed_process(delta):
	check_status(delta)

func check_status(delta):
	#check_player_win(player_amount)
	#check_catastrophe()
	change_enjoyment(-delta)

func attack(attacker):
	amount = float(attacker.fans)/400
	#print("attack ", amount)
	change_enjoyment(amount)

func death(player):
	amount = float(player.haters*2.5 - player.fans)/50
	#print("death ", amount)
	change_enjoyment(amount)

func item_pickup(player):
	amount = float(player.fans)/600
	#print("pickup ", amount)
	change_enjoyment(amount)

func use_item(player):
	pass
	#amount = float(player.fans - player.max_life - player.haters/3)
	#print("use item ", amount)
	#change_enjoyment(amount)

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

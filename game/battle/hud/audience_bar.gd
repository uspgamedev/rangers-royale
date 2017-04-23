extends ProgressBar

onready var players = get_node('../../Map/Players')
var enjoyment = 0
var amount
var end = false

onready var hoes = get_node("Hoes")
onready var cheering = get_node("Cheering")

signal epic_fail
signal intense

func _ready():
	change_enjoyment(70)
	yield(get_tree(), "fixed_frame")
	yield(get_tree(), "fixed_frame")
	yield(get_tree(), "fixed_frame")
	set_fixed_process(true)

func _fixed_process(delta):
	check_status(delta)
	if (players.get_child_count() <= 1 and !end):
		if (players.get_child_count() <= 0 and !end):
			catastrophe()
		else:
			player_win(players.get_child(get_child_count() - 1).get_node('AI'))
		end = true

func catastrophe():
	#print("CATASTROPHE")
	change_enjoyment(-50)

func check_status(delta):
	change_enjoyment(-delta)

func attack(attacker):
	amount = float(attacker.fans)/400
	#print("attack ", amount)
	change_enjoyment(amount)

func death(player):
	amount = float(player.haters - player.fans)/5
	#print("death ", amount)
	change_enjoyment(amount)

func player_win(winner):
	amount = float(winner.fans - winner.haters)/2
	#print('player win', amount)
	change_enjoyment(amount)

func item_pickup(player):
	amount = float(player.fans)/600
	#print("pickup ", amount)
	change_enjoyment(amount)

func use_item(player):
	amount = float(player.fans*2 - player.haters)/800
	#print("use item ", amount)
	change_enjoyment(amount)

func change_enjoyment(amount):
	var tween = get_node('ChangeStatus')
	tween.interpolate_property(self, "range/value", enjoyment, min(100, enjoyment + amount), .1, Tween.TRANS_LINEAR, Tween.EASE_IN_OUT)
	tween.start()
	var old = enjoyment
	enjoyment = min(100, enjoyment + amount)
	if (enjoyment <= 0 and !end):
		lose()
		end = true
	elif enjoyment > 80:
		emit_signal("intense")
	if (amount >= 10 or (old < 70 and enjoyment >= 70)) and not (cheering.is_playing() or hoes.is_playing()):
		cheering.play()
	if (amount <= -10 or (old > 30 and enjoyment <= 30)) and not (cheering.is_playing() or hoes.is_playing()):
		hoes.play()

func lose():
	emit_signal("epic_fail")
	print('you failed to entertain the crowd')

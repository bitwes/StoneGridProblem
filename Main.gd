extends Node2D
# ------------------------------------------------------------------------------
# You are given a 0-indexed, 2D integer matrix grid of 3 * 3, representing the
# number of stones in each cell. The grid contains exactly 9 stones, and there
# are multiple stones in a single cell.
#
# In one move, you can move a single stone from its current cell to any other
# cell if the two cells share a side.
#
# Return the minimum number of moves required to place one stone in each cell.
# ------------------------------------------------------------------------------

var StoneGridScene = load("res://stone_grid.tscn")

var three_x_three = {

	diag_three = [
		[3, 0, 0],
		[0, 3, 0],
		[0, 0, 3]
	],
	nine_center = [
		[0, 0, 0],
		[0, 9, 0],
		[0, 0, 0]
	],
	three_center_line = [
		[0, 3, 0],
		[0, 3, 0],
		[0, 3, 0]
	],
	harder = [
		[5, 0, 0],
		[0, 2, 0],
		[2, 0, 0]
	],
	harder_inverse = [
		[0, 0, 2],
		[0, 2, 0],
		[0, 0, 5]
	],
	tl = [
		[9, 0, 0],
		[0, 0, 0],
		[0, 0, 0]
	],
	br = [
		[0, 0, 0],
		[0, 0, 0],
		[0, 0, 9]
	],

}


var ten_x_ten = {
	ten_center = [
		[0, 0, 0, 0, 0, 10, 0, 0, 0, 0],
		[0, 0, 0, 0, 0, 10, 0, 0, 0, 0],
		[0, 0, 0, 0, 0, 10, 0, 0, 0, 0],
		[0, 0, 0, 0, 0, 10, 0, 0, 0, 0],
		[0, 0, 0, 0, 0, 10, 0, 0, 0, 0],
		[0, 0, 0, 0, 0, 10, 0, 0, 0, 0],
		[0, 0, 0, 0, 0, 10, 0, 0, 0, 0],
		[0, 0, 0, 0, 0, 10, 0, 0, 0, 0],
		[0, 0, 0, 0, 0, 10, 0, 0, 0, 0],
		[0, 0, 0, 0, 0, 10, 0, 0, 0, 0],
	],
	hundred_center = [
		[0, 0, 0, 0, 0, 0, 0, 0, 0, 0],
		[0, 0, 0, 0, 0, 0, 0, 0, 0, 0],
		[0, 0, 0, 0, 0, 0, 0, 0, 0, 0],
		[0, 0, 0, 0, 0, 0, 0, 0, 0, 0],
		[0, 0, 0, 0, 0, 100, 0, 0, 0, 0],
		[0, 0, 0, 0, 0, 0, 0, 0, 0, 0],
		[0, 0, 0, 0, 0, 0, 0, 0, 0, 0],
		[0, 0, 0, 0, 0, 0, 0, 0, 0, 0],
		[0, 0, 0, 0, 0, 0, 0, 0, 0, 0],
		[0, 0, 0, 0, 0, 0, 0, 0, 0, 0],
	],
	various_tens = [
		[0, 0, 0, 0, 0, 0, 0, 0, 0, 10],
		[0, 0, 10, 0, 0, 0, 0, 0, 0, 0],
		[0, 0, 0, 0, 0, 0, 0, 0, 10, 0],
		[10, 0, 0, 0, 0, 0, 0, 0, 0, 0],
		[0, 0, 0, 0, 0, 0, 10, 0, 0, 0],
		[0, 0, 0, 10, 0, 0, 0, 0, 0, 0],
		[0, 0, 0, 0, 0, 0, 0, 0, 0, 10],
		[0, 0, 0, 0, 10, 0, 0, 0, 0, 0],
		[0, 0, 0, 10, 0, 0, 0, 0, 0, 0],
		[0, 0, 0, 0, 0, 0, 0, 0, 10, 0],
	],
	various_tens_two = [
		[10,0,0,0,0,10,0,0,0,10,],
		[0,0,0,0,0,0,0,0,0,0,],
		[0,0,0,0,0,10,0,0,0,0,],
		[0,0,0,0,0,0,0,0,0,0,],
		[0,0,0,0,0,10,0,0,0,0,],
		[0,0,0,0,0,10,0,0,0,0,],
		[0,0,0,0,0,0,0,0,0,0,],
		[0,0,0,0,0,10,0,0,0,0,],
		[0,0,0,0,0,0,0,0,0,0,],
		[10,0,0,0,0,10,0,0,0,10,],
	],
	corners = [
		[25, 0, 0, 0, 0, 0, 0, 0, 0, 25],
		[0, 0, 0, 0, 0, 0, 0, 0, 0, 0],
		[0, 0, 0, 0, 0, 0, 0, 0, 0, 0],
		[0, 0, 0, 0, 0, 0, 0, 0, 0, 0],
		[0, 0, 0, 0, 0, 0, 0, 0, 0, 0],
		[0, 0, 0, 0, 0, 0, 0, 0, 0, 0],
		[0, 0, 0, 0, 0, 0, 0, 0, 0, 0],
		[0, 0, 0, 0, 0, 0, 0, 0, 0, 0],
		[0, 0, 0, 0, 0, 0, 0, 0, 0, 0],
		[25, 0, 0, 0, 0, 0, 0, 0, 0, 25],
	],
	tl = [
		[100, 0, 0, 0, 0, 0, 0, 0, 0, 0],
		[0, 0, 0, 0, 0, 0, 0, 0, 0, 0],
		[0, 0, 0, 0, 0, 0, 0, 0, 0, 0],
		[0, 0, 0, 0, 0, 0, 0, 0, 0, 0],
		[0, 0, 0, 0, 0, 0, 0, 0, 0, 0],
		[0, 0, 0, 0, 0, 0, 0, 0, 0, 0],
		[0, 0, 0, 0, 0, 0, 0, 0, 0, 0],
		[0, 0, 0, 0, 0, 0, 0, 0, 0, 0],
		[0, 0, 0, 0, 0, 0, 0, 0, 0, 0],
		[0, 0, 0, 0, 0, 0, 0, 0, 0, 0],
	],
	br = [
		[0, 0, 0, 0, 0, 0, 0, 0, 0, 0],
		[0, 0, 0, 0, 0, 0, 0, 0, 0, 0],
		[0, 0, 0, 0, 0, 0, 0, 0, 0, 0],
		[0, 0, 0, 0, 0, 0, 0, 0, 0, 0],
		[0, 0, 0, 0, 0, 0, 0, 0, 0, 0],
		[0, 0, 0, 0, 0, 0, 0, 0, 0, 0],
		[0, 0, 0, 0, 0, 0, 0, 0, 0, 0],
		[0, 0, 0, 0, 0, 0, 0, 0, 0, 0],
		[0, 0, 0, 0, 0, 0, 0, 0, 0, 0],
		[0, 0, 0, 0, 0, 0, 0, 0, 0, 100],
	]
}
@onready var _ctrls = {
	buttons_vbox = $Controls/Layout/Buttons,
	stone_arrangements = $Controls/Layout/Buttons/StoneArrangements,
	time = $Controls/Layout/Time,
	delay = $Controls/Layout/Buttons/Delay
}

var _stone_grid : StoneGrid = null
var _running = false
var _start_time = 0.0

var solver = Solvers.PushTillWeGetThere.new()

func _ready():
	var bg = ButtonGroup.new()
	for btn in $Controls/Layout/Buttons/Solvers.get_children():
		btn.button_group = bg
	
	_create_grid_all_at_center(20)
	#_create_stone_grid(3, three_x_three)
	#_create_stone_grid(10, ten_x_ten)


func _create_grid_all_at_center(s):
	_create_stone_grid(s, {})
	var btn = _stone_grid.get_button_at(Vector2(s/2, s/2))
	btn.stones = s * s


func _create_stone_grid(size : int, arrangements : Dictionary):
	if(_stone_grid != null):
		_stone_grid.queue_free()

	_stone_grid = StoneGridScene.instantiate()
	add_child(_stone_grid)
	_stone_grid.position = Vector2(300, 10)
	_stone_grid.custom_minimum_size = Vector2(800, 600)

	_stone_grid.set_grid_size(size)
	_make_populate_buttons(arrangements)
	if(arrangements.keys().size() > 0):
		_stone_grid.populate(arrangements[arrangements.keys()[0]])


func _make_populate_buttons(arrangements):
	for child in _ctrls.stone_arrangements.get_children():
		child.free()

	for key in arrangements:
		var btn = Button.new()
		btn.text = key
		_ctrls.stone_arrangements.add_child(btn)
		btn.pressed.connect(func():  _stone_grid.populate(arrangements[key]))

func _update_time():
	var t = (Time.get_ticks_msec() - _start_time) / 1000.0
	_ctrls.time.text = str("%.3f" % t, 's')


func _process(__delta):
	if(_running):
		_update_time()


func solve():
	_stone_grid.save_layout()
	_start_time = Time.get_ticks_msec()
	_running = true
	_stone_grid.wait_time = _ctrls.delay.value
	_ctrls.buttons_vbox.visible = false
	await solver.solve(_stone_grid)
	_ctrls.buttons_vbox.visible = true
	_stone_grid.wait_time = 0
	_running = false
	_update_time()
	print('Time = ', _ctrls.time.text)


func _on_solve_pressed():
	solve()


func _on_diag_threes_pressed():
	_stone_grid.populate(three_x_three.diag_three)


func _on_center_nine_pressed():
	_stone_grid.populate(three_x_three.nine_center)


func _on_center_line_three_pressed():
	_stone_grid.populate(three_x_three.three_center_line)


func _on_harder_pressed():
	_stone_grid.populate(three_x_three.harder)


func _on_harder_inverse_pressed():
	_stone_grid.populate(three_x_three.harder_inverse)


func _on_three_x_three_pressed():
	_create_stone_grid(3, three_x_three)


func _on_ten_x_ten_pressed():
	_create_stone_grid(10, ten_x_ten)


func _on_reset_pressed():
	_stone_grid.reset()


func _on_this_one_pressed():
	solver = Solvers.ThisOne.new()


func _on_push_until_pressed():
	solver = Solvers.PushTillWeGetThere.new()

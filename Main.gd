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
	]
}
@onready var _ctrls = {
	stone_arrangements = $Controls/Layout/StoneArrangements
}

var _stone_grid : StoneGrid = null

func _ready():
	_create_stone_grid(3, three_x_three)
	#_create_stone_grid(10, ten_x_ten)

func _create_stone_grid(size, arrangements):
	if(_stone_grid != null):
		_stone_grid.queue_free()

	_stone_grid = StoneGridScene.instantiate()
	add_child(_stone_grid)
	_stone_grid.position = Vector2(300, 100)
	_stone_grid.custom_minimum_size = Vector2(460, 350)
	
	_stone_grid.set_grid_size(size)
	_make_populate_buttons(arrangements)


func _make_populate_buttons(arrangements):
	for child in _ctrls.stone_arrangements.get_children():
		child.free()
		
	for key in arrangements:
		var btn = Button.new()
		btn.text = key
		_ctrls.stone_arrangements.add_child(btn)
		btn.pressed.connect(func():  _stone_grid.populate(arrangements[key]))
		
	

func solve():
	_stone_grid.wait_time = $Controls/Layout/Delay.value
	$Controls.visible = false
	var solver = Solvers.ThisOne.new()
	await solver.solve(_stone_grid)
	$Controls.visible = true
	_stone_grid.wait_time = 0


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

class_name StoneGridPlayer


var _manual_solver = Solvers.BaseSolver.new()
var _from : StoneButton = null


var stone_grid : StoneGrid = null :
	set(val):
		stone_grid = val
		_manual_solver._grid = stone_grid
		val.stone_pressed.connect(_on_stone_button_pressed)
		val.stone_button_gui_input.connect(_on_stone_button_gui_input)
		_from = null


func _init():
	pass


func _on_stone_button_gui_input(which : StoneButton, event : InputEvent):
	pass


func _on_stone_button_pressed(which : StoneButton):
	if(_from == null):
		_from = which
	elif(_from == which and which.get_stone_count() > 1):
		_from.button_pressed = false
		_from = null
	elif(_from != null and which.get_stone_count() == 0):
		_manual_solver.push_and_fill_until_there(_from.grid_pos, which)
		which.button_pressed = false
		which.release_focus()
		_from.grab_focus()
		_from.button_pressed = true
	elif(_from != which and which.get_stone_count() > 1):
		_from.button_pressed = false
		_from.release_focus()
		_from = which
		_from.grab_focus()
	else:
		which.button_pressed = false
		which.release_focus()

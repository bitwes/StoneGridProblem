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


@onready var _ctrls = {
	c1_buttons_vbox = $Layout/Controls/Layout/Buttons,
	c2_buttons_vbox = $Layout/Controls2/Layout/Buttons,
	stone_arrangements = $Layout/Controls/Layout/Buttons/StoneArrangements,

	time = $Layout/Controls2/Layout/Time,
	delay = $Layout/Controls2/Layout/Buttons/Delay,
	orig_stone_grid = $Layout/CenterBox/StoneGrid,
	stop = $Layout/Controls2/Layout/Stop,
	moves = $Layout/Controls2/Layout/Buttons/Stats/Moves,
	checks = $Layout/Controls2/Layout/Buttons/Stats/Checks,
	passes = $Layout/Controls2/Layout/Buttons/Stats/Passes,
	solver_buttons = $Layout/Controls2/Layout/Buttons/Solvers,
	resume = $Layout/Controls2/Layout/Resume,

	undo_slider = $Layout/CenterBox/UndoSlider,
}

var _stone_grid : StoneGrid = null
var _running = false
var _start_time = 0.0
var _player : StoneGridPlayer = StoneGridPlayer.new()


var solver = Solvers.BestIdea.new() :
	get: return solver
	set(val):
		solver = val
		solver.paused.connect(_on_solver_paused)


func _ready():
	_ctrls.resume.visible = false
	_ctrls.orig_stone_grid.visible = false
	_stone_grid = _ctrls.orig_stone_grid
	_ctrls.stop.visible = false

	_group_buttons($Layout/Controls2/Layout/Buttons/Solvers.get_children())
	_group_buttons($Layout/Controls/Layout/Buttons/Layouts.get_children())

	for entry in Solvers.TheListOfSolvers:
		_add_solver_button(entry[0], entry[1])
	_group_buttons(_ctrls.solver_buttons.get_children())

	_create_stone_grid(3, Layouts.three_x_three)

	$Layout.set_deferred('size', get_viewport_rect().size)


func _process(__delta):
	if(_running):
		_update_time()

# ------------------------
# Private
# ------------------------
func _group_buttons(buttons):
	var first = true
	var bg = ButtonGroup.new()
	for btn in buttons:
		btn.toggle_mode = true
		btn.button_group = bg
		if(first):
			btn.button_pressed = true
			btn.pressed.emit()
			first = false
		else:
			btn.button_pressed = false
	return bg


func _create_grid_all_at_center(s):
	_create_stone_grid(s, {})
	var btn = _stone_grid.get_button_at(Vector2(s/2, s/2))
	btn.set_stone_count(s * s)


func _create_stone_grid(size : int, arrangements : Dictionary):
	if(_stone_grid != null  and _stone_grid != _ctrls.orig_stone_grid):
		_stone_grid.queue_free()

	_stone_grid = StoneGridScene.instantiate()
	_stone_grid.size_flags_vertical = Control.SIZE_EXPAND_FILL
	_stone_grid.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	$Layout/CenterBox.add_child(_stone_grid)
	$Layout/CenterBox.move_child(_stone_grid, 0)
	_stone_grid.undoer.slider = _ctrls.undo_slider
	_stone_grid.position = _ctrls.orig_stone_grid.position
	_stone_grid.size = _ctrls.orig_stone_grid.size

	_stone_grid.set_grid_size(size)
	_make_populate_buttons(arrangements)
	if(arrangements.keys().size() > 0):
		_stone_grid.populate(arrangements[arrangements.keys()[0]])
	_player.stone_grid = _stone_grid


func _make_populate_buttons(arrangements):
	for child in _ctrls.stone_arrangements.get_children():
		child.free()

	var g = ButtonGroup.new()
	var first = true
	for key in arrangements:
		var btn = Button.new()
		btn.text = key
		btn.toggle_mode = true
		btn.button_group = g
		_ctrls.stone_arrangements.add_child(btn)

		btn.pressed.connect(func():
			_stone_grid.populate(arrangements[key])
		)
		if(first):
			btn.button_pressed = true
			btn.pressed.emit()
			first = false
		else:
			btn.button_pressed = false


func _add_solver_button(text, solver_class):
	var btn = Button.new()
	btn.text = text
	btn.pressed.connect(_on_solver_button_pressed.bind(solver_class))
	_ctrls.solver_buttons.add_child(btn)


func _update_time():
	var t = (Time.get_ticks_msec() - _start_time) / 1000.0
	_ctrls.time.text = str("%.3f" % t, 's')


func _run_mode(is_it):
	_running = is_it
	_ctrls.stop.visible = is_it
	_running = is_it
	_ctrls.c1_buttons_vbox.visible = !is_it
	_ctrls.c2_buttons_vbox.visible = !is_it


# ------------------------
# Events
# ------------------------
func _on_solve_pressed():
	solve()


func _on_three_x_three_pressed():
	_create_stone_grid(3, Layouts.three_x_three)


func _on_seven_x_seven_pressed():
	_create_stone_grid(7, Layouts.seven_x_seven)


func _on_ten_x_ten_pressed():
	_create_stone_grid(10, Layouts.ten_x_ten)


func _on_fifteen_x_fifteen_pressed():
	_create_stone_grid(15, Layouts.fifteen_x_fifteen)


func _on_reset_pressed():
	_stone_grid.reset()
	_stone_grid.reload_layout()


func _on_solver_button_pressed(solver_class):
	solver = solver_class.new()


func _on_stop_pressed():
	solver.stop()


var _pause_object = null
func _on_solver_paused(po):
	_pause_object = po
	_ctrls.resume.visible = true


func _on_resume_pressed():
	_ctrls.resume.visible = false
	_emit_resume.call_deferred()


func _emit_resume():
	_pause_object.resume.emit()


# ------------------------
# Public
# ------------------------
func solve():
	_ctrls.undo_slider.editable = false
	if(_stone_grid.is_solved()):
		_stone_grid.reload_layout()

	_stone_grid.save_layout()
	_stone_grid.reset()
	_stone_grid.wait_time = _ctrls.delay.value
	set_process(false)
	_run_mode(true)
	_ctrls.time.text = '0.0'
	await get_tree().create_timer(.25).timeout
	_start_time = Time.get_ticks_msec()
	set_process(true)
	await solver.solve(_stone_grid)
	_run_mode(false)

	_stone_grid.wait_time = 0
	_update_time()

	_ctrls.moves.text = str('Moves:  ', _stone_grid.moves)
	_ctrls.checks.text = str('Checks:  ', _stone_grid.get_check_count())
	_ctrls.passes.text = str('Passes:  ', solver.passes)
	_ctrls.undo_slider.editable = true
	#_stone_grid.show_change_counts()

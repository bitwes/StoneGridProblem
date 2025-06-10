class_name StoneGrid
extends Control

class Undo:
	var moves = []
	var _stone_grid = null
	var _cur_index = 0
	var _ignore_slider = false
	var slider : HSlider = null :
		get: return slider
		set(val):
			slider = val
			slider.value_changed.connect(_on_slider_value_changed)
			_update_slider()

	func _init(stone_grid):
		_stone_grid = stone_grid


	func _update_slider():
		if(slider == null):
			return

		_ignore_slider = true
		slider.max_value = moves.size()
		slider.value = moves.size()
		_ignore_slider = false


	func _on_slider_value_changed(value):
		if(_ignore_slider):
			return
		goto_index(slider.value)
		_stone_grid.moves = slider.value + 1


	func _redo_x(x):
		for i in range(x):
			_cur_index += 1
			var m = moves[_cur_index]
			var s = _stone_grid.get_button_at(m[0]).take_stone()
			_stone_grid.get_button_at(m[1]).add_stone(s)


	func _undo_x(x):
		for i in range(x):
			var m = moves[_cur_index]
			var s = _stone_grid.get_button_at(m[1]).take_stone()
			_stone_grid.get_button_at(m[0]).add_stone(s)
			_cur_index -= 1


	func add(from, to):
		moves.append([from, to])
		_cur_index = moves.size() -1
		_update_slider()


	func goto_index(index):
		if(index == _cur_index):
			return
		elif(index < -1 or index > moves.size() -1):
			return

		var x = abs(_cur_index - index)
		if(index > _cur_index):
			_redo_x(x)
		elif(index <= _cur_index):
			_undo_x(x)


	func undo():
		if(moves.size() > 0):
			var m = moves.pop_back()
			var s = _stone_grid.get_button_at(m[1]).take_stone()
			_stone_grid.get_button_at(m[0]).add_stone(s)

			_stone_grid.moves -= 1
			_cur_index = moves.size() -1
			_update_slider()


	func size():
		return moves.size()


	func clear():
		moves.clear()
		_cur_index = 0
		_update_slider()


# ------------------------------------------------------------------------------
# ------------------------------------------------------------------------------
var colors = [
	Color(1, 0, 0), Color(0, 1, 0), Color(0, 0, 1),
	Color(1, 0, 1), Color(1, 1, 0), Color(0, 1, 1),
	Color(.5, 0, .5), Color(.5, .5, 0), Color(0, .5, .5),
	Color(1, .5, 1), Color(1, 1, .5), Color(.5, 1, 1),
	Color(1, .5, .5), Color(.5, 1, .5), Color(.5, .5, 1),
]

const MODES = {
	PLAY = 'play',
	EDIT = 'edit',
	SOLVE = 'solve',
}

var StoneButtonScene = load('res://stone_button.tscn')


var _stone_buttons = []
var _last_layout = null


var from_color = Color(1, 0, 0)
var to_color = Color(0, 1, 0)
var mode = MODES.PLAY :
	get: return mode
	set(val):
		mode = val
		_update_for_mode()

var wait_time = 0
var undoer = Undo.new(self)
var log_enabled = false
var moves = 0 :
	get: return moves
	set(val):
		moves = val
		_ctrls.moves_label.text = str('Moves: ', val)
var _cur_color_index = 0


@onready var _ctrls = {
	grid = $Layout/Scroll/Grid,
	moves_label = $Layout/Header/Moves,
	stone_count = $Layout/Header/Stones,

	edit_button = $Layout/Header2/EditMode,
	edit_buttons = $Layout/Header2/EditButtons,
	edit_clear = $Layout/Header2/EditButtons/Clear,
	edit_plus = $Layout/Header2/EditButtons/Plus,
}


signal stone_pressed(which : StoneButton)
signal stone_button_gui_input(which : StoneButton, event : InputEvent)


func _ready():
	_ctrls.edit_buttons.visible = false


func _animate_move(from_btn : StoneButton, to_btn : StoneButton, duration : float):
	var lbl = Label.new()
	$TopLayer.add_child(lbl)
	lbl.global_position = from_btn.global_position
	lbl.size = from_btn.size
	lbl.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	lbl.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	lbl.text = '1'
	lbl.add_theme_color_override("font_color", from_btn.get("theme_override_colors/font_color"))

	var t = from_btn.create_tween()
	t.finished.connect(func ():  lbl.queue_free())
	t.tween_property(lbl, 'global_position', to_btn.global_position, duration)
	t.play()
	return t


func _update_count():
	var count = 0
	for i in range(grid_size()):
		for j in range(grid_size()):
			count += _stone_buttons[i][j].get_stone_count()
	var s = grid_size() * grid_size()
	_ctrls.stone_count.text = str('Stones: ', count, ' of ', s)


func _update_for_mode():
	_ctrls.edit_buttons.visible = mode == MODES.EDIT
	call_on_buttons(func(btn): btn.edit_mode = mode == MODES.EDIT)
	_update_count()


func _next_color():
	var c = colors[_cur_color_index]
	_cur_color_index += 1
	if(_cur_color_index > colors.size() -1):
		_cur_color_index = 0
	return c

# ------------------------
# Events
# ------------------------
func _on_stones_changed():
	if(mode != MODES.SOLVE):
		_update_count()


func _on_undo_pressed():
	undo()


func _on_reset_pressed():
	reset()
	reload_layout()


func _on_edit_mode_pressed():
	if(_ctrls.edit_button.button_pressed):
		mode = MODES.EDIT
	else:
		mode = MODES.PLAY


func _on_stone_button_pressed(which : StoneButton):
	if(which.edit_mode):
		_update_count()
	else:
		stone_pressed.emit(which)



func _on_plus_pressed():
	var val = -1
	if(_ctrls.edit_plus.button_pressed):
		val = 1
	call_on_buttons(func(btn): btn.edit_increment = val)


func _on_clear_pressed():
	clear()


func _on_print_array_pressed():
	print_board_array()


func _on_color_stones_pressed():
	color_starting_stones()


# ------------------------
# Public
# ------------------------
func clear():
	call_on_buttons(func(btn): btn.clear())


func p(s1='', s2='', s3='', s4='', s5='', s6='', s7='', s8=''):
	if(log_enabled):
		print(s1, s2, s3, s4, s5, s6, s7, s8)


func call_on_buttons(do_this : Callable):
	for i in range(grid_size()):
		for j in range(grid_size()):
			do_this.call(_stone_buttons[i][j])


func move_stone(from : Vector2, to : Vector2):
	var from_btn = _stone_buttons[from.x][from.y]
	var to_btn = _stone_buttons[to.x][to.y]

	if(from_btn != to_btn and from.distance_to(to) == 1.0 and from_btn.get_stone_count() > 0):
		p(from_btn, ' -> ', to_btn)

		var s = from_btn.take_stone()
		if(wait_time > 0.0):
			await _animate_move(from_btn, to_btn, wait_time).finished
		to_btn.add_stone(s)
		moves += 1
		undoer.add(from, to)

		print_board()

		return true
	else:
		push_error('invalid move ', from_btn, ' -> ', to_btn)
		return false


func get_button_at(pos : Vector2):
	return _stone_buttons[pos.x][pos.y]


func get_stones_at(pos):
	return _stone_buttons[pos.x][pos.y].get_stone_count()


func undo():
	undoer.undo()


func create_map(w, h):
	var map = []
	for x in range(w):
		var col = []
		col.resize(h)
		map.append(col)
	return map


func set_grid_size(s):
	_stone_buttons = create_map(s, s)
	for i in range(s):
		var r = HBoxContainer.new()
		r.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		r.size_flags_vertical = Control.SIZE_EXPAND_FILL
		_ctrls.grid.add_child(r)
		for j in range(s):
			var b = StoneButtonScene.instantiate()
			b.pressed.connect(_on_stone_button_pressed.bind(b))
			b.gui_input.connect(func(event): stone_button_gui_input.emit(b, event))
			b.grid_pos.x = i
			b.grid_pos.y = j
			b.custom_minimum_size = Vector2(20, 20)
			r.add_child(b)
			b.stones_changed.connect(_on_stones_changed)
			_stone_buttons[i][j] = b


func _populate_array(stones):
	_last_layout = stones
	moves = 0
	for i in stones.size():
		for j in stones[i].size():
			_stone_buttons[i][j].set_stone_count(stones[i][j])
			_stone_buttons[i][j].set_bg_color(Color(0, 0, 0))
	_update_count()


func _populate_dictionary(stones):
	for key in stones:
		var btn = _stone_buttons[key.x][key.y]
		btn.set_stone_count(stones[key])
		btn.set_bg_color(Color.BLACK)


func populate(stones):
	clear()
	if(typeof(stones) == TYPE_ARRAY):
		_populate_array(stones)
	elif(typeof(stones) == TYPE_DICTIONARY):
		_populate_dictionary(stones)
	color_starting_stones()


func reload_layout():
	if(_last_layout != null):
		populate(_last_layout)


func reset():
	moves = 0
	reset_counts()
	undoer.clear()


func grid_size():
	return _stone_buttons.size()


func print_board():
	p("".lpad(10, '-'))
	for i in range(grid_size()):
		var rowstr = '|'
		for j in range(grid_size()):
			rowstr += str(get_stones_at(Vector2(i, j)), '|').lpad(3, ' ')
		p(rowstr)
	p("".lpad(10, '-'))


func print_board_array():
	print('[')
	for i in range(grid_size()):
		var rowstr = "\t["
		for j in range(grid_size()):
			rowstr += str(get_stones_at(Vector2(i, j)), ',')
		print(rowstr, '],')
	print(']')


func get_num_wrong():
	var num_wrong = 0
	for i in range(grid_size()):
		for j in range(grid_size()):
			print(_stone_buttons[i][j])
			if(_stone_buttons[i][j].get_stone_count() > 1):
				num_wrong += 1
	return num_wrong


func is_solved():
	return get_num_wrong() == 0


func save_layout():
	if(!is_solved()):
		_last_layout = []
		for i in range(grid_size()):
			_last_layout.append([])
			for j in range(grid_size()):
				_last_layout[i].append(_stone_buttons[i][j].get_stone_count())


func show_check_counts():
	call_on_buttons(func(btn): btn.show_check_count())


func show_change_counts():
	call_on_buttons(func(btn): btn.show_change_count())


func reset_counts():
	call_on_buttons(func(btn): btn.reset_counts())


func get_check_count():
	var val = 0
	for i in range(grid_size()):
		for j in range(grid_size()):
			val += _stone_buttons[i][j].check_count
	return val


func color_starting_stones():
	call_on_buttons(func(btn):
		if(btn.get_stone_count() > 1):
			btn.set_bg_color(_next_color())
	)

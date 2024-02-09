class_name StoneGrid
extends Control


var StoneButtonScene = load('res://stone_button.tscn')

var _from : StoneButton = null
var _stone_buttons = []
var _undo = []
var _last_layout = null

var wait_time = 0

var moves = 0 :
	get: return moves
	set(val):
		moves = val
		_ctrls.moves_label.text = str('Moves: ', val)

@onready var _ctrls = {
	grid = $Layout/Grid,
	moves_label = $Layout/Header/Moves
}

func _on_stone_button_toggled(which : StoneButton):
	if(_from == which):
		return
	elif(_from == null):
		if(which.stones == 0):
			which.button_pressed = false
		else:
			_from = which
	else:
		move_stone(_from.grid_pos, which.grid_pos)
		_from.button_pressed = false
		_from.release_focus()
		which.button_pressed = false
		which.release_focus()
		_from = null


func move_stone(from : Vector2, to : Vector2):
	var from_btn = _stone_buttons[from.x][from.y]
	var to_btn = _stone_buttons[to.x][to.y]

	if(from_btn != to_btn and from.distance_to(to) == 1.0 and from_btn.stones > 0):
		print(from_btn, ' -> ', to_btn)
		if(wait_time > 0):
			from_btn.modulate = Color(1, 0, 0)
			to_btn.modulate = Color(0, 1, 0)
		from_btn .stones -= 1
		to_btn.stones += 1
		moves += 1
		_undo.append([from, to])
		print_board()
		if(wait_time > 0):
			await get_tree().create_timer(wait_time).timeout
			from_btn.modulate = Color(1, 1, 1)
			to_btn.modulate = Color(1, 1, 1)

		return true
	else:
		print('invalid move ', from_btn, ' -> ', to_btn)
		return false


func get_stones_at(pos):
	return _stone_buttons[pos.x][pos.y].stones


func undo():
	print('undoing ', _undo.size())
	if(_undo.size() > 0):
		var m = _undo.pop_back()
		m[0].stones += 1
		m[1].stones -= 1
		moves -= 1


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
			b.pressed.connect(_on_stone_button_toggled.bind(b))
			b.grid_pos.x = i
			b.grid_pos.y = j
			r.add_child(b)
			_stone_buttons[i][j] = b

func populate(stones):
	_last_layout = stones
	moves = 0
	for i in stones.size():
		for j in stones[i].size():
			_stone_buttons[i][j].stones = stones[i][j]

func reset():
	if(_last_layout != null):
		populate(_last_layout)
		moves = 0


func size():
	return _stone_buttons.size()

func _on_undo_pressed():
	undo()


func _on_reset_pressed():
	reset()


func print_board():
	print("".lpad(10, '-'))
	for i in range(size()):
		var rowstr = '|'
		for j in range(size()):
			rowstr += str(get_stones_at(Vector2(i, j)), '|').lpad(3, ' ')
		print(rowstr)
	print("".lpad(10, '-'))

func get_button_at(pos : Vector2):
	return _stone_buttons[pos.x][pos.y]


func get_num_wrong():
	var num_wrong = 0
	for i in range(size()):
		for j in range(size()):
			if(_stone_buttons[i][j].stones > 1):
				num_wrong += 1
	return num_wrong
	

func is_solved():
	return get_num_wrong() == 0	

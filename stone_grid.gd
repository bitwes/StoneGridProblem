extends Control


var StoneButtonScene = load('res://stone_button.tscn')
var _rows = []




var _from : StoneButton = null
var _stone_buttons = []
var _undo = []
var _last_layout = null

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
	elif(_from.grid_pos.distance_to(which.grid_pos) == 1.0):
		move_stone(_from, which)
		_from.button_pressed = false
		_from.release_focus()
		which.button_pressed = false
		which.release_focus()
		_from = null
	else:
		_from.button_pressed = false
		_from.release_focus()
		which.button_pressed = false
		which.release_focus()
		_from = null
		print('invalid move')
		


func move_stone(from : StoneButton, to : StoneButton):
	from .stones -= 1
	to.stones += 1
	moves += 1
	_undo.append([from, to])


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


func _on_undo_pressed():
	undo()


func _on_reset_pressed():
	reset()

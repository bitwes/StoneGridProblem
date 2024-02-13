class_name StoneButton
extends Button

var grid_pos = Vector2(-1, -1)
var edit_increment = 1
var increment_repeat = .25
var _waited = 0.0
var _repeat = false

var _change_count = 0
var _check_count = 0

signal stones_changed

func _process(delta):
	if(_repeat):
		_waited += delta
		if(_waited > increment_repeat):
			stones += edit_increment
			_waited = 0.0


var edit_mode = false :
	get: return edit_mode
	set(val):
		edit_mode = val
		toggle_mode = !edit_mode

var stones = 0 :
	get:
		_check_count += 1 
		return stones
	set(val):
		_change_count += 1
		if(val >= 0):
			stones = val
			stones_changed.emit()

		if(stones > 0):
			text = str(stones)
		else:
			text = ' '

func _init():
	size_flags_horizontal = Control.SIZE_EXPAND_FILL
	size_flags_vertical = Control.SIZE_EXPAND_FILL
	edit_mode = edit_mode

func _gui_input(event):
	if(edit_mode):
		if(event is InputEventMouseButton):
			_repeat = event.pressed
			if(event.pressed):
				stones += edit_increment

func _ready():
	if(stones == -1):
		text = str(grid_pos)

func _to_string():
	return str(grid_pos, '[', stones, ']')

func set_color(c):
	$ColorRect.color = c

func reset_counts():
	_change_count = 0
	_check_count = 0
	
func show_change_count():
	#text = " "
	$ColorRect/Label.text = str(_change_count)

func show_check_count():
	#text = " "
	$ColorRect/Label.text = str(_check_count)
	
func show_stones():
	text = str(stones)
	$ColorRect/Label.text = ""

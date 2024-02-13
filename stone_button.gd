class_name StoneButton
extends Button


var _waited = 0.0
var _initial_waited = 0.0
var _repeat = false
var _sb : StyleBox = null

var grid_pos = Vector2(-1, -1)
var edit_increment = 1
var increment_initial_delay = .5
var increment_repeat = .1
var _change_count = 0
var change_count = 0 :
	get: return _change_count
	set(val):  pass
var _check_count = 0
var check_count = 0 :
	get: return _check_count
	set(val): pass
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


signal stones_changed


func _init():
	size_flags_horizontal = Control.SIZE_EXPAND_FILL
	size_flags_vertical = Control.SIZE_EXPAND_FILL
	edit_mode = edit_mode


func _ready():
	_sb = get("theme_override_styles/normal")
	if(stones == -1):
		text = str(grid_pos)


func _process(delta):
	if(_repeat):
		_initial_waited += delta
		if(_initial_waited >= increment_initial_delay):
			_waited += delta
			if(_waited > increment_repeat):
				stones += edit_increment
				_waited = 0.0


func _gui_input(event):
	if(edit_mode):
		if(event is InputEventMouseButton):
			_repeat = event.pressed
			_initial_waited = 0.0
			if(event.pressed):
				stones += edit_increment


func _to_string():
	return str(grid_pos, '[', stones, ']')


# ---------------------------
# Public
# ---------------------------
func set_color(c):
	$ColorRect.color = c


func reset_counts():
	_change_count = 0
	_check_count = 0


func show_change_count():
	$ColorRect/Label.text = str(_change_count)


func show_check_count():
	$ColorRect/Label.text = str(_check_count)


func show_stones():
	text = str(stones)
	$ColorRect/Label.text = ""


func set_bg_color(c):
	_sb.bg_color = c
	if(is_color_dark(c)):
		set("theme_override_colors/font_color", Color(1, 1, 1))
	else:
		set("theme_override_colors/font_color", Color(0, 0, 0))


func get_bg_color():
	return _sb.bg_color


func get_lumenescen(color : Color):
	return  0.2126 * color.r + 0.7152 * color.g + 0.0722 * color.b


func is_color_dark(color):
	return get_lumenescen(color) < .6

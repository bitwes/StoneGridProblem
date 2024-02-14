class_name StoneButton
extends Button


var _waited = 0.0
var _initial_waited = 0.0
var _repeat = false
var _sb : StyleBox = null
var _should_highlight = false

var highlight_color = Color(1, 1, 1)
var default_bg_color = Color(0, 0, 0)
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

@onready var _draw_on_this = $DrawLayer
var _stones = []


signal stones_changed

func highlight(c = highlight_color):
	_should_highlight = true
	highlight_color = c
	_draw_on_this.queue_redraw()

func stop_highlight():
	_should_highlight = false
	_draw_on_this.queue_redraw()

func add_stone(s):
	if(s == null):
		return

	if(_stones.size() == 0 and get_bg_color() == default_bg_color):
		set_bg_color(s.color)

	_stones.append(s)
	_update_display()
	_change_count += 1
	stones_changed.emit()


func take_stone():
	var s = _stones.pop_back()
	_update_display()
	stones_changed.emit()
	_change_count += 1

	return s

func set_stone_count(x):
	_stones.clear()
	for i in range(x):
		var s = Stone.new()
		s.color = get_bg_color()
		_stones.append(s)
	_update_display()
	stones_changed.emit()


func get_stone_count():
	_check_count += 1
	return _stones.size()


func _init():
	size_flags_horizontal = Control.SIZE_EXPAND_FILL
	size_flags_vertical = Control.SIZE_EXPAND_FILL
	edit_mode = edit_mode


func _ready():
	_sb = get("theme_override_styles/normal")
	set_bg_color(default_bg_color)
	_draw_on_this.draw.connect(_draw_on.bind(_draw_on_this))


func _draw_on(which):
	if(_should_highlight):
		var thickness = size.x * .05
		which.draw_rect(Rect2(Vector2(thickness, thickness)/2, get_rect().size - Vector2(thickness, thickness)), highlight_color, false, thickness)


func _update_display():
	if(_stones.size() != 0):
		text = str(_stones.size())
	else:
		text = ''

func _process(delta):
	if(_repeat):
		_initial_waited += delta
		if(_initial_waited >= increment_initial_delay):
			_waited += delta
			if(_waited > increment_repeat):
				if(edit_increment == 1):
					add_stone(Stone.new())
				else:
					take_stone()
				_waited = 0.0


func _gui_input(event):
	if(edit_mode):
		if(event is InputEventMouseButton):
			_repeat = event.pressed
			_initial_waited = 0.0

			if(event.pressed):
				if(edit_increment == 1):
					add_stone(Stone.new())
				else:
					take_stone()


func _to_string():
	return str(grid_pos, '[', _stones.size(), ']')


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
	# text = str(stones)
	$ColorRect/Label.text = ""


func set_bg_color(c):
	_sb.bg_color = c
	if(is_color_dark(c)):
		set("theme_override_colors/font_color", Color(1, 1, 1))
	else:
		set("theme_override_colors/font_color", Color(0, 0, 0))

	for s in _stones:
		s.color = c


func get_bg_color():
	return _sb.bg_color


func get_lumenescen(color : Color):
	return  0.2126 * color.r + 0.7152 * color.g + 0.0722 * color.b


func is_color_dark(color):
	return get_lumenescen(color) < .6

func clear():
	_change_count = 0
	_check_count = 0
	_stones.clear()
	set_bg_color(default_bg_color)
	_update_display()

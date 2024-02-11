class_name StoneButton
extends Button

var grid_pos = Vector2(-1, -1)

var edit_mode = false :
	get: return edit_mode
	set(val): 
		edit_mode = val
		toggle_mode = !edit_mode

var stones = 0 :
	get: return stones
	set(val):
		if(val >= 0):
			stones = val
			
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
			if(event.pressed):
				if(event.button_index == MOUSE_BUTTON_LEFT):
					stones += 1
				elif(event.button_index == MOUSE_BUTTON_RIGHT):
					stones -= 1
					pressed.emit()

func _ready():
	if(stones == -1):
		text = str(grid_pos)

func _to_string():
	return str(grid_pos, '[', stones, ']')

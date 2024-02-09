class_name StoneButton
extends Button

var grid_pos = Vector2(-1, -1)

var stones = -1 :
	get: return stones
	set(val):
		stones = val
		if(stones > 0):
			text = str(stones)
		else:
			text = ''

func _init():
	size_flags_horizontal = Control.SIZE_EXPAND_FILL
	size_flags_vertical = Control.SIZE_EXPAND_FILL
	toggle_mode = true
	

func _ready():
	if(stones == -1):
		text = str(grid_pos)

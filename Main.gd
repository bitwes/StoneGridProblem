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


var diag_three = [
		[3, 0, 0],
		[0, 3, 0],
		[0, 0, 3]
	]
	
var nine_center = [
	[0, 0, 0],
	[0, 9, 0],
	[0, 0, 0]
]

var three_center_line = [
	[0, 3, 0],
	[0, 3, 0],
	[0, 3, 0]
]

var harder = [
	[5, 0, 0],
	[0, 2, 0],
	[2, 0, 0]	
]

var harder_inverse = [
	[0, 0, 2],
	[0, 2, 0],
	[0, 0, 5]		
]

func _ready():
	$StoneGrid.set_grid_size(3)
	$StoneGrid.populate(harder)
	
	
func solve():
	pass


func _on_solve_pressed():
	solve()


func _on_diag_threes_pressed():
	$StoneGrid.populate(diag_three)


func _on_center_nine_pressed():
	$StoneGrid.populate(nine_center)


func _on_center_line_three_pressed():
	$StoneGrid.populate(three_center_line)


func _on_harder_pressed():
	$StoneGrid.populate(harder)


func _on_harder_inverse_pressed():
	$StoneGrid.populate(harder_inverse)

class_name Solvers



class ThisOne:
	var _grid : StoneGrid = null
	
	func get_surrounding_squares(pos : Vector2):
		var to_return = []
		if(pos.x + 1 < _grid.size()):
			to_return.append(_grid._stone_buttons[pos.x + 1][pos.y])
		
		if(pos.x -1 >=0):
			to_return.append(_grid._stone_buttons[pos.x - 1][pos.y])
		
		if(pos.y + 1 < _grid.size()):
			to_return.append(_grid._stone_buttons[pos.x][pos.y + 1])
		
		if(pos.y - 1 >= 0):
			to_return.append(_grid._stone_buttons[pos.x][pos.y - 1])
		
		return to_return


	func solve(grid : StoneGrid):
		_grid = grid
		grid.print_board()
		
		var count = 0
		var max_attempts = 200
		while(!_grid.is_solved() and count <= max_attempts):
			print('===================================')
			count += 1
			attempt()
			_grid.print_board()
			
		print('Attempts  ', count)
		print('Moves     ', _grid.moves)
		print('Solved    ', _grid.is_solved())


	func push_to_least_first(pos : Vector2):
		var around = get_surrounding_squares(pos)
		around.sort_custom(func(a, b): return a.stones < b.stones)
		var here = _grid.get_button_at(pos)
		
		var i = 0
		while(i < around.size() and here.stones > 1):
			_grid.move_stone(pos, around[i].grid_pos)
			i += 1

	func get_all_zeros():
		var to_return = []
		for i in range(_grid.size()):
			for j in range(_grid.size()):
				var pos = Vector2(i, j)
				var btn = _grid.get_button_at(pos)
				if(btn.stones == 0):
					to_return.append(btn)
		return to_return

	func get_closest_zero(pos):
		var zeros = get_all_zeros()
		var closest = null
		if(zeros.size() > 0):
			var min_dist = 9999
			for z in zeros:
				var dist = pos.distance_to(z.grid_pos)
				if(dist < min_dist):
					closest = z
					min_dist = dist
		return closest
			

	func push_to_least_then_in_dir_of_zero(pos : Vector2):
		var around = get_surrounding_squares(pos)
		around.sort_custom(func(a, b): return a.stones < b.stones)
		var here = _grid.get_button_at(pos)
		
		if(around.size() > 0 and around[0].stones == 0):
			var i = 0
			while(i < around.size() and here.stones > 1):
				_grid.move_stone(pos, around[i].grid_pos)
				i += 1
		elif(here.stones > 1):
			var closest_zero = get_closest_zero(pos)
			var to = null
			if(closest_zero != null):
				var xdiff = closest_zero.grid_pos.x - pos.x
				var ydiff = closest_zero.grid_pos.y - pos.y
				
				if(abs(xdiff) > abs(ydiff)):
					to = _grid.get_button_at(pos + Vector2(sign(xdiff), 0))
				else:
					to = _grid.get_button_at(pos + Vector2(0, sign(ydiff)))
				_grid.move_stone(pos, to.grid_pos)

	func attempt():
		for i in range(_grid.size()):
			for j in range(_grid.size()):
				var pos = Vector2(i, j)
				push_to_least_then_in_dir_of_zero(pos)



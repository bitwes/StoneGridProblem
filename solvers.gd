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
			print('===== Pass ', count, ' =====')
			await attempt()
			count += 1

		print('Passes    ', count)
		print('Moves     ', _grid.moves)
		print('Solved    ', _grid.is_solved())


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


	func push_in_direction_of_closest_zero(pos : Vector2):
		var here = _grid.get_button_at(pos)

		if(here.stones > 1):
			var closest_zero = get_closest_zero(pos)
			var to = null
			if(closest_zero != null):
				var xdiff = closest_zero.grid_pos.x - pos.x
				var ydiff = closest_zero.grid_pos.y - pos.y

				if(abs(xdiff) > abs(ydiff)):
					to = _grid.get_button_at(pos + Vector2(sign(xdiff), 0))
				else:
					to = _grid.get_button_at(pos + Vector2(0, sign(ydiff)))
				await _grid.move_stone(pos, to.grid_pos)


	func attempt():
		for i in range(_grid.size()):
			for j in range(_grid.size()):
				var pos = Vector2(i, j)
				await push_in_direction_of_closest_zero(pos)

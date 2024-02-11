class_name Solvers

class BaseSolver:
	var _grid : StoneGrid = null

	func get_surrounding_squares(pos : Vector2):
		var to_return = []
		if(pos.x + 1 < _grid.grid_size()):
			to_return.append(_grid._stone_buttons[pos.x + 1][pos.y])

		if(pos.x -1 >=0):
			to_return.append(_grid._stone_buttons[pos.x - 1][pos.y])

		if(pos.y + 1 < _grid.grid_size()):
			to_return.append(_grid._stone_buttons[pos.x][pos.y + 1])

		if(pos.y - 1 >= 0):
			to_return.append(_grid._stone_buttons[pos.x][pos.y - 1])

		return to_return


	func get_all_zeros():
		var to_return = []
		for i in range(_grid.grid_size()):
			for j in range(_grid.grid_size()):
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


	func get_furthest_zero(pos):
		var zeros = get_all_zeros()
		var furthest = null
		if(zeros.size() > 0):
			var max_dist = 0
			for z in zeros:
				var dist = pos.distance_to(z.grid_pos)
				if(dist > max_dist):
					furthest = z
					max_dist = dist
		return furthest


	func push_in_direction_of(pos : Vector2, target_button : StoneButton):
		var here = _grid.get_button_at(pos)

		if(here.stones > 1):
			var to = null
			if(target_button != null):
				var xdiff = target_button.grid_pos.x - pos.x
				var ydiff = target_button.grid_pos.y - pos.y

				if(abs(xdiff) > abs(ydiff)):
					to = _grid.get_button_at(pos + Vector2(sign(xdiff), 0))
				else:
					to = _grid.get_button_at(pos + Vector2(0, sign(ydiff)))
				await _grid.move_stone(pos, to.grid_pos)

	func _solve():
		pass

	func solve(grid : StoneGrid):
		_grid = grid
		grid.print_board()

		await _solve()

		print('Moves     ', _grid.moves)
		print('Solved    ', _grid.is_solved())



class ThisOne:
	extends BaseSolver

	func _solve():

		var count = 0
		var max_attempts = 200
		while(!_grid.is_solved() and count <= max_attempts):
			print('===== Pass ', count, ' =====')
			await attempt()
			count += 1

		print('Passes    ', count)


	func attempt():
		for i in range(_grid.grid_size()):
			for j in range(_grid.grid_size()):
				var pos = Vector2(i, j)
				var target = get_closest_zero(pos)
				await push_in_direction_of(pos, target)



class PushTillWeGetThere:
	extends BaseSolver

	func _solve():

		var count = 0
		var max_attempts = 200
		while(!_grid.is_solved() and count <= max_attempts):
			print('===== Pass ', count, ' =====')
			await attempt()
			count += 1

		print('Passes    ', count)


	func attempt():
		for i in range(_grid.grid_size()):
			for j in range(_grid.grid_size()):
				var pos = Vector2(i, j)
				# while(_grid.get_stones_at(pos))
				# await push_in_direction_of(pos, get_closest_zero)

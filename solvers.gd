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
		var to = null
		if(here.stones > 1):
			if(target_button != null):
				var xdiff = target_button.grid_pos.x - pos.x
				var ydiff = target_button.grid_pos.y - pos.y

				if(abs(xdiff) > abs(ydiff)):
					to = _grid.get_button_at(pos + Vector2(sign(xdiff), 0))
				else:
					to = _grid.get_button_at(pos + Vector2(0, sign(ydiff)))
				await _grid.move_stone(pos, to.grid_pos)
		return to

	func get_button_in_direction(pos : Vector2, target_button : StoneButton):
		var here = _grid.get_button_at(pos)
		var to = null
		if(here.stones > 1):
			if(target_button != null):
				var xdiff = target_button.grid_pos.x - pos.x
				var ydiff = target_button.grid_pos.y - pos.y

				if(abs(xdiff) > abs(ydiff)):
					to = _grid.get_button_at(pos + Vector2(sign(xdiff), 0))
				else:
					to = _grid.get_button_at(pos + Vector2(0, sign(ydiff)))
		return to


	func calc_moves_to(btn_from : StoneButton, btn_target : StoneButton):
		var xdiff = abs(btn_from.grid_pos.x - btn_target.grid_pos.x)
		var ydiff = abs(btn_from.grid_pos.y - btn_target.grid_pos.y)
		return xdiff + ydiff




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
		var max_attempts = _grid.grid_size() * _grid.grid_size()
		while(!_grid.is_solved() and count <= max_attempts):
			print('===== Pass ', count, ' =====')
			await attempt()
			count += 1

		print('Passes    ', count)


	func push_all_towards(pos, target):
		if(target == null):
			return

		var moved = 0
		var here = _grid.get_button_at(pos)
		var to = get_button_in_direction(pos, target)
		if(to != null):
			var dist = calc_moves_to(here, to)

			while(moved < int(dist) and here.stones > 1):
				await _grid.move_stone(pos, to.grid_pos)
				moved += 1

			if(moved > 0 and to != null):
				await push_all_towards(to.grid_pos, target)



	func attempt():
		for i in range(_grid.grid_size()):
			for j in range(_grid.grid_size()):
				var pos = Vector2(i, j)
				var target = get_closest_zero(pos)
				var here = _grid.get_button_at(pos)
				here.set_color(Color(1, 1, 1, .5))
				if(target != null):
					target.set_color(Color(0, 0, 1, .5))
					await push_all_towards(pos, target)
					target.set_color(Color(0, 0, 0, 0))
				here.set_color(Color(0, 0, 0, 0))

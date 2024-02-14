class_name Solvers

static var TheListOfSolvers = [
	['This One', ThisOne],
	['Push Till We Get There', PushTillWeGetThere],
	['Best Idea', BestIdea]
]


class BaseSolver:
	var _grid : StoneGrid = null
	var _should_run = true

	var _passes = 0
	var passes = _passes :
		get: return _passes
		set(val): pass

	var max_attempts = 200


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
				if(btn.get_stone_count() == 0):
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
		if(here.get_stone_count() > 1):
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
		if(here.get_stone_count() > 1):
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


	func push_untl_there(pos : Vector2, target : StoneButton, c = null):
		if(target == null):
			return

		var moved = 0
		var here = _grid.get_button_at(pos)
		if(c == null):
			c = here.get_bg_color()
		var to = get_button_in_direction(pos, target)
		if(to != null):
			var dist = calc_moves_to(here, to)
			if(to.get_stone_count() == 0):
				to.set_bg_color(c)

			while(moved < int(dist) and here.get_stone_count() > 1):
				await _grid.move_stone(pos, to.grid_pos)
				moved += 1

			if(moved > 0 and to != null):
				await push_untl_there(to.grid_pos, target, c)


	func _get_buttons_with_spreadable_stones():
		var btns = []
		for i in range(_grid.grid_size()):
			for j in range(_grid.grid_size()):
				var btn = _grid.get_button_at(Vector2(i, j))
				if(btn.get_stone_count() > 1):
					btns.append(btn)
		return btns


	# Virtual
	func _solve():
		pass


	func solve(grid : StoneGrid):
		_should_run = true
		_grid = grid
		_grid.print_board()
		_grid.color_starting_stones()

		var prev_mode = _grid.mode
		_grid.mode = _grid.MODES.SOLVE
		await _solve()
		_grid.mode = prev_mode

		print('Moves     ', _grid.moves)
		print('Checks    ', _grid.get_check_count())
		print('Passes    ', passes)
		print('Solved    ', _grid.is_solved())


	func stop():
		_should_run = false


# ------------------------------------------------------------------------------
# * Loop through board, any spot that has more than one pushes one in the
#   direction of closest open (1 space)
# * Repeat until solved.
# ------------------------------------------------------------------------------
class ThisOne:
	extends BaseSolver

	func _solve():
		_passes = 0
		while(!_grid.is_solved() and _passes <= max_attempts):
			if(!_should_run):
					return
			print('===== Pass ', _passes, ' =====')
			await attempt()
			_passes += 1


	func attempt():
		for i in range(_grid.grid_size()):
			for j in range(_grid.grid_size()):
				var pos = Vector2(i, j)
				var target = get_closest_zero(pos)
				var here = _grid.get_button_at(pos)
				if(here != null and target != null):
					here.highlight()
					target.highlight()
					await push_in_direction_of(pos, target)
					here.stop_highlight()
					target.stop_highlight()


# ------------------------------------------------------------------------------
# * Loop through board, any spot that has more than one pushes one all the way
#   to the closest open spot
# * Repeat until solved
# ------------------------------------------------------------------------------
class PushTillWeGetThere:
	extends BaseSolver

	func _solve():
		_get_buttons_with_spreadable_stones()

		max_attempts = _grid.grid_size() * _grid.grid_size()
		while(!_grid.is_solved() and _passes <= max_attempts):
			if(!_should_run):
				return
			print('===== Pass ', _passes, ' =====')
			await attempt()
			_passes += 1


	func attempt():
		for i in range(_grid.grid_size()):
			for j in range(_grid.grid_size()):
				var pos = Vector2(i, j)
				var target = get_closest_zero(pos)
				var here = _grid.get_button_at(pos)
				here.highlight()
				if(target != null):
					target.highlight()
					await push_untl_there(pos, target)
					target.stop_highlight()
				here.stop_highlight()


# ------------------------------------------------------------------------------
# * Get the starting stone locations, sort them by size descending.
# * Push out from each starting location open spaces within a range
# * Increase range and repeat pushing.
# ------------------------------------------------------------------------------
class BestIdea:
	extends BaseSolver


	func _get_closest_zero_in_range(from : StoneButton, r):
		var target = get_closest_zero(from.grid_pos)
		if(target != null and calc_moves_to(from, target) <= r):
			return target
		else:
			return null


	func attempt(here, r):
		var target = _get_closest_zero_in_range(here, r)
		here.highlight()
		while(target != null and here.get_stone_count() > 1):
			if(!_should_run):
				return
			target.highlight()
			await push_untl_there(here.grid_pos, target)
			target.stop_highlight()
			target = _get_closest_zero_in_range(here, r)
		here.stop_highlight()


	func _solve():
		max_attempts = _grid.grid_size() * _grid.grid_size()
		var spreadable = _get_buttons_with_spreadable_stones()

		# Move piles that have the most amount of stones first.
		spreadable.sort_custom(func(a, b):
			return a.get_stone_count() > b.get_stone_count())

		var r = 1
		while(!_grid.is_solved() and _passes <= max_attempts):
			print('===== Pass ', _passes, ' =====')
			for s in spreadable:
				if(!_should_run):
					return
				await attempt(s, r)
			r += 1

			_passes += 1

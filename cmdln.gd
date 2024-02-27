extends SceneTree

var main_scene = null

func solve(size, layout, solver):
	print('-- Solving --')
	main_scene._create_stone_grid(size, {})
	main_scene._stone_grid.populate(layout)
	main_scene._ctrls.delay.value = 0.0
	main_scene.solver = solver

	# main_scene.solver = Solvers.PushTillWeGetThere.new()

	await main_scene.solve()
	print('time = ',main_scene._ctrls.time.text)
	main_scene._stone_grid.print_board_array()
	print('done')
	print(main_scene._stone_grid.is_solved())


func keep_on_keeping_on():
	await solve(15, Layouts.fifteen_x_fifteen.near_corners_plus, Solvers.BestIdeaBetter.new())
	# await solve(15, Layouts.fifteen_x_fifteen.near_corners_plus, Solvers.PushTillWeGetThere.new())
	# await solve(15, Layouts.fifteen_x_fifteen.near_corners_plus, Solvers.PushTillWeGetTherePlus.new())
	# await solve(15, Layouts.fifteen_x_fifteen.near_corners_plus, Solvers.BestIdea.new())
	# quit()


func _init():
	main_scene = load('res://Main.tscn').instantiate()
	main_scene.ready.connect(keep_on_keeping_on)
	root.add_child(main_scene)

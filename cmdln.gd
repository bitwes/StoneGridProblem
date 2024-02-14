extends SceneTree

var main_scene = null

func keep_on_keeping_on():
	main_scene._create_stone_grid(15, {})
	main_scene._stone_grid.populate(Layouts.fifteen_x_fifteen.near_corners_plus)
	main_scene._ctrls.delay.value = 0.0
	main_scene.solver = Solvers.PushTillWeGetThere.new()

	await main_scene.solve()
	print('time = ',main_scene._ctrls.time.text)


func _init():
	main_scene = load('res://Main.tscn').instantiate()
	main_scene.ready.connect(keep_on_keeping_on)
	root.add_child(main_scene)

class_name MultiballPowerup
extends BasePowerup


func _init() -> void:
	type = PowerupRegistry.PowerType.MULTIBALL
	duration = 0.0


func activate() -> void:
	var spawn_pos: Vector2 = collect_pos
	if spawn_pos == Vector2.ZERO and game and game.paddle:
		spawn_pos = game.paddle.global_position

	var roll := randf()
	var count := 1
	if roll < 0.60:
		count = 1
	elif roll < 0.90:
		count = 2
	else:
		count = 3

	var spacing: float = 16.0
	for i in range(count):
		var x_offset := (float(i) - float(count - 1) / 2.0) * spacing
		var ball_x := spawn_pos.x + x_offset
		if game and game.window_size.x > 0:
			ball_x = clampf(ball_x, 20.0, game.window_size.x - 20.0)

		var pos := Vector2(ball_x, spawn_pos.y)
		var dmg := _roll_damage()
		var b := game.add_ball(dmg, false, pos)
		if b:
			var fanned_angle := _get_launch_angle(i, count)
			b.set_angle_velocity(fanned_angle)


func _roll_damage() -> int:
	var roll := randf()
	if roll < 0.40:
		return 2
	elif roll < 0.70:
		return 3
	elif roll < 0.90:
		return 4
	else:
		return 5


func _get_launch_angle(index: int, total: int) -> float:
	if total == 1:
		return randf_range(-deg_to_rad(40.0), deg_to_rad(40.0))
	elif total == 2:
		return -deg_to_rad(25.0) if index == 0 else deg_to_rad(25.0)
	elif total == 3:
		var angles: Array[float] = [-deg_to_rad(35.0), 0.0, deg_to_rad(35.0)]
		return angles[index]
	return 0.0

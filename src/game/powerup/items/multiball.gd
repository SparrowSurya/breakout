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
	for i in range(count):
		game.add_ball(1, false, spawn_pos)

class_name FireballPowerup
extends BasePowerup


func _init() -> void:
	type = PowerupRegistry.PowerType.FIREBALL
	duration = 0.0


func activate() -> void:
	var spawn_pos: Vector2 = collect_pos
	if spawn_pos == Vector2.ZERO and game and game.paddle:
		spawn_pos = game.paddle.global_position
	game.add_ball(1, true, spawn_pos)

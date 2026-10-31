class_name FireballPowerup
extends BasePowerup


func _init() -> void:
	type = PowerupRegistry.PowerType.FIREBALL
	duration = 0.0


func activate() -> void:
	var current_balls = game.balls
	var src: Ball = current_balls.pick_random() if not current_balls.is_empty() else null
	game.add_ball_from(src, true)

class_name MultiballPowerup
extends BasePowerup


func _init() -> void:
	type = PowerupRegistry.PowerType.MULTIBALL
	duration = 0.0


func activate() -> void:
	var current_balls = game.balls
	var src: Ball = current_balls.pick_random() if not current_balls.is_empty() else null
	for i in range(randi_range(1, 3)):
		game.add_ball_from(src, false)

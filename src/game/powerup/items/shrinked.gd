class_name ShrinkedPowerup
extends BasePowerup


func _init() -> void:
	type = PowerupRegistry.PowerType.SHRINKED
	duration = 8.0


func activate() -> void:
	game.paddle.set_width_mod(&"shrinked", 0.5)


func deactivate() -> void:
	game.paddle.clear_width_mod(&"shrinked")

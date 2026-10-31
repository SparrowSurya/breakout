class_name OiledPowerup
extends BasePowerup


func _init() -> void:
	type = PowerupRegistry.PowerType.OILED
	duration = 16.0


func activate() -> void:
	game.paddle.set_speed_mod(&"oiled", 1.5)


func deactivate() -> void:
	game.paddle.clear_speed_mod(&"oiled")

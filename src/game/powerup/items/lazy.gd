class_name LazyPowerup
extends BasePowerup


func _init() -> void:
	type = PowerupRegistry.PowerType.LAZY
	duration = 8.0


func activate() -> void:
	game.paddle.set_speed_mod(&"lazy", 0.25)


func deactivate() -> void:
	game.paddle.clear_speed_mod(&"lazy")

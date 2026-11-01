class_name OiledPowerup
extends BasePowerup

var _mult: float = 1.5


func _init() -> void:
	type = PowerupRegistry.PowerType.OILED
	var roll := randf()
	if roll < 0.60:
		_mult = 2.0
		duration = 8.0
	else:
		_mult = 1.5
		duration = 16.0
	remaining = duration


func activate() -> void:
	game.paddle.set_speed_mod(&"oiled", _mult)


func deactivate() -> void:
	game.paddle.clear_speed_mod(&"oiled")

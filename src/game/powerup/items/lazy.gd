class_name LazyPowerup
extends BasePowerup

var _mult: float = 0.4


func _init() -> void:
	type = PowerupRegistry.PowerType.LAZY
	var roll := randf()
	if roll < 0.60:
		_mult = 0.4
		duration = 16.0
	elif roll < 0.90:
		_mult = 0.5
		duration = 12.0
	else:
		_mult = 0.6
		duration = 8.0
	remaining = duration


func activate() -> void:
	game.paddle.set_speed_mod(&"lazy", _mult)


func deactivate() -> void:
	game.paddle.clear_speed_mod(&"lazy")

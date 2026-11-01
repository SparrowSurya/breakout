class_name ExpandedPowerup
extends BasePowerup

var _mult: float = 1.5


func _init() -> void:
	type = PowerupRegistry.PowerType.EXPANDED
	var roll := randf()
	if roll < 0.70:
		_mult = 1.5
		duration = 12.0
	else:
		_mult = 2.0
		duration = 8.0
	remaining = duration


func activate() -> void:
	game.paddle.set_width_mod(&"expanded", _mult)


func deactivate() -> void:
	game.paddle.clear_width_mod(&"expanded")

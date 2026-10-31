class_name ExpandedPowerup
extends BasePowerup


func _init() -> void:
	type = PowerupRegistry.PowerType.EXPANDED
	duration = 16.0


func activate() -> void:
	game.paddle.set_width_mod(&"expanded", 2.0)


func deactivate() -> void:
	game.paddle.clear_width_mod(&"expanded")

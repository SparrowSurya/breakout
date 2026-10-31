class_name ImmortalPowerup
extends BasePowerup


func _init() -> void:
	type = PowerupRegistry.PowerType.IMMORTAL
	duration = 8.0


func activate() -> void:
	game.set_tiles_immune(true)


func deactivate() -> void:
	game.set_tiles_immune(false)

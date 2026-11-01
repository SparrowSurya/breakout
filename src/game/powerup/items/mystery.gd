class_name MysteryPowerup
extends BasePowerup


func _init() -> void:
	type = PowerupRegistry.PowerType.MYSTERY
	duration = 0.0


func activate() -> void:
	var chosen: int = game.powerups.pick(type)
	if chosen >= 0:
		game.powerups.collect(chosen as PowerupRegistry.PowerType, collect_pos)

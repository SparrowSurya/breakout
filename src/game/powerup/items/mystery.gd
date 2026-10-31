class_name MysteryPowerup
extends BasePowerup


func _init() -> void:
	type = PowerupRegistry.PowerType.MYSTERY
	duration = 0.0


func activate() -> void:
	var chosen_type: int = game.powerups.pick(type)
	if chosen_type >= 0:
		game.powerups.collect(chosen_type)

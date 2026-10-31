class_name GuardianPowerup
extends BasePowerup


func _init() -> void:
	type = PowerupRegistry.PowerType.GUARDIAN
	duration = 60.0


func can_spawn(g: BaseGame) -> bool:
	return not g.powerups.active.has(type)


func activate() -> void:
	game.enable_shield()


func deactivate() -> void:
	game.disable_shield()

class_name GuardianPowerup
extends BasePowerup


func _init() -> void:
	type = PowerupRegistry.PowerType.GUARDIAN
	if randf() < 0.05:
		duration = INF
	else:
		var roll := randf()
		if roll < 0.60:
			duration = 20.0
		elif roll < 0.90:
			duration = 40.0
		else:
			duration = 60.0
	remaining = duration


func can_spawn(g: BaseGame) -> bool:
	return not g.powerups.active.has(type)


func activate() -> void:
	game.enable_shield()


func deactivate() -> void:
	game.disable_shield()

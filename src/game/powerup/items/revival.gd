class_name RevivalPowerup
extends BasePowerup


func _init() -> void:
	type = PowerupRegistry.PowerType.REVIVAL
	duration = 0.0


func can_spawn(g: BaseGame) -> bool:
	return g.hearts < g.max_hearts


func activate() -> void:
	game.add_heart()

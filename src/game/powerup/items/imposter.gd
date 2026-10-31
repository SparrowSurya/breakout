class_name ImposterPowerup
extends BasePowerup


func _init() -> void:
	type = PowerupRegistry.PowerType.IMPOSTER
	duration = 8.0


func activate() -> void:
	game.set_ball_damage_mod(&"imposter", 0.0)


func deactivate() -> void:
	game.clear_ball_damage_mod(&"imposter")

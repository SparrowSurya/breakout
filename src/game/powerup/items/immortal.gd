class_name ImmortalPowerup
extends BasePowerup


func _init() -> void:
	type = PowerupRegistry.PowerType.IMMORTAL
	var roll := randf()
	if roll < 0.60:
		duration = 16.0
	elif roll < 0.90:
		duration = 12.0
	else:
		duration = 8.0
	remaining = duration


func activate() -> void:
	SoundManager.play_sfx(Constants.SOUND.PowerupImmortalBegin)
	game.set_tiles_immune(true)


func deactivate() -> void:
	game.set_tiles_immune(false)


func on_expire() -> void:
	SoundManager.play_sfx(Constants.SOUND.PowerupImmortalExpire)

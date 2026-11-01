class_name ShrinkedPowerup
extends BasePowerup

var _mult: float = 0.5


func _init() -> void:
	type = PowerupRegistry.PowerType.SHRINKED
	var roll := randf()
	if roll < 0.60:
		_mult = 0.5
		duration = 12.0
	elif roll < 0.90:
		_mult = 0.4
		duration = 16.0
	else:
		_mult = 0.6
		duration = 8.0
	remaining = duration


func activate() -> void:
	SoundManager.play_sfx(Constants.SOUND.PowerupShrinkedBegin)
	game.paddle.set_width_mod(&"shrinked", _mult)


func deactivate() -> void:
	game.paddle.clear_width_mod(&"shrinked")


func on_expire() -> void:
	SoundManager.play_sfx(Constants.SOUND.PowerupShrinkedExpire)

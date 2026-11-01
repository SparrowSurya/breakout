class_name ImposterPowerup
extends BasePowerup

var _mult: float = 1.0
var _offset: int = 0


func _init() -> void:
	type = PowerupRegistry.PowerType.IMPOSTER
	duration = 8.0
	remaining = duration

	var roll := randf()
	if roll < 0.50:
		# No damage
		_mult = 0.0
		_offset = 0
	elif roll < 0.75:
		# One less damage
		_mult = 1.0
		_offset = 1
	else:
		# Random less damage (50% reduction)
		_mult = 0.5
		_offset = 0


func activate() -> void:
	SoundManager.play_sfx(Constants.SOUND.PowerupImposterBegin)
	if _mult < 1.0:
		game.set_ball_damage_mod(&"imposter", _mult)
	if _offset > 0:
		game.set_ball_damage_offset(&"imposter", _offset)


func deactivate() -> void:
	game.clear_ball_damage_mod(&"imposter")
	game.clear_ball_damage_offset(&"imposter")


func on_expire() -> void:
	SoundManager.play_sfx(Constants.SOUND.PowerupImposterExpire)

extends CanvasLayer


@export var tap_to_start: Label
@export var press_key_to_start: Label
@export var version_value: Label

const VISIBLE_SECS: float = 0.5
const INVISIBLE_SECS: float = 0.5
const BLINK_TRANSITION_SECS: float = 0.1


var _done: bool = false

func _ready() -> void:
	version_value.text = "v%s" % Constants.VERSION_STRING
	if DisplayServer.is_touchscreen_available():
		press_key_to_start.hide()
	_blink()
	
	if YTPlayableSdk.in_playables_env():
		YTPlayableSdk.first_frame_ready()
		YTPlayableSdk.game_ready()


func _input(event: InputEvent) -> void:
	if _done:
		return

	if event is InputEventKey and event.pressed and not event.echo \
	or event is InputEventScreenTouch and event.pressed            \
	or event is InputEventMouseButton and event.pressed:
		_start_game()


func _blink() -> void:
	var tween = create_tween().set_loops()
	tween.tween_interval(VISIBLE_SECS)
	tween.tween_property(tap_to_start, "modulate:a", 0.0, BLINK_TRANSITION_SECS)
	if press_key_to_start.visible:
		tween.parallel().tween_property(press_key_to_start, "modulate:a", 0.0, BLINK_TRANSITION_SECS)
	tween.tween_interval(INVISIBLE_SECS)
	tween.tween_property(tap_to_start, "modulate:a", 1.0, BLINK_TRANSITION_SECS)
	if press_key_to_start.visible:
		tween.parallel().tween_property(press_key_to_start, "modulate:a", 1.0, BLINK_TRANSITION_SECS)


func _start_game() -> void:
	if _done:
		return

	_done = true
	SoundManager.play_sound(Constants.SOUND.Click)
	GameManager.navigate_to_mainmenu()

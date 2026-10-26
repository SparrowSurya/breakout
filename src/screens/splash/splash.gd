extends CanvasLayer


@export var tap_to_start: Label
@export var press_key_to_start: Label
@export var version_value: Label

const VISIBLE_SECS: float = 0.5
const INVISIBLE_SECS: float = 0.5
const BLINK_TRANSITION_SECS: float = 0.1


func _ready() -> void:
	version_value.text = "v%s" % Constants.VERSION_STRING
	_blink(tap_to_start)


func _input(event: InputEvent) -> void:
	if event is InputEventKey and event.pressed and not event.echo:
		_start_game()
	elif event is InputEventScreenTouch and event.pressed:
		_start_game()
	elif event is InputEventMouseButton and event.pressed:
		_start_game()


func _blink(label: Label) -> void:
	var tween = create_tween().set_loops()
	tween.tween_interval(VISIBLE_SECS)
	tween.tween_property(label, "modulate:a", 0.0, BLINK_TRANSITION_SECS)
	tween.tween_interval(INVISIBLE_SECS)
	tween.tween_property(label, "modulate:a", 1.0, BLINK_TRANSITION_SECS)


func _start_game() -> void:
	GameManager.navigate_to_mainmenu()

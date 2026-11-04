
class_name CustomSwitchButton
extends Button


## Emitted when value changes.
signal value_changed(is_on: bool)

@export var track: Panel
@export var track_texture: TextureRect
@export var knob: Panel
@export var overlay: ColorRect

# Textures
const TRACK_ON := preload("res://assets/textures/switch-button/track-on.png")
const TRACK_OFF := preload("res://assets/textures/switch-button/track-off.png")

# Colors
const KNOB_ON := Palette.LAVENDER
const KNOB_OFF := Palette.SURFACE1

const POS_OFF := Vector2(3.0, 3.0)
const POS_ON := Vector2(27.0, 3.0)

const SLIDE_DURATION := 0.16

var _tween: Tween
var _track_style: StyleBoxFlat

var _is_hovered := false
var _is_down := false
var _last_disabled := false

var value: bool = false:
	set(p_value):
		if value == p_value:
			return

		value = p_value
		button_pressed = value
		if is_node_ready():
			_update_visuals(true)


func _ready() -> void:
	toggle_mode = true
	button_pressed = value

	var style = track.get_theme_stylebox("panel")
	if style is StyleBoxFlat:
		_track_style = style.duplicate() as StyleBoxFlat
	else:
		_track_style = StyleBoxFlat.new()
	_track_style.set_border_width_all(1)
	track.add_theme_stylebox_override("panel", _track_style)

	toggled.connect(_on_toggled)

	mouse_entered.connect(_on_mouse_entered)
	mouse_exited.connect(_on_mouse_exited)

	focus_entered.connect(_on_focus_changed)
	focus_exited.connect(_on_focus_changed)

	button_down.connect(_on_button_down)
	button_up.connect(_on_button_up)

	_last_disabled = disabled
	_apply_disable_setting()
	_update_visuals(false)


func _gui_input(event: InputEvent) -> void:
	if event is InputEventMouseButton \
	and event.button_index == MOUSE_BUTTON_LEFT \
	and event.pressed:
		_on_button_pressed()


func _on_button_pressed() -> void:
	var sound := Constants.SOUND.Disabled if disabled else Constants.SOUND.Click
	SoundManager.play_sound(sound)


func _notification(what: int) -> void:
	if what == NOTIFICATION_DRAW:
		if disabled != _last_disabled:
			_last_disabled = disabled
			_apply_disable_setting()


func _apply_disable_setting() -> void:
	if disabled:
		mouse_default_cursor_shape = Control.CURSOR_FORBIDDEN
		focus_mode = Control.FOCUS_NONE
	else:
		mouse_default_cursor_shape = Control.CURSOR_POINTING_HAND
		focus_mode = Control.FOCUS_ALL
	_update_visuals(false)


func _get_visual_state() -> String:
	var state := "On" if button_pressed else "Off"

	if disabled:
		return "Disable" + state

	if _is_down:
		return "Press" + state

	if _is_hovered:
		return "Hover" + state

	if has_focus():
		return "Focus" + state

	return state


func _update_visuals(animate: bool = true) -> void:
	if not is_node_ready():
		return

	var target_pos := POS_ON if button_pressed else POS_OFF
	var target_texture: Texture2D = (
		TRACK_ON if button_pressed else TRACK_OFF
	)

	# Track texture
	if track_texture:
		track_texture.texture = target_texture

	# Focus border
	if _track_style:
		_track_style.border_color = (
			Palette.LAVENDER if has_focus() and not disabled
			else Color.TRANSPARENT
		)

	# Overlay appearance
	var overlay_color := Color.TRANSPARENT

	if disabled:
		overlay_color = Color(0.0, 0.0, 0.0, 0.40)
	elif _is_down:
		overlay_color = Color(1.0, 1.0, 1.0, 0.22)
	elif _is_hovered:
		overlay_color = Color(1.0, 1.0, 1.0, 0.12)

	if overlay:
		overlay.color = overlay_color

	if _tween and _tween.is_running():
		_tween.kill()

	if animate and is_inside_tree():
		_tween = create_tween().set_parallel(true)

		_tween.tween_property(
			knob, "position", target_pos, SLIDE_DURATION
		).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)

	else:
		knob.position = target_pos


func _on_toggled(is_on: bool) -> void:
	if value != is_on:
		value = is_on
		value_changed.emit(value)


func _on_mouse_entered() -> void:
	_is_hovered = true
	_update_visuals()


func _on_mouse_exited() -> void:
	_is_hovered = false
	_update_visuals()


func _on_focus_changed() -> void:
	_update_visuals()


func _on_button_down() -> void:
	_is_down = true
	_update_visuals()


func _on_button_up() -> void:
	_is_down = false
	_update_visuals()

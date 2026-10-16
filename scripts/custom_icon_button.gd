class_name CustomIconButton
extends Button

const HOVER_Y_DELTA: float = 8.0
const PRESS_Y_DELTA: float = 2.0

var active_tween: Tween

var style_normal: StyleBoxTexture
var style_hover: StyleBoxTexture
var style_pressed: StyleBoxTexture
var style_focus: StyleBoxTexture

var base_margin_top: float
var base_margin_bottom: float

func _ready() -> void:
	style_normal = get_theme_stylebox("normal") as StyleBoxTexture
	style_hover = get_theme_stylebox("hover") as StyleBoxTexture
	style_pressed = get_theme_stylebox("pressed") as StyleBoxTexture
	style_focus = get_theme_stylebox("focus") as StyleBoxTexture # NEW
	
	
	if style_normal: style_normal = style_normal.duplicate()
	if style_hover: style_hover = style_hover.duplicate()
	if style_pressed: style_pressed = style_pressed.duplicate()
	if style_focus: style_focus = style_focus.duplicate()
	
	add_theme_stylebox_override("normal", style_normal)
	add_theme_stylebox_override("hover", style_hover)
	add_theme_stylebox_override("pressed", style_pressed)
	add_theme_stylebox_override("focus", style_focus)

	base_margin_top = max(0.0, style_normal.content_margin_top)
	base_margin_bottom = max(0.0, style_normal.content_margin_bottom)

	mouse_entered.connect(_on_mouse_entered)
	mouse_exited.connect(_on_mouse_exited)
	button_down.connect(_on_button_down)
	button_up.connect(_on_button_up)
	
	_apply_disable_setting()


func _notification(what: int) -> void:
	if what == NOTIFICATION_DRAW:
		_apply_disable_setting()


func _apply_disable_setting() -> void:
	if disabled:
		mouse_default_cursor_shape = Control.CURSOR_FORBIDDEN
		focus_mode = Control.FOCUS_NONE
	else:
		mouse_default_cursor_shape = Control.CURSOR_POINTING_HAND
		focus_mode = Control.FOCUS_ALL


func animate_graphic_and_text_shift(target_offset: float) -> void:
	if active_tween and active_tween.is_valid():
		active_tween.kill()
		
	active_tween = create_tween().set_parallel(true)
	
	for style in [style_normal, style_hover, style_pressed, style_focus]:
		if style:
			active_tween.tween_property(style, "expand_margin_top", target_offset, 0.1)\
				.set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
			active_tween.tween_property(style, "expand_margin_bottom", -target_offset, 0.1)\
				.set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)

			active_tween.tween_property(style, "content_margin_top", base_margin_top - target_offset, 0.1)\
				.set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
			active_tween.tween_property(style, "content_margin_bottom", base_margin_bottom + target_offset, 0.1)\
				.set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)


func _on_mouse_entered() -> void:
	animate_graphic_and_text_shift(HOVER_Y_DELTA)


func _on_mouse_exited() -> void:
	animate_graphic_and_text_shift(0.0)


func _on_button_down() -> void:
	animate_graphic_and_text_shift(PRESS_Y_DELTA)


func _on_button_up() -> void:
	if is_hovered():
		animate_graphic_and_text_shift(HOVER_Y_DELTA)
	else:
		animate_graphic_and_text_shift(0.0)


func _on_focus_entered() -> void:
	animate_graphic_and_text_shift(HOVER_Y_DELTA)


func _on_focus_exited() -> void:
	if is_hovered():
		animate_graphic_and_text_shift(HOVER_Y_DELTA)
	else:
		animate_graphic_and_text_shift(0.0)

class_name LevelCard
extends PanelContainer

@export var border_node: ColorRect
@export var margin_node: MarginContainer
@export var overlay_node: ColorRect
@export var highlight_node: ColorRect

@export var indicator_node: ColorRect
@export var lock_icon_node: TextureRect
@export var level_node: Label
@export var tab_locked_status_node: TabContainer
@export var progress_tab_node: TabContainer
@export var stars_node: HBoxContainer
@export var progress_node: ProgressBar

@export var level_no: int = 0
@export var difficulty: LevelDef.LevelDifficulty = LevelDef.LevelDifficulty.EASY
@export var locked: bool = true
@export var progress: float = 0.0
@export var stars: int = 0

const LOCKED_TAB: int = 0
const UNLOCKED_TAB: int = 1
const FINISHED_TAB: int = 0
const UNFINISHED_TAB: int = 1

const HOVER_Y_DELTA: float = 8.0
const PRESS_Y_DELTA: float = 2.0
const HOVER_BRIGHTNESS: float = 0.15

var active_tween: Tween
var is_hovered: bool = false

# Track original baseline Y positions
var orig_border_y: float
var orig_indicator_y: float
var orig_margin_y: float
var orig_overlay_y: float
var orig_highlight_y: float


func _ready() -> void:
	highlight_node.color = Color.TRANSPARENT
	
	lock_icon_node.modulate = Palette.OVERLAY1
	level_node.text = str(level_no)
	
	var level_progress: LevelProgress = UserProgress.get_level(level_no)
	var stars_node_list: Array[TextureRect] = []
	for node in stars_node.get_children():
		if node is TextureRect:
			stars_node_list.append(node)

	for i in range(stars_node_list.size()):
		if i < level_progress.stars:
			stars_node_list[i].modulate = Palette.YELLOW
		else:
			stars_node_list[i].modulate = Palette.SURFACE1

	apply()

	if border_node: orig_border_y = border_node.position.y
	if indicator_node: orig_indicator_y = indicator_node.position.y
	if margin_node: orig_margin_y = margin_node.position.y
	if overlay_node: orig_overlay_y = overlay_node.position.y
	if highlight_node: orig_highlight_y = highlight_node.position.y

	gui_input.connect(_on_gui_input)
	mouse_entered.connect(_on_mouse_entered)
	mouse_exited.connect(_on_mouse_exited)

	if locked:
		focus_mode = Control.FOCUS_NONE
	else:
		focus_mode = Control.FOCUS_ALL
		focus_entered.connect(_on_focus_enter)
		focus_exited.connect(_on_focus_exit)


func apply() -> void:
	if locked:
		indicator_node.color = Palette.SURFACE1
		tab_locked_status_node.current_tab = LOCKED_TAB
	else:
		mouse_default_cursor_shape = Control.CURSOR_POINTING_HAND
		indicator_node.color = _get_difficulty_color(difficulty)
		tab_locked_status_node.current_tab = UNLOCKED_TAB
		progress_node.value = progress
		
		if progress == 100.0:
			progress_tab_node.current_tab = FINISHED_TAB
		else:
			progress_tab_node.current_tab = UNFINISHED_TAB

			var star_nodes = stars_node.get_children()
			for i in range(star_nodes.size()):
				if star_nodes[i] is TextureRect:
					star_nodes[i].modulate = Palette.YELLOW if i < stars else Palette.SURFACE2


func _on_gui_input(event: InputEvent) -> void:
	if locked: return

	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT:
		if event.is_pressed():
			_on_button_down()
			GameManager.play_level(level_no)
		elif event.is_released():
			_on_button_up()

	if has_focus() and event.is_action_pressed("continue"):
		accept_event()
		GameManager.play_level(level_no)


func _get_difficulty_color(p_difficulty: LevelDef.LevelDifficulty) -> Color:
	var color = Palette.OVERLAY2
	match p_difficulty:
		LevelDef.LevelDifficulty.EASY:
			color = Palette.GREEN
		LevelDef.LevelDifficulty.MEDIUM:
			color = Palette.YELLOW
		LevelDef.LevelDifficulty.HARD:
			color = Palette.RED
		LevelDef.LevelDifficulty.SPECIAL:
			color = Palette.MAUVE
	return color


func animate_lift(offset: float, brightness: float) -> void:
	if locked: return

	if active_tween and active_tween.is_valid():
		active_tween.kill()

	active_tween = create_tween().set_parallel(true)
	
	if border_node:
		active_tween.tween_property(border_node, "position:y", orig_border_y - offset, 0.1)\
			.set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
	if indicator_node:
		active_tween.tween_property(indicator_node, "position:y", orig_indicator_y - offset, 0.1)\
			.set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
	if margin_node:
		active_tween.tween_property(margin_node, "position:y", orig_margin_y - offset, 0.1)\
			.set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
	if highlight_node:
		active_tween.tween_property(highlight_node, "position:y", orig_highlight_y - offset, 0.1)\
			.set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
	if overlay_node:
		active_tween.tween_property(overlay_node, "position:y", orig_margin_y - offset, 0.1)\
			.set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
		active_tween.tween_property(overlay_node, "color:a", brightness, 0.1)\
				.set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)


func _on_mouse_entered() -> void:
	if locked: return

	is_hovered = true
	animate_lift(HOVER_Y_DELTA, 0.1)


func _on_mouse_exited() -> void:
	if locked: return

	is_hovered = false
	animate_lift(0.0, 0.0)


func _on_button_down() -> void:
	animate_lift(PRESS_Y_DELTA, 0.2)


func _on_button_up() -> void:
	var mouse_pos = get_local_mouse_position()
	var is_mouse_inside = Rect2(Vector2.ZERO, size).has_point(mouse_pos)
	
	if is_mouse_inside:
		animate_lift(HOVER_Y_DELTA, 0.1)
	else:
		animate_lift(0.0, 0.0)


func _on_focus_enter() -> void:
	highlight_node.color = Palette.LAVENDER


func _on_focus_exit() -> void:
	highlight_node.color = Color.TRANSPARENT

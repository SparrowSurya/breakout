extends CanvasLayer

@export var levels_grid_node: GridContainer
@export var back_button_node: Button
@export var star_icon_node: TextureRect
@export var page_nav_node: PageNav
@export var footer_node: Label
@export var star_progress_node: Label

const GRID_CAP: int = 16

var level_page: int = 1
var page_count: int = 1
var level_card_scene: PackedScene = preload(Constants.SCENE.LevelCard)


func _ready() -> void:
	page_count = ceil(float(LevelDef.level_count) / float(GRID_CAP))

	star_progress_node.text = "%d/%d" % [UserProgress.stars_collected(), LevelDef.level_count * 3]
	star_icon_node.modulate = Palette.YELLOW

	_update_page_footer(page_count, level_page)

	page_nav_node.total_pages = page_count
	page_nav_node.current_page = level_page

	page_nav_node.page_update.connect(_on_page_update)
	back_button_node.pressed.connect(_on_back_button_clicked)

	_fill_levels()


func _unhandled_input(event: InputEvent) -> void:
	if get_viewport().gui_get_focus_owner() == null:
		if event.is_action_pressed("ui_focus_next") or event.is_action_pressed("ui_focus_prev") \
		or event.is_action_pressed("ui_up") or event.is_action_pressed("ui_down") \
		or event.is_action_pressed("ui_left") or event.is_action_pressed("ui_right"):
			_focus_best_control()
			get_viewport().set_input_as_handled()


func _fill_levels() -> void:
	var old_focus_owner = get_viewport().gui_get_focus_owner() if is_inside_tree() else null
	var had_grid_focus = false
	if old_focus_owner and is_instance_valid(old_focus_owner) and levels_grid_node.is_ancestor_of(old_focus_owner):
		had_grid_focus = true

	for child in levels_grid_node.get_children():
		child.queue_free()
	
	var focus_level = UserProgress.highest_unlocked_level()
	var level_begin = (level_page-1) * GRID_CAP
	var level_end = min(level_begin + GRID_CAP, LevelDef.level_count)
	
	var card_to_focus: Control = null
	var first_unlocked_card: Control = null

	for level in range(level_begin+1, level_end+1): # Index=0 equals Level-1
		var level_card: LevelCard = level_card_scene.instantiate()
		var level_progress = UserProgress.get_level(level)
		var level_data = LevelDef.load_level(level)

		level_card.level_no = level_progress.level_no
		level_card.locked = level_progress.status == LevelProgress.LevelStatus.LOCKED
		level_card.progress = level_progress.progress
		level_card.stars = level_progress.stars

		if level_data != null:
			level_card.difficulty = level_data.difficulty

		levels_grid_node.add_child(level_card)

		if not level_card.locked and first_unlocked_card == null:
			first_unlocked_card = level_card

		if level == focus_level:
			card_to_focus = level_card

	if card_to_focus == null:
		card_to_focus = first_unlocked_card

	if old_focus_owner == null or had_grid_focus:
		if card_to_focus != null:
			card_to_focus.grab_focus()
			card_to_focus.call_deferred("grab_focus")
		elif not page_nav_node.prev_button_node.disabled:
			page_nav_node.prev_button_node.grab_focus()
		else:
			back_button_node.grab_focus()


func _focus_best_control() -> void:
	for child in levels_grid_node.get_children():
		if child is LevelCard and not child.locked:
			child.grab_focus()
			return
	if not back_button_node.disabled:
		back_button_node.grab_focus()


func _update_page_footer(total_pages: int, current_page: int) -> void:
	footer_node.text = "Page %d/%d" % [current_page, total_pages]


func _on_page_update(total_pages: int, current_page: int) -> void:
	level_page = current_page
	_update_page_footer(total_pages, current_page)
	_fill_levels()


func _on_back_button_clicked() -> void:
	GameManager.navigate_to_mainmenu()

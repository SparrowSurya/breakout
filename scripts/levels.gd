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
var level_label_scene: PackedScene = preload(Constants.SCENE.LevelLabel)


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


func _fill_levels() -> void:
	for child in levels_grid_node.get_children():
		child.queue_free()
	
	var focus_level = UserProgress.highest_unlocked_level()
	var level_begin = (level_page-1) * GRID_CAP
	var level_end = min(level_begin + GRID_CAP, LevelDef.level_count)
	
	for level in range(level_begin+1, level_end+1): # Index=0 equals Level-1
		var level_label: LevelLabel = level_label_scene.instantiate()
		var level_progress = UserProgress.of_level(level)
		var level_data = LevelDef.load_level(level)

		level_label.level_no = level_progress.level_no
		level_label.locked = level_progress.status == LevelProgress.LevelStatus.LOCKED
		level_label.progress = level_progress.progress
		level_label.stars = level_progress.stars

		if level_data != null:
			level_label.difficulty = level_data.difficulty

		levels_grid_node.add_child(level_label)

		if level == focus_level:
			level_label.grab_focus()


func _update_page_footer(total_pages: int, current_page: int) -> void:
	footer_node.text = "Page %d/%d" % [current_page, total_pages]


func _on_page_update(total_pages: int, current_page: int) -> void:
	_update_page_footer(total_pages, current_page)


func _on_back_button_clicked() -> void:
	get_tree().change_scene_to_file(Constants.SCENE.MainMenu)

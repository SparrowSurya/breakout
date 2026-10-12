extends CanvasLayer

@export var levels_grid_node: GridContainer
@export var back_button: Button

const LEVELS_COUNT: int = 15 # TODO: needs to be read from somewhere else
const GRID_CAP: int = 15

var level_page: int = 0
var level_label_scene: PackedScene = preload(Constants.SCENE.LevelLabel)


func _ready() -> void:
	back_button.pressed.connect(_on_back_button_clicked)
	_fill_levels()


func _fill_levels() -> void:
	for child in levels_grid_node.get_children():
		child.queue_free()

	var level_begin = level_page * GRID_CAP
	var level_end = level_begin + min(GRID_CAP, LEVELS_COUNT - level_begin)
	for level in range(level_begin+1, level_end+1): # Index=0 equals Level-1
		var level_label = level_label_scene.instantiate()
		level_label.level = level
		levels_grid_node.add_child(level_label)


func _on_back_button_clicked() -> void:
	get_tree().change_scene_to_file(Constants.SCENE.MainMenu)

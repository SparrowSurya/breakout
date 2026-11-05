class_name LoseMenu
extends PanelContainer

@export var heading_label: Label
@export var level_label: Label
@export var level_value: Label
@export var time_label: Label
@export var time_value: Label
@export var progress_label: Label
@export var progress_value: Label
@export var stars_row: HBoxContainer
@export var level_row: HBoxContainer
@export var time_row: HBoxContainer
@export var progress_row: HBoxContainer
@export var progress_bar: ProgressBar
@export var play_next_button: CustomButton
@export var play_again_button: CustomButton
@export var exit_button: CustomButton


func _ready() -> void:
	_setup(GameManager.game_mode())
	hide()


func _setup(mode: GameManager.GameMode) -> void:
	heading_label.text = "YOU LOSE!"
	level_label.text = "LEVEL"
	level_value.text = "000"
	time_label.text = "TIME TAKEN"
	time_value.text = "00:00"
	progress_label.text = "PROGRESS"
	progress_value.text = "00%"
	progress_bar.value = 0.0

	for i in range(stars_row.get_children().size()):
		var star_node = stars_row.get_child(i)
		if star_node is TextureRect:
			star_node.modulate = Palette.SURFACE2

	if mode == GameManager.GameMode.QUICK:
		stars_row.hide()
		level_row.hide()


func update(time: float, progress: float, level_no: int = -1) -> void:
	time_value.text = Utils.format_time(time)
	progress_value.text = "%02d%%" % int(progress)
	progress_bar.value = progress
	
	if level_no != -1:
		level_value.text = "%03d" % level_no
	
	if GameManager.game_mode() == GameManager.GameMode.LEVEL:
		if GameManager.is_level_unlocked(level_no+1):
			play_next_button.show()
		else:
			play_next_button.hide()

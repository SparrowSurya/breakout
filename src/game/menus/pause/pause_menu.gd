class_name PauseMenu
extends PanelContainer


@export_group("Nodes")
@export var number_label: Label
@export var number_value: Label
@export var time_label: Label
@export var time_value: Label
@export var progress_label: Label
@export var progress_value: Label
@export var progress_bar: ProgressBar
@export var number_row: HBoxContainer
@export var time_row: HBoxContainer
@export var progress_row: HBoxContainer
@export var resume_button: CustomButton
@export var restart_button: CustomButton
@export var exit_button: CustomButton


func _ready() -> void:
	_setup(GameManager.game_mode())


func _setup(mode: GameManager.GameMode) -> void:
	number_label.text = _number_label(mode)
	number_value.text = "000"
	time_label.text = _time_label(mode)
	progress_label.text = _progress_label(mode)
	progress_value.text = "00%"
	progress_bar.value = 0.0

	if mode == GameManager.GameMode.QUICK:
		number_row.hide()
	elif mode == GameManager.GameMode.LEVEL:
		number_value.text = "%03d" % GameManager.level_data.level_no


func update(progress: float, time: float, no: int = -1) -> void:
	if no != -1:
		number_value.text = "%03d" % no
	time_value.text = Utils.format_time(time)
	progress_bar.value = progress
	progress_value.text = "%02d%%" % int(progress)


func _number_label(mode: GameManager.GameMode) -> String:
	match mode:
		GameManager.GameMode.LEVEL:
			return "LEVEL"
		GameManager.GameMode.SURVIVAL:
			return "STAGE"
	return ""


func _time_label(_mode: GameManager.GameMode) -> String:
	return "TIME"


func _progress_label(_mode: GameManager.GameMode) -> String:
	return "PROGRESS"

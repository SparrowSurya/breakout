class_name LevelPauseMenu
extends PanelContainer

# Nodes
@export var level_value: Label
@export var progress_value: Label
@export var progress_bar: ProgressBar
@export var resume_button: CustomButton
@export var restart_button: CustomButton
@export var exit_button: CustomButton


## Updates the values in the nodes.
func update(level: String, progress: float) -> void:
	level_value.text = level
	progress_value.text = "%02d%%" % int(progress)
	progress_bar.value = progress

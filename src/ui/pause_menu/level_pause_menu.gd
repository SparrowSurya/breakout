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
func update(level: int, progress: float) -> void:
	level_value.text = "%03d" % level
	progress_value.text = "%02d%%" % int(progress)
	progress_bar.value = progress
	resume_button.grab_focus()

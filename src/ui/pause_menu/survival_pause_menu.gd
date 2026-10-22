class_name SurvivalPauseMenu
extends PanelContainer

# Nodes
@export var stage_value: Label
@export var time_value: Label
@export var progress_value: Label
@export var progress_bar: ProgressBar
@export var resume_button: CustomButton
@export var restart_button: CustomButton
@export var exit_button: CustomButton


## Updates the values in the nodes.
func update(stage: int, progress: float, time: String) -> void:
	stage_value.text = "%03d" % stage
	time_value.text = time
	progress_value.text = "%02d%%" % int(progress)
	progress_bar.value = progress
	restart_button.grab_focus()

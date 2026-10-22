class_name QuickLoseMenu
extends PanelContainer

@export var time_value: Label
@export var progress_value: Label
@export var progress_bar: ProgressBar
@export var replay_button: CustomButton
@export var exit_button: CustomButton


## Updates the values in the nodes.
func update(time: String, progress: float) -> void:
	time_value.text = time
	progress_value.text = "%02d%%" % int(progress)
	progress_bar.value = progress
	replay_button.grab_focus()

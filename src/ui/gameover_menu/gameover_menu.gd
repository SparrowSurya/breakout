class_name GameoverMenu
extends PanelContainer

# Ndoes
@export var score_value: Label
@export var new_best: Label
@export var stage_value: Label
@export var time_value: Label
@export var progress_value: Label
@export var progress_bar: ProgressBar
@export var play_again_button: CustomButton
@export var exit_button: CustomButton


## Updates the values in the nodes.
func update(stage: String, score: String, progress: float, time: String, best: bool) -> void:
	score_value.text = score
	score_value.modulate = Palette.YELLOW if best else Palette.TEXT
	if best:
		new_best.show()
	else:
		new_best.hide()
	stage_value.text = stage
	time_value.text = time
	progress_value.text = "%02d%%" % int(progress)
	progress_bar.value = progress

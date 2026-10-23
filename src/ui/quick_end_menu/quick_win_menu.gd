class_name QuickWinMenu
extends PanelContainer


@export var time_value: Label
@export var lives_value: Label
@export var replay_button: CustomButton
@export var exit_button: CustomButton


## Updates the values in the nodes.
func update(time: String, lives: int) -> void:
	time_value.text = time
	lives_value.text = str(lives)

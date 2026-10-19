class_name PauseMenu
extends Control

# Nodes
@export var level_node: Label
@export var progress_node: Label
@export var progress_bar: ProgressBar
@export var resume_button: CustomButton
@export var restart_button: CustomButton
@export var exit_button: CustomButton


func _ready() -> void:
	progress_bar.min_value = Constants.PROGRESS_MIN
	progress_bar.max_value = Constants.PROGRESS_MAX


## Performs reusable reset type actions.
func setup() -> void:
	pass

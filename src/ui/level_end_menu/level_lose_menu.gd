class_name LevelLoseMenu
extends PanelContainer

# Nodes
@export var stars_node: HBoxContainer
@export var level_value: Label
@export var time_value: Label
@export var progress_value: Label
@export var progress_bar: ProgressBar
@export var play_again_button: CustomButton
@export var exit_button: CustomButton


func _ready() -> void:
	for star_node in stars_node.get_children():
		if star_node is TextureRect:
			star_node.modulate = Palette.SURFACE2


## Updates the values in the nodes.
func update(level: String, time: String, progress: float) -> void:
	level_value.text = level
	time_value.text = time
	progress_value.text = "%02d%%" % int(progress)
	progress_bar.value = progress

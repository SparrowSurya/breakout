class_name LevelLoseMenu
extends PanelContainer

# Nodes
@export var stars_node: HBoxContainer
@export var level_node: Label
@export var time_node: Label
@export var progress_node: Label
@export var progress_bar: ProgressBar
@export var play_again_button: CustomButton
@export var exit_button: CustomButton


func _ready() -> void:
	for star_node in stars_node.get_children():
		if star_node is TextureRect:
			star_node.modulate = Palette.SURFACE2


## Updates the values in the nodes.
func update(level_no: int, time: String, progress: float) -> void:
	level_node.text = str(level_no).pad_zeros(3)
	time_node.text = time
	progress_node.text = "%02d%%" % int(progress)
	progress_bar.value = progress
	play_again_button.grab_focus()

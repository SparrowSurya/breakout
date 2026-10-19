class_name WinMenu
extends PanelContainer

# Nodes
@export var stars_node: HBoxContainer
@export var level_node: Label
@export var time_node: Label
@export var lives_node: Label
@export var play_next_button: CustomButton
@export var play_again_button: CustomButton
@export var exit_button: CustomButton


## Applies the value to the nodes.
func apply(level_no: int, time: String, lives: int) -> void:
	level_node.text = str(level_no).pad_zeros(3)
	time_node.text = time
	lives_node.text = str(lives)

	for i in range(stars_node.get_children().size()):
		var star_node = stars_node.get_child(i)
		if star_node is TextureRect:
			star_node.modulate = Palette.YELLOW if i < lives else Palette.SURFACE2
	
	if GameManager.has_level(level_no+1):
		play_next_button.grab_focus()
	else:
		play_next_button.hide()
		exit_button.grab_focus()

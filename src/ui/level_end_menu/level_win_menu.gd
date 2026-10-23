class_name LevelWinMenu
extends PanelContainer

# Nodes
@export var stars_node: HBoxContainer
@export var level_value: Label
@export var time_value: Label
@export var lives_value: Label
@export var play_next_button: CustomButton
@export var play_again_button: CustomButton
@export var exit_button: CustomButton


## Updates the values in the nodes.
func update(level: String, time: String, lives: int, has_next_level: bool) -> void:
	level_value.text = level
	time_value.text = time
	lives_value.text = str(lives)

	for i in range(stars_node.get_children().size()):
		var star_node = stars_node.get_child(i)
		if star_node is TextureRect:
			star_node.modulate = Palette.YELLOW if i < lives else Palette.SURFACE2
	
	if has_next_level:
		play_next_button.show()
	else:
		play_next_button.hide()

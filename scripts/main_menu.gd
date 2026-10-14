extends CanvasLayer


@export var levels_button: Button
@export var initial_focus: Control


func _ready() -> void:
	levels_button.pressed.connect(_on_levels_button_pressed)
	if initial_focus:
		initial_focus.grab_focus()


func _on_levels_button_pressed() -> void:
	get_tree().change_scene_to_file(Constants.SCENE.Levels)

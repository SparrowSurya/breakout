extends CanvasLayer


@export var levels_button: Button


func _ready() -> void:
	levels_button.pressed.connect(_on_levels_button_pressed)


func _on_levels_button_pressed() -> void:
	get_tree().change_scene_to_file(Constants.SCENE.Levels)

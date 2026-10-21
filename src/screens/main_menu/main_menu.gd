extends CanvasLayer


@export var initial_focus: Control
@export var levels_button: Button
@export var survival_button: CustomButton


func _ready() -> void:
	levels_button.pressed.connect(_on_levels_button_pressed)
	survival_button.pressed.connect(_on_survival_button_pressed)
	if initial_focus:
		initial_focus.grab_focus()


func _on_levels_button_pressed() -> void:
	GameManager.navigate_to_select_level()


func _on_survival_button_pressed() -> void:
	GameManager.play_survival()

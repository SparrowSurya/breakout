extends CanvasLayer


@export var initial_focus: Control
@export var levels_button: Button
@export var survival_button: CustomButton
@export var highscore_value: Label
@export var version_value: Label


func _ready() -> void:
	levels_button.pressed.connect(_on_levels_button_pressed)
	survival_button.pressed.connect(_on_survival_button_pressed)

	highscore_value.text = "%06d" % UserProgress.highscore
	version_value.text = "v%d.%d.%d" % [Constants.VERSION_MAJOR, Constants.VERSION_MINOR, Constants.VERSION_PATCH]

	if initial_focus:
		initial_focus.grab_focus()


func _on_levels_button_pressed() -> void:
	GameManager.navigate_to_select_level()


func _on_survival_button_pressed() -> void:
	GameManager.play_survival()

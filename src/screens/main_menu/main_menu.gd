extends CanvasLayer


@export var quick_play_button: CustomButton
@export var levels_button: Button
@export var survival_button: CustomButton
@export var highscore_value: Label
@export var version_value: Label


func _ready() -> void:
	quick_play_button.pressed.connect(_on_quick_play_button_pressed)
	levels_button.pressed.connect(_on_levels_button_pressed)
	survival_button.pressed.connect(_on_survival_button_pressed)

	highscore_value.text = "%06d" % UserProgress.highscore
	version_value.text = "v%d.%d.%d" % [Constants.VERSION_MAJOR, Constants.VERSION_MINOR, Constants.VERSION_PATCH]

	quick_play_button.grab_focus()


func _on_quick_play_button_pressed() -> void:
	GameManager.quick_play()


func _on_levels_button_pressed() -> void:
	GameManager.navigate_to_select_level()


func _on_survival_button_pressed() -> void:
	GameManager.play_survival()

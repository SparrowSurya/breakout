extends Control

@export var background: ColorRect
@export var button: Button
@export var level: int = 1


func _ready() -> void:
	button.text = str(level)
	button.pressed.connect(_on_button_clicked)


func _on_button_clicked() -> void:
	print("TODO: Goto level %s", level)

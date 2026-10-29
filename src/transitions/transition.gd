class_name Transition
extends CanvasLayer

signal transition_half_finished ## Screen fully covered: safe to swap the scene.
signal transition_finished      ## Screen fully revealed again.

@export var cover_time: float = 0.15
@export var reveal_time: float = 0.15

@export var blocker: Control ## Full rectangle which eats input


func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS


func cover() -> void:
	blocker.mouse_filter = Control.MOUSE_FILTER_STOP
	@warning_ignore("redundant_await")
	await _cover()
	transition_half_finished.emit()


func reveal() -> void:
	@warning_ignore("redundant_await")
	await _reveal()
	blocker.mouse_filter = Control.MOUSE_FILTER_IGNORE
	transition_finished.emit()



func _cover() -> void:
	pass

func _reveal() -> void:
	pass

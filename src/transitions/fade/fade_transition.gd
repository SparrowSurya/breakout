extends Transition

@export var rect: ColorRect


func _ready() -> void:
	super._ready()
	rect.modulate.a = 0.0


func _cover() -> void:
	var t := create_tween()
	t.tween_property(rect, "modulate:a", 1.0, cover_time)
	await t.finished


func _reveal() -> void:
	var t := create_tween()
	t.tween_property(rect, "modulate:a", 0.0, reveal_time)
	await t.finished

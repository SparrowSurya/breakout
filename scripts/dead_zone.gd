extends Area2D

signal ball_entered


func _on_body_entered(body: Node2D) -> void:
	if body is Ball:
		ball_entered.emit()

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

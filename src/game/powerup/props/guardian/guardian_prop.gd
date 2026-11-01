class_name GuardianProp
extends StaticBody2D

@export var sprite: Sprite2D
@export var collision_shape: CollisionShape2D


func _ready() -> void:
	disable()


func enable() -> void:
	show()
	if collision_shape:
		collision_shape.set_deferred("disabled", false)


func disable() -> void:
	hide()
	if collision_shape:
		collision_shape.set_deferred("disabled", true)

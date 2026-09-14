class_name Paddle
extends CharacterBody2D

@export var sprite: Sprite2D

const SPEED: float = 380

var window_size: Vector2
var paddle_size: Vector2
var is_playing: bool = false


func _ready() -> void:
	window_size = get_viewport().get_visible_rect().size
	paddle_size = sprite.get_rect().size


func _physics_process(delta: float) -> void:
	if not is_playing:
		return

	if Input.is_action_pressed("move_left"):
		_move_left(SPEED * delta)
	elif Input.is_action_pressed("move_right"):
		_move_right(SPEED * delta)


func _move_left(amount: float) -> void:
	var left = position.x - paddle_size.x/2
	if (left - amount) >= 0:
		position.x -= amount
	else:
		position.x = paddle_size.x/2


func _move_right(amount: float) -> void:
	var right = position.x + paddle_size.x/2
	if (right + amount) < window_size.x:
		position.x += amount
	else:
		position.x = window_size.x - paddle_size.x/2 - 1


func get_width() -> float:
	return sprite.get_rect().size.x

class_name Paddle
extends CharacterBody2D


@export var sprite: Sprite2D

const SPEED: float = 480

var window_size: Vector2
var paddle_size: Vector2


func _ready() -> void:
	window_size = get_viewport().get_visible_rect().size
	paddle_size = sprite.get_rect().size


func _physics_process(delta: float) -> void:
	if GameManager.game_state != GameManager.GameState.PLAYING:
		return

	if Input.is_action_pressed("move_left"):
		_move_left(SPEED * delta)
	elif Input.is_action_pressed("move_right"):
		_move_right(SPEED * delta)


func _move_left(amount: float) -> void:
	var half_width = paddle_size.x / 2
	position.x = clampf(position.x - amount, half_width, window_size.x - half_width)


func _move_right(amount: float) -> void:
	var half_width = paddle_size.x / 2
	position.x = clampf(position.x + amount, half_width, window_size.x - half_width)


func get_width() -> float:
	return sprite.get_rect().size.x

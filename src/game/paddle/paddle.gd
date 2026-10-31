class_name Paddle
extends CharacterBody2D


@export var sprite: Sprite2D

const SPEED: float = 480.0

var window_size: Vector2
var paddle_size: Vector2

var touch_y_min: float = 0.0
var touch_y_max: float = 0.0

var _width_mods: Dictionary[StringName, float] = {}
var _speed_mods: Dictionary[StringName, float] = {}


func _ready() -> void:
	window_size = get_viewport().get_visible_rect().size
	paddle_size = sprite.get_rect().size


func _physics_process(delta: float) -> void:
	if GameManager.game_state != GameManager.GameState.PLAYING:
		return

	var current_speed = get_speed()

	if Input.is_action_pressed("move_left"):
		move_left(current_speed * delta)
	elif Input.is_action_pressed("move_right"):
		move_right(current_speed * delta)
	elif Input.is_mouse_button_pressed(MOUSE_BUTTON_LEFT):
		var pos: Vector2 = get_viewport().get_mouse_position()
		var mid_x = window_size.x / 2.0

		if touch_y_min <= pos.y and pos.y <= touch_y_max:
			if pos.x < mid_x:
				move_left(current_speed * delta)
			else:
				move_right(current_speed * delta)


func move_left(amount: float) -> void:
	var half_width = (paddle_size.x * scale.x) / 2.0
	position.x = clampf(position.x - amount, half_width, window_size.x - half_width)


func move_right(amount: float) -> void:
	var half_width = (paddle_size.x * scale.x) / 2.0
	position.x = clampf(position.x + amount, half_width, window_size.x - half_width)


func get_width() -> float:
	return paddle_size.x * scale.x


func set_width_mod(key: StringName, mult: float) -> void:
	_width_mods[key] = mult
	_apply_width()


func clear_width_mod(key: StringName) -> void:
	_width_mods.erase(key)
	_apply_width()


func _apply_width() -> void:
	var m: float = 1.0
	for v in _width_mods.values():
		m *= v
	scale.x = m
	# Clamp position immediately so paddle doesn't poke outside window
	var half_width = (paddle_size.x * scale.x) / 2.0
	position.x = clampf(position.x, half_width, window_size.x - half_width)


func set_speed_mod(key: StringName, mult: float) -> void:
	_speed_mods[key] = mult


func clear_speed_mod(key: StringName) -> void:
	_speed_mods.erase(key)


func get_speed() -> float:
	var m: float = 1.0
	for v in _speed_mods.values():
		m *= v
	return SPEED * m

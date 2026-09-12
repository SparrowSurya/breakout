class_name Ball
extends CharacterBody2D

@onready var sprite: Sprite2D = $Sprite2D
@onready var sfx: AudioStreamPlayer2D = $AudioStreamPlayer2D

const SPEED: float = 360.0
const MAX_ANGLE_RAD: float = deg_to_rad(60.0)

const HIT_PADDLE_SOUND = preload("res://assets/sounds/Ball-Hit-Paddle.wav")
const HIT_WALL_SOUND = preload("res://assets/sounds/Ball-Hit-Wall.wav")

var window_size: Vector2
var ball_size: Vector2
var is_playing: bool = false

func _ready() -> void:
	window_size = get_viewport().get_visible_rect().size
	ball_size = sprite.get_rect().size
	setup()

func setup() -> void:
	velocity = Vector2(0, SPEED)

func _physics_process(delta: float) -> void:
	if not is_playing:
		return

	var collision = move_and_collide(velocity * delta)
	if collision:
		var collider = collision.get_collider()
		if collider is Paddle:
			bounce_from_paddle(collider)
			_play(HIT_PADDLE_SOUND)
		elif collider is Tile:
			collider.hit()
			velocity = velocity.bounce(collision.get_normal())
		else: # Wall
			velocity = velocity.bounce(collision.get_normal())
			_play(HIT_WALL_SOUND)


func bounce_from_paddle(paddle: Paddle) -> void:
	var paddle_width = paddle.get_width()

	var hit_position = global_position.x - paddle.global_position.x
	var hit_ratio = hit_position / (paddle_width / 2.0)
	hit_ratio = clamp(hit_ratio, -1.0, 1.0)

	var base_angle = hit_ratio * MAX_ANGLE_RAD
	var random_angle = randf_range(deg_to_rad(-5.0), deg_to_rad(5.0))
	var angle = clamp(base_angle + random_angle, -MAX_ANGLE_RAD, MAX_ANGLE_RAD)

	velocity = Vector2(sin(angle), -cos(angle)) * SPEED


func _play(stream: AudioStream) -> void:
	sfx.stream = stream
	sfx.play()

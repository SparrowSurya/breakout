class_name Ball
extends CharacterBody2D

const BALL_SPEED: float = 280.0
const MAX_ANGLE_RAD: float = deg_to_rad(60.0)

@export var sprite: Sprite2D
@export var audio: AudioStreamPlayer2D

var window_size: Vector2
var ball_size: Vector2
var is_playing: bool = false

func _ready() -> void:
	window_size = get_viewport().get_visible_rect().size
	ball_size = sprite.get_rect().size
	setup()


func _physics_process(delta: float) -> void:
	if not is_playing:
		return

	var collision = move_and_collide(velocity * delta)
	if collision:
		var collider = collision.get_collider()

		if collider is Paddle:
			bounce_from_paddle(collider)
			play_sound(Constants.SOUND.BallHitPaddle)
			#paddle_collide_resolve(collision)
		elif collider is Tile:
			collider.hit()
			velocity = velocity.bounce(collision.get_normal())
		else: # Wall
			velocity = velocity.bounce(collision.get_normal())
			play_sound(Constants.SOUND.BallHitWall)


func setup() -> void:
	velocity = Vector2(0, BALL_SPEED)


func bounce_from_paddle(paddle: Paddle) -> void:
	var paddle_width = paddle.get_width()

	var hit_position = global_position.x - paddle.global_position.x
	var hit_ratio = hit_position / (paddle_width / 2.0)
	hit_ratio = clamp(hit_ratio, -1.0, 1.0)

	var base_angle = hit_ratio * MAX_ANGLE_RAD
	var random_angle = randf_range(deg_to_rad(-5.0), deg_to_rad(5.0))
	var angle = clamp(base_angle + random_angle, -MAX_ANGLE_RAD, MAX_ANGLE_RAD)

	velocity = Vector2(sin(angle), -cos(angle)) * BALL_SPEED


func paddle_collide_resolve(collision: KinematicCollision2D) -> void:
	if not collision:
		return
	
	var collider = collision.get_collider()
	if collider is not Paddle:
		return
	
	var max_iterations = 10
	var iteration = 0
	var new_collision = collision

	while iteration < max_iterations and new_collision and new_collision.get_collider() is Paddle:
		var normal = new_collision.get_normal()
		var remainder = new_collision.get_remainder().bounce(normal)
		new_collision = move_and_collide(remainder)
		iteration += 1


func play_sound(stream: AudioStream) -> void:
	audio.stream = stream
	audio.play()

class_name Ball
extends CharacterBody2D

signal on_hit_paddle(ball: Ball, paddle: Paddle)

const BALL_SPEED: float = 420.0
const MAX_ANGLE_RAD: float = deg_to_rad(60.0)

@export var sprite: Sprite2D
@export var damage: int = 1    ## Damange done by ball to tile.

var window_size: Vector2
var ball_size: Vector2

## Since ball and paddle can overlap we need to ignore paddle.
var _ignored_paddle: Paddle = null


func _ready() -> void:
	window_size = get_viewport().get_visible_rect().size
	ball_size = sprite.get_rect().size
	setup()


func _physics_process(delta: float) -> void:
	if GameManager.game_state != GameManager.GameState.PLAYING:
		return

	_release_paddle_if_clear()

	var collision = move_and_collide(velocity * delta)
	if collision:
		var collider = collision.get_collider()

		if collider is Paddle:
			_on_paddle_hit(collider, collision)
			on_hit_paddle.emit(self, collider)
		elif collider is Tile:
			collider.hit(damage)
			velocity = velocity.bounce(collision.get_normal())
		else: # Wall
			velocity = velocity.bounce(collision.get_normal())
			SoundManager.play_sfx(Constants.SOUND.BallHitWall)


## Resets the attributes like velocity.
func setup() -> void:
	velocity = Vector2(0, BALL_SPEED)


## Sets random velocity of ball.
func set_random_velocity() -> void:
	var angle = randf_range(-MAX_ANGLE_RAD, MAX_ANGLE_RAD)
	velocity = Vector2(sin(angle), -cos(angle)) * BALL_SPEED


func bounce_from_paddle(paddle: Paddle) -> void:
	var paddle_width = paddle.get_width()

	var hit_position = global_position.x - paddle.global_position.x
	var hit_ratio = hit_position / (paddle_width / 2.0)
	hit_ratio = clamp(hit_ratio, -1.0, 1.0)

	var base_angle = hit_ratio * MAX_ANGLE_RAD
	var random_angle = randf_range(deg_to_rad(-5.0), deg_to_rad(5.0))
	var angle = clamp(base_angle + random_angle, -MAX_ANGLE_RAD, MAX_ANGLE_RAD)

	velocity = Vector2(sin(angle), -cos(angle)) * BALL_SPEED


## Removes the ball from scene.
func destroy() -> void:
	queue_free()


func _on_paddle_hit(paddle: Paddle, collision: KinematicCollision2D) -> void:
	bounce_from_paddle(paddle)
	SoundManager.play_sfx(Constants.SOUND.BallHitPaddle)

	# Nudge out of any overlap, then ignore the paddle until the ball is clear
	global_position += collision.get_normal() * (collision.get_depth() + 1.0)
	add_collision_exception_with(paddle)
	_ignored_paddle = paddle


func _release_paddle_if_clear() -> void:
	if _ignored_paddle == null:
		return

	# Ball is clearly above the paddle: safe to collide again
	if global_position.y < _ignored_paddle.global_position.y - ball_size.y * 1.5:
		remove_collision_exception_with(_ignored_paddle)
		_ignored_paddle = null

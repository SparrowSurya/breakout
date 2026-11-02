class_name Powerup
extends Area2D


## Signal emitted when powerup is collected.
signal collected(type: PowerupRegistry.PowerType, pos: Vector2)

@export var sprite: Sprite2D   ## Popwerup sprite

const MIN_FALL_SPEED: float = 75.0   ## Minimum falling speed of powerup
const MAX_FALL_SPEED: float = 125.0  ## Maximum falling speed of powerup

const HEALTH_COLORS: Array[Color] = [
	Palette.MAUVE,
	Palette.BLUE,
	Palette.GREEN,
	Palette.YELLOW,
	Palette.PEACH,
	Palette.RED,
]

var type: PowerupRegistry.PowerType  ## Type of the powerup
var fall_speed: float = 90.0         ## Randomized falling speed
var _color_tween: Tween = null


func _ready() -> void:
	add_to_group(PowerupManager.GROUP)
	fall_speed = randf_range(MIN_FALL_SPEED, MAX_FALL_SPEED)
	if sprite and PowerupRegistry.POWERUP.has(type):
		sprite.texture = PowerupRegistry.POWERUP[type]
	body_entered.connect(_on_body_entered)
	if type == PowerupRegistry.PowerType.PHASE_SHIFTER:
		_start_phase_shifter_animation()


func _start_phase_shifter_animation() -> void:
	if sprite == null:
		return
	sprite.self_modulate = HEALTH_COLORS[0]
	_color_tween = create_tween().set_loops()
	for i in range(1, HEALTH_COLORS.size()):
		_color_tween.tween_property(sprite, "self_modulate", HEALTH_COLORS[i], 0.35)
	for i in range(HEALTH_COLORS.size() - 2, -1, -1):
		_color_tween.tween_property(sprite, "self_modulate", HEALTH_COLORS[i], 0.35)


func _process(delta: float) -> void:
	if GameManager.game_state != GameManager.GameState.PLAYING:
		return
	position.y += fall_speed * delta
	if global_position.y > get_viewport_rect().size.y + 16.0:
		queue_free()


func _on_body_entered(body: Node2D) -> void:
	if body is Paddle:
		set_deferred("monitoring", false)
		collected.emit(type, global_position)
		queue_free()

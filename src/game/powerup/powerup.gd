class_name PowerupItem
extends Area2D

signal collected(type: int)

const FALL_SPEED: float = 90.0

@export var sprite: Sprite2D
var type: int


func _ready() -> void:
	add_to_group(PowerupManager.GROUP)
	if sprite == null:
		sprite = get_node_or_null("sprite")
	if sprite and PowerupRegistry.POWERUP.has(type):
		sprite.texture = PowerupRegistry.POWERUP[type]
	body_entered.connect(_on_body_entered)


func _process(delta: float) -> void:
	if GameManager.game_state != GameManager.GameState.PLAYING:
		return
	position.y += FALL_SPEED * delta
	if global_position.y > get_viewport_rect().size.y + 16.0:
		queue_free()


func _on_body_entered(body: Node2D) -> void:
	if body is Paddle:
		collected.emit(type)
		queue_free()

class_name Tile
extends StaticBody2D

enum TileType {
	MAUVE,
	BLUE,
	GREEN,
	YELLOW,
	PEACH,
	RED,
	METAL
}

@export var tile_type: TileType = TileType.GREEN

@onready var sprite: Sprite2D = $Sprite2D
@onready var sfx: AudioStreamPlayer2D = $AudioStreamPlayer2D
@onready var collision_shape: CollisionShape2D = $CollisionShape2D

const HIT_TILE_SOUND = preload("res://assets/sounds/Ball-Hit-Tile.wav")
const HIT_METAL_TILE_SOUND = preload("res://assets/sounds/Ball-Hit-Metal-Tile.wav")
const TILE_DESTORY_SOUND = preload("res://assets/sounds/Tile-Destroy.wav")

var immune: bool = false
var health: int = 1


func _ready() -> void:
	match tile_type:
		TileType.MAUVE:
			sprite.texture = preload("res://assets/sprites/tiles/mauve.png")
			health = 1
		TileType.BLUE:
			sprite.texture = preload("res://assets/sprites/tiles/blue.png")
			health = 2
		TileType.GREEN:
			sprite.texture = preload("res://assets/sprites/tiles/green.png")
			health = 3
		TileType.YELLOW:
			sprite.texture = preload("res://assets/sprites/tiles/yellow.png")
			health = 4
		TileType.PEACH:
			sprite.texture = preload("res://assets/sprites/tiles/peach.png")
			health = 5
		TileType.RED:
			sprite.texture = preload("res://assets/sprites/tiles/red.png")
			health = 6
		TileType.METAL:
			sprite.texture = preload("res://assets/sprites/tiles/metal.png")
			health = -1
			immune = true


func _process(_delta: float) -> void:
	pass


func hit() -> void:
	if immune:
		_play(HIT_METAL_TILE_SOUND)
		return
		
	health -= 1
	if health <= 0:
		_play(TILE_DESTORY_SOUND)
		destroy()
	else:
		_play(HIT_TILE_SOUND)


func destroy() -> void:
	get_parent().get_parent().tile_destroyed()
	
	hide()
	collision_shape.set_deferred("disabled", true)
	
	if sfx.playing:
		await sfx.finished
	
	queue_free()


func _play(stream: AudioStream) -> void:
	sfx.stream = stream
	sfx.play()

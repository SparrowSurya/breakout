class_name Tile
extends StaticBody2D

# Signal is used to identify the tile destoryed
signal destroyed(tile: Tile)

# Varitiey of tile we have.
enum TileType {
	
	# Destructiable
	MAUVE,
	BLUE,
	GREEN,
	YELLOW,
	PEACH,
	RED,
	
	# Indestructible
	METAL,
}

@export var tile_type: TileType = TileType.GREEN
@export var sprite: Sprite2D
@export var audio: AudioStreamPlayer2D
@export var collision_shape: CollisionShape2D

var is_immune: bool = false
var tile_health: int = 0
var shake_duration = 0.2 
var shake_intensity = 3.0
var shake_steps = 6
var particles_scene: PackedScene = preload(Constants.SCENE.Particles)


func _ready() -> void:
	setup_tile()


func setup_tile():
	is_immune = false
	match tile_type:
		TileType.MAUVE:
			sprite.texture = Constants.TILE.Mauve
			tile_health = 1
		TileType.BLUE:
			sprite.texture = Constants.TILE.Blue
			tile_health = 2
		TileType.GREEN:
			sprite.texture = Constants.TILE.Green
			tile_health = 3
		TileType.YELLOW:
			sprite.texture = Constants.TILE.Yellow
			tile_health = 4
		TileType.PEACH:
			sprite.texture = Constants.TILE.Peach
			tile_health = 5
		TileType.RED:
			sprite.texture = Constants.TILE.Red
			tile_health = 6
		TileType.METAL:
			sprite.texture = Constants.TILE.Metal
			is_immune = true


func hit() -> void:
	if is_immune:
		play_sound(Constants.SOUND.BallHitMetalTile)
		shake()
		return
		
	spawn_particles(position)

	tile_health -= 1
	if tile_health <= 0:
		play_sound(Constants.SOUND.TileDestroy)
		destroy()
		return

	play_sound(Constants.SOUND.BallHitTile)
	match tile_health:
		1:
			tile_type = TileType.MAUVE
			sprite.texture = Constants.TILE.Mauve
		2:
			tile_type = TileType.BLUE
			sprite.texture = Constants.TILE.Blue
		3:
			tile_type = TileType.GREEN
			sprite.texture = Constants.TILE.Green
		4:
			tile_type = TileType.YELLOW
			sprite.texture = Constants.TILE.Yellow
		5:
			tile_type = TileType.PEACH
			sprite.texture = Constants.TILE.Peach
		6:
			tile_type = TileType.RED
			sprite.texture = Constants.TILE.Red


func destroy() -> void:
	destroyed.emit(self)
	hide()
	collision_shape.set_deferred("disabled", true)

	if audio.playing:
		await audio.finished
	
	queue_free()


func spawn_particles(pos: Vector2) -> void:
	var particles = particles_scene.instantiate()
	get_tree().current_scene.add_child(particles)
	particles.global_position = pos
	
	var image := Image.create(2, 2, false, Image.FORMAT_RGBA8)
	var target_color = Constants.HEALTH_COLORS.get(tile_health, Color.WHITE)

	image.fill(target_color)
	particles.texture = ImageTexture.create_from_image(image)


func shake() -> void:
	var original_pos = sprite.position
	var tween = create_tween()
	
	for i in range(shake_steps):
		var random_offset = Vector2(
			randf_range(-shake_intensity, shake_intensity), 
			randf_range(-shake_intensity, shake_intensity)
		)
		tween.tween_property(sprite, "position", original_pos + random_offset, shake_duration / shake_steps)
	tween.tween_property(sprite, "position", original_pos, shake_duration / shake_steps)

func play_sound(stream: AudioStream) -> void:
	audio.stream = stream
	audio.play()

class_name Tile
extends StaticBody2D

# Signal is used to identify the tile destoryed
signal destroyed(tile: Tile)

@export var tile_type: TileDef.TileType = TileDef.TileType.GREEN
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
	_apply(TileDef.from_type(tile_type))


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
	_apply(TileDef.from_health(tile_health))


# Apply tile data entry to the tile live data.
func _apply(data: TileDef) -> void:
	tile_health = data.health
	tile_type = data.type
	is_immune = data.is_immune
	sprite.texture = data.texture


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
	var target_color = TileDef.from_health(tile_health).color

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

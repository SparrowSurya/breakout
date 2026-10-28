class_name Tile
extends StaticBody2D

# Signal emitted when tile takes damage.
signal on_hit(tile: Tile, effective_damage: int, destroyed: bool)

@export var tile_type: TileDef.TileType = TileDef.TileType.GREEN
@export var sprite: Sprite2D
@export var collision_shape: CollisionShape2D

var is_immune: bool = false
var tile_health: int = 0

var shake_duration: float = 0.2
var shake_intensity: float = 3.0
var shake_steps: int = 6

var particles_scene: PackedScene = preload(Constants.SCENE.Particles)

var _rest_pos: Vector2
var _shake_tween: Tween


func _ready() -> void:
	_rest_pos = sprite.position
	_apply(TileDef.from_type(tile_type))


func hit(damage: int = 1) -> void:
	if is_immune:
		SoundManager.play_sfx(Constants.SOUND.BallHitMetalTile)
		shake()
		return
	
	var effective_damage = tile_health if damage > tile_health else damage

	spawn_particles(global_position)
	tile_health -= damage
	if tile_health <= 0:
		SoundManager.play_sfx(Constants.SOUND.TileDestroy)
		on_hit.emit(self, effective_damage, true)
		destroy()
		return
	
	on_hit.emit(self, effective_damage, false)
	SoundManager.play_sfx(Constants.SOUND.BallHitTile)
	_apply(TileDef.from_health(tile_health))


# Apply tile data entry to the tile live data.
func _apply(data: TileDef) -> void:
	tile_health = data.health
	tile_type = data.type
	is_immune = data.is_immune
	sprite.texture = data.texture


func destroy() -> void:
	hide()
	collision_shape.set_deferred("disabled", true)
	queue_free()


func spawn_particles(pos: Vector2) -> void:
	var particles: HitParticles = particles_scene.instantiate()
	particles.global_position = pos
	particles.texture = TileDef.from_health(tile_health).particle_texture
	get_tree().current_scene.add_child(particles)


func shake() -> void:
	if _shake_tween and _shake_tween.is_valid():
		_shake_tween.kill()
	sprite.position = _rest_pos

	_shake_tween = create_tween()
	var step_time: float = shake_duration / shake_steps
	for i in range(shake_steps):
		var falloff: float = 1.0 - float(i) / shake_steps
		var offset := Vector2(
			randf_range(-shake_intensity, shake_intensity),
			randf_range(-shake_intensity, shake_intensity)
		) * falloff
		_shake_tween.tween_property(sprite, "position", _rest_pos + offset, step_time)
	_shake_tween.tween_property(sprite, "position", _rest_pos, step_time)

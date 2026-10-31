class_name PowerupManager
extends Node

signal activated(powerup: BasePowerup)
signal expired(powerup: BasePowerup)

const ITEM_SCENE := preload("res://src/game/powerup/powerup.tscn")
const GROUP := &"powerup_items"

var game: BaseGame
var config: PowerupConfig
var active: Dictionary = {}   ## type -> BasePowerup
var _since_drop: int = 0
var _interval_left: float = 0.0


func setup(p_game: BaseGame, p_config: PowerupConfig) -> void:
	game = p_game
	config = p_config
	clear()
	if config:
		_interval_left = config.interval


func clear() -> void:
	for p in active.values():
		p.deactivate()
	active.clear()
	clear_items()
	_since_drop = 0


func clear_items() -> void:
	for item in get_tree().get_nodes_in_group(GROUP):
		item.queue_free()


## Called by BaseGame only while the state is PLAYING, so pause stops the timers.
func tick(delta: float) -> void:
	for type in active.keys():
		var p: BasePowerup = active[type]
		p.tick(delta)
		p.remaining -= delta
		if p.remaining <= 0.0:
			active.erase(type)
			p.deactivate()
			expired.emit(p)

	if config and config.enabled and config.interval > 0.0:
		_interval_left -= delta
		if _interval_left <= 0.0:
			_interval_left = config.interval
			_drop(Vector2(randf_range(24.0, game.window_size.x - 24.0), -8.0))


func on_tile_destroyed(pos: Vector2) -> void:
	if config == null or not config.enabled:
		return
	_since_drop += 1
	var pity := config.pity_tiles > 0 and _since_drop >= config.pity_tiles
	if pity or randf() < config.drop_chance:
		_drop(pos)


func collect(type: int) -> void:
	if active.has(type):
		active[type].refresh()
		activated.emit(active[type])
		return
	var p := PowerupRegistry.create(type)
	if p == null:
		return
	p.game = game
	p.remaining = p.duration
	p.activate()
	if p.duration > 0.0:
		active[type] = p
	activated.emit(p)


## Ends a timed power-up early (e.g. Guardian after saving a ball).
func expire(type: int) -> void:
	if active.has(type):
		active[type].remaining = 0.0


## Weighted pick among types that are allowed by the config and eligible right now.
func pick(exclude: int = -1) -> int:
	if config == null or not config.enabled:
		return -1
	var pool := {}
	var total := 0.0
	for type in config.weights:
		var w: float = config.weights[type]
		if type == exclude or w <= 0.0:
			continue
		var instance = PowerupRegistry.create(type)
		if instance == null or not instance.can_spawn(game):
			continue
		pool[type] = w
		total += w
	if pool.is_empty():
		return -1
	var r := randf() * total
	for type in pool:
		r -= pool[type]
		if r <= 0.0:
			return type
	return pool.keys().back()


func _drop(pos: Vector2) -> void:
	if config == null or not config.enabled:
		return
	if get_tree().get_nodes_in_group(GROUP).size() >= config.max_falling:
		return
	var type := pick()
	if type < 0:
		return
	_since_drop = 0
	var item: PowerupItem = ITEM_SCENE.instantiate()
	item.type = type
	item.position = pos
	item.collected.connect(collect)
	game.add_child(item)

class_name PowerupManager
extends Node

signal activated(powerup: BasePowerup)  ## Emitted when powerup is activated
signal expired(powerup: BasePowerup)    ## EMitted when powerup expires

const POWERUP_SCENE := preload(Constants.SCENE.Powerup)
const GROUP := &"powerup_items"

var game: BaseGame               ## Game running
var config: PowerupConfig        ## Game powerup config
var active: Dictionary[PowerupRegistry.PowerType, BasePowerup] = {}
var recent_drops: Array[PowerupRegistry.PowerType] = []  ## History of up to last 3 spawned drops
var _since_drop: int = 0
var _interval_left: float = 0.0


## Initializes the manager with the target game instance and powerup configuration.
func setup(p_game: BaseGame, p_config: PowerupConfig) -> void:
	game = p_game
	config = p_config
	clear()
	if config:
		_interval_left = config.interval


## Clears all active powerups (triggering deactivate), removes falling capsules,
## and resets drop counters.
func clear() -> void:
	for p in active.values():
		p.deactivate()
	active.clear()
	clear_items()
	recent_drops.clear()
	_since_drop = 0


## Removes all currently falling powerup capsules from the scene.
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


## Evaluates pity and random drop chances when a tile is destroyed to drop a powerup.
func on_tile_destroyed(pos: Vector2) -> void:
	if config == null or not config.enabled:
		return
	_since_drop += 1
	var pity := config.pity_tiles > 0 and _since_drop >= config.pity_tiles
	if pity or randf() < config.drop_chance:
		_drop(pos)


## Activates a powerup upon collection, or refreshes its duration if already active.
func collect(type: PowerupRegistry.PowerType, pos: Vector2 = Vector2.ZERO) -> void:
	if active.has(type):
		active[type].refresh()
		activated.emit(active[type])
		return
	var p := PowerupRegistry.create(type)
	if p == null:
		return
	p.game = game
	p.collect_pos = pos
	p.remaining = p.duration
	p.activate()
	if p.duration > 0.0:
		active[type] = p
	activated.emit(p)


## Ends a timed power-up early (e.g. Guardian after saving a ball).
func expire(type: PowerupRegistry.PowerType) -> void:
	if active.has(type):
		active[type].remaining = 0.0


## Weighted pick among types that are allowed by the config and eligible right now.
## Excludes the last 3 spawned drops to guarantee uniqueness among recent drops.
## Returns -1 if no eligible powerup can be chosen.
func pick(exclude: Variant = null) -> int:
	if config == null or not config.enabled:
		return -1
	var pool := {}
	var total := 0.0
	for type in config.weights:
		var w: float = config.weights[type]
		if (exclude != null and type == exclude) or w <= 0.0:
			continue
		if type in recent_drops:
			continue
		var instance = PowerupRegistry.create(type)
		if instance == null or not instance.can_spawn(game):
			continue
		pool[type] = w
		total += w

	# Fallback if exclusion of recent_drops left no valid choices:
	if pool.is_empty():
		for type in config.weights:
			var w: float = config.weights[type]
			if (exclude != null and type == exclude) or w <= 0.0:
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


## Spawns a falling power-up item at pos. If power_type is not provided, picks a random eligible power-up.
func spawn_item(pos: Vector2, power_type: Variant = null) -> Powerup:
	var chosen_type = power_type if power_type != null else pick()
	if chosen_type == null or chosen_type < 0:
		return null
	var actual_type: PowerupRegistry.PowerType = chosen_type as PowerupRegistry.PowerType
	recent_drops.append(actual_type)
	if recent_drops.size() > 3:
		recent_drops.pop_front()
	var item: Powerup = POWERUP_SCENE.instantiate()
	item.type = actual_type
	item.position = pos
	item.collected.connect(collect)
	game.add_child(item)
	return item


## Internal drop logic respecting max falling capsule limits on screen.
func _drop(pos: Vector2) -> void:
	if config == null or not config.enabled:
		return
	if get_tree().get_nodes_in_group(GROUP).size() >= config.max_falling:
		return
	var type := pick()
	if type < 0:
		return
	_since_drop = 0
	spawn_item(pos, type)

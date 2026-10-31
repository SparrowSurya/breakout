class_name BaseGame
extends Node2D

# Common game related nodes.
@export var tiles_node: Node2D           ## Contains instance tiles
@export var balls_node: Node2D           ## COntains instance balls
@export var dead_zone: Area2D            ## Deadzone area
@export var top_wall: CollisionShape2D   ## Top collission wall
@export var countdown_label: Label       ## Countdown label

# Instancible scenes needed.
const ball_scene = preload(Constants.SCENE.Ball)
const paddle_scene = preload(Constants.SCENE.Paddle)
const tile_scene = preload(Constants.SCENE.Tile)

# Positioning information for various entities.
const PADDLE_Y_OFFSET: float = 48.0
const BALL_Y_OFFSET: float = PADDLE_Y_OFFSET + 16.0
const TILE_TOP_GAP: float = 24.0

# Layout related information.
var tile_y_begin: float = 0.0 ## Y coordinate from where tiles begine to appear.
var window_size: Vector2      ## Viewport size (read during runtime).

# Manually added scenes (entities).
var paddle: Paddle    ## Paddle scene object.
var shield: StaticBody2D ## Guardian barrier object.
var powerups: PowerupManager ## Powerup manager component.

# Multi-ball & damage state
var balls: Array[Ball]:
	get:
		var list: Array[Ball] = []
		if balls_node:
			for child in balls_node.get_children():
				if child is Ball:
					list.append(child)
		return list

var max_hearts: int:
	get:
		return player_attempts_count()

var are_tiles_immune: bool = false
var _ball_damage_mods: Dictionary[StringName, float] = {}

# Time state 
var elapsed_ms: float = 0.0   ## Elapsed milliseconds during the gameplay

# Destructible tiles state.
var tiles_count: int = 0   ## Count of tiles (destructible)
var tiles_left: int = 0    ## Tiles (destructible) left to clear
var total_hits: int = 0    ## Total hits on tile (destructible) to clear all tiles
var hits_left: int = 0     ## Hits left to clear remaing tiles (destructible)

# Player attempts.
var hearts: int   ## Lives player has before game ends.

# Tiles grid data
var grid_data: Array   ## Tile formation grid data
var grid_rows: int     ## Grid rows count
var grid_cols: int     ## Grid columns count


func _ready() -> void:
	GameManager.game_state = GameManager.GameState.WAITING
	initialise()
	setup()
	start_game()


func _process(delta: float) -> void:
	if GameManager.game_state == GameManager.GameState.PLAYING:
		tick(delta)
		if powerups:
			powerups.tick(delta)

	if Input.is_action_just_pressed("pause"):
		if GameManager.game_state == GameManager.GameState.PLAYING:
			pause_game()
		elif GameManager.game_state == GameManager.GameState.PAUSED:
			resume_game()


## Performs first time setup that should only done once at beginning.
func initialise() -> void:
	dead_zone.body_entered.connect(_on_dead_zone_body_entered)

	window_size = get_viewport().get_visible_rect().size
	tile_y_begin = (
		TILE_TOP_GAP
		+ top_wall.position.y
		+ top_wall.shape.get_rect().size.y / 2.0
	)

	var ball = ball_scene.instantiate()
	ball.game = self
	balls_node.add_child(ball)
	ball.on_hit_paddle.connect(_on_ball_hit_paddle)

	paddle = paddle_scene.instantiate()
	add_child(paddle)

	paddle.touch_y_min = tile_y_begin
	paddle.touch_y_max = window_size.y

	_setup_shield()

	powerups = PowerupManager.new()
	powerups.name = "PowerupManager"
	add_child(powerups)


func _setup_shield() -> void:
	shield = StaticBody2D.new()
	shield.name = "GuardianShield"

	var shield_shape := CollisionShape2D.new()
	shield_shape.name = "CollisionShape2D"
	var rect_shape := RectangleShape2D.new()
	rect_shape.size = Vector2(window_size.x, 6.0)
	shield_shape.shape = rect_shape

	shield.position = Vector2(window_size.x / 2.0, dead_zone.position.y - 10.0)

	var visual := ColorRect.new()
	visual.name = "Visual"
	visual.color = Palette.TEAL
	visual.color.a = 0.8
	visual.size = Vector2(window_size.x, 4.0)
	visual.position = Vector2(-window_size.x / 2.0, -2.0)

	shield.add_child(visual)
	shield.add_child(shield_shape)
	add_child(shield)
	disable_shield()


func enable_shield() -> void:
	if shield:
		shield.show()
		var col: CollisionShape2D = shield.get_node_or_null("CollisionShape2D")
		if col:
			col.set_deferred("disabled", false)


func disable_shield() -> void:
	if shield:
		shield.hide()
		var col: CollisionShape2D = shield.get_node_or_null("CollisionShape2D")
		if col:
			col.set_deferred("disabled", true)


func add_ball_from(src: Ball = null, is_fireball: bool = false) -> Ball:
	var new_ball: Ball = ball_scene.instantiate()
	new_ball.game = self
	new_ball.is_fireball = is_fireball
	balls_node.add_child(new_ball)
	if src:
		new_ball.global_position = src.global_position
		new_ball.set_random_velocity()
	else:
		var paddle_height = paddle.sprite.texture.get_height()
		new_ball.position.x = window_size.x / 2.0
		new_ball.position.y = window_size.y - paddle_height - BALL_Y_OFFSET
		new_ball.setup()
	new_ball.on_hit_paddle.connect(_on_ball_hit_paddle)
	return new_ball


func add_heart() -> void:
	hearts = mini(hearts + 1, max_hearts)
	update_hud()


func set_ball_damage_mod(key: StringName, mult: float) -> void:
	_ball_damage_mods[key] = mult


func clear_ball_damage_mod(key: StringName) -> void:
	_ball_damage_mods.erase(key)


func get_ball_damage_multiplier() -> float:
	var m: float = 1.0
	for v in _ball_damage_mods.values():
		m *= v
	return m


func set_tiles_immune(immune: bool) -> void:
	are_tiles_immune = immune
	if tiles_node:
		for tile in tiles_node.get_children():
			if tile is Tile:
				tile.immune_override = immune


func refresh_tile_stats() -> void:
	total_hits = 0
	hits_left = 0
	tiles_left = 0
	if tiles_node:
		for tile in tiles_node.get_children():
			if tile is Tile and is_instance_valid(tile) and not tile.is_queued_for_deletion():
				if tile.tile_type != TileDef.TileType.METAL and not tile.is_immune:
					tiles_left += 1
					total_hits += tile.tile_health
					hits_left += tile.tile_health
	update_progress()
	update_hud()


## Virtual handler for ball paddle collision
func _on_ball_hit_paddle(_ball: Ball, _paddle: Paddle) -> void:
	pass


## Performs setup which is called after initialise or during fresh start. Before
## calling this method (parent) from child class make sure that variables are 
## reset so that changes apply and shows correct state in the screen.
func setup() -> void:
	elapsed_ms = 0.0
	hearts = player_attempts_count()
	if powerups:
		powerups.setup(self, get_powerup_config())

	setup_tiles()
	update_hud()
	reposition()


## Returns the attempts player can take. (default: 3)
func player_attempts_count() -> int:
	return 3


## Performs the tiles formation setup. It is called during setup only.
func setup_tiles() -> void:
	total_hits = 0
	hits_left = 0
	tiles_left = 0

	for tile in tiles_node.get_children():
		tile.queue_free()

	var total_width: float = grid_cols * Constants.DEFAULT_TILE_WIDTH + (grid_cols - 1) * Constants.DEFAULT_COL_GAP
	var start_x: float = (window_size.x - total_width) / 2.0

	for index in range(grid_data.size()):
		var row: int = int(index / float(grid_cols))
		var col: int = index % grid_cols

		var tile_health = grid_data[index]
		if tile_health == 0: # treats as empty place
			continue

		var tile_def = TileDef.from_health(tile_health)
		var pos = Vector2(
			start_x + col * (Constants.DEFAULT_TILE_WIDTH + Constants.DEFAULT_COL_GAP) + Constants.DEFAULT_TILE_WIDTH / 2.0,
			tile_y_begin + row * (Constants.DEFAULT_TILE_HEIGHT + Constants.DEFAULT_ROW_GAP),
		)
		add_tile(tile_def, pos)

	hits_left = total_hits
	if total_hits <= 0:
		push_error("LevelGame: total_hits evaluated to non positive integer")



## Adds the tile to tiles_node and returns it.
func add_tile(def: TileDef, pos: Vector2) -> Tile:
	var tile: Tile = tile_scene.instantiate()

	tile.tile_health = def.health
	tile.tile_type = def.type
	tile.position = pos

	if tile.tile_type != TileDef.TileType.METAL:
		tiles_left += 1
		total_hits += tile.tile_health

	tiles_node.add_child(tile)
	tile.on_hit.connect(_on_tile_hit)
	return tile


## Updates information displayed on HUD.
func update_hud() -> void:
	pass


## Called when elapsed time is updated.
func tick(delta: float) -> void:
	elapsed_ms += delta


## Updates the progress. Called when a tile take damage.
func update_progress() -> void:
	pass


## Performs countdown before game starts.
func countdown() -> void:
	if countdown_label == null:
		return

	GameManager.game_state = GameManager.GameState.COUNTDOWN
	countdown_label.show()

	for i in range(3, 0, -1):
		countdown_label.text = str(i)
		SoundManager.play_sfx(Constants.SOUND.Countdown)
		await get_tree().create_timer(1.0, false).timeout

	countdown_label.text = "GO!"
	var player := SoundManager.play_sfx(Constants.SOUND.CountdownGo)
	if player != null:
		await player.finished
	await get_tree().create_timer(0.5, false).timeout

	countdown_label.hide()


## Starts the game. Child should always call this before doing something.
func start_game() -> void:
	await countdown()
	GameManager.game_state = GameManager.GameState.PLAYING


## Pause the game. Child should always call this before doing something.
func pause_game() -> void:
	GameManager.game_state = GameManager.GameState.PAUSED


## Resumes the game. Child should always call this before doing something.
func resume_game() -> void:
	GameManager.game_state = GameManager.GameState.PLAYING


## Ends the game. Additionally, takes the result object. Child should always
## call this before doing something.
func end_game(_result) -> void:
	GameManager.game_state = GameManager.GameState.END
	if powerups:
		powerups.clear()


## Restarts the game again.
func restart_game() -> void:
	if powerups:
		powerups.clear()
	setup()
	start_game()


## Resets position of paddle and ball.
func reposition() -> void:
	var paddle_height = paddle.sprite.texture.get_height()

	paddle.position.x = window_size.x / 2.0
	paddle.position.y = window_size.y - PADDLE_Y_OFFSET
	paddle.z_index = 1

	var current_balls: Array[Ball] = []
	for child in balls_node.get_children():
		if child is Ball:
			current_balls.append(child)

	if current_balls.is_empty():
		add_ball_from(null, false)
	else:
		for i in range(current_balls.size()):
			var b = current_balls[i]
			if i == 0:
				b.position.x = window_size.x / 2.0
				b.position.y = window_size.y - paddle_height - BALL_Y_OFFSET
				b.z_index = 1
				b.setup()
			else:
				b.destroy()


## Called when ball enters deadzone.
func ball_lost(_ball: Ball) -> void:
	pass


## Called when all (destructible) tiles finished.
func tiles_finished() -> void:
	pass


## Provides the balls count in scene.
func balls_count() -> int:
	return balls_node.get_children().filter(func(node): return node is Ball).size()


## Signal handler when ball enters dead zone.
func _on_dead_zone_body_entered(body: Node2D) -> void:
	if body is Ball:
		var count = balls_count()
		if count > 1:
			body.destroy()
		else:
			ball_lost(body)


## Provides the power-up config.
func get_powerup_config() -> PowerupConfig:
	return PowerupConfig.disabled()


## Signal handler when tiles takes damage. Note that this function must be
## attached to each created tile.
func _on_tile_hit(_tile: Tile, effective_damage: int, destroyed: bool) -> void:
	hits_left -= effective_damage
	update_progress()

	if destroyed:
		tiles_left -= 1
		if powerups:
			powerups.on_tile_destroyed(_tile.global_position)

	if tiles_left <= 0:
		tiles_finished()

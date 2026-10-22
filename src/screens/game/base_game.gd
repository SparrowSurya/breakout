class_name BaseGame
extends Node2D


# Common game related nodes.
@export var tiles_node: Node2D               ## Contains instance tiles
@export var dead_zone: Area2D                ## Deadzone area

# Time related 
var elapsed_ms: float = 0.0  ## Elapsed milliseconds during the gameplay

# Destructible tiles
var tiles_count: int = 0 ## Count of tiles (destructible)
var tiles_left: int = 0  ## Tiles (destructible) left to clear
var total_hits: int = 0  ## Total hits on tile (destructible) to clear all tiles
var hits_left: int = 0   ## Hits left to clear remaing tiles (destructible)


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	GameManager.game_state = GameManager.GameState.WAITING
	initialise()
	setup()
	call_deferred("start_game")


func _process(delta: float) -> void:
	if GameManager.game_state == GameManager.GameState.PLAYING:
		tick(delta)
	
	if Input.is_action_just_pressed("continue"):
		if GameManager.game_state == GameManager.GameState.PLAYING:
			pause_game()
		elif GameManager.game_state == GameManager.GameState.PAUSED:
			resume_game()


## Performs first time setup that should only done once at beginning.
func initialise() -> void:
	dead_zone.body_entered.connect(_on_dead_zone_body_entered)


## Performs setup which is called after initialise or during restart.
func setup() -> void:
	elapsed_ms = 0.0
	total_hits = 0
	hits_left = 0

	setup_tiles()
	setup_hud()


func setup_tiles() -> void:
	pass


func setup_hud() -> void:
	pass


## Called when elapsed time is updated.
func tick(delta: float) -> void:
	elapsed_ms += delta


## Called when a tile take damage.
func update_progress() -> void:
	pass


## Starts tge gameplay.
func start_game() -> void:
	pass


## Pause the gameplay.
func pause_game() -> void:
	pass


## Resumes the gameplay.
func resume_game() -> void:
	pass


## Ends the gameplay.
func end_game(_result) -> void:
	pass


## Called when ball enters deadzone
func ball_lost() -> void:
	pass


## Called when all (destructible) tiles finished.
func tiles_finished() -> void:
	pass


func _on_dead_zone_body_entered(body: Node2D) -> void:
	if body is Ball:
		ball_lost()


func _on_tile_hit(_tile: Tile, effective_damage: int, destroyed: bool) -> void:
	hits_left -= effective_damage
	update_progress()

	if destroyed:
		tiles_left -= 1

	if tiles_left <= 0:
		tiles_finished()


## Formats the time as mm:ss
func format_time(p_time: float) -> String:
	var minutes: int = int(p_time / 60.0)
	var seconds: int = int(p_time) % 60
	# Isolate the decimal portion and convert to 2-digit centiseconds
	#var centiseconds: int = int((time - int(time)) * 100)
	
	return "%02d:%02d" % [minutes, seconds]

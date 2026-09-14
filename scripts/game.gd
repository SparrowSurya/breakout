extends Node2D

# State of the game
enum GameState {
	START,     # Initial state
	COUNTDOWN, # Countdown before starting game
	PLAYING,   # Game playing state
	END,       # Game end screen state
}

@export var paddle: CharacterBody2D
@export var ball: CharacterBody2D
@export var tiles_node: Node
@export var sfx: AudioStreamPlayer2D
@export var deadzone: Area2D
@export var end_screen: Control
@export var start_screen: Control
@export var countdown: Label
@export var result: Label

const PADDLE_Y_OFFSET: float = 30.0
const BALL_Y_OFFET: float = 10.0
const TILE_Y_BEGIN: float = 16.0

# Tiles structural layout configuration
const TILE_ROWS := 7
const TILE_COLS := 15
const ROW_GAP := 4.0
const COL_GAP := 8.0

# Dimensions of the tile
const TILE_WIDTH := 32.0
const TILE_HEIGHT := 16.0

# Order of tiles from top to bottom
const TILE_ROW_ORDER := [
	Tile.TileType.RED,
	Tile.TileType.PEACH,
	Tile.TileType.YELLOW,
	Tile.TileType.GREEN,
	Tile.TileType.BLUE,
	Tile.TileType.MAUVE,
	Tile.TileType.METAL
]

# Exception to metal tile beinig not placed in some columns
const METAL_TILE_NOT_ALLOWED_COL := [1, 3, 5, 7, 9, 11, 13]

var game_state: GameState
var tiles_alive: int
var window_size: Vector2
var ball_size: Vector2


func _ready() -> void:
	window_size = get_viewport().get_visible_rect().size

	deadzone.ball_entered.connect(_on_dead_zone_body_entered)

	countdown.hide()
	end_screen.hide()
	start_screen.show()

	tiles_alive = 0
	game_state = GameState.START
	ball.is_playing = false
	paddle.is_playing = false

	setup()


func _process(_delta: float) -> void:
	match game_state:
		GameState.START:
			if Input.is_action_just_pressed("continue"):
				start_game()
		GameState.END:
			if Input.is_action_just_pressed("continue"):
				restart_game()


func setup() -> void:
	setup_ball_and_paddle()
	setup_tiles()


func setup_ball_and_paddle() -> void:
	var paddle_height = paddle.sprite.texture.get_height()
	paddle.position.x = (window_size.x - paddle_height) / 2
	paddle.position.y = window_size.y - PADDLE_Y_OFFSET

	ball_size = ball.sprite.texture.get_size()
	ball.position.x = (window_size.x - ball_size.x) / 2
	ball.position.y = window_size.y - PADDLE_Y_OFFSET - paddle_height - BALL_Y_OFFET


func setup_tiles() -> void:
	tiles_alive = 0

	# Clear existing Tile node if any
	for tile in tiles_node.get_children():
		tile.queue_free()

	var total_width := TILE_COLS * TILE_WIDTH + (TILE_COLS - 1) * COL_GAP
	var start_x := (window_size.x - total_width) / 2.0

	for row in range(TILE_ROWS):
		for col in range(TILE_COLS):

			# Metal only appears in specific columns
			if TILE_ROW_ORDER[row] == Tile.TileType.METAL and col not in METAL_TILE_NOT_ALLOWED_COL:
				continue

			var tile = Constants.SCENE.Tile.instantiate()
			tile.tile_type = TILE_ROW_ORDER[row]
			tile.position = Vector2(
				start_x + col * (TILE_WIDTH + COL_GAP) + TILE_WIDTH / 2.0,
				TILE_Y_BEGIN + row * (TILE_HEIGHT + ROW_GAP)
			)
			tiles_node.add_child(tile)
			if tile.tile_type != Tile.TileType.METAL:
				tiles_alive += 1
			
			tile.destroyed.connect(_on_tile_destroyed)


func tile_destroyed(_tile: Tile) -> void:
	tiles_alive -= 1
	if tiles_alive <= 0:
		end_game(true)


func start_game() -> void:
	start_screen.hide()
	end_screen.hide()
	start_countdown()


func start_countdown() -> void:
	game_state = GameState.COUNTDOWN
	countdown.show()

	for i in range(3, 0, -1):
		countdown.text = str(i)
		play_sound(Constants.SOUND.Countdown)
		await get_tree().create_timer(1.0).timeout

	countdown.text = "GO!"
	play_sound(Constants.SOUND.CountdownGo)
	await get_tree().create_timer(0.5).timeout

	countdown.hide()
	play_game()


func play_game() -> void:
	game_state = GameState.PLAYING
	paddle.is_playing = true
	ball.is_playing = true
	
	ball.setup()


func end_game(won: bool) -> void:
	game_state = GameState.END
	ball.is_playing = false
	paddle.is_playing = false
	
	var sound = Constants.SOUND.GameWon if won else Constants.SOUND.GameLost
	play_sound(sound)
	await get_tree().create_timer(0.5).timeout
	
	result.text = "You Win!" if won else "You Lose"
	end_screen.show()


func restart_game() -> void:
	end_screen.hide()
	setup()
	start_countdown()


func play_sound(stream: AudioStream) -> void:
	sfx.stream = stream
	sfx.play()


func _on_tile_destroyed(tile: Tile) -> void:
	tile_destroyed(tile)


func _on_start_button_pressed() -> void:
	start_game()


func _on_retart_button_pressed() -> void:
	restart_game()


func _on_dead_zone_body_entered(body: Node2D) -> void:
	if body is Ball:
		end_game(false)

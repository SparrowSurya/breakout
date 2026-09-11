extends Node2D

@onready var paddle: CharacterBody2D = $Paddle
@onready var ball: CharacterBody2D = $Ball
@onready var tiles_node: Node = $Tiles

enum GameState {
	START,
	COUNTDOWN,
	PLAYING,
	END,
}

const PADDLE_Y_OFFSET: float = 30.0
const BALL_Y_OFFET: float = 10.0
const TILE_Y_BEGIN: float = 16.0

const TILE_SCENE = preload("res://scenes/tile.tscn")

var game_state: GameState = GameState.START
var window_size: Vector2
var ball_size: Vector2
var tiles_alive: int = 0


func _ready() -> void:
	game_state = GameState.START
	window_size = get_viewport().get_visible_rect().size
	
	$DeadZone.ball_entered.connect(_on_dead_zone_body_entered)
	$UI/Countdown.hide()
	$UI/EndScreen.hide()
	$UI/StartScreen.show()
	
	ball.is_playing = false
	paddle.is_playing = false

	setup()


func _process(_delta: float) -> void:
	if game_state != GameState.PLAYING:
		return


func setup() -> void:
	var paddle_height = paddle.get_node("Sprite2D").texture.get_height()
	paddle.position.x = (window_size.x - paddle_height) / 2
	paddle.position.y = window_size.y - PADDLE_Y_OFFSET

	ball_size = ball.get_node("Sprite2D").texture.get_size()
	ball.position.x = (window_size.x - ball_size.x) / 2
	ball.position.y = window_size.y - PADDLE_Y_OFFSET - paddle_height - BALL_Y_OFFET
	
	_setup_tiles()


func _on_dead_zone_body_entered(body: Node2D) -> void:
	if body is Ball:
		end_game(false)


func end_game(won: bool) -> void:
	ball.is_playing = false
	paddle.is_playing = false

	await get_tree().create_timer(0.5).timeout
	
	$UI/EndScreen/Result.text = "You Win!" if won else "You Lose"
	$UI/EndScreen.show()


func _setup_tiles() -> void:
	const ROWS := 7
	const COLS := 15

	var row_gap := 4.0
	var col_gap := 8.0

	var tile_width := 32.0
	var tile_height := 16.0

	var total_width := COLS * tile_width + (COLS - 1) * col_gap
	var start_x := (window_size.x - total_width) / 2.0

	var tile_types := [
		Tile.TileType.RED,
		Tile.TileType.PEACH,
		Tile.TileType.YELLOW,
		Tile.TileType.GREEN,
		Tile.TileType.BLUE,
		Tile.TileType.MAUVE,
		Tile.TileType.METAL
	]
	
	tiles_alive = 0

	for row in range(ROWS):
		for col in range(COLS):
			# Metal only appears in specific columns
			if row == 6 and col not in [1, 3, 5, 7, 9, 11, 13]:
				continue

			var tile = TILE_SCENE.instantiate()

			tile.tile_type = tile_types[row]

			tile.position = Vector2(
				start_x + col * (tile_width + col_gap) + tile_width / 2.0,
				TILE_Y_BEGIN + row * (tile_height + row_gap)
			)

			tiles_node.add_child(tile)
			if tile.tile_type != Tile.TileType.METAL:
				tiles_alive += 1

func tile_destroyed() -> void:
	tiles_alive -= 1
	if tiles_alive <= 0:
		end_game(true)


func _on_start_button_pressed() -> void:
	$UI/StartScreen.hide()
	$UI/EndScreen.hide()
	start_countdown()

func start_countdown() -> void:
	game_state = GameState.COUNTDOWN
	
	$UI/Countdown.show()

	for i in range(3, 0, -1):
		$UI/Countdown.text = str(i)
		await get_tree().create_timer(1.0).timeout

	$UI/Countdown.text = "GO!"
	await get_tree().create_timer(0.5).timeout

	$UI/Countdown.hide()

	start_game()

func start_game() -> void:
	game_state = GameState.PLAYING
	
	paddle.is_playing = true
	ball.is_playing = true


func _on_retart_button_pressed() -> void:
	$UI/EndScreen.hide()
	resetup()
	start_countdown()

func resetup() -> void:
	for tile in tiles_node.get_children():
		tile.queue_free()
	setup()

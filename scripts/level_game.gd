extends Node2D

@export var tiles_node: Node2D
@export var dead_zone: Area2D
@export var countdown: Label
@export var end_screen: Control
@export var result: Label
@export var audio: AudioStreamPlayer2D

@export var play_next_button: Button
@export var play_again_button: Button
@export var exit_button: Button

const ball_scene = preload(Constants.SCENE.Ball)
const paddle_scene = preload(Constants.SCENE.Paddle)
const tile_scene = preload(Constants.SCENE.Tile)

const PADDLE_Y_OFFSET: float = 60.0
const BALL_Y_OFFSET: float = PADDLE_Y_OFFSET + 20.0
const TILE_Y_BEGIN: float = 40.0

var window_size: Vector2
var ball: Ball
var paddle: Paddle
var level: int
var tiles_left: int


func _ready() -> void:
	if GameManager.level_data == null:
		level = 1
		push_warning("LevelGame: no level_data set in GameManager, selecting level 1")
	else:
		level = GameManager.level_data.level_no

	window_size = get_viewport().get_visible_rect().size

	dead_zone.body_entered.connect(_on_dead_zone_body_entered)
	play_next_button.pressed.connect(_on_play_next_pressed)
	play_again_button.pressed.connect(_on_play_again_pressed)
	exit_button.pressed.connect(_on_exit_pressed)
	
	_setup()
	call_deferred("start_level")


func _setup():
	_setup_tiles()
	_setup_paddle()
	_setup_ball()
	
	countdown.hide()
	end_screen.hide()


func _process(delta: float) -> void:
	if Input.is_action_pressed("continue"):
		GameManager.enter_levels()


# Instantiate and setup tiles as per the level
func _setup_tiles() -> void:
	var data = GameManager.level_data
	tiles_left = 0
	
	for tile in tiles_node.get_children():
		tile.queue_free()

	var total_width: float = data.cols * data.tile_width + (data.cols - 1) * data.col_gap
	var start_x: float = (window_size.x - total_width) / 2.0
	
	for index in range(data.grid.size()):
		var row: int = index / data.cols
		var col: int = index % data.cols

		var health = data.grid[index]
		if health == 0: # treats as empty place
			continue
		
		var tile = tile_scene.instantiate()
		tile.tile_type = TileDef.from_health(health).type
		tile.position = Vector2(
			start_x + col * (data.tile_width + data.col_gap) + data.tile_width / 2.0,
			TILE_Y_BEGIN + row * (data.tile_height + data.row_gap),
		)
		tiles_node.add_child(tile)
		if tile.tile_type != TileDef.TileType.METAL:
			tiles_left += 1
		
		tile.destroyed.connect(tile_destroyed)


# Instantiate and setup ball
func _setup_ball() -> void:
	if ball != null:
		ball.queue_free()

	ball = ball_scene.instantiate()
	
	var ball_size = ball.sprite.texture.get_size()
	var paddle_height = paddle.sprite.texture.get_height()

	ball.position.x = (window_size.x - ball_size.x) / 2
	ball.position.y = window_size.y - paddle_height - BALL_Y_OFFSET
	ball.z_index = 1
	
	add_child(ball)


# Instantiate and setup ball
func _setup_paddle() -> void:
	if paddle != null:
		paddle.queue_free()

	paddle = paddle_scene.instantiate()
	
	var paddle_height = paddle.sprite.texture.get_height()
	paddle.position.x = (window_size.x - paddle_height) / 2
	paddle.position.y = window_size.y - PADDLE_Y_OFFSET
	paddle.z_index = 1
	
	add_child(paddle)


# Stats the level game
func start_level() -> void:
	ball.setup()
	end_screen.hide()
	_countdown()


# Countdown before ball starts moving
func _countdown() -> void:
	GameManager.game_state = GameManager.GameState.COUNTDOWN
	countdown.show()

	for i in range(3, 0, -1):
		countdown.text = str(i)
		play_sound(Constants.SOUND.Countdown)
		await get_tree().create_timer(1.0).timeout

	countdown.text = "GO!"
	play_sound(Constants.SOUND.CountdownGo)
	await get_tree().create_timer(0.5).timeout

	countdown.hide()
	GameManager.game_state = GameManager.GameState.PLAYING


# Ends the level game
func end_level(won: bool) -> void:
	if GameManager.game_state != GameManager.GameState.PLAYING:
		return
	
	GameManager.game_state = GameManager.GameState.END
	
	var sound = Constants.SOUND.GameWon if won else Constants.SOUND.GameLost
	play_sound(sound)
	await get_tree().create_timer(0.5).timeout
	
	result.text = "You Win!" if won else "You Lose!"
	
	if GameManager.has_level(level+1):
		play_next_button.show()
	else:
		play_next_button.hide()
	
	end_screen.show()


# Play again same level
func restart_level() -> void:
	end_screen.hide()
	_setup()
	call_deferred("start_level")


# Exit to levels scene
func exit_level() -> void:
	GameManager.enter_levels()


# Updates the tiles counter and triggers end game if no tiles left to destroy.
func tile_destroyed(_tile: Tile) -> void:
	tiles_left -= 1
	if tiles_left <= 0:
		end_level(true)


func play_sound(stream: AudioStream) -> void:
	audio.stream = stream
	audio.play()


func play_next_level() -> void:
	var next_level = level+1
	if GameManager.has_level(next_level):
		GameManager.enter_level(next_level)


func _on_play_next_pressed() -> void:
	play_next_level()


func _on_play_again_pressed() -> void:
	restart_level()


func _on_exit_pressed() -> void:
	exit_level()


func _on_dead_zone_body_entered(body: Node2D) -> void:
	if body is Ball:
		end_level(false)

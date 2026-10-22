extends BaseGame

# Game related nodes
@export var wall_top_collider: CollisionShape2D

# HUD Nodes
@export var pause_resume_tab: TabContainer
@export var pause_button: CustomIconButton
@export var resume_button: CustomIconButton
@export var hearts_node: HBoxContainer
@export var time_value: Label
@export var progress_value: Label
@export var progress_bar: ProgressBar
@export var countdown_label: Label

# Menu node
@export var menus_node: Control
@export var background_overlay: ColorRect
@export var pause_menu: QuickPauseMenu
@export var end_menu: QuickEndMenu

const ball_scene = preload(Constants.SCENE.Ball)
const paddle_scene = preload(Constants.SCENE.Paddle)
const tile_scene = preload(Constants.SCENE.Tile)

const TAB_PAUSE: int = 0
const TAB_RESUME: int = 1

const ROWS_MIN: int = 3
const COLS_MIN: int = 5

const ROWS_MAX: int = 8
const COLS_MAX: int = 8

const PADDLE_Y_OFFSET: float = 60.0
const BALL_Y_OFFSET: float = PADDLE_Y_OFFSET + 20.0
const TILE_TOP_GAP: float = 24.0
const SCORE_DIGITS: int = 6

var tile_y_begin: float = 0.0 ## Y coordinate from where tiles begine to appear.
var window_size: Vector2      ## Viewport size (read during runtime).

var ball: Ball        ## Ball scene (manually added to tree).
var paddle: Paddle    ## Paddle scene (manually added to tree).

var lives: int        ## Lives count (default: read from the health_node child count)

var grid_data: Array[int] ## Tile formation grid data
var grid_rows: int        ## Grid rows count
var grid_cols: int        ## Grid columns count


func initialise() -> void:
	super.initialise()

	window_size = get_viewport().get_visible_rect().size
	tile_y_begin = (
		TILE_TOP_GAP
		+ wall_top_collider.position.y
		+ wall_top_collider.shape.get_rect().size.y / 2.0
	)

	pause_button.pressed.connect(pause_game)
	resume_button.pressed.connect(resume_game)

	pause_menu.resume_button.pressed.connect(resume_game)
	pause_menu.restart_button.pressed.connect(restart_game)
	pause_menu.exit_button.pressed.connect(exit_game)

	end_menu.win_menu.replay_button.pressed.connect(restart_game)
	end_menu.win_menu.exit_button.pressed.connect(exit_game)

	end_menu.lose_menu.replay_button.pressed.connect(restart_game)
	end_menu.lose_menu.exit_button.pressed.connect(exit_game)
	
	if ball != null:
		ball.queue_free()

	ball = ball_scene.instantiate()
	add_child(ball)

	if paddle != null:
		paddle.queue_free()

	paddle = paddle_scene.instantiate()
	add_child(paddle)


func setup() -> void:
	lives = hearts_node.get_children().filter(func(node): return node is TextureRect).size()

	pause_resume_tab.current_tab = TAB_PAUSE

	pause_button.disabled = true
	resume_button.disabled = true

	background_overlay.hide()
	countdown_label.hide()
	pause_menu.hide()
	end_menu.hide()

	elapsed_ms = 0
	progress_bar.value = 0.0

	_reposition()
	_update_heart()
	tick(0)

	super.setup()


func _update_grid() -> void:
	var rows := randi_range(ROWS_MIN, ROWS_MAX)
	var cols := randi_range(COLS_MIN, COLS_MAX)

	var formation := TileFormation.create(rows, cols)
	
	grid_data = formation.grid_data
	grid_rows = formation.grid_rows
	grid_cols = formation.grid_cols
	

func setup_tiles() -> void:
	_update_grid()

	for tile in tiles_node.get_children():
		tile.queue_free()
	
	total_hits = 0
	tiles_left = 0

	var total_width: float = grid_cols * Constants.DEFAULT_TILE_WIDTH + (grid_cols - 1) * Constants.DEFAULT_COL_GAP
	var start_x: float = (window_size.x - total_width) / 2.0

	for index in range(grid_data.size()):
		@warning_ignore("integer_division")
		var row: int = index / grid_cols
		var col: int = index % grid_cols

		var tile_health = grid_data[index]
		if tile_health == 0: # treats as empty place
			continue

		var tile: Tile = tile_scene.instantiate()
		tile.tile_type = TileDef.from_health(tile_health).type
		tile.position = Vector2(
			start_x + col * (Constants.DEFAULT_TILE_WIDTH + Constants.DEFAULT_COL_GAP) + Constants.DEFAULT_TILE_WIDTH / 2.0,
			tile_y_begin + row * (Constants.DEFAULT_TILE_HEIGHT + Constants.DEFAULT_ROW_GAP),
		)
		tiles_node.add_child(tile)
		if tile.tile_type != TileDef.TileType.METAL:
			tiles_left += 1
			total_hits += tile.tile_health

		tile.on_hit.connect(_on_tile_hit)
	
	hits_left = total_hits
	if total_hits <= 0:
		push_error("LevelGame: total_hits evaluated to non positive integer")


func _reposition() -> void:
	var paddle_height = paddle.sprite.texture.get_height()

	paddle.position.x = window_size.x / 2.0
	paddle.position.y = window_size.y - PADDLE_Y_OFFSET
	paddle.z_index = 1

	ball.position.x = window_size.x / 2.0
	ball.position.y = window_size.y - paddle_height - BALL_Y_OFFSET
	ball.z_index = 1

	ball.setup()


# Sets the information in HUD
func setup_hud() -> void:
	_update_heart()
	update_progress()


# Updates the heart (lives) count in HUD
func _update_heart() -> void:
	var hearts: Array[TextureRect] = []
	for heart in hearts_node.get_children():
		if heart is TextureRect:
			hearts.append(heart)

	for i in range(hearts.size()):
		hearts[i].modulate = Palette.RED if i < lives else Palette.SURFACE1


func tick(delta: float) -> void:
	super.tick(delta)
	time_value.text = format_time(elapsed_ms)


# Updates the progress bar and value in HUD
func update_progress() -> void:
	var percent: float = 100.0
	if total_hits > 0:
		percent = ((total_hits - hits_left) * 100.0) / total_hits
	var percent_text = "%d%%" % int(percent)

	progress_value.text = percent_text

	var tween = create_tween()
	tween.set_trans(Tween.TRANS_CUBIC)
	tween.set_ease(Tween.EASE_OUT)
	tween.tween_property(progress_bar, "value", percent, 0.25)


# Countdown before ball starts moving
func _countdown() -> void:
	GameManager.game_state = GameManager.GameState.COUNTDOWN
	countdown_label.show()

	for i in range(3, 0, -1):
		countdown_label.text = str(i)
		SoundManager.play_sfx(Constants.SOUND.Countdown)
		await get_tree().create_timer(1.0).timeout

	countdown_label.text = "GO!"
	SoundManager.play_sfx(Constants.SOUND.CountdownGo)
	await get_tree().create_timer(0.5).timeout

	countdown_label.hide()
	pause_button.disabled = false
	resume_button.disabled = false
	GameManager.game_state = GameManager.GameState.PLAYING


# Pause game if playing
func pause_game() -> void:
	if GameManager.game_state != GameManager.GameState.PLAYING:
		return

	GameManager.game_state = GameManager.GameState.PAUSED
	pause_resume_tab.current_tab = TAB_RESUME
	pause_menu.update(format_time(elapsed_ms), progress_bar.value)
	background_overlay.show()
	pause_menu.show()
	menus_node.show()


# Resume game if paused
func resume_game() -> void:
	if GameManager.game_state != GameManager.GameState.PAUSED:
		return

	GameManager.game_state = GameManager.GameState.PLAYING
	pause_resume_tab.current_tab = TAB_PAUSE
	menus_node.hide()
	background_overlay.hide()
	pause_menu.hide()


# Ends the level.
func end_game(won: bool) -> void:
	if GameManager.game_state != GameManager.GameState.PLAYING:
		return

	GameManager.game_state = GameManager.GameState.END
	menus_node.show()

	pause_button.disabled = true
	resume_button.disabled = true

	var sound = Constants.SOUND.GameWon if won else Constants.SOUND.GameLost
	SoundManager.play_sfx(sound)
	await get_tree().create_timer(0.5).timeout
	
	if won:
		end_menu.show_win(format_time(elapsed_ms), lives)
	else:
		end_menu.show_lose(format_time(elapsed_ms), progress_bar.value)

	background_overlay.show()


func start_game() -> void:
	menus_node.hide()
	_countdown()


# Play again same level
func restart_game() -> void:
	setup()
	call_deferred("start_game")


func ball_lost() -> void:
	lives -= 1
	_update_heart()
	if lives <= 0:
		end_game(false)
	else:
		GameManager.game_state = GameManager.GameState.WAITING
		SoundManager.play_sfx(Constants.SOUND.LifeLost)
		await get_tree().create_timer(2.0).timeout
		_reposition()
		_countdown()


func tiles_finished() -> void:
	end_game(true)


# Exit to levels scene
func exit_game() -> void:
	GameManager.navigate_to_mainmenu()

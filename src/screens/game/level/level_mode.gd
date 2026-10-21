extends BaseGame

# HUD nodes
@export var pause_resume_tab: TabContainer
@export var pause_button: CustomIconButton
@export var resume_button: CustomIconButton
@export var level_label: Label
@export var health_node: HBoxContainer
@export var time_node: Label
@export var progress_node: Label
@export var progress_bar: ProgressBar
@export var wall_top_node: CollisionShape2D

# Menus nodes
@export var menus_node: Control
@export var pause_menu: LevelPauseMenu
@export var end_menu: EndMenu
@export var background_overlay: ColorRect


const ball_scene = preload(Constants.SCENE.Ball)
const paddle_scene = preload(Constants.SCENE.Paddle)
const tile_scene = preload(Constants.SCENE.Tile)

const TAB_PAUSE: int = 0
const TAB_RESUME: int = 1
const TAB_WON: int = 0
const TAB_LOST: int = 1

const PADDLE_Y_OFFSET: float = 60.0
const BALL_Y_OFFSET: float = PADDLE_Y_OFFSET + 20.0
const TILE_TOP_GAP: float = 24.0
const SCORE_DIGITS: int = 6

var tile_y_begin: float = 0.0 ## Y coordinate from where tiles begine to appear.
var window_size: Vector2      ## Viewport size (read during runtime).

var ball: Ball        ## Ball scene (manually added to tree).
var paddle: Paddle    ## Paddle scene (manually added to tree).

var level_no: int = 0 ## Level number being played.
var lives: int        ## Lives count (default: read from the health_node child count)


func initialise() -> void:
	super.initialise()

	if GameManager.level_data == null:
		level_no = 1
		push_warning("LevelGame: no level_data set in GameManager, selecting level 1")
	else:
		level_no = GameManager.level_data.level_no

	window_size = get_viewport().get_visible_rect().size
	tile_y_begin = (
		TILE_TOP_GAP
		+ wall_top_node.position.y
		+ wall_top_node.shape.get_rect().size.y / 2.0
	)

	pause_button.pressed.connect(pause_game)
	resume_button.pressed.connect(resume_game)

	pause_menu.resume_button.pressed.connect(resume_game)
	pause_menu.restart_button.pressed.connect(restart_game)
	pause_menu.exit_button.pressed.connect(exit_level)

	end_menu.win_menu.play_next_button.pressed.connect(play_next_level)
	end_menu.win_menu.play_again_button.pressed.connect(restart_game)
	end_menu.win_menu.exit_button.pressed.connect(exit_level)

	end_menu.lose_menu.play_again_button.pressed.connect(restart_game)
	end_menu.lose_menu.exit_button.pressed.connect(exit_level)
	
	if ball != null:
		ball.queue_free()

	ball = ball_scene.instantiate()
	add_child(ball)

	if paddle != null:
		paddle.queue_free()

	paddle = paddle_scene.instantiate()
	add_child(paddle)


func setup() -> void:
	lives = health_node.get_children().filter(func(node): return node is TextureRect).size()

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


func setup_tiles() -> void:
	var data = GameManager.level_data

	for tile in tiles_node.get_children():
		tile.queue_free()

	var total_width: float = data.cols * data.tile_width + (data.cols - 1) * data.col_gap
	var start_x: float = (window_size.x - total_width) / 2.0
	
	for index in range(data.grid.size()):
		var row: int = index / data.cols
		var col: int = index % data.cols

		var tile_health = data.grid[index]
		if tile_health == 0: # treats as empty place
			continue

		var tile: Tile = tile_scene.instantiate()
		tile.tile_type = TileDef.from_health(tile_health).type
		tile.position = Vector2(
			start_x + col * (data.tile_width + data.col_gap) + data.tile_width / 2.0,
			tile_y_begin + row * (data.tile_height + data.row_gap),
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
	var ball_size = ball.sprite.texture.get_size()

	paddle.position.x = (window_size.x - paddle_height) / 2
	paddle.position.y = window_size.y - PADDLE_Y_OFFSET
	paddle.z_index = 1

	ball.position.x = (window_size.x - ball_size.x) / 2
	ball.position.y = window_size.y - paddle_height - BALL_Y_OFFSET
	ball.z_index = 1
	
	ball.setup()


# Sets the information in HUD
func setup_hud() -> void:
	var level_text = "Level %03d" % level_no
	level_label.text = level_text
	pause_menu.level_value.text = level_text

	_update_heart()
	update_progress()


# Updates the heart (lives) count in HUD
func _update_heart() -> void:
	var hearts: Array[TextureRect] = []
	for heart in health_node.get_children():
		if heart is TextureRect:
			hearts.append(heart)

	for i in range(hearts.size()):
		hearts[i].modulate = Palette.RED if i < lives else Palette.SURFACE1


func tick(delta: float) -> void:
	super.tick(delta)
	time_node.text = format_time(elapsed_ms)


# Updates the progress bar and value in HUD
func update_progress() -> void:
	var percent: float = 100.0
	if total_hits > 0:
		percent = ((total_hits - hits_left) * 100.0) / total_hits
	var percent_text = "%d%%" % int(percent)

	progress_node.text = percent_text

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


# Pause level if playing
func pause_game() -> void:
	if GameManager.game_state != GameManager.GameState.PLAYING:
		return

	GameManager.game_state = GameManager.GameState.PAUSED
	pause_resume_tab.current_tab = TAB_RESUME
	pause_menu.update(level_no, progress_bar.value)
	background_overlay.show()
	pause_menu.show()
	menus_node.show()


# Resume level if paused
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
	
	var level_progress: LevelProgress
	if won:
		end_menu.show_win(level_no, format_time(elapsed_ms), lives)
		level_progress = LevelProgress.as_done(level_no, lives)
	else:
		end_menu.show_lose(level_no, format_time(elapsed_ms), progress_bar.value)
		level_progress = LevelProgress.as_wip(level_no, progress_bar.value)

	background_overlay.show()
	UserProgress.save_progress(level_progress)


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
func exit_level() -> void:
	GameManager.exit_level()


# Exit to new level
func play_next_level() -> void:
	var next_level = level_no+1
	if GameManager.level_exists(next_level):
		GameManager.enter_level(next_level)

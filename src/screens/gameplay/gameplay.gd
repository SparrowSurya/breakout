extends Node2D

# Game nodes
@export var tiles_node: Node2D
@export var dead_zone: Area2D
@export var countdown_label: Label
@export var wall_top_node: CollisionShape2D
@export var audio: AudioStreamPlayer2D

# HUD nodes
@export var pause_resume_tab: TabContainer
@export var pause_button: CustomIconButton
@export var resume_button: CustomIconButton
@export var level_label: Label
@export var health_node: HBoxContainer
@export var time_node: Label
@export var progress_node: Label
@export var progress_bar: ProgressBar

# Pause menu nodes
@export var pause_menu: Control
@export var pause_menu_level_no: Label
@export var pause_menu_progress: Label
@export var pause_menu_progress_bar: ProgressBar
@export var pause_menu_resume_button: CustomButton
@export var pause_menu_restart_button: CustomButton
@export var pause_menu_exit_button: CustomButton

# End status tab
@export var end_menu: Control
@export var end_menu_tab: TabContainer

# Win menu nodes
@export var win_menu_stars: HBoxContainer
@export var win_menu_level_no_label: Label
@export var win_menu_time_label: Label
@export var win_menu_lives: Label
@export var win_menu_play_next_button: CustomButton
@export var win_menu_play_again_button: CustomButton
@export var win_menu_exit_button: CustomButton

# Lost menu nodes
@export var lost_menu_stars: HBoxContainer
@export var lost_menu_level_no_label: Label
@export var lost_menu_time_label: Label
@export var lost_menu_progress: Label
@export var lost_menu_progress_bar: ProgressBar
@export var lost_menu_play_again_button: CustomButton
@export var lost_menu_exit_button: CustomButton


const ball_scene = preload(Constants.SCENE.Ball)
const paddle_scene = preload(Constants.SCENE.Paddle)
const tile_scene = preload(Constants.SCENE.Tile)

const TAB_PAUSE: int = 0
const TAB_RESUME: int = 1
const TAB_WON: int = 0
const TAB_LOST: int = 1

const PROGRESS_MIN_VALUE: float = 0.0
const PROGRESS_MAX_VALUE: float = 100.0

const PADDLE_Y_OFFSET: float = 60.0
const BALL_Y_OFFSET: float = PADDLE_Y_OFFSET + 20.0
const TILE_TOP_GAP: float = 24.0
const SCORE_DIGITS: int = 6

var tile_y_begin: float = 0.0 ## Y coordinate from where tiles begine to appear.
var window_size: Vector2      ## Viewport size (read during runtime).

var ball: Ball        ## Ball scene (manually added to tree).
var paddle: Paddle    ## Paddle scene (manually added to tree).

var level_no: int = 0 ## Level number being played.
var total_hits: int   ## Total number of hits to break all breakable tiles.
var hits_left: int    ## Hits left to break all leftover breakable tiles.
var tiles_left: int   ## Number of breakable tiles left.
var lives: int        ## Lives count (default: read from the health_node child count)
var time: float       ## Stores the stopwatch time data.


func _ready() -> void:
	_init_variables()
	_connect_signals()
	setup()
	progress_bar.show()
	call_deferred("start_level")


func _process(delta: float) -> void:
	if GameManager.game_state == GameManager.GameState.PLAYING:
		time += delta
		_update_time_value()
	
	if Input.is_action_just_pressed("continue"):
		if GameManager.game_state == GameManager.GameState.PLAYING:
			pause_level()
		elif GameManager.game_state == GameManager.GameState.PAUSED:
			resume_level()


# Initialises all the variables the needs to be initialised.
func _init_variables() -> void:
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

	progress_bar.min_value = PROGRESS_MIN_VALUE
	progress_bar.max_value = PROGRESS_MAX_VALUE

	pause_menu_progress_bar.min_value = PROGRESS_MIN_VALUE
	pause_menu_progress_bar.max_value = PROGRESS_MAX_VALUE

	lost_menu_progress_bar.min_value = PROGRESS_MIN_VALUE
	lost_menu_progress_bar.max_value = PROGRESS_MAX_VALUE


# Attaches signals listeners to the signals.;
func _connect_signals() -> void:
	dead_zone.body_entered.connect(_on_dead_zone_body_entered)
	pause_button.pressed.connect(pause_level)
	resume_button.pressed.connect(resume_level)

	pause_menu_resume_button.pressed.connect(resume_level)
	pause_menu_restart_button.pressed.connect(restart_level)
	pause_menu_exit_button.pressed.connect(exit_level)

	win_menu_play_next_button.pressed.connect(play_next_level)
	win_menu_play_again_button.pressed.connect(restart_level)
	win_menu_exit_button.pressed.connect(exit_level)

	lost_menu_play_again_button.pressed.connect(restart_level)
	lost_menu_exit_button.pressed.connect(exit_level)


# Setup perfomrs the game setup based on the level selected.
func setup() -> void:
	pause_resume_tab.current_tab = TAB_PAUSE

	lives = health_node.get_children().filter(func(node): return node is TextureRect).size()
	time = 0

	pause_button.disabled = true
	resume_button.disabled = true

	countdown_label.hide()
	pause_menu.hide()
	end_menu.hide()

	_setup_tiles()
	_setup_paddle()
	_setup_ball()
	_setup_hud()


# Instantiate and setup tiles as per the level
func _setup_tiles() -> void:
	var data = GameManager.level_data
	tiles_left = 0
	total_hits = 0
	
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
		
		tile.on_hit.connect(tile_destroyed)
	
	hits_left = total_hits
	if total_hits <= 0:
		push_error("LevelGame: total_hits evaluated to non positive integer")


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


# Sets the information in HUD
func _setup_hud() -> void:
	var level_text = "Level %03d" % level_no
	level_label.text = level_text
	pause_menu_level_no.text = level_text

	_update_heart()
	_update_time_value()
	_update_progress()


# Updates the heart (lives) count in HUD
func _update_heart() -> void:
	var hearts: Array[TextureRect] = []
	for heart in health_node.get_children():
		if heart is TextureRect:
			hearts.append(heart)

	for i in range(hearts.size()):
		hearts[i].modulate = Palette.RED if i < lives else Palette.SURFACE1


# Updates the time in HUD
func _update_time_value() -> void:
	time_node.text = format_time(time)


# Updates the progress bar and value in HUD
func _update_progress() -> void:
	var percent: float = 100.0
	if total_hits > 0:
		percent = ((total_hits - hits_left) * 100.0) / total_hits
	var percent_text = "%d%%" % int(percent)

	progress_node.text = percent_text

	var tween = create_tween()
	tween.set_trans(Tween.TRANS_CUBIC)
	tween.set_ease(Tween.EASE_OUT)
	tween.tween_property(progress_bar, "value", percent, 0.25)


# Stats the level game
func start_level() -> void:
	ball.setup()
	_countdown()
	time = 0.0


# Countdown before ball starts moving
func _countdown() -> void:
	GameManager.game_state = GameManager.GameState.COUNTDOWN
	countdown_label.show()

	for i in range(3, 0, -1):
		countdown_label.text = str(i)
		play_sound(Constants.SOUND.Countdown)
		await get_tree().create_timer(1.0).timeout

	countdown_label.text = "GO!"
	play_sound(Constants.SOUND.CountdownGo)
	await get_tree().create_timer(0.5).timeout

	countdown_label.hide()
	pause_button.disabled = false
	resume_button.disabled = false
	GameManager.game_state = GameManager.GameState.PLAYING


# Pause level if playing
func pause_level() -> void:
	if GameManager.game_state == GameManager.GameState.PLAYING:
		GameManager.game_state = GameManager.GameState.PAUSED
		pause_resume_tab.current_tab = TAB_RESUME
		pause_menu_progress.text = progress_node.text
		pause_menu_progress_bar.value = progress_bar.value
		pause_menu_resume_button.grab_focus()
		pause_menu.show()


# Resume level if paused
func resume_level() -> void:
	if GameManager.game_state == GameManager.GameState.PAUSED:
		GameManager.game_state = GameManager.GameState.PLAYING
		pause_resume_tab.current_tab = TAB_PAUSE
		pause_menu.hide()


# Ends the level.
func end_level(won: bool) -> void:
	if GameManager.game_state != GameManager.GameState.PLAYING:
		return

	GameManager.game_state = GameManager.GameState.END

	pause_button.disabled = true
	resume_button.disabled = true

	var sound = Constants.SOUND.GameWon if won else Constants.SOUND.GameLost
	play_sound(sound)
	await get_tree().create_timer(0.5).timeout
	
	var level_progress: LevelProgress
	if won:
		level_progress = _show_win()
	else:
		level_progress = _show_lost()
	
	UserProgress.save(level_progress)
	end_menu.show()


# Shows the menu of game won.
func _show_win() -> LevelProgress:
	win_menu_level_no_label.text = str(level_no).pad_zeros(3)
	win_menu_time_label.text = format_time(time)
	win_menu_lives.text = str(lives)

	var stars = lives
	var star_nodes = win_menu_stars.get_children()
	for i in range(star_nodes.size()):
		if star_nodes[i] is TextureRect:
			star_nodes[i].modulate = Palette.YELLOW if i < stars else Palette.SURFACE2

	if GameManager.has_level(level_no+1):
		win_menu_play_next_button.grab_focus()
	else:
		win_menu_play_next_button.hide()
		win_menu_exit_button.grab_focus()

	end_menu_tab.current_tab = TAB_WON
	return LevelProgress.as_done(level_no, stars)


# Shows the menu of game lost.
func _show_lost() -> LevelProgress:
	lost_menu_level_no_label.text = str(level_no).pad_zeros(3)
	lost_menu_time_label.text = format_time(time)

	lost_menu_progress.text = progress_node.text
	lost_menu_progress_bar.value = progress_bar.value

	for star_node in lost_menu_stars.get_children():
		if star_node is TextureRect:
			star_node.modulate = Palette.SURFACE2
	
	lost_menu_play_again_button.grab_focus()
	end_menu_tab.current_tab = TAB_LOST
	return LevelProgress.as_wip(level_no, progress_bar.value)


# Play again same level
func restart_level() -> void:
	setup()
	call_deferred("start_level")


# CHance given to player based on their leftover lives.
func next_attempt() -> void:
	lives -= 1
	_update_heart()
	if lives <= 0:
		end_level(false)
	else:
		GameManager.game_state = GameManager.GameState.WAITING
		play_sound(Constants.SOUND.LifeLost)
		await get_tree().create_timer(2.0).timeout
		_setup_ball()
		_setup_paddle()
		_countdown()


# Exit to levels scene
func exit_level() -> void:
	GameManager.enter_levels()


# Exit to new level
func play_next_level() -> void:
	var next_level = level_no+1
	if GameManager.has_level(next_level):
		GameManager.enter_level(next_level)


# Evaluates the stars from the score.
func evaluate_stars(_score: int) -> int:
	return lives

# Updates the tiles counter and triggers end game if no tiles left to destroy.
func tile_destroyed(_tile: Tile, effective_damage: int, destroyed: bool) -> void:
	hits_left -= effective_damage
	_update_progress()

	if destroyed:
		tiles_left -= 1

	if tiles_left <= 0:
		end_level(true)


func play_sound(stream: AudioStream) -> void:
	audio.stream = stream
	audio.play()


func _on_dead_zone_body_entered(body: Node2D) -> void:
	if body is Ball:
		next_attempt()


func format_time(p_time: float) -> String:
	var minutes: int = int(p_time) / 60
	var seconds: int = int(p_time) % 60
	# Isolate the decimal portion and convert to 2-digit centiseconds
	#var centiseconds: int = int((time - int(time)) * 100)
	
	return "%02d:%02d" % [minutes, seconds]

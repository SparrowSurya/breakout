extends BaseGame

# Hud related nodes.
@export var pause_resume_tab: TabContainer
@export var pause_button: CustomIconButton
@export var resume_button: CustomIconButton
@export var hearts_node: HBoxContainer
@export var score_value: Label
@export var stage_value: Label
@export var progress_bar: ProgressBar
@export var best_value: Label
@export var progress_value: Label

# Menu related nodes.
@export var menus_node: Control
@export var pause_menu: SurvivalPauseMenu
@export var gameover_menu: GameoverMenu


const TAB_PAUSE: int = 0
const TAB_RESUME: int = 1

var stage_no: int = 0 ## Stage number being played.
var score: int = 0    ## Score value
var combo: int = 1    ## Combo as hit multiplier


func initialise() -> void:
	super.initialise()

	pause_button.pressed.connect(pause_game)
	resume_button.pressed.connect(resume_game)

	pause_menu.resume_button.pressed.connect(resume_game)
	pause_menu.restart_button.pressed.connect(restart_game)
	pause_menu.exit_button.pressed.connect(exit_game)

	gameover_menu.play_again_button.pressed.connect(restart_game)
	gameover_menu.exit_button.pressed.connect(exit_game)
	
	ball.on_hit_paddle.connect(_on_ball_hit_paddle)


func setup() -> void:
	super.setup()

	combo = 1
	stage_no = 1
	score = 0
	progress_bar.value = 0.0
	best_value.text = "%06d" % UserProgress.highscore
	pause_resume_tab.current_tab = TAB_PAUSE
	pause_button.disabled = true
	resume_button.disabled = true

	countdown_label.hide()
	pause_menu.hide()
	gameover_menu.hide()


func player_attempts_count() -> int:
	return hearts_node.get_children().filter(func(node): return node is TextureRect).size()


func setup_tiles() -> void:
	var rows := randi_range(Constants.ROWS_MIN, Constants.ROWS_MAX)
	var cols := randi_range(Constants.COLS_MIN, Constants.COLS_MAX)

	var formation := TileFormation.create(rows, cols)
	
	grid_data = formation.grid_data
	grid_rows = formation.grid_rows
	grid_cols = formation.grid_cols
	
	super.setup_tiles()


# Sets the information in HUD
func update_hud() -> void:
	stage_value.text = "%03d" % stage_no
	
	_update_score()
	_update_heart()
	update_progress()


# Updates the heart (lives) count in HUD
func _update_heart() -> void:
	var nodes: Array[TextureRect] = []
	for node in hearts_node.get_children():
		if node is TextureRect:
			nodes.append(node)

	for i in range(nodes.size()):
		nodes[i].modulate = Palette.RED if i < hearts else Palette.SURFACE1


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


## Updates the score on HUD.
func _update_score() -> void:
	score_value.text = "%06d" % score
	if score > UserProgress.highscore:
		score_value.modulate = Palette.YELLOW
	else:
		score_value.modulate = Palette.TEXT


# Pause game if playing
func pause_game() -> void:
	if GameManager.game_state != GameManager.GameState.PLAYING:
		return

	GameManager.game_state = GameManager.GameState.PAUSED
	pause_resume_tab.current_tab = TAB_RESUME
	
	var stage_text := "%03d" % stage_no
	pause_menu.update(stage_text, progress_bar.value, Utils.format_time(elapsed_ms))
	pause_menu.resume_button.grab_focus()
	pause_menu.show()
	menus_node.show()


# Resume game if paused
func resume_game() -> void:
	if GameManager.game_state != GameManager.GameState.PAUSED:
		return

	GameManager.game_state = GameManager.GameState.PLAYING
	pause_resume_tab.current_tab = TAB_PAUSE
	menus_node.hide()
	pause_menu.hide()


# Ends the game.
func end_game(won: bool) -> void:
	if GameManager.game_state != GameManager.GameState.PLAYING:
		return

	GameManager.game_state = GameManager.GameState.END
	menus_node.show()

	pause_button.disabled = true
	resume_button.disabled = true

	var sound = Constants.SOUND.GameWon if won else Constants.SOUND.GameLost
	SoundManager.play_sfx(sound)
	await Utils.wait(1.5)
	
	var best := score > UserProgress.highscore
	var stage_text := "%03d" % stage_no
	var score_text := "%06d" % score
	gameover_menu.update(stage_text, score_text, progress_bar.value, Utils.format_time(elapsed_ms), best)
	gameover_menu.play_again_button.grab_focus()
	gameover_menu.show()
	menus_node.show()

	UserProgress.save_highscore(score)


func start_game() -> void:
	menus_node.hide()
	await super.start_game()

	pause_button.disabled = false
	resume_button.disabled = false


func ball_lost(_ball: Ball) -> void:
	hearts -= 1
	_update_heart()
	if hearts <= 0:
		end_game(false)
	else:
		_another_chance()


## Gives another chance to continue finishing stage.
func _another_chance() -> void:
	GameManager.game_state = GameManager.GameState.WAITING
	pause_button.disabled = true
	resume_button.disabled = true
	
	var player := SoundManager.play_sfx(Constants.SOUND.LifeLost)
	await player.finished
	await Utils.wait(1.0)

	reposition()
	start_game()


func tiles_finished() -> void:
	_next_stage()


## Setups and starts the next stage.
func _next_stage() -> void:
	GameManager.game_state = GameManager.GameState.WAITING

	var player := SoundManager.play_sfx(Constants.SOUND.StageFinished)
	await player.finished
	await Utils.wait(1.0)

	stage_no += 1
	progress_bar.value = 0.0
	
	reposition()
	setup_tiles()
	update_hud()
	start_game()


## Exit to levels screen.
func exit_game() -> void:
	GameManager.navigate_to_mainmenu()


## Handler which resets the combo since ball hits the paddle.
func _on_ball_hit_paddle(_p_ball: Ball, _p_paddle: Paddle) -> void:
	combo = 1


## Handler updates the score and increments the combo when tile is hit.
func _on_tile_hit(_tile: Tile, effective_damage: int, destroyed: bool) -> void:
	super._on_tile_hit(_tile, effective_damage, destroyed)

	score += effective_damage * combo
	combo += 1
	_update_score()

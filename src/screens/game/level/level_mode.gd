extends BaseGame

# HUD nodes
@export var pause_resume_tab: TabContainer
@export var pause_button: CustomIconButton
@export var resume_button: CustomIconButton
@export var title_label: Label
@export var hearts_node: HBoxContainer
@export var time_value: Label
@export var progress_value: Label
@export var progress_bar: ProgressBar

# Menus nodes
@export var menus_node: Control
@export var pause_menu: LevelPauseMenu
@export var end_menu: LevelEndMenu

# Tab values
const TAB_PAUSE: int = 0
const TAB_RESUME: int = 1
const TAB_WON: int = 0
const TAB_LOST: int = 1

var level_no: int = 0    ## Level number being played.


func initialise() -> void:
	super.initialise()

	if GameManager.level_data == null:
		level_no = 1
		push_warning("LevelGame: no level_data set in GameManager, selecting level 1")
	else:
		level_no = GameManager.level_data.level_no

	pause_button.pressed.connect(pause_game)
	resume_button.pressed.connect(resume_game)

	pause_menu.resume_button.pressed.connect(resume_game)
	pause_menu.restart_button.pressed.connect(restart_game)
	pause_menu.exit_button.pressed.connect(exit_game)

	end_menu.win_menu.play_next_button.pressed.connect(play_next_level)
	end_menu.win_menu.play_again_button.pressed.connect(restart_game)
	end_menu.win_menu.exit_button.pressed.connect(exit_game)

	end_menu.lose_menu.play_again_button.pressed.connect(restart_game)
	end_menu.lose_menu.exit_button.pressed.connect(exit_game)


func setup() -> void:
	super.setup()

	pause_resume_tab.current_tab = TAB_PAUSE
	progress_bar.value = 0.0
	pause_button.disabled = true
	resume_button.disabled = true

	countdown_label.hide()
	menus_node.hide()
	pause_menu.hide()
	end_menu.hide()


func player_attempts_count() -> int:
	return hearts_node.get_children().filter(func(node): return node is TextureRect).size()


func setup_tiles() -> void:
	var data = GameManager.level_data
	
	grid_data = data.grid
	grid_rows = data.rows
	grid_cols = data.cols

	super.setup_tiles()


# Sets the information in HUD
func update_hud() -> void:
	title_label.text = "Level %d" % level_no
	pause_menu.level_value.text = "Level %03d" % level_no

	_update_heart()
	_update_time()
	update_progress()


## Updates the heart (lives) count in HUD
func _update_heart() -> void:
	var nodes: Array[TextureRect] = []
	for node in hearts_node.get_children():
		if node is TextureRect:
			nodes.append(node)

	for i in range(nodes.size()):
		nodes[i].modulate = Palette.RED if i < hearts else Palette.SURFACE1


func tick(delta: float) -> void:
	super.tick(delta)
	_update_time()


func _update_time() -> void:
	time_value.text = Utils.format_time(elapsed_ms)


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


func pause_game() -> void:
	if GameManager.game_state != GameManager.GameState.PLAYING:
		return

	GameManager.game_state = GameManager.GameState.PAUSED
	pause_resume_tab.current_tab = TAB_RESUME

	var level_text := "%03d" % level_no
	pause_menu.update(level_text, progress_bar.value)
	pause_menu.resume_button.grab_focus()
	pause_menu.show()
	menus_node.show()


func resume_game() -> void:
	if GameManager.game_state != GameManager.GameState.PAUSED:
		return

	GameManager.game_state = GameManager.GameState.PLAYING
	pause_resume_tab.current_tab = TAB_PAUSE
	menus_node.hide()
	pause_menu.hide()


func end_game(won: bool) -> void:
	if GameManager.game_state != GameManager.GameState.PLAYING:
		return

	GameManager.game_state = GameManager.GameState.END

	pause_button.disabled = true
	resume_button.disabled = true

	var sound = Constants.SOUND.GameWon if won else Constants.SOUND.GameLost
	SoundManager.play_sfx(sound)
	await Utils.wait(1.5)

	var level_progress: LevelProgress
	var level_text := "%03d" % level_no
	
	if won:
		var has_next_level := GameManager.level_exists(level_no + 1)
		end_menu.win_menu.update(level_text, Utils.format_time(elapsed_ms), hearts, has_next_level)
		
		if has_next_level:
			end_menu.win_menu.play_next_button.grab_focus()
		else:
			end_menu.win_menu.exit_button.grab_focus()

		level_progress = LevelProgress.as_done(level_no, hearts)
	else:
		end_menu.lose_menu.update(level_text, Utils.format_time(elapsed_ms), progress_bar.value)
		end_menu.lose_menu.play_again_button.grab_focus()
		level_progress = LevelProgress.as_wip(level_no, progress_bar.value)

	menus_node.show()
	UserProgress.save_progress(level_progress)


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
	end_game(true)


## Exit to levels screen.
func exit_game() -> void:
	GameManager.exit_level()


## Play next level (if exists).
func play_next_level() -> void:
	var next_level = level_no + 1
	if GameManager.level_exists(next_level):
		GameManager.play_level(next_level)

extends BaseGame

# HUD Nodes
@export var pause_resume_tab: TabContainer
@export var pause_button: CustomIconButton
@export var resume_button: CustomIconButton
@export var hearts_node: HBoxContainer
@export var time_value: Label
@export var progress_value: Label
@export var progress_bar: ProgressBar

# Menu node
@export var menus_node: Control
@export var pause_menu: QuickPauseMenu
@export var end_menu: QuickEndMenu

const TAB_PAUSE: int = 0
const TAB_RESUME: int = 1


func initialise() -> void:
	super.initialise()

	pause_button.pressed.connect(pause_game)
	resume_button.pressed.connect(resume_game)

	pause_menu.resume_button.pressed.connect(resume_game)
	pause_menu.restart_button.pressed.connect(restart_game)
	pause_menu.exit_button.pressed.connect(exit_game)

	end_menu.win_menu.replay_button.pressed.connect(restart_game)
	end_menu.win_menu.exit_button.pressed.connect(exit_game)

	end_menu.lose_menu.replay_button.pressed.connect(restart_game)
	end_menu.lose_menu.exit_button.pressed.connect(exit_game)


func setup() -> void:
	pause_resume_tab.current_tab = TAB_PAUSE
	pause_button.disabled = true
	resume_button.disabled = true
	elapsed_ms = 0
	progress_bar.value = 0.0

	super.setup()

	countdown_label.hide()
	menus_node.hide()
	pause_menu.hide()
	end_menu.hide()



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


func update_hud() -> void:
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


func tick(delta: float) -> void:
	super.tick(delta)
	_update_time()


func _update_time() -> void:
	time_value.text = Utils.format_time(elapsed_ms)


func start_game() -> void:
	menus_node.hide()
	await super.start_game()

	pause_button.disabled = false
	resume_button.disabled = false


func pause_game() -> void:
	if GameManager.game_state != GameManager.GameState.PLAYING:
		return

	GameManager.game_state = GameManager.GameState.PAUSED
	pause_resume_tab.current_tab = TAB_RESUME
	pause_menu.update(Utils.format_time(elapsed_ms), progress_bar.value)
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
	var player := SoundManager.play_sfx(sound)
	await player.finished
	await Utils.wait(1.5)

	if won:
		end_menu.win_menu.update(Utils.format_time(elapsed_ms), hearts)
		end_menu.win_menu.replay_button.grab_focus()
		end_menu.show_win()
	else:
		end_menu.lose_menu.update(Utils.format_time(elapsed_ms), progress_bar.value)
		end_menu.lose_menu.replay_button.grab_focus()
		end_menu.show_lose()
	
	menus_node.show()


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
	GameManager.navigate_to_mainmenu()

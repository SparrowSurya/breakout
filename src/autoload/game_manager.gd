extends Node


## State of the running game.
enum GameState {
	NONE,      # Not in game
	WAITING,   # Waiting state
	COUNTDOWN, # Countdown before starting game
	PLAYING,   # Game playing state
	PAUSED,    # Game is paused
	END,       # Game end screen state
}


## Screen in the viewport.
enum Screen {

	SPLASH,

	# Normal screens
	MAIN_MENU,
	SELECT_LEVEL,

	# Gameplay screens
	QUICK_PLAY,
	LEVEL_MODE,
	SURVIVAL_MODE,
}


var current_screen: Screen = Screen.SPLASH
var level_data: LevelDef = null
var game_state: GameState = GameState.NONE

var _in_transition := false


func _ready() -> void:
	LevelDef.initialise()


func change_screen(path: String, transition: String = "Fade") -> void:
	if _in_transition:
		return
	_in_transition = true

	if not Constants.TRANSITION.has(transition):
		get_tree().change_scene_to_file(path)
		_in_transition = false
		return

	var t: Transition = Constants.TRANSITION[transition].instantiate()
	get_tree().root.add_child(t)
	await t.cover()
	get_tree().change_scene_to_file(path)
	await get_tree().process_frame
	await get_tree().process_frame
	await t.reveal()
	t.queue_free()
	_in_transition = false


## Enter main menu scene.
func navigate_to_mainmenu() -> void:
	current_screen = Screen.MAIN_MENU
	change_screen(Constants.SCENE.MainMenu)
	

## Enter select levels scene.
func navigate_to_select_level() -> void:
	current_screen = Screen.SELECT_LEVEL
	change_screen(Constants.SCENE.SelectLevel)


## Quick play a random formation.
func quick_play() -> void:
	current_screen = Screen.QUICK_PLAY
	change_screen(Constants.SCENE.QuickPlayMode)


## Play specific level mode.
func play_level(level: int) -> void:
	current_screen = Screen.LEVEL_MODE
	level_data = LevelDef.load_level(level)
	if level_data == null:
		push_warning("GameManager: enter level failed because level_data is null")
		return

	change_screen(Constants.SCENE.LevelMode)


## Navigates the select level menu while clearing the level related data.
func exit_level() -> void:
	level_data = null
	game_state = GameState.NONE

	navigate_to_select_level()


## Play survival mode.
func play_survival() -> void:
	current_screen = Screen.SURVIVAL_MODE
	change_screen(Constants.SCENE.SurvivalMode)


# Know if the level exists.
func level_exists(level: int) -> bool:
	return level > 0 and level <= LevelDef.level_count

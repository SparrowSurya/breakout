extends Node

# State of the game
enum GameState {
	NONE,      # Not in game
	INITIAL,   # Initial state
	COUNTDOWN, # Countdown before starting game
	PLAYING,   # Game playing state
	PAUSED,    # Game is paused
	WAITING,   # Waiting state as small break
	END,       # Game end screen state
}


var level_data: LevelDef
var game_state: GameState = GameState.NONE


func _ready() -> void:
	LevelDef.initialise()


# Enter MainMenu scene.
func enter_mainmenu() -> void:
	_exit_level()
	get_tree().change_scene_to_file(Constants.SCENE.MainMenu)
	

# Enter Levels scene.
func enter_levels() -> void:
	_exit_level()
	get_tree().change_scene_to_file(Constants.SCENE.Levels)


# Enter specific Level.
func enter_level(level: int) -> void:
	level_data = LevelDef.load_level(level)
	if level_data == null:
		push_warning("GameManager: enter level failed beacause level_data is null")
		return

	get_tree().change_scene_to_file(Constants.SCENE.Gameplay)


# Enter survival mode.
func enter_survival() -> void:
	pass


# Know if the level exists.
func has_level(level: int) -> bool:
	return level > 0 and level <= LevelDef.level_count


# Helper function that erases old level data when exited.
func _exit_level() -> void:
	level_data = null
	game_state = GameState.NONE

extends Node

# State of the game
enum GameState {
	NONE,      # Not in game
	INITIAL,   # Initial state
	COUNTDOWN, # Countdown before starting game
	PLAYING,   # Game playing state
	END,       # Game end screen state
}


var level_data: LevelData
var game_state: GameState = GameState.NONE


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
	level_data = LevelData.load_level(level)
	if level_data == null:
		push_warning("GameManager: enter level failed beacause level_data is null")
		return

	get_tree().change_scene_to_file(Constants.SCENE.LevelGame)


# Know if the level exists.
func has_level(level: int) -> bool:
	return level > 0 and level < LevelData.level_count


# Helper function that erases old level data when exited.
func _exit_level() -> void:
	level_data = null
	game_state = GameState.NONE

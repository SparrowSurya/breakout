extends Node

# State of the game
enum GameState {
	NONE,      # Not in game
	INITIAL,   # Initial state
	COUNTDOWN, # Countdown before starting game
	PLAYING,   # Game playing state
	END,       # Game end screen state
}


var levels_count: int = Constants.LEVELS_DATA.size()
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
	level_data = LevelData.new(level)
	game_state = GameState.INITIAL
	var raw_grid = Constants.LEVELS_DATA[level_data.level_no]
	level_data.grid = raw_grid
	get_tree().change_scene_to_file(Constants.SCENE.LevelGame)


# Know if the level exists.
func has_level(level: int) -> bool:
	return Constants.LEVELS_DATA.has(level)


# Helper function that erases old level data when exited.
func _exit_level() -> void:
	level_data = null
	game_state = GameState.NONE

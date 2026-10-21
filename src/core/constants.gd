class_name Constants
extends Resource


## Mapping from sound name to sound asset filepath.
const SOUND: Dictionary = {

	# Sounds inside game mode
	"BallHitPaddle": preload("res://assets/sounds/Ball-Hit-Paddle.wav"),
	"BallHitTile": preload("res://assets/sounds/Ball-Hit-Tile.wav"),
	"BallHitMetalTile": preload("res://assets/sounds/Ball-Hit-Metal-Tile.wav"),
	"BallHitWall": preload("res://assets/sounds/Ball-Hit-Wall.wav"),
	"TileDestroy": preload("res://assets/sounds/Tile-Destroy.wav"),
	"Countdown": preload("res://assets/sounds/Countdown.wav"),
	"CountdownGo": preload("res://assets/sounds/Countdown-Go.wav"),
	"LifeLost": preload("res://assets/sounds/Life-Lost.wav"),
	"GameWon": preload("res://assets/sounds/Game-Won.wav"),
	"GameLost": preload("res://assets/sounds/Game-Lost.wav"),
}


## Mapping from scene name to its filepath.
const SCENE: Dictionary = {
	
	# Screens
	"MainMenu": "res://src/screens/main_menu/main_menu.tscn",
	"SelectLevel": "res://src/screens/select_level/select_level.tscn",
	"LevelMode": "res://src/screens/game/level/level_mode.tscn",
	"SurvivalMode": "res://src/screens/game/survival/survival_mode.tscn",
	
	# Other screens
	"Ball": "res://src/game/ball/ball.tscn",
	"LevelLabel": "res://src/ui/level_card/level_label.tscn",
	"Paddle": "res://src/game/paddle/paddle.tscn",
	"Particles": "res://src/game/particles/hit_particles.tscn",
	"Tile": "res://src/game/tile/tile.tscn",
}

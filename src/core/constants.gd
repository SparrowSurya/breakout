class_name Constants
extends Resource


# Souds in the game.
const SOUND: Dictionary = {
	"BallHitPaddle": preload("res://assets/sounds/Ball-Hit-Paddle.wav"),
	"BallHitTile": preload("res://assets/sounds/Ball-Hit-Tile.wav"),
	"BallHitMetalTile": preload("res://assets/sounds/Ball-Hit-Metal-Tile.wav"),
	"BallHitWall": preload("res://assets/sounds/Ball-Hit-Wall.wav"),
	"TileDestroy": preload("res://assets/sounds/Tile-Destroy.wav"),
	"Countdown": preload("res://assets/sounds/Countdown.wav"),
	"CountdownGo": preload("res://assets/sounds/Countdown-Go.wav"),
	"GameWon": preload("res://assets/sounds/Game-Won.wav"),
	"GameLost": preload("res://assets/sounds/Game-Lost.wav"),
}

# Instanciable scenes
const SCENE: Dictionary = {
	"LevelLabel": "res://src/ui/level_card/level_label.tscn",
	"Paddle": "res://src/game/paddle/paddle.tscn",
	"Particles": "res://src/game/particles/hit_particles.tscn",
	"Tile": "res://src/game/tile/tile.tscn",
	"Ball": "res://src/game/ball/ball.tscn",
	"MainMenu": "res://src/screens/main_menu/main_menu.tscn",
	"Levels": "res://src/screens/level_select/levels.tscn",
	"LevelGame": "res://src/screens/gameplay/level_game.tscn",
}

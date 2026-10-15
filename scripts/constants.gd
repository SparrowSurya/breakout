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
	"Ball": "res://scenes/ball.tscn",
	"LevelGame": "res://scenes/level_game.tscn",
	"LevelLabel": "res://scenes/level_label.tscn",
	"Levels": "res://scenes/levels.tscn",
	"MainMenu": "res://scenes/main_menu.tscn",
	"Paddle": "res://scenes/paddle.tscn",
	"Particles": "res://scenes/hit_particles.tscn",
	"Tile": "res://scenes/tile.tscn",
}

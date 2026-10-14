extends Node

# Levels data file
const LEVELS_PATH := "res://data/levels.jsonl"

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

# TIles in the game
const TILE: Dictionary = {
	"Mauve": preload("res://assets/sprites/tiles/mauve.png"),
	"Blue": preload("res://assets/sprites/tiles/blue.png"),
	"Green": preload("res://assets/sprites/tiles/green.png"),
	"Yellow": preload("res://assets/sprites/tiles/yellow.png"),
	"Peach": preload("res://assets/sprites/tiles/peach.png"),
	"Red": preload("res://assets/sprites/tiles/red.png"),
	"Metal": preload("res://assets/sprites/tiles/metal.png"),
}

const BUTTON_TEXTURES: Dictionary = {
	"Disable": preload("res://assets/textures/button/button-disable.png"),
	"Focus": preload("res://assets/textures/button/button-focus.png"),
	"Hover": preload("res://assets/textures/button/button-hover.png"),
	"Normal": preload("res://assets/textures/button/button-normal.png"),
	"Press": preload("res://assets/textures/button/button-press.png"),
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

const HEALTH_COLORS: Dictionary = {
	0: Color("#6c7086"),
	1: Color("#cba6f7"),
	2: Color("#89b4fa"),
	3: Color("#a6e3a1"),
	4: Color("#f9e2af"),
	5: Color("#fab387"),
	6: Color("#f38ba8"),
}

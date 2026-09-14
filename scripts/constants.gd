extends Node

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

# Instanciable scenes
const SCENE: Dictionary = {
	"Tile": preload("res://scenes/tile.tscn"),
}

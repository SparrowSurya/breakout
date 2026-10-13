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

# Place this inside your global game_manager.gd script
const LEVELS_DATA: Dictionary[int, Array] = {
	1: [ # Level 1: Standard Pyramid
		0, 0, 1, 1, 0, 0,
		0, 1, 2, 2, 1, 0,
		1, 2, 3, 3, 2, 1,
	],
	2: [ # Level 2: Alternating Stripes
		1, 2, 1, 2, 1, 2,
		0, 3, 3, 3, 3, 0,
		2, 1, 2, 1, 2, 1,
	],
	3: [ # Level 3: The Walled Garden
		4, 4, 4, 4, 4, 4,
		2, 0, 0, 0, 0, 2,
		1, 1, 1, 1, 1, 1,
	],
	4: [ # Level 4: Armor Core
		0, 2, 2, 2, 2, 0,
		2, 5, 6, 6, 5, 2,
		0, 2, 2, 2, 2, 0,
	],
	5: [ # Level 5: Checkerboard Gate
		3, 0, 3, 0, 3, 0,
		0, 3, 0, 3, 0, 3,
		3, 0, 3, 0, 3, 0,
		1, 1, 1, 1, 1, 1,
	],
	6: [ # Level 6: Side Pillars
		5, 1, 0, 0, 1, 5,
		5, 2, 0, 0, 2, 5,
		5, 3, 0, 0, 3, 5,
		5, 4, 4, 4, 4, 5,
	],
	7: [ # Level 7: Reinforced Roof
		6, 6, 6, 6, 6, 6,
		3, 3, 2, 2, 3, 3,
		1, 1, 1, 1, 1, 1,
		0, 2, 0, 0, 2, 0,
	],
	8: [ # Level 8: Space Invader Shape
		0, 1, 0, 0, 1, 0,
		0, 0, 2, 2, 0, 0,
		1, 2, 3, 3, 2, 1,
		2, 2, 2, 2, 2, 2,
		1, 0, 1, 1, 0, 1,
	],
	9: [ # Level 9: Dense Fortress
		4, 4, 4, 4, 4, 4,
		5, 5, 5, 5, 5, 5,
		2, 2, 2, 2, 2, 2,
		1, 1, 1, 1, 1, 1,
	],
	10: [ # Level 10: Diamond Ring
		0, 0, 6, 6, 0, 0,
		0, 5, 1, 1, 5, 0,
		4, 1, 0, 0, 1, 4,
		0, 5, 1, 1, 5, 0,
		0, 0, 6, 6, 0, 0,
	],
	11: [ # Level 11: The Citadel Girders
		3, 3, 3, 3, 3, 3,
		0, 0, 5, 5, 0, 0,
		2, 2, 0, 0, 2, 2,
		0, 0, 5, 5, 0, 0,
		4, 4, 4, 4, 4, 4,
	],
	12: [ # Level 12: Zipper Teeth
		1, 0, 2, 0, 3, 0,
		0, 3, 0, 2, 0, 1,
		4, 0, 5, 0, 6, 0,
		0, 6, 0, 5, 0, 4,
		2, 2, 2, 2, 2, 2,
	],
	13: [ # Level 13: Titanium Shield
		6, 6, 6, 6, 6, 6,
		6, 1, 1, 1, 1, 6,
		6, 2, 0, 0, 2, 6,
		6, 3, 3, 3, 3, 6,
	],
	14: [ # Level 14: Dual X-Cross
		5, 0, 0, 0, 0, 5,
		0, 4, 1, 1, 4, 0,
		0, 1, 3, 3, 1, 0,
		0, 4, 1, 1, 4, 0,
		5, 0, 0, 0, 0, 5,
	],
	15: [ # Level 15: Rainbow Cascades
		6, 5, 4, 4, 5, 6,
		5, 4, 3, 3, 4, 5,
		4, 3, 2, 2, 3, 4,
		3, 2, 1, 1, 2, 3,
		2, 1, 0, 0, 1, 2,
	],
	16: [ # Level 16: Grand Finale Boss Matrix
		6, 6, 6, 6, 6, 6,
		6, 5, 5, 5, 5, 6,
		6, 4, 3, 3, 4, 6,
		5, 3, 2, 2, 3, 5,
		4, 2, 1, 1, 2, 4,
		3, 1, 1, 1, 1, 3,
	]
}

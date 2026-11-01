class_name PowerupRegistry
extends RefCounted


## Power types
enum PowerType {

	# Rewarding
	MULTIBALL, ## Spawns additional balls.
	FIREBALL,  ## Destorys the tiles and nearby tiles including indestructible.
	EXPANDED,  ## Grows the paddle width.
	REVIVAL,   ## Provides extra life.
	GUARDIAN,  ## Creates a barrier that prevents ball lost.

	# Punishing
	LAZY,     ## Slows the movement of the paddle.
	SHRINKED, ## Shrinks the width of paddle.
	REFORGED, ## Adds random health to some tiles.
	IMMORTAL, ## Makes the tiles immortal.
	IMPOSTER, ## Make the ball do less or no damage.

	# can be rewarding or punisshing
	OILED,         ## Makes the movement of paddle faster than normal.
	PHASE_SHIFTER, ## Changes health of leftover tiles to a single one including indestructible.
	MYSTERY,       ## Provides random powerup.
}


## Mapping from Power name to their asset file.
const POWERUP: Dictionary = {
	PowerType.MULTIBALL: preload("res://assets/textures/powerup/multiball.png"),
	PowerType.FIREBALL: preload("res://assets/textures/powerup/fireball.png"),
	PowerType.EXPANDED: preload("res://assets/textures/powerup/expanded.png"),
	PowerType.REVIVAL: preload("res://assets/textures/powerup/revival.png"),
	PowerType.GUARDIAN: preload("res://assets/textures/powerup/guardian.png"),
	PowerType.LAZY: preload("res://assets/textures/powerup/lazy.png"),
	PowerType.SHRINKED: preload("res://assets/textures/powerup/shrinked.png"),
	PowerType.REFORGED: preload("res://assets/textures/powerup/reforged.png"),
	PowerType.IMMORTAL: preload("res://assets/textures/powerup/immortal.png"),
	PowerType.IMPOSTER: preload("res://assets/textures/powerup/imposter.png"),
	PowerType.OILED: preload("res://assets/textures/powerup/oiled.png"),
	PowerType.PHASE_SHIFTER: preload("res://assets/textures/powerup/phase-shifter.png"),
	PowerType.MYSTERY: preload("res://assets/textures/powerup/mystery.png"),
}


const SCRIPTS: Dictionary = {
	PowerType.MULTIBALL: preload("res://src/game/powerup/items/multiball.gd"),
	PowerType.FIREBALL: preload("res://src/game/powerup/items/fireball.gd"),
	PowerType.EXPANDED: preload("res://src/game/powerup/items/expanded.gd"),
	PowerType.REVIVAL: preload("res://src/game/powerup/items/revival.gd"),
	PowerType.GUARDIAN: preload("res://src/game/powerup/items/guardian.gd"),
	PowerType.LAZY: preload("res://src/game/powerup/items/lazy.gd"),
	PowerType.SHRINKED: preload("res://src/game/powerup/items/shrinked.gd"),
	PowerType.REFORGED: preload("res://src/game/powerup/items/reforged.gd"),
	PowerType.IMMORTAL: preload("res://src/game/powerup/items/immortal.gd"),
	PowerType.IMPOSTER: preload("res://src/game/powerup/items/imposter.gd"),
	PowerType.OILED: preload("res://src/game/powerup/items/oiled.gd"),
	PowerType.PHASE_SHIFTER: preload("res://src/game/powerup/items/phase_shifter.gd"),
	PowerType.MYSTERY: preload("res://src/game/powerup/items/mystery.gd"),
}


static func create(type: PowerType) -> BasePowerup:
	if not SCRIPTS.has(type):
		return null
	return SCRIPTS[type].new()

class_name PowerupConfig
extends RefCounted

var enabled: bool = true
var drop_chance: float = 0.1  ## Chance per destroyed tile.
var pity_tiles: int = 15      ## Guaranteed drop after this many tiles without one (0 = off).
var interval: float = 0.0     ## Also drop every N seconds (0 = off). Useful for Survival.
var max_falling: int = 2      ## Cap on capsules on screen.
var weights: Dictionary = {}  ## PowerType -> weight. Missing or 0 = never spawns.


static func disabled() -> PowerupConfig:
	var cfg := PowerupConfig.new()
	cfg.enabled = false
	return cfg

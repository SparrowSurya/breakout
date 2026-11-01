class_name ReforgedPowerup
extends BasePowerup


func _init() -> void:
	type = PowerupRegistry.PowerType.REFORGED
	duration = 0.0


func activate() -> void:
	SoundManager.play_sfx(Constants.SOUND.PowerupReforged)
	if game.tiles_node:
		for tile in game.tiles_node.get_children():
			if tile is Tile and not tile.is_immune and tile.tile_type != TileDef.TileType.METAL:
				tile.set_tile_health(_roll_health())
	game.refresh_tile_stats()


func _roll_health() -> int:
	var roll := randf()
	if roll < 0.08:
		return 6
	elif roll < 0.20:
		return 5
	elif roll < 0.50:
		return 4
	elif roll < 0.80:
		return 3
	elif roll < 0.92:
		return 2
	else:
		return 1

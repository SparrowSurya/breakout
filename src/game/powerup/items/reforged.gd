class_name ReforgedPowerup
extends BasePowerup


func _init() -> void:
	type = PowerupRegistry.PowerType.REFORGED
	duration = 0.0


func activate() -> void:
	if game.tiles_node:
		for tile in game.tiles_node.get_children():
			if tile is Tile and not tile.is_immune and tile.tile_health < 6:
				if randf() < 0.5:
					tile.set_tile_health(tile.tile_health + 1)
	game.refresh_tile_stats()

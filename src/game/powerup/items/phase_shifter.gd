class_name PhaseShifterPowerup
extends BasePowerup


func _init() -> void:
	type = PowerupRegistry.PowerType.PHASE_SHIFTER
	duration = 0.0


func activate() -> void:
	if game.tiles_node:
		for tile in game.tiles_node.get_children():
			if tile is Tile and not tile.is_immune:
				tile.set_tile_health(randi_range(1, 6))
	game.refresh_tile_stats()

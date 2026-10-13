class_name TileDef
extends RefCounted


# Varitiey of tile we have.
enum TileType {
	
	# Destructiable tile with health.
	MAUVE,
	BLUE,
	GREEN,
	YELLOW,
	PEACH,
	RED,
	
	# Indestructible tile with health 9. It's a special value for metal tile.
	METAL,
}


var health: int
var is_immune: bool
var texture: Texture2D
var type: TileType
var color: Color

static var _table: Array[TileDef] = []


func _init(
	p_health: int,
	p_is_immune: bool,
	p_texture: Texture2D,
	p_type: TileType,
	p_color: Color,
) -> void:
	health = p_health
	is_immune = p_is_immune
	texture = p_texture
	type = p_type
	color = p_color


# Builds tile data table for visible tiles only.
static func _build_table() -> void:
	if not _table.is_empty():
		return
	
	_table = [
		TileDef.new(9, false, Constants.TILE.Metal, TileType.METAL, Constants.HEALTH_COLORS[0]),
		TileDef.new(1, false, Constants.TILE.Mauve, TileType.MAUVE, Constants.HEALTH_COLORS[1]),
		TileDef.new(2, false, Constants.TILE.Blue, TileType.BLUE, Constants.HEALTH_COLORS[2]),
		TileDef.new(3, false, Constants.TILE.Green, TileType.GREEN, Constants.HEALTH_COLORS[3]),
		TileDef.new(4, false, Constants.TILE.Yellow, TileType.YELLOW, Constants.HEALTH_COLORS[4]),
		TileDef.new(5, false, Constants.TILE.Peach, TileType.PEACH, Constants.HEALTH_COLORS[5]),
		TileDef.new(6, false, Constants.TILE.Red, TileType.RED, Constants.HEALTH_COLORS[6]),
	]


static func from_health(health: int) -> TileDef:
	_build_table()
	for entry in _table:
		if entry.health == health:
			return entry
	
	push_warning("TileDef: no entry for health %d, falling back to metal" % health)
	return _table[0]


static func from_type(type: TileType) -> TileDef:
	_build_table()
	for entry in _table:
		if entry.type == type:
			return entry
	
	push_warning("TileDef: no entry for type %d, falling back to metal" % type)
	return _table[0]

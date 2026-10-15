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

const TILE: Dictionary = {
	"Mauve": preload("res://assets/sprites/tiles/mauve.png"),
	"Blue": preload("res://assets/sprites/tiles/blue.png"),
	"Green": preload("res://assets/sprites/tiles/green.png"),
	"Yellow": preload("res://assets/sprites/tiles/yellow.png"),
	"Peach": preload("res://assets/sprites/tiles/peach.png"),
	"Red": preload("res://assets/sprites/tiles/red.png"),
	"Metal": preload("res://assets/sprites/tiles/metal.png"),
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
		TileDef.new(9, false, TILE.Metal, TileType.METAL, Palette.OVERLAY0),
		TileDef.new(1, false, TILE.Mauve, TileType.MAUVE, Palette.MAUVE),
		TileDef.new(2, false, TILE.Blue, TileType.BLUE, Palette.BLUE),
		TileDef.new(3, false, TILE.Green, TileType.GREEN, Palette.GREEN),
		TileDef.new(4, false, TILE.Yellow, TileType.YELLOW, Palette.YELLOW),
		TileDef.new(5, false, TILE.Peach, TileType.PEACH, Palette.PEACH),
		TileDef.new(6, false, TILE.Red, TileType.RED, Palette.RED),
	]


static func from_health(p_health: int) -> TileDef:
	_build_table()
	for entry in _table:
		if entry.health == p_health:
			return entry
	
	push_warning("TileDef: no entry for health %d, falling back to metal" % p_health)
	return _table[0]


static func from_type(p_type: TileType) -> TileDef:
	_build_table()
	for entry in _table:
		if entry.type == p_type:
			return entry
	
	push_warning("TileDef: no entry for type %d, falling back to metal" % p_type)
	return _table[0]

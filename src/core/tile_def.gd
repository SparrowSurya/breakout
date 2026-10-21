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
	"Mauve": preload("res://assets/textures/tiles/purple.png"),
	"Blue": preload("res://assets/textures/tiles/blue.png"),
	"Green": preload("res://assets/textures/tiles/green.png"),
	"Yellow": preload("res://assets/textures/tiles/yellow.png"),
	"Peach": preload("res://assets/textures/tiles/orange.png"),
	"Red": preload("res://assets/textures/tiles/red.png"),
	"Metal": preload("res://assets/textures/tiles/metal.png"),
}

var health: int
var is_immune: bool
var texture: Texture2D
var type: TileType
var color: Color
var particle_texture: ImageTexture

static var table: Array[TileDef] = []
static var _by_health: Dictionary[int, TileDef] = {}
static var _by_type: Dictionary[TileType, TileDef] = {}


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
	particle_texture = _create_particle_texture(p_color)


# Create 2x2 particle texture.
static func _create_particle_texture(p_color: Color) -> ImageTexture:
	var image := Image.create(2, 2, false, Image.FORMAT_RGBA8)
	image.fill(p_color)
	return ImageTexture.create_from_image(image)


# Builds tile data table for visible tiles only.
static func _build_table() -> void:
	if not table.is_empty():
		return
	
	table = [
		TileDef.new(9, true, TILE.Metal, TileType.METAL, Palette.OVERLAY0),
		TileDef.new(1, false, TILE.Mauve, TileType.MAUVE, Palette.MAUVE),
		TileDef.new(2, false, TILE.Blue, TileType.BLUE, Palette.BLUE),
		TileDef.new(3, false, TILE.Green, TileType.GREEN, Palette.GREEN),
		TileDef.new(4, false, TILE.Yellow, TileType.YELLOW, Palette.YELLOW),
		TileDef.new(5, false, TILE.Peach, TileType.PEACH, Palette.PEACH),
		TileDef.new(6, false, TILE.Red, TileType.RED, Palette.RED),
	]

	for entry in table:
		_by_health[entry.health] = entry
		_by_type[entry.type] = entry


static func from_health(p_health: int) -> TileDef:
	_build_table()
	if _by_health.has(p_health):
		return _by_health[p_health]
	
	push_warning("TileDef: no entry for health %d, falling back to metal" % p_health)
	return table[0]


static func from_type(p_type: TileType) -> TileDef:
	_build_table()
	if _by_type.has(p_type):
		return _by_type[p_type]
	
	push_warning("TileDef: no entry for type %d, falling back to metal" % p_type)
	return table[0]

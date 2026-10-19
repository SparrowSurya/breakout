class_name LevelDef
extends RefCounted


# Difficulty of the level.
enum LevelDifficulty {
	EASY,
	MEDIUM,
	HARD,
}

# Levels data file
const LEVELS_PATH := "res://data/levels.jsonl"

# Leve state data.
var level_no: int                ## Level number
var difficulty: LevelDifficulty  ## Level difficulty
var grid: Array                  ## Represents arrangemen of tiles
var rows: int                    ## Rows in the grid
var cols: int                    ## Columns in the grid
var row_gap: float               ## Gap between rows
var col_gap: float               ## Gap between columns
var tile_width: float            ## Width of the tile
var tile_height: float           ## Height of the tile

static var level_count: int = -1              ## Total number of levels
static var _cache: Dictionary[int, LevelDef]  ## STores the levels data


# Initialises the initial level data.
static func initialise() -> void:
	if level_count != -1:
		return

	level_count = 0

	var file := FileAccess.open(LEVELS_PATH, FileAccess.READ)
	if file == null:
		push_error("Failed to open levels file")
		return

	while not file.eof_reached():
		var line = file.get_line()
		var level_def: LevelDef = _parse(line)

		if level_def == null:
			break

		level_count += 1
		_cache[level_def.level_no] = level_def

	file.close()


# Parses JSON string representing a level
static func _parse(line: String) -> LevelDef:
	if not line.begins_with("{") and not line.ends_with("}"):
		return null

	var parsed = JSON.parse_string(line)
	if not parsed is Dictionary:
		return null

	var level_def := LevelDef.new()
	level_def.level_no = int(parsed.get("level_no", 0))
	level_def.difficulty = _parse_difficulty(parsed.get("difficulty", "easy"))
	level_def.rows = int(parsed.get("rows", 0))
	level_def.cols = int(parsed.get("cols", 0))
	level_def.row_gap = float(parsed.get("row_gap", 4.0))
	level_def.col_gap = float(parsed.get("col_gap", 8.0))
	level_def.tile_width = float(parsed.get("tile_width", 30.0))
	level_def.tile_height = float(parsed.get("tile_height", 12.0))

	for value in parsed.get("grid", []):
		level_def.grid.append(int(value))

	return level_def


# Returns the level definition if exists
static func load_level(level: int) -> LevelDef:
	if _cache.has(level):
		return _cache[level]
	
	return null


static func _parse_difficulty(p_difficulty: String) -> LevelDifficulty:
	match p_difficulty.to_lower():
		"medium":
			return LevelDifficulty.MEDIUM
		"hard":
			return LevelDifficulty.HARD
		"easy":
			return LevelDifficulty.EASY
	return LevelDifficulty.EASY

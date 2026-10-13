class_name LevelData
extends RefCounted


var level_no: int
var grid: Array
var rows: int
var cols: int
var row_gap: float
var col_gap: float
var tile_width: float
var tile_height: float

static var level_count: int = -1
static var _cache: Dictionary[int, LevelData]


static func initialise() -> void:
	if level_count != -1:
		return
	
	level_count = 0

	var file := FileAccess.open(Constants.LEVELS_PATH, FileAccess.READ)
	if file == null:
		push_error("Failed to open levels file")
		return

	while not file.eof_reached():
		file.get_line()
		level_count += 1

	file.close()


static func load_level(level: int) -> LevelData:
	if _cache.has(level):
		return _cache[level]
	
	initialise()

	if level < 1 or level >= level_count:
		push_error("Invalid level: %d", level)
		return null
	
	return _load_from_file(level)
#

static func _load_from_file(level: int) -> LevelData:
	var file := FileAccess.open(Constants.LEVELS_PATH, FileAccess.READ)
	if file == null:
		return null
#
	for i in range(level + 1):
		if file.eof_reached():
			file.close()
			return null
#
		var line := file.get_line()

		if i == level:
			file.close()
#
			var parsed = JSON.parse_string(line)
			if not parsed is Dictionary:
				push_error("Invalid JSON at line: %d" % level)
				return null
#
			var level_data := LevelData.new()
			level_data.level_no = int(parsed.get("level_no", 0))
			level_data.rows = int(parsed.get("rows", 0))
			level_data.cols = int(parsed.get("cols", 0))
			level_data.row_gap = float(parsed.get("row_gap", 4.0))
			level_data.col_gap = float(parsed.get("col_gap", 8.0))
			level_data.tile_width = float(parsed.get("tile_width", 32.0))
			level_data.tile_height = float(parsed.get("tile_height", 16.0))
#
			for value in parsed.get("grid", []):
				level_data.grid.append(int(value))
#			
			_cache[level] = level_data
			return level_data
#
	file.close()
	return null

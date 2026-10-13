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


func _init(level: int) -> void:
	level_no = level
	_load_data() # TODO: for testing only


# TODO: use this to load from jsonl file
func _load_from_file() -> void:
	pass


func _load_data() -> void:
	rows = 3
	cols = 6
	row_gap = 4.0
	col_gap = 8.0
	grid = [
		1, 2, 1, 2, 1, 2,
		0, 3, 3, 3, 3, 0,
		2, 1, 2, 1, 2, 1,
	]
	tile_width = 32.0
	tile_height = 16.0

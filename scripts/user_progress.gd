extends Node

# User data file
const USER_PROGRESS_PATH := "user://progress.json"

# A copy of the actual data in file.
var _cache: Dictionary[int, LevelProgress] = {}


func _ready() -> void:
	var raw_data = _load()
	_cache = _parse(raw_data)


# Saves the level progress
func save(progress: LevelProgress) -> void:
	_cache[progress.level_no] = progress
	_unlock_level(progress.level_no+1)
	var data = _to_dict()
	_save(data)


# Returns the LevelProgress for given level
func of_level(level_no: int) -> LevelProgress:
	if _cache.has(level_no):
		return _cache[level_no]
	return LevelProgress.as_locked(level_no)


# Returns the total stars collected
func stars_collected() -> int:
	var count = 0
	for key in _cache.keys():
		count += _cache[key].stars
	return count


# Returns the level_no which after which all are locked
func highest_unlocked_level() -> int:
	var level_no: int = 0
	for key in _cache.keys():
		var value = _cache[key]
		var unlocked = value.status == LevelProgress.LevelStatus.UNLOCKED
		if unlocked and value.level_no > level_no:
			level_no = value.level_no
	return level_no


# Unlocks given level
func _unlock_level(level_no: int):
	if 0 < level_no and level_no <= LevelDef.level_count:
		_cache[level_no] = LevelProgress.as_wip(level_no, 0.0)


# Parses the intenral cache to dictionary
func _to_dict() -> Dictionary[int, Dictionary]:
	var data: Dictionary[int, Dictionary] = {}
	for key in _cache.keys():
		var value = _cache[key]
		data[key] = {
			"level_no": value.level_no,
			"status": _status_to_string(value.status),
			"progress": value.progress,
			"stars": value.stars,
		}
	return data


# Converts LevelStatus enum into string representation
func _status_to_string(status: LevelProgress.LevelStatus) -> String:
	match status:
		LevelProgress.LevelStatus.LOCKED:
			return "locked"
		_:
			return "unlocked"


# Converts string to LevelStatus enum
func _string_to_status(value: String) -> LevelProgress.LevelStatus:
	match value.to_lower():
		"unlocked":
				return LevelProgress.LevelStatus.UNLOCKED
		_:
			return LevelProgress.LevelStatus.LOCKED


# Saves data to file
func _save(data: Dictionary) -> void:
	var file = FileAccess.open(USER_PROGRESS_PATH, FileAccess.WRITE)
	if file:
		file.store_string(JSON.stringify(data))
		file.close()
	else:
		push_error("UserProgress: failed to save user progress")


# Loads data from file
func _load() -> Dictionary[int, Dictionary]:
	if not FileAccess.file_exists(USER_PROGRESS_PATH):
		return {}

	var file = FileAccess.open(USER_PROGRESS_PATH, FileAccess.READ)
	var content = file.get_as_text()
	file.close()

	var data = JSON.parse_string(content)

	if data is Dictionary[int, Dictionary]:
		return data

	return {}


# Parses the raw data into suitable format. Additionally makes first level unlocked.
func _parse(data: Dictionary[int, Dictionary]) -> Dictionary[int, LevelProgress]:
	var parsed: Dictionary[int, LevelProgress] = {}
	for key in parsed.keys():
		parsed[key] = LevelProgress.new(
			key,
			_string_to_status(data.get("status", "locked")),
			data.get("progress", 0.0),
			data.get("stars", 0),
		)
	
	# Make sure that first level is unlocked
	var first_level = parsed.get(1)
	if first_level == null:
		parsed[1] = LevelProgress.as_wip(1, 0.0)
	else:
		first_level.status = LevelProgress.LevelStatus.UNLOCKED
	
	return parsed

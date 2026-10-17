extends Node

# User data file
const USER_PROGRESS_PATH := "user://progress.json"

# A copy of the actual data in file.
var _cache: Dictionary[int, LevelProgress] = {}


func _ready() -> void:
	var raw_data = _load()
	_cache = _parse(raw_data)


# Saves the level progress. It save the best of current or existing. Additionally unlocks the next level
# if current level is completed.
func save(new_progress: LevelProgress) -> void:
	var level_no = new_progress.level_no
	var existing = get_level(level_no)
	
	# Select best state
	var should_update: bool
	if not _cache.has(level_no):
		should_update = true
	elif new_progress.stars > existing.stars:
		should_update = true
	elif new_progress.stars == existing.stars and new_progress.progress > existing.progress:
		should_update = true
	else:
		should_update = false
	
	if should_update:
		_cache[level_no] = new_progress
	
	# Unlock next level if current is finished and next is locked.
	var current_best = _cache[level_no]
	var is_complete = current_best.progress >= 100.0
	var next_level_no = level_no+1
	var next_level_exists = next_level_no <= LevelDef.level_count

	if is_complete and next_level_exists:
		var next_level = get_level(next_level_no)
		if next_level.status == LevelProgress.LevelStatus.LOCKED:
			_cache[next_level_no] = LevelProgress.as_wip(next_level_no, 0.0)

	_save()


# Returns the LevelProgress for given level
func get_level(level_no: int) -> LevelProgress:
	var progress = _cache.get(level_no)
	if progress:
		return progress
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
func _save() -> void:
	var data = _to_dict()
	var file = FileAccess.open(USER_PROGRESS_PATH, FileAccess.WRITE)
	if file:
		file.store_string(JSON.stringify(data))
		file.close()
	else:
		push_error("UserProgress: failed to save user progress")


# Loads data from file. Additionally, converts string key to int key.
func _load() -> Dictionary[int, Dictionary]:
	if not FileAccess.file_exists(USER_PROGRESS_PATH):
		return {}

	var file = FileAccess.open(USER_PROGRESS_PATH, FileAccess.READ)
	if not file:
		return {}

	var content = file.get_as_text()
	file.close()

	var data = JSON.parse_string(content)

	if data is Dictionary:
		var result: Dictionary[int, Dictionary] = {}
		for key in data:
			if not key.is_valid_int():
				push_warning("Invalid level key: %s" % key)
				continue
			result[int(key)] = data[key]
		return result

	return {}


# Parses the raw data into suitable format. Additionally makes first level unlocked.
func _parse(data: Dictionary[int, Dictionary]) -> Dictionary[int, LevelProgress]:
	var parsed: Dictionary[int, LevelProgress] = {}
	for key in data.keys():
		var value = data[key]
		parsed[key] = LevelProgress.new(
			key,
			_string_to_status(value.get("status", "locked")),
			value.get("progress", 0.0),
			value.get("stars", 0),
		)
	
	# Make sure that first level is unlocked
	var first_level = parsed.get(1)
	if first_level == null:
		parsed[1] = LevelProgress.as_wip(1, 0.0)
	else:
		first_level.status = LevelProgress.LevelStatus.UNLOCKED
	
	return parsed

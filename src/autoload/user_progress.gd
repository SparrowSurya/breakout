extends Node

## Signal emitted when progress is loaded.
signal progress_loaded


# User data file.
const USER_PROGRESS_PATH := "user://progress.json"
const USER_HIGHSCORE_PATH := "user://highscore.txt"

## A copy of the actual data in file.
var _levels: Dictionary[int, LevelProgress] = {
	1: LevelProgress.as_wip(1), # FIrst level always unlocked
}

var highscore: int = 0        ## Best score in survival mode
var time_taken: float = 0.0   ## Time taken for the highscore
var total_hits: int = 0       ## Total hits done
var tiles_cleared: int = 0    ## Total tiles cleared


func _ready() -> void:
	if not YTPlayableSdk.in_playables_env():
		var raw_data = _load_levels()
		_levels = _parse_levels(raw_data)

		raw_data = _load_survival_data()
		_set_survival_data(raw_data)
		
		progress_loaded.emit()
	else:
		YTPlayableSdk.load_data_received.connect(_on_yt_playable_load_data)
		YTPlayableSdk.save_data_success.connect(_on_yt_playable_save_data_success)
		YTPlayableSdk.save_data_failed.connect(_on_yt_playable_save_data_failed)
		YTPlayableSdk.load_data()


## Saves the level progress. It save the best of current or existing. Additionally unlocks the next level
## if current level is completed.
func save_progress(new_progress: LevelProgress) -> void:
	var level_no = new_progress.level_no
	var existing = get_level(level_no)
	
	# Select best state
	var should_update: bool
	if not _levels.has(level_no):
		should_update = true
	elif new_progress.stars > existing.stars:
		should_update = true
	elif new_progress.stars == existing.stars and new_progress.progress > existing.progress:
		should_update = true
	else:
		should_update = false
	
	if should_update:
		_levels[level_no] = new_progress
	
	# Unlock next level if current is finished and next is locked.
	var current_best = _levels[level_no]
	var is_complete = current_best.progress >= 100.0
	var next_level_no = level_no + 1
	var next_level_exists = next_level_no <= LevelDef.level_count

	if is_complete and next_level_exists:
		var next_level = get_level(next_level_no)
		if next_level.status == LevelProgress.LevelStatus.LOCKED:
			_levels[next_level_no] = LevelProgress.as_wip(next_level_no, 0.0)

	_save_levels()


func save_highscore(score: int, p_time_taken: float, p_total_hits: int, p_tiles_cleared: int) -> void:
	if score > highscore:
		highscore = score
		time_taken = p_time_taken
		total_hits = p_total_hits
		tiles_cleared = p_tiles_cleared
		_save_highscore()


## Returns the LevelProgress for given level
func get_level(level_no: int) -> LevelProgress:
	var progress = _levels.get(level_no)
	if progress:
		return progress
	return LevelProgress.as_locked(level_no)


## Returns the total stars collected
func stars_collected() -> int:
	var count = 0
	for level in _levels.values():
		count += level.stars
	return count


## Returns the level_no which after which all are locked
func highest_unlocked_level() -> int:
	var level_no: int = 1
	for level in _levels.values():
		if level.status == LevelProgress.LevelStatus.UNLOCKED and level.level_no > level_no:
			level_no = level.level_no
	return level_no


## Returns survival data as Dictionary.
func _survival_data() -> Dictionary:
	return {
		"highscore": highscore,
		"time_taken": time_taken,
		"total_hits": total_hits,
		"tiles_cleared": tiles_cleared,
	}


## Parses the intenral cache to dictionary
func _levels_to_dict() -> Dictionary[int, Dictionary]:
	var data: Dictionary[int, Dictionary] = {}
	for key in _levels.keys():
		var value = _levels[key]
		data[key] = {
			"level_no": value.level_no,
			"status": _status_to_string(value.status),
			"progress": value.progress,
			"stars": value.stars,
			"time": value.time,
		}
	return data


## Converts LevelStatus enum into string representation
func _status_to_string(status: LevelProgress.LevelStatus) -> String:
	match status:
		LevelProgress.LevelStatus.LOCKED:
			return "locked"
		_:
			return "unlocked"


## Converts string to LevelStatus enum
func _string_to_status(value: String) -> LevelProgress.LevelStatus:
	match value.to_lower():
		"unlocked":
				return LevelProgress.LevelStatus.UNLOCKED
		_:
			return LevelProgress.LevelStatus.LOCKED


## Loads data from file. Additionally, converts string key to int key.
func _load_levels() -> Dictionary[int, Dictionary]:
	if not FileAccess.file_exists(USER_PROGRESS_PATH):
		return {}

	var file = FileAccess.open(USER_PROGRESS_PATH, FileAccess.READ)
	if not file:
		return {}

	var content = file.get_as_text()
	file.close()

	var data = JSON.parse_string(content)

	if data is Dictionary:
		return _convert_string_key_to_int(data)
	return {}


## Loads the survival user data from file.
func _load_survival_data() -> Dictionary:
	if not FileAccess.file_exists(USER_HIGHSCORE_PATH):
		return {}

	var file = FileAccess.open(USER_HIGHSCORE_PATH, FileAccess.READ)
	if not file:
		return {}

	var content = file.get_as_text()
	file.close()
	
	var data = JSON.parse_string(content)
	if data is Dictionary:
		return data
	
	return {}


## Parses the raw data into suitable format. Additionally makes first level unlocked.
func _parse_levels(data: Dictionary[int, Dictionary]) -> Dictionary[int, LevelProgress]:
	var parsed: Dictionary[int, LevelProgress] = {}
	for key in data.keys():
		var value = data[key]
		parsed[key] = LevelProgress.new(
			key,
			_string_to_status(value.get("status", "locked")),
			value.get("progress", 0.0),
			value.get("stars", 0),
			value.get("time", 0.0),
		)
	
	# Make sure that first level is unlocked
	var first_level = parsed.get(1)
	if first_level == null:
		parsed[1] = LevelProgress.as_wip(1, 0.0)
	else:
		first_level.status = LevelProgress.LevelStatus.UNLOCKED
	
	return parsed


## Sets the variables related to survival mode.
func _set_survival_data(data: Dictionary) -> void:
	highscore = data.get("highscore", 0)
	time_taken = data.get("time_taken", 0.0)
	total_hits = data.get("total_hits", 0)
	tiles_cleared = data.get("tiles_cleared", 0)


## Converts the string key of dictionary as int.
func _convert_string_key_to_int(data: Dictionary) -> Dictionary[int, Dictionary]:
	var result: Dictionary[int, Dictionary] = {}
	for key in data:
		if not key.is_valid_int():
			push_warning("Invalid level key: %s" % key)
			continue
		result[int(key)] = data[key]
	return result


## Saves levels data.
func _save_levels() -> void:
	if YTPlayableSdk.in_playables_env():
		_save_yt_playable_user_data()
		return

	var data = _levels_to_dict()
	var file = FileAccess.open(USER_PROGRESS_PATH, FileAccess.WRITE)
	if file:
		file.store_string(JSON.stringify(data))
		file.close()
	else:
		push_error("UserProgress: failed to save level progress")


## Saves survival data.
func _save_highscore() -> void:
	if YTPlayableSdk.in_playables_env():
		_save_yt_playable_user_data()
		YTPlayableSdk.send_score(highscore)
		return

	var data = JSON.stringify(_survival_data())
	var file = FileAccess.open(USER_HIGHSCORE_PATH, FileAccess.WRITE)
	if file:
		file.store_string(data)
		file.close()
	else:
		push_error("UserProgress: failed to save highscore")


## --------------------------------------------------------------------------------youtube-playables

## Sets the user data from yt playebles received data.
func _on_yt_playable_load_data(data: String) -> void:
	var content = JSON.parse_string(data)
	if content is not Dictionary:
		return

	var survival_data = content.get("survival", {})
	var levels_data = content.get("levels", {})

	_set_survival_data(survival_data)
	_levels = _parse_levels(_convert_string_key_to_int(levels_data))
	progress_loaded.emit()


## Saves the user progress data to yt playables.
func _save_yt_playable_user_data() -> void:
	var data = JSON.stringify({
		"survival": _survival_data(),
		"levels": _levels_to_dict(),
	})
	YTPlayableSdk.save_data(data)


func _on_yt_playable_save_data_success() -> void:
	print("UserProgress.YTPlayable: user data saved.")


func _on_yt_playable_save_data_failed(error_message: String) -> void:
	print("UserProgress.YTPlayable: user data failed to save.\n%s" % error_message)
	push_error(error_message)


## ------------------------------------------------------------------------------------------testing

##NOTE: This is onyl for testing purposes.
func dbg_unlock_all_levels() -> void:
	for i in range(LevelDef.level_count+1):
		if not _levels.has(i) or _levels[i].status == LevelProgress.LevelStatus.LOCKED:
			_levels[i] = LevelProgress.as_wip(i)
	_save_levels()

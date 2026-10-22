class_name LevelProgress
extends RefCounted


enum LevelStatus {
	LOCKED,
	UNLOCKED
}

var level_no: int = 1
var status: LevelStatus = LevelStatus.LOCKED
var progress: float = 0.0
var stars: int = 0


func _init(
	p_level_no: int,
	p_status: LevelStatus,
	p_progress: float = 0.0,
	p_stars: int = 0,
) -> void:
	level_no = p_level_no
	status = p_status
	progress = p_progress
	stars = p_stars


# Instantiate as locked level
static func as_locked(p_level_no: int) -> LevelProgress:
	return LevelProgress.new(p_level_no, LevelStatus.LOCKED)


# Instantiate as level in progress
static func as_wip(p_level_no: int, p_progress: float = 0.0) -> LevelProgress:
	return LevelProgress.new(p_level_no, LevelStatus.UNLOCKED, p_progress, 0)


# Instantiate as level completed
static func as_done(p_level_no: int, p_stars: int) -> LevelProgress:
	return LevelProgress.new(p_level_no, LevelStatus.UNLOCKED, 100.0, p_stars)

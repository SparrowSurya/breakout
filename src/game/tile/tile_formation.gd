class_name TileFormation
extends RefCounted

# Tile formation data
var grid_rows: int
var grid_cols: int
var grid_data: Array[int]
var grid_wall: bool

## These tiles has health and are destructible.
static var health_tiles: Array[int] = [1, 2, 3, 4, 5, 6]

## This counts as tile but dues to zero health it just occupioes space but no tile is present.
static var no_tile: int = 0

## This tile is non destructible.
static var metal_tile: int = 9


## Different types of formations
enum Archetype {
	PYRAMID_VAULT,
	CHECKER_INFILTRATOR,
	STRIPED_BASTION,
	FORTRESS_BORDER,
	SYMMETRIC_INVADER,
	DIAMOND_CITADEL,
}

const MAX_HISTORY: int = 3
static var _history: Array[int] = []


func _init(p_rows: int, p_cols: int, p_data: Array[int], p_wall: bool) -> void:
	grid_rows = p_rows
	grid_cols = p_cols
	grid_data = p_data
	grid_wall = p_wall


## Initialises the important things.
static func initialise() -> void:
	_history.clear()


## Select an archetype that has not appeared in the last 3 matches.
static func _select_archetype() -> int:
	var available: Array[int] = []
	for arch in Archetype.values():
		if arch not in _history:
			available.append(arch)

	if available.is_empty():
		available.assign(Archetype.values())

	var chosen: int = available.pick_random()
	_history.append(chosen)
	if _history.size() > MAX_HISTORY:
		_history.pop_front()
	return chosen


## Creates a strategic tile formation tailored for the specific survival stage.
static func create_for_stage(stage: int) -> TileFormation:
	var profile: Dictionary = _get_stage_profile(stage)
	var rows: int = profile.rows
	var cols: int = profile.cols
	var wall: bool = false
	var grid: Array[int] = _create(rows, cols, wall, profile.min_hp, profile.max_hp, profile.allow_metal, profile.high_hp_cap)
	return TileFormation.new(rows, cols, grid, wall)


## Returns a metric-driven difficulty profile based on the survival stage number.
static func _get_stage_profile(stage: int) -> Dictionary:
	if stage <= 3:
		# Phase 1: Onboarding (Compact, HP 1-2 only, 0 metal)
		return {
			"rows": 3,
			"cols": randi_range(5, 6),
			"min_hp": 1,
			"max_hp": 2,
			"high_hp_cap": 0,
			"allow_metal": false,
		}
	elif stage <= 7:
		# Phase 2: Volume Expansion (More tiles, HP 1-3 only, 0 metal)
		return {
			"rows": 4,
			"cols": randi_range(5, 6),
			"min_hp": 1,
			"max_hp": 3,
			"high_hp_cap": 0,
			"allow_metal": false,
		}
	elif stage <= 12:
		# Phase 3: Armored Debut (HP 4-5 in low amount <= 3 tiles, 0 metal)
		return {
			"rows": randi_range(4, 5),
			"cols": 6,
			"min_hp": 1,
			"max_hp": 5,
			"high_hp_cap": 3,
			"allow_metal": false,
		}
	elif stage <= 18:
		# Phase 4: Heavy Fortification (Prominent HP 4-6, 0 metal)
		return {
			"rows": randi_range(5, 6),
			"cols": 6,
			"min_hp": 2,
			"max_hp": 6,
			"high_hp_cap": 999,
			"allow_metal": false,
		}
	elif stage <= 25:
		# Phase 5: The Iron Frontier (Full HP 1-6 + Metal obstacles)
		return {
			"rows": randi_range(5, 6),
			"cols": randi_range(6, 7),
			"min_hp": 2,
			"max_hp": 6,
			"high_hp_cap": 999,
			"allow_metal": true,
		}
	else:
		# Phase 6: Endless Crucible (Dynamic weighted probability mix)
		var roll: float = randf()
		if roll < 0.15:
			# Breather Stage (15% chance: fast clear, low HP, 0 metal)
			return {
				"rows": randi_range(3, 4),
				"cols": 6,
				"min_hp": 1,
				"max_hp": 3,
				"high_hp_cap": 0,
				"allow_metal": false,
			}
		elif roll < 0.40:
			# Tactical Corridor (25% chance: medium grid, HP 2-5, sparse metal)
			return {
				"rows": randi_range(4, 5),
				"cols": 6,
				"min_hp": 2,
				"max_hp": 5,
				"high_hp_cap": 6,
				"allow_metal": randf() < 0.5,
			}
		else:
			# Heavy Citadel / Iron Bastion (60% chance: full spectrum, metal anchors)
			return {
				"rows": randi_range(5, 6),
				"cols": randi_range(6, 7),
				"min_hp": 2,
				"max_hp": 6,
				"high_hp_cap": 999,
				"allow_metal": true,
			}


## Create TileFormation instance of randomly selected strategic tile formation pattern (unrestricted).
static func create(rows: int, cols: int) -> TileFormation:
	var wall: bool = false # Removed for now. randi_range(0, 1) == 1
	var grid: Array[int] = _create(rows, cols, wall, 1, 6, true, 999)
	return TileFormation.new(rows, cols, grid, wall)


## Creates strategic tile formation pattern.
static func _create(rows: int, cols: int, wall: bool, min_hp: int = 1, max_hp: int = 6, allow_metal: bool = true, high_hp_cap: int = 999) -> Array[int]:
	var archetype: int = _select_archetype()
	var grid: Array[int] = _create_wall(rows, cols, no_tile) if wall else _create_grid(rows, cols, no_tile)

	match archetype:
		Archetype.PYRAMID_VAULT:
			_build_pyramid_vault(rows, cols, wall, grid, min_hp, max_hp, allow_metal)
		Archetype.CHECKER_INFILTRATOR:
			_build_checker_infiltrator(rows, cols, wall, grid, min_hp, max_hp, allow_metal)
		Archetype.STRIPED_BASTION:
			_build_striped_bastion(rows, cols, wall, grid, min_hp, max_hp, allow_metal)
		Archetype.FORTRESS_BORDER:
			_build_fortress_border(rows, cols, wall, grid, min_hp, max_hp, allow_metal)
		Archetype.SYMMETRIC_INVADER:
			_build_symmetric_invader(rows, cols, wall, grid, min_hp, max_hp, allow_metal)
		Archetype.DIAMOND_CITADEL:
			_build_diamond_citadel(rows, cols, wall, grid, min_hp, max_hp, allow_metal)

	# Enforce high-HP quota if specified
	if high_hp_cap < 999:
		var high_hp_count: int = 0
		for i in range(grid.size()):
			if grid[i] >= 4 and grid[i] <= 6:
				high_hp_count += 1
				if high_hp_count > high_hp_cap:
					grid[i] = clampi(min_hp + 1, 1, 3)

	# Failsafe: if grid is completely empty, populate with a fallback gradient
	var has_destructible: bool = false
	for val in grid:
		if val in health_tiles:
			has_destructible = true
			break
	if not has_destructible:
		_fill_gradient(rows, cols, grid, [], wall, min_hp, max_hp)

	return grid


## Fills a mask with a smooth vertical health gradient (softer entry below, tougher above).
static func _fill_gradient(rows: int, cols: int, grid: Array[int], mask: Array[int], wall: bool, min_hp: int = 1, max_hp: int = 6) -> void:
	var index: int = 0
	for r in range(rows):
		var row_cols: int = cols - ((r & 1) if wall else 0)
		var t: float = float(rows - 1 - r) / float(max(1, rows - 1))
		var hp: int = clampi(int(round(lerp(float(min_hp), float(max_hp), t))), 1, 6)
		for c in range(row_cols):
			if mask.is_empty() or mask[index] != 0:
				grid[index] = hp
			index += 1


# --- ARCHETYPE BUILDERS ---

## 1. Triangular pyramid with protected apex or side metal anchor posts.
static func _build_pyramid_vault(rows: int, cols: int, wall: bool, grid: Array[int], min_hp: int = 1, max_hp: int = 5, allow_metal: bool = true) -> void:
	var pyr_mask: Array[int] = _mask_pyramid(rows, cols, wall, false)
	_fill_gradient(rows, cols, grid, pyr_mask, wall, min_hp, max_hp)

	# Cap the apex or corner posts with metal if allowed
	if allow_metal:
		var idx: int = 0
		for r in range(rows):
			var row_cols: int = cols - ((r & 1) if wall else 0)
			for c in range(row_cols):
				if pyr_mask[idx] != 0:
					if r == 0:
						grid[idx] = metal_tile
					elif (c == 0 or c == row_cols - 1) and r == rows - 1:
						grid[idx] = metal_tile
				idx += 1


## 2. Porous checkerboard pattern allowing balls to filter through to upper rows.
static func _build_checker_infiltrator(rows: int, cols: int, wall: bool, grid: Array[int], min_hp: int = 2, max_hp: int = 6, allow_metal: bool = true) -> void:
	var check_mask: Array[int] = _mask_checkerboard(rows, cols, wall)
	_fill_gradient(rows, cols, grid, check_mask, wall, min_hp, max_hp)

	# Place sparse metal anchors in the second row if allowed
	if allow_metal:
		var idx: int = 0
		for r in range(rows):
			var row_cols: int = cols - ((r & 1) if wall else 0)
			for c in range(row_cols):
				if r == 1 and check_mask[idx] != 0 and (c == 1 or c == row_cols - 2):
					grid[idx] = metal_tile
				idx += 1


## 3. Striped bastion with alternating health tiers and open corridors.
static func _build_striped_bastion(rows: int, cols: int, wall: bool, grid: Array[int], min_hp: int = 1, max_hp: int = 6, allow_metal: bool = true) -> void:
	var stripe_mask: Array[int] = _mask_stripes(rows, cols, wall, false, 1)
	_fill_gradient(rows, cols, grid, stripe_mask, wall, min_hp, max_hp)

	# Carve vertical corridor in the middle so ball can penetrate deep
	var idx: int = 0
	for r in range(rows):
		var row_cols: int = cols - ((r & 1) if wall else 0)
		var mid: int = row_cols >> 1
		for c in range(row_cols):
			if c == mid and r > 0 and r < rows - 1:
				grid[idx] = no_tile
			elif allow_metal and (c == 0 or c == row_cols - 1) and r == 1:
				grid[idx] = metal_tile
			idx += 1


## 4. Fortress with an outer border wall guarding a high-value core.
static func _build_fortress_border(rows: int, cols: int, wall: bool, grid: Array[int], min_hp: int = 2, max_hp: int = 5, allow_metal: bool = true) -> void:
	var border_mask: Array[int] = _mask_border(rows, cols, wall)
	var inner_mask: Array[int] = _mask_invert(border_mask)

	# Outer perimeter
	_fill(rows, cols, min_hp, grid, border_mask, wall)

	# Inner vault: tougher core tiles
	_fill(rows, cols, max_hp, grid, inner_mask, wall)

	# Metal reinforced corners if allowed
	if allow_metal:
		var idx: int = 0
		for r in range(rows):
			var row_cols: int = cols - ((r & 1) if wall else 0)
			for c in range(row_cols):
				if (r == 0 or r == rows - 1) and (c == 0 or c == row_cols - 1):
					grid[idx] = metal_tile
				idx += 1


## 5. Horizontally mirrored arcade invader silhouette.
static func _build_symmetric_invader(rows: int, cols: int, wall: bool, grid: Array[int], min_hp: int = 2, max_hp: int = 5, allow_metal: bool = true) -> void:
	var sym_mask: Array[int] = _mask_symmetric(rows, cols, 0.25, wall)
	_fill_gradient(rows, cols, grid, sym_mask, wall, min_hp, max_hp)

	# Center metal eyelet / pivot if allowed
	if allow_metal:
		var idx: int = 0
		for r in range(rows):
			var row_cols: int = cols - ((r & 1) if wall else 0)
			var mid: int = row_cols >> 1
			for c in range(row_cols):
				if r == 1 and (c == mid or (row_cols % 2 == 0 and c == mid - 1)):
					if sym_mask[idx] != 0:
						grid[idx] = metal_tile
				idx += 1


## 6. Diamond citadel: regular pyramid meeting an inverted pyramid.
static func _build_diamond_citadel(rows: int, cols: int, wall: bool, grid: Array[int], min_hp: int = 3, max_hp: int = 6, allow_metal: bool = true) -> void:
	var top_pyr: Array[int] = _mask_pyramid(rows, cols, wall, false)
	var bot_pyr: Array[int] = _mask_pyramid(rows, cols, wall, true)
	var diamond_mask: Array[int] = _mask_and(top_pyr, bot_pyr)

	# Fill diamond core with high-health bricks
	_fill_gradient(rows, cols, grid, diamond_mask, wall, min_hp, max_hp)

	# Surround diamond with perimeter wing bricks
	var wings_mask: Array[int] = _mask_xor(top_pyr, bot_pyr)
	_fill(rows, cols, min_hp, grid, wings_mask, wall)

	# Metal center anchor if allowed
	if allow_metal:
		var idx: int = 0
		for r in range(rows):
			var row_cols: int = cols - ((r & 1) if wall else 0)
			var mid_r: int = rows >> 1
			var mid_c: int = row_cols >> 1
			for c in range(row_cols):
				if r == mid_r and c == mid_c:
					grid[idx] = metal_tile
				idx += 1


## Helper logical XOR for masks.
static func _mask_xor(mask_a: Array[int], mask_b: Array[int]) -> Array[int]:
	var result: Array[int] = []
	var count: int = mini(mask_a.size(), mask_b.size())
	result.resize(count)
	for i in range(count):
		var a: bool = mask_a[i] != 0
		var b: bool = mask_b[i] != 0
		result[i] = 1 if (a != b) else 0
	return result



## Creates simple hollow grid of given rows and columns.
static func _create_grid(rows: int, cols: int, value: int = 0) -> Array[int]:
	var grid: Array[int] = []
	for i in range(rows*cols):
		grid.append(value)
	return grid


## Creates wall like hollow grid of given rows and columns where every 2nd row will have cols-1 tiles.
static func _create_wall(rows: int, cols: int, value: int = 0) -> Array[int]:
	var grid: Array[int] = []
	for r in range(rows):
		for c in range(cols - (r & 1)):
			grid.append(value)
	return grid


## Fills the grid with given value where mask is not set.
static func _fill(rows: int, cols: int, value: int, grid: Array[int], mask: Array[int], wall: bool) -> void:
	var index: int = 0
	for r in range(rows):
		var delta = (r & 1) if wall else 0
		for c in range(cols - delta):
			if mask.is_empty() or mask[index] != 0:
				grid[index] = value
			index += 1


## Creates a random mask on the grid. 0 means mask is set and 1 means that mask is not set.
## In short where value is 1 it can be overwritten.
static func _mask_random(rows: int, cols: int, mask_chance: float, wall: bool) -> Array[int]:
	var grid: Array[int] = []
	for r in range(rows):
		var delta = (r & 1) if wall else 0
		for c in range(cols - delta):
			var value: int = 0 if randf() < mask_chance else 1
			grid.append(value)
	return grid


## Creates a horizontally symmetric mask by reflecting the left half onto the right half.
static func _mask_symmetric(rows: int, cols: int, mask_chance: float, wall: bool) -> Array[int]:
	var mask: Array[int] = []
	for r in range(rows):
		var row_cols: int = cols - ((r & 1) if wall else 0)
		var half_cols: int = (row_cols + 1) >> 1
		var left_half: Array[int] = []

		for c in range(half_cols):
			left_half.append(0 if randf() < mask_chance else 1)

		for c in range(row_cols):
			if c < half_cols:
				mask.append(left_half[c])
			else:
				var mirror_c: int = row_cols - 1 - c
				mask.append(left_half[mirror_c])
	return mask


## Creates a checkerboard / mesh pattern mask.
static func _mask_checkerboard(rows: int, cols: int, wall: bool, invert: bool = false) -> Array[int]:
	var mask: Array[int] = []
	var offset: int = 1 if invert else 0
	for r in range(rows):
		var row_cols: int = cols - ((r & 1) if wall else 0)
		for c in range(row_cols):
			mask.append(1 if ((r + c + offset) % 2 == 0) else 0)
	return mask


## Creates a striped mask (horizontal if vertical is false, vertical columns if true).
static func _mask_stripes(rows: int, cols: int, wall: bool, vertical: bool = false, step: int = 2) -> Array[int]:
	var mask: Array[int] = []
	for r in range(rows):
		var row_cols: int = cols - ((r & 1) if wall else 0)
		for c in range(row_cols):
			var active: bool = (c % step == 0) if vertical else (r % step == 0)
			mask.append(1 if active else 0)
	return mask


## Creates a pyramid / triangle mask (regular apex at top, or inverted if inverted is true).
static func _mask_pyramid(rows: int, cols: int, wall: bool, inverted: bool = false) -> Array[int]:
	var mask: Array[int] = []
	for r in range(rows):
		var row_cols: int = cols - ((r & 1) if wall else 0)
		var row_idx: int = (rows - 1 - r) if inverted else r
		var indent: int = int((float(rows - 1 - row_idx) / float(max(1, rows - 1))) * (float(row_cols) / 2.0))
		for c in range(row_cols):
			var inside: bool = (c >= indent) and (c < (row_cols - indent))
			mask.append(1 if inside else 0)
	return mask


## Creates a border / perimeter frame mask.
static func _mask_border(rows: int, cols: int, wall: bool) -> Array[int]:
	var mask: Array[int] = []
	for r in range(rows):
		var row_cols: int = cols - ((r & 1) if wall else 0)
		for c in range(row_cols):
			var is_edge: bool = (r == 0) or (r == rows - 1) or (c == 0) or (c == row_cols - 1)
			mask.append(1 if is_edge else 0)
	return mask


## Inverts a mask (0 becomes 1, 1 becomes 0).
static func _mask_invert(mask: Array[int]) -> Array[int]:
	var inverted: Array[int] = []
	inverted.resize(mask.size())
	for i in range(mask.size()):
		inverted[i] = 0 if mask[i] != 0 else 1
	return inverted


## Combines two masks with logical AND (both must be active).
static func _mask_and(mask_a: Array[int], mask_b: Array[int]) -> Array[int]:
	var result: Array[int] = []
	var count: int = mini(mask_a.size(), mask_b.size())
	result.resize(count)
	for i in range(count):
		result[i] = 1 if (mask_a[i] != 0 and mask_b[i] != 0) else 0
	return result


## Combines two masks with logical OR (either can be active).
static func _mask_or(mask_a: Array[int], mask_b: Array[int]) -> Array[int]:
	var result: Array[int] = []
	var count: int = mini(mask_a.size(), mask_b.size())
	result.resize(count)
	for i in range(count):
		result[i] = 1 if (mask_a[i] != 0 or mask_b[i] != 0) else 0
	return result

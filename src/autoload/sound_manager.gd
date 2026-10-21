extends Node

## Allowed volume range (settings sliders use this range).
const VOLUME_MIN: float = 0.0   ## Silent.
const VOLUME_MAX: float = 10.0  ## Full volume (0 dB, never boosted).
const SILENT_DB: float = -80.0

const BUS_MUSIC: StringName = &"Music"
const BUS_SOUND: StringName = &"Sound"
const BUS_SFX: StringName = &"SFX"

const SOUND_POOL_SIZE: int = 4
const SFX_POOL_SIZE: int = 8

var music_player: AudioStreamPlayer ## Plays background music.

var _sound_pool: Array[AudioStreamPlayer] = [] ## Plays ui sounds.
var _sfx_pool: Array[AudioStreamPlayer] = []   ## Plays in-game sfx.
var _music_stream: AudioStream                 ## Last playing music stream.
var _levels: Dictionary = {
	BUS_MUSIC: VOLUME_MAX,
	BUS_SOUND: VOLUME_MAX,
	BUS_SFX: VOLUME_MAX,
}


func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS # keep playing while the tree is paused

	for bus in _levels.keys():
		_ensure_bus(bus)

	music_player = _make_player(BUS_MUSIC, "MusicPlayer")
	music_player.finished.connect(_on_music_finished)

	for i in SOUND_POOL_SIZE:
		_sound_pool.append(_make_player(BUS_SOUND, "SoundPlayer%d" % i))
	for i in SFX_POOL_SIZE:
		_sfx_pool.append(_make_player(BUS_SFX, "SfxPlayer%d" % i))

	for bus in _levels.keys():
		_set_bus_level(bus, _levels[bus])


## Plays background music (looping). Does nothing if it is already playing.
func play_music(stream: AudioStream, restart: bool = false) -> void:
	if stream == null:
		push_warning("SoundManager.play_music: stream is null")
		return
	if stream == _music_stream and music_player.playing and not restart:
		return

	_enable_loop(stream)
	_music_stream = stream
	music_player.stream = stream
	music_player.play()


func stop_music() -> void:
	_music_stream = null
	music_player.stop()


## Plays ui related sounds (buttons, menus).
func play_sound(stream: AudioStream) -> void:
	_play_pooled(_sound_pool, stream)


## Plays in-game sfx. pitch_variation (e.g. 0.05) randomises pitch slightly
## so repeated hits don't sound identical.
func play_sfx(stream: AudioStream, pitch_variation: float = 0.0) -> void:
	_play_pooled(_sfx_pool, stream, pitch_variation)


func set_music_volume(level: float) -> void:
	_set_bus_level(BUS_MUSIC, level)

func set_sound_volume(level: float) -> void:
	_set_bus_level(BUS_SOUND, level)

func set_sfx_volume(level: float) -> void:
	_set_bus_level(BUS_SFX, level)

func get_music_volume() -> float:
	return _levels[BUS_MUSIC]

func get_sound_volume() -> float:
	return _levels[BUS_SOUND]

func get_sfx_volume() -> float:
	return _levels[BUS_SFX]


## Clamps to the allowed range, stores it, and applies it to the bus.
func _set_bus_level(bus: StringName, level: float) -> void:
	level = clampf(level, VOLUME_MIN, VOLUME_MAX)
	_levels[bus] = level

	var idx: int = AudioServer.get_bus_index(bus)
	AudioServer.set_bus_volume_db(idx, _level_to_db(level))
	AudioServer.set_bus_mute(idx, level <= VOLUME_MIN)


## Maps the slider range to dB: VOLUME_MIN -> silent, VOLUME_MAX -> 0 dB.
func _level_to_db(level: float) -> float:
	var normalized: float = (level - VOLUME_MIN) / (VOLUME_MAX - VOLUME_MIN)
	return SILENT_DB if normalized <= 0.0 else linear_to_db(normalized)


func _make_player(bus: StringName, player_name: String) -> AudioStreamPlayer:
	var player := AudioStreamPlayer.new()
	player.name = player_name
	player.bus = bus
	add_child(player)
	return player


## Creates the bus at runtime if it is missing from the project's bus layout.
func _ensure_bus(bus: StringName) -> void:
	if AudioServer.get_bus_index(bus) != -1:
		return
	AudioServer.add_bus()
	var idx: int = AudioServer.bus_count - 1
	AudioServer.set_bus_name(idx, bus)
	AudioServer.set_bus_send(idx, &"Master")


func _play_pooled(pool: Array[AudioStreamPlayer], stream: AudioStream, pitch_variation: float = 0.0) -> void:
	if stream == null:
		push_warning("SoundManager: stream is null")
		return

	var player: AudioStreamPlayer = _pick_player(pool)
	player.stream = stream
	player.pitch_scale = 1.0 + randf_range(-pitch_variation, pitch_variation)
	player.play()


## Returns an idle player, or steals the one that has been playing longest.
func _pick_player(pool: Array[AudioStreamPlayer]) -> AudioStreamPlayer:
	var oldest: AudioStreamPlayer = pool[0]
	for player in pool:
		if not player.playing:
			return player
		if player.get_playback_position() > oldest.get_playback_position():
			oldest = player
	return oldest


## Uses the stream's own loop flag when it has one (no gap at the loop point).
func _enable_loop(stream: AudioStream) -> void:
	if "loop" in stream:
		stream.loop = true


## Fallback for streams without a loop flag (e.g. WAV).
func _on_music_finished() -> void:
	if _music_stream != null:
		music_player.play()

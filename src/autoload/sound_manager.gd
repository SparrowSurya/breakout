extends Node

## Allowed volume range (settings sliders use this range).
const VOLUME_MIN: float = 0.0   ## Silent.
const VOLUME_MAX: float = 10.0  ## Full volume (0 dB, never boosted).
const SILENT_DB: float = -80.0

const DEFAULT_MUSIC_VOLUME: float = 1.0
const DEFAULT_SOUND_VOLUME: float = 3.0
const DEFAULT_SFX_VOLUME: float = 3.0

const MUSIC_FADE_IN_SEC: float = 3

const BUS_MUSIC: StringName = &"Music"
const BUS_SOUND: StringName = &"Sound"
const BUS_SFX: StringName = &"SFX"

var music_player: AudioStreamPlayer ## Plays background music.
var sound_player: AudioStreamPlayer ## Plays ui sounds.
var sfx_player: AudioStreamPlayer   ## Plays in-game sfx.

var _music_tween: Tween
var _music_stream: AudioStream      ## Last playing music stream.
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
	sound_player = _make_player(BUS_SOUND, "SoundPlayer")
	sfx_player = _make_player(BUS_SFX, "SfxPlayer")
	music_player.finished.connect(_on_music_finished)

	for bus in _levels.keys():
		_set_bus_level(bus, _levels[bus])
	
	set_music_volume(DEFAULT_MUSIC_VOLUME)
	set_sound_volume(DEFAULT_SOUND_VOLUME)
	set_sfx_volume(DEFAULT_SFX_VOLUME)


## Plays background music (looping). Does nothing if it is already playing.
## fade_in is in seconds; pass 0.0 to start at full volume immediately.
func play_music(stream: AudioStream, restart: bool = false, fade_in: float = MUSIC_FADE_IN_SEC) -> void:
	if stream == null:
		push_warning("SoundManager.play_music: stream is null")
		return
	if stream == _music_stream and music_player.playing and not restart:
		return

	_enable_loop(stream)
	_music_stream = stream
	_kill_music_tween()

	music_player.stream = stream
	music_player.volume_db = SILENT_DB if fade_in > 0.0 else 0.0
	music_player.play()

	if fade_in > 0.0:
		_music_tween = create_tween()
		_music_tween.tween_method(_set_music_fade, 0.0, 1.0, fade_in)


func stop_music() -> void:
	_music_stream = null
	_kill_music_tween()
	music_player.stop()
	music_player.volume_db = 0.0


## Applies a 0..1 fade amount to the music player (not the bus).
func _set_music_fade(amount: float) -> void:
	music_player.volume_db = linear_to_db(amount) if amount > 0.0 else SILENT_DB


func _kill_music_tween() -> void:
	if _music_tween and _music_tween.is_valid():
		_music_tween.kill()


## Plays ui related sounds (buttons, menus).
func play_sound(stream: AudioStream) -> AudioStreamPlayer:
	_play(sound_player, stream)
	return sound_player


## Plays in-game sfx. pitch_variation (e.g. 0.05) randomises pitch slightly.
func play_sfx(stream: AudioStream, pitch_variation: float = 0.0) -> AudioStreamPlayer:
	_play(sfx_player, stream, pitch_variation)
	return sfx_player


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


func _play(player: AudioStreamPlayer, stream: AudioStream, pitch_variation: float = 0.0) -> void:
	if stream == null:
		push_warning("SoundManager: stream is null")
		return

	player.stream = stream
	player.pitch_scale = 1.0 + randf_range(-pitch_variation, pitch_variation)
	player.play()


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


## Uses the stream's own loop flag when it has one (no gap at the loop point).
func _enable_loop(stream: AudioStream) -> void:
	if "loop" in stream:
		stream.loop = true
	elif "loop_mode" in stream:
		stream.loop_mode = AudioStreamWAV.LOOP_FORWARD


## Fallback for streams without a loop flag (e.g. WAV).
func _on_music_finished() -> void:
	if _music_stream != null:
		music_player.play()

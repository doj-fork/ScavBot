extends Node

const GAME_BGM_TRACKS: Array[String] = [
	"res://Assets/SFX/BGMNew/ScavBot - Warzone.mp3",
]
const INTERMISSION_TRACK: String = "res://Assets/SFX/BGMNew/ScavBot - Stalemate.mp3"
const TARGET_DB: float = -30.0
const FADE_IN_DURATION: float = 1.5
const FADE_OUT_DURATION: float = 0.8

var _player: AudioStreamPlayer = null
var _tween: Tween = null

func _ready() -> void:
	if AudioServer.get_bus_index("Music") == -1:
		AudioServer.add_bus()
		var music_idx: int = AudioServer.get_bus_count() - 1
		AudioServer.set_bus_name(music_idx, "Music")
		AudioServer.set_bus_send(music_idx, "Master")
	if AudioServer.get_bus_index("SFX") == -1:
		AudioServer.add_bus()
		var sfx_idx: int = AudioServer.get_bus_count() - 1
		AudioServer.set_bus_name(sfx_idx, "SFX")
		AudioServer.set_bus_send(sfx_idx, "Master")
	_apply_bus_volumes()
	_player = AudioStreamPlayer.new()
	_player.bus = "Music"
	_player.volume_db = -80.0
	add_child(_player)
	_player.finished.connect(_on_track_finished)

func _apply_bus_volumes() -> void:
	var music_idx: int = AudioServer.get_bus_index("Music")
	if music_idx != -1:
		if Stats.music_volume == 0:
			AudioServer.set_bus_mute(music_idx, true)
		else:
			AudioServer.set_bus_mute(music_idx, false)
			AudioServer.set_bus_volume_db(music_idx, linear_to_db(float(Stats.music_volume) / 5.0))
	var sfx_idx: int = AudioServer.get_bus_index("SFX")
	if sfx_idx != -1:
		if Stats.sfx_volume == 0:
			AudioServer.set_bus_mute(sfx_idx, true)
		else:
			AudioServer.set_bus_mute(sfx_idx, false)
			AudioServer.set_bus_volume_db(sfx_idx, linear_to_db(float(Stats.sfx_volume) / 5.0))

func play_game_bgm() -> void:
	_fade_in(_pick_random_game_track())

func play_intermission_bgm() -> void:
	_fade_in(INTERMISSION_TRACK)

func fade_out() -> void:
	if _tween:
		_tween.kill()
	if not _player.playing:
		return
	_tween = create_tween()
	_tween.tween_property(_player, "volume_db", -80.0, FADE_OUT_DURATION)
	await _tween.finished
	_player.stop()

func stop_immediate() -> void:
	if _tween:
		_tween.kill()
		_tween = null
	_player.stop()
	_player.volume_db = -80.0

func _fade_in(track_path: String) -> void:
	if _tween:
		_tween.kill()
	var stream := load(track_path) as AudioStreamMP3
	if stream != null:
		stream.loop = true
	_player.stream = stream
	_player.volume_db = -80.0
	_player.play()
	_tween = create_tween()
	_tween.tween_property(_player, "volume_db", TARGET_DB, FADE_IN_DURATION)

func _pick_random_game_track() -> String:
	return GAME_BGM_TRACKS[randi() % GAME_BGM_TRACKS.size()]

func _on_track_finished() -> void:
	pass

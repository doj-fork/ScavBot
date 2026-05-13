extends Node

const GAME_BGM_TRACKS: Array[String] = [
	"res://Assets/SFX/BGM/Ancient Rite.mp3",
	"res://Assets/SFX/BGM/Brain Dance.mp3",
	"res://Assets/SFX/BGM/Clash Defiant.mp3",
	"res://Assets/SFX/BGM/Curse of the Scarab.mp3",
	"res://Assets/SFX/BGM/Lord of the Rangs.mp3",
	"res://Assets/SFX/BGM/Obliteration.mp3",
	"res://Assets/SFX/BGM/Oppressive Gloom.mp3",
]
const INTERMISSION_TRACK: String = "res://Assets/SFX/BGM/Vibing Over Venus.mp3"
const TARGET_DB: float = -30.0
const FADE_IN_DURATION: float = 1.5
const FADE_OUT_DURATION: float = 0.8

var _player: AudioStreamPlayer = null
var _tween: Tween = null

func _ready() -> void:
	_player = AudioStreamPlayer.new()
	_player.volume_db = -80.0
	add_child(_player)
	_player.finished.connect(_on_track_finished)

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

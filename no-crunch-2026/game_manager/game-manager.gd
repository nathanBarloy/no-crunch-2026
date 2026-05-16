extends Node

var current_scene: Node = null
var current_level_number: int = 0

var song_paths: Array[String] = [
	"res://game_manager/Moleom-main-title.ogg",
	"res://game_manager/moleom-ambiant-song-1.ogg",
	"res://game_manager/moleom-ambiant-track-2_1.ogg",
]
var id_song: int = 1; # start at the first ambiant song
var music_player_started: bool = false;

@onready var music_player: AudioStreamPlayer = AudioStreamPlayer.new()
@onready var mole_sound_player: AudioStreamPlayer = AudioStreamPlayer.new()

func _ready():
	add_child(music_player)
	add_child(mole_sound_player)
	music_player.finished.connect(_on_music_finished)

func _load_song(song_path):
	music_player_started = true;
	music_player.stream = load(song_path)
	music_player.play()

func _on_music_finished():
	# Load and play the next song
	id_song = (id_song + 1) % song_paths.size();
	var song_path = song_paths[id_song];
	_load_song(song_path)

# volume between 0.0 and 1.0
func set_volume(volume: float):
	music_player.volume_db = linear_to_db(volume)  # volume entre 0.0 et 1.0

func unload_scene():
	if current_scene:
		current_scene.queue_free()
		current_scene = null

func level_exists(lvl_number: int) -> bool:
	return ResourceLoader.exists("res://levels/%d/level.tscn" % lvl_number)

func load_level(lvl_number: int):
	unload_scene()
	var scene = load("res://levels/%d/level.tscn" % lvl_number).instantiate()
	current_scene = scene
	current_level_number = lvl_number
	get_tree().root.add_child(scene)
	
	if not music_player_started:
		music_player_started = true;
		_load_song(song_paths[id_song])
		
		# trigger mole sound
		mole_sound_player.stream = load("res://game_manager/mole.mp3")
		mole_sound_player.play()

func load_next_level():
	if level_exists(current_level_number+1):
		load_level(current_level_number+1)
	else:
		load_end_scene()

func load_end_scene():
	unload_scene()
	var scene = load("res://title_screen/end_screen.tscn").instantiate()
	current_scene = scene
	get_tree().root.add_child(scene)
	# disconnect the signal
	music_player.finished.disconnect(_on_music_finished)
	_load_song("res://game_manager/Moleom-main-title.ogg")
	

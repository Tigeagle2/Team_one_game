extends Node
var song_amount = 1

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	_play_song_1()


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
func _play_song_1():
	var p = AudioStreamPlayer.new()
	add_child(p)
	p.stream = load("res://Assets/Sounds/Cereal Killers (Full Rough Mix) 2.16.26.wav")
	p.play()
	p.finished.connect(func():
		_song_finished(1)
		p.queue_free()
		)
func _song_finished(song_num: int):
	var song_roll = randi_range(1, song_amount)
	if song_amount != 1:
		while song_roll == song_num:
			song_roll = randi_range(1, song_amount)
	match song_roll:
		1: 
			_play_song_1()
		_:
			pass
	

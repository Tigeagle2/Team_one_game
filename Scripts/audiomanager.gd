extends Node


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
func _play_song_1():
	var p = AudioStreamPlayer.new()
	add_child(p)
	p.stream = load("res://Assets/Sounds/Cereal Killers (Full Rough Mix) 2.16.26.wav")
	p.play()
	p.finished.connect(p.queue_free)

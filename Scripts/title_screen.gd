extends Node2D


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	pass


func _on_start_button_pressed() -> void:
	get_tree().change_scene_to_file("res://scenes/main_scene.tscn")


func _on_start_button_mouse_entered() -> void:
	$UIRoot/Control/StartButton.scale = Vector2(1.05, 1.05)



func _on_start_button_mouse_exited() -> void:
	$UIRoot/Control/StartButton.scale = Vector2(1, 1)

extends Button

func _pressed():
	get_tree().change_scene_to_file("res://scenes/main_scene.tscn")
	
func _ready():
	mouse_entered.connect(func(): scale = Vector2(1.05, 1.05))
	mouse_exited.connect(func(): scale = Vector2(1, 1))

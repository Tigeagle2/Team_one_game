extends CanvasLayer
signal weapon_selected(weapon_name)

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass


func _on_weapon_button_1_pressed() -> void:
	weapon_selected.emit("choc_steak")
	_clear_weapon_selection()

func _on_weapon_button_2_pressed() -> void:
	weapon_selected.emit("spoon_bowl")
	_clear_weapon_selection()

func _on_weapon_button_3_pressed() -> void:
	weapon_selected.emit("holy_milk")
	_clear_weapon_selection()

func _clear_weapon_selection():
	$weapon_select_panel.visible = false

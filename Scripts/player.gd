extends CharacterBody2D


const SPEED = 300.0
const JUMP_VELOCITY = -400.0
var coyote_time: float = 0.15  
var jump_buffer_time: float = 0.15 
var coyote_timer: float = 0.0
var jump_buffer_timer: float = 0.0
var weapons_library = {
	"choc_steak" : preload("res://Scenes/Weapons/dark_choc_steak.tscn")
}
@onready var weapon_slot = $weapon_slot
@onready var ui = $main_ui
var current_weapon
func _ready() -> void:
	ui.weapon_selected.connect(equip_weapon)
func _physics_process(delta: float) -> void:
	if is_on_floor():
		coyote_timer = coyote_time 
	else:
		coyote_timer -= delta 

	jump_buffer_timer -= delta
	if Input.is_action_just_pressed("ui_accept"):
		jump_buffer_timer = jump_buffer_time

	if not is_on_floor():
		velocity += get_gravity() * delta
	if jump_buffer_timer > 0 and coyote_timer > 0:
		velocity.y = JUMP_VELOCITY
		jump_buffer_timer = 0 
		coyote_timer = 0    

	var input_direction = Input.get_axis("key_a", "key_d")	
	if input_direction:
		velocity.x = input_direction * SPEED
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED)

	move_and_slide()
func equip_weapon(weapon_name: String):
	if not weapons_library.has(weapon_name):
		print("weapon could not be found")
		return
	for child in weapon_slot.get_children():
		child.queue_free()
	var weapon_scene = weapons_library[weapon_name]
	var new_weapon = weapon_scene.instantiate()
	weapon_slot.add_child(new_weapon)
	current_weapon = $weapon_slot.get_child(0)
func _input(event: InputEvent) -> void:
	if event.is_action_pressed("attack"):
		if current_weapon.has_method("_attack"):
			current_weapon._attack()

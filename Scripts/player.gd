extends CharacterBody2D


const SPEED = 900.0
const JUMP_VELOCITY = -1000.0
var coyote_time: float = 0.15  
var jump_buffer_time: float = 0.15 
var coyote_timer: float = 0.0
var jump_buffer_timer: float = 0.0
var dash_cooldown = 2.0
var dash_time = 0.1
var dash_power = 50.0

var dash_ready: bool = true
var dashing: bool = false
var player_direction = 1
var weapons_library = {
	"choc_steak" : preload("res://Scenes/Weapons/dark_choc_steak.tscn"),
	"spoon_bowl" : preload("res://Scenes/Weapons/silver_spoon_and_bowl.tscn"),
	"holy_milk" : preload("res://Scenes/Weapons/holy_milk.tscn")
	}
@onready var weapon_slot = $weapon_slot
@onready var ui = $main_ui
var current_weapon
func _ready() -> void:
	ui.weapon_selected.connect(_equip_weapon)
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
		$AnimationPlayer.play("Walk")
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED)
	if input_direction != 0 and not dashing:
		player_direction = sign(input_direction)	
		$Sprite2D.flip_h = (player_direction == -1)
		$weapon_slot.scale.x = player_direction
		#print(player_direction)
	if dashing:
		velocity.x = player_direction * dash_power * 100
		#print(player_direction * delta * dash_power)

	move_and_slide()
func _equip_weapon(weapon_name: String):
	if not weapons_library.has(weapon_name):
		print("Weapon not found!")
		return
	for child in weapon_slot.get_children():
		child.queue_free()
	var weapon_scene = weapons_library[weapon_name]
	var new_instance = weapon_scene.instantiate()
	weapon_slot.add_child(new_instance)
	current_weapon = new_instance 
	print("Successfully equipped: ", weapon_name)
func _input(event: InputEvent) -> void:
	if event.is_action_pressed("attack"):
		if is_instance_valid(current_weapon):
			if current_weapon.has_method("_attack"):
				current_weapon._attack()
			else:
				print("no attack method")
		else:
			print(" invalid instance")
	elif event.is_action_pressed("dash") && dash_ready == true: 
		print("dash")
		dash_ready = false
		dashing = true
		await get_tree().create_timer(dash_time).timeout
		dashing = false
		await get_tree().create_timer(dash_cooldown).timeout
		dash_ready = true

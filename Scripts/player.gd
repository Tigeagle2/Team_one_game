extends CharacterBody2D


const SPEED = 300.0
const JUMP_VELOCITY = -400.0
var coyote_time: float = 0.15  
var jump_buffer_time: float = 0.15 
var coyote_timer: float = 0.0
var jump_buffer_timer: float = 0.0


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

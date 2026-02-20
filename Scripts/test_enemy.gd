extends CharacterBody2D

@export var speed = 150.0
@export var jump_velocity = -400.0
@onready var player = get_tree().get_first_node_in_group("player") # Make sure Player is in "player" group

var current_path: PackedVector2Array = []
var target_index: int = 0
var gravity = ProjectSettings.get_setting("physics/2d/default_gravity")

func _physics_process(delta):
	# Apply Gravity
	if not is_on_floor():
		velocity.y += gravity * delta

	if target_index < current_path.size():
		var target_pos = current_path[target_index]
		var diff = target_pos.x - global_position.x

		# Horizontal Movement
		if abs(diff) > 4:
			velocity.x = sign(diff) * speed
		else:
			# We are horizontally aligned with the point, move to next
			target_index += 1
			
		# Jump Logic: If the next point is high up and we are on the floor
		if is_on_floor() and target_pos.y < global_position.y - 15:
			velocity.y = jump_velocity
	else:
		velocity.x = move_toward(velocity.x, 0, speed)

	move_and_slide()

# This runs every time the Timer hits zero
func _on_timer_timeout():
	if player:
		current_path = navigationmanager.get_path_to_target(global_position, player.global_position)
		target_index = 0

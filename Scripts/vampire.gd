extends CharacterBody2D

@export var speed = 400.0 # Slightly lower speed often helps path following
@export var jump_velocity = -800.0
@onready var player = get_tree().get_first_node_in_group("player")

var current_path: PackedVector2Array = []
var target_index: int = 0
var gravity = ProjectSettings.get_setting("physics/2d/default_gravity")

func _physics_process(delta):
	# 1. Gravity
	if not is_on_floor():
		velocity.y += gravity * delta

	# 2. Pathfollowing Logic
	if target_index < current_path.size():
		var target_pos = current_path[target_index]
		var dist_to_target = global_position.distance_to(target_pos)
		
		# --- THE FIX: ARIVE AND ADVANCE ---
		# If we are close enough to the point, just move to the next one immediately
		# so we don't 'pause' at every tile.
		if dist_to_target < 30: 
			target_index += 1
			return # Skip the rest of this frame to prevent jitter

		# 3. DIRECTIONAL MOVEMENT
		var dir_x = sign(target_pos.x - global_position.x)
		
		# Instead of precision alignment, keep moving if the point is further away
		if abs(target_pos.x - global_position.x) > 10:
			velocity.x = move_toward(velocity.x, dir_x * speed, speed * 0.2)
		else:
			# We are horizontally aligned, don't stop entirely, 
			# just reduce speed to stay on the point's X axis
			velocity.x = move_toward(velocity.x, 0, speed * 0.1)

		# 4. JUMP LOGIC
		if is_on_floor():
			# Jump if: Target is high OR we are blocked by a wall
			if target_pos.y < global_position.y - 20 or is_on_wall():
				velocity.y = jump_velocity
	else:
		# Reached the very end of the path (the Player's location)
		# Check distance to player directly here to keep moving if player moves
		velocity.x = move_toward(velocity.x, 0, speed * 0.2)

	move_and_slide()

func _on_timer_timeout():
	if player:
		# Use your navigation manager
		var path = navigationmanager.get_path_to_target(global_position, player.global_position)
		if path.size() > 1:
			current_path = path
			target_index = 1 # Skip current position

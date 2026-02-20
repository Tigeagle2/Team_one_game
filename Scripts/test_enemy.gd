extends CharacterBody2D

@export var speed = 500.0
@export var jump_velocity = -1000.0
@onready var player = get_tree().get_first_node_in_group("player")

var current_path: PackedVector2Array = []
var target_index: int = 0
var gravity = ProjectSettings.get_setting("physics/2d/default_gravity")

func _physics_process(delta):
	# 1. Apply Gravity
	if not is_on_floor():
		velocity.y += gravity * delta

	# 2. Pathfollowing Logic
	if target_index < current_path.size():
		var target_pos = current_path[target_index]
		
		# Check distance to the target point
		# Use a larger margin (e.g., 20 pixels) so the enemy doesn't have to be pixel-perfect
		if global_position.distance_to(target_pos) < 25:
			target_index += 1
		else:
			# Horizontal Movement
			var direction = sign(target_pos.x - global_position.x)
			if abs(target_pos.x - global_position.x) > 5:
				velocity.x = direction * speed
			else:
				# Precision alignment when close to the X of the point
				velocity.x = move_toward(velocity.x, 0, speed)

			# 3. Jump Logic (Better detection)
			# Jump if target is higher AND we are either stuck or need to go up
			if is_on_floor():
				if target_pos.y < global_position.y - 20:
					velocity.y = jump_velocity
	else:
		# No path or reached the end
		velocity.x = move_toward(velocity.x, 0, speed)

	move_and_slide()

func _on_timer_timeout():
	if player:
		var path = navigationmanager.get_path_to_target(global_position, player.global_position)
		if path.size() > 0:
			current_path = path
			# Start at index 1 to skip the point the enemy is already standing on
			target_index = 1

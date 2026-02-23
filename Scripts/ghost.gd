extends Area2D

@export var speed = 400.0
@export var wave_amplitude = 75.0
@export var wave_frequency = 3.0

var time_passed = 0.0

func _physics_process(delta):
	var player = get_tree().get_first_node_in_group("player")
	
	if player:
		# 1. Use physics delta for the timer to stay in sync
		time_passed += delta
		
		# 2. Get the core direction
		var direction = global_position.direction_to(player.global_position)
		
		# 3. Get the perpendicular (90 degree) vector for the wiggle
		var side_direction = Vector2(-direction.y, direction.x)
		
		# 4. Calculate the TWO parts of movement:
		# Forward movement toward the player
		var forward_move = direction * speed * delta
		
		# Side movement based on the CHANGE in the sine wave (the derivative)
		# We use cos() here because it represents the velocity of the sin wave
		var wave_vel = cos(time_passed * wave_frequency) * wave_amplitude * wave_frequency
		var side_move = side_direction * wave_vel * delta
		
		# 5. Apply both
		global_position += forward_move + side_move

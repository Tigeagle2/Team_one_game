extends CharacterBody2D
const base_speed = 450
var speed
var health = 100.0
var jump_velocity = -900.0
var jump_cooldown: float = 0.0
var gravity_multiplier = 0.9
@onready var player = get_tree().get_first_node_in_group("player")

var current_path: PackedVector2Array = []
var target_index: int = 0
var gravity = ProjectSettings.get_setting("physics/2d/default_gravity")
var locked_dir_x: float = 0.0
var needs_path_update: bool = false
var waiting_for_landing: bool = false 
var knockback_timer: float = 0.0
var slow_time
func _ready() -> void:
	speed = base_speed
func _process(delta: float) -> void:
	if speed < base_speed:
		if slow_time > 0:
			slow_time -= delta
		elif slow_time <= 0:
			speed += delta * 100
	if speed > base_speed:
		speed = base_speed
	print(speed)
func _physics_process(delta):
	# 0. Cooldown Timer
	if jump_cooldown > 0:
		jump_cooldown -= delta

	# 1. Gravity 
	if not is_on_floor():
		velocity.y += gravity * delta

	if knockback_timer > 0:
		knockback_timer -= delta
		velocity.x = move_toward(velocity.x, 0, speed * delta * 3.0)
		move_and_slide()
		return

	# 2. Landing Logic
	if is_on_floor():
		locked_dir_x = 0.0
		if waiting_for_landing:
			waiting_for_landing = false
			needs_path_update = true
			
		if needs_path_update:
			update_path()

	# 3. Midair Stop Logic (Falling straight down)
	if waiting_for_landing:
		velocity.x = move_toward(velocity.x, 0, speed * 0.1)
		move_and_slide()
		return

	# 4. Pathfollowing Logic
	if target_index < current_path.size():
		var target_pos = current_path[target_index]
		
		var dist_x = abs(target_pos.x - global_position.x)
		var dist_y = abs(target_pos.y - global_position.y)

		var arrived_normally = dist_x < 15 and dist_y < 30
		var flying_over_target = dist_x < 15 and global_position.y < target_pos.y and not is_on_floor()

		if arrived_normally or flying_over_target:
			target_index += 1
			
			if not is_on_floor():
				waiting_for_landing = true
				locked_dir_x = 0.0
				velocity.x = 0
			return

		var dir_x = sign(target_pos.x - global_position.x)
		
		if is_on_floor():
			var target_is_below = target_pos.y > global_position.y + 10
			
			if dist_x > 15:
				velocity.x = move_toward(velocity.x, dir_x * speed, speed * 0.2)
			elif target_is_below:
				var slide_dir = sign(velocity.x)
				if slide_dir == 0:
					if not _has_floor_ahead(1): slide_dir = 1
					elif not _has_floor_ahead(-1): slide_dir = -1
					else: slide_dir = dir_x
					
				velocity.x = move_toward(velocity.x, slide_dir * speed, speed * 0.2)
			else:
				velocity.x = move_toward(velocity.x, 0, speed * 0.2)
			
			# JUMP LOGIC
			if jump_cooldown <= 0:
				var target_is_above = target_pos.y < global_position.y - 40
				var floor_ahead = _has_floor_ahead(dir_x)
				var at_ledge = not floor_ahead
				
				var jump_for_wall = is_on_wall()
				var jump_for_gap = at_ledge and dist_x > 20
				var jump_straight_up = target_is_above and dist_x < 30
				
				if jump_for_wall or jump_for_gap or jump_straight_up:
					
					if not target_is_above and at_ledge:
						velocity.y = jump_velocity * 0.8
					else:
						velocity.y = jump_velocity
					
					locked_dir_x = dir_x
					jump_cooldown = 0.5
		else:
			# MID-AIR LOGIC
			if locked_dir_x != 0:
				velocity.x = locked_dir_x * speed
	else:
		velocity.x = move_toward(velocity.x, 0, speed * 0.2)

	move_and_slide()

func update_path():
	if player:
		var path = navigationmanager.get_path_to_target(global_position, player.global_position)
		if path.size() > 1:
			current_path = path
			target_index = 1
	needs_path_update = false 

func _on_timer_timeout():
	if is_on_floor():
		update_path()
	else:
		needs_path_update = true

func _has_floor_ahead(dir_x: float) -> bool:
	if dir_x == 0: return true
	
	var space_state = get_world_2d().direct_space_state
	
	# Offset X: Look 30px ahead (adjust based on your sprite width)
	var start_pos = global_position + Vector2(dir_x * 30, 0)
	
	# Offset Y: Look 100px down to find floor. 
	var end_pos = start_pos + Vector2(0, 100) 
	
	var query = PhysicsRayQueryParameters2D.create(start_pos, end_pos)
	query.collision_mask = 1 # Must match your Floor Layer
	
	var result = space_state.intersect_ray(query)
	
	return not result.is_empty()

func _take_damage():
	var weapon_slot = player.get_node("weapon_slot")

	if weapon_slot.get_child_count() > 0:
		var current_weapon = weapon_slot.get_child(0)
		var damage = current_weapon.damage
		
		health -= damage
		_take_knockback()
		if "slow_amount" in current_weapon:
			speed = current_weapon.slow_amount * base_speed
			slow_time = current_weapon.slowdown_duration
func _on_hitbox_area_entered(area: Area2D) -> void:
	if area.is_in_group("weapon") and not player.block_held_down:
		_take_damage()
	elif area.is_in_group("weapon") and player.block_held_down:
		_take_knockback()
func _take_knockback():
	var weapon_slot = player.get_node("weapon_slot")
	if weapon_slot.get_child_count() > 0:
		var current_weapon = weapon_slot.get_child(0)
		var knockback_force_x = 700.0 * current_weapon.knockback_multiplier
		var knockback_force_y = -350.0 
		if current_weapon.has_method("_toggle_block"):
			if current_weapon.blocking:
				knockback_force_x *= current_weapon.blocking_knockback_multiplier
				knockback_force_y *= (current_weapon.blocking_knockback_multiplier)
		var push_dir = sign(global_position.x - player.global_position.x)
		if push_dir == 0: 
			push_dir = 1 
		
		velocity.x = push_dir * knockback_force_x
		velocity.y = knockback_force_y
		knockback_timer = 0.4 
		locked_dir_x = 0.0
		waiting_for_landing = false

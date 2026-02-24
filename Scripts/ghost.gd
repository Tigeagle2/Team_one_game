extends Area2D
const base_speed = 350
var speed 
var wave_amplitude = 75.0
var wave_frequency = 3.0
var time_passed = 0.0
var active: bool = false
var off_screen: bool = true
var invincible: bool = false
var off_screen_active_time = 5.0
var health = 100.0
var slow_time
@onready var player = get_tree().get_first_node_in_group("player")
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
func _physics_process(delta):
	if player and active:
		time_passed += delta
		var direction = global_position.direction_to(player.global_position)
		var side_direction = Vector2(-direction.y, direction.x)
		var forward_move = direction * speed * delta
		var wave_vel = cos(time_passed * wave_frequency) * wave_amplitude * wave_frequency
		var side_move = side_direction * wave_vel * delta
		global_position += forward_move + side_move

func _on_visible_on_screen_notifier_2d_screen_entered() -> void:
	active = true
	off_screen = false

func _on_visible_on_screen_notifier_2d_screen_exited() -> void:
	off_screen = true
	await get_tree().create_timer(off_screen_active_time).timeout
	if off_screen == true:
		active = false;

func _take_damage():
	var weapon_slot = player.get_node("weapon_slot")
	if weapon_slot.get_child_count() > 0:
		var current_weapon = weapon_slot.get_child(0)
		var damage = current_weapon.damage
		health -= damage
		if "slow_amount" in current_weapon:
			speed = current_weapon.slow_amount * base_speed
			slow_time = current_weapon.slowdown_duration
		_start_teleport_sequence()

func _start_teleport_sequence():
	invincible = true
	set_deferred("monitoring", false)
	set_deferred("monitorable", false)
	
	var tween = create_tween()
	#Fade Out
	tween.tween_property($Sprite2D, "modulate:a", 0.0, 0.5)
	#Teleport
	tween.tween_callback(_teleport_to_edge)
	#Fade Back In
	tween.tween_property($Sprite2D, "modulate:a", 1.0, 0.5)
	# Reset everything
	tween.tween_callback(_end_teleport_sequence)

func _end_teleport_sequence():
	invincible = false
	set_deferred("monitoring", true)
	set_deferred("monitorable", true)

func _teleport_to_edge():
	var viewport_rect = get_viewport_rect()
	var camera = get_viewport().get_camera_2d()
	var center = camera.get_screen_center_position() if camera else global_position
	
	var width = viewport_rect.size.x / 1.3
	var height = viewport_rect.size.y / 1.3
	
	var top = center.y - height
	var bottom = center.y + height
	var left = center.x - width
	var right = center.x + width
	
	var side = randi() % 4
	match side:
		0: global_position = Vector2(randf_range(left, right), top)
		1: global_position = Vector2(randf_range(left, right), bottom)
		2: global_position = Vector2(left, randf_range(top, bottom))
		3: global_position = Vector2(right, randf_range(top, bottom))

func _on_area_entered(area: Area2D) -> void:
	if area.is_in_group("weapon") and not invincible:
		_take_damage()

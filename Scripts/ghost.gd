extends Area2D

var speed = 200.0
var wave_amplitude = 75.0
var wave_frequency = 3.0
var time_passed = 0.0
var active: bool = false
var off_screen: bool = true
var off_screen_active_time = 5.0
func _physics_process(delta):
	var player = get_tree().get_first_node_in_group("player")
	
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

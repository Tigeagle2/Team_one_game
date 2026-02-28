extends Area2D
var damage = 35.0
var knockback_multiplier = 1.0
var blocking_knockback_multiplier = 1.75
var can_attack: bool = true
var blocking: bool = false
var attack_duration = 0.2
var attack_cooldown = 0.5
var block_timer 
var block_timer_max = 1
var block_cooldown
var block_cooldown_max = 2
@onready var player = get_tree().get_first_node_in_group("player")
signal block_status(can_block: bool)
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	$hitbox.set_deferred("disabled", true)
	block_timer = block_timer_max
	block_cooldown = block_cooldown_max

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if blocking:
		block_timer -= delta
		if block_timer <= 0:
			_deactivate_block()
	if not blocking && block_timer < block_timer_max && block_cooldown > 0:
		block_cooldown -= delta
	if not blocking && block_cooldown <= 0:
		block_timer = block_timer_max
		block_cooldown = block_cooldown_max
func _attack():
	if can_attack:
		can_attack = false
		$hitbox.set_deferred("disabled", false)
		await get_tree().create_timer(attack_duration).timeout
		Input.start_joy_vibration(0, 0.5, 0.2, attack_duration)
		$hitbox.set_deferred("disabled", true)
		await get_tree().create_timer(attack_cooldown).timeout
		can_attack = true
func _toggle_block(is_pressing: bool):
	if is_pressing && block_timer >= block_timer_max:
		block_status.emit(true)
		_activate_block()
	elif blocking:
		block_status.emit(false)
		_deactivate_block()
	else:
		block_status.emit(false)
func _activate_block():
	blocking = true
	$hitbox.set_deferred("disabled", false)
func _deactivate_block():
	blocking = false
	$hitbox.set_deferred("disabled", true)

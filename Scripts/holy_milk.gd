extends Area2D
var can_attack: bool = true
var attack_duration = 0.1
var attack_cooldown = 1.5
var damage = 20.0
var knockback_multiplier = 0.2
var slow_amount = 0.25
var slowdown_duration = 1.0

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	$hitbox.set_deferred("disabled", true)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
func _attack():
	if can_attack:
		can_attack = false
		$hitbox.set_deferred("disabled", false)
		await get_tree().create_timer(attack_duration).timeout
		Input.start_joy_vibration(0, 0.5, 0.3, attack_duration + 0.3)
		$hitbox.set_deferred("disabled", true)
		await get_tree().create_timer(attack_cooldown).timeout
		can_attack = true

extends Area2D
var can_attack: bool = true
var attack_duration = 0.1
var attack_cooldown = 1.0

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
		$hitbox.set_deferred("disabled", true)
		await get_tree().create_timer(attack_cooldown).timeout
		can_attack = true

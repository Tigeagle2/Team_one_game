extends Node
var gamerunning: bool = false
var health = 100 
var invincible: bool = false
var i_time = 0.5
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	Engine.time_scale = 1


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	pass
func _take_damage(amount: float):
	if not invincible:
		invincible = true
		health -= amount
		await get_tree().create_timer(i_time).timeout
		invincible = false

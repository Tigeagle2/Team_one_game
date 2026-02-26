extends Node

var gamerunning: bool = false
var health = 100 
var invincible: bool = false
var i_time = 0.5
var regen_amount = 2
var regen_cooldown
const regen_cooldown_time = 5
var regen_time_gap = 1
var regen_checking: bool = true
var regen_timer = 0.0
var score = 0
var time_pass = 0.0

func _ready() -> void:
	Engine.time_scale = 1
	regen_cooldown = regen_cooldown_time

func _process(delta: float) -> void:
	time_pass += delta
	if health > 100:
		health = 100

	if health < 100:
		if regen_cooldown > 0:
			regen_cooldown -= delta
			regen_timer = 0.0
		else:
			regen_timer += delta
			if regen_timer >= regen_time_gap:
				health += regen_amount
				regen_timer = 0.0
	if time_pass >= 0.5:
		print(health)
		time_pass = 0
func _take_damage(amount: float):
	if not invincible:
		invincible = true
		regen_cooldown = regen_cooldown_time
		health -= amount
		await get_tree().create_timer(i_time).timeout
		invincible = false

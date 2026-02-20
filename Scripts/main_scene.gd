extends Node2D

@onready var world_tiles = $TileMapLayer
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	navigationmanager.setup_navigation(world_tiles)
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

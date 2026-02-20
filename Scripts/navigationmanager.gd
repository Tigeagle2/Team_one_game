extends Node

var astar = AStar2D.new()
var tilemap: TileMapLayer 

func setup_navigation(map: TileMapLayer):
	tilemap = map
	astar.clear()
	_add_points()
	_connect_points()

func _add_points():
	var used_tiles = tilemap.get_used_cells() 
	for cell in used_tiles:
		# 1. Get the TileData for the current cell
		var tile_data = tilemap.get_cell_tile_data(cell)
		
		# 2. Check if this tile has physics/collision
		# (Checking if the collision polygon count is greater than 0)
		if tile_data and tile_data.get_collision_polygons_count(0) > 0:
			
			# 3. Only add the air point if the tile BELOW it is solid
			var air_cell = cell + Vector2i(0, -1)
			
			# Ensure the air space itself isn't a solid wall
			var air_data = tilemap.get_cell_tile_data(air_cell)
			var air_is_solid = air_data and air_data.get_collision_polygons_count(0) > 0
			
			if not air_is_solid:
				var global_pos = tilemap.to_global(tilemap.map_to_local(air_cell))
				var id = _get_id(air_cell)
				if not astar.has_point(id):
					astar.add_point(id, global_pos)

func _connect_points():
	for id in astar.get_point_ids():
		var pos = astar.get_point_position(id)
		var cell = tilemap.local_to_map(tilemap.to_local(pos))
		
		# 1. Standard Horizontal Neighbors (Walking)
		var horizontal = [cell + Vector2i(1, 0), cell + Vector2i(-1, 0)]
		for n_cell in horizontal:
			_check_and_connect(id, n_cell)
		
		# 2. Jump/Fall Neighbors (Checking 2-3 tiles away)
		# This lets the AI "see" a path from a ledge to the floor
		for x_offset in [-1, 1]:
			for y_offset in [-2, -1, 1, 2, 3]: # Check above and below
				var jump_cell = cell + Vector2i(x_offset, y_offset)
				_check_and_connect(id, jump_cell)

# Helper function to keep code clean
func _check_and_connect(id: int, target_cell: Vector2i):
	var target_id = _get_id(target_cell)
	if astar.has_point(target_id):
		# bidirectional = true allows walking back and forth
		astar.connect_points(id, target_id, true)

func _get_id(cell: Vector2i) -> int:
	# Better hashing to avoid collisions
	return (cell.x * 31) ^ (cell.y * 71)

func get_path_to_target(start_pos: Vector2, end_pos: Vector2) -> PackedVector2Array:
	var start_id = astar.get_closest_point(start_pos)
	var end_id = astar.get_closest_point(end_pos)
	
	if start_id == -1 or end_id == -1:
		return PackedVector2Array() 
		
	return astar.get_point_path(start_id, end_id)

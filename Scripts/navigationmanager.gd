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
	var points = astar.get_point_ids()
	for id in points:
		var pos = astar.get_point_position(id)
		var cell = tilemap.local_to_map(tilemap.to_local(pos))
		
		# We check a window around every point to find other platforms
		# x_range: How far can the enemy leap?
		# y_range: how high can they jump / how far can they fall?
		for x_off in range(-5, 20): 
			for y_off in range(-6, 7):
				if x_off == 0 and y_off == 0: continue
				
				var target_cell = cell + Vector2i(x_off, y_off)
				var target_id = _get_id(target_cell)
				
				if astar.has_point(target_id):
					# Connect the points! 
					# This creates the "bridges" between separate platforms.
					astar.connect_points(id, target_id, true)

func _check_and_connect(id: int, target_cell: Vector2i):
	var target_id = _get_id(target_cell)
	if astar.has_point(target_id):
		# bidirectional = true allows walking back and forth
		astar.connect_points(id, target_id, true)

func _get_id(cell: Vector2i) -> int:
	# Better hashing to avoid collisions
	return abs(hash(cell))

func get_path_to_target(start_pos: Vector2, end_pos: Vector2) -> PackedVector2Array:
	var start_id = astar.get_closest_point(start_pos)
	var end_id = astar.get_closest_point(end_pos)
	
	if start_id == -1 or end_id == -1:
		return PackedVector2Array() 
		
	var path = astar.get_point_path(start_id, end_id)
	
	# FALLBACK: If there's no way to reach the player, 
	# find a point that gets the enemy as close as possible.
	if path.size() == 0:
		# Just return the closest point it CAN reach
		return PackedVector2Array([astar.get_point_position(start_id)])

	return path

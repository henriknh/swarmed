extends Node2D

export(int) var bound_radius = 20
export(int) var bounds_thickness = 3

onready var ground: TileMap = $Ground
onready var level: TileMap = $Level

func _ready():
	# Remove out of bounds
	for pos in level.get_used_cells():
		if pos.x < -bound_radius or pos.x > bound_radius or pos.y < -bound_radius or pos.y > bound_radius:
			level.set_cellv(pos, -1)
	
	# Create bounds wall
	var wall_tall_tile = level.tile_set.find_tile_by_name('wall_tall')
	if wall_tall_tile != -1:
		for i in range(bound_radius + bounds_thickness):
			for j in range(bounds_thickness):
				level.set_cell(i, bound_radius + j, wall_tall_tile)
				level.set_cell(bound_radius + j, i, wall_tall_tile)
				level.set_cell(-i, bound_radius + j, wall_tall_tile)
				level.set_cell(bound_radius + j, -i, wall_tall_tile)
				level.set_cell(i, -bound_radius - j, wall_tall_tile)
				level.set_cell(-bound_radius - j, i, wall_tall_tile)
				level.set_cell(-i, -bound_radius - j, wall_tall_tile)
				level.set_cell(-bound_radius - j, -i, wall_tall_tile)
	else:
		breakpoint
		
	# Place navigation tiles
	var navigation_tile = level.tile_set.find_tile_by_name('navigation')
	var ground_tile = ground.tile_set.find_tile_by_name('ground')
	if navigation_tile != -1 and ground_tile != -1:
		for x in range(-bound_radius, bound_radius):
			for y in range(-bound_radius, bound_radius):
				var cell = level.get_cell(x, y)
				if cell == TileMap.INVALID_CELL:
					level.set_cell(x, y, navigation_tile)
					Spawner.walkable_cells.append(Vector2(x, y) * level.cell_size + level.cell_size / 2)
					
				ground.set_cell(x, y, ground_tile)
		level.tile_set.tile_set_modulate(navigation_tile, Color.transparent)
		
	else:
		breakpoint
	
	level.update_bitmask_region()
	level.update_dirty_quadrants()
	ground.update_bitmask_region()
	ground.update_dirty_quadrants()

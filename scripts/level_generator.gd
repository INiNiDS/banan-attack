extends Node2D

@onready var tile_map: TileMapLayer = $Terrain/TileMapLayer

@onready var player: CharacterBody2D = $"Player 1"

const CHUNK_WIDTH: int = 20   
const TILE_SIZE: int = 16      

const FLOOR_Y: int = 25

const CHUNKS_AHEAD: int = 3
const CHUNKS_BEHIND: int = 2

var loaded_chunks: Dictionary = {}

const TOP_LEFT_TILE = Vector2i(6, 0)
const TOP_TILE = Vector2i(7, 0)
const TOP_RIGHT_TILE = Vector2i(8, 0)

const CENTER_LEFT_TILE = Vector2i(6, 1)
const CENTER_TILE = Vector2i(7, 1)
const CENTER_RIGHT_TILE = Vector2i(8, 1)

const BOTTOM_LEFT_TILE = Vector2i(6, 2)
const BOTTOM_TILE = Vector2i(7, 2)
const BOTTOM_RIGHT_TILE = Vector2i(8, 2)

func _ready() -> void:
	if not player:
		player = get_node_or_null("Player")
	
	update_chunks()

func _process(_delta: float) -> void:
	if player:
		update_chunks()

func update_chunks() -> void:
	var player_tile_x = int(player.position.x / TILE_SIZE)
	var current_chunk = int(floor(float(player_tile_x) / CHUNK_WIDTH))

	for i in range(current_chunk - CHUNKS_BEHIND, current_chunk + CHUNKS_AHEAD + 1):
		if not loaded_chunks.has(i):
			generate_chunk(i)
			loaded_chunks[i] = true

	var chunks_to_remove: Array = []
	for chunk_idx in loaded_chunks.keys():
		if chunk_idx < current_chunk - CHUNKS_BEHIND:
			unload_chunk(chunk_idx)
			chunks_to_remove.append(chunk_idx)

	for chunk_idx in chunks_to_remove:
		loaded_chunks.erase(chunk_idx)

func generate_chunk(chunk_idx: int) -> void:
	var start_x = chunk_idx * CHUNK_WIDTH

	if chunk_idx <= 0:
		build_ground(start_x, CHUNK_WIDTH, FLOOR_Y)
	else:
		if randf() < 0.2:
			var pit_start = start_x + randi_range(3, 6)
			var pit_width = randi_range(2, 4)
			build_ground(start_x, pit_start - start_x, FLOOR_Y)
			var after_pit_x = pit_start + pit_width
			var remaining_width = (start_x + CHUNK_WIDTH) - after_pit_x
			if remaining_width > 0:
				build_ground(after_pit_x, remaining_width, FLOOR_Y)
		else:
			build_ground(start_x, CHUNK_WIDTH, FLOOR_Y)

	var islands_count = randi_range(1, 3)
	for _i in range(islands_count):
		var island_width = randi_range(2, 5) 
		var island_x = start_x + randi_range(0, CHUNK_WIDTH - island_width)
		var island_y = FLOOR_Y - randi_range(3, 10)
		build_floating_island(island_x, island_y, island_width)

func build_ground(start_x: int, width: int, y: int) -> void:
	for i in range(width):
		var cur_x = start_x + i
		var top_tile = TOP_TILE
		var dirt_tile = CENTER_TILE

		if i == 0:
			top_tile = TOP_LEFT_TILE
			dirt_tile = CENTER_LEFT_TILE
		elif i == width - 1:
			top_tile = TOP_RIGHT_TILE
			dirt_tile = CENTER_RIGHT_TILE

		tile_map.set_cell(Vector2i(cur_x, y), 0, top_tile)
		for depth in range(1, 15):
			tile_map.set_cell(Vector2i(cur_x, y + depth), 0, dirt_tile)

func build_floating_island(start_x: int, top_y: int, width: int) -> void:
	for i in range(width):
		var cur_x = start_x + i
		var top_t = TOP_TILE
		var mid_t = CENTER_TILE
		var bot_t = BOTTOM_TILE

		if i == 0:
			top_t = TOP_LEFT_TILE
			mid_t = CENTER_LEFT_TILE
			bot_t = BOTTOM_LEFT_TILE
		elif i == width - 1:
			top_t = TOP_RIGHT_TILE
			mid_t = CENTER_RIGHT_TILE
			bot_t = BOTTOM_RIGHT_TILE

		tile_map.set_cell(Vector2i(cur_x, top_y), 0, top_t)
		tile_map.set_cell(Vector2i(cur_x, top_y + 1), 0, mid_t)
		tile_map.set_cell(Vector2i(cur_x, top_y + 2), 0, bot_t)


func unload_chunk(chunk_idx: int) -> void:
	var start_x = chunk_idx * CHUNK_WIDTH
	for x in range(start_x, start_x + CHUNK_WIDTH):
		for y in range(FLOOR_Y - 15, FLOOR_Y + 10):
			tile_map.set_cell(Vector2i(x, y), -1)

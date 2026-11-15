extends Node2D

@onready var tile_map: TileMapLayer = $Terrain/TileMapLayer

@onready var player: CharacterBody2D = $"Player 1"
var scenes = []
var end = Vector2.ZERO
var current_chunks = []

func _ready() -> void:
	var path = "res://scenes/chunks/"
	for file_name in ResourceLoader.list_directory(path):
		if file_name.ends_with(".tscn"):
			scenes.append(load(path + file_name))


func _process(delta: float) -> void:
	if not player:
		return
	if (end.x - player.global_position.x) < 100 * 16:
		spawn_chunk()
	if not current_chunks.is_empty():
		var oldest = current_chunks[0]
		var oldest_end = oldest.get_node("EndMarker").global_position.x
		if (player.global_position.x - oldest_end) > 100 * 16.0:
			oldest.queue_free()
			current_chunks.pop_front()

func spawn_chunk() -> void:
	var gap_blocks = randi_range(3, 5) # Something like this is good enogh. Do you know what i'm meaning by that? I too.
	var spawn_at = end + Vector2(gap_blocks * 16, 0)
	var scene = scenes.pick_random()
	var scene_node = scene.instantiate()
	scene_node.global_position = spawn_at
	add_child(scene_node)
	current_chunks.append(scene_node)
	end = scene_node.get_node("EndMarker").global_position

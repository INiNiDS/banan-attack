extends Node2D

@onready var player: CharacterBody2D = $"Player 1"
@onready var tiles: TileMapLayer = $TileMapLayer
@onready var http_request: HTTPRequest = $HTTPRequest
var scene_type: int = 1
var chunk_counter: int = 11
var current_chunk: Node2D = null
const FLOOR_Y: int = 35
var chunk_width: int = 27

const MAX_JUMP_Y: int = 6
const MAX_JUMP_X: int = 10

var solid_cells: Dictionary = {}
var safe_air_cells: Dictionary = {}
var path_history: Array[Rect2i] = []
var cursor_rect: Rect2i = Rect2i()
var shaft_left: int = 10
var shaft_right: int = 15

const PEAK_Y: int = -50

const MAIN_SHAPE_WEIGHTS: Dictionary = {
	"box": 78.0, "mega_box": 12.0, "one": 5.0, "h_beam": 3.5, "v_beam": 1.5
}

var true_air_cells: Dictionary = {}
var placed_items: Array = []
var true_nodes: Array = []
var fake_nodes: Array = []
var fork_hints: Array = []
var landmark_fake_seeds: Array = []
var shaft_x: int = 12
var shaft_w: int = 4
var med_air_cells: Dictionary = {} # med = medium
var med_platforms: Array = []
var lar_air_cells: Dictionary = {} # lar = large 0_0
var lar_platforms: Array = []

const TOP_LEFT_TILE = Vector2i(6, 0)
const TOP_TILE = Vector2i(7, 0)
const TOP_RIGHT_TILE = Vector2i(8, 0)

const CENTER_LEFT_TILE = Vector2i(6, 1)
const CENTER_TILE = Vector2i(7, 1)
const CENTER_RIGHT_TILE = Vector2i(8, 1)

const BOTTOM_LEFT_TILE = Vector2i(6, 2)
const BOTTOM_TILE = Vector2i(7, 2)
const BOTTOM_RIGHT_TILE = Vector2i(8, 2)

const CUPRUM_LEFT_H_BEAM = Vector2i(12, 0)
const CUPRUM_CENTER_H_BEAM = Vector2i(13, 0)
const CUPRUM_RIGHT_H_BEAM = Vector2i(14, 0)
const CUPRUM_ONE = Vector2i(12, 1)
const CUPRUM_TOP_LEFT_BLOCK = Vector2i(13, 1)
const CUPRUM_TOP_RIGHT_BLOCK = Vector2i(14, 1)
const CUPRUM_BOTTOM_LEFT_BLOCK = Vector2i(13, 2)
const CUPRUM_BOTTOM_RIGHT_BLOCK = Vector2i(14, 2)
const CUPRUM_TOP_V_BEAM = Vector2i(15, 0)
const CUPRUM_CENTER_V_BEAM = Vector2i(15, 1)
const CUPRUM_BOTTOM_V_BEAM = Vector2i(15, 2)

const FERRUM_LEFT_H_BEAM = Vector2i(12, 4)
const FERRUM_CENTER_H_BEAM = Vector2i(13, 4)
const FERRUM_RIGHT_H_BEAM = Vector2i(14, 4)
const FERRUM_ONE = Vector2i(12, 5)
const FERRUM_TOP_LEFT_BLOCK = Vector2i(13, 5)
const FERRUM_TOP_RIGHT_BLOCK = Vector2i(14, 5)
const FERRUM_BOTTOM_LEFT_BLOCK = Vector2i(13, 6)
const FERRUM_BOTTOM_RIGHT_BLOCK = Vector2i(14, 6)
const FERRUM_TOP_V_BEAM = Vector2i(15, 4)
const FERRUM_CENTER_V_BEAM = Vector2i(15, 5)
const FERRUM_BOTTOM_V_BEAM = Vector2i(15, 6)

const IDK_LEFT_H_BEAM = Vector2i(12, 8)
const IDK_CENTER_H_BEAM = Vector2i(13, 8)
const IDK_RIGHT_H_BEAM = Vector2i(14, 8)
const IDK_ONE = Vector2i(12, 9)
const IDK_TOP_LEFT_BLOCK = Vector2i(13, 9)
const IDK_TOP_RIGHT_BLOCK = Vector2i(14, 9)
const IDK_BOTTOM_LEFT_BLOCK = Vector2i(13, 10)
const IDK_BOTTOM_RIGHT_BLOCK = Vector2i(14, 10)
const IDK_TOP_V_BEAM = Vector2i(15, 8)
const IDK_CENTER_V_BEAM = Vector2i(15, 9)
const IDK_BOTTOM_V_BEAM = Vector2i(15, 10)

const AURUM_LEFT_H_BEAM = Vector2i(17, 8)
const AURUM_CENTER_H_BEAM = Vector2i(18, 8)
const AURUM_RIGHT_H_BEAM = Vector2i(19, 8)
const AURUM_ONE = Vector2i(17, 9)
const AURUM_TOP_LEFT_BLOCK = Vector2i(18, 9)
const AURUM_TOP_RIGHT_BLOCK = Vector2i(19, 9)
const AURUM_BOTTOM_LEFT_BLOCK = Vector2i(18, 10)
const AURUM_BOTTOM_RIGHT_BLOCK = Vector2i(19, 10)
const AURUM_TOP_V_BEAM = Vector2i(20, 8)
const AURUM_CENTER_V_BEAM = Vector2i(20, 9)
const AURUM_BOTTOM_V_BEAM = Vector2i(20, 10)

# Chemistry Yeee

const BRICK_TOP_LEFT = Vector2i(17, 4)
const BRICK_TOP_CENTER = Vector2i(18, 4)
const BRICK_TOP_RIGHT = Vector2i(19, 4)
const BRICK_CENTER_LEFT = Vector2i(17, 5)
const BRICK_CENTER_CENTER = Vector2i(18, 5)
const BRICK_CENTER_RIGHT = Vector2i(19, 5)
const BRICK_BOTTOM_LEFT = Vector2i(17, 6)
const BRICK_BOTTOM_CENTER = Vector2i(18, 6)
const BRICK_BOTTOM_RIGHT = Vector2i(19, 6)

const DIRT_TOP_LEFT = Vector2i(6, 0)
const DIRT_TOP_CENTER = Vector2i(7, 0)
const DIRT_TOP_RIGHT = Vector2i(8, 0)
const DIRT_CENTER_LEFT = Vector2i(6, 1)
const DIRT_CENTER_CENTER = Vector2i(7, 1)
const DIRT_CENTER_RIGHT = Vector2i(8, 1)
const DIRT_BOTTOM_LEFT = Vector2i(6, 2)
const DIRT_BOTTOM_CENTER = Vector2i(7, 2)
const DIRT_BOTTOM_RIGHT = Vector2i(8, 2)

const DIRT_PINK_TOP_LEFT = Vector2i(6, 8)
const DIRT_PINK_TOP_CENTER = Vector2i(7, 8)
const DIRT_PINK_TOP_RIGHT = Vector2i(8, 8)
const DIRT_PINK_CENTER_LEFT = Vector2i(6, 9)
const DIRT_PINK_CENTER_CENTER = Vector2i(7, 9)
const DIRT_PINK_CENTER_RIGHT = Vector2i(8, 9)
const DIRT_PINK_BOTTOM_LEFT = Vector2i(6, 10)
const DIRT_PINK_BOTTOM_CENTER = Vector2i(7, 10)
const DIRT_PINK_BOTTOM_RIGHT = Vector2i(8, 10)

const DIRT_YELLOW_TOP_LEFT = Vector2i(6, 4)
const DIRT_YELLOW_TOP_CENTER = Vector2i(7, 4)
const DIRT_YELLOW_TOP_RIGHT = Vector2i(8, 4)
const DIRT_YELLOW_CENTER_LEFT = Vector2i(6, 5)
const DIRT_YELLOW_CENTER_CENTER = Vector2i(7, 5)
const DIRT_YELLOW_CENTER_RIGHT = Vector2i(8, 5)
const DIRT_YELLOW_BOTTOM_LEFT = Vector2i(6, 6)
const DIRT_YELLOW_BOTTOM_CENTER = Vector2i(7, 6)
const DIRT_YELLOW_BOTTOM_RIGHT = Vector2i(8, 6)


func _ready() -> void:
	generate()


func _process(delta: float) -> void:
	pass


func _input(event: InputEvent) -> void:
	if event is InputEventKey and event.pressed and not event.is_echo():
		match event.keycode:
			KEY_1:
				scene_type = 1
				generate()
			KEY_2:
				scene_type = 2
				generate()
			KEY_3:
				scene_type = 3
				generate()
			KEY_R:
				reject()
			KEY_P:
				accept()
			KEY_C:
				changes()


func generate() -> void:
	tiles.clear()
	if current_chunk:
		current_chunk.queue_free()

	current_chunk = Node2D.new()
	current_chunk.name = "Chunk " + str(chunk_counter)
	add_child(current_chunk)

	if player:
		player.position = Vector2(30, (FLOOR_Y - 2) * 16)
		player.velocity = Vector2.ZERO

	match scene_type:
		1:
			chunk_width = 27
			build_floor(0, chunk_width, FLOOR_Y)
			generate_small()
		2:
			chunk_width = 48
			build_floor(0, chunk_width, FLOOR_Y)
			generate_medium()
		3:
			chunk_width = 144
			build_floor(0, chunk_width, FLOOR_Y)
			generate_large()

	var end_marker = Marker2D.new()
	end_marker.name = "EndMarker"
	end_marker.position = Vector2(chunk_width * 16, FLOOR_Y * 16)
	current_chunk.add_child(end_marker)


func generate_small() -> void:
	randomize()

	var best_items: Array = []
	var best_peak_rect: Rect2i = Rect2i(12, PEAK_Y, 2, 2)

	for attempt in range(12):
		if build_level_graph_in_memory():
			best_items = placed_items.duplicate(true)
			best_peak_rect = true_nodes.back()["rect"]
			if placed_items.size() >= 78:
				break

	for item in best_items:
		var kind: String = item["kind"]
		var r: Rect2i = item["rect"]
		var mat: int = item["mat"]
		if kind == "wide_dirt":
			place_wide_dirt(r.position.x, r.position.y, r.size.x, r.size.y, mat)
		else:
			place_shape(kind, r.position.x, r.position.y, mat)

	var loot_container = Node2D.new()
	loot_container.name = "LootContainer"
	current_chunk.add_child(loot_container)

	var loot_spot = Marker2D.new()
	loot_spot.name = "PeakLootMarker"
	loot_spot.position = Vector2(
		(best_peak_rect.position.x + best_peak_rect.size.x * 0.5) * 16.0,
		best_peak_rect.position.y * 16.0 - 8.0
	)
	loot_container.add_child(loot_spot)


func build_level_graph_in_memory() -> bool:
	solid_cells.clear()
	true_air_cells.clear()
	placed_items.clear()
	true_nodes.clear()
	fake_nodes.clear()
	fork_hints.clear()
	landmark_fake_seeds.clear()

	true_air_cells[Vector2i(1, FLOOR_Y - 1)] = true
	true_air_cells[Vector2i(2, FLOOR_Y - 1)] = true
	true_air_cells[Vector2i(1, FLOOR_Y - 2)] = true
	true_air_cells[Vector2i(2, FLOOR_Y - 2)] = true

	shaft_w = randi_range(4, 5)
	shaft_x = randi_range(6, chunk_width - 6 - shaft_w)

	var zone_palettes: Array = [
		{"box": [0, 1, 2, 3].pick_random(), "dirt": [0, 2].pick_random()},
		{"box": [0, 1, 2, 3].pick_random(), "dirt": [1, 2, 3].pick_random()},
		{"box": [0, 2, 3].pick_random(), "dirt": [1, 3].pick_random()}
	]

	var use_mid_landmark: bool = randf() < 0.65
	var mid_lm_y: int = randi_range(4, 12)
	var top_lm_y: int = randi_range(-25, -16)
	var mid_lm_built: bool = not use_mid_landmark
	var top_lm_built: bool = false

	var start_kind: String = "box" if randf() < 0.75 else "mega_box"
	var start_sz: Vector2i = get_shape_size(start_kind)
	var start_x: int = randi_range(4, chunk_width - 3 - start_sz.x)
	var start_rect: Rect2i = Rect2i(start_x, FLOOR_Y - start_sz.y, start_sz.x, start_sz.y)
	add_platform_to_memory(
		start_kind, start_rect, get_zone_mat(start_kind, FLOOR_Y, zone_palettes), true, -1
	)

	var waypoint_x: int = randi_range(2, chunk_width - 5)
	var steps_until_retarget: int = randi_range(3, 5)
	var guard: int = 0

	while (true_nodes.back()["rect"] as Rect2i).position.y > PEAK_Y and guard < 90:
		guard += 1
		var cur_r: Rect2i = true_nodes.back()["rect"]

		if not mid_lm_built and cur_r.position.y <= mid_lm_y + 3:
			mid_lm_built = true
			build_horizon_landmark(zone_palettes)
			steps_until_retarget = 0
			continue

		if not top_lm_built and cur_r.position.y <= top_lm_y + 3:
			top_lm_built = true
			build_horizon_landmark(zone_palettes)
			steps_until_retarget = 0
			continue

		if steps_until_retarget <= 0 or abs(cur_r.position.x - waypoint_x) <= 3:
			if cur_r.position.x < 10:
				waypoint_x = randi_range(14, chunk_width - 4)
			elif cur_r.position.x > 16:
				waypoint_x = randi_range(2, 12)
			else:
				waypoint_x = (
					randi_range(2, 8) if randf() < 0.5 else randi_range(18, chunk_width - 4)
				)
			steps_until_retarget = randi_range(3, 6)

		steps_until_retarget -= 1
		if not step_true_climber(waypoint_x, zone_palettes):
			if not step_true_climber(-1, zone_palettes):
				return false

	var final_y: int = (true_nodes.back()["rect"] as Rect2i).position.y
	if final_y > PEAK_Y + 2 or true_nodes.size() < 24:
		return false

	spawn_floor_rival_paths(zone_palettes)

	for seed_info in landmark_fake_seeds:
		var s_rect: Rect2i = seed_info["rect"]
		var orig_idx: int = seed_info["origin_idx"]
		grow_fake_climber(s_rect, orig_idx, randi_range(7, 13), 0, zone_palettes, true)
		if s_rect.size.x >= 6:
			var sub_start = Rect2i(s_rect.position.x + s_rect.size.x - 2, s_rect.position.y, 2, 1)
			grow_fake_climber(sub_start, orig_idx, randi_range(5, 9), 0, zone_palettes, true)

	fork_hints.shuffle()
	for hint in fork_hints:
		var t_idx: int = hint["idx"]
		var pref_dir: int = hint["dir"]
		var anchor_r: Rect2i = true_nodes[t_idx]["rect"]
		grow_fake_climber(anchor_r, t_idx, randi_range(5, 10), pref_dir, zone_palettes, true)

	var indices: Array = range(1, true_nodes.size() - 2)
	indices.shuffle()
	for idx in indices:
		if placed_items.size() > 112:
			break
		var anchor_r: Rect2i = true_nodes[idx]["rect"]
		var dir: int = -1 if anchor_r.position.x > chunk_width / 2 else 1
		if randf() < 0.4:
			dir = -dir
		grow_fake_climber(anchor_r, idx, randi_range(4, 8), dir, zone_palettes, true)

	var initial_fakes: Array = fake_nodes.duplicate()
	initial_fakes.shuffle()
	var sub_branches: int = 0
	for f_node in initial_fakes:
		if sub_branches >= 12 or placed_items.size() > 118:
			break
		var f_rect: Rect2i = f_node["rect"]
		var orig_idx: int = f_node["origin_idx"]
		if grow_fake_climber(f_rect, orig_idx, randi_range(3, 6), 0, zone_palettes, true) > 0:
			sub_branches += 1

	return true


func step_true_climber(target_x: int, palettes: Array) -> bool:
	var cur_r: Rect2i = true_nodes.back()["rect"]
	var candidates: Array = []

	for i in range(60):
		var kind: String = pick_weighted_shape(MAIN_SHAPE_WEIGHTS)
		var sz: Vector2i = get_shape_size(kind)

		var dy: int = (
			[0, -1].pick_random()
			if (randf() < 0.10 and cur_r.position.y < FLOOR_Y - 6)
			else randi_range(1, MAX_JUMP_Y)
		)
		var max_gap: int = get_max_gap_for_dy(dy)
		var min_gap: int = 1 if dy > 0 else 2
		var gap: int = randi_range(min_gap, max_gap)

		var dir: int
		if target_x >= 0 and randf() < 0.78:
			dir = 1 if cur_r.position.x < target_x else -1
		else:
			dir = 1 if randf() < 0.5 else -1

		var tx: int = (
			(cur_r.position.x + cur_r.size.x + gap) if dir > 0 else (cur_r.position.x - sz.x - gap)
		)
		var ty: int = cur_r.position.y - dy

		var cand_r: Rect2i = Rect2i(tx, ty, sz.x, sz.y)
		if not is_valid_placement(cand_r, true):
			continue
		if not is_arc_clear_of_solids(cur_r, cand_r):
			continue

		if overlaps_shaft(cand_r) and sz.x >= 2 and randf() < 0.70:
			continue

		candidates.append({"kind": kind, "rect": cand_r, "dir": dir, "gap": gap, "dy": dy})

	if candidates.is_empty():
		return false

	var chosen: Dictionary = candidates.pick_random()
	if randf() < 0.35:
		for c in candidates:
			if c["gap"] >= 2 and c["dy"] >= 2:
				chosen = c
				break

	var cur_idx: int = true_nodes.size() - 1
	if chosen["gap"] >= 2 or chosen["dy"] == MAX_JUMP_Y:
		fork_hints.append({"idx": cur_idx, "dir": -int(chosen["dir"])})

	var c_kind: String = chosen["kind"]
	var c_rect: Rect2i = chosen["rect"]
	carve_true_arc(cur_r, c_rect)
	add_platform_to_memory(
		c_kind, c_rect, get_zone_mat(c_kind, c_rect.position.y, palettes), true, -1
	)
	return true


func build_horizon_landmark(palettes: Array) -> void:
	var cur_r: Rect2i = true_nodes.back()["rect"]
	var lm_y: int = cur_r.position.y - randi_range(2, 3)
	var dirt_mat: int = get_zone_mat("mega_box", lm_y, palettes)
	var box_mat: int = get_zone_mat("box", lm_y, palettes)
	var cur_idx: int = true_nodes.size() - 1
	var style: int = randi_range(0, 2)

	if style == 0:
		var gap_w: int = randi_range(5, 7)
		var gap_x: int = randi_range(7, chunk_width - 7 - gap_w)
		shaft_x = gap_x
		shaft_w = gap_w

		var left_r: Rect2i = Rect2i(2, lm_y, gap_x - 2, 3)
		var right_r: Rect2i = Rect2i(gap_x + gap_w, lm_y, (chunk_width - 2) - (gap_x + gap_w), 3)

		var left_ok: bool = left_r.size.x >= 4 and is_valid_placement(left_r, true)
		var right_ok: bool = right_r.size.x >= 4 and is_valid_placement(right_r, true)

		var mid_box: Rect2i = Rect2i(gap_x + int(gap_w / 2.0) - 1, lm_y + 1, 2, 2)
		if can_step_between(cur_r, mid_box) and is_valid_placement(mid_box, true):
			carve_true_arc(cur_r, mid_box)
			add_platform_to_memory("box", mid_box, box_mat, true, -1)
			cur_r = mid_box
			cur_idx = true_nodes.size() - 1

		var reachable_sides: Array = []
		if left_ok and can_step_between(cur_r, left_r):
			reachable_sides.append("left")
		if right_ok and can_step_between(cur_r, right_r):
			reachable_sides.append("right")

		if not reachable_sides.is_empty():
			var true_side: String = reachable_sides.pick_random()
			if left_ok:
				add_platform_to_memory("wide_dirt", left_r, dirt_mat, true_side == "left", cur_idx)
				if true_side == "left":
					carve_true_arc(cur_r, left_r)
				else:
					landmark_fake_seeds.append(
						{
							"rect": Rect2i(left_r.position.x + 1, left_r.position.y, 2, 1),
							"origin_idx": cur_idx
						}
					)
			if right_ok:
				add_platform_to_memory(
					"wide_dirt", right_r, dirt_mat, true_side == "right", cur_idx
				)
				if true_side == "right":
					carve_true_arc(cur_r, right_r)
				else:
					landmark_fake_seeds.append(
						{
							"rect": Rect2i(right_r.position.x + 1, right_r.position.y, 2, 1),
							"origin_idx": cur_idx
						}
					)
			for cx in range(gap_x, gap_x + gap_w):
				for cy in range(lm_y - 3, lm_y + 3):
					true_air_cells[Vector2i(cx, cy)] = true

	elif style == 1:
		var xs: Array = [randi_range(2, 5), randi_range(11, 14), randi_range(20, 22)]
		var valid_islands: Array = []
		for ix in xs:
			var ir: Rect2i = Rect2i(ix, lm_y, 3, 3)
			if is_valid_placement(ir, true):
				valid_islands.append(ir)

		var reachable_idx: Array = []
		for k in range(valid_islands.size()):
			if can_step_between(cur_r, valid_islands[k]):
				reachable_idx.append(k)

		if not reachable_idx.is_empty():
			var chosen_k: int = reachable_idx.pick_random()
			for k in range(valid_islands.size()):
				var ir: Rect2i = valid_islands[k]
				if k == chosen_k:
					carve_true_arc(cur_r, ir)
					add_platform_to_memory("mega_box", ir, dirt_mat, true, -1)
				else:
					add_platform_to_memory("mega_box", ir, dirt_mat, false, cur_idx)
					landmark_fake_seeds.append({"rect": ir, "origin_idx": cur_idx})

	else:
		var bw: int = randi_range(8, 11)
		var bx: int = clampi(
			cur_r.position.x - int(bw / 2.0) + randi_range(-2, 2), 4, chunk_width - 4 - bw
		)
		var br: Rect2i = Rect2i(bx, lm_y, bw, 3)
		if is_valid_placement(br, true) and can_step_between(cur_r, br):
			carve_true_arc(cur_r, br)
			add_platform_to_memory("wide_dirt", br, dirt_mat, true, -1)
			var fake_edge_x: int = bx if randf() < 0.5 else (bx + bw - 2)
			landmark_fake_seeds.append(
				{"rect": Rect2i(fake_edge_x, lm_y, 2, 1), "origin_idx": true_nodes.size() - 1}
			)


func spawn_floor_rival_paths(palettes: Array) -> void:
	var sectors: Array = [Vector2i(3, 8), Vector2i(10, 16), Vector2i(18, 23)]
	sectors.shuffle()

	for sec in sectors:
		var placed_starter: bool = false
		for attempt in range(12):
			var kind: String = "box" if randf() < 0.8 else "mega_box"
			var sz: Vector2i = get_shape_size(kind)
			var sx: int = randi_range(sec.x, sec.y - sz.x + 1)
			var s_rect: Rect2i = Rect2i(sx, FLOOR_Y - sz.y, sz.x, sz.y)

			if is_valid_placement(s_rect, false) and not can_shortcut_to_true_path(s_rect, 0):
				add_platform_to_memory(
					kind, s_rect, get_zone_mat(kind, FLOOR_Y, palettes), false, 0
				)
				grow_fake_climber(s_rect, 0, randi_range(8, 16), 0, palettes, true)
				placed_starter = true
				break


func grow_fake_climber(
	start_rect: Rect2i,
	origin_true_idx: int,
	steps: int,
	initial_dir: int,
	palettes: Array,
	cap_with_trap: bool
) -> int:
	var cur_r: Rect2i = start_rect
	var dir: int = initial_dir if initial_dir != 0 else (1 if randf() < 0.5 else -1)
	var max_climb_y: int = start_rect.position.y - randi_range(16, 28)
	var built_count: int = 0

	for s in range(steps):
		if cur_r.position.y <= maxi(PEAK_Y + 2, max_climb_y):
			break

		var step_candidates: Array = []
		for attempt in range(30):
			var kind: String = pick_weighted_shape(MAIN_SHAPE_WEIGHTS)
			var sz: Vector2i = get_shape_size(kind)
			var dy: int = randi_range(1, 2) if s == 0 else randi_range(1, MAX_JUMP_Y)
			var max_gap: int = get_max_gap_for_dy(dy)
			var gap: int = randi_range(1, mini(2, max_gap)) if s == 0 else randi_range(1, max_gap)

			var try_dir: int = dir if randf() < 0.72 else -dir
			var tx: int = (
				(cur_r.position.x + cur_r.size.x + gap)
				if try_dir > 0
				else (cur_r.position.x - sz.x - gap)
			)
			var ty: int = cur_r.position.y - dy
			var cand_r: Rect2i = Rect2i(tx, ty, sz.x, sz.y)

			if not is_valid_placement(cand_r, false):
				continue
			if not is_arc_clear_of_solids(cur_r, cand_r):
				continue
			if overlaps_shaft(cand_r) and randf() < 0.80:
				continue
			if can_shortcut_to_true_path(cand_r, origin_true_idx):
				continue

			step_candidates.append({"kind": kind, "rect": cand_r, "dir": try_dir})

		if step_candidates.is_empty():
			break

		var chosen: Dictionary = step_candidates.pick_random()
		var c_kind: String = chosen["kind"]
		var c_rect: Rect2i = chosen["rect"]
		add_platform_to_memory(
			c_kind,
			c_rect,
			get_zone_mat(c_kind, c_rect.position.y, palettes),
			false,
			origin_true_idx
		)
		cur_r = c_rect
		dir = chosen["dir"]
		if randf() < 0.35:
			dir = -dir
		built_count += 1

	if cap_with_trap and built_count >= 2:
		place_fake_finale_trap(cur_r, origin_true_idx, dir, palettes)

	return built_count


func place_fake_finale_trap(tip_r: Rect2i, origin_true_idx: int, dir: int, palettes: Array) -> void:
	var trap_roll: float = randf()
	var mat: int = get_zone_mat("box", tip_r.position.y, palettes)

	if trap_roll < 0.65:
		for d in [dir, -dir]:
			var dy: int = randi_range(2, 3)
			var bait_gap: int = get_max_gap_for_dy(dy) + 1
			var bx: int = (
				(tip_r.position.x + tip_r.size.x + bait_gap)
				if d > 0
				else (tip_r.position.x - 2 - bait_gap)
			)
			var bait_r: Rect2i = Rect2i(bx, tip_r.position.y - dy, 2, 2)
			if (
				is_valid_placement(bait_r, false)
				and not can_shortcut_to_true_path(bait_r, origin_true_idx)
			):
				add_platform_to_memory("box", bait_r, mat, false, origin_true_idx)
				break
	else:
		for d in [dir, -dir]:
			var target_r: Rect2i = Rect2i(
				(tip_r.position.x + tip_r.size.x + 2) if d > 0 else (tip_r.position.x - 4),
				tip_r.position.y - 2,
				2,
				2
			)
			var bonker_x: int = (
				(tip_r.position.x + tip_r.size.x) if d > 0 else (tip_r.position.x - 2)
			)
			var bonker_r: Rect2i = Rect2i(bonker_x, tip_r.position.y - 4, 2, 2)
			if (
				is_valid_placement(target_r, false)
				and not can_shortcut_to_true_path(target_r, origin_true_idx)
			):
				add_platform_to_memory("box", target_r, mat, false, origin_true_idx)
				if (
					is_valid_placement(bonker_r, false)
					and not can_shortcut_to_true_path(bonker_r, origin_true_idx)
				):
					add_platform_to_memory("box", bonker_r, mat, false, origin_true_idx)
				break


func can_shortcut_to_true_path(fake_r: Rect2i, origin_true_idx: int) -> bool:
	var start_check: int = maxi(0, origin_true_idx + 2)
	for j in range(start_check, true_nodes.size()):
		var t_r: Rect2i = true_nodes[j]["rect"]
		var dy_to_true: int = fake_r.position.y - t_r.position.y
		var h_gap: int = get_horiz_gap(fake_r, t_r)

		if dy_to_true >= -1 and dy_to_true <= MAX_JUMP_Y:
			if h_gap <= get_max_gap_for_dy(dy_to_true) + 1:
				return true

		if dy_to_true < -1:
			var drop_dist: int = -dy_to_true
			var max_air_drift: int = 4 + int(drop_dist * 0.45)
			if drop_dist <= 18 and h_gap <= max_air_drift:
				return true

	return false


func can_step_between(from_r: Rect2i, to_r: Rect2i) -> bool:
	var dy: int = from_r.position.y - to_r.position.y
	if dy < -1 or dy > MAX_JUMP_Y:
		return false
	var h_gap: int = get_horiz_gap(from_r, to_r)
	if dy > 0 and h_gap < 0:
		return false
	return h_gap <= get_max_gap_for_dy(dy) and is_arc_clear_of_solids(from_r, to_r)


func get_horiz_gap(a: Rect2i, b: Rect2i) -> int:
	if b.position.x >= a.position.x + a.size.x:
		return b.position.x - (a.position.x + a.size.x)
	if a.position.x >= b.position.x + b.size.x:
		return a.position.x - (b.position.x + b.size.x)
	return 0


func get_max_gap_for_dy(dy: int) -> int:
	if dy >= 3:
		return 2
	if dy == 2:
		return 3
	if dy == 1:
		return 4
	if dy == 0:
		return 4
	return 5


func is_valid_placement(rect: Rect2i, is_true_node: bool) -> bool:
	if rect.position.x < 1 or rect.position.x + rect.size.x > chunk_width - 1:
		return false
	var bottom_y: int = rect.position.y + rect.size.y
	if bottom_y > FLOOR_Y:
		return false
	if bottom_y > FLOOR_Y - 3 and bottom_y < FLOOR_Y:
		return false

	for cx in range(rect.position.x - 1, rect.position.x + rect.size.x + 1):
		for cy in range(rect.position.y - 1, rect.position.y + rect.size.y + 1):
			if solid_cells.has(Vector2i(cx, cy)):
				return false

	for cx in range(rect.position.x, rect.position.x + rect.size.x):
		for cy in range(rect.position.y - 3, rect.position.y):
			if solid_cells.has(Vector2i(cx, cy)):
				return false

	for cx in range(rect.position.x, rect.position.x + rect.size.x):
		for cy in range(rect.position.y, rect.position.y + rect.size.y):
			if true_air_cells.has(Vector2i(cx, cy)):
				return false

	return true


func add_platform_to_memory(
	kind: String, rect: Rect2i, mat: int, is_true: bool, origin_idx: int
) -> void:
	placed_items.append({"kind": kind, "rect": rect, "mat": mat})
	for cx in range(rect.position.x, rect.position.x + rect.size.x):
		for cy in range(rect.position.y, rect.position.y + rect.size.y):
			solid_cells[Vector2i(cx, cy)] = true

	if is_true:
		for cx in range(rect.position.x, rect.position.x + rect.size.x):
			for cy in range(rect.position.y - 3, rect.position.y):
				true_air_cells[Vector2i(cx, cy)] = true
		true_nodes.append({"kind": kind, "rect": rect})
	else:
		fake_nodes.append({"kind": kind, "rect": rect, "origin_idx": origin_idx})


func is_arc_clear_of_solids(from_r: Rect2i, to_r: Rect2i) -> bool:
	for cell in get_jump_arc_cells(from_r, to_r):
		if solid_cells.has(cell):
			return false
	return true


func carve_true_arc(from_r: Rect2i, to_r: Rect2i) -> void:
	for cell in get_jump_arc_cells(from_r, to_r):
		true_air_cells[cell] = true


func get_jump_arc_cells(from_r: Rect2i, to_r: Rect2i) -> Array:
	var cells: Array = []
	var apex_y: int = mini(from_r.position.y, to_r.position.y) - 3
	var low_y: int = maxi(from_r.position.y, to_r.position.y) + 1

	for cx in range(from_r.position.x, from_r.position.x + from_r.size.x):
		for cy in range(apex_y, from_r.position.y):
			cells.append(Vector2i(cx, cy))

	for cx in range(to_r.position.x, to_r.position.x + to_r.size.x):
		for cy in range(apex_y, to_r.position.y):
			cells.append(Vector2i(cx, cy))

	var gap_start: int = mini(from_r.position.x + from_r.size.x, to_r.position.x + to_r.size.x)
	var gap_end: int = maxi(from_r.position.x, to_r.position.x)
	for cx in range(gap_start, gap_end):
		for cy in range(apex_y, low_y):
			cells.append(Vector2i(cx, cy))

	return cells


func overlaps_shaft(rect: Rect2i) -> bool:
	return rect.position.x < (shaft_x + shaft_w) and (rect.position.x + rect.size.x) > shaft_x


func get_zone_mat(kind: String, y: int, palettes: Array) -> int:
	var zone_idx: int = 0 if y > 8 else (1 if y > -22 else 2)
	var pal: Dictionary = palettes[zone_idx]
	if kind == "mega_box" or kind == "wide_dirt":
		return pal["dirt"] if randf() < 0.85 else randi_range(0, 3)
	return pal["box"] if randf() < 0.82 else randi_range(0, 3)


func pick_weighted_shape(weights: Dictionary) -> String:
	var total: float = 0.0
	for w in weights.values():
		total += w
	var roll: float = randf() * total
	var acc: float = 0.0
	for k in weights.keys():
		acc += weights[k]
		if roll <= acc:
			return k
	return "box"


func get_shape_size(kind: String) -> Vector2i:
	match kind:
		"one":
			return Vector2i(1, 1)
		"box":
			return Vector2i(2, 2)
		"h_beam":
			return Vector2i(3, 1)
		"v_beam":
			return Vector2i(1, 3)
		"mega_box":
			return Vector2i(3, 3)
	return Vector2i(2, 2)


func place_shape(kind: String, x: int, y: int, mat: int) -> void:
	match kind:
		"one":
			place_one(x, y, mat)
		"box":
			place_box(x, y, mat)
		"h_beam":
			place_h_beam(x, y, mat)
		"v_beam":
			place_v_beam(x, y, mat)
		"mega_box":
			place_mega_box(x, y, mat)


func place_wide_dirt(start_x: int, start_y: int, w: int, h: int, mat: int = 1) -> void:
	if w < 2 or h < 2:
		return
	var tl = DIRT_TOP_LEFT
	var tc = DIRT_TOP_CENTER
	var tr = DIRT_TOP_RIGHT
	var cl = DIRT_CENTER_LEFT
	var cc = DIRT_CENTER_CENTER
	var cr = DIRT_CENTER_RIGHT
	var bl = DIRT_BOTTOM_LEFT
	var bc = DIRT_BOTTOM_CENTER
	var br = DIRT_BOTTOM_RIGHT

	match mat:
		0:
			tl = BRICK_TOP_LEFT
			tc = BRICK_TOP_CENTER
			tr = BRICK_TOP_RIGHT
			cl = BRICK_CENTER_LEFT
			cc = BRICK_CENTER_CENTER
			cr = BRICK_CENTER_RIGHT
			bl = BRICK_BOTTOM_LEFT
			bc = BRICK_BOTTOM_CENTER
			br = BRICK_BOTTOM_RIGHT
		2:
			tl = DIRT_YELLOW_TOP_LEFT
			tc = DIRT_YELLOW_TOP_CENTER
			tr = DIRT_YELLOW_TOP_RIGHT
			cl = DIRT_YELLOW_CENTER_LEFT
			cc = DIRT_YELLOW_CENTER_CENTER
			cr = DIRT_YELLOW_CENTER_RIGHT
			bl = DIRT_YELLOW_BOTTOM_LEFT
			bc = DIRT_YELLOW_BOTTOM_CENTER
			br = DIRT_YELLOW_BOTTOM_RIGHT
		3:
			tl = DIRT_PINK_TOP_LEFT
			tc = DIRT_PINK_TOP_CENTER
			tr = DIRT_PINK_TOP_RIGHT
			cl = DIRT_PINK_CENTER_LEFT
			cc = DIRT_PINK_CENTER_CENTER
			cr = DIRT_PINK_CENTER_RIGHT
			bl = DIRT_PINK_BOTTOM_LEFT
			bc = DIRT_PINK_BOTTOM_CENTER
			br = DIRT_PINK_BOTTOM_RIGHT

	for ix in range(w):
		for iy in range(h):
			var tile_coord: Vector2i
			if iy == 0:
				tile_coord = tl if ix == 0 else (tr if ix == w - 1 else tc)
			elif iy == h - 1:
				tile_coord = bl if ix == 0 else (br if ix == w - 1 else bc)
			else:
				tile_coord = cl if ix == 0 else (cr if ix == w - 1 else cc)
			tiles.set_cell(Vector2i(start_x + ix, start_y + iy), 0, tile_coord)


func generate_medium() -> void:
	randomize()
	solid_cells.clear()
	med_air_cells.clear()
	med_platforms.clear()

	var peak_y: int = randi_range(-121, -45)
	var total_h: int = FLOOR_Y - peak_y
	var target_count: int = clampi(int(total_h * 0.85) + randi_range(-5, 8), 84, 118)

	var pal: Dictionary = {
		"box": [0, 1, 2, 3].pick_random(),
		"alt_box": [0, 1, 2, 3].pick_random(),
		"dirt": [0, 1, 2, 3].pick_random(),
		"alt_dirt": [1, 2, 3].pick_random(),
		"beam": [0, 1, 2].pick_random()
	}

	for cx in range(1, 5):
		for cy in range(FLOOR_Y - 3, FLOOR_Y):
			med_air_cells[Vector2i(cx, cy)] = true

	med_build_setpieces(peak_y, pal)

	var walker_count: int = 3 if total_h <= 105 else 2
	var entry_zones: Array[Vector2i] = [
		Vector2i(4, 13),
		Vector2i(18, 28),
		Vector2i(33, 43)
	]
	entry_zones.shuffle()

	var walkers: Array = []
	for w in range(walker_count):
		var start_x: int = randi_range(entry_zones[w].x, entry_zones[w].y)
		var start_kind: String = "box" if randf() < 0.72 else "mega_box"
		var sz: Vector2i = get_shape_size(start_kind)
		var y_off: int = [0, 1, 2].pick_random()
		var s_rect: Rect2i = Rect2i(start_x, FLOOR_Y - sz.y - y_off, sz.x, sz.y)
		var mat: int = pal["dirt"] if start_kind == "mega_box" else pal["box"]

		var idx: int = med_try_place_single(start_kind, s_rect, mat)
		if idx == -1:
			idx = med_find_nearest_platform_in_band(start_x - 6, start_x + 6, FLOOR_Y - 8, FLOOR_Y)
		if idx != -1:
			var drift: int = 1 if start_x < 24 else -1
			walkers.append({"idx": idx, "drift": drift, "turn_cd": randi_range(3, 5), "done": false})

	var guard: int = 0
	while guard < 240 and med_platforms.size() < target_count:
		guard += 1
		var lowest_w: int = -1
		var max_y: int = -99999

		for w in range(walkers.size()):
			if walkers[w]["done"]:
				continue
			var wy: int = (med_platforms[walkers[w]["idx"]]["walk_rect"] as Rect2i).position.y
			if wy <= peak_y + 2:
				walkers[w]["done"] = true
				continue
			if wy > max_y:
				max_y = wy
				lowest_w = w

		if lowest_w == -1:
			break

		var wk: Dictionary = walkers[lowest_w]
		var cur_idx: int = wk["idx"]
		var cur_r: Rect2i = med_platforms[cur_idx]["walk_rect"]

		if wk["turn_cd"] <= 0 or cur_r.position.x < 6 or cur_r.position.x > chunk_width - 8:
			if cur_r.position.x < 8:
				wk["drift"] = 1
			elif cur_r.position.x > chunk_width - 10:
				wk["drift"] = -1
			elif randf() < 0.72:
				wk["drift"] = -wk["drift"]
			wk["turn_cd"] = randi_range(3, 6)
		wk["turn_cd"] -= 1

		var next_idx: int = med_step_from_platform(cur_idx, wk["drift"], peak_y, pal, true)
		if next_idx == -1:
			next_idx = med_step_from_platform(cur_idx, -wk["drift"], peak_y, pal, true)
		if next_idx == -1:
			next_idx = med_fallback_step(cur_idx, peak_y, pal)

		if next_idx == -1:
			wk["done"] = true
		else:
			wk["idx"] = next_idx
			if randf() < 0.25 and med_platforms.size() < target_count - 10:
				var side_idx: int = med_step_from_platform(cur_idx, -wk["drift"], peak_y, pal, false)
				if side_idx != -1 and randf() < 0.45:
					med_step_from_platform(side_idx, -wk["drift"], peak_y, pal, false)

	med_fill_empty_sectors(peak_y, target_count, pal)

	for p in med_platforms:
		for part in p["parts"]:
			var pr: Rect2i = part["rect"]
			place_shape(part["kind"], pr.position.x, pr.position.y, part["mat"])

	var loot_container = Node2D.new()
	loot_container.name = "LootContainer"
	current_chunk.add_child(loot_container)

	med_place_loot_spots(loot_container)

func med_build_setpieces(peak_y: int, pal: Dictionary) -> void:
	var total_h: int = FLOOR_Y - peak_y

	if randf() < 0.40:
		var count: int = randi_range(4, 6)
		var step_x: int = randi_range(6, 7)
		var sx: int = randi_range(6, 11)
		var row_y: int = FLOOR_Y - 2 - (1 if randf() < 0.4 else 0)
		var mat: int = pal["box"]
		for i in range(count):
			var bx: int = sx + i * step_x
			if bx + 2 >= chunk_width - 2:
				break
			med_try_place_single("box", Rect2i(bx, row_y, 2, 2), mat)

	var diag_count: int = 2 if total_h < 105 else 3
	for d in range(diag_count):
		var use_mega: bool = randf() < 0.55
		var kind: String = "mega_box" if use_mega else "box"
		var sz: Vector2i = get_shape_size(kind)
		var mat: int = pal["dirt"] if use_mega else pal["alt_box"]
		var dir: int = 1 if randf() < 0.5 else -1
		var cx: int = randi_range(4, 18) if dir > 0 else randi_range(28, 42)
		var band_y: int = FLOOR_Y - int(total_h * (float(d + 0.3) / float(diag_count + 0.5)))
		var cy: int = clampi(band_y, peak_y + 12, FLOOR_Y - sz.y - 2)
		var steps: int = randi_range(4, 6)
		for s in range(steps):
			if cx < 2 or cx + sz.x > chunk_width - 2 or cy < peak_y + 2:
				break
			med_try_place_single(kind, Rect2i(cx, cy, sz.x, sz.y), mat)
			cx += dir * (sz.x + randi_range(2, 3))
			cy -= randi_range(2, 3)

	var row_count: int = 2 if total_h < 105 else 3
	for r in range(row_count):
		var band_y: int = FLOOR_Y - int(total_h * (float(r + 0.7) / float(row_count + 0.6)))
		var row_y: int = clampi(band_y + randi_range(-4, 4), peak_y + 2, FLOOR_Y - 8)
		var count: int = randi_range(3, 5)
		var sx: int = randi_range(5, 20)
		var kind: String = "h_beam" if randf() < 0.68 else "box"
		var sz: Vector2i = get_shape_size(kind)
		var mat: int = pal["beam"] if kind == "h_beam" else pal["alt_box"]
		for i in range(count):
			var px: int = sx + i * (sz.x + randi_range(2, 4))
			if px + sz.x >= chunk_width - 2:
				break
			med_try_place_single(kind, Rect2i(px, row_y, sz.x, sz.y), mat)

	if randf() < 0.30:
		var wall_x: int = randi_range(12, 30)
		var roof_y: int = randi_range(peak_y + 6, FLOOR_Y - 25)
		var dir: int = 1 if wall_x < 24 else -1
		var wall_mat: int = pal["alt_box"]
		var parts: Array = []
		var segments_v: int = randi_range(2, 3)
		var segments_h: int = randi_range(3, 4)

		for vy in range(segments_v):
			parts.append({"kind": "v_beam", "rect": Rect2i(wall_x, roof_y + 1 + vy * 3, 1, 3), "mat": wall_mat})
		for hx in range(segments_h):
			var bx: int = (wall_x + hx * 3) if dir > 0 else (wall_x - 2 - hx * 3)
			if bx >= 2 and bx + 3 <= chunk_width - 2:
				parts.append({"kind": "h_beam", "rect": Rect2i(bx, roof_y, 3, 1), "mat": wall_mat})

		if not parts.is_empty():
			var bbox: Rect2i = med_parts_bbox(parts)
			if med_can_place_parts(parts, bbox, false):
				med_commit_platform("l_wall", parts, Rect2i(bbox.position.x, roof_y, bbox.size.x, 1))

func med_step_from_platform(from_idx: int, pref_dir: int, peak_y: int, pal: Dictionary, prefer_up: bool) -> int:
	var cur_r: Rect2i = med_platforms[from_idx]["walk_rect"]
	var candidates: Array = []

	for attempt in range(40):
		var roll: float = randf()
		var kind: String
		if roll < 0.44: kind = "box"
		elif roll < 0.62: kind = "mega_box"
		elif roll < 0.75: kind = "h_beam"
		elif roll < 0.86: kind = "v_beam"
		elif roll < 0.88: kind = "l_corner"
		else: kind = "box_stud"

		var dy: int
		if prefer_up:
			dy = [1, 2, 3, 3, 4, 4, 5, 0, -1].pick_random()
		else:
			dy = [-1, 0, 1, 2, 3].pick_random()

		var max_gap: int = med_max_gap_for_dy(dy)
		var min_gap: int = 2 if dy <= 1 else 1
		var gap: int = randi_range(min_gap, max_gap)
		var dir: int = pref_dir if randf() < 0.82 else -pref_dir

		var parts: Array = med_build_shape_parts(kind, 0, 0, pal)
		var bbox: Rect2i = med_parts_bbox(parts)
		var tx: int = (cur_r.position.x + cur_r.size.x + gap) if dir > 0 else (cur_r.position.x - bbox.size.x - gap)
		var ty: int = cur_r.position.y - dy

		if tx < 2 or tx + bbox.size.x > chunk_width - 2:
			continue
		if ty < peak_y or ty + bbox.size.y > FLOOR_Y - 2:
			continue

		parts = med_build_shape_parts(kind, tx, ty, pal)
		var walk_r: Rect2i = med_parts_walk_rect(kind, tx, ty, bbox)

		if not med_can_place_parts(parts, walk_r, false):
			continue
		if not med_is_arc_clear(cur_r, walk_r):
			continue

		candidates.append({"kind": kind, "parts": parts, "walk_r": walk_r})

	if candidates.is_empty():
		return -1

	var chosen: Dictionary = candidates.pick_random()
	return med_commit_platform(chosen["kind"], chosen["parts"], chosen["walk_r"])


func med_fallback_step(from_idx: int, peak_y: int, pal: Dictionary) -> int:
	var cur_r: Rect2i = med_platforms[from_idx]["walk_rect"]
	for kind in ["box", "h_beam", "one"]:
		var sz: Vector2i = get_shape_size(kind)
		for dy in [3, 2, 4, 1, 0]:
			for gap in [2, 3, 1, 4]:
				if gap > med_max_gap_for_dy(dy):
					continue
				for dir in [1, -1]:
					var tx: int = (cur_r.position.x + cur_r.size.x + gap) if dir > 0 else (cur_r.position.x - sz.x - gap)
					var ty: int = cur_r.position.y - dy
					if tx < 2 or tx + sz.x > chunk_width - 2 or ty < peak_y or ty + sz.y > FLOOR_Y - 2:
						continue
					var parts: Array = med_build_shape_parts(kind, tx, ty, pal)
					var walk_r: Rect2i = Rect2i(tx, ty, sz.x, sz.y)
					if med_can_place_parts(parts, walk_r, false) and med_is_arc_clear(cur_r, walk_r):
						return med_commit_platform(kind, parts, walk_r)
	return -1


func med_fill_empty_sectors(peak_y: int, target_count: int, pal: Dictionary) -> void:
	var total_h: int = FLOOR_Y - 2 - peak_y
	var cols: int = 4
	var rows: int = clampi(int(total_h / 15.0), 5, 10)
	var col_w: float = float(chunk_width - 4) / float(cols)
	var row_h: float = float(total_h) / float(rows)

	var sector_coords: Array[Vector2i] = []
	for r in range(rows):
		for c in range(cols):
			sector_coords.append(Vector2i(c, r))
	sector_coords.shuffle()

	for sc in sector_coords:
		if med_platforms.size() >= target_count + 6:
			break
		var sx0: int = 2 + int(sc.x * col_w)
		var sx1: int = 2 + int((sc.x + 1) * col_w)
		var sy0: int = peak_y + int(sc.y * row_h)
		var sy1: int = peak_y + int((sc.y + 1) * row_h)
		var area: Rect2i = Rect2i(sx0, sy0, sx1 - sx0, sy1 - sy0)

		if med_count_platforms_in_rect(area) >= 2:
			continue

		var cx_target: int = int((sx0 + sx1) / 2.0)
		var cy_target: int = int((sy0 + sy1) / 2.0)
		var nearest_idx: int = med_find_nearest_platform(cx_target, cy_target)
		if nearest_idx == -1:
			continue

		var nr: Rect2i = med_platforms[nearest_idx]["walk_rect"]
		var dir: int = 1 if nr.position.x < cx_target else -1
		var step_idx: int = med_step_from_platform(nearest_idx, dir, peak_y, pal, nr.position.y > cy_target)
		if step_idx != -1:
			var sr: Rect2i = med_platforms[step_idx]["walk_rect"]
			if abs(sr.position.x - cx_target) > 4 or abs(sr.position.y - cy_target) > 4:
				med_step_from_platform(step_idx, dir, peak_y, pal, sr.position.y > cy_target)

		if med_count_platforms_in_rect(area) == 0:
			var kind: String = ["box", "mega_box", "h_beam"].pick_random()
			var sz: Vector2i = get_shape_size(kind)
			var px: int = clampi(cx_target + randi_range(-2, 2) - int(sz.x / 2.0), 2, chunk_width - 2 - sz.x)
			var py: int = clampi(cy_target + randi_range(-2, 2) - int(sz.y / 2.0), peak_y, FLOOR_Y - 4 - sz.y)
			var mat: int = pal["dirt"] if kind == "mega_box" else pal["alt_box"]
			med_try_place_single(kind, Rect2i(px, py, sz.x, sz.y), mat)

	var expand_guard: int = 0
	while med_platforms.size() < target_count and expand_guard < 120:
		expand_guard += 1
		var base_idx: int = randi_range(0, med_platforms.size() - 1)
		var br: Rect2i = med_platforms[base_idx]["walk_rect"]
		var dir: int = 1 if br.position.x < 24 else -1
		if randf() < 0.4:
			dir = -dir
		med_step_from_platform(base_idx, dir, peak_y, pal, randf() < 0.65)


func med_build_shape_parts(kind: String, x: int, y: int, pal: Dictionary) -> Array:
	match kind:
		"one":
			return [{"kind": "one", "rect": Rect2i(x, y, 1, 1), "mat": pal["box"]}]
		"box":
			var m: int = pal["box"] if randf() < 0.7 else pal["alt_box"]
			return [{"kind": "box", "rect": Rect2i(x, y, 2, 2), "mat": m}]
		"mega_box":
			var dm: int = pal["dirt"] if randf() < 0.75 else pal["alt_dirt"]
			return [{"kind": "mega_box", "rect": Rect2i(x, y, 3, 3), "mat": dm}]
		"h_beam":
			return [{"kind": "h_beam", "rect": Rect2i(x, y, 3, 1), "mat": pal["beam"]}]
		"v_beam":
			return [{"kind": "v_beam", "rect": Rect2i(x, y, 1, 3), "mat": pal["beam"]}]
		"l_corner":
			var bm: int = pal["beam"]
			if randf() < 0.5:
				return [
					{"kind": "h_beam", "rect": Rect2i(x, y, 3, 1), "mat": bm},
					{"kind": "v_beam", "rect": Rect2i(x + 3, y, 1, 3), "mat": bm}
				]
			else:
				return [
					{"kind": "v_beam", "rect": Rect2i(x, y, 1, 3), "mat": bm},
					{"kind": "h_beam", "rect": Rect2i(x + 1, y + 2, 3, 1), "mat": bm}
				]
		"box_stud":
			var m2: int = pal["box"]
			if randf() < 0.5:
				return [
					{"kind": "box", "rect": Rect2i(x, y, 2, 2), "mat": m2},
					{"kind": "one", "rect": Rect2i(x + 2, y + 1, 1, 1), "mat": m2}
				]
			else:
				return [
					{"kind": "one", "rect": Rect2i(x, y, 1, 1), "mat": m2},
					{"kind": "box", "rect": Rect2i(x + 1, y, 2, 2), "mat": m2}
				]
	return [{"kind": "box", "rect": Rect2i(x, y, 2, 2), "mat": pal["box"]}]


func med_parts_bbox(parts: Array) -> Rect2i:
	var min_x: int = 9999; var min_y: int = 9999
	var max_x: int = -9999; var max_y: int = -9999
	for part in parts:
		var r: Rect2i = part["rect"]
		min_x = mini(min_x, r.position.x)
		min_y = mini(min_y, r.position.y)
		max_x = maxi(max_x, r.position.x + r.size.x)
		max_y = maxi(max_y, r.position.y + r.size.y)
	return Rect2i(min_x, min_y, max_x - min_x, max_y - min_y)


func med_parts_walk_rect(kind: String, x: int, y: int, bbox: Rect2i) -> Rect2i:
	if kind == "l_corner":
		return Rect2i(x, y, bbox.size.x, 1)
	return Rect2i(bbox.position.x, bbox.position.y, bbox.size.x, bbox.size.y)


func med_try_place_single(kind: String, rect: Rect2i, mat: int, allow_touch_solid: bool = false) -> int:
	if rect.position.x < 1 or rect.position.x + rect.size.x > chunk_width - 1:
		return -1
	if rect.position.y + rect.size.y > FLOOR_Y:
		return -1
	var parts: Array = [{"kind": kind, "rect": rect, "mat": mat}]
	if not med_can_place_parts(parts, rect, allow_touch_solid):
		return -1
	return med_commit_platform(kind, parts, rect)


func med_can_place_parts(parts: Array, walk_r: Rect2i, allow_touch_solid: bool) -> bool:
	var margin: int = 0 if allow_touch_solid else 1
	for part in parts:
		var r: Rect2i = part["rect"]
		var bottom_y: int = r.position.y + r.size.y
		if bottom_y > FLOOR_Y:
			return false
		if not allow_touch_solid and bottom_y == FLOOR_Y - 1:
			return false

		for cx in range(r.position.x - margin, r.position.x + r.size.x + margin):
			for cy in range(r.position.y - margin, r.position.y + r.size.y + margin):
				if solid_cells.has(Vector2i(cx, cy)):
					return false
		for cx in range(r.position.x, r.position.x + r.size.x):
			for cy in range(r.position.y, r.position.y + r.size.y):
				if med_air_cells.has(Vector2i(cx, cy)):
					return false

	if not allow_touch_solid:
		for cx in range(walk_r.position.x, walk_r.position.x + walk_r.size.x):
			for cy in range(walk_r.position.y - 2, walk_r.position.y):
				if solid_cells.has(Vector2i(cx, cy)):
					return false
	return true


func med_commit_platform(kind: String, parts: Array, walk_r: Rect2i) -> int:
	for part in parts:
		var r: Rect2i = part["rect"]
		for cx in range(r.position.x, r.position.x + r.size.x):
			for cy in range(r.position.y, r.position.y + r.size.y):
				solid_cells[Vector2i(cx, cy)] = true

	for cx in range(walk_r.position.x, walk_r.position.x + walk_r.size.x):
		for cy in range(walk_r.position.y - 2, walk_r.position.y):
			med_air_cells[Vector2i(cx, cy)] = true

	med_platforms.append({"kind": kind, "parts": parts, "walk_rect": walk_r})
	return med_platforms.size() - 1


func med_place_loot_spots(loot: Node2D) -> void:
	var reachable_indices: Array[int] = med_get_reachable_platforms()
	var candidates: Array[int] = []

	for idx in reachable_indices:
		var r: Rect2i = med_platforms[idx]["walk_rect"]
		if r.position.y <= FLOOR_Y - 5:
			candidates.append(idx)

	if candidates.is_empty():
		candidates = reachable_indices
	if candidates.is_empty():
		return

	candidates.sort_custom(func(a: int, b: int) -> bool:
		var ra: Rect2i = med_platforms[a]["walk_rect"]
		var rb: Rect2i = med_platforms[b]["walk_rect"]
		var sa: float = float(FLOOR_Y - ra.position.y) * 0.45 + randf() * 25.0
		var sb: float = float(FLOOR_Y - rb.position.y) * 0.45 + randf() * 25.0
		return sa > sb
	)

	var target_loot: int = clampi(int(med_platforms.size() / 6.0), 10, 20)
	var chosen_rects: Array[Rect2i] = []

	for min_dist in [10.0, 7.5]:
		for idx in candidates:
			if chosen_rects.size() >= target_loot:
				break
			var r: Rect2i = med_platforms[idx]["walk_rect"]
			var center: Vector2 = Vector2(r.position.x + r.size.x * 0.5, r.position.y)
			var too_close: bool = false
			for cr in chosen_rects:
				var c2: Vector2 = Vector2(cr.position.x + cr.size.x * 0.5, cr.position.y)
				if center.distance_to(c2) < min_dist:
					too_close = true
					break
			if not too_close:
				chosen_rects.append(r)

	if chosen_rects.is_empty():
		return

	var highest_i: int = 0
	for i in range(1, chosen_rects.size()):
		if chosen_rects[i].position.y < chosen_rects[highest_i].position.y:
			highest_i = i

	for i in range(chosen_rects.size()):
		var r: Rect2i = chosen_rects[i]
		var marker = Marker2D.new()
		marker.name = "PeakLootMarker" if i == highest_i else ("LootMarker_" + str(i))
		marker.position = Vector2((r.position.x + r.size.x * 0.5) * 16.0, r.position.y * 16.0 - 8.0)
		loot.add_child(marker)


func med_get_reachable_platforms() -> Array[int]:
	var visited: Dictionary = {}
	var queue: Array[int] = []

	for i in range(med_platforms.size()):
		var r: Rect2i = med_platforms[i]["walk_rect"]
		if FLOOR_Y - r.position.y <= MAX_JUMP_Y:
			visited[i] = true
			queue.append(i)

	var head: int = 0
	while head < queue.size():
		var cur_i: int = queue[head]
		head += 1
		var from_r: Rect2i = med_platforms[cur_i]["walk_rect"]

		for j in range(med_platforms.size()):
			if visited.has(j):
				continue
			var to_r: Rect2i = med_platforms[j]["walk_rect"]
			var dy: int = from_r.position.y - to_r.position.y

			if dy > MAX_JUMP_Y or dy < -14:
				continue

			var h_gap: int = med_horiz_gap(from_r, to_r)
			if dy >= 0:
				if h_gap < 0 and dy > 0:
					continue
				if h_gap <= med_max_gap_for_dy(dy) and med_is_arc_clear(from_r, to_r):
					visited[j] = true
					queue.append(j)
			else:
				var drop_dist: int = -dy
				if h_gap <= 4 + int(drop_dist * 0.4):
					visited[j] = true
					queue.append(j)

	var res: Array[int] = []
	for k in visited.keys():
		res.append(int(k))
	return res


func med_count_platforms_in_rect(area: Rect2i) -> int:
	var count: int = 0
	for p in med_platforms:
		var r: Rect2i = p["walk_rect"]
		if r.position.x >= area.position.x and r.position.x < area.position.x + area.size.x:
			if r.position.y >= area.position.y and r.position.y < area.position.y + area.size.y:
				count += 1
	return count


func med_find_nearest_platform(tx: int, ty: int) -> int:
	var best_idx: int = -1
	var best_dist: float = 999999.0
	for i in range(med_platforms.size()):
		var r: Rect2i = med_platforms[i]["walk_rect"]
		var d: float = Vector2(r.position.x + r.size.x * 0.5, r.position.y).distance_to(Vector2(tx, ty))
		if d < best_dist:
			best_dist = d
			best_idx = i
	return best_idx


func med_find_nearest_platform_in_band(min_x: int, max_x: int, min_y: int, max_y: int) -> int:
	for i in range(med_platforms.size()):
		var r: Rect2i = med_platforms[i]["walk_rect"]
		if r.position.x >= min_x and r.position.x <= max_x and r.position.y >= min_y and r.position.y <= max_y:
			return i
	return -1


func med_is_arc_clear(from_r: Rect2i, to_r: Rect2i) -> bool:
	var apex_y: int = mini(from_r.position.y, to_r.position.y) - 2
	var low_y: int = maxi(from_r.position.y, to_r.position.y)
	var gap_start: int = mini(from_r.position.x + from_r.size.x, to_r.position.x + to_r.size.x)
	var gap_end: int = maxi(from_r.position.x, to_r.position.x)
	for cx in range(gap_start, gap_end):
		for cy in range(apex_y, low_y):
			if solid_cells.has(Vector2i(cx, cy)):
				return false
	return true


func med_horiz_gap(a: Rect2i, b: Rect2i) -> int:
	if b.position.x >= a.position.x + a.size.x:
		return b.position.x - (a.position.x + a.size.x)
	if a.position.x >= b.position.x + b.size.x:
		return a.position.x - (b.position.x + b.size.x)
	return -1


func med_max_gap_for_dy(dy: int) -> int:
	if dy >= 5: return 2
	if dy >= 3: return 3
	if dy == 2: return 4
	if dy == 1: return 5
	if dy == 0: return 5
	return 6

func generate_large() -> void:
	randomize()
	solid_cells.clear()
	lar_air_cells.clear()
	lar_platforms.clear()
	
	var target_count = randi_range(28, 48)
	var left_mat = [0, 1, 2, 3].pick_random()
	var right_mat = [0, 1, 2, 3].pick_random()
	var attempts: int = 0
	var split_x = randi_range(55, 90)
	
	while lar_platforms.size() < target_count and attempts < 400:
		attempts += 1
		var platform_type: String = ""
		var platrandom = randf()
		if platrandom <= 0.40:
			platform_type = "one"
		elif platrandom <= 0.80:
			platform_type = "box"
		elif platrandom <= 0.90:
			platform_type = "mega_box"
		elif platrandom <= 1.0:
			platform_type = "h_beam"
		
		
		var sz = get_shape_size(platform_type)
		var x = randi_range(8, chunk_width - 4 - sz.x)
		var y = 0
		
		var floatrandom = randf()
		if floatrandom <= 0.60:
			y = randi_range(FLOOR_Y - 10, FLOOR_Y - sz.y)
		else:
			y = randi_range(FLOOR_Y - 22, FLOOR_Y - 11)
		
		var bottom_y = y + sz.y
		if bottom_y == FLOOR_Y - 1 or bottom_y == FLOOR_Y - 2:
			continue
			
		var can_place: bool = true
		for cx in range(x - 1, x + sz.x + 1):
			for cy in range(y - 1, y + sz.y + 1):
				if solid_cells.has(Vector2i(cx, cy)):
					can_place = false
		if can_place:
			for cx in range(x, x + sz.x):
				for cy in range(y, y + sz.y):
					if lar_air_cells.has(Vector2i(cx, cy)):
						can_place = false
						break
						
		if not can_place:
			continue
		var mat = 0
		if x <= split_x:
			mat = left_mat
		else:
			mat = right_mat
		
		place_shape(platform_type, x, y, mat) # okak
		
		for cx in range(x, x + sz.x):
			for cy in range(y, y + sz.y):
				solid_cells[Vector2i(cx, cy)] = true
		
		lar_platforms.append(Rect2i(x, y, sz.x, sz.y))
		

var _crypto := Crypto.new()

func generate_request_id() -> int:
	var id := 0
	while id == 0:
		id = _crypto.generate_random_bytes(4).decode_u32(0)
	return id

func accept(suffix: String = "") -> void:
	if not current_chunk:
		return

	var chunk_tiles: TileMapLayer = tiles.duplicate()
	current_chunk.add_child(chunk_tiles)

	chunk_tiles.owner = current_chunk
	for child in current_chunk.get_children():
		child.owner = current_chunk
		for sub_child in child.get_children():
			sub_child.owner = current_chunk

	var scene = PackedScene.new()
	scene.pack(current_chunk)

	var temp_path: String = "user://temp_chunk.tscn"
	ResourceSaver.save(scene, temp_path)
	
	var tscn_text: String = FileAccess.get_file_as_string(temp_path)
	
	DirAccess.remove_absolute(temp_path)
	
	var payload: Dictionary = {
		"size": scene_type,
		"id": generate_request_id(),
		"tscn": tscn_text
	}
	var json_body: String = JSON.stringify(payload)
	
	var headers: PackedStringArray = ["Content-Type: application/json"]
	http_request.request(
		"https://godot.ininids.in.rs/scenes",
		headers,
		HTTPClient.METHOD_POST,
		json_body
	)

	chunk_counter += 1

	generate()


func reject() -> void:
	generate()


func changes() -> void:
	accept("_changes")


func build_floor(start_x: int, width: int, y: int) -> void:
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

		tiles.set_cell(Vector2i(cur_x, y), 0, top_tile)

		for depth in range(1, 12):
			tiles.set_cell(Vector2i(cur_x, y + depth), 0, dirt_tile)


func place_one(x: int, y: int, mat: int) -> void:
	match mat:
		0:
			tiles.set_cell(Vector2i(x, y), 0, CUPRUM_ONE)
		1:
			tiles.set_cell(Vector2i(x, y), 0, FERRUM_ONE)
		2:
			tiles.set_cell(Vector2i(x, y), 0, AURUM_ONE)
		3:
			tiles.set_cell(Vector2i(x, y), 0, IDK_ONE)


func place_box(x: int, y: int, mat: int) -> void:
	var tl: Vector2i
	var tr: Vector2i
	var bl: Vector2i
	var br: Vector2i
	match mat:
		0:
			tl = CUPRUM_TOP_LEFT_BLOCK
			tr = CUPRUM_TOP_RIGHT_BLOCK
			bl = CUPRUM_BOTTOM_LEFT_BLOCK
			br = CUPRUM_BOTTOM_RIGHT_BLOCK
		1:
			tl = FERRUM_TOP_LEFT_BLOCK
			tr = FERRUM_TOP_RIGHT_BLOCK
			bl = FERRUM_BOTTOM_LEFT_BLOCK
			br = FERRUM_BOTTOM_RIGHT_BLOCK
		2:
			tl = AURUM_TOP_LEFT_BLOCK
			tr = AURUM_TOP_RIGHT_BLOCK
			bl = AURUM_BOTTOM_LEFT_BLOCK
			br = AURUM_BOTTOM_RIGHT_BLOCK
		3:
			tl = IDK_TOP_LEFT_BLOCK
			tr = IDK_TOP_RIGHT_BLOCK
			bl = IDK_BOTTOM_LEFT_BLOCK
			br = IDK_BOTTOM_RIGHT_BLOCK

	tiles.set_cell(Vector2i(x, y), 0, tl)
	tiles.set_cell(Vector2i(x + 1, y), 0, tr)
	tiles.set_cell(Vector2i(x, y + 1), 0, bl)
	tiles.set_cell(Vector2i(x + 1, y + 1), 0, br)


func place_h_beam(x: int, y: int, mat: int) -> void:
	var l: Vector2i
	var m: Vector2i
	var r: Vector2i
	match mat:
		0:
			l = CUPRUM_LEFT_H_BEAM
			m = CUPRUM_CENTER_H_BEAM
			r = CUPRUM_RIGHT_H_BEAM
		1:
			l = FERRUM_LEFT_H_BEAM
			m = FERRUM_CENTER_H_BEAM
			r = FERRUM_RIGHT_H_BEAM
		2:
			l = AURUM_LEFT_H_BEAM
			m = AURUM_CENTER_H_BEAM
			r = AURUM_RIGHT_H_BEAM
		3:
			l = IDK_LEFT_H_BEAM
			m = IDK_CENTER_H_BEAM
			r = IDK_RIGHT_H_BEAM

	tiles.set_cell(Vector2i(x, y), 0, l)
	tiles.set_cell(Vector2i(x + 1, y), 0, m)
	tiles.set_cell(Vector2i(x + 2, y), 0, r)


func place_mega_box(x: int, y: int, mat: int) -> void:
	var tl: Vector2i
	var tc: Vector2i
	var tr: Vector2i
	var cl: Vector2i
	var cc: Vector2i
	var cr: Vector2i
	var bl: Vector2i
	var bc: Vector2i
	var br: Vector2i

	match mat:
		0:
			tl = BRICK_TOP_LEFT
			tc = BRICK_TOP_CENTER
			tr = BRICK_TOP_RIGHT
			cl = BRICK_CENTER_LEFT
			cc = BRICK_CENTER_CENTER
			cr = BRICK_CENTER_RIGHT
			bl = BRICK_BOTTOM_LEFT
			bc = BRICK_BOTTOM_CENTER
			br = BRICK_BOTTOM_RIGHT
		1:
			tl = DIRT_TOP_LEFT
			tc = DIRT_TOP_CENTER
			tr = DIRT_TOP_RIGHT
			cl = DIRT_CENTER_LEFT
			cc = DIRT_CENTER_CENTER
			cr = DIRT_CENTER_RIGHT
			bl = DIRT_BOTTOM_LEFT
			bc = DIRT_BOTTOM_CENTER
			br = DIRT_BOTTOM_RIGHT
		2:
			tl = DIRT_YELLOW_TOP_LEFT
			tc = DIRT_YELLOW_TOP_CENTER
			tr = DIRT_YELLOW_TOP_RIGHT
			cl = DIRT_YELLOW_CENTER_LEFT
			cc = DIRT_YELLOW_CENTER_CENTER
			cr = DIRT_YELLOW_CENTER_RIGHT
			bl = DIRT_YELLOW_BOTTOM_LEFT
			bc = DIRT_YELLOW_BOTTOM_CENTER
			br = DIRT_YELLOW_BOTTOM_RIGHT
		3:
			tl = DIRT_PINK_TOP_LEFT
			tc = DIRT_PINK_TOP_CENTER
			tr = DIRT_PINK_TOP_RIGHT
			cl = DIRT_PINK_CENTER_LEFT
			cc = DIRT_PINK_CENTER_CENTER
			cr = DIRT_PINK_CENTER_RIGHT
			bl = DIRT_PINK_BOTTOM_LEFT
			bc = DIRT_PINK_BOTTOM_CENTER
			br = DIRT_PINK_BOTTOM_RIGHT

	tiles.set_cell(Vector2i(x, y), 0, tl)
	tiles.set_cell(Vector2i(x + 1, y), 0, tc)
	tiles.set_cell(Vector2i(x + 2, y), 0, tr)

	tiles.set_cell(Vector2i(x, y + 1), 0, cl)
	tiles.set_cell(Vector2i(x + 1, y + 1), 0, cc)
	tiles.set_cell(Vector2i(x + 2, y + 1), 0, cr)

	tiles.set_cell(Vector2i(x, y + 2), 0, bl)
	tiles.set_cell(Vector2i(x + 1, y + 2), 0, bc)
	tiles.set_cell(Vector2i(x + 2, y + 2), 0, br)


func place_v_beam(x: int, y: int, mat: int) -> void:
	var t: Vector2i
	var m: Vector2i
	var b: Vector2i
	match mat:
		0:
			t = CUPRUM_TOP_V_BEAM
			m = CUPRUM_CENTER_V_BEAM
			b = CUPRUM_BOTTOM_V_BEAM
		1:
			t = FERRUM_TOP_V_BEAM
			m = FERRUM_CENTER_V_BEAM
			b = FERRUM_BOTTOM_V_BEAM
		2:
			t = AURUM_TOP_V_BEAM
			m = AURUM_CENTER_V_BEAM
			b = AURUM_BOTTOM_V_BEAM
		3:
			t = IDK_TOP_V_BEAM
			m = IDK_CENTER_V_BEAM
			b = IDK_BOTTOM_V_BEAM

	tiles.set_cell(Vector2i(x, y), 0, t)
	tiles.set_cell(Vector2i(x, y + 1), 0, m)
	tiles.set_cell(Vector2i(x, y + 2), 0, b)

extends Node2D

onready var cursorMarker = $CursorMarker;
onready var player1 = $Player;
onready var player2 = $Player2;
onready var camera = $Camera2D;
onready var map = $Map;
onready var hud = $Hud;

var active_player = 0

var levels = [
	{
		"rows": 10,
		"cols": 10,
		"player1_start": Vector2(1, 9),
		"player2_start": Vector2(0, 9),
		"number_of_mines": 6
	},
	{
		"rows": 20,
		"cols": 20,
		"player1_start": Vector2(1, 19),
		"player2_start": Vector2(2, 19),
		"number_of_mines": 50
	},
]

var active_level_index = 0
var initialPathNoise = OpenSimplexNoise.new()
var active_level

var mapData = [];
var astar = AStar2D.new()

var revealed = []
var not_sure = []
var monster_markers = []
var is_game_over = false

func _ready():
	randomize()
	is_game_over = false
	initialPathNoise.octaves = 2
	initialPathNoise.persistence = 0.8
	initialPathNoise.period = 10
	load_level(0)
	player1.set_meta("name", "player_1")
	player2.set_meta("name", "player_2")
	player1.set_role("tank")
	player2.set_role("scout")

func load_level(index):
	player1.set_active(true)
	player2.set_active(false)
	player2.enable()

	active_level_index = index
	active_level = levels[active_level_index]

	$Hud.set_hidden(active_level.cols * active_level.rows - active_level.number_of_mines)
	$Hud.set_monsters(active_level.number_of_mines)
	$Hud.set_revealed(0)

	mapData = []
	astar = AStar2D.new()

	revealed = []
	not_sure = []
	monster_markers = []

	# prepare arrays
	for i in active_level.rows:
		revealed.append([])
		not_sure.append([])
		monster_markers.append([])
		for j in active_level.cols:
			revealed[i].append(false)
			not_sure[i].append(false)
			monster_markers[i].append(false)
	
	for i in active_level.rows:
		for j in active_level.cols:
			map.set_cellv(Vector2(i, j), 0)

	# spawn player
	generate_map()

	player1.position = active_level.player1_start * 16;
	camera.position = player1.position
	open_map(active_level.player1_start * 16)
	player2.position = active_level.player2_start * 16;
	open_map(active_level.player2_start * 16)
	update_hud()

	for i in active_level.cols:
		for j in active_level.rows:
			if !revealed[i][j]:
				continue

			var cell = mapData[j][i]
			if (0 < cell && cell < 6):
				map.set_cell(i, j, 7)

	for i in 3:
		for j in 3:
			var x = round(player2.position.x / 16) + j - 1
			var y = round(player2.position.y / 16) + i - 1

			if x < 0 || y < 0 || x > active_level.cols - 1 || y > active_level.rows - 1:
				continue

			if !revealed[x][y]:
				continue

			if (0 < mapData[y][x] && mapData[y][x] < 6):
				map.set_cell(x, y, mapData[y][x])


func _process(_delta):
	if (is_game_over):
		return;

	var world_mouse_position = get_global_mouse_position()
	var new_cursor_marker_position = world_mouse_position.snapped(Vector2(16, 16))
	cursorMarker.position = new_cursor_marker_position - Vector2(8, 8)

	if Input.is_action_just_pressed("ui_swap"):
		toggle_active_player()

func _input(event):
	if event is InputEventMouseButton && event.pressed:
		if (event.button_index == 1):
			handle_on_mouse_click(cursorMarker.position + Vector2(8, 8));
			if check_win_condition():
				end_level()
		if (event.button_index == 2):
			handle_on_right_click(cursorMarker.position + Vector2(8, 8));
		update_hud()

func handle_on_mouse_click(marker_position):
	if !is_in_range(marker_position):
		return

	var currently_active_player = get_active_player()
	var map_tile_position = map.world_to_map(marker_position)
	var cell = map.get_cellv(map_tile_position)

	if cell == 7 || (0 < cell && cell < 6):
		move_player(marker_position)

	if (currently_active_player.role != "tank"):
		return

	if cell == 0:
		open_map(marker_position)
		var opened_cell = map.get_cellv(map_tile_position)
		if opened_cell == 6:
			game_over()

func handle_on_right_click(marker_position):
	var currently_active_player = get_active_player()
	if (currently_active_player.role != "scout"):
		return

	var map_tile_position = map.world_to_map(marker_position)
	var cell = map.get_cellv(map_tile_position)

	var x = marker_position.x / 16
	var y = marker_position.y / 16

	if cell == 0:
		map.set_cell(x, y, 6)
		monster_markers[x][y] = true

	if cell == 6:
		map.set_cell(x, y, 8)
		monster_markers[x][y] = false
		not_sure[x][y] = true

	if cell == 8:
		map.set_cell(x, y, 0)
		not_sure[x][y] = false

func toggle_active_player():
	if player2.disabled:
		return

	if active_player:
		active_player = 0
		camera.position = player1.position;
	else:
		active_player = 1
		camera.position = player2.position;

	player1.set_active(!active_player)
	player2.set_active(active_player)

func move_player(new_position):
	var player = get_active_player()
	camera.position = new_position
	player.move(new_position)

	if player.role != "scout":
		return

	for i in active_level.cols:
		for j in active_level.rows:
			if !revealed[i][j]:
				continue

			var cell = mapData[j][i]
			if (0 < cell && cell < 6):
				map.set_cell(i, j, 7)

	for i in 3:
		for j in 3:
			var x = round(new_position.x / 16) + j - 1
			var y = round(new_position.y / 16) + i - 1

			if x < 0 || y < 0 || x > active_level.cols - 1 || y > active_level.rows - 1:
				continue

			if !revealed[x][y]:
				continue

			if (0 < mapData[y][x] && mapData[y][x] < 6):
				map.set_cell(x, y, mapData[y][x])

func check_win_condition():
	var count = 0
	for i in active_level.rows:
		for j in active_level.cols:
			if (revealed[j][i]):
				count = count + 1

	if count == active_level.rows * active_level.cols - active_level.number_of_mines:
		return true

	return false

func get_active_player():
	if active_player:
		return player2

	return player1

func is_in_range(new_position):
	var player = get_active_player()
	var player_range = player.position - new_position

	return abs(player_range.x) <= 16 && abs(player_range.y) <= 16

func open_map(marker_position):
	var x = marker_position.x / 16
	var y = marker_position.y / 16

	if x < 0 || y < 0 || x > active_level.cols - 1 || y > active_level.rows - 1:
		return

	if revealed[x][y]:
		return

	if not_sure[x][y]:
		return

	revealed[x][y] = true 
	var cell = mapData[y][x]
	if !cell:
		cell = 7

	map.set_cellv(Vector2(x, y), cell)

	if cell == 7:
		for i in 3:
			for j in 3:
				if !(i == 0 && j == 0):
					open_map(Vector2(marker_position.x + (j - 1) * 16, marker_position.y + (i - 1) * 16))

func generate_map():
	# generate empty array
	for i in active_level.rows:
		mapData.append([])
		for j in active_level.cols:
			mapData[i].append(-1)

	var number_of_mines = active_level.number_of_mines

	while(number_of_mines > 0):
		var x = randi() % active_level.cols;
		var y = randi() % active_level.rows;
		if (mapData[y][x] == -1):
			number_of_mines = number_of_mines - 1
			mapData[y][x] = 6
	
	for i in active_level.rows:
		for j in active_level.cols:
			if mapData[i][j] == 6 || mapData[i][j] > 6:
				continue

			# for each cell count mines around it
			var value = count_around(i, j)
			mapData[i][j] = value


func count_around(x, y):
	var counter = 0
	for i in 3:
		for j in 3:
			var x_pos = j - 1 + x
			var y_pos = i - 1 + y

			if x_pos < 0 || y_pos < 0 || x_pos > active_level.cols - 1 || y_pos > active_level.rows - 1:
				continue

			if (mapData[x_pos][y_pos] == 6):
				counter = counter + 1
				
	return counter

func game_over():
	$"/root/SceneTransition".change_scene()
	yield($"/root/SceneTransition", "scene_hidden")
	assert(get_tree().change_scene("res://Scenes/GameOverScene.tscn") == OK)

func end_level():
	$"/root/SceneTransition".change_scene()
	yield($"/root/SceneTransition", "scene_hidden")
	if active_level_index + 1 == levels.size():
		assert(get_tree().change_scene("res://Scenes/EndGame.tscn") == OK)
		return

	load_level(active_level_index + 1)

func update_hud():
	var count = 0
	var markers_count = 0

	for i in active_level.rows:
		for j in active_level.cols:
			if (revealed[j][i]):
				count = count + 1
			if (monster_markers[j][i]):
				markers_count = markers_count + 1

	$Hud.set_revealed(count)
	$Hud.set_monsters(active_level.number_of_mines - markers_count)



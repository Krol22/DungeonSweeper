extends Node2D

onready var cursorMarker = $CursorMarker;
onready var player1 = $Player;
onready var player2 = $Player2;
onready var camera = $Camera2D;
onready var map = $Map;

var active_player = 0

func _ready():
	load_level()
	pass

func _process(_delta):
	var world_mouse_position = get_global_mouse_position()
	var new_cursor_marker_position = world_mouse_position.snapped(Vector2(16, 16))
	cursorMarker.position = new_cursor_marker_position - Vector2(8, 8)

	if Input.is_action_just_pressed("ui_swap"):
		toggle_active_player()

func _input(event):
	if event is InputEventMouseButton && event.pressed:
		var current_marker_position = get_global_mouse_position().snapped(Vector2(16, 16))
		handle_on_mouse_click(current_marker_position);

func handle_on_mouse_click(marker_position):
	var map_tile_position = map.world_to_map(marker_position)
	var cell = map.get_cellv(map_tile_position)

	if cell == 7 || (0 < cell && cell < 6):
		move_player(marker_position)

	print(cell)

func load_level():
	player1.set_active(true)
	player2.set_active(false)

func toggle_active_player():
	if active_player:
		active_player = 0
		camera.position = player1.position;
	else:
		active_player = 1
		camera.position = player2.position;

	player1.set_active(!active_player)
	player2.set_active(active_player)

func move_player(new_position):
	if !is_in_range(new_position):
		return

	var player = get_active_player()
	player.position = new_position
	camera.position = new_position

func get_active_player():
	if active_player:
		return player2

	return player1

func is_in_range(new_position):
	var player = get_active_player()
	var player_range = player.position - new_position

	return abs(player_range.x) <= 16 && abs(player_range.y) <= 16

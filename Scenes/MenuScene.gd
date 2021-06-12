extends Control

onready var play_button = $MarginContainer/VBoxContainer/MarginContainer/CenterContainer/TextureButton
onready var how_to_button = $MarginContainer/VBoxContainer/MarginContainer2/CenterContainer/TextureButton

func _ready():
	Global.last_scene = "res://Scenes/MenuScene.tscn"

func _on_play_pressed():
	$"/root/SceneTransition".change_scene()
	$"/root/ButtonPlayer".play()
	yield($"/root/SceneTransition", "scene_hidden")
	assert(get_tree().change_scene("res://Scenes/MainScene.tscn") == OK)

func _on_how_to_pressed():
	$"/root/SceneTransition".change_scene()
	$"/root/ButtonPlayer".play()
	yield($"/root/SceneTransition", "scene_hidden")
	assert(get_tree().change_scene("res://Scenes/HowToScene.tscn") == OK)

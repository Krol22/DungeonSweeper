extends Control

onready var play_button = $MarginContainer/VBoxContainer/MarginContainer/CenterContainer/TextureButton
onready var how_to_button = $MarginContainer/VBoxContainer/MarginContainer2/CenterContainer/TextureButton

func _on_play_pressed():
	$"/root/SceneTransition".change_scene()
	yield($"/root/SceneTransition", "scene_hidden")
	assert(get_tree().change_scene("res://Scenes/MainScene.tscn") == OK)

func _on_how_to_pressed():
	print("pressed 2")

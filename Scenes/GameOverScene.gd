extends MarginContainer

func _ready():
	Global.last_scene = "res://Scenes/GameOverScene.tscn"

func _on_restart_pressed():
	$"/root/SceneTransition".change_scene()
	$"/root/ButtonPlayer".play()
	yield($"/root/SceneTransition", "scene_hidden")
	assert(get_tree().change_scene("res://Scenes/MainScene.tscn") == OK)

func _on_how_to_pressed():
	$"/root/SceneTransition".change_scene()
	$"/root/ButtonPlayer".play()
	yield($"/root/SceneTransition", "scene_hidden")
	assert(get_tree().change_scene("res://Scenes/HowToScene.tscn") == OK)

func _on_exit_pressed():
	$"/root/SceneTransition".change_scene()
	$"/root/ButtonPlayer".play()
	yield($"/root/SceneTransition", "scene_hidden")
	get_tree().quit()

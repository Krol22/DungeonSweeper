extends Control

func _on_back_pressed():
	$"/root/SceneTransition".change_scene()
	yield($"/root/SceneTransition", "scene_hidden")
	$"/root/ButtonPlayer".play()
	assert(get_tree().change_scene(Global.last_scene) == OK)

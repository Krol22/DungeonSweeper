extends CanvasLayer

signal scene_hidden
signal scene_active

func _ready():
	$ColorRect.anchor_left = -1
	$ColorRect.anchor_right = 0

func change_scene(delay = 0.5):
	$ColorRect.anchor_left = -1
	$ColorRect.anchor_right = 0
	$AnimationPlayer.play("end_scene")
	yield($AnimationPlayer, "animation_finished")
	emit_signal("scene_hidden")
	yield(get_tree().create_timer(delay), "timeout")	
	$AnimationPlayer.play("start_scene")
	yield($AnimationPlayer, "animation_finished")
	emit_signal("scene_active")

func start_scene(delay = 0.2):
	$ColorRect.anchor_left = 0
	$ColorRect.anchor_right = 1
	yield(get_tree().create_timer(delay), "timeout")
	$AnimationPlayer.play("start_scene")
	emit_signal("scene_active")

func hide_scene():
	$ColorRect.anchor_left = 0 
	$ColorRect.anchor_right = 1

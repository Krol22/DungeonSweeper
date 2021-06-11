extends Area2D

var active = false
onready var activityIndicator = $ActivityIndicator
onready var animationPlayer = $AnimationPlayer

func _ready():
	activityIndicator.visible = false
	animationPlayer.play("Idle")
	pass # Replace with function body.


func set_active(is_active):
	active = is_active
	activityIndicator.visible = active
	


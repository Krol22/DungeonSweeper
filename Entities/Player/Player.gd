extends Area2D

var active = false
var disabled = false

onready var activityIndicator = $ActivityIndicator
onready var animationPlayer = $AnimationPlayer
onready var animatedSprite = $AnimatedSprite
onready var moveTween = $MoveTween
onready var audioPlayer = $AudioStreamPlayer2D

var role

func _ready():
	activityIndicator.visible = false
	animationPlayer.play("Idle")

func set_active(is_active):
	active = is_active
	activityIndicator.visible = active

func set_role(new_role):
	if new_role == "scout":
		animatedSprite.play("idle-dark")
	role = new_role

func move(new_position):
	var difference = (new_position - position).normalized()
	animatedSprite.flip_h = difference.x < 0

	moveTween.interpolate_property(
		self,
		"position",
		position,
		new_position,
		1.0/10,
		Tween.TRANS_LINEAR,
		Tween.EASE_OUT_IN
	)

	audioPlayer.play()
	moveTween.start()
	
func _on_area_entered(_area):
	pass

func disable():
	disabled = true
	self.visible = false

func enable():
	disabled = false
	self.visible = true

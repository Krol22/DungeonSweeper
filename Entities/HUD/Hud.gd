extends CanvasLayer

onready var hidden_label = $MarginContainer/HBoxContainer/Hidden
onready var revealed_label = $MarginContainer/HBoxContainer/Revealed
onready var monsters_label = $MarginContainer/HBoxContainer2/Monsters

func _ready():
	pass # Replace with function body.

func set_hidden(new_progress):
	hidden_label.text = String(new_progress)

func set_revealed(new_revealed):
	revealed_label.text = String(new_revealed)

func set_monsters(new_monsters):
	monsters_label.text = String(new_monsters)

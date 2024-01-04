extends Node2D

onready var progressBar = $forground

# Called when the node enters the scene tree for the first time.
func _ready():
	pass

func updateBar(percent):
	progressBar.rect_size = Vector2(50*percent, 10)

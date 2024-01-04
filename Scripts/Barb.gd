extends StaticBody2D

var lineAngle

func _ready():
	if Perks.barbDamage == 0:
		collision_layer = 2




extends Area2D

var vector
var damage
var duration
var summonDamage = 1

var hitsFlying:bool = false

var hit = []

var piercing:bool = false

func _ready():
	pass
	
func _process(delta):
	position += vector
	
	duration -= delta
	if duration <= 0:
		queue_free()



func _on_CannonBall_area_entered(area):
	if not area in hit and not area.dead and ((area.isFlying and hitsFlying) or not area.isFlying):
		area.takeDamage(damage*Perks.physicalDamageMult*summonDamage)
		hit.append(area)
		if not piercing:
			queue_free()

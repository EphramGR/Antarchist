extends Area2D

var positionA
var positionB
var positionC

var GRAVITY = 19.6 * 4
var t = 0.0
var duration = 5.0
var targetsHit = []
var velocity
var despawnTime
var pierceReduction

var damage
var piercing
var hitsFlying:bool = false

var critChance:float
var camoRemover:bool
var critMultiplier

func _process(delta):
	if t > 1:
		velocity.y += GRAVITY * delta
		position += velocity/16
		rotation = velocity.angle()
		
		despawnTime -= delta
		
		if despawnTime <= 0:
			queue_free()
	else:
		t += delta / duration
		var q0 = positionA.linear_interpolate(positionC, min(t, 1.0))
		var q1 = positionC.linear_interpolate(positionB, min(t, 1.0))
		position = q0.linear_interpolate(q1, min(t, 1.0))

		velocity = q1 - q0

		rotation = velocity.angle()
	
	
		


func _on_Arrow_area_entered(area):
	if not area in targetsHit and not area.dead and ((area.isFlying and hitsFlying) or not area.isFlying):
		piercing -= 1
		
		if rand_range(0,1) < critChance:
			area.takeDamage(damage*critMultiplier*Perks.physicalDamageMult)
			if camoRemover:
				area.isCamo = false
		else:
			area.takeDamage(damage*Perks.physicalDamageMult)
		
		if piercing <= 0:
			queue_free()
			return
		targetsHit.append(area)
		damage -= damage*pierceReduction

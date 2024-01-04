extends Area2D

#logic
var target
var velocity
var lastDistance = INF

#settings
var damage
var effectDuration
var effectChance
var hitsFlying:bool = false

var isSplash
var hit = []

const SPINSPEED = 5

func _ready():
	pass
	
func _process(delta):
	global_position += velocity * delta
	rotation -= delta * SPINSPEED
	
	var currentDistance = global_position.distance_squared_to(target)
	
	if lastDistance < currentDistance:
		queue_free()
	else:
		lastDistance = currentDistance
	

	


func _on_Vortex_area_entered(area):
	if not area in hit and ((area.isFlying and hitsFlying) or not area.isFlying) and not area.dead:
		var roll = rand_range(0,1)
		if roll <= effectChance:
			area.confuse(effectDuration*Perks.confusionDurationMult)
			
		area.takeDamage(damage*Perks.elementalDamageMult)
		hit.append(area)
		
		if not isSplash:
			queue_free()
		
		
		
		

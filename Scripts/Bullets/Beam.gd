extends Sprite

var tower:Object

var target:Object

var time:float = 0
var index:int
const moveSpeed = -300

var lastShotTime = 0

var RANGE

var damage
var tickRate
var damageCap
var chargeTime
var numCharges
var killReset = true
var rangeReset = true
var currentDamage

func _ready():
	pass
	
func _process(delta:float) -> void:
	time += delta
	if not is_instance_valid(tower):
		queue_free()
	elif not is_instance_valid(target):
		tower.activeTargets[index] = null
		queue_free()
	else:
		var distanceToTarget = target.global_position.distance_to(tower.global_position)
		if distanceToTarget > RANGE:
			tower.activeTargets[index] = null
			queue_free()
			if not rangeReset:
				tower.continueTime[index] = time
				tower.frameHold[index] = true
			
		else:
			updateSprite(distanceToTarget)
			
			if TimeScaler.time() - lastShotTime > tickRate:
				var power = time*chargeTime
				
				if  power > numCharges:
					currentDamage = damageCap
					
				elif power < 0:
					currentDamage = damage
					
				else:
					currentDamage = pow(damage, power)
					
				target.takeDamage(currentDamage*Perks.elementalDamageMult)
				if target.dead:
					queue_free()
					tower.activeTargets[index] = null
					
					if not killReset:
						tower.continueTime[index] = time
						tower.frameHold[index] = true
					
				lastShotTime = TimeScaler.time()
				
				

func updateSprite(distanceToTarget: float):
	global_position = tower.shootPos.global_position + (Vector2(cos(rotation), sin(rotation)).normalized() * distanceToTarget/2)
	var m = max((time*chargeTime)/numCharges * 7, 0.75)
	modulate = Color(m,m,m)
	var s = max((time*chargeTime)/numCharges * 1.3, 0.25)
	scale = Vector2(s,s)
	region_rect =  Rect2(time * moveSpeed, 0, distanceToTarget/s, 14)
	rotation = atan2((target.global_position.y - tower.shootPos.global_position.y), (target.global_position.x -  tower.shootPos.global_position.x))
	#took out /s in each segment of rotation without testing
	visible = true
	

extends Node2D

export(Gradient) var poisonColor
export(Gradient) var iceColor
export(Gradient) var bothColor
export(Gradient) var tempColor

#references
var target
var tower
onready var particles = [get_node("CPUParticles2D")]
#onready var collisionShape = get_node("CollisionShape2D")

const collision = preload("res://Scenes/FlameCollision.tscn")

#logic
var lastShotTime = 0
var touchingAnts = []
var unlock = false
onready var fakePos = tower.global_position
var lastCollisionTime = 0

#setings
var damage
var RANGE #sqr
var tickRate
var spread
var burnDuration
var slow
var poison


func _ready() -> void:
	for particle in particles:
		particle.emitting = false
	updateParticlePosition(tower.global_position)
	
func _process(delta:float) -> void:
	if target != null and unlock:

		if not is_instance_valid(target) or target.dead:
			tower.target = null
			target = null
			toggle()
			tower.toggleSound(false)
		else:
			var distanceToTarget = target.global_position.distance_squared_to(tower.global_position)
			if distanceToTarget > RANGE:
				tower.target = null
				target = null
				toggle()
				tower.toggleSound(false)
				
			else:
				rotateTowards()
					
					
	if TimeScaler.time() - lastShotTime > tickRate:
		var remove = []
		for i in range(touchingAnts.size()):
			if is_instance_valid(touchingAnts[i]):
				if ((touchingAnts[i].isFlying and tower.hitsFlying) or not touchingAnts[i].isFlying):
					touchingAnts[i].takeDamage(damage*Perks.elementalDamageMult)
					
					if slow or poison:
						if slow:
							touchingAnts[i].slow(burnDuration*Perks.slowDurationMult)
						if poison:
							touchingAnts[i].poision(burnDuration*Perks.poisonDurationMult)
							
					else:
						touchingAnts[i].burn(burnDuration*Perks.fireDurationMult)
			else:
				remove.append(touchingAnts[i])
				
		for i in range(remove.size()):
			touchingAnts.erase(remove[i])
			
		if touchingAnts.size() > 0:
			lastShotTime = TimeScaler.time()
		
	if particles[0].emitting and TimeScaler.time()-lastCollisionTime>tickRate/2:
		createCollision()
		lastCollisionTime = TimeScaler.time()

func toggle() -> void:
	for particle in particles:
		particle.emitting = not particle.emitting 

func rotateTowards() -> void:
	var direction = (target.global_position - fakePos).normalized()
	
	for i in range(particles.size()):
		var particle = particles[i]
		
		if i == 0:
			particle.gravity = direction * 100
			particle.direction = direction
		elif i == 1:
			particle.gravity = -direction * 100
			particle.direction = -direction
		elif i == 2:
			var direction2 = Vector2(-direction.y, direction.x)
			particle.gravity = direction2 * 100
			particle.direction = direction2
		else:
			var direction2 = Vector2(direction.y, -direction.x)
			particle.gravity = direction2 * 100
			particle.direction = direction2
	
func updateUpgrades():
	for particle in particles:
		if slow:
			if slow and poison:
				particle.color_ramp = bothColor
			else:
				particle.color_ramp = iceColor
		
		elif poison:
			particle.color_ramp = poisonColor
			
			
		particle.spread = spread


func _on_Flame_area_entered(area):
	if not area in touchingAnts:
		touchingAnts.append(area)


func _on_Flame_area_exited(area):
	if area in touchingAnts:
		touchingAnts.erase(area)

func updateParticlePosition(newPos:Vector2):
	for particle in particles:
		particle.set_emission_points([newPos])
	fakePos = newPos
	
func createCollision():
	for i in range(particles.size()):
		var collisionInstance = collision.instance()
		collisionInstance.z_index = 4
		collisionInstance.get_node("CollisionShape").num = i
		
		add_child(collisionInstance)

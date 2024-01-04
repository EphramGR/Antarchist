extends Area2D

#references
var target
var tower
onready var particle = get_node("CPUParticles2D")
onready var collisionShape = get_node("CollisionShape2D")

var touchingAnts = []

#logic
var lastShotTime = 0

#settings
var damage
var effectDuration
var freeze = false 
var weaken = false
var radial = false
var fireRate
var hitsFlying:bool = false

func _ready() -> void:
	tower = get_parent()
	particle.emitting = false
	
	
func _process(delta:float) -> void:
	if not tower.isInHand:
		if TimeScaler.time() - lastShotTime > fireRate:
			shoot()
		
func _physics_process(delta:float)->void:
	if radial:
		slowAll()
		
func slowAll()->void:
	for i in range(touchingAnts.size()):
		if is_instance_valid(touchingAnts[i]):
			if not touchingAnts[i].dead and touchingAnts[i].slowTime <= 0:
				touchingAnts[i].slow(0.02*Perks.slowDurationMult)


func shoot()->void:
	var validTarget = false
	var flagForRemove = []
	
	for i in range(touchingAnts.size()):
		if is_instance_valid(touchingAnts[i]) and ((touchingAnts[i].isFlying and hitsFlying) or not touchingAnts[i].isFlying):
			if touchingAnts[i].dead:
				flagForRemove.append(touchingAnts[i])
			else:
				validTarget = true
				touchingAnts[i].takeDamage(damage*Perks.elementalDamageMult)
				if freeze or weaken or radial:
					if freeze:
						touchingAnts[i].freeze(effectDuration*Perks.freezeDurationMult)
					if weaken:
						touchingAnts[i].weaken(effectDuration*Perks.weakenDurationMult)
				else:
					touchingAnts[i].slow(effectDuration*Perks.slowDurationMult)
				
	if validTarget:
		particle.emitting = false
		particle.emitting = true
		lastShotTime = TimeScaler.time()
		tower.playSound()
		
	for i in range(flagForRemove.size()):
		touchingAnts.erase(flagForRemove[i])
	

func _on_Ice_area_entered(area):
	if not area.dead:
		touchingAnts.append(area)


func _on_Ice_area_exited(area):
	if not area.dead:
		touchingAnts.erase(area)
		
func updateRange(newRange:float):
	scale = Vector2.ONE * newRange/40

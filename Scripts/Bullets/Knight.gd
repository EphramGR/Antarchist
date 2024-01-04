extends Sprite

#references
var tower
var target = null
var isNecro = false
var lifeTime = null
var degradePerSec = null

#logic
enum STATE {WANDER, IDLE, PURSUE}
var currentState = STATE.WANDER
var nextDir = null
var nextPos = null
var closeEnoughRange = 10 #sqr

var idleTime = 0
const minIdleTime = 3
const maxIdleTime = 15

var lastAttackTime = 0
var takeDamage
var wizard = false
var necro = false


var showHealthBar = false
var healthbarDuration = 0
var maxHealthBarDuration = 3
onready var MAX_BAR_WIDTH = texture.get_width()
onready var bar_height = texture.get_height() / 5

#settings
var spawnHealth
onready var MAXHEALTH = spawnHealth
var spawnDamage
var spawnDamageTaken
var spawnSightRange
onready var sightRange = spawnSightRange * spawnSightRange
const attackRange = 20 #sqr
var spawnSpeed
var spawnAttackSpeed

onready var audioPlayer = get_node("AudioStreamPlayer2D")

func _ready():
	if isNecro:
		degradePerSec = MAXHEALTH/lifeTime
		
func playSound():
	audioPlayer.volume_db = linear2db(Perks.shootVolume)

	audioPlayer.play()
	
func _process(delta:float):
	if currentState == STATE.WANDER:
		handleWander(delta)
	elif currentState == STATE.IDLE:
		handleIdle(delta)
		
	if currentState == STATE.PURSUE:
		handlePursue(delta)
	else:
		lookForTarget()
		
	if isNecro:
		showHealthBar = true
		spawnHealth -= degradePerSec * delta
		healthbarDuration = max(healthbarDuration, 1)
		if spawnHealth <= 0:
			die()
		
	if showHealthBar:
		healthbarDuration -= delta
		update()
		
		
func handleWander(delta:float):
	if nextPos == null:
		nextPos = tower.getRandomPointInRange() + tower.global_position
		nextDir = (nextPos - global_position).normalized() * spawnSpeed
		if nextDir.x >= 0:
			flip_h = false
		else:
			flip_h = true
		
	if global_position.distance_squared_to(nextPos) <= closeEnoughRange:
		currentState = STATE.IDLE
		idleTime = rand_range(minIdleTime, maxIdleTime)
		nextPos = null
		return
	global_position += nextDir*delta
	
func handleIdle(delta:float):
	idleTime -= delta
	if idleTime <= 0:
		currentState = STATE.WANDER
	
func handlePursue(delta:float):
	if not is_instance_valid(target) or target.dead:
		currentState = STATE.WANDER
		nextPos = null
	
	elif wizard or global_position.distance_squared_to(target.global_position) <= attackRange:
		if TimeScaler.time() - lastAttackTime > spawnAttackSpeed/ Perks.firerateMultiplier:
			var mult
			if wizard:
				mult = Perks.elementalDamageMult
			else:
				mult = Perks.physicalDamageMult
			target.takeDamage(spawnDamage*mult)
			lastAttackTime = TimeScaler.time()
			takeDamage = true
			playSound()
			
			if necro:
				target.necro(tower)
	else:
		var moveDirection = (target.global_position-global_position).normalized()
		
		if moveDirection.x >= 0:
			flip_h = false
		else:
			flip_h = true
		
		global_position += moveDirection*delta * spawnSpeed * 1.75
		
	if not wizard and takeDamage and TimeScaler.time() - lastAttackTime > spawnAttackSpeed/2:
		takeDamage(spawnDamageTaken)
		takeDamage = false
		if spawnHealth <= 0:
			die()
	
func lookForTarget():
	target = getTarget()
	if target != null:
		currentState = STATE.PURSUE


func getTarget():
	var ants = get_tree().get_nodes_in_group("Ants")
	var comparatorAndTarget = [null, null]
	
	for ant in ants:
		if not ant.dead and ((ant.isCamo and tower.seesCamo) or not ant.isCamo) and ((ant.isFlying and tower.hitsFlying) or not ant.isFlying):
			var distance = global_position.distance_squared_to(ant.global_position)
			
			if distance <= sightRange:
				compareTarget(comparatorAndTarget, distance, ant)
	
	return comparatorAndTarget[1]

func compareTarget(comparatorAndTarget:Array, distance:float, newAnt:Object):
	if comparatorAndTarget[1] == null:
		comparatorAndTarget[1] = newAnt
		if tower.targetType == tower.TARGET.closest or tower.targetType == tower.TARGET.farthest:
			comparatorAndTarget[0] = distance
			
		elif tower.targetType == tower.TARGET.closestToDestination or tower.targetType == tower.TARGET.farthestFromDestination:
			if newAnt.currentState == newAnt.State.SearchingForFood:
				comparatorAndTarget[0] = newAnt.global_position.distance_squared_to(newAnt.colony.base.global_position)
			else:
				comparatorAndTarget[0] = newAnt.global_position.distance_squared_to(newAnt.colony.global_position)
		#change if you add more targeting options!
		else:
			comparatorAndTarget[0] = newAnt.health
			
	else:
		if tower.targetType == tower.TARGET.closest:
			if distance < comparatorAndTarget[0]:
				comparatorAndTarget[0] = distance
				comparatorAndTarget[1] = newAnt
				
		elif tower.targetType == tower.TARGET.farthest:
			if distance > comparatorAndTarget[0]:
				comparatorAndTarget[0] = distance
				comparatorAndTarget[1] = newAnt
				
		elif tower.targetType == tower.TARGET.strongest:
			if newAnt.health > comparatorAndTarget[0]:
				comparatorAndTarget[0] = newAnt.health
				comparatorAndTarget[1] = newAnt
			
		elif tower.targetType == tower.TARGET.weakest:
			if newAnt.health < comparatorAndTarget[0]:
				comparatorAndTarget[0] = newAnt.health
				comparatorAndTarget[1] = newAnt
			
		#change if you add more targeting options!
		else:
			if newAnt.currentState == newAnt.State.SearchingForFood:
				distance = newAnt.global_position.distance_squared_to(newAnt.colony.base.global_position)
			else:
				distance = newAnt.global_position.distance_squared_to(newAnt.colony.global_position)
				
			if tower.targetType == tower.TARGET.closestToDestination:
				if distance < comparatorAndTarget[0]:
					comparatorAndTarget[0] = distance
					comparatorAndTarget[1] = newAnt
					
			else:
				if distance > comparatorAndTarget[0]:
					comparatorAndTarget[0] = distance
					comparatorAndTarget[1] = newAnt

func takeDamage(amount:float):
	spawnHealth -= amount
	if spawnHealth > 0:
		showHealthBar = true
		healthbarDuration = maxHealthBarDuration
	else:
		die()

func die():
	if not isNecro:
		tower.currentSpawns.erase(self)
		if TimeScaler.time() - tower.lastSpawnTime > tower.spawnRate:
			tower.lastSpawnTime = TimeScaler.time()
	else:
		tower.necroSpawns.erase(self)
	queue_free()

func _draw():
	if healthbarDuration > 0:
		drawHealthBar()
	else:
		showHealthBar = false

func drawHealthBar():
	# Calculate health bar dimensions
	var duration = healthbarDuration/maxHealthBarDuration
	var health_percentage = spawnHealth/MAXHEALTH
	var bar_width = health_percentage * MAX_BAR_WIDTH

	# Calculate health bar position
	var bar_x = - bar_width / 2
	var bar_y = - 3*bar_height	

	# Draw health bar background
	draw_rect(Rect2(bar_x, bar_y, MAX_BAR_WIDTH, bar_height), Color(1,0,0,duration))

	# Draw filled health bar
	draw_rect(Rect2(bar_x, bar_y, bar_width, bar_height), Color(0,1,0,duration))

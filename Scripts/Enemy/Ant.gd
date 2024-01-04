extends Area2D

class_name Ant

onready var fireParticle = get_node("Fire")
onready var slowParticle = get_node("Slow")
onready var freezeParticle = get_node("Frozen")
onready var poisionParticle = get_node("ParticleGenerator")
onready var confuseParticles = get_node("Confuse")
onready var necroParticles = get_node("Necro")
onready var weakenParticles = get_node("Weaken")
onready var sickParticles = get_node("Sick")

const camoSprite = preload("res://Assets/Enemy/AntCamo.png")

enum State { SearchingForFood, ReturningHome }

var currentState

var currentVelocity :Vector2
var collisionAvoidForce :Vector2

var nextRandomSteerTime :float

var sensorData = [null, null, null] #float

var collectedFood #obj #can prob just be bool, and -1 hp from base

var lastPheromonePos :Vector2
var foodColliders
var pheromoneEntries
var colony #obj
var nextDirUpdateTime :float

var randomSteerForce :Vector2
var pheromoneSteerForce :Vector2

enum Antenna { None, Left, Right }
var lastAntennaCollision

var foodInSight :bool
var targetFood #obj
var deathTime :float
var turningAround = false
var turnAroundForce :Vector2
var turnAroundEndTime :float

var leftHomeTime :float
var leftFoodTime :float

#State
var currentForwardDir :Vector2
var currentPosition :Vector2
var colDst :float
var obstacleAvoidForce :Vector2
var obstacleForceResetTime :float
var antennaCollisionLastFrame :bool
var homePos :Vector2

var slowTurn = false
var lockSprite = false

var one80 = false
var counter = 0

var amountToSteal = 1

var showHealthBar = false
var healthbarDuration = 0
var maxHealthBarDuration = 3
onready var MAX_BAR_WIDTH = get_node("Sprite").texture.get_width()
onready var bar_height = get_node("Sprite").texture.get_height() / 5
onready var sprite = get_node("Sprite")

#Settings ## means not used
#combat
var health = 100
var MAXHEALTH = 100
#combat logic
var burnTime = 0
var poisionTime = 0
var lastBurnTime = 0
var lastPoisionTime = 0

var slowTime = 0
var slowSpeedMultiplier = 1
var freezeTime = 0
var isFreezeing = false
var lastFreezeTime = 0

var confusionTime = 0
var isConfused = false
var lastConfuseTime = 0

var necroTime = 0
var necroTower:Object = null

var weakenTime = 0

var sickTime = 0

var isCamo = false
var isFlying = false

var value = 15

var dead = false

var baseSpeedFactor:float = 1.1
var spawnNum
const spawnRadius = 10

#movment
var collisionAvoidSteerStrength= 5
var targetSteerStrength= 300 #was 3
var randomSteerStrength= 60 #was 0.6
var randomSteerMaxDuration= 2000
var dstBetweenMarkers= 25
var timeBetweenDirUpdate= 0.15 * 1000 
var collisionRadius= 0.15 #commented
var antennaDst= 0.25 #commented
var homingForce= 0 ##
#var lifetime= 60 * 1000 ##set by colony
var useHomeMarkers= 1##
var useFoodMarkers= 1##
var useDeath= 0 ##
var pheremoneRunOutTime= 15 * 1000 ##NOTUSED REAL SET BY COLONY
var pheromoneEvaporateTime= 60 * 1000 #30 seconds to evaporating inside ant #now set by colony
var maxPheromoneLifeTime #set by colony, max amount of time pheremones can live for
var minPheromoneLifeTime=0 #percent of max ^, how low it can degrade in ant before spawning
var pheromoneWeight= 1000
var perceptionRad#= 2.5 set by colony #sensorRadius. it is root of radius
var sensorSize= 0.75 ##
var sensorDst= 30
var sensorSpacing= 1 ##

const globalTurnDuration = 100 #ms
const turningAroundAccel = 800

var maxSpeed= 100 #80
const acceleration= 150 #30

var seaFood = false
const seaFoodAccel = 200

var slowSteerAccel= 400 #if editing this make sure to edit the one in turn function

var steerWeight = 1
var turnBackToPhero = 0

var leftSensorDir = Vector2(1,-5).normalized()
var rightSensorDir = Vector2(1,5).normalized()

var sensors = [(Vector2(1,0) * sensorDst), (leftSensorDir * sensorDst), (rightSensorDir * sensorDst)]

#hitbox shit
onready var hitbox = get_node("CollisionShape2D")
var hitboxRadius

var sightLine = 60

#for food/base
var rect_min
var rect_max
#for anthill
var rectMin
var rectMax

#Debug
var printer = false #change in colony not here
const visualizeSensors = false
const visualizeSightLine = false

const colonySize = 1.8 #1/n
var needsToCalcSize = true
var adjustedRectMin
var adjustedRectMax

func _ready():
	hitboxRadius = hitbox.shape.radius
	
	#lastPheromonePos = position
	currentState = State.SearchingForFood
	currentVelocity = currentForwardDir * maxSpeed

	homePos = position

	nextDirUpdateTime = rand_range(0.0,0.1) * timeBetweenDirUpdate
	colDst = collisionRadius / 2
	#deathTime = TimeScaler.antTime(baseSpeedFactor) + lifetime + rand_range(0, lifetime / 2)
	leftHomeTime = TimeScaler.antTime(baseSpeedFactor)
	
	
	
	if isCamo:
		sprite.texture = camoSprite
	elif printer:
		invertSprite(get_node("Sprite"))
		
	if dead:
		#remove_from_group("Ants")
		#get_node("CollisionShape2D").disabled = true
		set_deferred("monitorable", false)
		set_deferred("monitoring", false)
		disconnect("body_entered", self, "_on_Ant_body_entered")
		#collision_layer = 0
		#collision_mask = 0
		
	
func invertSprite(sprite):
	sprite.texture = load("res://Assets/Enemy/printer.png")




func _process(delta):
	delta *= baseSpeedFactor
	if printer:
		pass#print(burnTime)
		
	#if TimeScaler.antTime(baseSpeedFactor) > deathTime:
		#print("no time")
		#deathByTurret()
		#die()
		
	if showHealthBar:
		healthbarDuration -= delta
		
	handleStatus(delta)
	
	if not isConfused:
		HandlePheromonePlacement()
	HandleRandomSteering()

	if currentState == State.SearchingForFood:
		HandleSearchForFood()
	
	elif currentState == State.ReturningHome:
		HandleReturnHome()
	
	HandleMovement(delta)
	
	if isConfused:
		sprite.rotation -= PI
	
	update()
	
func handleStatus(delta:float) -> void:
	if burnTime > 0:
		if TimeScaler.antTime(baseSpeedFactor) - lastBurnTime > Perks.burnTickRate:
			takeDamage(MAXHEALTH*Perks.burnPercent, true) 
			lastBurnTime = TimeScaler.antTime(baseSpeedFactor)
			burnTime -= delta
			fireParticle.emitting = true
	else:
		fireParticle.emitting = false
		
	if poisionTime > 0:
		if TimeScaler.antTime(baseSpeedFactor) - lastPoisionTime > Perks.poisionTickRate:
			takeDamage(health*Perks.poisionPercent, true)
			lastPoisionTime = TimeScaler.antTime(baseSpeedFactor)
			poisionTime -= delta
			poisionParticle.on = true
			poisionParticle.visible = true
	else:
		poisionParticle.on = false
		poisionParticle.visible = false
	
		
	if slowTime > 0:
		slowSpeedMultiplier = Perks.slowPercent
		slowTime -= delta
		slowParticle.emitting = true
	else:
		slowParticle.emitting = false
		slowSpeedMultiplier = 1
		
	if freezeTime > 0:
		if not isFreezeing and TimeScaler.antTime(baseSpeedFactor) - lastFreezeTime > Perks.freezeImmunityDuration:
			isFreezeing = true
		
		if isFreezeing:
			slowSpeedMultiplier = 0
			freezeTime -= delta
			freezeParticle.visible = true
			
			if freezeTime <= 0:
				isFreezeing = false
				lastFreezeTime = TimeScaler.antTime(baseSpeedFactor)
				slowSpeedMultiplier = 1
				freezeParticle.visible = false
				
	else:
		freezeParticle.visible = false
		
		
	if confusionTime > 0:
		if not isConfused and TimeScaler.antTime(baseSpeedFactor) - lastConfuseTime > Perks.confusionImmunityDuration:
			isConfused = true
			confuseParticles.emitting = true
			flipState()
			
		if isConfused:
			confusionTime -= delta
			
			if confusionTime <= 0:
				isConfused = false
				lastConfuseTime = TimeScaler.antTime(baseSpeedFactor)
				confuseParticles.emitting = false
				flipState()
				
	if necroTime > 0:
		necroTime -= delta
		
		if necroTime <= 0:
			necroParticles.emitting = false
			
	if weakenTime > 0:
		weakenTime -= delta
		
		if weakenTime <= 0:
			weakenParticles.emitting = false
			
	if sickTime > 0:
		sickTime -= delta
		
		if sickTime <= 0:
			sickParticles.emitting = false
			
	
func flipState()->void:
	if currentState == State.ReturningHome:
		currentState = State.SearchingForFood
	else:
		currentState = State.ReturningHome
		
	currentForwardDir = -currentForwardDir
	currentVelocity = -currentVelocity
		
	
func HandlePheromonePlacement():
	#pheromones stored on colony dictionary Vector2 -> lifetime (sec?)
	if (position.distance_to(lastPheromonePos) > dstBetweenMarkers):
		if (currentState == State.SearchingForFood):
			#seeing the amount of time since home / pheremone evaporate time ratio, 
			#and subtracting from 1 to get inverse ratio
			#will always be less than 1 cause Time.time > left home time
			
			#basically calulates for weight before spawning pheromone 
			#so that if you are on a very long tedious journey, people wont follow u
			var t = 1 - (TimeScaler.antTime(baseSpeedFactor) - leftHomeTime) / pheromoneEvaporateTime
			t = max(t, minPheromoneLifeTime)
			if t > 0:
				colony.createHomeMarkerAt(position, [[TimeScaler.time() + (t *maxPheromoneLifeTime)], Vector2(cos(sprite.rotation), sin(sprite.rotation))])
				lastPheromonePos = position
				
		elif (currentState == State.ReturningHome):
			var t = 1 - (TimeScaler.antTime(baseSpeedFactor) - leftFoodTime) / pheromoneEvaporateTime
			t = max(t, minPheromoneLifeTime)
			
			if t > 0:
				colony.createFoodMarkerAt(position, [[TimeScaler.time() + (t *maxPheromoneLifeTime)], Vector2(cos(sprite.rotation), sin(sprite.rotation))])
				lastPheromonePos = position

func HandleRandomSteering():
		if (targetFood != null):
			randomSteerForce = Vector2.ZERO
			return


		if (TimeScaler.antTime(baseSpeedFactor) > nextRandomSteerTime):
			nextRandomSteerTime = TimeScaler.antTime(baseSpeedFactor) + rand_range(randomSteerMaxDuration / 3, randomSteerMaxDuration)
			randomSteerForce = GetRandomDir(currentForwardDir, 5) * randomSteerStrength

	
func HandleSearchForFood():		
	HandlePheromoneSteering()
	
	if printer:
		pass#print(State)#spammy be careful
	
	#targetting food???
	if hitFood():
		pass

	
func HandleReturnHome():

	hitColony()

	HandlePheromoneSteering()
		
func HandlePheromoneSteering():

	if (TimeScaler.antTime(baseSpeedFactor) > nextDirUpdateTime):


		pheromoneSteerForce = Vector2.ZERO
		var currentTime = TimeScaler.antTime(baseSpeedFactor)

		nextDirUpdateTime = currentTime + timeBetweenDirUpdate
		
		
		#there position in relation to themselves
		

		for i in range(3):

			sensorData[i] = 0
			var numPheromones = 0
			pheromoneEntries = []
			
			if (currentState == State.SearchingForFood):
				numPheromones = colony.GetNearFood(pheromoneEntries, getGlobalSensorPosition(sensors[i]))
			
			if (currentState == State.ReturningHome):
				numPheromones = colony.GetNearHome(pheromoneEntries, getGlobalSensorPosition(sensors[i]))
			
			#if printer and pheromoneEntries.size()>0: print(currentState, " ", pheromoneEntries.size())
			
			#wait it does do it based on time
			sensorData[i] = pheromoneEntries.duplicate()

		var centre = sensorData[0].size()
		var left = sensorData[1].size()
		var right = sensorData[2].size()

		if printer:
			pass#for i in range(3):
				#print(sensorData[i])

		#now it gets the average direction of all the pheromones, and goes opposite way 
		if (centre > left and centre > right):
			pheromoneSteerForce = calculateAverageVector(sensorData[0]) * pheromoneWeight * -1
		elif (left > right):
			pheromoneSteerForce = (calculateAverageVector(sensorData[1])* -1 + sensors[1].rotated(sprite.rotation).normalized()*turnBackToPhero).normalized() * pheromoneWeight#here
		elif (right > left):
			pheromoneSteerForce = (calculateAverageVector(sensorData[2])* -1 + sensors[1].rotated(sprite.rotation).normalized()*turnBackToPhero).normalized() * pheromoneWeight


func calculateAverageVector(vectors: Array) -> Vector2:
	var sum: Vector2 = Vector2.ZERO

	# Calculate the sum of all vectors
	for vector in vectors:
		sum += vector

	# Divide the sum by the number of vectors to get the average
	var count: int = vectors.size()
	var average: Vector2 = sum / count

	return average.normalized()

func getGlobalSensorPosition(sensorPosition: Vector2) -> Vector2:
	var globalPosition = sensorPosition.rotated(sprite.rotation) + position
	return globalPosition
	
	
func HandleMovement(delta):
	var steerForce = randomSteerForce + pheromoneSteerForce + obstacleAvoidForce


	if turningAround:
		steerForce += turnAroundForce * targetSteerStrength;
		if TimeScaler.antTime(baseSpeedFactor) > turnAroundEndTime:
			turningAround = false
			slowTurn = false
			lockSprite = false
			if one80:
				StartTurnAround2()
				counter += 1
				if counter == 4:
					one80 = false
					counter = 1
					
	elif not seaFood:
		if currentState == State.SearchingForFood:
			seafood2()
		elif currentState == State.ReturningHome:
			seahome2()
			
	if seaFood and currentState == State.ReturningHome:
		steerForce = colony.global_position - global_position 
		
	elif seaFood and currentState == State.SearchingForFood:
		steerForce = colony.base.global_position - global_position

	var desiredVelocity = steerForce.normalized() * maxSpeed * slowSpeedMultiplier
	SteerTowards(desiredVelocity, delta) #BOZO???HEREMAYBE

	currentForwardDir = currentVelocity.normalized()
	#var moveDst = currentVelocity.length() * delta
	#var desiredPos = currentPosition + currentVelocity * delta
	
	var moveDst = maxSpeed * slowSpeedMultiplier * delta
	var desiredPos = currentPosition + currentForwardDir * maxSpeed * slowSpeedMultiplier * delta

	#Some turinging around shit for collision, hitbox barb slowturn
	if not turningAround:
		var space_state = get_world_2d().direct_space_state
		var from_position = global_position
		var to_position = global_position + currentForwardDir * 40
		var result = space_state.intersect_ray(from_position, to_position, [], 2)  # Collision layer 2

		if result:
			var hit = result["position"]
			
			var reflectedVector = currentForwardDir.reflect(result["collider"].lineAngle.normalized())
			#will be small if barley turn, and big if big turn
			var angleDifference = (PI - abs(currentForwardDir.angle_to(reflectedVector)))/2
			
			var turnAccel = turningAroundAccel*angleDifference/PI
			
			#if coming strait on or perp
			if turnAccel > 385 or turnAccel < 90:
				StartTurnAround3(
				Vector2(-currentForwardDir.y, currentForwardDir.x), 
				200, 
				globalTurnDuration*6*0.5, 
				true, 
				turningAroundAccel*75,
				true
				)
			else:
			
				StartTurnAround3(
					reflectedVector, 
					200, 
					globalTurnDuration*6*(1-angleDifference/PI), 
					true, 
					turnAccel*1.5
				)
			
			#print(globalTurnDuration*6*(1-angleDifference/PI), " ", turningAroundAccel*angleDifference/PI)
			
				#print("turning")
				#desiredPos = hit - currentForwardDir * collisionRadius
		#this means they are outside the circle
		elif from_position.distance_squared_to(Vector2.ZERO) > colony.mapSize*colony.mapSize:
			if currentState == State.SearchingForFood:
				StartTurnAround(Vector2(global_position.y, -global_position.x), 200, false, globalTurnDuration*2, true)
			else:
				var turnAngle = global_position - colony.global_position
				StartTurnAround(Vector2(turnAngle.y, -turnAngle.x), 200, false, globalTurnDuration*2, true)
		#this means they are heading outside
		elif to_position.distance_squared_to(Vector2.ZERO) > colony.mapSize*colony.mapSize:
			if currentState == State.SearchingForFood:
				#reflects off of perp to the angle from center to it, since that would be the angle of inside of circle
				var circleEdgeAngle = Vector2(global_position.y, -global_position.x).normalized()
				StartTurnAround(currentForwardDir.reflect(circleEdgeAngle), 200, false, globalTurnDuration*2, true)
			else:
				#StartTurnAround(currentForwardDir.reflect((global_position - colony.global_position)), 200, false, globalTurnDuration*2, true)
				StartTurnAround(currentForwardDir.reflect((global_position - colony.global_position).normalized()), 200, false, globalTurnDuration*2, true)
	currentPosition = desiredPos

	# Set the position and rotation of your object
	position = currentPosition
	if not lockSprite and currentForwardDir.angle() != 0:
		sprite.rotation = currentForwardDir.angle()
	
func SteerTowards(desiredVelocity, delta):
	var steeringForce = desiredVelocity - currentVelocity


	var thisAcceleration
	
	#makes sure acceleration doesnt exceed settings accel
	if slowTurn:
		thisAcceleration = (steeringForce * slowSteerAccel).clamped(slowSteerAccel)
	elif turningAround:
		thisAcceleration = (steeringForce * turningAroundAccel).clamped(turningAroundAccel)
	elif seaFood:
		thisAcceleration = (steeringForce * seaFoodAccel).clamped(seaFoodAccel)
	else:
		thisAcceleration = (steeringForce * acceleration).clamped(acceleration)
	
	
	currentVelocity += thisAcceleration * delta;
	currentVelocity = currentVelocity.clamped(maxSpeed * slowSpeedMultiplier)
	
	
func StartTurnAround(returnDir: Vector2, randomStrength = 200, leftTurn = false, turnTimer = globalTurnDuration, slow = false, slowAccel = 225):
	turningAround = true
	slowTurn = slow
	slowSteerAccel = slowAccel
	turnAroundEndTime = TimeScaler.antTime(baseSpeedFactor) + turnTimer
	var perpAxis = Vector2(-returnDir.y, returnDir.x)
	if not leftTurn:
		turnAroundForce = returnDir + perpAxis * (rand_range(0.0, 0.1) - 0.5) * 2 * randomStrength
	else:
		turnAroundForce = returnDir - perpAxis * (rand_range(0.0, 0.1) - 0.5) * 2 * randomStrength
	#if printer:
	#print("turn")

#method overloading
func StartTurnAround2(leftTurn = false, randomStrength = 200):
		StartTurnAround(-currentForwardDir, randomStrength, leftTurn)
		
func StartTurnAround3(returnDir: Vector2, randomStrength = 200, turnTimer = globalTurnDuration, slow = false, slowAccel = 225, lock = false):
	lockSprite = lock
	if lockSprite and (returnDir).angle() != 0:
		sprite.rotation = (returnDir).angle()
	turningAround = true
	slowTurn = slow
	slowSteerAccel = slowAccel
	turnAroundEndTime = TimeScaler.antTime(baseSpeedFactor) + turnTimer
	turnAroundForce = -returnDir * (rand_range(0.0, 0.1) - 0.5) * 2 * randomStrength

		

#gets the smallest change out of 4 random directions (can change 4)
func GetRandomDir(referenceDir:Vector2, similarity = 4) -> Vector2:
		var smallestRandomDir = Vector2.ZERO;
		var change = -1
		for i in range(4):
			var randomDir = Vector2(rand_range(-1.0, 1.0), rand_range(-1.0, 1.0)).normalized()
			var dot = referenceDir.dot(randomDir)
			if (dot > change):
				change = dot
				smallestRandomDir = randomDir

		#if printer:
			#print(smallestRandomDir)
		return smallestRandomDir

		
func _draw():
	if visualizeSensors:
		if printer:
			pass#print(currentForwardDir)
		
		for i in range(3):
			draw_circle(sensors[i], perceptionRad, Color.gold)
			
	if visualizeSightLine:
		if seaFood:
			draw_circle(Vector2.ZERO, sightLine, Color.coral)
		else:
			draw_circle(Vector2.ZERO, sightLine, Color.aqua)
			
	if showHealthBar:
		if healthbarDuration > 0:
			drawHealthBar()
		else:
			showHealthBar = false
			
			
func drawHealthBar():
	# Calculate health bar dimensions
	var duration = healthbarDuration/maxHealthBarDuration
	var health_percentage = health/MAXHEALTH
	var bar_width = health_percentage * MAX_BAR_WIDTH

	# Calculate health bar position
	var bar_x = - bar_width / 2
	var bar_y = - 3*bar_height	

	# Draw health bar background
	draw_rect(Rect2(bar_x, bar_y, MAX_BAR_WIDTH, bar_height), Color(1,0,0,duration))

	# Draw filled health bar
	draw_rect(Rect2(bar_x, bar_y, bar_width, bar_height), Color(0,1,0,duration))
			
			
func hitFood():
	var hitboxPosition = hitbox.global_position

	var closestX = clamp(hitboxPosition.x, rect_min.x, rect_max.x)
	var closestY = clamp(hitboxPosition.y, rect_min.y, rect_max.y)

	var distanceX = hitboxPosition.x - closestX
	var distanceY = hitboxPosition.y - closestY

	var distanceSquared = distanceX * distanceX + distanceY * distanceY
	var hitboxRadiusSquared = hitboxRadius * hitboxRadius

	if distanceSquared <= hitboxRadiusSquared:
		if isConfused:
			isConfused = false
			lastConfuseTime = TimeScaler.antTime(baseSpeedFactor)
			confuseParticles.emitting = false
			flipState()
		else:
			currentState = State.ReturningHome
			seaFood = false
			takeFood()
			#if printer: print("turning")
			StartTurnAround2(true)
			leftFoodTime = TimeScaler.antTime(baseSpeedFactor)
			one80 = true
			return true
		
	return false

func hitColony():
	var hitboxPosition = hitbox.global_position

	if printer:
		pass  # print(rectMax, rectMin)
		
	if needsToCalcSize:
		actualColonyPos()
		needsToCalcSize = false

	var closestX = clamp(hitboxPosition.x, adjustedRectMin.x, adjustedRectMax.x)
	var closestY = clamp(hitboxPosition.y, adjustedRectMin.y, adjustedRectMax.y)

	var distanceX = hitboxPosition.x - closestX
	var distanceY = hitboxPosition.y - closestY

	var distanceSquared = distanceX * distanceX + distanceY * distanceY
	var hitboxRadiusSquared = hitboxRadius * hitboxRadius

	if distanceSquared <= hitboxRadiusSquared:
		#print("Home sweet home")
		if isConfused:
			isConfused = false
			lastConfuseTime = TimeScaler.antTime(baseSpeedFactor)
			confuseParticles.emitting = false
			flipState()
		else:
			madeItHome()
			die()
		
	
func actualColonyPos():
	var rectCenter = (rectMax + rectMin) / 2.0  # Calculate the center point of the original rectangle

	var halfWidth = (rectMax.x - rectMin.x) / (2.0 * colonySize)  # Calculate half the width of the adjusted rectangle
	var halfHeight = (rectMax.y - rectMin.y) / (2.0 * colonySize)  # Calculate half the height of the adjusted rectangle

	adjustedRectMin = rectCenter - Vector2(halfWidth, halfHeight)  # Calculate the adjusted minimum point
	adjustedRectMax = rectCenter + Vector2(halfWidth, halfHeight)  # Calculate the adjusted maximum point
	
func seafood2():
	var hitboxPosition = global_position

	var foodPos = colony.base.global_position
	
	if hitboxPosition.distance_squared_to(foodPos) <= sightLine * sightLine:
		seaFood = true
		
	
func seahome2():
	var hitboxPosition = global_position
	
	var closestX = clamp(hitboxPosition.x, rectMin.x, rectMax.x)
	var closestY = clamp(hitboxPosition.y, rectMin.y, rectMax.y)
	
	var distanceX = hitboxPosition.x - closestX
	var distanceY = hitboxPosition.y - closestY

	var distanceSquared = distanceX * distanceX + distanceY * distanceY
	var hitboxRadiusSquared = sightLine * sightLine * 0.8

	if distanceSquared <= hitboxRadiusSquared:
		seaFood = true


func deathByTurret():
	if not dead:
		if currentState == State.ReturningHome and spawnNum == null:
			colony.base.foodReturned(amountToSteal)

		if spawnNum != null:
			deathSpawn()
			
		visible = false
		
		if necroTime > 0:
			necroTower.spawnNecro(global_position)
			
		colony.addMoney(value*Perks.cashFromKillMult)
		dead = true
		if "Ants" in get_groups():
			remove_from_group("Ants")
		#get_node("CollisionShape2D").disabled = true
		set_deferred("monitorable", false)
		set_deferred("monitoring", false)
		disconnect("body_entered", self, "_on_Ant_body_entered")
	else:
		
		if is_in_group("Ants"):
			remove_from_group("Ants")
		
func deathSpawn():
	for i in range(spawnNum):
		var ant = 0
		if isCamo:
			if isFlying:
				ant = 3
			else:
				ant = 1
		elif isFlying:
			ant =2

		
		colony.spawnThisAntAt(ant,spawnNum,getRandomPointInRange(),currentState,currentForwardDir)
		
func getRandomPointInRange()->Vector2:
	var point:Vector2 = Vector2(rand_range(-1,1),rand_range(-1,1)).normalized()
	
	var distance:int = randi()%int(spawnRadius)
	
	
	return position + (point*distance)

func die():
	queue_free()
	colony.numDead += 1
	if printer:
		colony.printer = true
	#print("dead")
	
func madeItHome():
	if not dead:
		colony.base.foodStolen(amountToSteal)
	
func takeFood(): #maybe add return to food taken, and just camp if no food avalible
	if not dead:
		amountToSteal = colony.base.foodTaken(amountToSteal)
	
func body_entered(body):
	print(body)

func takeDamage(amount:float, isElement:bool=false):
	if isElement:
		if sickTime > 0:
			amount *= Perks.sickMultiplier
	elif weakenTime > 0:
		amount *= Perks.weakenMultiplier
	
	health -= amount
	if health > 0:
		showHealthBar = true
		healthbarDuration = maxHealthBarDuration
	else:
		deathByTurret()

func burn(burnDuration:float):
	burnTime = min(burnDuration + burnTime, Perks.maxBurnDuration)
	
func poision(poisionDuration:float):
	poisionTime = min(poisionDuration + poisionTime, Perks.maxPoisionDuration)

func slow(slowDuration:float):
	slowTime = min(slowTime + slowDuration, Perks.maxSlowDuration)
	
func freeze(freezeDuration:float):
	freezeTime = min(freezeTime + freezeDuration, Perks.maxFreezeDuration)

func confuse(confuseDuration:float):
	confusionTime = min(confusionTime + confuseDuration, Perks.maxConfusionDuration)
	
func necro(tower):
	if necroTime <= 0:
		necroParticles.emitting = true
	
	necroTime = Perks.maxNecroTime
	necroTower = tower
	
func weaken(weakenDuration:float):
	if weakenTime <= 0:
		weakenParticles.emitting = true
		
	weakenTime = min(weakenTime + weakenDuration, Perks.maxWeakenTime)
	
func sick(sickDuration:float):
	if sickTime <= 0:
		sickParticles.emitting = true
		
	sickTime = min(sickTime + sickDuration, Perks.maxSickTime)



"""
func handleScaleing():
	var color = getColorAt(global_position)
	
	if color == Color.white or (color == previousColour and rotation_degrees + 10 > previousRotation and rotation_degrees - 10 > previousRotation):
		return
	
	previousColour = color
	previousRotation = rotation_degrees
	
	sprite3D.setRotation(rotation, color)
	
	var texture = $Viewport.get_texture()
	sprite.texture = texture
	sprite.set_scale(Vector2(16.0 / texture.get_width(), 16.0 / texture.get_height()))
	
	
	
func getColorAt(coords: Vector2):
	var chunkIndex = game.getTouchingChunk(coords)
	#print(chunkIndex)
	
	if not chunkIndex in game.chunks:
		#print("doesnt exist")
		return Color.black
		
	var chunk = game.chunks[chunkIndex]
	
	var tileMap = chunk.tileMap
	var tileMapFlipped = chunk.tileMapF
	var coordsInSprite = (coords - chunk.global_position + Vector2(56, 56)) / 4
	
	if int(coordsInSprite.x) > 27:
		return Color.white
	#print(coordsInSprite)
	
	var tile = chunk.wfc.waveFunction[1][1].keys()[0]
	
	var colour = getPixelColor(tile, int(coordsInSprite.x), int(coordsInSprite.y))
	
	return colour


func getPixelColor(tile:String, x: int, y: int) -> Color:
	var flip = false
	
	if tile[0] == "f":
		flip = true
		tile = tile.replace("f", "")
		x = abs(x - 27)

	var tile_index = Vector2(int(tile.split(",")[1]), int(tile.split(",")[0]))
	
	var tile_size = Vector2(28, 28)
				
	var crop_region = Rect2(tile_index * tile_size, tile_size)
	
	var tileMap: StreamTexture
	if not flip:
		tileMap = game.chunks[Vector2(0,0)].tileMap
	else:
		tileMap = game.chunks[Vector2(0,0)].tileMapF

	var image = tileMap.get_data()
	if image:
		image.lock()
		var pixelColor = image.get_pixel(x + crop_region.position.x, y + crop_region.position.y)
		image.unlock()
		#print(pixelColor)
		return pixelColor
	
	return Color.white


extends Spatial

var BLUE = Color(0.388235,0.607843,1,1)
var RED = Color(0.67451,0.196078,0.196078,1)
#var YELLOW = Color(0.984314,0.94902,0.211765,1)




func _ready():
	pass
	
func setRotation(currentRotation, color):
	var top = Vector3(0, -45, 0)
	var left = Vector3(45, 0, 0)
	var right = Vector3(-45, 0, 0)
	
	if color == Color.black:
		$Sprite3D.rotation_degrees = Vector3.ZERO
	elif color == RED:
		$Sprite3D.rotation_degrees = rotateVectorAroundZ(left, currentRotation)
	elif color == BLUE:
		$Sprite3D.rotation_degrees = rotateVectorAroundZ(top, currentRotation)
	else:
		$Sprite3D.rotation_degrees = rotateVectorAroundZ(right, currentRotation)

func rotateVectorAroundZ(vector: Vector3, rotation_radians: float) -> Vector3:
	var cos_angle = cos(rotation_radians)
	var sin_angle = sin(rotation_radians)
	var x = vector.x * cos_angle - vector.y * sin_angle
	var y = vector.x * sin_angle + vector.y * cos_angle
	return Vector3(x, y, 0)
"""


func _on_Ant_body_entered(body):
	takeDamage(Perks.barbDamage)

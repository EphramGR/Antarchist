extends Node2D

const antPrefab = preload("res://Scenes/Ant.tscn")
const flyPrefab = preload("res://Scenes/FlyingAnt.tscn")

signal addMoney

enum ANTHEALTH {WEAKEST, WEAK, MID, STRONG, STRONGEST, GOD, B1, B2, B3}
enum ANTSPEED {SLOWEST, SLOW, MID, FAST, FASTEST, GOD, DEMON}#...
enum ANTS {NORM, CAMO, FLY, FLYCAMO, SPAWNER_G, SPAWNER_GC, SPAWNER_F, SPAWNER_FC}#...

const HEALTH = {
	ANTHEALTH.WEAKEST:100,
	ANTHEALTH.WEAK:200,
	ANTHEALTH.MID:300,
	ANTHEALTH.STRONG:500,
	ANTHEALTH.STRONGEST:750,
	ANTHEALTH.GOD:1000,
	ANTHEALTH.B1:2500,
	ANTHEALTH.B2:5000,
	ANTHEALTH.B3:10000
}
const SPEED = {
	ANTSPEED.SLOWEST:0.6,
	ANTSPEED.SLOW:0.85,
	ANTSPEED.MID:1.1,
	ANTSPEED.FAST:1.6,
	ANTSPEED.FASTEST:2.1,
	ANTSPEED.GOD:2.6,
	ANTSPEED.DEMON:3.1
}

const spawnerAmountDic = {
	50:[HEALTH[ANTHEALTH.STRONGEST],SPEED[ANTSPEED.FAST]],
	75:[HEALTH[ANTHEALTH.GOD],SPEED[ANTSPEED.FAST]],
	100:[HEALTH[ANTHEALTH.GOD],SPEED[ANTSPEED.FASTEST]],
	150:[HEALTH[ANTHEALTH.B1],SPEED[ANTSPEED.GOD]]
}

var defaultBonus
#never have multiple different spawns in a burst. not ment to handle that. IE: [[[[ANTS.NORM, [2,2], 150],[ANTS.CAMO, [2,2], 150]],[5], 1000]]
#[ant/another command, num, delay between (ms), HP, SPEED], wave end bonus
"""var waves = [
	[[ANTS.NORM, [20], 500, ANTHEALTH.WEAKEST, ANTSPEED.SLOW], null],
	[[ANTS.NORM, [30], 250, ANTHEALTH.WEAKEST, ANTSPEED.MID], null],
	[[ANTS.NORM, [10], 250, ANTHEALTH.WEAKEST, ANTSPEED.MID], [ANTS.NORM, [10], 500, ANTHEALTH.WEAK, ANTSPEED.SLOW], [ANTS.NORM, [10], 250, ANTHEALTH.WEAKEST, ANTSPEED.MID], null],
	[[ANTS.NORM, [20], 375, ANTHEALTH.WEAK, ANTSPEED.SLOW], null],
	[[ANTS.NORM, [30], 150, ANTHEALTH.WEAKEST, ANTSPEED.MID], null],

	[[ANTS.NORM, [30], 375, ANTHEALTH.WEAK, ANTSPEED.SLOW], null],
	[[ANTS.FLY, [10], 625, ANTHEALTH.WEAKEST, ANTSPEED.MID], null],
	[[ANTS.FLY, [2], 200, ANTHEALTH.WEAK, ANTSPEED.SLOW], [ANTS.NORM, [2], 200, ANTHEALTH.WEAKEST, ANTSPEED.MID], [ANTS.FLY, [2], 200, ANTHEALTH.WEAK, ANTSPEED.SLOW], [ANTS.NORM, [2], 200, ANTHEALTH.WEAKEST, ANTSPEED.MID], [ANTS.FLY, [2], 200, ANTHEALTH.WEAK, ANTSPEED.SLOW], [ANTS.NORM, [2], 200, ANTHEALTH.WEAKEST, ANTSPEED.MID], [ANTS.FLY, [2], 200, ANTHEALTH.WEAK, ANTSPEED.SLOW], [ANTS.NORM, [2], 200, ANTHEALTH.WEAKEST, ANTSPEED.MID], [ANTS.FLY, [2], 200, ANTHEALTH.WEAK, ANTSPEED.SLOW], [ANTS.NORM, [2], 200, ANTHEALTH.WEAKEST, ANTSPEED.MID], null],
	[[ANTS.NORM, [20], 300, ANTHEALTH.WEAK, ANTSPEED.SLOW], [ANTS.FLY, [10], 300, ANTHEALTH.WEAKEST, ANTSPEED.MID], [ANTS.FLY, [1], 1000, ANTHEALTH.MID, ANTSPEED.SLOWEST], null],
	[[ANTS.CAMO, [20], 500, ANTHEALTH.WEAKEST, ANTSPEED.SLOW], null]
]"""

var bonus

var numToSpawn = 1

var numDead = 0

var radius
var mapSize

var sensorRadius = 20.5 #square this for comparing squared distance

var homeMarkers = {}
var foodMarkers = {}

var base

var rect_min
var rect_max

var rectMin
var rectMax

var currentWave
var lastSpawn = 0
var waveComplete = false

var data
var spawns = []
var spawnTime = [null, null, null, null]
var lastSpawnTime = [null, null, null, null]
var antsToSpawn = [null, null, null, null]
var spawnerAmount = [null,null,null,null]
const dataSize = 6

#settings
var maxPheromoneLifeTime
var pheromoneEvaporateTime
var lifetime

const mergeDist = 6
const mergeDistSqr = mergeDist * mergeDist

const timePerAdditionalChunk = 2.2 #every time new SET of buttons apear, they get this much aditional phero time

#Debug
var printer = true
var visualizePheromoneTrails = true
var saveMarker = null

var slowFactor

const printWave = true

#for pathfind help
const minAnts = 100





func _ready():
	var sprite = get_node("Sprite")
		
	rectMin = sprite.global_position - (sprite.texture.get_size() * sprite.scale) / 2.0
	rectMax = sprite.global_position + (sprite.texture.get_size() * sprite.scale) / 2.0
	
	#print(base.position - position)
	#print(rad2deg((base.position - position).angle()))
	maxPheromoneLifeTime = timePerAdditionalChunk * ((round(mapSize)-324)/72 + 1) * 1000
	pheromoneEvaporateTime = maxPheromoneLifeTime * 1.5
	lifetime = maxPheromoneLifeTime * 4
		
	connect("addMoney", get_parent(), "_addMoney")
	
	numDead = minAnts
	
	processWavesCSV()
		
	
		
func _process(delta):
	#print(homeMarkers.size(), " ", foodMarkers.size())
	
	#removes depleating markers
	var markersToRemove = []
	for marker in homeMarkers:
		var size = homeMarkers[marker][0].size()
		if size == 0:
			homeMarkers.erase(marker)
			#print(marker, homeMarkers)
			continue
		for i in range(size):
			if homeMarkers[marker][0][i] < TimeScaler.time():
				markersToRemove.append([marker, i])
			
	for i in range(markersToRemove.size() - 1, -1, -1):
		homeMarkers[markersToRemove[i][0]][0].remove(markersToRemove[i][1])
		if homeMarkers[markersToRemove[i][0]][0].size() == 0:
			homeMarkers.erase(markersToRemove[i][0])
			
	
	markersToRemove = []
	for marker in foodMarkers:
		var size = foodMarkers[marker][0].size()
		if size == 0:
			foodMarkers.erase(marker)
			continue
		for i in range(size):
			if foodMarkers[marker][0][i] < TimeScaler.time():
				markersToRemove.append([marker, i])
			
	
	for i in range(markersToRemove.size() - 1, -1, -1):
		foodMarkers[markersToRemove[i][0]][0].remove(markersToRemove[i][1])
		if foodMarkers[markersToRemove[i][0]][0].size() == 0:
			foodMarkers.erase(markersToRemove[i][0])
		
	#if saveMarker in homeMarkers:
		#print(homeMarkers[saveMarker], TimeScaler.time())
	#if visualizePheromoneTrails:
	

	
	if not waveComplete:
		spawnWaveCSV()
	else:
		var ants = get_tree().get_nodes_in_group("AllAnts")
		var flag = true
		for ant in ants:
			if not ant.dead:
				flag = false
				break
		if flag:
			if bonus == null:
				bonus = defaultBonus
			addMoney(bonus, true)
			queue_free()
			TimeScaler.prep = true
			
	if numDead > 0:
		spawnDeadAnt()
		numDead -= 1
	if numDead < 0:
		killUselessAnt()
		numDead += 1
				
		
		
	
	update()
	
func spawnDeadAnt():
	var ant = SpawnAnt(false, true)
	ant.visible = false
	
func killUselessAnt():
	var ants = get_tree().get_nodes_in_group("AllAnts")
	
	var worstAnt = null
	var farthestAnt = 0
	
	for ant in ants:
		if ant.dead and ant.currentState == ant.State.SearchingForFood:
			var distance = ant.global_position.distance_squared_to(base.global_position)
			if distance >= farthestAnt:
				farthestAnt = distance
				worstAnt = ant
				
	if worstAnt == null:
		for ant in ants:
			if ant.dead:
				ant.queue_free()
				break
	else:
		worstAnt.queue_free()
		
func processWavesCSV():
	for i in range(4):
		var offset = dataSize*i
		if data[offset] == null:
			break
		var antType
		if data[5+offset] != null and data[5+offset] > 0:
			spawnerAmount[i] = data[5+offset]
			if data[4+offset] != null:
				if data[3+offset] != null:
					antType = ANTS.SPAWNER_FC
				else:
					antType = ANTS.SPAWNER_F
			elif data[3+offset] != null:
				antType = ANTS.SPAWNER_GC
			else:
				antType = ANTS.SPAWNER_G
			
		elif data[4+offset] != null:
			if data[3+offset] != null:
				antType = ANTS.FLYCAMO
			else:
				antType = ANTS.FLY
		elif data[3+offset] != null:
			antType = ANTS.CAMO
		else:
			antType = ANTS.NORM
			
		spawns.append([antType, data[1+offset]-1, data[2+offset]-1])
		antsToSpawn[i] = data[offset]
		lastSpawnTime[i] = 0
		
		spawnTime[i] = data[24]/data[offset]
		
	if printWave:
		printWaveBreakDown()
		
func printWaveBreakDown():
	
	var antNames = {ANTS.NORM:"Normal", ANTS.CAMO:"Camo", ANTS.FLY:"Flying", ANTS.FLYCAMO:"Flying-Camo", ANTS.SPAWNER_G:"Spawner", ANTS.SPAWNER_F:"Flying Spawner", ANTS.SPAWNER_GC:"Camo Spawner", ANTS.SPAWNER_FC:"Flying-Camo Spawner"}
	
	for i in range(spawns.size()):
		print("Spawning ", antsToSpawn[i], " ", antNames[spawns[i][0]], " Ants, ", spawnTime[i], "ms delay.")
		print(HEALTH[spawns[i][1]], " health, ", SPEED[spawns[i][2]], " speed","(",spawns[i][2], ")", ".")
		
func spawnWaveCSV():
	for i in range(spawns.size()):
		if antsToSpawn[i] > 0 and TimeScaler.time() - lastSpawnTime[i] > spawnTime[i]:
			lastSpawnTime[i] = TimeScaler.time()
			spawnThisAnt(spawns[i][0], spawns[i][1], spawns[i][2], spawnerAmount[i])
			antsToSpawn[i] -= 1
			
			var flag = true
			for j in range(spawns.size()):
				if antsToSpawn[j] > 0:
					flag = false
					break
			if flag:
				waveComplete = true
				get_parent().circleCloseButton.visible = true
				
			

func spawnThisAnt(ant:int, health:int, speed:int, spawnNum=null):
	var antInstance
	
	if spawnNum != null:
		ant -= 4
	
	if ant == ANTS.NORM:
		antInstance = SpawnAnt()
		antInstance.baseSpeedFactor = SPEED[speed]
	elif ant == ANTS.CAMO:
		antInstance = SpawnAnt(true)
		antInstance.baseSpeedFactor = SPEED[speed]
	elif ant == ANTS.FLY:
		antInstance = SpawnFly()
		antInstance.baseSpeedFactor = SPEED[speed+2]
	elif ant == ANTS.FLYCAMO:
		antInstance = SpawnFly(true)
		antInstance.baseSpeedFactor = SPEED[speed+2]
	else:
		print("ant not made yet, ", ant)
		
	antInstance.health = HEALTH[health]
	antInstance.MAXHEALTH = HEALTH[health]
	
	if spawnNum != null:
		antInstance.spawnNum = spawnNum
		antInstance.amountToSteal = spawnNum
		
	
	numDead -= 1
	
func spawnThisAntAt(ant:int, spawnNum:int, pos:Vector2, state:int, facingDir:Vector2):
	var antInstance
	if ant == ANTS.NORM:
		antInstance = SpawnAnt()
		antInstance.currentForwardDir = facingDir
	elif ant == ANTS.CAMO:
		antInstance = SpawnAnt(true)
		antInstance.currentForwardDir = facingDir
	elif ant == ANTS.FLY:
		antInstance = SpawnFly()
		var vector_to_food = base.global_position - pos
		antInstance.currentForwardDir = vector_to_food
	elif ant == ANTS.FLYCAMO:
		antInstance = SpawnFly(true)
		var vector_to_food = base.global_position - pos
		antInstance.currentForwardDir = vector_to_food
	else:
		print("ant not made yet, ", ant)
		
	antInstance.health = spawnerAmountDic[spawnNum][0]
	antInstance.MAXHEALTH = spawnerAmountDic[spawnNum][0]
	antInstance.baseSpeedFactor = spawnerAmountDic[spawnNum][1]
	
	antInstance.position = pos
	antInstance.currentPosition = pos
	antInstance.currentState=state
		
	
	numDead -= 1

func SpawnAnt(camo:bool=false,dead:bool=false):
	var antInstance = antPrefab.instance()
	antInstance.dead = dead
	#antInstance.position = position
	antInstance.perceptionRad = sensorRadius
	antInstance.maxPheromoneLifeTime = maxPheromoneLifeTime
	antInstance.pheromoneEvaporateTime = pheromoneEvaporateTime
	#antInstance.lifetime = lifetime
	#round(mapSize)-324)/72 gives 0, 1, 2 based on hwo far from center
	antInstance.isCamo = camo
	
	if printer:
		antInstance.printer = true
		printer = false
		
	var vector_to_food = base.position - position
	antInstance.currentForwardDir = vector_to_food
	#antInstance.rotation_degrees = rad2deg(vector_to_food.angle())
	
	antInstance.rect_max = rect_max
	antInstance.rect_min = rect_min
	
	antInstance.rectMin = rectMin
	antInstance.rectMax = rectMax
	
	add_child(antInstance)
	if not dead:
		antInstance.add_to_group("Ants")
	antInstance.add_to_group("AllAnts")
	antInstance.colony = self
	
	return antInstance
	
func SpawnFly(camo:bool=false):
	var antInstance = flyPrefab.instance()
	#antInstance.lifetime = lifetime
	
	antInstance.isCamo = camo
		
	var vector_to_food = base.position - position
	antInstance.currentForwardDir = vector_to_food.normalized()
	
	antInstance.rect_max = rect_max
	antInstance.rect_min = rect_min
	
	antInstance.rectMin = rectMin
	antInstance.rectMax = rectMax
	
	add_child(antInstance)
	antInstance.add_to_group("Ants")
	antInstance.colony = self
	
	return antInstance
	
func killRandomAnt():
	var ants = get_tree().get_nodes_in_group("Ants")

	if ants.size() > 0:
		var randomAntIndex = randi() % ants.size()
		var randomAnt = ants[randomAntIndex]
		if randomAnt.printer:
			killRandomAnt()
		else:
			randomAnt.queue_free()
	
func killAnts():
	get_tree().call_group("Ants", "queue_free")
	
#edits array of nearby pheoromones that is stored full if there time left, which is weight
func GetNearFood(nearby:Array, sensorCenter:Vector2):
	var numNear = 0
	for marker in foodMarkers:
		if (marker.distance_squared_to(sensorCenter) < sensorRadius*sensorRadius):
			nearby.append(getTotalLifetime(marker, false) * foodMarkers[marker][1])
			numNear += foodMarkers[marker][0].size()
			
	return numNear
	
	
	
func GetNearHome(nearby:Array, sensorCenter:Vector2):
	var numNear = 0
	for marker in homeMarkers:
		if (marker.distance_squared_to(sensorCenter) < sensorRadius*sensorRadius):
			nearby.append(getTotalLifetime(marker, true) * homeMarkers[marker][1])
			numNear += homeMarkers[marker][0].size()
			
	return numNear
	
	
	
	
func _draw():
	if visualizePheromoneTrails:
		visulaizePheromones()
	
	
func visulaizePheromones():
	
	
	for marker in foodMarkers:
		#var lifetime = foodMarkers[marker][0]
		var intensity = (getTotalLifetime(marker, false)-(TimeScaler.time()*foodMarkers[marker][0].size()))/maxPheromoneLifeTime
		var color = Color(intensity, 0, 0)
		draw_circle(marker, mergeDist, color)
		
	for marker in homeMarkers:
		#var lifetime = homeMarkers[marker][0]
		var intensity = (getTotalLifetime(marker, true)-(TimeScaler.time()*homeMarkers[marker][0].size()))/maxPheromoneLifeTime
		var color = Color(0, 0, intensity)
		draw_circle(marker, mergeDist, color)
	
	
func getTotalLifetime(marker, isHome):
	var totalTime = 0
	if isHome:
		for i in range(homeMarkers[marker][0].size()):
			totalTime += homeMarkers[marker][0][i]
	else:
		for i in range(foodMarkers[marker][0].size()):
			totalTime += foodMarkers[marker][0][i]
			
	return totalTime
	
func createHomeMarkerAt(pos:Vector2, arr:Array):
	var MIN = INF
	var closest = null
	
	for marker in homeMarkers:
		var dist = pos.distance_squared_to(marker)
		if dist < MIN:
			MIN = dist
			closest = marker
			
	if MIN <= mergeDistSqr:
		homeMarkers[closest][0] += arr[0]
	else:
		homeMarkers[pos] = arr
		
func createFoodMarkerAt(pos:Vector2, arr:Array):
	var MIN = INF
	var closest = null
	
	for marker in foodMarkers:
		var dist = pos.distance_squared_to(marker)
		if dist < MIN:
			MIN = dist
			closest = marker
			
	if MIN <= mergeDistSqr:
		foodMarkers[closest][0] += arr[0]
	else:
		foodMarkers[pos] = arr

func addMoney(amount:float, lumens:bool = false):
	 emit_signal("addMoney", amount, lumens)


"""

func spawnWave(arr:Array=currentWave):
	
	
	if arr.size() == 0:
		#print("Invalid wave, it is empty. ", get_stack())
		waveComplete = true
		print("waveComplete")
		return true
	
	if arr.size() == 1:
		if arr[0] is Array:
			if spawnWave(arr[0]):
				arr.remove(0)
		else:
			waveComplete = true
			bonus = arr[0]
			print("waveComplete")
			return true
			
	elif arr[0] is Array:
		if arr[1] is Array and arr[1].size() > 2:
			if spawnWave(arr[0]):
				arr.remove(0)
				
			
		elif arr[0][1][0] != 0 or TimeScaler.time() - lastSpawn >= arr[2]:
			if spawnWave(arr[0]):
				if arr[1] is Array and arr[1].size() == 1:
					arr[1][0] -= 1
					if arr[1][0] == 0:
						return true
					elif arr[1].size() == 2 and arr[1][0] < 0:
						arr[1][0] = arr[1][1] - 1
						
				else:
					arr.remove(0)
			
				lastSpawn = TimeScaler.time()
				
	elif arr[0] is int:
		if TimeScaler.time() - lastSpawn >= arr[2]:
			spawnThisAnt(arr[0], arr[3], arr[4])
			lastSpawn = TimeScaler.time()
			arr[1][0] -= 1
			if arr[1][0] == 0:
				return true
			elif arr[1] is Array and arr[1].size() == 2 and arr[1][0] < 0:
				arr[1][0] = arr[1][1] - 1
				
				
				
	return false

"""

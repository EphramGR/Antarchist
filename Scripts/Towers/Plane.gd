extends Tower

onready var sprite = get_node("Sprite")
var planeSprite = preload("res://Assets/Buildings/Towers/Drone/plane_0.png")
const plane = preload("res://Scenes/PlaneBullet.tscn")

var planes = []

#branch, more drones, or armed drone

#logic
var time = 0
var numPlanes = 1

#settings
enum STYLE {CIRCLE, H_FIGURE8, V_FIGURE8} #figures turn to weird orbits when more than 2
var flightPath = STYLE.CIRCLE
var planeSpeed = 2

var supremeSupport = false

var unboostedRange = 75* Perks.rangeMultiplier

var hasMissles:bool = false
var numBullets:int = 0

func _ready():
	actualRange = unboostedRange
	RANGE = actualRange*actualRange
	
	if mint:
		sprite.texture = load("res://Assets/Buildings/Towers/Drone/drone_0_mint.png")
		planeSprite = load("res://Assets/Buildings/Towers/Drone/plane_0_mint.png")
		
	createAllPlanes(numPlanes) 
	
	updatePerkTree()
	
	
	
func updateStats():
	stats = {
		"Range":actualRange,
		"Drone Speed":planeSpeed,
		"Number of Drones":numPlanes
	}
	
	if numBullets > 0:
		stats["Guns"]=numBullets
		stats["Gun Bullet Speed"]=5
		stats["Gun Firerate"]=round(50/20)/100
		stats["Gun Damage"]=80
		
	if hasMissles:
		stats["Missles Bullet Speed"]=1/0.25
		stats["Number of Missles"]=10
		stats["Missles Shot Delay"]=round(50/20)/100
		stats["Missles Reload Time"]=1000/2000
		stats["Missles Damage"]=150
		stats["Missle Explosion Radius"]=20
	
func updatePerkTree():
	upgrades = {
		"Drone Speed+":[],
		"Range+":["Drone Speed+"],
		"2nd Drone":["Range+"],
		"Armed Drones":["2nd Drone"],
		"Twin Barrel":["Armed Drones"],
		"Strafing Missiles":["Twin Barrel"],
		"3rd Drone":["2nd Drone"],
		"4th & 5th Drone":["3rd Drone"],
		"Supreme Support":["4th & 5th Drone"]
	}
	descriptions = {
		"Drone Speed+":"Increases drone speed by x%.",
		"Range+":"Increases drone flight range by x%.",
		"2nd Drone":"Adds a second drone.",
		"Armed Drones":"Drones get a machine gun.",
		"Twin Barrel":"Drones get a second machine gun.",
		"Strafing Missiles":"Drones get two mounted strafe missles.",
		"3rd Drone":"Adds a third drone.",
		"4th & 5th Drone":"Adds a fourth and fith drone.",
		"Supreme Support":"Towers on drones can see camo and hit flying."
	}
	upgradeSprites = {
		"Range+": Perks.defaultUpgradeSprites[Perks.baseUpgrades.RANGE],
		"Drone Speed+": Perks.droneUpgrades[Perks.drone.droneSpeed],
		"2nd Drone": Perks.droneUpgrades[Perks.drone.secondDrone],
		"Armed Drones": Perks.droneUpgrades[Perks.drone.armed],
		"Twin Barrel": Perks.droneUpgrades[Perks.drone.armed2],
		"Strafing Missiles": Perks.droneUpgrades[Perks.drone.missles],
		"3rd Drone": Perks.droneUpgrades[Perks.drone.thirdDrone],
		"4th & 5th Drone": Perks.droneUpgrades[Perks.drone.fifthDrone],
		"Supreme Support": Perks.droneUpgrades[Perks.drone.support]
	}
	prices = {
		"Drone Speed+": 100*Perks.upgradeCostMult,
		"Range+": 150*Perks.upgradeCostMult,
		"2nd Drone": 750*Perks.upgradeCostMult,
		"Armed Drones": 1000*Perks.upgradeCostMult,
		"Twin Barrel": 2250*Perks.upgradeCostMult,
		"Strafing Missiles": 3750*Perks.upgradeCostMult,
		"3rd Drone": 800*Perks.upgradeCostMult,
		"4th & 5th Drone": 1000*Perks.upgradeCostMult,
		"Supreme Support": 2750*Perks.upgradeCostMult
	}

	
func updateUpgrade(upgrade: String) -> void:
	if upgrade == "Drone Speed+":
		# Code for "Drone Speed+" upgrade
		planeSpeed *= 1.1

	elif upgrade == "Range+":
		# Code for "Range+" upgrade
		unboostedRange *= 1.1

	elif upgrade == "2nd Drone":
		# Code for "2nd Drone" upgrade
		createAllPlanes(2-numPlanes)
		numPlanes = 2
		

	elif upgrade == "Armed Drones":
		# Code for "Armed Drones" upgrade
		numBullets = 1

	elif upgrade == "Twin Barrel":
		# Code for "Twin Barrel" upgrade
		numBullets = 2

	elif upgrade == "Strafing Missiles":
		# Code for "Strafing Missles" upgrade
		hasMissles = true

	elif upgrade == "3rd Drone":
		# Code for "3rd Drone" upgrade
		createAllPlanes(3-numPlanes)
		numPlanes = 3

	elif upgrade == "4th & 5th Drone":
		# Code for "4th & 5th Drone" upgrade
		createAllPlanes(5-numPlanes)
		numPlanes = 5

	elif upgrade == "Supreme Support":
		# Code for "Supreme Support" upgrade
		supremeSupport = true
		unboostedSeesCamo = true
		hitsFlying = true

	else:
		print("Upgrade not found.")
		
	updateSprite(upgrade)
	updatePlanes()
	
func updateSprite(upgrade):
	if ownedUpgrades.size() == upgrades.size():
		planeSprite = load("res://Assets/Buildings/Towers/Drone/plane_max.png")
		for i in range(planes.size()):
			planes[i].texture = planeSprite
		return
		
	var planeString:String
	var string:String
	
	if upgrade == "Drone Speed+":
		# Code for "Drone Speed+" upgrade
		planeString = "res://Assets/Buildings/Towers/Drone/plane_1"

	elif upgrade == "Range+":
		# Code for "Range+" upgrade
		string = "res://Assets/Buildings/Towers/Drone/drone_2"

	elif upgrade == "Armed Drones":
		# Code for "Armed Drones" upgrade
		planeString = "res://Assets/Buildings/Towers/Drone/plane_a0"

	elif upgrade == "Twin Barrel":
		# Code for "Twin Barrel" upgrade
		planeString = "res://Assets/Buildings/Towers/Drone/plane_a1"

	elif upgrade == "Strafing Missiles":
		# Code for "Strafing Missles" upgrade
		planeString = "res://Assets/Buildings/Towers/Drone/plane_a2"

	elif upgrade == "Supreme Support":
		# Code for "Supreme Support" upgrade
		planeString = "res://Assets/Buildings/Towers/Drone/plane_b2"

	else:
		print("Upgrade not found.")
		return
		
	if mint:
		if string:
			sprite.texture = load(string + "_mint.png")
		elif planeString:
			planeSprite = load(planeString + "_mint.png")
			for i in range(planes.size()):
				planes[i].texture = planeSprite
	else:
		if string:
			sprite.texture = load(string + ".png")
		elif planeString:
			planeSprite = load(planeString + ".png")
			for i in range(planes.size()):
				planes[i].texture = planeSprite
	
	
		

	
func updateBoosts():
	actualRange = unboostedRange * buffs[BUFFS.RANGE]
	RANGE = actualRange * actualRange
	seesCamo = (buffs[BUFFS.SEECAMO] == 2 or unboostedSeesCamo)

func _process(delta):
	time += delta * planeSpeed
	handlePlaneMovement()

func handlePlaneMovement():
	if flightPath == STYLE.CIRCLE:
		flyCircle()
		
	elif flightPath == STYLE.H_FIGURE8:
		flyFigure8()
	
	else:
		flyFigure8(false)
		
func flyCircle():
	for i in range(planes.size()):
		var offset = 2*PI/planes.size() * i
		
		var angle = Vector2(sin(time + offset), cos(time + offset))
		
		planes[i].global_position = global_position + angle*actualRange
		
func flyFigure8(horizontal:bool = true):
	for i in range(planes.size()):
		var offset = 2*PI/planes.size() * i
		
		var x = cos(time/2 + offset) * actualRange
		var y = sin(time + offset) * actualRange/2
		
		if horizontal:
			planes[i].global_position = global_position + Vector2(x, y)
		else:
			planes[i].global_position = global_position + Vector2(y, x)

func createAllPlanes(num:int):
	for i in range(num):
		createNewPlane()

func createNewPlane():
	var planeInstance = plane.instance()
	planeInstance.texture = planeSprite
	planeInstance.z_index = 5
	planeInstance.myTower = self
	planeInstance.hasMissles = hasMissles
	planeInstance.numBullets = numBullets
	planeInstance.supremeSupport = supremeSupport
	game.add_child(planeInstance)
	planes.append(planeInstance)
	
func updatePlanes():
	for i in range(numPlanes):
		planes[i].hasMissles = hasMissles
		planes[i].numBullets = numBullets
		planes[i].supremeSupport = supremeSupport
	

func hitchRide(tower):
	for i in range(planes.size()):
		if planes[i].heldTower == null:
			planes[i].heldTower = tower
			return
			
	print("NO EMPTY PLANES")
	
func unride(tower):
	for i in range(planes.size()):
		if planes[i].heldTower == tower:
			planes[i].heldTower = null
			return
			
	print("NO MATCHING TOWER")
	
func checkForFree():
	for i in range(planes.size()):
		if planes[i].heldTower == null:
			return true
			
	return false

func cleanUp():
	for i in range(planes.size()):
		if planes[i] != null:
			planes[i].queue_free()
			if planes[i].heldTower != null:
				planes[i].heldTower.queue_free()
				planes[i].heldTower.cleanUp()

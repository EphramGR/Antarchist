extends Tower

onready var sprite = get_node("Sprite")

var bullet = preload("res://Scenes/Beam.tscn")
var bulletInstances

onready var shootPos = get_node("shootPos")

#references
#var game

#logic
var lastShotTime = 0
var distanceToTarget
var frameHold
var continueTime
var activeTargets
var avalibleBeams

#settings
#unboosted
var unboostedRange = 150 * Perks.rangeMultiplier
var unboostedFireRate = 200/ Perks.firerateMultiplier
var unboostedDamage = 20

var damage = 20
var tickRate = unboostedFireRate #rate of dealing damge 
var damageCap = 250
var chargeTime = 1.2 #rate of how time gets translated to exponent /2
var killReset = true
var rangeReset = true
var numTargets = 1

onready var audioPlayer = get_node("AudioStreamPlayer2D")

func _ready():
	actualRange = unboostedRange
	RANGE = actualRange * actualRange
	hitsFlying = true
	
	updateNumBeams(1)
	updatePerkTree()
	
	if mint:
		sprite.texture = load("res://Assets/Buildings/Towers/Inferno/inferno_0_mint.png")
	
	
func updateStats():
	stats = {
		"Initial Damage":damage,
		"Damage Cap":damageCap,
		"Charge Rate":chargeTime,
		"Range":actualRange,
		"Tick Rate":round(tickRate/20)/100,
	}
	if not unboostedSeesCamo:
		stats["Camo"] = false
	
	if numTargets > 1:
		stats["Number of Targets"] = numTargets
	
func updatePerkTree():
	upgrades = {
		"Initial Damage+":[],
		"Damage Cap+":["Initial Damage+"],
		"Range++":["Damage Cap+"],
		"Tickrate+":["Range++"],
		"Persistent Reach":["Tickrate+"],
		"Flames of Life":["Tickrate+"],
		"Second Target":["Damage Cap+"],
		"Third Target":["Second Target"],
		"Split Beam":["Third Target"]
	}
	descriptions = {
		"Initial Damage+":"Increases starting damage by x%.",
		"Damage Cap+":"Increases damage cap by x%.",
		"Range++":"Increases range by x%.",
		"Tickrate+":"Increases damage tickrate by x%.",
		"Persistent Reach":"Beam charge doesn't reset when enemy walks out of range, but reduce charge up time.",
		"Flames of Life":"Beam charge doesn't reset when it kills an enemy, but reduce charge up time.",
		"Second Target":"Has two beams, two targets.",
		"Third Target":"Has three beams, three targets.",
		"Split Beam":"Gains two additional targets, having five beams total."
	}
	upgradeSprites = {
		"Initial Damage+": Perks.defaultUpgradeSprites[Perks.baseUpgrades.DAMAGE],
		"Damage Cap+": Perks.defaultUpgradeSprites[Perks.baseUpgrades.DAMAGE],
		"Range++": Perks.defaultUpgradeSprites[Perks.baseUpgrades.RANGE],
		"Tickrate+": Perks.defaultUpgradeSprites[Perks.baseUpgrades.FIRERATE],
		"Persistent Reach": Perks.infernoUpgrades[Perks.inferno.persistantReach],
		"Flames of Life":  Perks.infernoUpgrades[Perks.inferno.life],
		"Second Target":  Perks.infernoUpgrades[Perks.inferno.second],
		"Third Target":  Perks.infernoUpgrades[Perks.inferno.third],
		"Split Beam":  Perks.infernoUpgrades[Perks.inferno.fifth]
	}
	prices = {
		"Initial Damage+": 100*Perks.upgradeCostMult,
		"Damage Cap+": 150*Perks.upgradeCostMult,
		"Range++": 200*Perks.upgradeCostMult,
		"Tickrate+": 225*Perks.upgradeCostMult,
		"Persistent Reach": 2750*Perks.upgradeCostMult,
		"Flames of Life": 3750*Perks.upgradeCostMult,
		"Second Target": 800*Perks.upgradeCostMult,
		"Third Target": 1200*Perks.upgradeCostMult,
		"Split Beam": 3250*Perks.upgradeCostMult
	}

	
func updateUpgrade(upgrade: String) -> void:
	if upgrade == "Initial Damage+":
		# Code for "Initial Damage+" upgrade
		unboostedDamage *= 1.2

	elif upgrade == "Damage Cap+":
		# Code for "Damage Cap+" upgrade
		damageCap *= 1.1

	elif upgrade == "Range++":
		# Code for "Range+" upgrade
		unboostedRange *= 1.5

	elif upgrade == "Tickrate+":
		# Code for "Tickrate+" upgrade
		unboostedFireRate *= 0.9

	elif upgrade == "Persistent Reach":
		# Code for "Persistent Reach" upgrade
		rangeReset = false
		chargeTime -= 0.3

	elif upgrade == "Flames of Life":
		# Code for "Flames of Life" upgrade
		killReset = false
		chargeTime -= 0.3

	elif upgrade == "Second Target":
		# Code for "Second Target" upgrade
		cleanUp()
		updateNumBeams(2)

	elif upgrade == "Third Target":
		# Code for "Third Target" upgrade
		cleanUp()
		updateNumBeams(3)

	elif upgrade == "Split Beam":
		# Code for "Split Beam" upgrade
		cleanUp()
		updateNumBeams(5)

	else:
		print("Upgrade not found.")
		
	updateSprite(upgrade)
		
func updateSprite(upgrade:String)->void:
	if ownedUpgrades.size() == upgrades.size():
		sprite.texture = load("res://Assets/Buildings/Towers/Inferno/inferno_max.png")
		return
	
	var string:String
	
	if upgrade == "Initial Damage+":
		string = "res://Assets/Buildings/Towers/Inferno/inferno_1"

	elif upgrade == "Damage Cap+":
		string = "res://Assets/Buildings/Towers/Inferno/inferno_2"

	elif upgrade == "Range++":
		string = "res://Assets/Buildings/Towers/Inferno/inferno_a0"

	elif upgrade == "Tickrate+":
		string = "res://Assets/Buildings/Towers/Inferno/inferno_a1"

	elif upgrade == "Persistent Reach":
		string = "res://Assets/Buildings/Towers/Inferno/inferno_aa"

	elif upgrade == "Flames of Life":
		string = "res://Assets/Buildings/Towers/Inferno/inferno_ab"

	elif upgrade == "Second Target":
		string = "res://Assets/Buildings/Towers/Inferno/inferno_b0"

	elif upgrade == "Third Target":
		string = "res://Assets/Buildings/Towers/Inferno/inferno_b1"

	elif upgrade == "Split Beam":
		string = "res://Assets/Buildings/Towers/Inferno/inferno_b2"

	else:
		print("Upgrade not found.")
		return
		
	if mint:
		sprite.texture = load(string + "_mint.png")
	else:
		sprite.texture = load(string + ".png")
		

	
func _process(delta):
	if not isInHand:
		if null in activeTargets:
			getAllTargets()
			
			toggleSound()
			
			for i in range(avalibleBeams.size()):
				if activeTargets[avalibleBeams[i]] != null:
					shoot(avalibleBeams[i])
					
				frameHold[avalibleBeams[i]] = false
			
			avalibleBeams = []
		
		
func toggleSound():
	var enable:bool = false
	
	for i in range(avalibleBeams.size()):
		if activeTargets[avalibleBeams[i]] != null:
			enable = true
			break
	
	if enable:
		audioPlayer.volume_db = linear2db(Perks.shootVolume*2)
		audioPlayer.play()
	else:
		audioPlayer.stop()
		
		
			
func updateBoosts():
	actualRange = unboostedRange * buffs[BUFFS.RANGE]
	RANGE = actualRange * actualRange
	
	damage = unboostedDamage * buffs[BUFFS.DAMAGE]
	
	tickRate = unboostedFireRate * 1/buffs[BUFFS.FIRERATE]
	seesCamo = (buffs[BUFFS.SEECAMO] == 2 or unboostedSeesCamo)
	
	
			
func cleanUp():
	for bulletInstance in bulletInstances:
		if bulletInstance != null and is_instance_valid(bulletInstance):
			bulletInstance.queue_free()
		
		
func updateNumBeams(num):
	numTargets = num
	lastShotTime = []
	activeTargets = []
	avalibleBeams = []
	frameHold = []
	continueTime = []
	bulletInstances = []
	for i in range(num):
		lastShotTime.append(0)
		activeTargets.append(null)
		avalibleBeams.append(i)
		frameHold.append(false)
		continueTime.append(null)
		bulletInstances.append(null)

func getAllTargets():
	var ants = get_tree().get_nodes_in_group("Ants")
	
	for i in range(numTargets):
		if activeTargets[i] == null:
			var comparatorAndTarget = [null, null]
			
			
			for ant in ants:
				if not ant.dead and not ant in activeTargets and ((ant.isCamo and seesCamo) or not ant.isCamo) and ((ant.isFlying and hitsFlying) or not ant.isFlying):
					var distance = global_position.distance_squared_to(ant.global_position)
					
					if distance <= RANGE:
						compareTarget(comparatorAndTarget, distance, ant)
						
						activeTargets[i] = comparatorAndTarget[1]
						
			avalibleBeams.append(i)

	
func shoot(index:int):
	bulletInstances[index] = bullet.instance()
	bulletInstances[index].z_index = 4
	bulletInstances[index].tower = self
	bulletInstances[index].target = activeTargets[index]
	
	if frameHold[index]:
		bulletInstances[index].time = continueTime[index]
		
	bulletInstances[index].damage = damage
	
	bulletInstances[index].damageCap = damageCap
	bulletInstances[index].chargeTime = chargeTime
	bulletInstances[index].tickRate = tickRate
	bulletInstances[index].RANGE = actualRange
	bulletInstances[index].numCharges = log(damageCap) / log(damage)
	
	bulletInstances[index].killReset = killReset
	bulletInstances[index].rangeReset = rangeReset
	
	bulletInstances[index].index = index
	bulletInstances[index].updateSprite(activeTargets[index].global_position.distance_to(global_position))
	bulletInstances[index].visible = false
	
	game.add_child(bulletInstances[index])
	

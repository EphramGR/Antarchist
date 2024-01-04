extends Tower

onready var sprite = get_node("Sprite")
var flailSprite = preload("res://Assets/Buildings/Towers/Flail/spike_0.png")

#references
var flail = preload("res://Scenes/Spike.tscn")
var chain = preload("res://Scenes/Chain.tscn")
var activeFlails = []
var activeChains = []

#logic
var time = 0
var visualFramehold = 0

#settings
#unboosted
var unboostedRange = 50* Perks.rangeMultiplier
var unboostedDamage = 100
var unboostedBulletSpeed = 4*Perks.bulletSpeedMultiplier

var rotateSpeed = unboostedBulletSpeed #mult by time
var damage = 100
var numSpikes = 2
var flailScale = 1
var slow = false
var confuse = false



func _ready():	
	actualRange = unboostedRange
	RANGE = actualRange * actualRange
	
	updatePerkTree()
	
	if mint:
		sprite.texture = load("res://Assets/Buildings/Towers/Flail/flail_0_mint.png")
	
func updateStats():
	stats = {
		"Damage":damage,
		"Spin Speed":rotateSpeed,
		"Flail Scale":flailScale,
		"Number of Flails":numSpikes
	}
		
	if not hitsFlying:
		stats["Flying"] = false
	
	if slow:
		stats["Applies Slow"] = "Active"
		
	if confuse:
		stats["Applies Confusion"] = "Active"
	
func updatePerkTree():
	upgrades = {
		"Speed+":[],
		"Range+":["Speed+"],
		"Damage+":[],
		"Damage++":["Damage+"],
		"3rd Flail":["Range+", "Damage++"],
		"More Flails":["3rd Flail"],
		"Even More Flails":["More Flails"],
		"Ice Balls":["Even More Flails"],
		"Aerodynamics":["More Flails"],
		"Power in Numbers":["Aerodynamics"],
		"Quality Over Quantity":["3rd Flail"],
		"Heavy Balls":["Quality Over Quantity"],
		"Momentus Strike":["Heavy Balls"]
	}
	descriptions = {
		"Speed+":"Increases speed of balls by x%.",
		"Range+":"Increases range of balls by x%.",
		"Damage+":"Increases damage of balls by x%.",
		"Damage++":"Increases damage of balls by x%.",
		"3rd Flail":"Gain an aditional flail.",
		"More Flails":"Gain an aditional flail.",
		"Even More Flails":"Gain an aditional flail.",
		"Ice Balls":"Balls inflict a low duration of slow.",
		"Aerodynamics":"Smaller flails, but much faster spin.",
		"Power in Numbers":"Five more flails.",
		"Quality Over Quantity":"One less flail, but flails become much bigger.",
		"Heavy Balls":"Increases damage massively.",
		"Momentus Strike":"x% chance to confuse ants for low duration."
	}
	upgradeSprites = {
		"Speed+": Perks.defaultUpgradeSprites[Perks.baseUpgrades.BULLETSPEED],
		"Range+": Perks.defaultUpgradeSprites[Perks.baseUpgrades.RANGE],
		"Damage+": Perks.defaultUpgradeSprites[Perks.baseUpgrades.DAMAGE],
		"Damage++": Perks.defaultUpgradeSprites[Perks.baseUpgrades.DAMAGE],
		"3rd Flail": Perks.flailUpgrades[Perks.flail.thirdFlail],
		"More Flails": Perks.flailUpgrades[Perks.flail.forthFlail],
		"Even More Flails": Perks.flailUpgrades[Perks.flail.fifthFlail],
		"Ice Balls": Perks.flailUpgrades[Perks.flail.iceBalls],
		"Aerodynamics": Perks.flailUpgrades[Perks.flail.aero],
		"Power in Numbers": Perks.flailUpgrades[Perks.flail.powerInNumbers],
		"Quality Over Quantity": Perks.flailUpgrades[Perks.flail.quality],
		"Heavy Balls": Perks.flailUpgrades[Perks.flail.spikey],
		"Momentus Strike": Perks.flailUpgrades[Perks.flail.momentus]
	}
	prices = {
		"Speed+": 150*Perks.upgradeCostMult,
		"Range+": 200*Perks.upgradeCostMult,
		"Damage+": 175*Perks.upgradeCostMult,
		"Damage++": 225*Perks.upgradeCostMult,
		"3rd Flail": 600*Perks.upgradeCostMult,
		"More Flails": 750*Perks.upgradeCostMult,
		"Even More Flails": 800*Perks.upgradeCostMult,
		"Ice Balls": 2500*Perks.upgradeCostMult,
		"Aerodynamics": 900*Perks.upgradeCostMult,
		"Power in Numbers": 2750*Perks.upgradeCostMult,
		"Quality Over Quantity": 750*Perks.upgradeCostMult,
		"Heavy Balls": 750*Perks.upgradeCostMult,
		"Momentus Strike": 3000*Perks.upgradeCostMult
	}

	
func updateUpgrade(upgrade: String) -> void:
	if upgrade == "Speed+":
		# Code for "Speed+" upgrade
		unboostedBulletSpeed *= 1.3

	elif upgrade == "Range+":
		# Code for "Range+" upgrade
		unboostedRange *= 1.3

	elif upgrade == "Damage+":
		# Code for "Damage+" upgrade
		unboostedDamage *= 1.1

	elif upgrade == "Damage++":
		# Code for "Damage++" upgrade
		unboostedDamage *= 1.15

	elif upgrade == "3rd Flail":
		# Code for "3rd Flail" upgrade
		numSpikes = 3

	elif upgrade == "More Flails":
		# Code for "More Flails" upgrade
		numSpikes += 1

	elif upgrade == "Even More Flails":
		# Code for "Even More Flails" upgrade
		numSpikes += 1

	elif upgrade == "Ice Balls":
		# Code for "Ice Balls" upgrade
		slow = true

	elif upgrade == "Aerodynamics":
		# Code for "Aerodynamics" upgrade
		unboostedBulletSpeed *= 2

	elif upgrade == "Power in Numbers":
		# Code for "Power in Numbers" upgrade
		numSpikes += 5

	elif upgrade == "Quality Over Quantity":
		# Code for "Quality Over Quantity" upgrade
		numSpikes -= 1
		flailScale *= 2.5

	elif upgrade == "Heavy Balls":
		# Code for "Spikey Balls" upgrade
		unboostedDamage *= 1.5

	elif upgrade == "Momentus Strike":
		# Code for "Momentus Strike" upgrade
		confuse = true

	else:
		print("Upgrade not found.")
		
	updateSprite(upgrade)
		
func updateSprite(upgrade: String) -> void:
	if ownedUpgrades.size() == upgrades.size():
		sprite.texture = load("res://Assets/Buildings/Towers/Flail/flail_max.png")
		flailSprite = load("res://Assets/Buildings/Towers/Flail/spike_max.png")
		return
		
	var flailString:String
	var string:String
	
	if upgrade == "Speed+":
		# Code for "Speed+" upgrade
		string = "res://Assets/Buildings/Towers/Flail/flail_1"

	elif upgrade == "Range+":
		# Code for "Range+" upgrade
		string = "res://Assets/Buildings/Towers/Flail/flail_2"

	elif upgrade == "Damage+":
		# Code for "Damage+" upgrade
		flailString = "res://Assets/Buildings/Towers/Flail/spike_1"

	elif upgrade == "Damage++":
		# Code for "Damage++" upgrade
		flailString = "res://Assets/Buildings/Towers/Flail/spike_2"

	elif upgrade == "3rd Flail":
		# Code for "3rd Flail" upgrade
		string = "res://Assets/Buildings/Towers/Flail/flail_3"

	elif upgrade == "Ice Balls":
		# Code for "Ice Balls" upgrade
		flailString = "res://Assets/Buildings/Towers/Flail/spike_a2"

	elif upgrade == "Aerodynamics":
		# Code for "Aerodynamics" upgrade
		flailString = "res://Assets/Buildings/Towers/Flail/spike_aa0"

	elif upgrade == "Quality Over Quantity":
		# Code for "Quality Over Quantity" upgrade
		flailString = "res://Assets/Buildings/Towers/Flail/spike_b0"

	elif upgrade == "Heavy Balls":
		# Code for "Spikey Balls" upgrade
		flailString = "res://Assets/Buildings/Towers/Flail/spike_b1"

	elif upgrade == "Momentus Strike":
		# Code for "Momentus Strike" upgrade
		flailString = "res://Assets/Buildings/Towers/Flail/spike_b2"

	else:
		print("Upgrade not found.")
		return
		
	if mint:
		if string:
			sprite.texture = load(string + "_mint.png")
		elif flailString:
			flailSprite = load(flailString + "_mint.png")
	else:
		if string:
			sprite.texture = load(string + ".png")
		elif flailString:
			flailSprite = load(flailString + ".png")

func placed():
	if mint:
		flailSprite = load("res://Assets/Buildings/Towers/Flail/spike_0_mint.png")
	createAllFlails()
	
func _process(delta):
	if not isInHand:
		time += delta * rotateSpeed
		handleFlailMovement()
	

func updateBoosts():
	actualRange = unboostedRange * buffs[BUFFS.RANGE]
	RANGE = actualRange * actualRange
	
	damage = unboostedDamage * buffs[BUFFS.DAMAGE]
	
	rotateSpeed = unboostedBulletSpeed * buffs[BUFFS.BULLETSPEED]
	seesCamo = (buffs[BUFFS.SEECAMO] == 2 or unboostedSeesCamo)
	
	if not isInHand:
		eraseAllFlails()
		createAllFlails()
		
	visualFramehold = 0
	
func createAllFlails():
	for i in range(numSpikes):
		createNewFlail()

func createNewFlail():
	var flailInstance = flail.instance()
	flailInstance.damage = damage
	flailInstance.scale = Vector2(flailScale, flailScale)
	flailInstance.z_index = 6
	flailInstance.slow = slow
	flailInstance.confuse = confuse
	flailInstance.hitsFlying = hitsFlying
	flailInstance.get_node("Sprite").texture = flailSprite
	game.add_child(flailInstance)
	activeFlails.append(flailInstance)
	
	var chainInstance = chain.instance()
	chainInstance.z_index = 5
	chainInstance.visible = false
	game.add_child(chainInstance)
	activeChains.append(chainInstance)

	
func eraseAllFlails():
	for i in range(activeFlails.size()):
		activeFlails[i].queue_free()
		activeChains[i].queue_free()
		
	activeFlails = []
	activeChains = []
	

func handleFlailMovement():
	for i in range(activeFlails.size()):
		var offset = 2*PI/activeFlails.size() * i
		
		var angle = Vector2(sin(time + offset), cos(time + offset))
		
		activeFlails[i].rotation = atan2(angle.y, angle.x)
		
		activeFlails[i].global_position = global_position + angle*actualRange
		
		#Handle Chain movement:
		activeChains[i].global_position = global_position + (Vector2(cos(activeChains[i].rotation), sin(activeChains[i].rotation)).normalized() * actualRange/2)
		activeChains[i].region_rect =  Rect2(0, 0, actualRange/scale.x, 9)
		activeChains[i].rotation = atan2((activeFlails[i].global_position.y - global_position.y)/scale.x, (activeFlails[i].global_position.x -  global_position.x)/scale.x)
		if visualFramehold == 2:
			activeChains[i].visible = true
			
			
	if visualFramehold < 3:
		visualFramehold += 1
		
		
func cleanUp():
	eraseAllFlails()

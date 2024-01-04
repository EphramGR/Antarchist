extends Tower

onready var sprite = get_node("Sprite")
var bullet = preload("res://Scenes/Lightning.tscn")

onready var shootPos = get_node("shootPos")


#logic
var lastShotTime = 0
var target

#settings
#unboosted
var unboostedRange = 150* Perks.rangeMultiplier
var unboostedChainRange = 100
var unboostedFireRate = 1800/ Perks.firerateMultiplier
var unboostedDamage = 40

var damage = 100
var fireRate = unboostedFireRate
var actualChainRange = 100
var chainRange = actualChainRange*actualChainRange
var chainCap = 3
var duration = 0.25
var farChain = true

var closeDamage = false
var farDamage = false
var conductive = false

var sounds = [
	preload("res://Assets/Music/soundEffects/tesla/laserShoot.wav"),
	preload("res://Assets/Music/soundEffects/tesla/laserShoot (1).wav"),
	preload("res://Assets/Music/soundEffects/tesla/laserShoot (2).wav")
]
onready var audioPlayer = get_node("AudioStreamPlayer2D")

func _ready():
	actualRange = unboostedRange
	RANGE = actualRange * actualRange
	hitsFlying = true
	
	updatePerkTree()
	
	if mint:
		sprite.texture = load("res://Assets/Buildings/Towers/Tesla/tesla_0_mint.png")
	
func playSound():
	var randomIndex = randi() % sounds.size()

	audioPlayer.stream = sounds[randomIndex]
	
	audioPlayer.volume_db = linear2db(Perks.shootVolume)

	audioPlayer.play()
	
func updateStats():
	stats = {
		"Damage":damage,
		"Range":actualRange,
		"Chain Range":actualChainRange,
		"Chain Cap":chainCap,
		"Fire Rate":round(fireRate/200)/10
	}
	
	if not unboostedSeesCamo:
		stats["Camo"] = false
	
func updatePerkTree():
	upgrades = {
		"Damage+":[],
		"Range+":["Damage+"],
		"Firerate+":["Range+"],
		"Firerate++":["Firerate+"],
		"More Chains":["Firerate++"],
		"Conductive":["More Chains"],
		"Chain Range+":["Firerate+"],
		"Damage++":["Chain Range+"],
		"Proximity Surge":["Damage++"],
		"Chain Range++":["Firerate+"],
		"Fork Lightning":["Chain Range++"],
		"Acceleration":["Fork Lightning"]
	}
	descriptions = {
		"Damage+":"Increases damage by x%.",
		"Range+":"Increases range by x%.",
		"Firerate+":"Increases firerate by x%.",
		"Firerate++":"Increases firerate by x%.",
		"Fork Lightning":"Changes the chain start point from the tip of the lightning to the center.",
		"Proximity Surge":"Does more damage the closer the target. Chained ants receive only x% of the previous ant's bonus, on top of their bonus.",
		"Chain Range+":"Increases chain range by x%.",
		"Damage++":"Increases damage by x%.",
		"Conductive":"Each ant takes more damage the farther down the chain the ant is.",
		"Chain Range++":"Increases chain range by x%.",
		"More Chains":"Increases max number of chains from 3 to 5.",
		"Acceleration":"Damage increases with distance. Chained ants receive only x% of the previous ant's bonus, on top of their bonus."
	}
	upgradeSprites = {
		"Damage+": Perks.defaultUpgradeSprites[Perks.baseUpgrades.DAMAGE],
		"Range+": Perks.defaultUpgradeSprites[Perks.baseUpgrades.RANGE],
		"Firerate+": Perks.defaultUpgradeSprites[Perks.baseUpgrades.FIRERATE],
		"Firerate++": Perks.defaultUpgradeSprites[Perks.baseUpgrades.FIRERATE],
		"Chain Range+": Perks.defaultUpgradeSprites[Perks.baseUpgrades.RANGE],
		"Damage++": Perks.defaultUpgradeSprites[Perks.baseUpgrades.DAMAGE],
		"Chain Range++": Perks.defaultUpgradeSprites[Perks.baseUpgrades.RANGE],
		"Fork Lightning": Perks.teslaUpgrades[Perks.tesla.fork],
		"Proximity Surge": Perks.teslaUpgrades[Perks.tesla.prox],
		"Conductive": Perks.teslaUpgrades[Perks.tesla.chain],
		"More Chains": Perks.teslaUpgrades[Perks.tesla.moreChains],
		"Acceleration": Perks.teslaUpgrades[Perks.tesla.accel]
	}
	prices = {
		"Damage+": 150*Perks.upgradeCostMult,
		"Range+": 175*Perks.upgradeCostMult,
		"Firerate+": 225*Perks.upgradeCostMult,
		"Firerate++": 250*Perks.upgradeCostMult,
		"Fork Lightning": 750*Perks.upgradeCostMult,
		"Proximity Surge": 3000*Perks.upgradeCostMult,
		"Chain Range+": 225*Perks.upgradeCostMult,
		"Damage++": 250*Perks.upgradeCostMult,
		"Conductive": 3500*Perks.upgradeCostMult,
		"Chain Range++": 250*Perks.upgradeCostMult,
		"More Chains": 750*Perks.upgradeCostMult,
		"Acceleration": 2750*Perks.upgradeCostMult
	}

	
func updateUpgrade(upgrade: String) -> void:
	if upgrade == "Damage+":
		# Code for "Damage+" upgrade
		unboostedDamage *= 1.1

	elif upgrade == "Range+":
		# Code for "Range+" upgrade
		unboostedRange *= 1.1

	elif upgrade == "Firerate+":
		# Code for "Firerate+" upgrade
		unboostedFireRate *= 1.1

	elif upgrade == "Firerate++":
		# Code for "Firerate++" upgrade
		unboostedFireRate *= 1.15

	elif upgrade == "Fork Lightning":
		# Code for "Close Chain" upgrade
		farChain = false

	elif upgrade == "Proximity Surge":
		# Code for "Proximity Surge" upgrade
		closeDamage = true

	elif upgrade == "Chain Range+":
		# Code for "Chain Range+" upgrade
		unboostedChainRange *= 1.1

	elif upgrade == "Damage++":
		# Code for "Damage++" upgrade
		unboostedDamage *= 1.15

	elif upgrade == "Conductive":
		# Code for "Conductive" upgrade
		conductive = true

	elif upgrade == "Chain Range++":
		# Code for "Chain Range++" upgrade
		unboostedChainRange *= 1.15

	elif upgrade == "More Chains":
		# Code for "More Chains" upgrade
		chainCap += 2

	elif upgrade == "Acceleration":
		# Code for "Acceleration" upgrade
		farDamage = true

	else:
		print("Upgrade not found.")
		
	updateSprite(upgrade)
		
func updateSprite(upgrade: String) -> void:
	if ownedUpgrades.size() == upgrades.size():
		sprite.texture = load("res://Assets/Buildings/Towers/Tesla/tesla_max.png")
		return
		
	var string:String
	
	if upgrade == "Damage+":
		# Code for "Damage+" upgrade
		string = "res://Assets/Buildings/Towers/Tesla/tesla_0-5"

	elif upgrade == "Range+":
		# Code for "Range+" upgrade
		string = "res://Assets/Buildings/Towers/Tesla/tesla_1"

	elif upgrade == "Firerate+":
		# Code for "Firerate+" upgrade
		string = "res://Assets/Buildings/Towers/Tesla/tesla_2"

	elif upgrade == "Firerate++":
		# Code for "Firerate++" upgrade
		string = "res://Assets/Buildings/Towers/Tesla/tesla_b0"

	elif upgrade == "Fork Lightning":
		# Code for "Close Chain" upgrade
		string = "res://Assets/Buildings/Towers/Tesla/tesla_a1"

	elif upgrade == "Proximity Surge":
		# Code for "Proximity Surge" upgrade
		string = "res://Assets/Buildings/Towers/Tesla/tesla_c2"

	elif upgrade == "Chain Range+":
		# Code for "Chain Range+" upgrade
		string = "res://Assets/Buildings/Towers/Tesla/tesla_c0"

	elif upgrade == "Damage++":
		# Code for "Damage++" upgrade
		string = "res://Assets/Buildings/Towers/Tesla/tesla_c1"

	elif upgrade == "Conductive":
		# Code for "Conductive" upgrade
		string = "res://Assets/Buildings/Towers/Tesla/tesla_b2"

	elif upgrade == "Chain Range++":
		# Code for "Chain Range++" upgrade
		string = "res://Assets/Buildings/Towers/Tesla/tesla_a0"

	elif upgrade == "More Chains":
		# Code for "More Chains" upgrade
		string = "res://Assets/Buildings/Towers/Tesla/tesla_b1"

	elif upgrade == "Acceleration":
		# Code for "Acceleration" upgrade
		string = "res://Assets/Buildings/Towers/Tesla/tesla_a2"

	else:
		print("Upgrade not found.")
		return
		
	if mint:
		sprite.texture = load(string + "_mint.png")
	else:
		sprite.texture = load(string + ".png")
	
func updateBoosts():
	actualRange = unboostedRange * buffs[BUFFS.RANGE]
	RANGE = actualRange * actualRange
	
	actualChainRange = unboostedChainRange * buffs[BUFFS.RANGE] * buffs[BUFFS.EXPLOSIONRADIUS]
	chainRange = actualChainRange*actualChainRange
	
	fireRate = unboostedFireRate * 1/buffs[BUFFS.FIRERATE]
	
	damage = unboostedDamage * buffs[BUFFS.DAMAGE]
	seesCamo = (buffs[BUFFS.SEECAMO] == 2 or unboostedSeesCamo)
	
	
func _process(delta):
	if not isInHand:
		if TimeScaler.time() - lastShotTime > fireRate:
			target = getTarget()
			if target != null:
				shoot()
				lastShotTime = TimeScaler.time()

	
func shoot():
	var lightningInstance = bullet.instance()
	lightningInstance.damage = damage
	lightningInstance.tower = self
	lightningInstance.target = target
	lightningInstance.chainIndex = 1
	lightningInstance.chainCap = chainCap
	lightningInstance.antInChain = [target]
	lightningInstance.chainRange = chainRange
	lightningInstance.global_position = shootPos.global_position
	lightningInstance.z_index = 4
	lightningInstance.game = game
	lightningInstance.duration = duration
	lightningInstance.parent = self
	lightningInstance.farChain = farChain
	
	lightningInstance.closeDamage = closeDamage
	lightningInstance.farDamage = farDamage
	lightningInstance.conductive = conductive
	
	game.add_child(lightningInstance)
	
	playSound()
	
func getParentPos() -> Vector2:
	return shootPos.global_position

extends Tower


#upgrades
#more and more votexes and damage and firerate
#or vortexes go until reach destination (so splash instead of despawn and bigger 

onready var sprite = get_node("Sprite")
var bullet = preload("res://Scenes/Vortex.tscn")

#logic
var lastShotTime = 0

#settings
var unboostedFirerate = 1000/ Perks.firerateMultiplier
var unboostedDamage = 100
var unboostedEffectDuration = 0.4
var unboostedRange = 75* Perks.rangeMultiplier
var unboostedBulletSpeed = 50*Perks.bulletSpeedMultiplier

var fireRate = unboostedFirerate
var damage = 100
var effectDuration = 0.4
var effectChance = 0.6
var numBullets = 3
var bulletSpeed = unboostedBulletSpeed
var isSplash = false
var sizeMult = 1
var piercing = false

var sounds = [
	preload("res://Assets/Music/soundEffects/vortex/random.wav"),
	preload("res://Assets/Music/soundEffects/vortex/random (1).wav"),
	preload("res://Assets/Music/soundEffects/vortex/random (2).wav")
]
onready var audioPlayer = get_node("AudioStreamPlayer2D")


func _ready():	
	actualRange = unboostedRange
	RANGE = actualRange*actualRange
	hitsFlying = true
	
	updatePerkTree()
	
	if mint:
		sprite.texture = load("res://Assets/Buildings/Towers/Vortex/vortex_0_mint.png")
	
func playSound():
	var randomIndex = randi() % sounds.size()

	audioPlayer.stream = sounds[randomIndex]
	
	audioPlayer.volume_db = linear2db(Perks.shootVolume)

	audioPlayer.play()
	
func updateStats():
	stats = {
		"Damage":damage,
		"Range":actualRange,
		"Bullet Speed":bulletSpeed/10,
		"Fire Rate":round(fireRate/200)/10,
		"Confusion Chance":String(min(round(effectChance*1000)/10,100)) + "%",
		"Confusion Duration":effectDuration/2,
		"Number of Vortexs":numBullets,
		"Size":sizeMult*100
	}
	if not unboostedSeesCamo:
		stats["Camo"]=true
	
func updateBoosts():
	actualRange = unboostedRange * buffs[BUFFS.RANGE]
	RANGE = actualRange * actualRange
	
	damage = unboostedDamage * buffs[BUFFS.DAMAGE]
	
	fireRate = unboostedFirerate *1/buffs[BUFFS.FIRERATE]
	
	effectDuration = unboostedEffectDuration * buffs[BUFFS.EFFECTDURATION]
	
	bulletSpeed = unboostedBulletSpeed * buffs[BUFFS.BULLETSPEED]
	
	
func updatePerkTree():
	upgrades = {
		"Range+":[],
		"Damage+":[],
		"Confusion Chance+":["Range+"],
		"Bullet Speed+":["Damage+"],
		"Additional Vortex":["Confusion Chance+", "Bullet Speed+"],
		"Camo Vision":["Additional Vortex"],
		"Massive Vortexes":["Camo Vision"],
		"Confusion Chance++":["Massive Vortexes"],
		"Relentless Vortex":["Confusion Chance++"],
		"Double Vortexes":["Camo Vision"],
		"Firerate++":["Double Vortexes"],
		"Maelstrom Barrage":["Firerate++"]
	}
	descriptions = {
		"Range+":"Increases range by x%.",
		"Damage+":"Increases damage by x%.",
		"Confusion Chance+":"Increases confusion chance by x%.",
		"Bullet Speed+":"Increases bullet speed by x%.",
		"Additional Vortex":"Shoots one aditional vortex.",
		"Camo Vision":"Can see camo ants.",
		"Massive Vortexes":"Vortex size is drasticaly increased.",
		"Confusion Chance++":"Increases confusion chance by x%.",
		"Relentless Vortex":"Vortex goes through ants.",
		"Double Vortexes":"Shoots four aditional vortex.",
		"Firerate++":"Increases firerate by x%.",
		"Maelstrom Barrage":"Shoots eight aditional vortex, for a total of 16."
	}
	upgradeSprites = {
		"Range+": Perks.defaultUpgradeSprites[Perks.baseUpgrades.RANGE],
		"Damage+": Perks.defaultUpgradeSprites[Perks.baseUpgrades.DAMAGE],
		"Confusion Chance+": Perks.defaultUpgradeSprites[Perks.baseUpgrades.ELEMENTDURATION],
		"Bullet Speed+": Perks.defaultUpgradeSprites[Perks.baseUpgrades.BULLETSPEED],
		"Camo Vision": Perks.defaultUpgradeSprites[Perks.baseUpgrades.CAMOVISION],
		"Confusion Chance++": Perks.defaultUpgradeSprites[Perks.baseUpgrades.ELEMENTDURATION],
		"Firerate++": Perks.defaultUpgradeSprites[Perks.baseUpgrades.FIRERATE],
		"Maelstrom Barrage": Perks.vortexUpgrades[Perks.vortex.barrage],
		"Relentless Vortex": Perks.vortexUpgrades[Perks.vortex.relentless],
		"Double Vortexes": Perks.vortexUpgrades[Perks.vortex.double],
		"Massive Vortexes": Perks.vortexUpgrades[Perks.vortex.massiveVortex],
		"Additional Vortex": Perks.vortexUpgrades[Perks.vortex.additionalVortex]
	}
	prices = {
		"Range+": 125*Perks.upgradeCostMult,
		"Damage+": 175*Perks.upgradeCostMult,
		"Confusion Chance+": 200*Perks.upgradeCostMult,
		"Bullet Speed+": 225*Perks.upgradeCostMult,
		"Additional Vortex": 700*Perks.upgradeCostMult,
		"Camo Vision": 200*Perks.upgradeCostMult,
		"Massive Vortexes": 1000*Perks.upgradeCostMult,
		"Confusion Chance++": 275*Perks.upgradeCostMult,
		"Relentless Vortex": 3500*Perks.upgradeCostMult,
		"Double Vortexes": 1750*Perks.upgradeCostMult,
		"Firerate++": 225*Perks.upgradeCostMult,
		"Maelstrom Barrage": 3350*Perks.upgradeCostMult
	}

	
func updateUpgrade(upgrade: String) -> void:
	if upgrade == "Range+":
		# Code for "Range+" upgrade
		unboostedRange *= 1.1

	elif upgrade == "Damage+":
		# Code for "Damage+" upgrade
		unboostedDamage *= 1.1

	elif upgrade == "Confusion Chance+":
		# Code for "Confusion Chance+" upgrade
		effectChance *= 1.15

	elif upgrade == "Bullet Speed+":
		# Code for "Bullet Speed+" upgrade
		unboostedBulletSpeed *= 1.1

	elif upgrade == "Additional Vortex":
		# Code for "Additional Vortex" upgrade
		numBullets = 4

	elif upgrade == "Camo Vision":
		# Code for "Camo Vision" upgrade
		unboostedSeesCamo = true

	elif upgrade == "Massive Vortexes":
		# Code for "Massive Vortexes" upgrade
		sizeMult *= 2

	elif upgrade == "Confusion Chance++":
		# Code for "Confusion Chance++" upgrade
		effectChance *= 1.5

	elif upgrade == "Relentless Vortex":
		# Code for "Relentless Vortex" upgrade
		piercing = true

	elif upgrade == "Double Vortexes":
		# Code for "Double Vortexes" upgrade
		numBullets = 8

	elif upgrade == "Firerate++":
		# Code for "Firerate++" upgrade
		unboostedFirerate *= 1.15

	elif upgrade == "Maelstrom Barrage":
		# Code for "Maelstrom Barradge" upgrade
		numBullets = 16

	else:
		print("Upgrade not found.")
	
	updateSprite(upgrade)
		

func updateSprite(upgrade: String) -> void:
	if ownedUpgrades.size() == upgrades.size():
		sprite.texture = load("res://Assets/Buildings/Towers/Vortex/vortex_max.png")
		return
		
	var string:String
	
	if upgrade == "Range+":
		# Code for "Range+" upgrade
		if ownedUpgrades.size() == 1:
			string = "res://Assets/Buildings/Towers/Vortex/vortex_1"
		else:
			return

	elif upgrade == "Damage+":
		# Code for "Damage+" upgrade
		if ownedUpgrades.size() == 1:
			string = "res://Assets/Buildings/Towers/Vortex/vortex_1"
		else:
			return

	elif upgrade == "Confusion Chance+":
		# Code for "Confusion Chance+" upgrade
		string = "res://Assets/Buildings/Towers/Vortex/vortex_2"

	elif upgrade == "Bullet Speed+":
		# Code for "Bullet Speed+" upgrade
		string = "res://Assets/Buildings/Towers/Vortex/vortex_2"

	elif upgrade == "Additional Vortex":
		# Code for "Additional Vortex" upgrade
		string = "res://Assets/Buildings/Towers/Vortex/vortex_3"

	elif upgrade == "Camo Vision":
		# Code for "Camo Vision" upgrade
		string = "res://Assets/Buildings/Towers/Vortex/vortex_4"

	elif upgrade == "Massive Vortexes":
		# Code for "Massive Vortexes" upgrade
		string = "res://Assets/Buildings/Towers/Vortex/vortex_a0"

	elif upgrade == "Confusion Chance++":
		# Code for "Confusion Chance++" upgrade
		string = "res://Assets/Buildings/Towers/Vortex/vortex_a1"

	elif upgrade == "Relentless Vortex":
		# Code for "Relentless Vortex" upgrade
		string = "res://Assets/Buildings/Towers/Vortex/vortex_a2"

	elif upgrade == "Double Vortexes":
		# Code for "Double Vortexes" upgrade
		string = "res://Assets/Buildings/Towers/Vortex/vortex_b0"

	elif upgrade == "Firerate++":
		# Code for "Firerate++" upgrade
		string = "res://Assets/Buildings/Towers/Vortex/vortex_b1"

	elif upgrade == "Maelstrom Barrage":
		# Code for "Maelstrom Barradge" upgrade
		string = "res://Assets/Buildings/Towers/Vortex/vortex_b2"
		
		
	else:
		print("Upgrade not found.")
		return
		
	if mint:
		sprite.texture = load(string + "_mint.png")
	else:
		sprite.texture = load(string + ".png")

	
	
func _process(delta):
	if not isInHand:
		if TimeScaler.time() - lastShotTime > fireRate:
			aim()
	
func aim():
	var ants = get_tree().get_nodes_in_group("Ants")
	
	for ant in ants:
		if not ant.dead:
			var distance = global_position.distance_squared_to(ant.global_position)
			
			if distance <= RANGE:
				shoot()
				lastShotTime = TimeScaler.time()
				break
	
func shoot():
	playSound()
	
	for i in range(numBullets):
		var offset = 2*PI/numBullets * i
		
		var angle = Vector2(sin(offset), cos(offset))
	
		var target = global_position + angle*actualRange
		
		var bulletInstance = bullet.instance()
		
		bulletInstance.damage = damage
		bulletInstance.effectDuration = effectDuration
		bulletInstance.effectChance = effectChance
		bulletInstance.target = target
		bulletInstance.global_position = global_position
		bulletInstance.z_index = 4
		bulletInstance.velocity = (target-global_position).normalized() * bulletSpeed
		bulletInstance.scale *= sizeMult
		bulletInstance.isSplash = piercing
		
		game.add_child(bulletInstance)
	
func cleanUp():
	pass



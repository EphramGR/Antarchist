extends Tower

onready var sprite = get_node("Sprite")

var bullet = preload("res://Scenes/Arrow.tscn")

onready var shootPos = get_node("shootPos")

#references
#var game

#logic
var lastShotTime = 0
var distanceToTarget

#settings

#unboosted
var unboostedRange = 150 * Perks.rangeMultiplier
var unboostedFireRate = 1000 / Perks.firerateMultiplier
var unboostedDamage = 100
var unboostedBulletSpeed = 0.25/Perks.bulletSpeedMultiplier

var bulletSpeed = unboostedBulletSpeed #inverse

var fireRate = unboostedFireRate #ms, /1000 for s *2 cause time scale 0.5
var baseFirerate = unboostedFireRate
var damage = 100
var piercing = 3
var pierceReduction = 0.25
var despawnTime = 3
var critChance = 0
var camoRemover = false
const critMultiplier = 2

var sounds = [
	preload("res://Assets/Music/soundEffects/laserArrow/laserShoot.wav"),
	preload("res://Assets/Music/soundEffects/laserArrow/laserShoot (1).wav"),
	preload("res://Assets/Music/soundEffects/laserArrow/laserShoot (2).wav"),
	preload("res://Assets/Music/soundEffects/laserArrow/laserShoot (3).wav")
]
onready var audioPlayer = get_node("AudioStreamPlayer2D")

#var targetType = Tower.TARGET.closest

func _ready():	
	actualRange = unboostedRange
	RANGE = actualRange * actualRange
	hitsFlying = true
	
	updatePerkTree()
	
	if mint:
		sprite.texture = load("res://Assets/Buildings/Towers/Archer/arch_0_mint.png")
	
func playSound():
	var randomIndex = randi() % sounds.size()

	audioPlayer.stream = sounds[randomIndex]
	
	audioPlayer.volume_db = linear2db(Perks.shootVolume)

	audioPlayer.play()

func updateStats():
	stats = {
		"Damage":damage,
		"Firerate":round(fireRate/200)/10,
		"Bullet Speed":1/bulletSpeed,
		"Range":actualRange
	}
	if piercing != INF:
		stats["Peircing"] = piercing
	else:
		stats["Peircing"] = "Infinite"
	
	stats["Peirce Damage Reduction"] = pierceReduction
	
	if critChance > 0:
		stats["Crit Chance"] = String(round(critChance*10)/10) + "%"
		stats["Crit Multiplier"] = critMultiplier
		
	if not unboostedSeesCamo:
		stats["Camo"]= true
		
	
	
func updatePerkTree():
	upgrades = {
		"Range+":[],
		"Bullet Speed+":["Range+"],
		"Camo Vision":["Bullet Speed+", "Damage+"],
		"2nd Archer":["Camo Vision"],
		"+1 Peirce":[],
		"Damage+":["+1 Peirce"],
		"Sturdy Shafts": ["2nd Archer"],
		"Infinite Peirce":["Sturdy Shafts"],
		"Critical Eye": ["2nd Archer"],
		"Critical Camo":["Critical Eye"],
		"3rd Archer": ["2nd Archer"],
		"4th & 5th Archer": ["3rd Archer"]
	}
	descriptions = {
		"Range+":"Increase range by x percent.",
		"Bullet Speed+":"Increases bullet speed by x percent.",
		"Camo Vision": "Can see camo ants.",
		"2nd Archer":"Adds another archer, doubling base firerate.",
		"+1 Peirce":"Increases ants peirced by 1.",
		"Damage+":"Increases damage by x percent.",
		"Sturdy Shafts":"Arrows no longer get reduced damage after peircing targets.",
		"Infinite Peirce":"Arrows no longer have a peirce limit.",
		"Critical Eye":"Arrows have a 50% chance to crit, dealing 2x damage.",
		"Critical Camo":"Arrows crit's now remove camo.",
		"3rd Archer": "Adds another archer, tripling base firerate.",
		"4th & 5th Archer": "Adds 2 more archers, making it shoot 5x the base firerate."
	}
	upgradeSprites = {
		"Range+": Perks.defaultUpgradeSprites[Perks.baseUpgrades.RANGE],
		"Bullet Speed+": Perks.defaultUpgradeSprites[Perks.baseUpgrades.BULLETSPEED],
		"Camo Vision": Perks.defaultUpgradeSprites[Perks.baseUpgrades.CAMOVISION],
		"Damage+": Perks.defaultUpgradeSprites[Perks.baseUpgrades.DAMAGE],
		"2nd Archer": Perks.archUpgrades[Perks.arch.second],
		"+1 Peirce": Perks.archUpgrades[Perks.arch.pierce],
		"Sturdy Shafts": Perks.archUpgrades[Perks.arch.sturdy],
		"Infinite Peirce": Perks.archUpgrades[Perks.arch.infinite],
		"Critical Eye": Perks.archUpgrades[Perks.arch.critEye],
		"Critical Camo": Perks.archUpgrades[Perks.arch.critCamo],
		"3rd Archer": Perks.archUpgrades[Perks.arch.third],
		"4th & 5th Archer": Perks.archUpgrades[Perks.arch.fifth]
	}
	prices = {
		"Range+": 100*Perks.upgradeCostMult,
		"Bullet Speed+": 150*Perks.upgradeCostMult,
		"Camo Vision": 200*Perks.upgradeCostMult,
		"2nd Archer": 500*Perks.upgradeCostMult,
		"+1 Peirce": 200*Perks.upgradeCostMult,
		"Damage+": 200*Perks.upgradeCostMult,
		"Sturdy Shafts": 1000*Perks.upgradeCostMult,
		"Infinite Peirce": 2000*Perks.upgradeCostMult,
		"Critical Eye": 750*Perks.upgradeCostMult,
		"Critical Camo": 1750*Perks.upgradeCostMult,
		"3rd Archer": 750*Perks.upgradeCostMult,
		"4th & 5th Archer": 2500*Perks.upgradeCostMult
	}
	
func updateUpgrade(upgrade:String)->void:
	if upgrade == "Range+":
		unboostedRange *=  1.25
	
	elif upgrade == "Bullet Speed+":
		unboostedBulletSpeed *= 1.25
		
	elif upgrade == "Camo Vision":
		unboostedSeesCamo = true
	
	elif upgrade == "2nd Archer":
		unboostedFireRate = baseFirerate/2
		
	elif upgrade == "+1 Peirce":
		piercing += 1
		
	elif upgrade == "Damage+":
		unboostedDamage *= 1.1
		
	elif upgrade == "Sturdy Shafts":
		pierceReduction = 0
		
	elif upgrade == "Infinite Peirce":
		piercing = INF
		
	elif upgrade == "Critical Eye":
		critChance = 0.5
		
	elif upgrade == "Critical Camo":
		camoRemover = true
		
	elif upgrade == "3rd Archer":
		unboostedFireRate = baseFirerate/3
		
	elif upgrade == "4th & 5th Archer":
		unboostedFireRate = baseFirerate/5
		
	else:
		print("Upgrade not found.")
		
	updateSprite(upgrade)
		
	
func _process(delta):
	if not isInHand:
		if TimeScaler.time() - lastShotTime > fireRate:
			var target = getTarget()
			if target != null:
				var targetPos = target.global_position
				distanceToTarget = global_position.distance_to(targetPos)
				shoot(takeAim(targetPos), targetPos)
				lastShotTime = TimeScaler.time()
				
			
			
				
func updateSprite(upgrade:String)->void:
	if ownedUpgrades.size() == upgrades.size():
		sprite.texture = load("res://Assets/Buildings/Towers/Archer/arch_max.png")
		return
	
	var string:String
	
	if upgrade == "Range+" and "+1 Peirce" in ownedUpgrades:
		string = "res://Assets/Buildings/Towers/Archer/arch_1"
	
	elif upgrade == "Bullet Speed+" and "Damage+" in ownedUpgrades:
		string = "res://Assets/Buildings/Towers/Archer/arch_2"
		
	elif upgrade == "Camo Vision":
		string = "res://Assets/Buildings/Towers/Archer/arch_3"
	
	elif upgrade == "2nd Archer":
		string = "res://Assets/Buildings/Towers/Archer/arch_4"
		
	elif upgrade == "+1 Peirce" and "Range+" in ownedUpgrades:
		string = "res://Assets/Buildings/Towers/Archer/arch_1"
		
	elif upgrade == "Damage+" and "Bullet Speed+" in ownedUpgrades:
		string = "res://Assets/Buildings/Towers/Archer/arch_2"
		
	elif upgrade == "Sturdy Shafts":
		string = "res://Assets/Buildings/Towers/Archer/arch_a0"
		
	elif upgrade == "Infinite Peirce":
		string = "res://Assets/Buildings/Towers/Archer/arch_a1"
		
	elif upgrade == "Critical Eye":
		string = "res://Assets/Buildings/Towers/Archer/arch_b0"
		
	elif upgrade == "Critical Camo":
		string = "res://Assets/Buildings/Towers/Archer/arch_b1"
		
	elif upgrade == "3rd Archer":
		string = "res://Assets/Buildings/Towers/Archer/arch_c0"
		
	elif upgrade == "4th & 5th Archer":
		string = "res://Assets/Buildings/Towers/Archer/arch_c1"
		
	else:
		print("Upgrade not found.")
		return
		
	if mint:
		sprite.texture = load(string + "_mint.png")
	else:
		sprite.texture = load(string + ".png")
		
		
	
func takeAim(targetPos):
	var midpoint = Vector2()
	midpoint.x = (shootPos.global_position.x + targetPos.x) / 2
	midpoint.y = (shootPos.global_position.y + targetPos.y) / 2 - distanceToTarget/4
	return midpoint
	
func shoot(pointC, targetPos):
	var bulletInstance = bullet.instance()
	bulletInstance.positionA = shootPos.global_position
	bulletInstance.positionB = targetPos
	bulletInstance.positionC = pointC
	bulletInstance.duration = distanceToTarget / 100 * bulletSpeed
	bulletInstance.damage = damage
	bulletInstance.piercing = piercing
	bulletInstance.z_index = 4
	bulletInstance.despawnTime = despawnTime
	bulletInstance.critChance = critChance
	bulletInstance.camoRemover = camoRemover
	bulletInstance.critMultiplier = critMultiplier
	bulletInstance.pierceReduction = pierceReduction
	bulletInstance.hitsFlying = hitsFlying
	game.add_child(bulletInstance)
	playSound()

func updateBoosts():
	actualRange = unboostedRange * buffs[BUFFS.RANGE]
	RANGE = actualRange * actualRange
	
	fireRate = unboostedFireRate * 1/buffs[BUFFS.FIRERATE]
	
	damage = unboostedDamage * buffs[BUFFS.DAMAGE]
	
	bulletSpeed = unboostedBulletSpeed * 1/buffs[BUFFS.BULLETSPEED]
	
	seesCamo = (buffs[BUFFS.SEECAMO] == 2 or unboostedSeesCamo)

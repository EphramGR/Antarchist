extends Tower


var bullet = preload("res://Scenes/MortarBullet.tscn")
onready var sprite = get_node("Sprite")
onready var barrel = get_node("Barrel")

#logic
var lastShotTime = 0
var distanceToTarget

#settings
#unboosted
var unboostedRange = 175 * Perks.rangeMultiplier
var unboostedFireRate = 2500/ Perks.firerateMultiplier
var unboostedDamage = 150
var unboostedBulletSpeed = 0.5/Perks.bulletSpeedMultiplier
var unboostedExplosionRadius = 70

var bulletSpeed = unboostedBulletSpeed #inverse
var explosionRadius = 70

var fireRate = unboostedFireRate #ms, /1000 for s *2 cause time scale 0.5
var damage = 150

var nuke = false
var fire = false
var shrapnel
var aoeDuration = 0.4

var sounds = [
	preload("res://Assets/Music/soundEffects/mortar/explosion.wav"),
	preload("res://Assets/Music/soundEffects/mortar/explosion (1).wav"),
	preload("res://Assets/Music/soundEffects/mortar/explosion (2).wav")
]
onready var audioPlayer = get_node("AudioStreamPlayer2D")

func _ready():	
	actualRange = unboostedRange
	RANGE = actualRange * actualRange
	
	updatePerkTree()
	
	if mint:
		sprite.texture = load("res://Assets/Buildings/Towers/Mortar/mortar_0_base_mint.png")
		barrel.texture = load("res://Assets/Buildings/Towers/Mortar/mortar_0_barrel_mint.png")
	
func playSound():
	var randomIndex = randi() % sounds.size()

	audioPlayer.stream = sounds[randomIndex]
	
	audioPlayer.volume_db = linear2db(Perks.shootVolume)

	audioPlayer.play()
	
func updateStats():
	stats = {
		"Damage":damage,
		"Fire Rate":round(fireRate/200)/10,
		"Bullet Speed":1/bulletSpeed,
		"Explosion Radius":explosionRadius,
		"Range":actualRange
	}
	
	if nuke:
		if fire:
			stats["AOE"] = "Radiation and Fire"
		else:
			stats["AOE"] = "Radiation"
	elif fire:
		stats["AOE"] = "Fire"
		
	if shrapnel:
		stats["Shrapnel"] = "Active"
		
	if not hitsFlying:
		stats["Flying"] = true
		
	if not unboostedSeesCamo:
		stats["Camo"] = true
	
func updatePerkTree():
	upgrades = {
		"Bullet Speed+":[],
		"AOE+":["Bullet Speed+"],
		"Firerate++":["AOE+"],
		"Camo Vision":["Firerate++"],
		"Bullet Speed+++":["Camo Vision"],
		"Shrapnel Shots":["Bullet Speed+++"],
		"AOE++":["AOE+"],
		"Range++":["AOE++"],
		"Aerial Assault":["Range++"],
		"Nuke Lobber":["Aerial Assault"],
		"Damage++":["AOE+"],
		"Bullet Speed++":["Damage++"],
		"Range+":["Bullet Speed++"],
		"Molten Shells":["Range+"]
		
	}
	descriptions = {
		"Bullet Speed+":"Increases bullet speed by x%.",
		"AOE+":"Increases explosive radius by x%.",
		"Firerate++":"Increases firerate by x%.",
		"Camo Vision":"Can see camo ants.",
		"Bullet Speed+++":"Increases bullet speed by x%.",
		"Shrapnel Shots":"On explosion, shoot out 8 shrapnel that continue forever.",
		"AOE++":"Increases explosive radius by x%.",
		"Range++":"Increases range by x%.",
		"Aerial Assault":"Can hit flying ants.",
		"Nuke Lobber":"Massive damage, AOE, and does DoT. But reduces rate of fire.",
		"Damage++":"Increases damage by x%.",
		"Bullet Speed++":"Increases bullet speed by x%.",
		"Range+":"Increases range by x%.",
		"Molten Shells":"Leaves fire behind in AOE, which ignites ants, for a short period of time."
	}
	upgradeSprites = {
		"Bullet Speed+": Perks.defaultUpgradeSprites[Perks.baseUpgrades.BULLETSPEED],
		"AOE+": Perks.defaultUpgradeSprites[Perks.baseUpgrades.AOE],
		"Firerate++": Perks.defaultUpgradeSprites[Perks.baseUpgrades.FIRERATE],
		"Camo Vision": Perks.defaultUpgradeSprites[Perks.baseUpgrades.CAMOVISION],
		"Bullet Speed+++": Perks.defaultUpgradeSprites[Perks.baseUpgrades.BULLETSPEED],
		"AOE++": Perks.defaultUpgradeSprites[Perks.baseUpgrades.AOE],
		"Range++": Perks.defaultUpgradeSprites[Perks.baseUpgrades.RANGE],
		"Aerial Assault": Perks.defaultUpgradeSprites[Perks.baseUpgrades.AERIALASSAULT],
		"Damage++": Perks.defaultUpgradeSprites[Perks.baseUpgrades.DAMAGE],
		"Bullet Speed++": Perks.defaultUpgradeSprites[Perks.baseUpgrades.BULLETSPEED],
		"Range+": Perks.defaultUpgradeSprites[Perks.baseUpgrades.RANGE],
		"Shrapnel Shots": Perks.mortarUpgrades[Perks.mortar.shrapnel],
		"Nuke Lobber": Perks.mortarUpgrades[Perks.mortar.nuke],
		"Molten Shells": Perks.mortarUpgrades[Perks.mortar.molten]
	}
	prices = {
		"Bullet Speed+": 100*Perks.upgradeCostMult,
		"AOE+": 125*Perks.upgradeCostMult,
		"Firerate++": 200*Perks.upgradeCostMult,
		"Camo Vision": 200*Perks.upgradeCostMult,
		"Bullet Speed+++": 300*Perks.upgradeCostMult,
		"Shrapnel Shots": 2000*Perks.upgradeCostMult,
		"AOE++": 225*Perks.upgradeCostMult,
		"Range++": 200*Perks.upgradeCostMult,
		"Aerial Assault": 200*Perks.upgradeCostMult,
		"Nuke Lobber": 3000*Perks.upgradeCostMult,
		"Damage++": 225*Perks.upgradeCostMult,
		"Bullet Speed++": 250*Perks.upgradeCostMult,
		"Range+": 200*Perks.upgradeCostMult,
		"Molten Shells": 2500*Perks.upgradeCostMult
	}

	
func updateUpgrade(upgrade: String) -> void:
	if upgrade == "Bullet Speed+":
		# Code for "Bullet Speed+" upgrade
		unboostedBulletSpeed *= 1.1

	elif upgrade == "AOE+":
		# Code for "AOE+" upgrade
		unboostedExplosionRadius *= 1.1

	elif upgrade == "Firerate++":
		# Code for "Firerate++" upgrade
		unboostedFireRate *= 0.85

	elif upgrade == "Camo Vision":
		# Code for "Camo Vision" upgrade
		unboostedSeesCamo = true

	elif upgrade == "Bullet Speed+++":
		# Code for "Bullet Speed+++" upgrade
		unboostedBulletSpeed *= 1.25

	elif upgrade == "Shrapnel Shots":
		# Code for "Shrapnel Shots" upgrade
		shrapnel = true

	elif upgrade == "AOE++":
		# Code for "AOE++" upgrade
		unboostedExplosionRadius *= 1.15

	elif upgrade == "Range++":
		# Code for "Range++" upgrade
		unboostedRange *= 1.15

	elif upgrade == "Aerial Assault":
		# Code for "Aerial Assault" upgrade
		hitsFlying = true

	elif upgrade == "Nuke Lobber":
		# Code for "Nuke Lobber" upgrade
		nuke = true
		aoeDuration = max(2.5, aoeDuration)
		unboostedFireRate *= 2
		unboostedExplosionRadius *= 2
		unboostedDamage *= 1.5

	elif upgrade == "Damage++":
		# Code for "Damage++" upgrade
		unboostedDamage *= 1.15

	elif upgrade == "Bullet Speed++":
		# Code for "Bullet Speed++" upgrade
		unboostedBulletSpeed *= 1.15

	elif upgrade == "Range+":
		# Code for "Range+" upgrade
		unboostedRange *= 1.1

	elif upgrade == "Molten Shells":
		# Code for "Molten Shells" upgrade
		fire = true
		aoeDuration = max(2.5, aoeDuration)

	else:
		print("Upgrade not found.")
		
	updateSprite(upgrade)

func updateSprite(upgrade: String) -> void:
	if ownedUpgrades.size() == upgrades.size():
		barrel.texture = load("res://Assets/Buildings/Towers/Mortar/mortar_max.png")
		sprite.texture = load("res://Assets/Buildings/Towers/Mortar/mortar_max_base.png")
		return
		
	var baseString:String
	var string:String
	
	if upgrade == "Bullet Speed+":
		# Code for "Bullet Speed+" upgrade
		baseString = "res://Assets/Buildings/Towers/Mortar/mortar_1"

	elif upgrade == "AOE+":
		# Code for "AOE+" upgrade
		string = "res://Assets/Buildings/Towers/Mortar/mortar_2"

	elif upgrade == "Firerate++":
		# Code for "Firerate++" upgrade
		baseString = "res://Assets/Buildings/Towers/Mortar/mortar_a0"

	elif upgrade == "Camo Vision":
		# Code for "Camo Vision" upgrade
		string = "res://Assets/Buildings/Towers/Mortar/mortar_a1"

	elif upgrade == "Bullet Speed+++":
		# Code for "Bullet Speed+++" upgrade
		string = "res://Assets/Buildings/Towers/Mortar/mortar_a2"

	elif upgrade == "Shrapnel Shots":
		# Code for "Shrapnel Shots" upgrade
		string = "res://Assets/Buildings/Towers/Mortar/mortar_a3"

	elif upgrade == "AOE++":
		# Code for "AOE++" upgrade
		string = "res://Assets/Buildings/Towers/Mortar/mortar_b0"

	elif upgrade == "Range++":
		# Code for "Range++" upgrade
		baseString = "res://Assets/Buildings/Towers/Mortar/mortar_b1"

	elif upgrade == "Aerial Assault":
		# Code for "Aerial Assault" upgrade
		string = "res://Assets/Buildings/Towers/Mortar/mortar_b2"
		baseString = "res://Assets/Buildings/Towers/Mortar/mortar_b2_base"

	elif upgrade == "Nuke Lobber":
		# Code for "Nuke Lobber" upgrade
		string = "res://Assets/Buildings/Towers/Mortar/mortar_b3"

	elif upgrade == "Damage++":
		# Code for "Damage++" upgrade
		baseString = "res://Assets/Buildings/Towers/Mortar/mortar_c0"

	elif upgrade == "Bullet Speed++":
		# Code for "Bullet Speed++" upgrade
		string = "res://Assets/Buildings/Towers/Mortar/mortar_c1"

	elif upgrade == "Range+":
		# Code for "Range+" upgrade
		string = "res://Assets/Buildings/Towers/Mortar/mortar_c2"

	elif upgrade == "Molten Shells":
		string = "res://Assets/Buildings/Towers/Mortar/mortar_c3"
		baseString = "res://Assets/Buildings/Towers/Mortar/mortar_c3_base"

	else:
		print("Upgrade not found.")
		return
		
	if mint:
		if string:
			barrel.texture = load(string + "_mint.png")
		if baseString:
			sprite.texture = load(baseString + "_mint.png")
	else:
		if string:
			barrel.texture = load(string + ".png")
		if baseString:
			sprite.texture = load(baseString + ".png")

	
func _process(delta):
	if not isInHand:
		if TimeScaler.time() - lastShotTime > fireRate:
			var target = getTarget()
			if target != null:
				var targetPos = target.global_position
				distanceToTarget = global_position.distance_to(targetPos)
				shoot(takeAim(targetPos), targetPos)
				lastShotTime = TimeScaler.time()
	
func updateBoosts():
	actualRange = unboostedRange * buffs[BUFFS.RANGE]
	RANGE = actualRange * actualRange
	
	damage = unboostedDamage * buffs[BUFFS.DAMAGE]
	
	fireRate = unboostedFireRate * 1/buffs[BUFFS.FIRERATE]
	
	bulletSpeed = unboostedBulletSpeed * 1/buffs[BUFFS.BULLETSPEED]
	
	explosionRadius = unboostedExplosionRadius * buffs[BUFFS.EXPLOSIONRADIUS]
	seesCamo = (buffs[BUFFS.SEECAMO] == 2 or unboostedSeesCamo)
	
func takeAim(targetPos):
	var midpoint = Vector2()
	midpoint.x = (global_position.x + targetPos.x) / 2
	midpoint.y = (global_position.y + targetPos.y) / 2 - distanceToTarget
	return midpoint
	
func shoot(pointC, targetPos):
	playSound()
	
	var bulletInstance = bullet.instance()
	bulletInstance.global_position = global_position
	bulletInstance.positionA = global_position
	bulletInstance.positionB = targetPos
	bulletInstance.positionC = pointC
	bulletInstance.duration = distanceToTarget / 100 * bulletSpeed
	bulletInstance.z_index = 4
	bulletInstance.explosionRadius = explosionRadius * explosionRadius
	bulletInstance.realExplosionRadius = explosionRadius
	bulletInstance.damage = damage
	bulletInstance.explosdingDuration = aoeDuration
	bulletInstance.shrapnel = shrapnel
	bulletInstance.fire = fire
	bulletInstance.nuke = nuke
	bulletInstance.hitsFlying = hitsFlying
	bulletInstance.barrel = barrel
	
	if shrapnel:
		bulletInstance.game = game
		
	
	game.add_child(bulletInstance)
	

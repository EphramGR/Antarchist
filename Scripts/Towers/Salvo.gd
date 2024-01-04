extends Tower

var bullet = preload("res://Scenes/Rocket.tscn")

onready var front = get_node("Sprite")
onready var back = get_node("Sprite2")
onready var barrel = get_node("Barrel")

#logic
var lastShotTime = 0
var distanceToTarget
var reloading = false
var firedBullets = 0
var lastReloadTime = 0

#settings
#unboosted
var unboostedRange = 150* Perks.rangeMultiplier
var unboostedShotDelay = 100
var unboostedReloadTime = 4000
var unboostedDamage = 45
var unboostedBulletSpeed = 0.3/Perks.bulletSpeedMultiplier
var unboostedExplosionRadius = 20

var bulletSpeed = unboostedBulletSpeed #inverse

var shotDelay = 100/ Perks.firerateMultiplier
var reloadTime = 4000/ Perks.firerateMultiplier
var damage = 100
var explosionRadius = 20

var numXBullets = 3
var numYbullets = 2 #5 by 2
var totalBullets = 6

var passiveReload = false
var homing = false
var DoT = false
var explosdingDuration = 0.3

var sounds = [
	preload("res://Assets/Music/soundEffects/shoot/shoot.wav"),
	preload("res://Assets/Music/soundEffects/shoot/shoot1.wav"),
	preload("res://Assets/Music/soundEffects/shoot/shoot2.wav"),
	preload("res://Assets/Music/soundEffects/shoot/shoot3.wav")
]
onready var audioPlayer = get_node("AudioStreamPlayer2D")


func _ready():	
	actualRange = unboostedRange
	RANGE = actualRange * actualRange
	
	updatePerkTree()
	
	if mint:
		barrel.texture = load("res://Assets/Buildings/Towers/Salvo/salvo_0_barrel_mint.png")
		front.texture = load("res://Assets/Buildings/Towers/Salvo/salvo_0_front_mint.png")
		back.texture = load("res://Assets/Buildings/Towers/Salvo/salvo_0_back_mint.png")
	
func playSound():
	var randomIndex = randi() % sounds.size()

	audioPlayer.stream = sounds[randomIndex]
	
	audioPlayer.volume_db = linear2db(Perks.shootVolume)

	audioPlayer.play()
	
func updateStats():
	stats = {
		"Damage":damage,
		"Range":actualRange,
		"Bullet Speed":1/bulletSpeed,
		"Number of Bullets":totalBullets,
		"Shot Delay":round(shotDelay/20)/100,
		"Reload Time":round(reloadTime/20)/100,
		"Explosion Radius":explosionRadius
	}
	
	if not unboostedSeesCamo:
		stats["Camo"] = false
	
	if passiveReload:
		stats["Passive Reload"] = "Active"
		
	if DoT:
		stats["Damage Over Time"] = "Active"
		
	if homing:
		stats["Direct Damage"] = "150%"
		stats["Splash Damage"] = "75%"
		
	if not hitsFlying:
		stats["Flying"] = true
		
	
		
func updatePerkTree():
	upgrades = {
		"4th Column":[],
		"AOE+":["4th Column"],
		"5th Column":["AOE+"],
		"Faster Reload":["5th Column"],
		"Damage+":["Range+"],
		"Range++":["Damage+"],
		"Flying Pikes":["Range++"],
		"Damage++":["Faster Reload"],
		"Fastest Reload":["Damage++"],
		"Passive Reload":["Fastest Reload"],
		"Range+":["5th Column"],
		"Firerate+":["Faster Reload"],
		"3rd Row":["Firerate+"],
		"Maximum Rockets":["3rd Row"],
		"AOE++":["Range+"],
		"Bullet Speed++":["AOE++"],
		"Firework Launcher":["Bullet Speed++"]
		#firework launcher, more aoe, damage, and hits ait + aditional damage to air (but shoot slower?)
	}
	descriptions = {
		"4th Column":"Gains another column, holding more missles.",
		"AOE+":"Increases explosive radius by x%.",
		"5th Column":"Gains another column, holding more missles.",
		"Faster Reload":"Decreases reload time by x%.",
		"Firerate+":"Increases firerate by x%.",
		"3rd Row":"Gains another row, holding more missles.",
		"Maximum Rockets":"Gains another column and a row, holding many more missles.",
		"Damage++":"Increases damage by x%.",
		"Fastest Reload":"Decreases reload time by x%.",
		"Passive Reload":"Doesn't wait until missles are depleated to reload, it's always reloading",
		"Range+":"Increases range by x%.",
		"Damage+":"Increases damage by x%.",
		"Range++":"Increases range by x%.",
		"Flying Pikes":"Missles turn into pikes, dealing less splash damage, but WAY more direct damage.",
		"AOE++":"Increases explosive radius by x%.",
		"Bullet Speed++":"Increases bullet speed by x%.",
		"Firework Launcher":"Can hit air, and leaves a damage over time effect where shot explodes."
	}
	upgradeSprites = {
		"AOE+": Perks.defaultUpgradeSprites[Perks.baseUpgrades.AOE],
		"Faster Reload": Perks.defaultUpgradeSprites[Perks.baseUpgrades.RECHARGE],
		"Firerate+": Perks.defaultUpgradeSprites[Perks.baseUpgrades.FIRERATE],
		"Damage++": Perks.defaultUpgradeSprites[Perks.baseUpgrades.DAMAGE],
		"Fastest Reload": Perks.defaultUpgradeSprites[Perks.baseUpgrades.RECHARGE],
		"Range+": Perks.defaultUpgradeSprites[Perks.baseUpgrades.RANGE],
		"Damage+": Perks.defaultUpgradeSprites[Perks.baseUpgrades.DAMAGE],
		"Range++": Perks.defaultUpgradeSprites[Perks.baseUpgrades.RANGE],
		"AOE++": Perks.defaultUpgradeSprites[Perks.baseUpgrades.AOE],
		"Bullet Speed++": Perks.defaultUpgradeSprites[Perks.baseUpgrades.BULLETSPEED],
		"4th Column": Perks.salvoUpgrades[Perks.salvo.fourthColumn],
		"5th Column": Perks.salvoUpgrades[Perks.salvo.fifthColumn],
		"3rd Row": Perks.salvoUpgrades[Perks.salvo.thirdRow],
		"Maximum Rockets": Perks.salvoUpgrades[Perks.salvo.maxRockets],
		"Passive Reload": Perks.salvoUpgrades[Perks.salvo.passive],
		"Flying Pikes": Perks.salvoUpgrades[Perks.salvo.pikes],
		"Firework Launcher": Perks.salvoUpgrades[Perks.salvo.firework]
	}
	prices = {
		"4th Column": 300*Perks.upgradeCostMult,
		"AOE+": 200*Perks.upgradeCostMult,
		"5th Column": 500*Perks.upgradeCostMult,
		"Faster Reload": 250*Perks.upgradeCostMult,
		"Firerate+": 225*Perks.upgradeCostMult,
		"3rd Row": 800*Perks.upgradeCostMult,
		"Maximum Rockets": 3250*Perks.upgradeCostMult,
		"Damage++": 225*Perks.upgradeCostMult,
		"Fastest Reload": 250*Perks.upgradeCostMult,
		"Passive Reload": 3000*Perks.upgradeCostMult,
		"Range+": 200*Perks.upgradeCostMult,
		"Damage+": 225*Perks.upgradeCostMult,
		"Range++": 225*Perks.upgradeCostMult,
		"Flying Pikes": 2750*Perks.upgradeCostMult,
		"AOE++": 225*Perks.upgradeCostMult,
		"Bullet Speed++": 250*Perks.upgradeCostMult,
		"Firework Launcher": 3500*Perks.upgradeCostMult
	}

	
func updateUpgrade(upgrade: String) -> void:
	if upgrade == "4th Column":
		# Code for "4th Column" upgrade
		numXBullets += 1

	elif upgrade == "AOE+":
		# Code for "AOE+" upgrade
		unboostedExplosionRadius *= 1.1

	elif upgrade == "5th Column":
		# Code for "5th Column" upgrade
		numXBullets += 1

	elif upgrade == "Faster Reload":
		# Code for "Faster Reload" upgrade
		unboostedReloadTime *= 0.9

	elif upgrade == "Firerate+":
		# Code for "Firerate+" upgrade
		unboostedShotDelay *= 0.9

	elif upgrade == "3rd Row":
		# Code for "3rd Row" upgrade
		numYbullets += 1

	elif upgrade == "Maximum Rockets":
		# Code for "Maximum Rockets" upgrade
		numXBullets += 1
		numYbullets += 1

	elif upgrade == "Damage++":
		# Code for "Damage++" upgrade
		unboostedDamage *= 1.15

	elif upgrade == "Fastest Reload":
		# Code for "Fastest Reload" upgrade
		unboostedReloadTime *= 0.85

	elif upgrade == "Passive Reload":
		# Code for "Passive Reload" upgrade
		passiveReload = true

	elif upgrade == "Range+":
		# Code for "Range+" upgrade
		unboostedRange *= 1.1

	elif upgrade == "Damage+":
		# Code for "Damage+" upgrade
		unboostedDamage *= 1.1

	elif upgrade == "Range++":
		# Code for "Range++" upgrade
		unboostedRange *= 1.5

	elif upgrade == "Flying Pikes":
		# Code for "Homing Missiles" upgrade
		homing = true

	elif upgrade == "AOE++":
		# Code for "AOE++" upgrade
		unboostedExplosionRadius *= 1.15

	elif upgrade == "Bullet Speed++":
		# Code for "Bullet Speed++" upgrade
		unboostedBulletSpeed *= 1.15

	elif upgrade == "Firework Launcher":
		# Code for "Aerial Assault" upgrade
		hitsFlying = true
		DoT = true
		explosdingDuration = 2

	else:
		print("Upgrade not found.")
		
	updateSprite(upgrade)
		
func updateSprite(upgrade: String) -> void:
	if ownedUpgrades.size() == upgrades.size():
		barrel.texture = load("res://Assets/Buildings/Towers/Salvo/salvo_max.png")
		front.texture = load("res://Assets/Buildings/Towers/Salvo/salvo_base_front_max.png")
		back.texture = load("res://Assets/Buildings/Towers/Salvo/salvo_base_back_max.png")
		return
		
	var baseString:String
	var string:String
	
	if upgrade == "4th Column":
		# Code for "4th Column" upgrade
		string = "res://Assets/Buildings/Towers/Salvo/salvo_1"

	elif upgrade == "AOE+":
		# Code for "AOE+" upgrade
		baseString = "res://Assets/Buildings/Towers/Salvo/salvo_2"

	elif upgrade == "5th Column":
		# Code for "5th Column" upgrade
		string = "res://Assets/Buildings/Towers/Salvo/salvo_3"

	elif upgrade == "Faster Reload":
		# Code for "Faster Reload" upgrade
		baseString = "res://Assets/Buildings/Towers/Salvo/salvo_b0"

	elif upgrade == "Firerate+":
		# Code for "Firerate+" upgrade
		string = "res://Assets/Buildings/Towers/Salvo/salvo_bb0"

	elif upgrade == "3rd Row":
		# Code for "3rd Row" upgrade
		string = "res://Assets/Buildings/Towers/Salvo/salvo_bb1"

	elif upgrade == "Maximum Rockets":
		# Code for "Maximum Rockets" upgrade
		string = "res://Assets/Buildings/Towers/Salvo/salvo_bb2"

	elif upgrade == "Damage++":
		# Code for "Damage++" upgrade
		baseString = "res://Assets/Buildings/Towers/Salvo/salvo_ba0"

	elif upgrade == "Fastest Reload":
		# Code for "Fastest Reload" upgrade
		baseString = "res://Assets/Buildings/Towers/Salvo/salvo_ba1"

	elif upgrade == "Passive Reload":
		# Code for "Passive Reload" upgrade
		baseString = "res://Assets/Buildings/Towers/Salvo/salvo_ba2"

	elif upgrade == "Range+":
		# Code for "Range+" upgrade
		string = "res://Assets/Buildings/Towers/Salvo/salvo_a0"

	elif upgrade == "Damage+":
		# Code for "Damage+" upgrade
		string = "res://Assets/Buildings/Towers/Salvo/salvo_aa0"

	elif upgrade == "Range++":
		# Code for "Range++" upgrade
		string = "res://Assets/Buildings/Towers/Salvo/salvo_aa1"

	elif upgrade == "Flying Pikes":
		# Code for "Homing Missiles" upgrade
		string = "res://Assets/Buildings/Towers/Salvo/salvo_aa2"

	elif upgrade == "AOE++":
		# Code for "AOE++" upgrade
		string = "res://Assets/Buildings/Towers/Salvo/salvo_ab0"

	elif upgrade == "Bullet Speed++":
		# Code for "Bullet Speed++" upgrade
		string = "res://Assets/Buildings/Towers/Salvo/salvo_ab1"

	elif upgrade == "Firework Launcher":
		# Code for "Aerial Assault" upgrade
		string = "res://Assets/Buildings/Towers/Salvo/salvo_ab2"
		
	else:
		print("Upgrade not found.")
		return
		
	if mint:
		if string:
			barrel.texture = load(string + "_mint.png")
		elif baseString:
			front.texture = load(baseString + "_front_mint.png")
			back.texture = load(baseString + "_back_mint.png")
	else:
		if string:
			barrel.texture = load(string + ".png")
		elif baseString:
			front.texture = load(baseString + "_front.png")
			back.texture = load(baseString + "_back.png")
		

		
func printBreakDown():
	print("Damage: ", damage, "\nRange: ", unboostedRange, "\nAOE: ", explosionRadius, "\nHoming: ", homing, "\nBulletSpeed: ", bulletSpeed)
	
func updateBoosts():
	actualRange = unboostedRange * buffs[BUFFS.RANGE]
	RANGE = actualRange * actualRange
	
	damage = unboostedDamage * buffs[BUFFS.DAMAGE]
	
	shotDelay = unboostedShotDelay * 1/buffs[BUFFS.FIRERATE]
	reloadTime = unboostedReloadTime * 1/buffs[BUFFS.FIRERATE]
	
	bulletSpeed = unboostedBulletSpeed * 1/buffs[BUFFS.BULLETSPEED]
	
	explosionRadius = unboostedExplosionRadius * buffs[BUFFS.EXPLOSIONRADIUS]
	
	totalBullets = numXBullets*numYbullets
	seesCamo = (buffs[BUFFS.SEECAMO] == 2 or unboostedSeesCamo)
	#print(totalBullets)
	
func _process(delta):
	if not isInHand:
		if reloading and not passiveReload:
			if TimeScaler.time() - lastShotTime > reloadTime:
				lastShotTime = 0
				reloading = false
				firedBullets = 0
				
		elif TimeScaler.time() - lastShotTime > shotDelay:
			if firedBullets < totalBullets:
				var target = getTarget()
				if target != null:
					var targetPos = target.global_position
					distanceToTarget = global_position.distance_to(targetPos)
					shoot(takeAim(targetPos), targetPos, target)
					lastShotTime = TimeScaler.time()
					
					firedBullets += 1
					
					rotate(global_position.angle_to_point(targetPos))
					
					#print(totalBullets-firedBullets)
					if firedBullets >= totalBullets:
						reloading = true
						lastReloadTime = TimeScaler.time()
		
		if passiveReload and firedBullets > 0:
			if TimeScaler.time() - lastReloadTime > reloadTime/totalBullets:
				firedBullets -= 1
				lastReloadTime = TimeScaler.time()
				#print(totalBullets-firedBullets)
				
				
func rotate(angle:float)->void:
	if angle > PI/2 or angle < -1*PI/2:
		front.flip_h = true
		back.flip_h = true
		barrel.flip_h = true
		
		barrel.rotation = (-angle+PI/4)/2
		
	else:
		front.flip_h = false
		back.flip_h = false
		barrel.flip_h = false
	
		barrel.rotation = (angle-PI/4)/2
	
func takeAim(targetPos):
	var midpoint = Vector2()
	midpoint.x = (global_position.x + targetPos.x) / 2 + (global_position.x - targetPos.x)/2
	midpoint.y = (global_position.y + targetPos.y) / 2 - abs(global_position.x - targetPos.x)/2
	
	#print(global_position, ">", midpoint, ">", targetPos)
	return midpoint
	
#WILL NEED TO MKAE ALL BULLETS INHERIT CAN HIT FLYING
func shoot(pointC, targetPos, target):
	var bulletInstance = bullet.instance()
	bulletInstance.global_position = global_position
	bulletInstance.visible = false 
	bulletInstance.positionA = global_position
	bulletInstance.positionB = targetPos
	bulletInstance.positionC = pointC
	bulletInstance.duration = distanceToTarget / 100 * bulletSpeed
	bulletInstance.damage = damage
	bulletInstance.explosionRadius = explosionRadius * explosionRadius
	bulletInstance.realExplosionRadius = explosionRadius
	bulletInstance.homing = homing
	bulletInstance.hitsFlying = hitsFlying
	bulletInstance.target = target
		
	bulletInstance.DoT = DoT
	bulletInstance.explosdingDuration = explosdingDuration
	bulletInstance.z_index = 4
	game.add_child(bulletInstance)
	
	playSound()
	

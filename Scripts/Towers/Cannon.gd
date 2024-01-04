extends Tower

var bullet = preload("res://Scenes/CannonBall.tscn")
onready var front = get_node("Sprite")
onready var back = get_node("Sprite2")
onready var barrel = get_node("barrel")

onready var shootPos = get_node("barrel/shootPos")
#references
#var game

#logic
var lastShotTime = 0
#var distanceToTarget

#settings
var sounds = [
	preload("res://Assets/Music/soundEffects/shoot/shoot.wav"),
	preload("res://Assets/Music/soundEffects/shoot/shoot1.wav"),
	preload("res://Assets/Music/soundEffects/shoot/shoot2.wav"),
	preload("res://Assets/Music/soundEffects/shoot/shoot3.wav")
]
onready var audioPlayer = get_node("AudioStreamPlayer2D")


#unboosted
var unboostedRange = 150* Perks.rangeMultiplier
var unboostedFireRate = 1000/ Perks.firerateMultiplier
var unboostedDamage = 100
var unboostedBulletSpeed = 3*Perks.bulletSpeedMultiplier

var bulletSpeed = unboostedBulletSpeed

var fireRate = unboostedFireRate #ms, /1000 for s *2 cause time scale 0.5
var damage = 100
var despawnTime = 3
var bulletScale = 1
var pierce = false
var numBullets = 1
const offsetSize = 5



func _ready():	
	actualRange = unboostedRange
	RANGE = actualRange * actualRange
	
	updatePerkTree()
	
	if mint:
		front.texture = load("res://Assets/Buildings/Towers/Cannon/cannon_0_front_mint.png")
		back.texture = load("res://Assets/Buildings/Towers/Cannon/cannon_0_back_mint.png")
		barrel.texture = load("res://Assets/Buildings/Towers/Cannon/cannon_0_mint.png")
	
	
func playSound():
	var randomIndex = randi() % sounds.size()

	audioPlayer.stream = sounds[randomIndex]
	
	audioPlayer.volume_db = linear2db(Perks.shootVolume)

	audioPlayer.play()

func updateStats():
	stats = {
		"Damage":damage,
		"Firerate":round(fireRate/200)/10,
		"Bullet Speed":bulletSpeed,
		"Range":actualRange,
	}
	
	if not unboostedSeesCamo:
		stats["Camo"] = false
		
	if not hitsFlying:
		stats["Flying"] = false
	
	if numBullets > 1:
		stats["Number of Bullets"] = numBullets
	
func updatePerkTree():
	upgrades = {
		"Damage+":[],
		"Range+":["Damage+"],
		"Range++":["Range+"],
		"Heavy Shot":["Range++"],
		"Rolling Seidge":["Heavy Shot"],
		"Double Barrel":["Range+"],
		"Damage++":["Double Barrel"],
		"Triple Barrel":["Damage++"],
		"Firerate+":["Range+"],
		"Bullet Speed++":["Firerate+"],
		"Gatling Gun":["Bullet Speed++"]
	}
	descriptions = {
		"Damage+":"Increase damage by x percent.",
		"Range+":"Increase range by x percent.",
		"Range++":"Increase range by x percent.",
		"Heavy Shot":"Slow bullet speed and fire rate, but massively increase bullet damage and size.",
		"Rolling Seidge":"Cannonball does not break when hitting an ant, instead it continues to hit more.",
		"Double Barrel":"Shoots an additional bullet each shot, but slightly reduces damage.",
		"Damage++":"Increases damage by x percent.",
		"Triple Barrel":"Shoots an additional bullet each shot, but slightly reduces damage.",
		"Firerate+":"Increases Firerate by x percent.",
		"Bullet Speed++":"Increase bulletspeed by x percent.",
		"Gatling Gun":"Reduces cannonball size and damage, but firerate massively increased."
	}
	upgradeSprites = {
		"Damage+": Perks.defaultUpgradeSprites[Perks.baseUpgrades.DAMAGE],
		"Range+": Perks.defaultUpgradeSprites[Perks.baseUpgrades.RANGE],
		"Range++": Perks.defaultUpgradeSprites[Perks.baseUpgrades.RANGE],
		"Damage++": Perks.defaultUpgradeSprites[Perks.baseUpgrades.DAMAGE],
		"Firerate+": Perks.defaultUpgradeSprites[Perks.baseUpgrades.FIRERATE],
		"Bullet Speed++": Perks.defaultUpgradeSprites[Perks.baseUpgrades.BULLETSPEED],
		"Heavy Shot": Perks.cannonUpgrades[Perks.cannon.heavyShot],
		"Rolling Seidge": Perks.cannonUpgrades[Perks.cannon.rolling],
		"Double Barrel": Perks.cannonUpgrades[Perks.cannon.doubleBarrel],
		"Triple Barrel": Perks.cannonUpgrades[Perks.cannon.trippleBarrel],
		"Gatling Gun": Perks.cannonUpgrades[Perks.cannon.gattleing]
	}
	prices = {
		"Damage+": 150*Perks.upgradeCostMult,
		"Range+": 150*Perks.upgradeCostMult,
		"Range++": 250*Perks.upgradeCostMult,
		"Heavy Shot": 750*Perks.upgradeCostMult,
		"Rolling Seidge": 3500*Perks.upgradeCostMult,
		"Double Barrel": 1200*Perks.upgradeCostMult,
		"Damage++": 450*Perks.upgradeCostMult,
		"Triple Barrel": 3000*Perks.upgradeCostMult,
		"Firerate+": 200*Perks.upgradeCostMult,
		"Bullet Speed++": 300*Perks.upgradeCostMult,
		"Gatling Gun": 2750*Perks.upgradeCostMult
	}

	
func updateUpgrade(upgrade: String) -> void:
	if upgrade == "Damage+":
		# Code for "Damage+" upgrade
		unboostedDamage *= 1.1

	elif upgrade == "Range+":
		# Code for "Range+" upgrade
		unboostedRange *= 1.25

	elif upgrade == "Range++":
		# Code for "Range++" upgrade
		unboostedRange *= 1.25

	elif upgrade == "Heavy Shot":
		# Code for "Heavy Shot" upgrade
		unboostedBulletSpeed *= 0.5
		unboostedFireRate *= 1.5
		unboostedDamage *= 2.5
		bulletScale *= 2

	elif upgrade == "Rolling Seidge":
		# Code for "Rolling Seidge" upgrade
		pierce = true

	elif upgrade == "Double Barrel":
		# Code for "Double Barrel" upgrade
		numBullets = 2

	elif upgrade == "Damage++":
		# Code for "Damage++" upgrade
		unboostedDamage *= 1.25

	elif upgrade == "Triple Barrel":
		# Code for "Triple Barrel" upgrade
		numBullets = 3

	elif upgrade == "Firerate+":
		# Code for "Firerate+" upgrade
		unboostedFireRate *= 0.9

	elif upgrade == "Bullet Speed++":
		# Code for "Increase Bullet Speed" upgrade
		unboostedBulletSpeed *= 1.5

	elif upgrade == "Gatling Gun":
		# Code for "Gatling Gun" upgrade
		bulletScale *= 0.4
		unboostedDamage *= 0.5
		unboostedFireRate *= 0.1

	else:
		print("Upgrade not found.")
		
	updateSprite(upgrade)
		
func updateSprite(upgrade: String) -> void:
	if ownedUpgrades.size() == upgrades.size():
		barrel.texture = load("res://Assets/Buildings/Towers/Cannon/cannon_max.png")
		front.texture = load("res://Assets/Buildings/Towers/Cannon/cannon_max_front.png")
		back.texture = load("res://Assets/Buildings/Towers/Cannon/cannon_max_back.png")
		return
		
	var baseString:String
	var string:String
	
	if upgrade == "Damage+":
		# Code for "Damage+" upgrade
		string = "res://Assets/Buildings/Towers/Cannon/cannon_1"

	elif upgrade == "Range+":
		# Code for "Range+" upgrade
		baseString = "res://Assets/Buildings/Towers/Cannon/cannon_2"

	elif upgrade == "Range++":
		# Code for "Range++" upgrade
		baseString = "res://Assets/Buildings/Towers/Cannon/cannon_a0"

	elif upgrade == "Heavy Shot":
		# Code for "Heavy Shot" upgrade
		string = "res://Assets/Buildings/Towers/Cannon/cannon_a1"

	elif upgrade == "Rolling Seidge":
		# Code for "Rolling Seidge" upgrade
		string = "res://Assets/Buildings/Towers/Cannon/cannon_a2"

	elif upgrade == "Double Barrel":
		# Code for "Double Barrel" upgrade
		string = "res://Assets/Buildings/Towers/Cannon/cannon_b0"

	elif upgrade == "Damage++":
		# Code for "Damage++" upgrade
		baseString = "res://Assets/Buildings/Towers/Cannon/cannon_b1"

	elif upgrade == "Triple Barrel":
		# Code for "Triple Barrel" upgrade
		string = "res://Assets/Buildings/Towers/Cannon/cannon_b2"

	elif upgrade == "Firerate+":
		# Code for "Firerate+" upgrade
		baseString = "res://Assets/Buildings/Towers/Cannon/cannon_c0"

	elif upgrade == "Bullet Speed++":
		# Code for "Increase Bullet Speed" upgrade
		string = "res://Assets/Buildings/Towers/Cannon/cannon_c1"

	elif upgrade == "Gatling Gun":
		# Code for "Momentus Strike" upgrade
		string = "res://Assets/Buildings/Towers/Cannon/cannon_c2"

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
		

	
func _process(delta):
	if not isInHand:
		var target = getTarget()
		if target != null:
			rotateTowards(target.global_position)
		
		
			if TimeScaler.time() - lastShotTime > fireRate:
				var targetPos = target.global_position
				#distanceToTarget = global_position.distance_to(targetPos)
				for i in range(numBullets):
					shoot(targetPos, i)
					
				lastShotTime = TimeScaler.time()
	
func shoot(targetPos:Vector2, bulletNum:int):
	var bulletInstance = bullet.instance()
	
	if numBullets == 2 or (numBullets == 3 and bulletNum % 2 == 0):
		var bulletOffset = (targetPos - global_position).normalized()
		bulletOffset = Vector2(-bulletOffset.y, bulletOffset.x) * offsetSize
		
		if bulletNum == 0:
			bulletInstance.global_position = shootPos.global_position - bulletOffset
		else:
			bulletInstance.global_position = shootPos.global_position + bulletOffset
	else:
		bulletInstance.global_position = shootPos.global_position
	
	var vector = (targetPos - global_position).normalized() 
	#can to bulletInstance.global position, if you want side bullets to go to target
	
	bulletInstance.vector = vector * bulletSpeed
	bulletInstance.damage = damage
	bulletInstance.duration = despawnTime
	bulletInstance.z_index = 6
	bulletInstance.piercing = pierce
	bulletInstance.scale = Vector2(bulletScale, bulletScale)
	bulletInstance.hitsFlying = hitsFlying
	game.add_child(bulletInstance)
	
	playSound()
	

func rotateTowards(pos:Vector2)->void:
	var angle = global_position.angle_to_point(pos)

	angle -= PI/2
	#print(angle)
	
	if angle >= 0 or angle < -PI:
		front.flip_h = false
		back.flip_h = false
		barrel.flip_h = false
		
		barrel.rotation = angle
		barrel.position.x = 0.4
		
	else:
		front.flip_h = true
		back.flip_h = true
		barrel.flip_h = true
	
		barrel.rotation = angle
		barrel.position.x = -0.4
	

func updateBoosts():
	actualRange = unboostedRange * buffs[BUFFS.RANGE]
	RANGE = actualRange * actualRange
	
	fireRate = unboostedFireRate * 1/buffs[BUFFS.FIRERATE]
	
	damage = unboostedDamage * buffs[BUFFS.DAMAGE]
	
	bulletSpeed = unboostedBulletSpeed * buffs[BUFFS.BULLETSPEED]
	
	seesCamo = (buffs[BUFFS.SEECAMO] == 2 or unboostedSeesCamo)


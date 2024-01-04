extends Tower

"""

**NOTE**
May need to make all audio files local to scene. press the actual.wav, and select local to scene.

"""




var bullet = preload("res://Scenes/Flame.tscn")
onready var sprite = get_node("Sprite")
var target = null
var bulletInstance

#logic
var distanceToTarget
#onready var offsetVector = get_node("Sprite").texture.get_width()/scale.x

#settings
#unboosted
var unboostedRange = 100* Perks.rangeMultiplier
var unboostedFireRate = 200/ Perks.firerateMultiplier
var unboostedDamage = 15
var unboostedEffectDuration = 0.25

var damage = 15
var spread = 30
var tickRate = unboostedFireRate
var burnDuration = 0.25 #x2
var iceThrower = false #does nothin
var poisonThrower = false

onready var audioPlayer = get_node("AudioStreamPlayer2D")


func _ready():	
	#offsetVector = Vector2(offsetVector, -offsetVector)/2
	
	actualRange = unboostedRange
	RANGE = actualRange * actualRange
	
	bulletInstance = bullet.instance()
	updateFlame(true)
	bulletInstance.global_position = Vector2.ZERO
	game.add_child(bulletInstance)
	
	updatePerkTree()
	
	if mint:
		sprite.frames = load("res://Assets/Buildings/Towers/FlameThrower/flame_0_mint.tres")
		
	
	
func updateStats():
	stats = {
		"Damage":damage,
		"Range":actualRange,
		"Spread":spread,
		"Tick Rate":round(tickRate/20)/100,
		"Element Duration":burnDuration/2
	}
	
	if iceThrower:
		if poisonThrower:
			stats["Element"] = "Poison and Ice"
		else:
			stats["Element"] = "Ice"
	elif poisonThrower:
		stats["Element"] = "Poison"
	else:
		stats["Element"] = "Fire"
		
	if not hitsFlying:
		stats["Flying"] = true
		
	if not unboostedSeesCamo:
		stats["Camo"] = true
	
func updatePerkTree():
	upgrades = {
		"Damage+":[],
		"Camo Vision":[],
		"Aerial Assault":["Damage+", "Camo Vision"],
		"Tickrate+":["Aerial Assault"],
		"Element Duration+":["Tickrate+"],
		"Ice Thrower":["Element Duration+"],
		"Poison Thrower":["Element Duration+"],
		"Flank Shot":["Aerial Assault"],
		"Spread+":["Flank Shot"],
		"Quad Coverage":["Spread+"]
	}
	descriptions = {
		"Damage+":"Increases damage by x%.",
		"Camo Vision":"Can see camo ants.",
		"Aerial Assault":"Can hit flying ants.",
		"Tickrate+":"Increases damage tickrate by x%.",
		"Element Duration+":"Increases elemental duration by x%.",
		"Ice Thrower":"Adds slow effect to shot, but removes fire effect.",
		"Poison Thrower":"Adds poision effect to shot, but removes fire effect.",
		"Flank Shot":"Adds a barrel that shoots behind where it is aiming.",
		"Spread+":"Increases spread by x%.",
		"Quad Coverage":"Adds two barrels that shoots to the sides of where it is aiming."
	}
	upgradeSprites = {
		"Damage+": Perks.defaultUpgradeSprites[Perks.baseUpgrades.DAMAGE],
		"Camo Vision": Perks.defaultUpgradeSprites[Perks.baseUpgrades.CAMOVISION],
		"Aerial Assault": Perks.defaultUpgradeSprites[Perks.baseUpgrades.AERIALASSAULT],
		"Tickrate+": Perks.defaultUpgradeSprites[Perks.baseUpgrades.FIRERATE],
		"Element Duration+": Perks.defaultUpgradeSprites[Perks.baseUpgrades.ELEMENTDURATION],
		"Spread+": Perks.defaultUpgradeSprites[Perks.baseUpgrades.AOE],
		"Ice Thrower": Perks.flameUpgrades[Perks.flame.ice],
		"Poison Thrower": Perks.flameUpgrades[Perks.flame.poison],
		"Flank Shot": Perks.flameUpgrades[Perks.flame.flank],
		"Quad Coverage": Perks.flameUpgrades[Perks.flame.quad]
	}
	prices = {
		"Damage+": 150*Perks.upgradeCostMult,
		"Camo Vision": 200*Perks.upgradeCostMult,
		"Aerial Assault": 200*Perks.upgradeCostMult,
		"Tickrate+": 150*Perks.upgradeCostMult,
		"Element Duration+": 225*Perks.upgradeCostMult,
		"Ice Thrower": 2000*Perks.upgradeCostMult,
		"Poison Thrower": 2750*Perks.upgradeCostMult,
		"Flank Shot": 1000*Perks.upgradeCostMult,
		"Spread+": 300*Perks.upgradeCostMult,
		"Quad Coverage": 3000*Perks.upgradeCostMult
	}

	
func updateUpgrade(upgrade: String) -> void:
	if upgrade == "Damage+":
		# Code for "Damage+" upgrade
		unboostedDamage *= 1.1

	elif upgrade == "Camo Vision":
		# Code for "Camo Vision" upgrade
		unboostedSeesCamo = true

	elif upgrade == "Aerial Assault":
		# Code for "Aerial Assault" upgrade
		hitsFlying = true

	elif upgrade == "Tickrate+":
		# Code for "Tickrate+" upgrade
		unboostedFireRate *= 0.9 #might not update bullet

	elif upgrade == "Element Duration+":
		# Code for "Element Duration+" upgrade
		unboostedEffectDuration *= 1.1

	elif upgrade == "Ice Thrower":
		# Code for "Ice Thrower" upgrade
		iceThrower = true

	elif upgrade == "Poison Thrower":
		# Code for "Poison Thrower" upgrade
		poisonThrower = true

	elif upgrade == "Flank Shot":
		# Code for "Flank Shot" upgrade
		var anotherFlame = bulletInstance.get_node("CPUParticles2D").duplicate()
		bulletInstance.particles.append(anotherFlame)
		bulletInstance.add_child(anotherFlame)
		

	elif upgrade == "Spread+":
		# Code for "Spread+" upgrade
		spread *= 1.5

	elif upgrade == "Quad Coverage":
		# Code for "Quad Coverage" upgrade
		var anotherFlame = bulletInstance.get_node("CPUParticles2D").duplicate()
		bulletInstance.particles.append(anotherFlame)
		bulletInstance.add_child(anotherFlame)
		
		anotherFlame = bulletInstance.get_node("CPUParticles2D").duplicate()
		bulletInstance.particles.append(anotherFlame)
		bulletInstance.add_child(anotherFlame)

	else:
		print("Upgrade not found.")
	
	updateSprite(upgrade)
		
func updateSprite(upgrade: String) -> void:
	if ownedUpgrades.size() == upgrades.size():
		sprite.frames = load("res://Assets/Buildings/Towers/FlameThrower/flame_max.tres")
		return
		
	var string:String
	
	if upgrade == "Damage+":
		# Code for "Damage+" upgrade
		if "Camo Vision" in ownedUpgrades:
			string = "res://Assets/Buildings/Towers/FlameThrower/flame_11"
		else:
			string = "res://Assets/Buildings/Towers/FlameThrower/flame_01"

	elif upgrade == "Camo Vision":
		# Code for "Camo Vision" upgrade
		if "Damage+" in ownedUpgrades:
			string = "res://Assets/Buildings/Towers/FlameThrower/flame_11"
		else:
			string = "res://Assets/Buildings/Towers/FlameThrower/flame_10"
		

	elif upgrade == "Aerial Assault":
		# Code for "Aerial Assault" upgrade
		string = "res://Assets/Buildings/Towers/FlameThrower/flame_2"
		

	elif upgrade == "Tickrate+":
		# Code for "Tickrate+" upgrade
		string = "res://Assets/Buildings/Towers/FlameThrower/flame_a0"
		

	elif upgrade == "Element Duration+":
		# Code for "Element Duration+" upgrade
		string = "res://Assets/Buildings/Towers/FlameThrower/flame_a1"
		

	elif upgrade == "Ice Thrower":
		# Code for "Ice Thrower" upgrade
		string = "res://Assets/Buildings/Towers/FlameThrower/flame_aa"
		

	elif upgrade == "Poison Thrower":
		# Code for "Poison Thrower" upgrade
		string = "res://Assets/Buildings/Towers/FlameThrower/flame_ab"
		

	elif upgrade == "Flank Shot":
		# Code for "Flank Shot" upgrade
		string = "res://Assets/Buildings/Towers/FlameThrower/flame_b0"
		
		

	elif upgrade == "Spread+":
		# Code for "Spread+" upgrade
		string = "res://Assets/Buildings/Towers/FlameThrower/flame_b1"
		

	elif upgrade == "Quad Coverage":
		string = "res://Assets/Buildings/Towers/FlameThrower/flame_b2"
		

	else:
		print("Upgrade not found.")
		return
		
	if mint:
		sprite.frames = load(string + "_mint.tres")
	else:
		sprite.frames = load(string + ".tres")

	
func _process(delta):
	if not isInHand:
		if target == null:
			target = getTarget()
			if target != null:
				rotateTowards(target.global_position)
				bulletInstance.target = target
				bulletInstance.toggle()
				toggleSound(true)
		elif is_instance_valid(target):
			rotateTowards(target.global_position)
			
func toggleSound(enable: bool):
	if enable:
		audioPlayer.volume_db = linear2db(Perks.shootVolume)
		audioPlayer.play()
	else:
		audioPlayer.stop()

			
func rotateTowards(pos:Vector2)->void:
	var angle = global_position.angle_to_point(pos)
	print(angle)
	"""
		PI/2
		 |   PI*3/4
	0 ________ PI/-PI
		 |   -PI*3/4
	   -PI/2
	"""
	
	if angle <= PI/2 and angle > -PI/2:
		sprite.flip_h = true
		
		if angle >= 0:
			angle = PI - angle
		else:
			angle = -PI - angle
	else:
		sprite.flip_h = false
		
	if angle > PI*7/8 or angle < -PI*7/8:
		sprite.frame = 2
	elif angle > PI*5/8:
		sprite.frame = 3
	elif angle < -PI*5/8:
		sprite.frame = 1
	elif angle > 0:
		sprite.frame = 4
	else:
		sprite.frame = 0
	
	

func updateBoosts():
	actualRange = unboostedRange * buffs[BUFFS.RANGE]
	RANGE = actualRange * actualRange
	
	damage = unboostedDamage * buffs[BUFFS.DAMAGE]
	
	tickRate = unboostedFireRate *1/buffs[BUFFS.FIRERATE]
	
	burnDuration = unboostedEffectDuration * buffs[BUFFS.EFFECTDURATION]
	seesCamo = (buffs[BUFFS.SEECAMO] == 2 or unboostedSeesCamo)
	
	updateFlame()
	
	
func updateFlame(first:bool = false):
	bulletInstance.z_index = 4
	bulletInstance.tower = self
	bulletInstance.target = target
	bulletInstance.damage = damage
	bulletInstance.tickRate = tickRate
	bulletInstance.RANGE = RANGE
	bulletInstance.spread = spread
	bulletInstance.burnDuration = burnDuration
	bulletInstance.slow = iceThrower
	bulletInstance.poison = poisonThrower
	if not first:
		bulletInstance.updateUpgrades()
		
func updatePosition(newPos:Vector2):
	global_position = newPos
	if bulletInstance != null:
		bulletInstance.updateParticlePosition(newPos)
	
func placed():
	bulletInstance.unlock = true
	bulletInstance.updateParticlePosition(global_position)
	
func cleanUp():
	bulletInstance.queue_free()



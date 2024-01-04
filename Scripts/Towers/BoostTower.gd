extends Tower

onready var sprite = get_node("Sprite")

onready var collision = get_node("BoostHitbox/CollisionShape2D")
const bullet = preload("res://Scenes/Pike.tscn")

var buffsGiven = {BUFFS.DAMAGE:1, BUFFS.RANGE:1.1, BUFFS.FIRERATE:1, BUFFS.BULLETSPEED:1, BUFFS.EXPLOSIONRADIUS:1, BUFFS.EFFECTDURATION:1, BUFFS.COSTREDUCTION:1, BUFFS.SEECAMO:1, BUFFS.HITSFLYING:1}

var unboostedRange = 150* Perks.rangeMultiplier

var boostedTowers = []

var lastAntsInRange = {}
var valueAnt = false
const bonus = 1.5

var goldenGlove = false
var lastShotTime = 0
const firerate = 1000

func _ready():	
	updateRange(unboostedRange)
	
	updatePerkTree()
	
	if mint:
		sprite.texture = load("res://Assets/Buildings/Towers/Boost/boost_0_mint.png")
	
func updateStats():
	stats = {
		"Range Buff":String((buffsGiven[BUFFS.RANGE]-1)*100)+"%"
	}
	
	if buffsGiven[BUFFS.DAMAGE] > 1:
		stats["Damage Buff"] = String((buffsGiven[BUFFS.DAMAGE]-1)*100)+"%"
		
	if buffsGiven[BUFFS.FIRERATE] > 1:
		stats["Firerate Buff"] = String((buffsGiven[BUFFS.FIRERATE]-1)*100)+"%"
		
	if buffsGiven[BUFFS.BULLETSPEED] > 1:
		stats["Bullet Speed Buff"] = String((buffsGiven[BUFFS.BULLETSPEED]-1)*100)+"%"
		
	if buffsGiven[BUFFS.EXPLOSIONRADIUS] > 1:
		stats["Explosion Radius Buff"] = String((buffsGiven[BUFFS.EXPLOSIONRADIUS]-1)*100)+"%"
		
	if buffsGiven[BUFFS.EFFECTDURATION] > 1:
		stats["Effect Duration Buff"] = String((buffsGiven[BUFFS.EFFECTDURATION]-1)*100)+"%"
		
	if buffsGiven[BUFFS.COSTREDUCTION] > 1:
		stats["Upgrade Cost Reduction"] = String((buffsGiven[BUFFS.COSTREDUCTION]-1)*100)+"%"
		
	if buffsGiven[BUFFS.SEECAMO] > 1:
		stats["See Camo Buff"] = "Active"
		
	if buffsGiven[BUFFS.HITSFLYING] > 1:
		stats["Hits Flying"] = "Active"
	
	
func updatePerkTree():
	upgrades = {
		"Firerate Boost":[],
		"Further Range Boost":["Firerate Boost"],
		"Cheaper Upgrades":["Further Range Boost"],
		"Valueable Ants":["Cheaper Upgrades"],
		"Golden Glove":["Valueable Ants"],
		"Damage Boost":["Further Range Boost"],
		"AOE Boost":["Damage Boost"],
		"Killer Instinct":["AOE Boost"],
		"Elemental Duration Boost":["Further Range Boost"],
		"Maximum Range Boost":["Elemental Duration Boost"],
		"Third Eye":["Maximum Range Boost"]
	}
	descriptions = {
		"Firerate Boost":"Increase the firerate of towers in range by 10%.",
		"Further Range Boost":"Increase the firerate of towers in range from 10% to 25%.",
		"Cheaper Upgrades":"Decreases the cost of upgrades for the towers in range by 25%.",
		"Valueable Ants":"All ants that die within radius drop 50% more cash.",
		"Golden Glove":"Gains a boxing glove that deals low damage. If this kills an ant, it drops 1000% more cash",
		"Damage Boost":"Increase the damage of towers in range by 10%.",
		"AOE Boost":"Increase the explosive radius of towers in range by 15%.",
		"Killer Instinct":"Increase the bullet speed by 25%, damage from 10% to 15%, and explosion radius from 15% to 25%.",
		"Elemental Duration Boost":"Increase the elemental duration of towers in range by 25%.",
		"Maximum Range Boost":"Increase the range of towers in range from 25% to 50%.",
		"Third Eye":"Allows towers within range to detect camos, and gives them 66% range bonus."
	}
	upgradeSprites = {
		"Firerate Boost": Perks.defaultUpgradeSprites[Perks.baseUpgrades.FIRERATE],
		"Further Range Boost": Perks.defaultUpgradeSprites[Perks.baseUpgrades.RANGE],
		"Damage Boost": Perks.defaultUpgradeSprites[Perks.baseUpgrades.DAMAGE],
		"AOE Boost": Perks.defaultUpgradeSprites[Perks.baseUpgrades.AOE],
		"Elemental Duration Boost": Perks.defaultUpgradeSprites[Perks.baseUpgrades.ELEMENTDURATION],
		"Maximum Range Boost": Perks.defaultUpgradeSprites[Perks.baseUpgrades.RANGE],
		"Cheaper Upgrades": Perks.boostUpgrades[Perks.boost.cheaper],
		"Valueable Ants": Perks.boostUpgrades[Perks.boost.valueAble],
		"Golden Glove": Perks.boostUpgrades[Perks.boost.goldenGlove],
		"Killer Instinct": Perks.boostUpgrades[Perks.boost.killer],
		"Third Eye": Perks.boostUpgrades[Perks.boost.thirdEye]
	}
	prices = {
		"Firerate Boost": 150*Perks.upgradeCostMult,
		"Further Range Boost": 200*Perks.upgradeCostMult,
		"Cheaper Upgrades": 1000*Perks.upgradeCostMult,
		"Valueable Ants": 1250*Perks.upgradeCostMult,
		"Golden Glove": 2000*Perks.upgradeCostMult,
		"Damage Boost": 250*Perks.upgradeCostMult,
		"AOE Boost": 450*Perks.upgradeCostMult,
		"Killer Instinct": 2250*Perks.upgradeCostMult,
		"Elemental Duration Boost": 300*Perks.upgradeCostMult,
		"Maximum Range Boost": 1000*Perks.upgradeCostMult,
		"Third Eye": 2500*Perks.upgradeCostMult
	}

	
func updateUpgrade(upgrade: String) -> void:
	if upgrade == "Firerate Boost":
		# Code for "Firerate Boost" upgrade
		buffsGiven[BUFFS.FIRERATE] = 1.1

	elif upgrade == "Further Range Boost":
		# Code for "Further Range Boost" upgrade
		buffsGiven[BUFFS.RANGE] = 1.25

	elif upgrade == "Cheaper Upgrades":
		# Code for "Cheaper Upgrades" upgrade
		buffsGiven[BUFFS.COSTREDUCTION] = 1.25

	elif upgrade == "Valueable Ants":
		# Code for "Valueable Ants" upgrade
		valueAnt = true

	elif upgrade == "Golden Glove":
		# Code for "Golden Glove" upgrade
		goldenGlove = true #to drop extra cash do to pike

	elif upgrade == "Damage Boost":
		# Code for "Damage Boost" upgrade
		buffsGiven[BUFFS.DAMAGE] = 1.1

	elif upgrade == "AOE Boost":
		# Code for "AOE Boost" upgrade
		buffsGiven[BUFFS.EXPLOSIONRADIUS] = 1.15

	elif upgrade == "Killer Instinct":
		# Code for "Killer Instinct" upgrade
		buffsGiven[BUFFS.BULLETSPEED] = 1.25
		buffsGiven[BUFFS.DAMAGE] = 1.15
		buffsGiven[BUFFS.EXPLOSIONRADIUS] = 1.25

	elif upgrade == "Elemental Duration Boost":
		# Code for "Elemental Duration Boost" upgrade
		buffsGiven[BUFFS.EFFECTDURATION] = 1.25

	elif upgrade == "Maximum Range Boost":
		# Code for "Maximum Range Boost" upgrade
		buffsGiven[BUFFS.RANGE] = 1.5

	elif upgrade == "Third Eye":
		# Code for "Third Eye" upgrade
		buffsGiven[BUFFS.SEECAMO] = 2
		buffsGiven[BUFFS.RANGE] = 1.66

	else:
		print("Upgrade not found.")
		
	updateBoostedTowersBoosts()
	updateSprite(upgrade)
		
func updateSprite(upgrade: String) -> void:
	if ownedUpgrades.size() == upgrades.size():
		sprite.texture = load("res://Assets/Buildings/Towers/Boost/boost_max.png")
		return
		
	var string:String
	
	if upgrade == "Firerate Boost":
		# Code for "Firerate Boost" upgrade
		string = "res://Assets/Buildings/Towers/Boost/boost_1"

	elif upgrade == "Further Range Boost":
		# Code for "Further Range Boost" upgrade
		string = "res://Assets/Buildings/Towers/Boost/boost_2"

	elif upgrade == "Cheaper Upgrades":
		# Code for "Cheaper Upgrades" upgrade
		string = "res://Assets/Buildings/Towers/Boost/boost_a0"

	elif upgrade == "Valueable Ants":
		# Code for "Valueable Ants" upgrade
		string = "res://Assets/Buildings/Towers/Boost/boost_a1"

	elif upgrade == "Golden Glove":
		# Code for "Golden Glove" upgrade
		string = "res://Assets/Buildings/Towers/Boost/boost_a2"

	elif upgrade == "Damage Boost":
		# Code for "Damage Boost" upgrade
		string = "res://Assets/Buildings/Towers/Boost/boost_b0"

	elif upgrade == "AOE Boost":
		# Code for "AOE Boost" upgrade
		string = "res://Assets/Buildings/Towers/Boost/boost_b1"

	elif upgrade == "Killer Instinct":
		# Code for "Killer Instinct" upgrade
		string = "res://Assets/Buildings/Towers/Boost/boost_b2"

	elif upgrade == "Elemental Duration Boost":
		# Code for "Elemental Duration Boost" upgrade
		string = "res://Assets/Buildings/Towers/Boost/boost_c0"

	elif upgrade == "Maximum Range Boost":
		# Code for "Maximum Range Boost" upgrade
		string = "res://Assets/Buildings/Towers/Boost/boost_c1"

	elif upgrade == "Third Eye":
		# Code for "Third Eye" upgrade
		string = "res://Assets/Buildings/Towers/Boost/boost_c2"

	else:
		print("Upgrade not found.")
		return
		
	if mint:
		sprite.texture = load(string + "_mint.png")
	else:
		sprite.texture = load(string + ".png")
		
	
func _process(delta):
	if valueAnt:
		checkIfAntsDiedInRange()
	if goldenGlove and TimeScaler.time() - lastShotTime > firerate:
		var target = getTarget()
		if target != null:
			shoot(target)
			lastShotTime = TimeScaler.time()
		
func shoot(target:Object)->void:
	var bulletInstance = bullet.instance()
	bulletInstance.damage = 10
	bulletInstance.target = target
	bulletInstance.global_position = global_position
	bulletInstance.z_index = 4
	bulletInstance.duration = 0.3
	bulletInstance.poisionDuration = 0
	bulletInstance.tower = self
	bulletInstance.pike = false
	game.add_child(bulletInstance)
	
func checkIfAntsDiedInRange():
	var ants = get_tree().get_nodes_in_group("Ants")
	
	var currentAnts = {}
	
	for ant in ants:
		if ant.global_position.distance_squared_to(global_position) <= RANGE:
			currentAnts[ant] = ant.health
			
	for ant in currentAnts:
		if currentAnts[ant] <= 0 and ant in lastAntsInRange and lastAntsInRange[ant] > 0:
			print(ant, " died in range!")
			game._addMoney(round(ant.value * bonus))
			
	lastAntsInRange = currentAnts

func updateRange(newRange):
	actualRange = newRange
	RANGE = actualRange * actualRange
	collision.shape.radius = actualRange

func updateBoostedTowersBoosts()->void:
	for tower in boostedTowers:
		tower.change = true

func _on_Area2D_area_entered(area):
	if area.is_in_group("Tower") and area != self:
		area.boosters.append(self)
		area.change = true
		boostedTowers.append(area)


func _on_Area2D_area_exited(area):
	if area.is_in_group("Tower") and area != self:
		area.boosters.erase(self)
		area.change = true
		boostedTowers.erase(area)

func updateBoosts():
	updateRange(unboostedRange * buffs[BUFFS.RANGE])
	

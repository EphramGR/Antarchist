extends Tower

onready var sprite = get_node("Sprite")

#references
const spawn = preload("res://Scenes/Knight.tscn")
const necroSprite = preload("res://Assets/Buildings/necroSpawn.png")

#logic
var lastSpawnTime = 0
var currentSpawns = []
var necroSpawns = []
var bringKnightsBack = false

#settings
var unboostedSpawnrate = 4000
var unboostedSpawnDamage = 100
var unboostedRange = 100 * Perks.rangeMultiplier
var unboostedSpawnSightRange = 75
var unboostedAttackSpeed = 1000

var spawnRate = 4000
var maxSpawns = 3
var spawnHealth = 100
var spawnDamage = 100
var spawnDamageTaken = 10
var spawnSightRange = 75
var spawnSpeed = 70
var spawnAttackSpeed = 1000
var wizard = false
var necro = false



func _ready():
	actualRange = unboostedRange
	RANGE = actualRange * actualRange
	updatePerkTree()
	
	if mint:
		sprite.texture = load("res://Assets/Buildings/Towers/Castle/castle_0_mint.png")
	
func updateStats():
	stats = {
		"Spawning Range":actualRange,
		"Spawn Rate":round(spawnRate/200)/10,
		"Max Knights":maxSpawns,
		"Spawn Damage":spawnDamage,
		"Spawn Attack Speed":round(spawnAttackSpeed/200)/10,
		"Spawn Speed":spawnSpeed/10,
		"Spawn Sight Range":spawnSightRange,
		"Spawn Health":spawnHealth
	}
	
	if not unboostedSeesCamo:
		stats["Camo"] = false
		
	if not hitsFlying:
		stats["Flying"] = false
	
	if wizard:
		stats["Spawn Type"] = "Wizard"
		
	else:
		stats["Spawn Type"] = "Knight"
		
	if necro:
		stats["Spawn Type"] = "Necromancer"
	
func updatePerkTree():
	upgrades = {
		"Range+":[],
		"Damage+":["Range+"],
		"More Soldiers":["Damage+"],
		"Beefy Soldiers":["More Soldiers"],
		"Quick Training":["Beefy Soldiers"],
		"All the Soldiers":["Quick Training"],
		"Wizard School":["Damage+"],
		"Sightrange+":["Wizard School"],
		"Protection Spell":["Sightrange+"],
		"Necromancy":["Protection Spell"]
	}
	descriptions = {
		"Range+":"Increases range by x percent.",
		"Damage+":"Increases damage by x percent.",
		"More Soldiers":"Increases max soldiers to 5.",
		"Beefy Soldiers":"Increases soldiers health by x percent.",
		"Quick Training":"Reduce soldier spawn time by x percent.",
		"All the Soldiers":"Increases max soldiers to 7.",
		"Wizard School":"Soldiers become wizards, and no longer run up to enemy to attack.",
		"Sightrange+":"Increase wizards sightrange by x percent.",
		"Protection Spell":"Wizards no longer take damage when fighting ants.",
		"Necromancy":"Wizards become necromancers, inflicting necromance effect on ants, making them weak soldiers after death."
	}
	upgradeSprites = {
		"Range+": Perks.defaultUpgradeSprites[Perks.baseUpgrades.RANGE],
		"Damage+": Perks.defaultUpgradeSprites[Perks.baseUpgrades.DAMAGE],
		"More Soldiers": Perks.castleUpgrades[Perks.castle.moreSoldiers],
		"Beefy Soldiers": Perks.castleUpgrades[Perks.castle.moreSoldiers],
		"Quick Training": Perks.defaultUpgradeSprites[Perks.baseUpgrades.RECHARGE],
		"All the Soldiers": Perks.castleUpgrades[Perks.castle.allSoldiers],
		"Wizard School": Perks.castleUpgrades[Perks.castle.wizard],
		"Sightrange+": Perks.castleUpgrades[Perks.castle.sightRange],
		"Protection Spell": Perks.castleUpgrades[Perks.castle.prot],
		"Necromancy": Perks.castleUpgrades[Perks.castle.necro]
	}
	prices = {
		"Range+": 150*Perks.upgradeCostMult,
		"Damage+": 200*Perks.upgradeCostMult,
		"More Soldiers": 500*Perks.upgradeCostMult,
		"Beefy Soldiers": 350*Perks.upgradeCostMult,
		"Quick Training": 300*Perks.upgradeCostMult,
		"All the Soldiers": 2500*Perks.upgradeCostMult,
		"Wizard School": 1000*Perks.upgradeCostMult,
		"Sightrange+": 250*Perks.upgradeCostMult,
		"Protection Spell": 700*Perks.upgradeCostMult,
		"Necromancy": 3100*Perks.upgradeCostMult
	}

	
func updateBoosts() -> void:
	spawnRate = unboostedSpawnrate * buffs[BUFFS.FIRERATE]
	spawnDamage = unboostedSpawnDamage * buffs[BUFFS.DAMAGE]
	actualRange = unboostedRange * buffs[BUFFS.RANGE]
	RANGE = actualRange * actualRange
	spawnSightRange = unboostedSpawnSightRange * buffs[BUFFS.RANGE]
	spawnAttackSpeed = unboostedAttackSpeed * buffs[BUFFS.FIRERATE]
	seesCamo = (buffs[BUFFS.SEECAMO] == 2 or unboostedSeesCamo)
	
#add boost before finish
func updateUpgrade(upgrade: String) -> void:
	if upgrade == "Range+":
		# Code for "Range+" upgrade
		unboostedRange *= 1.1

	elif upgrade == "Damage+":
		# Code for "Damage+" upgrade
		unboostedSpawnDamage *= 1.1

	elif upgrade == "More Soldiers":
		# Code for "More Soldiers" upgrade
		maxSpawns = 5

	elif upgrade == "Beefy Soldiers":
		# Code for "Beefy Soldiers" upgrade
		spawnHealth *= 1.1

	elif upgrade == "Quick Training":
		# Code for "Quick Training" upgrade
		unboostedSpawnrate *= 0.5

	elif upgrade == "All the Soldiers":
		# Code for "All the Soldiers" upgrade
		maxSpawns = 7

	elif upgrade == "Wizard School":
		# Code for "Wizard School" upgrade
		wizard = true
		seesCamo = true

	elif upgrade == "Sightrange+":
		# Code for "Sightrange+" upgrade
		unboostedSpawnSightRange *= 1.1

	elif upgrade == "Protection Spell":
		# Code for "Protection Spell" upgrade
		spawnDamageTaken = 0

	elif upgrade == "Necromancy":
		# Code for "Necromancy" upgrade
		necro = true

	else:
		print("Upgrade not found.")
	
	cleanUp()
	updateSprite(upgrade)
	
func updateSprite(upgrade: String) -> void:
	if ownedUpgrades.size() == upgrades.size():
		sprite.texture = load("res://Assets/Buildings/Towers/Castle/castle_max.png")
		return
		
	var string:String
	
	if upgrade == "Range+":
		# Code for "Range+" upgrade
		string = "res://Assets/Buildings/Towers/Castle/castle_1"

	elif upgrade == "Damage+":
		# Code for "Damage+" upgrade
		string = "res://Assets/Buildings/Towers/Castle/castle_2"

	elif upgrade == "More Soldiers":
		# Code for "More Soldiers" upgrade
		string = "res://Assets/Buildings/Towers/Castle/castle_0a"

	elif upgrade == "Beefy Soldiers":
		# Code for "Beefy Soldiers" upgrade
		string = "res://Assets/Buildings/Towers/Castle/castle_1a"

	elif upgrade == "Quick Training":
		# Code for "Quick Training" upgrade
		string = "res://Assets/Buildings/Towers/Castle/castle_2a"

	elif upgrade == "All the Soldiers":
		# Code for "All the Soldiers" upgrade
		string = "res://Assets/Buildings/Towers/Castle/castle_3a"

	elif upgrade == "Wizard School":
		# Code for "Wizard School" upgrade
		string = "res://Assets/Buildings/Towers/Castle/castle_0b"

	elif upgrade == "Sightrange+":
		# Code for "Sightrange+" upgrade
		string = "res://Assets/Buildings/Towers/Castle/castle_1b"

	elif upgrade == "Protection Spell":
		# Code for "Protection Spell" upgrade
		string = "res://Assets/Buildings/Towers/Castle/castle_2b"

	elif upgrade == "Necromancy":
		# Code for "Necromancy" upgrade
		string = "res://Assets/Buildings/Towers/Castle/castle_3b"

	else:
		print("Upgrade not found.")
		return
		
	if mint:
		sprite.texture = load(string + "_mint.png")
	else:
		sprite.texture = load(string + ".png")
		
func cleanUp():
	for i in range(currentSpawns.size()):
		currentSpawns[i].queue_free()
	
	currentSpawns = []
	
	for i in range(necroSpawns.size()):
		necroSpawns[i].queue_free()
	
	necroSpawns = []
	
func _process(delta):
	if not isInHand:
		if game.isWaveActive():
			if currentSpawns.size() < maxSpawns and TimeScaler.time() - lastSpawnTime > spawnRate:
				spawnKnight()
				lastSpawnTime = TimeScaler.time()
				
			if not bringKnightsBack:
				bringKnightsBack = true
				recall()
				
		elif bringKnightsBack:
			bringKnightsBack = false
			
	
func recall()->void:
	for knight in currentSpawns:
		if global_position.distance_squared_to(knight.global_position) > RANGE:
			knight.global_position = global_position
			knight.currentState = knight.STATE.WANDER
			knight.nextPos = null
			print("pulling knight back")
		else:
			knight.currentState = knight.STATE.IDLE

func getRandomPointInRange()->Vector2:
	var point:Vector2 = Vector2(rand_range(-1,1),rand_range(-1,1)).normalized()
	
	var distance:int = randi()%int(actualRange)
	
	
	return point*distance


func spawnKnight():
	var spawnInstance = spawn.instance()
	
	spawnInstance.spawnHealth = spawnHealth
	spawnInstance.spawnDamage = spawnDamage
	spawnInstance.spawnDamageTaken = spawnDamageTaken
	spawnInstance.spawnSightRange = spawnSightRange
	spawnInstance.spawnSpeed = spawnSpeed
	spawnInstance.spawnAttackSpeed = spawnAttackSpeed
	spawnInstance.tower = self
	spawnInstance.z_index = 5
	spawnInstance.global_position = global_position
	spawnInstance.wizard = wizard
	spawnInstance.necro = necro
	
	if wizard:
		spawnInstance.texture = preload("res://Assets/Buildings/Wizard.png")
	
	game.add_child(spawnInstance)
	currentSpawns.append(spawnInstance)
	
func spawnNecro(pos:Vector2):
	var spawnInstance = spawn.instance()
	
	spawnInstance.spawnHealth = 40
	spawnInstance.spawnDamage = 30
	spawnInstance.spawnDamageTaken = 10
	spawnInstance.spawnSightRange = 75
	spawnInstance.spawnSpeed = 50
	spawnInstance.spawnAttackSpeed = 1000
	spawnInstance.tower = self
	spawnInstance.z_index = 5
	spawnInstance.global_position = pos
	spawnInstance.wizard = false
	spawnInstance.necro = false
	spawnInstance.isNecro = true
	
	spawnInstance.texture = necroSprite
	
	spawnInstance.lifeTime = 10
	
	game.add_child(spawnInstance)
	necroSpawns.append(spawnInstance)

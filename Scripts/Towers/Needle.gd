extends Tower

onready var sprite = get_node("Sprite")
onready var fog = get_node("fog")

const bullet = preload("res://Scenes/Pike.tscn")

var lastShotTime = []
var activeTargets = []

#unboosted
var unboostedRange = 125 * Perks.rangeMultiplier
var unboostedDamage = 40
var unboostedBulletSpeed = 0.5/Perks.bulletSpeedMultiplier/ Perks.firerateMultiplier
var unboostedEffectDuration = 0.25

var numNeedles = 2
var avalibleNeedles = []

var damage = 40
var duration = unboostedBulletSpeed #asthetic, NOPE ITS THE FIRERATE PER NEEDLE. it sbasicly this *2 cause in and out
var poisionDuration = 0.25
var sick = false
var splash = false

var sounds = [
	preload("res://Assets/Music/soundEffects/needleShank/click.wav"),
	preload("res://Assets/Music/soundEffects/needleShank/click (1).wav"),
	preload("res://Assets/Music/soundEffects/needleShank/click (2).wav"),
	preload("res://Assets/Music/soundEffects/needleShank/click (3).wav")
]
onready var audioPlayer = get_node("AudioStreamPlayer2D")

func _ready()->void:
	actualRange = unboostedRange
	RANGE = actualRange * actualRange
	updateNumNeedles(numNeedles)
	
	updatePerkTree()
	
	if mint:
		sprite.texture = load("res://Assets/Buildings/Towers/Needle/needle_0_mint.png")
		
func playSound():
	var randomIndex = randi() % sounds.size()

	audioPlayer.stream = sounds[randomIndex]
	
	audioPlayer.volume_db = linear2db(Perks.shootVolume)

	audioPlayer.play()
	
func updateStats():
	stats = {
		"Damage":damage,
		"Range":actualRange,
		"Fire Rate":round(duration/2*100)/100,
		"Poison Duration":poisionDuration/2,
		"Number of Needles":numNeedles,
	}
	
	if not unboostedSeesCamo:
		stats["Camo"] = false
		
	if not hitsFlying:
		stats["Flying"] = false
	
	if sick:
		stats["Sick"] = "Active"
		
	if splash:
		stats["Splash"] = "Active"
	
func updatePerkTree():
	upgrades = {
		"Range+":[],
		"Damage++":["Range+"],
		"Additional Needle":["Damage++"],
		"Poison Duration+":["Additional Needle"],
		"Range++":["Poison Duration+"],
		"Pandemic":["Range++"],
		"More Needles":["Additional Needle"],
		"Needle Speed+":["More Needles"],
		"Needle Overload":["Needle Speed+"],
		"Needle Speed++":["Additional Needle"],
		"Poison Duration++":["Needle Speed++"],
		"Spray":["Poison Duration++"]
	}
	descriptions = {
		"Range+":"Increases range by x%.",
		"Damage++":"Increases damage by x%.",
		"Poison Duration+":"Increases poison duration by x%.",
		"Additional Needle":"One more needle baby!",
		"Range++":"Increases range by x%.",
		"Pandemic":"Inflicts ants with sick effect, on top of poison, which makes them take more elemental damage.",
		"More Needles":"Gets two more needles, with a total of five.",
		"Needle Speed++":"Increases needle speed by x%.",
		"Needle Overload":"Gets five more needles, with a total of ten.",
		"Needle Speed+":"Increases needle speed by x%.",
		"Poison Duration++":"Increases poison duration by x%.",
		"Spray":"Upon contact with ant, sprays poison in small radius giving effected ants 20% of poison duration."
	}
	upgradeSprites = {
		"Range+": Perks.defaultUpgradeSprites[Perks.baseUpgrades.RANGE],
		"Damage++": Perks.defaultUpgradeSprites[Perks.baseUpgrades.DAMAGE],
		"Poison Duration+": Perks.defaultUpgradeSprites[Perks.baseUpgrades.ELEMENTDURATION],
		"Range++": Perks.defaultUpgradeSprites[Perks.baseUpgrades.RANGE],
		"Poison Duration++": Perks.defaultUpgradeSprites[Perks.baseUpgrades.ELEMENTDURATION],
		"Needle Speed+": Perks.defaultUpgradeSprites[Perks.baseUpgrades.FIRERATE],
		"Needle Speed++": Perks.defaultUpgradeSprites[Perks.baseUpgrades.FIRERATE],
		"Additional Needle": Perks.needleUpgrades[Perks.needle.addNeedle],
		"Pandemic": Perks.needleUpgrades[Perks.needle.pandemic],
		"More Needles": Perks.needleUpgrades[Perks.needle.moreNeedles],
		"Needle Overload": Perks.needleUpgrades[Perks.needle.overload],
		"Spray": Perks.needleUpgrades[Perks.needle.spray]
	}
	prices = {
		"Range+": 100*Perks.upgradeCostMult,
		"Damage++": 150*Perks.upgradeCostMult,
		"Additional Needle":700*Perks.upgradeCostMult,
		"Poison Duration+": 225*Perks.upgradeCostMult,
		"Range++": 225*Perks.upgradeCostMult,
		"Pandemic": 2250*Perks.upgradeCostMult,
		"More Needles": 1000*Perks.upgradeCostMult,
		"Needle Speed++": 250*Perks.upgradeCostMult,
		"Needle Overload": 3500*Perks.upgradeCostMult,
		"Needle Speed+": 225*Perks.upgradeCostMult,
		"Poison Duration++": 225*Perks.upgradeCostMult,
		"Spray": 3000*Perks.upgradeCostMult
	}

	
func updateUpgrade(upgrade: String) -> void:
	if upgrade == "Range+":
		# Code for "Range+" upgrade
		unboostedRange *= 1.1

	elif upgrade == "Damage++":
		# Code for "Damage++" upgrade
		unboostedDamage *= 1.15
		
	elif upgrade == "Additional Needle":
		updateNumNeedles(numNeedles + 1)

	elif upgrade == "Poison Duration+":
		# Code for "Poison Duration+" upgrade
		unboostedEffectDuration *= 1.1

	elif upgrade == "Range++":
		# Code for "Range++" upgrade
		unboostedRange *= 1.15

	elif upgrade == "Pandemic":
		# Code for "Pandemic" upgrade
		sick = true

	elif upgrade == "More Needles":
		# Code for "More Needles" upgrade
		updateNumNeedles(numNeedles + 2)

	elif upgrade == "Needle Speed++":
		# Code for "Needle Speed++" upgrade
		unboostedBulletSpeed *= 0.85

	elif upgrade == "Needle Overload":
		# Code for "Needle Overload" upgrade
		updateNumNeedles(numNeedles + 5)

	elif upgrade == "Needle Speed+":
		# Code for "Needle Speed+" upgrade
		unboostedBulletSpeed *= 0.9

	elif upgrade == "Poison Duration++":
		# Code for "Poison Duration++" upgrade
		unboostedEffectDuration *= 1.15

	elif upgrade == "Spray":
		# Code for "Spray" upgrade
		splash = true

	else:
		print("Upgrade not found.")
		
	updateSprite(upgrade)
		

func updateSprite(upgrade: String) -> void:
	if ownedUpgrades.size() == upgrades.size():
		sprite.texture = load("res://Assets/Buildings/Towers/Needle/needle_max.png")
		fog.texture = load("res://Assets/Buildings/Towers/Needle/needle_a2_mint.png")
		return
		
	var string:String
	var fogString:String
	
	if upgrade == "Range+":
		# Code for "Range+" upgrade
		string = "res://Assets/Buildings/Towers/Needle/needle_1"

	elif upgrade == "Damage++":
		# Code for "Damage++" upgrade
		fogString = "res://Assets/Buildings/Towers/Needle/needle_2"
		
	elif upgrade == "Additional Needle":
		fogString = "res://Assets/Buildings/Towers/Needle/needle_3"
		#could remov depth effect from prior

	elif upgrade == "Poison Duration+":
		# Code for "Poison Duration+" upgrade
		fogString = "res://Assets/Buildings/Towers/Needle/needle_a0"

	elif upgrade == "Range++":
		# Code for "Range++" upgrade
		string = "res://Assets/Buildings/Towers/Needle/needle_a1"

	elif upgrade == "Pandemic":
		# Code for "Pandemic" upgrade
		fogString = "res://Assets/Buildings/Towers/Needle/needle_a2"

	elif upgrade == "More Needles":
		# Code for "More Needles" upgrade
		string = "res://Assets/Buildings/Towers/Needle/needle_b0"

	elif upgrade == "Needle Speed++":
		# Code for "Needle Speed++" upgrade
		string = "res://Assets/Buildings/Towers/Needle/needle_c0"

	elif upgrade == "Needle Overload":
		# Code for "Needle Overload" upgrade
		string = "res://Assets/Buildings/Towers/Needle/needle_b2"

	elif upgrade == "Needle Speed+":
		# Code for "Needle Speed+" upgrade
		string = "res://Assets/Buildings/Towers/Needle/needle_b1"

	elif upgrade == "Poison Duration++":
		# Code for "Poison Duration++" upgrade
		string = "res://Assets/Buildings/Towers/Needle/needle_c1"

	elif upgrade == "Spray":
		# Code for "Spray" upgrade
		string = "res://Assets/Buildings/Towers/Needle/needle_c2"

	else:
		print("Upgrade not found.")
		return
	
	
	
	if mint:
		if string:
			sprite.texture = load(string + "_mint.png")
		elif fogString:
			fog.texture = load(fogString + "_mint.png")
	else:
		if string:
			sprite.texture = load(string + ".png")
		elif fogString:
			fog.texture = load(fogString + ".png")
	


func updateBoosts():
	actualRange = unboostedRange * buffs[BUFFS.RANGE]
	RANGE = actualRange * actualRange
	
	duration = unboostedBulletSpeed * 1/buffs[BUFFS.FIRERATE] * 1/buffs[BUFFS.BULLETSPEED]
	
	damage = unboostedDamage * buffs[BUFFS.DAMAGE]
	
	poisionDuration = unboostedEffectDuration * buffs[BUFFS.EFFECTDURATION]
	seesCamo = (buffs[BUFFS.SEECAMO] == 2 or unboostedSeesCamo)
	

func _process(delta:float)->void:
	if not isInHand:
		var remove = []
		
		for i in range(avalibleNeedles.size()):
			getAllTargets()
		
			if activeTargets[avalibleNeedles[i]] != null:
				shoot(activeTargets[avalibleNeedles[i]], avalibleNeedles[i])
				remove.append(avalibleNeedles[i])
					
		for i in range(remove.size()):
			avalibleNeedles.erase(remove[i])

func shoot(target:Object, i)->void:
	var bulletInstance = bullet.instance()
	bulletInstance.damage = damage
	bulletInstance.target = target
	bulletInstance.global_position = global_position
	bulletInstance.z_index = 4
	bulletInstance.duration = duration
	bulletInstance.poisionDuration = poisionDuration
	bulletInstance.tower = self
	bulletInstance.index = i
	bulletInstance.splash = splash
	bulletInstance.sick = sick
	bulletInstance.add_to_group("Pike")
	game.add_child(bulletInstance)
	
func updateNumNeedles(num):
	numNeedles = num
	lastShotTime = []
	activeTargets = []
	avalibleNeedles = []
	for i in range(num):
		lastShotTime.append(0)
		activeTargets.append(null)
		avalibleNeedles.append(i)
		
func getAllTargets():
	var ants = get_tree().get_nodes_in_group("Ants")
	
	for i in range(numNeedles):
		if activeTargets[i] == null:
			var comparatorAndTarget = [null, null]
			
			
			for ant in ants:
				if not ant.dead and not ant in activeTargets and ((ant.isCamo and seesCamo) or not ant.isCamo) and ((ant.isFlying and hitsFlying) or not ant.isFlying):
					var distance = global_position.distance_squared_to(ant.global_position)
					
					if distance <= RANGE:
						compareTarget(comparatorAndTarget, distance, ant)
						
						activeTargets[i] = comparatorAndTarget[1]
	

func cleanUp():
	var pikes = get_tree().get_nodes_in_group("Pike")
	
	for pike in pikes:
		if pike.tower == self:
			pike.queue_free()

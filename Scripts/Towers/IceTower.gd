extends Tower

onready var sprite = get_node("Sprite")

var bullet = preload("res://Scenes/Ice.tscn")
var bulletInstance
#references
#var game

#logic
var lastShotTime = 0
#var distanceToTarget

#settings
#unboosted
var unboostedRange = 75 * Perks.rangeMultiplier
var unboostedFireRate = 1000/ Perks.firerateMultiplier
var unboostedDamage = 50
var unboostedEffectDuration = 0.4

var fireRate = unboostedFireRate
var damage = 50
var freeze = false
var weaken = false
var radial = false
var effectDuration = 0.4


var sounds = [
	preload("res://Assets/Music/soundEffects/ice/random.wav"),
	preload("res://Assets/Music/soundEffects/ice/random (1).wav"),
	preload("res://Assets/Music/soundEffects/ice/random (2).wav")
]
onready var audioPlayer = get_node("AudioStreamPlayer2D")


func _ready():	
	actualRange = unboostedRange
	RANGE = actualRange * actualRange
	bulletInstance = bullet.instance()
	updateIce()
	add_child(bulletInstance)
	hitsFlying = true
	
	updatePerkTree()
	
	if mint:
		sprite.texture = load("res://Assets/Buildings/Towers/IceTower/icetower_0_mint.png")
	
func playSound():
	var randomIndex = randi() % sounds.size()

	audioPlayer.stream = sounds[randomIndex]
	
	audioPlayer.volume_db = linear2db(Perks.shootVolume)

	audioPlayer.play()

func updateStats():
	stats = {
		"Damage":damage,
		"Range":actualRange,
		"Fire Rate":round(fireRate/200)/10,
		"Effect Duration":effectDuration/2
	}
	
	if not unboostedSeesCamo:
		stats["Camo"] = false
	
	if radial:
		if freeze:
			if weaken:
				stats["Element"] = "Freeze and Weaken and Slow"
			else:
				stats["Element"] = "Freeze and Slow"
		elif weaken:
			stats["Element"] = "Weaken and Slow"
		else:
			stats["Element"] = "Slow"
	else:
		if freeze:
			if weaken:
				stats["Element"] = "Freeze and Weaken"
			else:
				stats["Element"] = "Freeze"
		elif weaken:
			stats["Element"] = "Weaken"
		else:
			stats["Element"] = "Slow"
	
func updatePerkTree():
	upgrades = {
		"Range+":[],
		"Slow Duration+":["Range+"],
		"Damage++":["Slow Duration+"],
		"Firerate++":["Slow Duration+"],
		"Slow Duration++":["Damage++"],
		"Range++":["Firerate++"],
		"Trembling Shivers":["Slow Duration++"],
		"Freezing Winds":["Slow Duration++"],
		"Radial Slow":["Range++"]
	}
	descriptions = {
		"Range+":"Increases range by x%.",
		"Slow Duration+":"Increases slow duration by x%.",
		"Firerate++":"Increases firerate by x%.",
		"Damage++":"Increases damage by x%.",
		"Range++":"Increases range by x%.",
		"Slow Duration++":"Increases slow duration by x%.",
		"Radial Slow":"Troops in range are always slow.",
		"Trembling Shivers":"Gives ants weakened instead of slowed. Weakened ants take x% more damage from non-elemental sources.",
		"Freezing Winds":"Ants are frozen instead of slowed. Frozen ants cant move."
	}
	upgradeSprites = {
		"Range+": Perks.defaultUpgradeSprites[Perks.baseUpgrades.RANGE],
		"Slow Duration+": Perks.defaultUpgradeSprites[Perks.baseUpgrades.ELEMENTDURATION],
		"Firerate++": Perks.defaultUpgradeSprites[Perks.baseUpgrades.FIRERATE],
		"Damage++": Perks.defaultUpgradeSprites[Perks.baseUpgrades.DAMAGE],
		"Range++": Perks.defaultUpgradeSprites[Perks.baseUpgrades.RANGE],
		"Slow Duration++": Perks.defaultUpgradeSprites[Perks.baseUpgrades.ELEMENTDURATION],
		"Radial Slow": Perks.iceUpgrades[Perks.ice.radialSlow],
		"Trembling Shivers":  Perks.iceUpgrades[Perks.ice.tremble],
		"Freezing Winds":  Perks.iceUpgrades[Perks.ice.freeze]
	}
	prices = {
		"Range+": 100*Perks.upgradeCostMult,
		"Slow Duration+": 150*Perks.upgradeCostMult,
		"Firerate++": 225*Perks.upgradeCostMult,
		"Damage++": 225*Perks.upgradeCostMult,
		"Range++": 200*Perks.upgradeCostMult,
		"Slow Duration++": 250*Perks.upgradeCostMult,
		"Radial Slow": 3000*Perks.upgradeCostMult,
		"Trembling Shivers": 2750*Perks.upgradeCostMult,
		"Freezing Winds": 3250*Perks.upgradeCostMult
	}

	
func updateUpgrade(upgrade: String) -> void:
	if upgrade == "Range+":
		# Code for "Range+" upgrade
		unboostedRange *= 1.1

	elif upgrade == "Slow Duration+":
		# Code for "Slow Duration+" upgrade
		unboostedEffectDuration *= 1.1

	elif upgrade == "Firerate++":
		# Code for "Firerate++" upgrade
		unboostedFireRate *= 1.15

	elif upgrade == "Damage++":
		# Code for "Damage++" upgrade
		unboostedDamage *= 1.15

	elif upgrade == "Range++":
		# Code for "Range++" upgrade
		unboostedRange *= 1.15

	elif upgrade == "Slow Duration++":
		# Code for "Slow Duration++" upgrade
		unboostedEffectDuration *= 1.15

	elif upgrade == "Radial Slow":
		# Code for "Radial Slow" upgrade
		radial = true

	elif upgrade == "Trembling Shivers":
		# Code for "Trembling Shivers" upgrade
		weaken = true

	elif upgrade == "Freezing Winds":
		# Code for "Freezing Winds" upgrade
		freeze = true

	else:
		print("Upgrade not found.")
		
	updateSprite(upgrade)
		

func updateSprite(upgrade: String) -> void:
	if ownedUpgrades.size() == upgrades.size():
		sprite.texture = load("res://Assets/Buildings/Towers/IceTower/icetower_max.png")
		return
		
	var string:String
	
	if upgrade == "Range+":
		# Code for "Range+" upgrade
		string = "res://Assets/Buildings/Towers/IceTower/icetower_1"

	elif upgrade == "Slow Duration+":
		# Code for "Slow Duration+" upgrade
		string = "res://Assets/Buildings/Towers/IceTower/icetower_2"

	elif upgrade == "Firerate++":
		# Code for "Firerate++" upgrade
		string = "res://Assets/Buildings/Towers/IceTower/icetower_a0"

	elif upgrade == "Damage++":
		# Code for "Damage++" upgrade
		string = "res://Assets/Buildings/Towers/IceTower/icetower_b0"

	elif upgrade == "Range++":
		# Code for "Range++" upgrade
		string = "res://Assets/Buildings/Towers/IceTower/icetower_a1"

	elif upgrade == "Slow Duration++":
		# Code for "Slow Duration++" upgrade
		string = "res://Assets/Buildings/Towers/IceTower/icetower_b1"

	elif upgrade == "Radial Slow":
		# Code for "Radial Slow" upgrade
		string = "res://Assets/Buildings/Towers/IceTower/icetower_a2"

	elif upgrade == "Trembling Shivers":
		# Code for "Trembling Shivers" upgrade
		string = "res://Assets/Buildings/Towers/IceTower/icetower_ba"

	elif upgrade == "Freezing Winds":
		# Code for "Freezing Winds" upgrade
		string = "res://Assets/Buildings/Towers/IceTower/icetower_bb"

	else:
		print("Upgrade not found.")
		return
		
	if mint:
		sprite.texture = load(string + "_mint.png")
	else:
		sprite.texture = load(string + ".png")
	
func _process(delta):
	pass
	
func updateBoosts():
	actualRange = unboostedRange * buffs[BUFFS.RANGE]
	RANGE = actualRange * actualRange
	
	damage = unboostedDamage * buffs[BUFFS.DAMAGE]
	
	fireRate = unboostedFireRate * 1/buffs[BUFFS.FIRERATE]
	
	effectDuration = unboostedEffectDuration * buffs[BUFFS.EFFECTDURATION]
	seesCamo = (buffs[BUFFS.SEECAMO] == 2 or unboostedSeesCamo)
	
	updateIce()
	
func updateIce():
	bulletInstance.z_index = 6
	bulletInstance.damage = damage
	bulletInstance.fireRate = fireRate
	bulletInstance.freeze = freeze
	bulletInstance.radial = radial
	bulletInstance.weaken = weaken
	bulletInstance.effectDuration = effectDuration
	bulletInstance.hitsFlying = hitsFlying
	bulletInstance.updateRange(actualRange)
	
	
func placed():
	bulletInstance.global_position = global_position
	
func cleanUp():
	bulletInstance.queue_free()



extends CanvasLayer

var game
var stats
var towerName:String
var tower:Object
var sellPrice = null
var targetingType=0

enum TARGET {closest, farthest, strongest, weakest, closestToDestination, farthestFromDestination}
enum STYLE {CIRCLE, H_FIGURE8, V_FIGURE8, ORBIT, ORBIT_V}

const targetTextures = {
	TARGET.closest:preload("res://Assets/SkillTree/Targeting/closest.png"),
	TARGET.farthest:preload("res://Assets/SkillTree/Targeting/farthest.png"),
	TARGET.strongest:preload("res://Assets/SkillTree/Targeting/strongest.png"),
	TARGET.weakest:preload("res://Assets/SkillTree/Targeting/weakest.png"),
	TARGET.closestToDestination:preload("res://Assets/SkillTree/Targeting/closestTo.png"),
	TARGET.farthestFromDestination:preload("res://Assets/SkillTree/Targeting/farthestTo.png")
}

const droneTextures = {
	STYLE.CIRCLE:preload("res://Assets/SkillTree/Targeting/circle.png"),
	STYLE.H_FIGURE8:preload("res://Assets/SkillTree/Targeting/figure8_h.png"),
	STYLE.V_FIGURE8:preload("res://Assets/SkillTree/Targeting/figure8_v.png"),
	STYLE.ORBIT:preload("res://Assets/SkillTree/Targeting/orbit.png"),
	STYLE.ORBIT_V:preload("res://Assets/SkillTree/Targeting/orbit_v.png")
}

const targetString = {
	TARGET.closest:"Targeting closest ant. Click to change.",
	TARGET.farthest:"Targeting farthest ant.",
	TARGET.strongest:"Targeting ant with most health.",
	TARGET.weakest:"Targeting ant with least health.",
	TARGET.closestToDestination:"Targeting ant that's closest to its destination.",
	TARGET.farthestFromDestination:"Targeting ant that's farthest from its destination."
}

const droneString = {
	STYLE.CIRCLE:"Circular flight pattern. Click to change.",
	STYLE.H_FIGURE8:"Horizontal figure eight.",
	STYLE.V_FIGURE8:"Vertical figure eight.",
	STYLE.ORBIT:"Horizontal orbiting flight pattern.",
	STYLE.ORBIT_V:"Vertical orbiting flight pattern."
}
	

onready var statsText = [
	get_node("ColorRect/Stats/1"),
	get_node("ColorRect/Stats/2"),
	get_node("ColorRect/Stats/3"),
	get_node("ColorRect/Stats/4"),
	get_node("ColorRect/Stats/5"),
	get_node("ColorRect/Stats/6"),
	get_node("ColorRect/Stats/7"),
	get_node("ColorRect/Stats/8"),
	get_node("ColorRect/Stats/9"),
	get_node("ColorRect/Stats/10"),
	get_node("ColorRect/Stats/11"),
	get_node("ColorRect/Stats/12"),
	get_node("ColorRect/Stats/13"),
	get_node("ColorRect/Stats/14"),
	get_node("ColorRect/Stats/15")
	]
	
onready var text = get_node("ColorRect/Icons/text")
onready var targeting = get_node("ColorRect/Icons/Targeting")
	
const lock = preload("res://Assets/SkillTree/lock.png")
const no = preload("res://Assets/SkillTree/no.png")

func _ready():
	if stats == null:
		get_node("ColorRect/Exit").visible = false
		stats = Perks.baseStats[towerName]
		
	updateText()
	if towerName == "Stock" or towerName == "Drone" or towerName == "Boost":
		get_node("ColorRect/Icons/seeCamo").visible = false
		get_node("ColorRect/Icons/hitFlying").visible = false
		
	if tower == null or towerName == "Stock" or towerName == "Vortex" or towerName == "Boost" or towerName == "Flail":
		targeting.visible = false
		
	elif towerName == "Drone":
		updateDroneTexture()
		
	else:
		updateTargetTexture()
	
func updateText()->void:
	var i = 0
	
	for stat in stats:
		if stat == "Camo":
			if stats[stat]:
				get_node("ColorRect/Icons/camoMarker").texture = lock
			else:
				get_node("ColorRect/Icons/camoMarker").texture = no
		elif stat == "Flying":
			if stats[stat]:
				get_node("ColorRect/Icons/flyingMarker").texture = lock
			else:
				get_node("ColorRect/Icons/flyingMarker").texture = no
		else:
			statsText[i].text = stat + ": " + String(stats[stat])

		i += 1
		


	get_node("ColorRect/Name").text = towerName
	get_node("ColorRect/TextureRect").texture = Perks.towerThumbnails[towerName]
	
	if sellPrice != null:
		get_node("ColorRect/Name/sellPrice").text = "Sell Price: " + String(sellPrice)
		
func updateTargetTexture():
	targetingType = tower.targetType
	
	targeting.texture_normal = targetTextures[targetingType]
	

func cycleTargetTexture():
	tower.targetType += 1
	if tower.targetType > 5:
		tower.targetType = 0
		
	updateTargetTexture()
	
func updateDroneTexture():
	targetingType = tower.flightPath
	
	if targetingType != 0 and "3rd Drone" in tower.ownedUpgrades:
		targeting.texture_normal = droneTextures[targetingType+2]
	else:
		targeting.texture_normal = droneTextures[targetingType]

func cycleDroneTexture():
	tower.flightPath += 1
	if tower.flightPath > 2:
		tower.flightPath = 0
		
		
	updateDroneTexture()


func _on_Exit_pressed():
	queue_free()
	game.buttonsEnabled = true


func _on_seeCamo_mouse_entered():
	var string:String
	if not "Camo" in stats:
		string = "Can target camo ants."
	elif stats["Camo"]:
		string = "Can purchase upgrade to see camo ants."
	else:
		string = "Can not target camo ants."
	
	text.text = string

func _on_hitFlying_mouse_entered():
	var string:String
	if not "Flying" in stats:
		string = "Can hit flying ants."
	elif stats["Flying"]:
		string = "Can purchase upgrade to hit flying ants."
	else:
		string = "Can not hit flying ants."
	
	text.text = string
	
func _on_Targeting_mouse_entered():
	var string:String
	
	if towerName != "Drone":
		string = targetString[tower.targetType]
	else:
		var i:int = tower.flightPath
	
		if i != 0 and "3rd Drone" in tower.ownedUpgrades:
			i += 2
			
		string = droneString[i]
		
	text.text = string
	

func _on_mouse_exited():
	text.text = ""

func _on_Targeting_pressed():
	if towerName == "Drone":
		cycleDroneTexture()
	else:
		cycleTargetTexture()
	_on_Targeting_mouse_entered()

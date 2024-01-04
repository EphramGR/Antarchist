extends CanvasLayer

const nullSprite = preload("res://Assets/SkillTree/nullSprite.png")
const lockSprite = preload("res://Assets/SkillTree/lock.png")
onready var background = get_node("Background")

const UNLOCKEDCOLOR = Color.white
const UNLOCKINGCOLOR = Color(0.8,0.8,0.8)
const LOCKEDCOLOR = Color(0.3,0.3,0.3)

#upgrade name: upgrades required to get
var upgrades = {
	"Leathal Spikes":[],
	"Arctic Winds":["Abundant Magic"],
	"Malnourished":["Abundant Magic"],
	"Endless Kindling":["Malnourished"],
	"Virus Outbreak":["Abundant Magic"],
	"Toxic Fields":["Virus Outbreak"],
	"Bulky Base":["Leathal Spikes"],
	"Regeneration":["Bulky Base"],
	"Ration Shields":["Regeneration"],
	"Deflection":["Bulky Base"],
	"Reincarnation":["Deflection"],
	"Five Finger Discount":["Leathal Spikes"],
	"Thieving Rounds":["Five Finger Discount"],
	"Money Bags":["Thieving Rounds"],
	"Early Access":["Money Bags"],
	"Polisher":["Early Access"],
	"Barterer":["Clearance"],
	"Refund Policy":["Money Bags"],
	"Clearance":["Refund Policy"],
	"Selective Sight":["Polisher"],
	"Quality Ammo":["Thieving Rounds"],
	"Oiled Barrels":["Quality Ammo"],
	"Aerodynamics":["Oiled Barrels"],
	"Keen Eye":["Quality Ammo"],
	"Lethal Loyals":["Keen Eye"],
	"Efficient Energy":["Leathal Spikes"],
	"Lingering Hex":["Efficient Energy"],
	"Abundant Magic":["Lingering Hex"],
	"Freezing Winds":["Arctic Winds"],
	"Miscommunication":["Abundant Magic"]
}

var tower:Object

#these reference towers varaiblers, so any changes will stay with tower
var descriptions = {}
var upgradeSprites = {}
var prices = {}
var ownedUpgrades = {}

var avalibleUpgrades = []

var placements = {}
var lines = {}
var buttons = {}
var locks = {}

var game:Object

const MIN = Vector2(0,0)
onready var MAX = background.rect_size
const spaceingDist = 50
const buttonScale = 2
const buttonSize = Vector2(27*2,27*2)

var oneWay = true #change later bozo
const needAllPrevious = true


onready var descriptionText = get_node("ColorRect/Description")
onready var costText = get_node("ColorRect/Cost")
onready var nameText = get_node("ColorRect/Name")
onready var icon = get_node("ColorRect/Icon")

func _ready():
	createTree()
	updateAvalibleUpgrades()
	
	var bg = get_node("back")
	bg.region_rect = Rect2(MIN, MAX)
	bg.position = background.rect_position + MAX/2
	
func createTree():
	var verticalLayers = calcMaxVerticalLayers()
	var size = background.rect_size
	var verticalOffset = size.x/verticalLayers
	
	for upgrade in upgrades:
		 updateY(upgrade, verticalOffset * (countVerticalLayers(upgrade) - 0.5), size.y)
		
	drawTree()
		
func drawTree():
	for upgrade in upgrades:
		createTextureButton(upgrade)
		
		if not upgrade in ownedUpgrades:
			createLock(upgrade)
			
		for i in range(upgrades[upgrade].size()):
			createLine(placements[upgrades[upgrade][i]], placements[upgrade], upgrade)
	
func updateY(upgrade:String, x:float, size:float):
	if upgrades[upgrade].size() > 1:
		var totalY = 0
		var flag = true
		
		for i in range(upgrades[upgrade].size()):
			if upgrades[upgrade][i] in placements:
				 totalY += placements[upgrades[upgrade][i]].y
			else:
				flag = false
				
		if flag:
			placements[upgrade] = Vector2(x, totalY/upgrades[upgrade].size())
			return
		
	
	var onLayer = [upgrade]
	
	for upgrade in placements:
		#cause foating point error
		if round(placements[upgrade].x) == round(x):
			onLayer.append(upgrade)
		
	placements[upgrade] = Vector2(x, 0)
			
	for i in range(onLayer.size()):
		placements[onLayer[i]] = Vector2(placements[onLayer[i]].x, size/(onLayer.size() + 1) * (i+1))
	
func roundTo(num:float, roundTo:float)->float:
	return round(num * roundTo)/roundTo

func calcMaxVerticalLayers():
	var most = 0
	
	for upgrade in upgrades:
		most = max(countVerticalLayers(upgrade), most)
		
	return most


func countVerticalLayers(upgradeName):
	#print(upgrades)
	var requirements = upgrades[upgradeName]
	var layerCount = 0

	for requirement in requirements:
		var requirementLayers = countVerticalLayers(requirement)
		if requirementLayers > layerCount:
			layerCount = requirementLayers

	return layerCount + 1
					
		
func createLine(point1:Vector2, point2:Vector2, upgrade:String):
	var line = Line2D.new()
	line.add_point(point1)
	line.add_point(point2)
	#line.default_color = color
	line.z_index = -1
	background.add_child(line)
	
	if not upgrade in lines:
		lines[upgrade] = [line]
	else:
		lines[upgrade].append(line)

func createLock(upgrade):
	var texture = lockSprite
		
	var position = placements[upgrade]

	var sprite = Sprite.new()
	sprite.texture = texture
	sprite.position = position
	sprite.z_index = 8
	background.add_child(sprite)
	
	locks[upgrade] = sprite


func createTextureButton(upgrade):
	var texture = nullSprite
	if upgrade in upgradeSprites:
		texture = upgradeSprites[upgrade]
		
	var position = placements[upgrade]

	var button = TextureButton.new()
	button.texture_normal = texture
	button.expand = true
	button.name = upgrade
	button.connect("pressed", self, "_onUpgradeButtonPressed", [button.name])
	button.connect("mouse_entered", self, "_onUpgradeButtonHovered", [button.name])
	background.add_child(button)
	button.set_position(position-buttonSize/2)
	button.set_size(buttonSize)
	
	buttons[upgrade] = button
	
func updateAvalibleUpgrades()->void:
	if ownedUpgrades.size() == 0:
		for upgrade in upgrades:
			if upgrades[upgrade].size() == 0:
				avalibleUpgrades.append(upgrade)
				
	else:
		var edgeUpgrades = ownedUpgrades.duplicate()
		
		for upgrade in upgrades:
			if upgrades[upgrade].size() == 0 and not upgrade in ownedUpgrades:
				avalibleUpgrades.append(upgrade)
		
		if oneWay:
			for upgrade in ownedUpgrades:
				for i in range(upgrades[upgrade].size()):
					if upgrades[upgrade][i] in ownedUpgrades and upgrades[upgrade][i] in edgeUpgrades:
						edgeUpgrades.erase(upgrades[upgrade][i])
					
		for upgrade in upgrades:
			for edgeUpgrade in edgeUpgrades:
				if edgeUpgrade in upgrades[upgrade] and not upgrade in avalibleUpgrades and not upgrade in ownedUpgrades:
					avalibleUpgrades.append(upgrade)
		
	if needAllPrevious:
		var remove = []
		
		for avalible in avalibleUpgrades:
			for upgrade in upgrades:	
				if avalible != upgrade and not upgrade in ownedUpgrades and upgrade in upgrades[avalible]:
					remove.append(avalible)
					break
				
				
		for i in range(remove.size()):
			avalibleUpgrades.erase(remove[i])
			
			
	#print(avalibleUpgrades)
	
	if oneWay:
		createLocks()
		
	removeLocks()
	updateColors()

func removeLocks()->void:
	for upgrade in avalibleUpgrades:
		if upgrade in locks:
			locks[upgrade].queue_free()
			locks.erase(upgrade)
			
func createLocks()->void:
	for upgrade in upgrades:
		if not upgrade in ownedUpgrades and not upgrade in avalibleUpgrades and not upgrade in locks:
			createLock(upgrade)
		
	
func updateColors()->void:
	for upgrade in upgrades:
		if not upgrade in ownedUpgrades:
			if upgrade in lines:
				for i in range(lines[upgrade].size()):
					if upgrade in avalibleUpgrades:
						lines[upgrade][i].default_color = UNLOCKINGCOLOR
					else:
						lines[upgrade][i].default_color = LOCKEDCOLOR
						
			buttons[upgrade].modulate = Color(0.5,0.5,0.5)
			
		else:
			if upgrade in lines:
				for i in range(lines[upgrade].size()):
						lines[upgrade][i].default_color = UNLOCKEDCOLOR
						
			buttons[upgrade].modulate = Color(1,1,1)
						
					
						
						

	
		

func _onUpgradeButtonPressed(upgrade):
	if game.money >= tower.prices[upgrade]*(1/tower.buffs[tower.BUFFS.COSTREDUCTION]) and upgrade in avalibleUpgrades:
		ownedUpgrades.append(upgrade)
		avalibleUpgrades = []
		updateAvalibleUpgrades()
		tower.sellValue += tower.prices[upgrade]*1/tower.buffs[tower.BUFFS.COSTREDUCTION]
		tower.updateUpgrade(upgrade)
		tower.updateBoosts()
		game._addMoney(-1*tower.prices[upgrade]*(1/tower.buffs[tower.BUFFS.COSTREDUCTION]))
		if oneWay and not tower.maxed and avalibleUpgrades.size() == 0:
			Perks.currentCharges[tower.towerName] += 1
			tower.maxed = true
			game.updateCharge(tower.towerName)

func _onUpgradeButtonHovered(upgrade):
	var texture = nullSprite
	var cost = -1
	var description = "No description found."
	
	if upgrade in upgradeSprites:
		texture = upgradeSprites[upgrade]
	if upgrade in prices:
		cost = prices[upgrade] * (1/tower.buffs[tower.BUFFS.COSTREDUCTION])
	if upgrade in descriptions:
		description = descriptions[upgrade]
		
	nameText.bbcode_text = "Name: " + upgrade
	descriptionText.bbcode_text = "Description: " + description
	costText.bbcode_text = "Cost: " + String(cost)
	
	icon.texture = texture
	
	nameText.visible = true
	descriptionText.visible = true
	costText.visible = true
	icon.visible = true

func _on_Exit_pressed():
	queue_free()
	game.buttonsEnabled = true





































"""
func linesCollide(a: Vector2, b: Vector2, c: Vector2, d: Vector2) -> bool:
	var denominator = (b.x - a.x) * (d.y - c.y) - (b.y - a.y) * (d.x - c.x)
	var numerator1 = (a.y - c.y) * (d.x - c.x) - (a.x - c.x) * (d.y - c.y)
	var numerator2 = (a.y - c.y) * (b.x - a.x) - (a.x - c.x) * (b.y - a.y)

	if denominator == 0:
		return numerator1 == 0 and numerator2 == 0

	var r = numerator1 / denominator
	var s = numerator2 / denominator

	#greater/less than or EQUALS if you want end touching collision
	return (r > 0 and r < 1) and (s > 0 and s < 1)
"""

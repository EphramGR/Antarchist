extends CanvasLayer

enum TOWER {CANNON, ARCHER, CASTLE, FLAIL, MORTAR, SALVO, FLAME, ICE, NEEDLE, INFERNO, TESLA, VORTEX, DRONE, BOOST, STOCK}

const lock = preload("res://Assets/SkillTree/lock.png")

const towerNames = {
	TOWER.CANNON:"Cannon", 
	TOWER.ARCHER:"Archer",
	TOWER.CASTLE:"Castle", 
	TOWER.FLAIL:"Flail", 
	TOWER.MORTAR:"Mortar",
	TOWER.SALVO:"Salvo", 
	TOWER.FLAME:"Flame", 
	TOWER.ICE:"Ice", 
	TOWER.NEEDLE:"Needle", 
	TOWER.INFERNO:"Inferno", 
	TOWER.TESLA:"Tesla",
	TOWER.VORTEX:"Vortex",
	TOWER.DRONE:"Drone", 
	TOWER.BOOST:"Boost",
	TOWER.STOCK:"Stock"
	}

onready var scroll = get_node("VScrollBar")
onready var bg = get_node("perkbg")
onready var scrollOffset = get_node("UIbg").rect_size.y

onready var towerButtons = [
	get_node("UIbg/Perk1Lock"),
	get_node("UIbg/Perk2Lock"),
	get_node("UIbg/Perk3Lock")
]

#logic
var currentValue = 0
var inScroll = false

var towersSelected = []

#settings
var numPerksX = 3
var numPerksY = 5

func _ready():
	#OS.window_fullscreen = true
	placeTextureButtons()
	updateSelectedPerks()
	updateTextureButtons()
	get_tree().get_root().connect("size_changed", self, "updateTextureButtons")
	
func _process(delta):
	if Input.is_action_pressed("left_click") and inScroll:
		calcWhereToScroll(get_viewport().get_mouse_position().y)
		
	#updateTextureButtons()
	
func movePerks():
	var screenSize = get_viewport().size.y
	
	var scrollDistance = bg.rect_size.y - screenSize
	
	bg.rect_global_position.y = scrollDistance*-(currentValue/100)+scrollOffset
	
func placeTextureButtons():
	var bgX =  get_viewport().size.x
	var buttonSize = bgX/4
	
	
	for y in range(numPerksY):
		for x in range(numPerksX):
			var textureButton = TextureButton.new()
			var index = y*numPerksX+x
			var towerName = towerNames[index]
			
			textureButton.texture_normal = Perks.towerThumbnails[towerName]
				
			textureButton.expand = true
			
			textureButton.connect("pressed", self, "_on_perk_pressed", [towerName])
			
			#textureButton.mouse_filter = Control.MOUSE_FILTER_PASS
			
			bg.add_child(textureButton)
			
				
			
			
func updateTextureButtons():
	var children = bg.get_children()
	
	var bgX =  get_viewport().size.x
	var buttonSize = bgX/4
	
	
	for y in range(numPerksY):
		for x in range(numPerksX):
			children[(y*3)+x].rect_size = Vector2(buttonSize,buttonSize)
			
			var offsetX = buttonSize/(numPerksX+1)*(1+x)
			var offsetY = buttonSize/(numPerksY+1)*(1+y)
			
			children[(y*3)+x].rect_position = Vector2(offsetX+buttonSize*x,offsetY+buttonSize*y)
			
	bg.rect_size.y = buttonSize*(numPerksY+1)+buttonSize/2
	bg.rect_size.x = buttonSize*(numPerksX+1)
			
			
	
#Scroll bar function
func scrollTo(value, moveScroll=false):
	currentValue = max(min(value,100),0)
	
	if moveScroll:
		scroll.value = currentValue
		
	movePerks()
	
func calcWhereToScroll(y):
	scrollTo(y/get_viewport().get_visible_rect().size.y *100, true)
	
	
	
	
func removePerk(perk:String)->void:
	towersSelected.erase(perk)
		
	updateSelectedPerks()
	
func updateSelectedPerks():
	for i in range(3):
		if Perks.activePerks["Polisher"] < i:
			towerButtons[i].texture = lock
		elif towersSelected.size() >= i+1:
			towerButtons[i].texture = Perks.towerThumbnails[towersSelected[i]]
		else:
			towerButtons[i].texture = null
			
	
func updateText(perk:String,left:bool):
	var perkName:RichTextLabel
	var description:RichTextLabel
	var lvl:RichTextLabel
	
	if left:
		perkName = get_node("TextLeft/Name")
		description = get_node("TextLeft/Description")
		lvl = get_node("TextLeft/Lvl")
	else:
		perkName = get_node("TextRight/Name")
		description = get_node("TextRight/Description")
		lvl = get_node("TextRight/Lvl")
		
	perkName.text = perk
	description.text = String(Perks.perksDescriptions[perk])
	lvl.text = "1: " + String(Perks.perksLvls[perk][0]) + "\n2: " + String(Perks.perksLvls[perk][1]) + "\n3: " + String(Perks.perksLvls[perk][2])
	
func _input(event: InputEvent) -> void:
	if event is InputEventMouseButton:
		if event.is_pressed():
			if event.button_index == BUTTON_WHEEL_UP:
				scrollTo(currentValue-3,true)
			if event.button_index == BUTTON_WHEEL_DOWN:
				scrollTo(currentValue+3,true)
				
				

func _on_VScrollBar_mouse_entered():
	inScroll = true

func _on_VScrollBar_mouse_exited():
	inScroll = false


func _on_Perk1_pressed():
	if towersSelected.size() >= 1:
		removePerk(towersSelected[0])
			

func _on_Perk2_pressed():
	if towersSelected.size() >= 2:
		removePerk(towersSelected[1])


func _on_Perk3_pressed():
	if towersSelected.size() >= 3:
		removePerk(towersSelected[2])
	
	
func _on_perk_pressed(index):
	if towersSelected.size() <= Perks.activePerks["Polisher"] and not index in towersSelected:
		towersSelected.append(index)
		updateSelectedPerks()
				

		
	
	
func _on_StartButton_pressed():
	for i in range(towersSelected.size()):
		Perks.maxCharges[towersSelected[i]] -= 1
		
	print(Perks.maxCharges)
		
	var scene_tree = get_tree()
	scene_tree.change_scene("res://Scenes/Game.tscn")

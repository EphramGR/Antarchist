extends CanvasLayer

#reference
const nullSprite = preload("res://Assets/SkillTree/nullSprite.png")
const oneStar = preload("res://Assets/SkillTree/Perk/oneStar.png")
const twoStar = preload("res://Assets/SkillTree/Perk/twoStar.png")
const threeStar = preload("res://Assets/SkillTree/Perk/threeStar.png")
const noneSelected = preload("res://Assets/SkillTree/Perk/emptyPerk.png")
const lock = preload("res://Assets/SkillTree/lock.png")

onready var scroll = get_node("VScrollBar")
onready var bg = get_node("perkbg")
onready var scrollOffset = get_node("UIbg").rect_size.y
onready var leftDesc = get_node("TextLeft")
onready var rightDesc = get_node("TextRight")

onready var perkButtons = [
	get_node("UIbg/Perk1"),
	get_node("UIbg/Perk2"),
	get_node("UIbg/Perk3"),
	get_node("UIbg/Perk4"),
	get_node("UIbg/Perk5")
]

onready var perkStars = [
	get_node("UIbg/Perk1Star"),
	get_node("UIbg/Perk2Star"),
	get_node("UIbg/Perk3Star"),
	get_node("UIbg/Perk4Star"),
	get_node("UIbg/Perk5Star")
]

#logic
var currentValue = 0
var inScroll = false

var selectedPerks = {}
var perkPoints = Perks.perkPoints

#settings
var numPerksX = 3
var numPerksY = 10

func _ready():
	#OS.window_fullscreen = true
	placeTextureButtons()
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
			
			textureButton.texture_normal = load("res://Assets/SkillTree/Perk/"+ Perks.numToPerk[index] +".png")
			
			if not Perks.numToPerk[index] in Perks.ownedPerks:
				textureButton.modulate = Color(0.5,0.5,0.5)
				
				
			textureButton.expand = true
			
			textureButton.connect("pressed", self, "_on_perk_pressed", [index])
			textureButton.connect("mouse_entered", self, "_on_perk_mouse_entered", [index])
			textureButton.connect("mouse_exited", self, "_on_perk_mouse_exited", [index])
			
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
	perkPoints += 1
	selectedPerks[perk] -= 1
		
	if selectedPerks[perk] < 0:
		selectedPerks.erase(perk)
		
	updateSelectedPerks()
	
func updateSelectedPerks():
	var selectedArray = selectedPerks.keys()
	
	for i in range(5):
		if selectedArray.size() >= i+1:
			if selectedPerks[selectedArray[i]] == 0:
				perkStars[i].texture = oneStar
			elif selectedPerks[selectedArray[i]] == 1:
				perkStars[i].texture = twoStar
			elif selectedPerks[selectedArray[i]] == 2:
				perkStars[i].texture = threeStar
			else:
				print("selectedPerks[", selectedArray[i], "] = ", selectedPerks[selectedArray[i]])
				
	
			perkButtons[i].texture_normal = load("res://Assets/SkillTree/Perk/"+ selectedArray[i] +".png")
		
			
			
		else:
			perkButtons[i].texture_normal = noneSelected
			perkStars[i].texture = null
			
	get_node("UIbg/PerkPoints").text = "Perk Points: " + String(perkPoints)
	
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
	if selectedPerks.size() >= 1:
		removePerk(selectedPerks.keys()[0])
			

func _on_Perk2_pressed():
	if selectedPerks.size() >= 2:
		removePerk(selectedPerks.keys()[1])


func _on_Perk3_pressed():
	if selectedPerks.size() >= 3:
		removePerk(selectedPerks.keys()[2])


func _on_Perk4_pressed():
	if selectedPerks.size() >= 4:
		removePerk(selectedPerks.keys()[3])


func _on_Perk5_pressed():
	if selectedPerks.size() >= 5:
		removePerk(selectedPerks.keys()[4])
	
	
func _on_perk_pressed(index):
	if perkPoints > 0:
		var perk:String = Perks.numToPerk[index]
		
		if perk in Perks.ownedPerks:
		
			if not perk in selectedPerks and selectedPerks.size() < 5:
				perkPoints -= 1
				selectedPerks[perk] = 0
				updateSelectedPerks()
				
			elif perk in selectedPerks and selectedPerks[perk] < 2:
				perkPoints -= 1
				selectedPerks[perk] += 1
				updateSelectedPerks()
				
func _on_perk_mouse_entered(index):
	var perk:String = Perks.numToPerk[index]
	
	if index%3 == 0:
		rightDesc.visible = true
		updateText(perk, false)
	else:
		leftDesc.visible = true
		updateText(perk, true)
		
	

func _on_perk_mouse_exited(index):
	var perk:String = Perks.numToPerk[index]
	
	if index%3 == 0:
		rightDesc.visible = false
		updateText(perk, false)
	else:
		leftDesc.visible = false
		updateText(perk, true)
		
	
	
func _on_StartButton_pressed():
	var scene_tree = get_tree()
	Perks.activePerks = selectedPerks
	Perks.updatePerks()
	Perks.printDif()
	
	if not "Polisher" in selectedPerks:
		scene_tree.change_scene("res://Scenes/Game.tscn")
	else:
		scene_tree.change_scene("res://Scenes/TowerSelection.tscn")

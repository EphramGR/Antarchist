extends Node2D

enum TOWER {ARCHER, BOOST, CANNON, CASTLE, FLAIL, FLAME, ICE, INFERNO, MORTAR, NEEDLE, DRONE, SALVO, STOCK, TESLA, VORTEX}

var chunks = {}
var sideChunks = {}
var buttons = []
#var sideChunkButtons = {}
#SOMEHTING IS WRONG WITH SELLING MAXED TOWERS.MAKE SURE ITCACTUALY SENDS IT TO NEGATIVES. AND THINK ABOUT SELLING MINT
const directions = [Vector2(0,-1), Vector2(1,0), Vector2(0,1), Vector2(-1,0), Vector2.ZERO]

const chunkScene = preload("res://Scenes/Chunk.tscn")
const chunkButton = preload("res://Scenes/ChunkButton.tscn")

const infoScene = preload("res://Scenes/InfoBoard.tscn")

const playSprite = preload("res://Assets/UI/PlayButton/play.png")
const pauseSprite = preload("res://Assets/UI/PlayButton/pause.png")
const fastSprite = preload("res://Assets/UI/PlayButton/fast.png")
const fasterSprite = preload("res://Assets/UI/PlayButton/faster.png")

var speedIndex = 1
var visualizePhere = true

onready var moneyText = get_node("CanvasLayer/UI/Curency/Money")
onready var lumensText = get_node("CanvasLayer/UI/Curency/Lumens")
onready var healthbar = get_node("CanvasLayer/UI/Health")
onready var actualhealthbar = get_node("CanvasLayer/UI/ActualHealth")
onready var barbCost = get_node("CanvasLayer/UI/barbButton/barbCost")
onready var waveText = get_node("CanvasLayer/UI/Wave")
onready var playButton = get_node("CanvasLayer/UI/Play")

const names = {
	TOWER.ARCHER:"Archer", 
	TOWER.BOOST:"Boost", 
	TOWER.CANNON:"Cannon", 
	TOWER.CASTLE:"Castle", 
	TOWER.FLAIL:"Flail", 
	TOWER.FLAME:"Flame", 
	TOWER.ICE:"Ice", 
	TOWER.INFERNO:"Inferno", 
	TOWER.MORTAR:"Mortar", 
	TOWER.NEEDLE:"Needle", 
	TOWER.DRONE:"Drone", 
	TOWER.SALVO:"Salvo", 
	TOWER.STOCK:"Stock", 
	TOWER.TESLA:"Tesla", 
	TOWER.VORTEX:"Vortex"
}

const towerScenes = {
	TOWER.ARCHER:preload("res://Scenes/ArcherTower.tscn"), 
	TOWER.BOOST:preload("res://Scenes/BoostTower.tscn"), 
	TOWER.CANNON:preload("res://Scenes/Cannon.tscn"), 
	TOWER.CASTLE:preload("res://Scenes/Castle.tscn"), 
	TOWER.FLAIL:preload("res://Scenes/Flail.tscn"), 
	TOWER.FLAME:preload("res://Scenes/FlameThrower.tscn"), 
	TOWER.ICE:preload("res://Scenes/IceTower.tscn"), 
	TOWER.INFERNO:preload("res://Scenes/Inferno.tscn"), 
	TOWER.MORTAR:preload("res://Scenes/Mortar.tscn"), 
	TOWER.NEEDLE:preload("res://Scenes/Needle.tscn"), 
	TOWER.DRONE:preload("res://Scenes/Plane.tscn"), 
	TOWER.SALVO:preload("res://Scenes/Salvo.tscn"), 
	TOWER.STOCK:preload("res://Scenes/StockTower.tscn"), 
	TOWER.TESLA:preload("res://Scenes/Tesla.tscn"), 
	TOWER.VORTEX:preload("res://Scenes/Vortex Tower.tscn")
}

const popupTextScene = preload("res://Scenes/PopupText.tscn")

onready var barbButton = get_node("CanvasLayer/UI/barbButton")
const defaultBarbTexture = preload("res://Assets/UI/barbBut.png")
const toggledBarbTexture = preload("res://Assets/UI/barbButPressed.png")
onready var towerHolder = get_node("CanvasLayer/UI/Handle/Charge/Sprite")
var barbBeingPlaced = false


const backgroundScaleStart = 2.5
const backgroundScaleMultiplier = 3.8
onready var background = get_node("background")
onready var light = get_node("bgFogCut")
const lightTextures = [preload("res://Assets/bgFogCuttout0.png"),
preload("res://Assets/bgFogCuttout1.png"),
preload("res://Assets/bgFogCuttout2.png"),
preload("res://Assets/bgFogCuttout3.png"),
preload("res://Assets/bgFogCuttout4.png"),
preload("res://Assets/bgFogCuttout5.png")]

onready var upgradesButton = get_node("CanvasLayer/UI/Upgrades")
onready var infoButton = get_node("CanvasLayer/UI/Info")

var chunkSize = Vector2.ZERO

var redoFirst = true

var buttonsAt = []

var redoCoords
var redoDirection

var buttonsEnabled = true

var size = Vector2(3, 3)

const baseInstance = preload("res://Scenes/Base.tscn")
const colonyInstance = preload("res://Scenes/Colony.tscn")

var base
var colony

var actualBackgroundScale:Vector2
var previousScale:Vector2
const growTime = 3
var timeToGrow = 0

var rect_min 
var rect_max


const wallInstance = preload("res://Scenes/BarbedWire.tscn")
#array of currently active barbs
var barbHandle = []
var activeBarbs = {}


var selected = null
var previousSelected = null
var lastSelected = null

const upgradeScene = preload("res://Scenes/UpgradeTree.tscn")

var animating = false
var extended = false

const animationDuration = 0.3
var animatingTime = 0

onready var handle = get_node("CanvasLayer/UI/Handle")
onready var initialHandlePos = handle.rect_position
var handleOffset = Vector2(340,0)

#player stuff
var money = Perks.startingCash
var lumens:int = Perks.startingLumens

var waveEndLumens:int = Perks.waveEndLumens
var waveIndex = 0


#circle
var startingScale:Vector2
var circleCloseDuration:float
const circleDistanceFactor = 0.6
var circleClosing = false
var circleCurrentTime:float
onready var circleCloseButton = get_node("CanvasLayer/UI/CircleClosing")

#debug
var autoBuild = false

var nullButtonDic = {}
var createChunkYeild = null
var createChunkIsYeilding = false

var spawnerDebug = true
var spawnerAmount = 1
var togglePheromones = true

func _ready():
	
	if Perks.currentCharges["Cannon"] != 0:
		var towerNames = Perks.costs.keys()
		for tower in towerNames:
			updateCharge(tower)
	
	randomize()
	sideChunks[Vector2(0,0)] = [true, true, true, true]
	create_chunk(Vector2(0,0), true, 4)
	if not spawnerDebug:
		get_node("CanvasLayer/UI/HSlider").queue_free()
	if not togglePheromones:
		get_node("CanvasLayer/UI/CheckButton").queue_free()
		
	Engine.time_scale = 0.5
	makeBase()
	
	for tower in Perks.maxCharges:
		get_node("CanvasLayer/UI/Handle/Charge/" + tower).max_value = Perks.maxCharges[tower]
	
		
func _process(delta):
	if autoBuild and createChunkIsYeilding:
		createChunkYeild = createChunkYeild.resume()
	
	if Input.is_action_just_pressed("ui_cancel"):
		clearColony()
		makeColony()
	if Input.is_action_just_pressed("ui_focus_next"):
		clearColony()
		colony = null
		#print(Perks.currentCharges)
		
	if selected != null and previousSelected != selected:
		toggleSkillTreeButton()
		previousSelected = selected
		lastSelected = selected
		
	elif selected == null and previousSelected != null:
		toggleSkillTreeButton()
		previousSelected = null
		
	handleAnimation(delta)
	
		
func openUpgradeTree(tower:Object):
	var upgradeSceneInstance = upgradeScene.instance()
	upgradeSceneInstance.upgrades = tower.upgrades
	upgradeSceneInstance.upgradeSprites = tower.upgradeSprites
	upgradeSceneInstance.descriptions = tower.descriptions
	upgradeSceneInstance.ownedUpgrades = tower.ownedUpgrades
	upgradeSceneInstance.prices = tower.prices
	upgradeSceneInstance.game = self
	upgradeSceneInstance.tower = tower
	upgradeSceneInstance.oneWay = not tower.mint
	
	if tower.towerName == "Stock":
		tower.upgradePressed()
	
	add_child(upgradeSceneInstance)
	
func updateCharge(tower:String):
	get_node("CanvasLayer/UI/Handle/Charge/" + tower).value = Perks.currentCharges[tower]
	
	#print(Perks.currentCharges[tower])
	
	if Perks.currentCharges[tower] >= Perks.maxCharges[tower]:
		var sprite = get_node("CanvasLayer/UI/Handle/ButtonContainer/" + tower)
		
		if tower == "Archer":
			sprite.texture_normal = load("res://Assets/Buildings/Towers/Archer/arch_0_mint.png")
		elif tower == "Cannon":
			sprite.texture_normal = load("res://Assets/Buildings/Towers/Cannon/cannon_tumbnail_mint.png")
		elif tower == "Castle":
			sprite.texture_normal = load("res://Assets/Buildings/Towers/Castle/castle_0_mint.png")
		elif tower == "Flail":
			sprite.texture_normal = load("res://Assets/Buildings/Towers/Flail/flail_0_mint.png")
		elif tower == "Mortar":
			sprite.texture_normal = load("res://Assets/Buildings/Towers/Mortar/mortar_thumbnail_mint.png")
		elif tower == "Salvo":
			sprite.texture_normal = load("res://Assets/Buildings/Towers/Salvo/salvo_thumbnail_mint.png")
		elif tower == "Flame":
			sprite.texture_normal = load("res://Assets/Buildings/Towers/FlameThrower/flame_thumbnail_mint.png")
		elif tower == "Ice":
			sprite.texture_normal = load("res://Assets/Buildings/Towers/IceTower/icetower_0_mint.png")
		elif tower == "Needle":
			sprite.texture_normal = load("res://Assets/Buildings/Towers/Needle/needle_0_mint.png")
		elif tower == "Inferno":
			sprite.texture_normal = load("res://Assets/Buildings/Towers/Inferno/inferno_0_mint.png")
		elif tower == "Tesla":
			sprite.texture_normal = load("res://Assets/Buildings/Towers/Tesla/tesla_0_mint.png")
		elif tower == "Vortex":
			sprite.texture_normal = load("res://Assets/Buildings/Towers/Vortex/vortex_0_mint.png")
		elif tower == "Drone":
			sprite.texture_normal = load("res://Assets/Buildings/Towers/Drone/drone_0_mint.png")
		elif tower == "Boost":
			sprite.texture_normal = load("res://Assets/Buildings/Towers/Boost/boost_0_mint.png")
		elif tower == "Stock":
			sprite.texture_normal = load("res://Assets/Buildings/Towers/Stock/stock_0_mint.png")
			
	elif Perks.currentCharges[tower] <= 0:
		var sprite = get_node("CanvasLayer/UI/Handle/ButtonContainer/" + tower)
		
		if tower == "Archer":
			sprite.texture_normal = load("res://Assets/Buildings/Towers/Archer/arch_0.png")
		elif tower == "Cannon":
			sprite.texture_normal = load("res://Assets/Buildings/Towers/Cannon/cannon_tumbnail.png")
		elif tower == "Castle":
			sprite.texture_normal = load("res://Assets/Buildings/Towers/Castle/castle_0.png")
		elif tower == "Flail":
			sprite.texture_normal = load("res://Assets/Buildings/Towers/Flail/flail_0.png")
		elif tower == "Mortar":
			sprite.texture_normal = load("res://Assets/Buildings/Towers/Mortar/mortar_thumbnail.png")
		elif tower == "Salvo":
			sprite.texture_normal = load("res://Assets/Buildings/Towers/Salvo/salvo_thumbnail.png")
		elif tower == "Flame":
			sprite.texture_normal = load("res://Assets/Buildings/Towers/FlameThrower/flame_thumbnail.png")
		elif tower == "Ice":
			sprite.texture_normal = load("res://Assets/Buildings/Towers/IceTower/icetower_0.png")
		elif tower == "Needle":
			sprite.texture_normal = load("res://Assets/Buildings/Towers/Needle/needle_0.png")
		elif tower == "Inferno":
			sprite.texture_normal = load("res://Assets/Buildings/Towers/Inferno/inferno_0.png")
		elif tower == "Tesla":
			sprite.texture_normal = load("res://Assets/Buildings/Towers/Tesla/tesla_0.png")
		elif tower == "Vortex":
			sprite.texture_normal = load("res://Assets/Buildings/Towers/Vortex/vortex_0.png")
		elif tower == "Drone":
			sprite.texture_normal = load("res://Assets/Buildings/Towers/Drone/drone_0.png")
		elif tower == "Boost":
			sprite.texture_normal = load("res://Assets/Buildings/Towers/Boost/boost_0.png")
		elif tower == "Stock":
			sprite.texture_normal = load("res://Assets/Buildings/Towers/Stock/stock_0.png")
	
func _on_CircleClosing_pressed():
	circleCloseDuration = background.scale.x * circleDistanceFactor
	circleCurrentTime = 0
	startingScale = background.scale
	circleClosing = true
	circleCloseButton.visible = false
	
func circleCloseProcess(delta):
	circleCurrentTime += delta
	background.scale = startingScale.linear_interpolate(Vector2.ONE, circleCurrentTime/circleCloseDuration)
	loadLightTexture(round(circleCurrentTime/circleCloseDuration*6))
	if colony != null:
		colony.mapSize = getCircleRadius()
	
	if circleCurrentTime >= circleCloseDuration:
		circleClosing = false
		
func loadLightTexture(index:int):
	if index > 5:
		index = 5
	light.texture = lightTextures[index]
	
func isWaveActive()->bool:
	return not TimeScaler.prep

func toggleSkillTreeButton():
	upgradesButton.visible = not upgradesButton.visible
	infoButton.visible = not infoButton.visible
	
func toggleSkillTreeButtonForStock():
	previousSelected = null
	selected = null
	toggleSkillTreeButton()
	
func makeBase():
	if base == null:
		base = baseInstance.instance()
		base.position = Vector2.ZERO
		add_child(base)
		
		var sprite = base.get_node("Sprite")
		
		rect_min = sprite.global_position - (sprite.texture.get_size() * sprite.scale) / 2.0
		rect_max = sprite.global_position + (sprite.texture.get_size() * sprite.scale) / 2.0
		
		base.healthbar = healthbar
		base.actualhealthbar = actualhealthbar
		var sheild = get_node("CanvasLayer/UI/Shield")
		base.sheildBar = sheild
		sheild.value = Perks.maxSheildHits
		base.game = self
		
		healthbar.max_value = base.MAXFOOD
		actualhealthbar.max_value = base.MAXFOOD

func makeColony():
	colony = colonyInstance.instance()
	
	if buttonsAt.size() != 0:
		colony.position = buttonsAt[randi() % buttonsAt.size()] * chunkSize
	else:
		colony.position = Vector2(randi()%5 - 2, randi()%5 - 2) * chunkSize
		
	colony.radius = colony.position.distance_to(position)
	colony.mapSize = getCircleRadius()
	colony.base = base
	colony.rect_min = rect_min
	colony.rect_max = rect_max
	colony.z_index = 4
	colony.defaultBonus = (waveIndex*25 + 100)
	colony.visualizePheromoneTrails = visualizePhere
	colony.data = TimeScaler.getWaveData(waveIndex)
	waveIndex += 1
	
	
	if spawnerDebug:
		colony.numToSpawn = spawnerAmount
		
	add_child(colony)
	TimeScaler.prep = false
	
func _addMoney(amount:float, addLumens:bool=false):
	money += amount
	
	#Cumulative Cost per layer = 1 + 4 + 8 + 12 + ... + (4n - 3). 14.5 layers by wave 100 (400-1-4-8-12-16-20-24-28-32-36-40-44-48-52=35)
	if addLumens:
		if waveIndex < 100:
			lumens += waveEndLumens
		waveEnd()
		
func waveEnd():
	circleClosing = false
	circleCloseButton.visible = false
	updateLumens()
	updateCircle()
	playButton.texture_normal = pauseSprite
	base.foodHeld = 0
	base.foodLeft = min(base.foodLeft+Perks.regenPercent*base.MAXFOOD, base.MAXFOOD)
	base.sheildHits = Perks.maxSheildHits
	base.updateHealthBar()
	


func clearColony():
	if colony != null and is_instance_valid(colony):
		colony.killAnts()
		colony.queue_free()
		TimeScaler.prep = true
		playButton.texture_normal = pauseSprite
		waveEnd()


















func create_chunk(coords, firstChunk, i):

	
	var direction = directions[i]
	
	var pos = coords + direction
	# Create a new Chunk node and add it to the scene
	
	var chunk = chunkScene.instance()
	chunk.firstChunk = firstChunk
	chunk.size = size
	
	if autoBuild:
		chunk.autoBuild = true
	

	
	if not firstChunk:
		chunk.adjDic = calcAdj(coords, i)
		
		if autoBuild:
			while chunk.adjDic is GDScriptFunctionState:
				createChunkIsYeilding = true
				yield()
				chunk.adjDic = chunk.adjDic.resume()
			createChunkIsYeilding = false
		
	
		var connections = calcConnections(coords, i)
		
		chunk.corners = getCorners(coords + direction).duplicate()
		
		chunk.newSize = cases(connections)
		

	

	
	get_node("ChunkContainer").add_child(chunk)


	
	if chunkSize == Vector2.ZERO:
		chunkSize = chunk.getActualSize() #fast
	
	# Set the chunk's position based on its coordinates
	chunk.position = pos * chunkSize

	# Add the chunk to the dictionary, keyed by its coordinates
	chunks[pos] = chunk
	
	updateCircle()
	
	return chunk


	

func isSideChunk(pos):
	var posAdj = [true, true, true, true]
	
	for i in range(4):
		if pos+directions[i] in chunks:
			posAdj[i] = false
			
	if true in posAdj:
		sideChunks[pos] = posAdj
		
		
func updateButtons():
	calcSideChunks()
	
	for chunk in sideChunks:
		#sideChunkButtons[chunk] = [null, null, null, null]
		for i in range(4):
			if sideChunks[chunk][i]:
				if validButton2(chunk+directions[i]):
					drawButton(chunk, i)
					
	updateLumens()
				
func drawButton(pos: Vector2, i: int) -> void:
	
	if not pos + directions[i] in buttonsAt:
		buttonsAt.append(pos + directions[i])
		
		if not autoBuild:
			var center = pos*chunkSize-(chunkSize/2)
			
			var direction = directions[i]*chunkSize
			
			var button = chunkButton.instance()
			button.coords = pos
			button.direction = i
			add_child(button)
			button.rect_position = center + direction + chunkSize/2 - Vector2(28, 28) 
			buttons.append(button)
		else:
			nullButtonDic[pos + directions[i]] = [pos, i]
		#28 is size/2
		#sideChunkButtons[pos][i] = button
	
	
	

	
func calcAdj(coords, i):
	var newChunk = coords + directions[i]
	
	var dictOfRules = {}
	
	for chunk in sideChunks:
		for j in range(4):
			if newChunk + directions[j] == chunk:
				dictOfRules[j] = make_deep_copy_yield(chunks[chunk].getWaveRow(j)) 
				
				if autoBuild:
					while dictOfRules[j] is GDScriptFunctionState:
						yield()
						dictOfRules[j] = dictOfRules[j].resume()
				#@j = not append, gunna be problem for corners. cant be append cause dic, 
				#gunna have to null check if exist, if so append so thing at j
	#for num in dictOfRules:
		#for i in range(dictOfRules[num].size()):
			#print(dictOfRules[num][i].keys()) #SUS
	#gives direction and wall on that direction
	#ie right: 0 -> (matricies)0 | left: 0 -> 0(matricies)
	return dictOfRules
				
func calcConnections(coords, i):	
	var newChunk = coords + directions[i]
	
	var connections = [false, false, false, false]
	
	for chunk in sideChunks:
		for j in range(4):
			if newChunk - directions[j] == chunk:
				connections[j] = true
				
	return connections
				
				
func cases(connections):
	return size
	if connections == [true, false, false, false]:
		# up
		#size is 5x6. needs to add row to the bottom of wave function.
		return size + Vector2(1,0)
	elif connections == [false, true, false, false]:
		# right
		#size is 6x5. needs to add row to the left of wave function.
		return size + Vector2(0,1)
	elif connections == [false, false, true, false]:
		# down
		#size is 5x6. needs to add row to the top of wave function.
		return size + Vector2(1,0)
	elif connections == [false, false, false, true]:
		# left
		#size is 6x5. needs to add row to the right of wave function.
		return size + Vector2(0,1)
	elif connections == [true, false, false, true]:
		# up left
		#size is 6x6. needs to add row to the down right of wave function.
		return size + Vector2(1,1)
	elif connections == [true, true, false, false]:
		# up right
		#size is 6x6. needs to add row to the down left of wave function.
		return size + Vector2(1,1)
	elif connections == [true, false, true, false]:
		# up down
		#size is 5x7. needs to add row to the down up of wave function. 
		return size + Vector2(2,0)
	elif connections == [false, true, false, true]:
		# right left
		#size is 7x5. needs to add row to the right left of wave function. 
		return size + Vector2(0,2)
	elif connections == [false, false, true, true]:
		# down left
		#size is 6x6. needs to add row to the up right of wave function.
		return size + Vector2(1,1)
	elif connections == [false, true, true, false]:
		# down right
		#size is 6x6. needs to add row to the up right of wave function.
		return size + Vector2(1,1)
	elif connections == [true, true, true, false]:
		# up right down
		#size is 6x7. needs to add row to the up down left of wave function. 
		return size + Vector2(2,1)
	elif connections == [true, false, true, true]:
		# up down left
		#size is 6x7. needs to add row to the up down right of wave function. 
		return size + Vector2(2,1)
	elif connections == [false, true, true, true]:
		# right down left
		#size is 7x6. needs to add row to the up right left of wave function. 
		return size + Vector2(1,2)
	elif connections == [true, true, false, true]:
		# right down left
		#size is 7x6. needs to add row to the up right left of wave function. 
		return size + Vector2(1,2)
	elif connections == [true, true, true, true]:
		# up right down left
		#size is 7x7. needs to add row to the up right down left of wave function. 
		return size + Vector2(2,2)

	
func getCorners(newChunk):
	var cornerChunks = [null, null, null, null]
	
	"""
	|0 1|
	|2 3|
	"""
	
	for chunk in chunks:
		if newChunk + Vector2(-1,-1) == chunk:
			cornerChunks[0] = chunks[chunk].getBotRight()
		if newChunk + Vector2(-1,1) == chunk:
			cornerChunks[1] = chunks[chunk].getBotLeft()
		if newChunk + Vector2(1,-1) == chunk:
			cornerChunks[2] = chunks[chunk].getTopRight()
		if newChunk + Vector2(1,1) == chunk:
			cornerChunks[3] = chunks[chunk].getTopLeft()
			
	return cornerChunks

func calcSideChunks():
	sideChunks = {}
	
	for pos in chunks:
		isSideChunk(pos)



func redo():
	if redoFirst:
		sideChunks[Vector2(0,0)] = [true, true, true, true]
		create_chunk(Vector2(0,0), true, 4)
		
		
	else:
		createChunkYeild = create_chunk(redoCoords, false, redoDirection)
		
		
func make_deep_copy(original):
	if original is Array:
		var copied = original.duplicate()

		# Recursively copy any nested arrays or dictionaries
		for i in copied.size():
			if copied[i] is Array or copied[i] is Dictionary:
				copied[i] = make_deep_copy(copied[i])

		return copied

	elif original is Dictionary:
		var copied_dict = {}
		for key in original.keys():
			var value = original[key]
			if value is Array or value is Dictionary:
				copied_dict[key] = make_deep_copy(value)

		return copied_dict
		
func make_deep_copy_yield(original):
	if original is Array:
		var copied = original.duplicate()

		# Recursively copy any nested arrays or dictionaries
		for i in copied.size():
			if copied[i] is Array or copied[i] is Dictionary:
				copied[i] = make_deep_copy(copied[i])
				if autoBuild:
					yield()

		return copied

	elif original is Dictionary:
		var copied_dict = {}
		for key in original.keys():
			var value = original[key]
			if value is Array or value is Dictionary:
				copied_dict[key] = make_deep_copy(value)
				if autoBuild:
					yield()

		return copied_dict


func validButton(vec: Vector2) -> bool:
	var clear_to_origin = true
	var x_step = 1 
	if vec.x > 0:
		 x_step = -1
		
	var y_step = 1
	if vec.y > 0:
		y_step = -1
		
	if vec.x == 0 or vec.y == 0:
		return true
	
	# Check x-axis
	var x = vec.x + x_step
	while x != 0 + x_step:
		if not chunks.has(Vector2(x, vec.y)):
			clear_to_origin = false
			break
		x += x_step
	
	# Check y-axis
	var y = vec.y + y_step
	while y != 0 + y_step:
		if not chunks.has(Vector2(vec.x, y)):
			clear_to_origin = false
			break
		y += y_step
	
	return clear_to_origin
	
func validButton2(vec: Vector2) -> bool:
	var clear_to_origin = true
	
	if vec in directions:
		return clear_to_origin
	
	var diamondRadius = abs(vec.x) + abs(vec.y) - 1
	
	
	for i in range(diamondRadius+1):
		#print(Vector2(i, diamondRadius-i), Vector2(-i, diamondRadius-i), 
		#Vector2(i, -(diamondRadius-i)), Vector2(-i, -(diamondRadius-i)))
		if not (Vector2(i, diamondRadius-i)) in chunks:
			clear_to_origin = false
			#print("there is no chunk at ", Vector2(i, diamondRadius-i))
			#print(chunks)
			break
		if i != 0:
			if not (Vector2(-i, diamondRadius-i)) in chunks:
				clear_to_origin = false
				#print("there is no chunk at ", Vector2(-i, diamondRadius-i))
				#print(chunks)
				break
		if i != diamondRadius:
			if not (Vector2(i, -(diamondRadius-i))) in chunks:
				clear_to_origin = false
				#print("there is no chunk at ", Vector2(i, -(diamondRadius-i)))
				#print(chunks)
				break
		if not (Vector2(-i, -(diamondRadius-i))) in chunks:
				clear_to_origin = false
				#print("there is no chunk at ", Vector2(-i, -(diamondRadius-i)))
				#print(chunks)
				break
	
	
	return clear_to_origin
	
	
func createRandomChunk():
	var choosenChunk = buttonsAt[randi() % buttonsAt.size()]
	
	redoFirst = false
	redoCoords = nullButtonDic[choosenChunk][0]
	redoDirection = nullButtonDic[choosenChunk][1]
	#print(nullButtonDic[choosenChunk])
	
	
	buttonsAt.erase(choosenChunk)
	createChunkYeild = create_chunk(nullButtonDic[choosenChunk][0], false, nullButtonDic[choosenChunk][1])
	
	
func createWall():
	var barb = wallInstance.instance()
	barb.add_to_group("Wall")
	barb.game = self
	barb.z_index = 6
	add_child(barb)
	
func changeButtonTexture():
	if barbBeingPlaced:
		barbButton.texture_normal = (defaultBarbTexture)
		barbBeingPlaced = false
		buttonsEnabled = true
	else:
		barbButton.texture_normal = (toggledBarbTexture)
		barbBeingPlaced = true
		
func updateLumens()->void:
	if lumens > 0:
		for button in buttons:
			button.visible = true
	else:
		for button in buttons:
			button.visible = false
			
		
#transfers global coords into chunk at said coords
func getTouchingChunk(coords: Vector2) -> Vector2:
	var halfCheckX = coords.x
	var halfCheckY = coords.y
	
	var xNeg = coords.x < 0
	var yNeg = coords.y < 0
	
	if xNeg:
		halfCheckX = halfCheckX * -1
	if yNeg:
		halfCheckY = halfCheckY * -1
	
	var halfSize = chunkSize/2
	
	while halfCheckX > chunkSize.x:
		halfCheckX -= chunkSize.x
		
	while halfCheckY > chunkSize.y:
		halfCheckY -= chunkSize.y

	var x = int(coords.x / chunkSize.x)
	var y = int(coords.y / chunkSize.y)
	
	if halfCheckX > halfSize.x:
		if xNeg:
			x -= 1
		else:
			x += 1
		
	if halfCheckY > halfSize.y:
		if yNeg:
			y -= 1
		else:
			y += 1
			

	return Vector2(x, y)

func createPopupText(popupText:String):
	var popupTextInstance = popupTextScene.instance()
	popupTextInstance.text = popupText
	
	add_child(popupTextInstance)
	
func updateCircle():
	var farthestChunk = 0
	
	while true:
		if not validButton2(Vector2(farthestChunk,0)):
			break
		farthestChunk += 1
	
	actualBackgroundScale = (backgroundScaleStart + farthestChunk) * Vector2.ONE * backgroundScaleMultiplier
	loadLightTexture(0)
	if timeToGrow <= 0:
		timeToGrow = growTime
	#background.scale = 1.8 * (2.5 + farthestChunk) * Vector2.ONE * 1.6
	#light.scale = background.scale
	
	
func getCircleRadius():
	if circleClosing:
		return background.scale.x * 50 /2
	else:
		return actualBackgroundScale.x * 50 /2 #this is the circle radius
		
		
func updateWallCost(cost:float):
	barbCost.visible = true
	var color:String = "[color=green]"
	if cost > money:
		color = "[color=red]"
	
	barbCost.bbcode_text = "Cost: "+color+String(cost)
	
func disableWallCost():
	barbCost.visible = false

func _on_HSlider_value_changed(value):
	spawnerAmount = value
	
	if colony != null:
		colony.numDead += value - colony.numToSpawn
		colony.numToSpawn = value


func _on_CheckButton_toggled(button_pressed):
	if colony != null and is_instance_valid(colony):
		colony.visualizePheromoneTrails = button_pressed
	visualizePhere = button_pressed


func towerPressed(tower:int):
	buttonsEnabled = false
	createTower(tower)
		
func createTower(tower:int):
	var towerInstance = towerScenes[tower].instance()
	towerInstance.add_to_group("Tower")
	towerInstance.game = self
	towerInstance.towerName = names[tower]
	
	if Perks.currentCharges[names[tower]] >= Perks.maxCharges[names[tower]]:
		towerInstance.mint = true
		Perks.currentCharges[names[tower]] -= Perks.maxCharges[names[tower]]
	
	get_node("TowerContainter").add_child(towerInstance)

func _on_barbButton_pressed():
	if buttonsEnabled:
		createWall()
		changeButtonTexture()
		buttonsEnabled = false


func _on_Time_value_changed(value):
	Engine.time_scale = value

func _on_Upgrades_pressed():
	openUpgradeTree(previousSelected)
	buttonsEnabled = false
	

func _on_Info_pressed():
	openInfoScene(previousSelected)
	buttonsEnabled = false
	
func openInfoScene(tower):
	var infoInstance = infoScene.instance()
	infoInstance.towerName = previousSelected.towerName
	previousSelected.updateStats()
	infoInstance.stats = previousSelected.stats
	infoInstance.game = self
	infoInstance.tower = previousSelected
	infoInstance.sellPrice = previousSelected.calcTotalSellValue()
	add_child(infoInstance)
	
func handleAnimation(delta)->void:
	if animating:
		handleOffset = Vector2(-towerHolder.rect_size.x,0)
		
		animatingTime += delta
		if animatingTime >= animationDuration:
			var pos:Vector2
			if extended:
				pos = initialHandlePos + handleOffset
			else:
				pos = initialHandlePos
				
			handle.set_position(pos)
			animating = false
			animatingTime = 0
			buttonsEnabled = true
			
		else:
			var startPos:Vector2
			var endPos:Vector2
			
			if extended:
				endPos = initialHandlePos + handleOffset
				startPos = initialHandlePos 
			else:
				endPos = initialHandlePos
				startPos = initialHandlePos + handleOffset
				
			handle.set_position(startPos.linear_interpolate(endPos,animatingTime/animationDuration))
			
	moneyText.text = String(money)
	lumensText.text = String(lumens)
	waveText.bbcode_text = "[center]"+String(waveIndex)
	
	if circleClosing:
		circleCloseProcess(delta)
		
	if timeToGrow > 0:
		background.scale = previousScale.linear_interpolate(actualBackgroundScale, 1-timeToGrow/growTime)
		light.scale = background.scale
		timeToGrow -= delta
		if timeToGrow <= 0:
			previousScale = background.scale
		
		
		
func _on_Handle_pressed():
	if buttonsEnabled:
		if not extended:
			initialHandlePos = handle.rect_position
		else:
			initialHandlePos = handle.rect_position - handleOffset
		animating = true
		extended = not extended
		buttonsEnabled = false


func _on_anyTower_pressed(button:int, cost:int):
	if buttonsEnabled:
		if cost <= Perks.freeTowerUnder:
			towerPressed(button)
			animating = true
			extended = not extended
			Perks.freeTowerUnder = -1
		elif money >= cost:
			towerPressed(button)
			animating = true
			extended = not extended
			money -= cost


func _on_SettingsButton_pressed():
	money += 10000


func getPlayTexture():
	if speedIndex == 1:
		Engine.time_scale = 0.5
		return playSprite
	elif speedIndex == 2:
		Engine.time_scale = 0.75
		return fastSprite
	else:
		Engine.time_scale = 1
		return fasterSprite

func _on_Play_pressed():
	if TimeScaler.prep:
		if lumens < Perks.maxLumens:
			makeColony()
			playButton.texture_normal = getPlayTexture()
		else:
			createPopupText("You cannot start a wave with ten or more lumens.")
	else:
		speedIndex += 1
		if speedIndex > 3:
			speedIndex = 1
		playButton.texture_normal = getPlayTexture()










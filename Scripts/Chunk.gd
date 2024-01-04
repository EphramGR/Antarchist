extends Node2D

var size = Vector2(5,5)
var newSize = Vector2(5,5)

var waveFunction = []

var waveFunctionObject = preload("res://Scripts/waveFunction.gd")
var wfc = waveFunctionObject.new()

var tileMap = preload("res://Assets/tilemapCubePremium.png")
var tileMapF = preload("res://Assets/tilemapCubePremiumFlipped.png")

onready var progressBar = $CustomBar
onready var gameScript = get_parent().get_parent()

var unitSize = 4
var offset = Vector2(0, 0)

var currentTiles = []

var firstChunk = true
var adjDic
var adjDicCopy
var cornerCopy
var corners

var bonusX = 0
var bonusY = 0

var autoBuild = false

var initializeYield = null
var isYielding = false

var readyYielding = false
var readyYieldSpot = null


func _ready():
	"""adjDic = make_deep_copy(adjDic)

	if firstChunk:
		initialize(load_prototype_data())
	else:
		
		
		adjDicCopy = make_deep_copy(adjDic)
		
		cornerCopy = make_deep_copy(corners)
		
		
		#printCornerTest()
		initializeYield = initialize2(load_prototype_data(), false)"""
		
	readyYieldSpot = readyYielder()
		
func readyYielder():
	
	
	adjDic = make_deep_copy(adjDic)

	if firstChunk:
		initialize(load_prototype_data())
	else:
		
		
		adjDicCopy = make_deep_copy_yield(adjDic)
		
		while adjDicCopy is GDScriptFunctionState:
			readyYielding = true
			yield()
			adjDicCopy = adjDicCopy.resume()
		readyYielding = false
		
		cornerCopy = make_deep_copy_yield(corners)
		
		while cornerCopy is GDScriptFunctionState:
			readyYielding = true
			yield()
			cornerCopy = cornerCopy.resume()
			
		readyYielding = false
		
		
		#printCornerTest()
		initializeYield = initialize2(load_prototype_data(), false)
		

	
func _process(_delta):
	if isYielding:
		initializeYield = initializeYield.resume()
		
	elif readyYielding:
		readyYieldSpot = readyYieldSpot.resume()
	
	else:
		collapseWaveFunction()
	

#loads json file
func load_prototype_data():
	var file = File.new()
	file.open("res://Scripts/fastLegal.json", file.READ)
	#passes text from json and converts to dict
	var text = file.get_as_text()
	var data = JSON.parse(text).result
	return data
	
func load_data(name):
	var file = File.new()
	file.open("res://Scripts/" + name + ".json", file.READ)
	#passes text from json and converts to dict
	var text = file.get_as_text()
	var data = JSON.parse(text).result
	return data

#creates the wave function, by storeing list of rules in each cell
#_y/_x means not make y/x var
func initialize(data:Dictionary):
	for _y in range(size.y):
		var x = []
		for _x in range(size.x):
			x.append(data.duplicate())
		waveFunction.append(x)
	wfc.yieldTrue = false
	wfc.waveFunction = waveFunction
	wfc.size = size
	wfc.progressBar = progressBar
	wfc.forground = progressBar.get_node("forground")
	wfc.gameScript = self
	wfc.autoBuild = autoBuild
	

func initialize2(data:Dictionary, tryIlligal):
	
	for _y in range(size.y):
		var x = []
		for _x in range(size.x):
			x.append(data.duplicate())
		waveFunction.append(x)
	wfc.waveFunction = waveFunction
	wfc.size = newSize
	wfc.progressBar = progressBar
	wfc.forground = progressBar.get_node("forground")
	wfc.gameScript = self
	wfc.autoBuild = autoBuild
	
	if tryIlligal:
		wfc.tryIlligal()
	
	
	#yeild? 65 long
	var propagateCoords = completeWfc()
	
	if autoBuild:
		while propagateCoords is GDScriptFunctionState:
			isYielding = true
			yield()
			propagateCoords = propagateCoords.resume()
		isYielding = false

	#print("size: "+ String(newSize) + "| coords "+ String(propagateCoords))
	
	

	wfc.firstItterate(make_deep_copy(propagateCoords))
	

		

func collapseWaveFunction():
	#checks if any cell in the wave function contain more than one entery
	if not wfc.isCollapsed():
		wfc.itterate()
			
			
func update():
	clearMeshes()
	visualize_wave_function()

func regen_no_update():
	pass#regenerate?
	
func visualize_wave_function():
	for y in range(size.y-2):
		var X = []
		for x in range(size.x-2):
			if wfc.waveFunction[y+1][x+1].size() == 1:
				var flip = false
				
				var tile = wfc.waveFunction[y+1][x+1].keys()[0]
				#print(tile)
				if tile[0] == "f":
					flip = true
					tile = tile.replace("f", "")
		
				var tile_index = Vector2(int(tile.split(",")[1]), int(tile.split(",")[0]))
				
				var tile_size = Vector2(28, 28)
				
				var crop_region = Rect2(tile_index * tile_size, tile_size)
				
				var sprite = Sprite.new()
				sprite.region_rect = crop_region
				sprite.region_enabled = true
				
				if flip:
					sprite.texture = tileMapF
					sprite.flip_h = true
				else:
					sprite.texture = tileMap
					
				sprite.scale = Vector2(unitSize, unitSize)
				var newY = size.x-x-1
				sprite.position = Vector2((y+1)*unitSize*28-unitSize*28*(size.y-1)/2,
				(newY-1)*unitSize*28-unitSize*28*(size.x-1)/2)
					
				
				add_child(sprite)
				X.append(sprite)
		
		currentTiles.append(X)
		
func visualize_full_wave_function():
	for y in range(size.y):
		var X = []
		for x in range(size.x):
			if wfc.waveFunction[y][x].size() == 1:
				var flip = false
				
				var tile = wfc.waveFunction[y][x].keys()[0]
				
				if tile[0] == "f":
					flip = true
					tile = tile.replace("f", "")
		
				var tile_index = Vector2(int(tile.split(",")[1]), int(tile.split(",")[0]))
				
				var tile_size = Vector2(28, 28)
				
				var crop_region = Rect2(tile_index * tile_size, tile_size)
				
				var sprite = Sprite.new()
				sprite.region_rect = crop_region
				sprite.region_enabled = true
				
				if flip:
					sprite.texture = tileMapF
					sprite.flip_h = true
				else:
					sprite.texture = tileMap
					
				sprite.scale = Vector2(unitSize, unitSize)
				var newY = size.x-x-1
				sprite.position = Vector2((y)*unitSize*28-unitSize*28*(size.y-1)/2,
				(newY)*unitSize*28-unitSize*28*(size.x-1)/2)
					
				
				add_child(sprite)
				X.append(sprite)
		
		currentTiles.append(X)
			



func clearMeshes():
	for y in range(currentTiles.size()):
		for x in range(currentTiles[y].size()):
			currentTiles[y][x].queue_free()
			
	currentTiles = []
	
func applyConstraints():
	pass#likely for shit like clear solos
	
func updateBut():
	gameScript.buttonsEnabled = true
	gameScript.updateButtons()
	
func getWaveRow(direction: int):
	var data = load_prototype_data()
	if direction == 0:
		return make_deep_copy(getBottom(data))
	if direction == 2:
		return make_deep_copy(getTop(data))
	if direction == 3:
		return make_deep_copy(getRight(data))
	if direction == 1:
		return make_deep_copy(getLeft(data))


"""
(4, 0) (4, 1) (4, 2) (4, 3) (4, 4)
(3, 0) (3, 1) (3, 2) (3, 3) (3, 4)
(2, 0) (2, 1) (2, 2) (2, 3) (2, 4)
(1, 0) (1, 1) (1, 2) (1, 3) (1, 4)
(0, 0) (0, 1) (0, 2) (0, 3) (0, 4)
"""

func completeWfc():
	var directions = [Vector2(0,-1), Vector2(1,0), Vector2(0,1), Vector2(-1,0)]
	
	
	if 0 in adjDic:
		for y in range(size.y):
			wfc.waveFunction[y][newSize.x - 1] = adjDic[0][y].duplicate()
	if 1 in adjDic:
		wfc.waveFunction[newSize.y - 1] = adjDic[1].duplicate()
			
	if 2 in adjDic:
		for y in range(size.y):
			wfc.waveFunction[y][0] =  adjDic[2][y].duplicate()
		
		bonusY = 1
		
	if 3 in adjDic:
		wfc.waveFunction[0] = adjDic[3].duplicate()
		bonusX = 1
		
	var propagateCoords = []
	"""
	|0 2|
	|1 3|
	"""
	#wrong 
	if corners[0] != null:
		wfc.waveFunction[0][newSize.x-1] = corners[0]
		propagateCoords.append(Vector2(newSize.x-1, 0))
		
	if corners[1] != null:
		wfc.waveFunction[0][0] = corners[1]
		propagateCoords.append(Vector2(0, 0))
		
	if corners[2] != null:
		wfc.waveFunction[newSize.y-1][newSize.x-1] = corners[2]
		propagateCoords.append(Vector2(newSize.y-1, newSize.x-1))
		
	if corners[3] != null:
		wfc.waveFunction[newSize.y-1][0] = corners[3]
		propagateCoords.append(Vector2(0, newSize.y-1))
		
	
	#change this to include no corners? or rid dupes
	if 0 in adjDic:
		for i in range(size.x):
			propagateCoords.append(Vector2(newSize.y - 1, i))
			
	if 1 in adjDic:
		for i in range(size.x):
			propagateCoords.append(Vector2(i, newSize.x - 1))
			
	if 2 in adjDic:
		for i in range(size.x):
			propagateCoords.append(Vector2(0, i))
			
	if 3 in adjDic:
		for i in range(size.x):
			propagateCoords.append(Vector2(i, 0))
			
			
	propagateCoords = removeDuplicates(propagateCoords)
	#printAdjTest()#HERE SUS 536
	#wfc.printDebugLite()
	
	var illigals = load_data("illigals").duplicate()
	if autoBuild:
		yield()
	var illigalFlag = false
	
	for y in range(size.y):
		for x in range(size.x):
			if wfc.waveFunction[y][x].keys()[0] in illigals:
				illigalFlag = true
				if autoBuild:
					yield()
				
	if illigalFlag:
		var loadLongIlligal = load_data("longIllegal").duplicate()
		
		for y in range(size.y):
			for x in range(size.x):
				for tile in wfc.waveFunction[y][x]:
					if tile != "11,7":
						wfc.waveFunction[y][x][tile] = loadLongIlligal[tile]
						if autoBuild:
							yield()
	
	return propagateCoords






func getTop(padding):
	var list = []
	list.append(padding.duplicate())
	for y in range(size.y-2):
			list.append(waveFunction[y+1][size.x - 1-1].duplicate())
			
	list.append(padding.duplicate())
	return make_deep_copy(list)
	
func getBottom(padding):
	var list = []
	list.append(padding.duplicate())
	for y in range(size.y-2):
			list.append(waveFunction[y+1][0+1].duplicate())
			
	list.append(padding.duplicate())
	return make_deep_copy(list)
	
func getRight(padding):
	var list = []
	list.append(padding.duplicate())
	for x in range(size.x-2):
			list.append(waveFunction[size.y-1-1][x+1].duplicate())
	
	list.append(padding.duplicate())
	return make_deep_copy(list)
	
func getLeft(padding):
	var list = []
	list.append(padding.duplicate())
	for x in range(size.x-2):
			list.append(waveFunction[0+1][x+1].duplicate())
	
	list.append(padding.duplicate())
	return make_deep_copy(list)
	
func getTopRight():
	return make_deep_copy(waveFunction[size.y - 1-1][size.x - 1-1].duplicate())
	
func getTopLeft():
	return make_deep_copy(waveFunction[0+1][size.x - 1-1].duplicate())
	
func getBotRight():
	return make_deep_copy(waveFunction[size.y - 1-1][0+1].duplicate())
	
func getBotLeft():
	return make_deep_copy(waveFunction[0+1][0+1].duplicate())
	
	
func redo(tryIlligal):
	waveFunction = []
	wfc = waveFunctionObject.new()
	adjDic = make_deep_copy(adjDicCopy)
	corners = make_deep_copy(cornerCopy)
	#is actually making a deep copy, so somethign else
	
	if firstChunk:
		initialize(load_prototype_data())
	else:
		initializeYield = initialize2(load_prototype_data(), tryIlligal)
		
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

func getActualSize():
	return (size-Vector2(2,2))*unitSize*28
	
func getDebugSize():
	return (size)*unitSize*28
	
func printAdjTest():
	for num in adjDic:
		for i in range(adjDic[num].size()):
			print(num, " ", i, ": ", adjDic[num][i].keys().size())
	print("__adjDic_")
	
func printCornerTest():
	for i in range(4):
		if corners[i] == null:
			print(null)
		else:
			print(corners[i].keys())
	print("__corners__")


func removeDuplicates(arr: Array) -> Array:
	var unique = []
	for i in arr:
		if not i in unique:
			unique.append(i)
	return unique

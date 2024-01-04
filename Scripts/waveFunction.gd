extends Node

var waveFunction
var size
var initialEntropy = -1
var currentEntropy = -1
var previousEntropy = -1

var progressBar
var forground

var printMe

var isCollapsed = false

var activelyPropagating = false
var propagatingCoords
var propagate

var gameScript

var previous = []

var try = false
var illigals


#debug kinda
var autoBuild
var yieldTrue = true
var previousYeildTime = 0
const FRAMERATE = 65
const requestedYeildTime = 1000/FRAMERATE

func _ready():
	pass
	
	
	
	
	
func redo(tryIlligal):
	activelyPropagating = false
	gameScript.redo(tryIlligal)
	print("before queue: ")
	#printDebugLite()
	queue_free()
	#print(self)
	
	
func tryIlligal():
	try = true
	print("new: ")
	#printDebugLite()
	var blankDic = load_data("longIllegal").duplicate()
	illigals = load_data("longIllegal").duplicate()
	for key in blankDic.keys():
		waveFunction[1][1][key] = blankDic[key]
	
	
	
	
#itterates through entire waveFunction, and if everything is entropy 1, it is collpased
func isCollapsed():
	if isCollapsed:
		return true
	for y in range(len(waveFunction)):
		for x in range(len(waveFunction[y])):
			if getEntropy(Vector2(x,y)) > 1:
				return false
			if getEntropy(Vector2(x,y)) < 1:
				#print("0 entropy in isCollapsed: ", Vector2(x,y))
				#printDebugLite()
				redo(false)
				return false
			
	isCollapsed = true
	
	if gameScript.firstChunk:
		waveFunction[1][1] = {"12,8": {
		"socketTypes": [
			"b",
			"bbb",
			"b",
			"bbb"
		],
		"validSocketCombo": [
			[
				"b"
			],
			[
				"bbb"
			],
			[
				"b"
			],
			[
				"bbb"
			]
		],
		"validNeighbours": [
			[
				"0,0",
				"0,4",
				"1,4",
				"f1,4",
				"2,4",
				"2,8",
				"3,0",
				"f3,0",
				"4,0",
				"f4,0",
				"4,17",
				"4,18",
				"f4,18",
				"4,19",
				"6,0",
				"7,0",
				"f7,0",
				"8,0",
				"9,3",
				"9,4",
				"f9,4",
				"9,5",
				"9,6",
				"f9,6",
				"9,7",
				"f9,7",
				"9,8",
				"f9,8",
				"9,9",
				"f9,9",
				"9,10",
				"10,7",
				"f10,7",
				"10,8",
				"10,17",
				"f10,17",
				"10,18",
				"10,19",
				"11,16",
				"f11,16",
				"11,17",
				"f11,17",
				"11,18",
				"f11,18",
				"11,19",
				"f11,19",
				"12,8",
				"13,14",
				"f13,14",
				"13,15",
				"f13,15",
				"14,11",
				"f14,11",
				"16,0",
				"f16,0",
				"16,2",
				"f16,2",
				"16,4",
				"f16,4",
				"16,5",
				"f16,5",
				"16,6",
				"f16,6",
				"16,7",
				"f16,7",
				"16,8",
				"16,9",
				"f16,9",
				"16,10",
				"f16,10",
				"16,11",
				"17,14",
				"f17,14",
				"17,17",
				"f17,17",
				"18,17",
				"f18,17",
				"19,14",
				"19,19",
				"20,12",
				"f20,12",
				"20,13",
				"f20,13",
				"20,14",
				"f20,14",
				"20,15",
				"20,16",
				"f20,16",
				"20,17",
				"11,7"
			],
			[
				"11,12",
				"11,13",
				"12,8",
				"f13,8",
				"f13,9",
				"f13,14",
				"f13,15",
				"19,14",
				"f20,12",
				"f20,14",
				"11,7"
			],
			[
				"0,4",
				"0,5",
				"f0,5",
				"0,6",
				"0,7",
				"f0,7",
				"0,9",
				"0,10",
				"f0,10",
				"0,11",
				"0,12",
				"f0,12",
				"0,13",
				"f0,13",
				"0,14",
				"f0,14",
				"0,15",
				"f0,15",
				"0,17",
				"f0,17",
				"0,18",
				"f0,18",
				"1,4",
				"f1,4",
				"1,5",
				"f1,5",
				"1,6",
				"f1,6",
				"1,7",
				"1,8",
				"1,9",
				"f1,9",
				"1,11",
				"2,4",
				"2,5",
				"f2,5",
				"2,6",
				"2,7",
				"f2,7",
				"2,8",
				"2,9",
				"f2,9",
				"2,10",
				"f2,10",
				"3,4",
				"f3,4",
				"3,5",
				"f3,5",
				"3,6",
				"f3,6",
				"3,7",
				"3,8",
				"f3,8",
				"6,4",
				"f6,4",
				"9,3",
				"9,4",
				"f9,4",
				"9,5",
				"9,13",
				"9,16",
				"f9,16",
				"9,17",
				"9,18",
				"f9,18",
				"9,19",
				"10,3",
				"f10,3",
				"10,4",
				"f10,4",
				"10,5",
				"f10,5",
				"10,6",
				"f10,6",
				"10,17",
				"f10,17",
				"10,18",
				"10,19",
				"11,3",
				"11,4",
				"f11,4",
				"11,5",
				"12,8",
				"12,12",
				"f12,12",
				"12,15",
				"f12,15",
				"12,16",
				"f12,16",
				"12,17",
				"f12,17",
				"12,18",
				"f12,18",
				"12,19",
				"f12,19",
				"13,8",
				"f13,8",
				"13,9",
				"f13,9",
				"14,0",
				"f14,0",
				"14,1",
				"f14,1",
				"15,0",
				"f15,0",
				"15,1",
				"f15,1",
				"16,8",
				"16,9",
				"f16,9",
				"16,10",
				"f16,10",
				"16,11",
				"17,8",
				"f17,8",
				"17,9",
				"f17,9",
				"17,10",
				"f17,10",
				"17,11",
				"f17,11",
				"17,13",
				"f17,13",
				"17,16",
				"f17,16",
				"18,8",
				"f18,8",
				"18,9",
				"f18,9",
				"18,10",
				"f18,10",
				"18,11",
				"f18,11",
				"18,16",
				"f18,16",
				"18,18",
				"f18,18",
				"19,0",
				"f19,0",
				"19,1",
				"f19,1",
				"19,10",
				"f19,10",
				"19,11",
				"f19,11",
				"19,12",
				"f19,12",
				"19,13",
				"f19,13",
				"19,14",
				"19,15",
				"f19,15",
				"19,16",
				"f19,16",
				"19,17",
				"f19,17",
				"19,18",
				"f19,18",
				"19,19",
				"20,0",
				"f20,0",
				"20,1",
				"f20,1",
				"20,10",
				"f20,10",
				"20,11",
				"f20,11",
				"20,12",
				"f20,12",
				"20,13",
				"f20,13",
				"20,14",
				"f20,14",
				"20,15",
				"20,16",
				"f20,16",
				"20,17",
				"20,18",
				"f20,18",
				"20,19",
				"f20,19",
				"11,7"
			],
			[
				"f11,12",
				"f11,13",
				"12,8",
				"13,8",
				"13,9",
				"13,14",
				"13,15",
				"19,14",
				"20,12",
				"20,14",
				"11,7"
			]
		]
	}}
	
	gameScript.update()
	progressBar.queue_free()
	gameScript.updateBut()
	
	
	if autoBuild:
		gameScript.gameScript.createRandomChunk()
		
	
	
	#printDebugLite()
	return true
	
	
	
	
	
	
#give a list of all possible tiles this could be (return list of keys)
func getPossibilities(coords):
	if coords.y >= waveFunction.size() or coords.x >= waveFunction[coords.y].size():
		pass#printDebugLite()
	else:
		# Coordinates are within bounds, return the possibilities
		return waveFunction[coords.y][coords.x].keys()


	
	
	
	
	
	
#go through all tiles and make a list of all their possible neighbours
func getPossibleNeighbours(coords, index):
	var i = dirToIndex(index)
	var possibleNeighbours = []
	
	if "11,7" in waveFunction[coords.y][coords.x]:
		print("11_7, loading all neighbours")
		return load_data("11_7")["11,7"]["validNeighbours"][i]
	
	if not try:
		for tile in waveFunction[coords.y][coords.x]:
			for j in range(waveFunction[coords.y][coords.x][tile][
				"validNeighbours"][i].size()):	
				if (not (waveFunction[coords.y][coords.x][tile][
					"validNeighbours"][i][j] in possibleNeighbours)):
					possibleNeighbours.append(
						waveFunction[coords.y][coords.x][tile]["validNeighbours"][i][j])
						
	else:
		for tile in waveFunction[coords.y][coords.x]:
				for j in range(illigals[tile]["validNeighbours"][i].size()):
					if (not (illigals[tile]["validNeighbours"][i][j] in possibleNeighbours)):
						possibleNeighbours.append(illigals[tile]["validNeighbours"][i][j])
	#print("11,7" in possibleNeighbours)
	return possibleNeighbours
	
	
	
	
	
	
func dirToIndex(dir):
	if dir == Vector2(1, 0):
		return 0
	elif dir == Vector2(0, 1):
		 return 1
	elif dir == Vector2(-1, 0):
		return 2
	elif dir == Vector2(0, -1):
		return 3
	
	
	
	
	
	
func collapseCoordsTo():
	pass
	
	
	
	
	
	
#removes all but randomly chosen tile (can add weights here)
func collapseAt(coords:Vector2):
	if waveFunction[coords.y][coords.x].size() == 0:
		print("0 entropy in collapseAt")
		redo(false)
		return
	#if coords == Vector2(1,1):
		#print(waveFunction[coords.y][coords.x].keys())
	var chosenTile = waveFunction[coords.y][coords.x].keys()[
		randi() % waveFunction[coords.y][coords.x].size()]
	waveFunction[coords.y][coords.x] = {
		chosenTile: waveFunction[coords.y][coords.x][chosenTile]}
		
	
	
	
	
	
	
#later give wieghts to certian things, so when making random choice with same entropy, 
#more likely to pick this or something
func weightedChoice():
	pass
	
	
	
	
	
	
func collapse():
	var success = false
	
	var data = make_deep_copy(gameScript.load_data("longIllegal"))
	
	var adj = [Vector2(0,1), Vector2(1,2), Vector2(1,0), Vector2(2,1)]
	var direction = [0, 3, 1, 2]
	
	var neighbours = [make_deep_copy(data), make_deep_copy(data), make_deep_copy(data), make_deep_copy(data)]
	
	for i in range(4):
		if getEntropy(adj[i]) == 1:
			var tile = waveFunction[adj[i].y][adj[i].x].keys()[0]
			neighbours[i] = (waveFunction[adj[i].y][adj[i].x][tile][
				"validNeighbours"][direction[i]])
			
	var intersection = {}
	
	for thing in neighbours[0]:
		if thing in neighbours[1] and thing in neighbours[2] and thing in neighbours[3]:
			if thing in data:
				intersection[thing] = data[thing]
			
	if intersection.size() > 0:
		success = true
		waveFunction[1][1] = intersection
		collapseAt(Vector2(1,1))
	
	return success
	
	
	
	
	
	
#removes tile from coords
func constrain(coords, tile):
	if waveFunction[coords.y][coords.x].size() > 1:
		waveFunction[coords.y][coords.x].erase(tile)
		return false
	else:
		print("potential error")
		if coords in previous:
			print("attempting resolve")
			return true
		else:
			print("but its okay, we will deal with it later")
			waveFunction[coords.y][coords.x].erase(tile)
			return false
	
	
	
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
	
	
func getEntropy(coords):
	return waveFunction[coords.y][coords.x].size()
	
	
	
func updateBar():
	var totalEntropy = 0
	for y in range(len(waveFunction)):
		for x in range(len(waveFunction[y])):
			#calc entropy for every coord
			var entropy = getEntropy(Vector2(x,y))
			totalEntropy += entropy
			
	currentEntropy = totalEntropy/(size.x*size.y)
	if initialEntropy == -1:
		initialEntropy = currentEntropy
	
	#if (int(currentEntropy) % 10 == 0):
	forground.rect_size = Vector2(50*(1-currentEntropy/initialEntropy), 10)
	
	
func getMinEntropyCoords():
	var minEntropies = []
	var minEntropy = 10000
	
	#var totalEntropy = 0#
	
	#goes through all wave function
	for y in range(len(waveFunction)):
		for x in range(len(waveFunction[y])):
			#calc entropy for every coord
			var entropy = getEntropy(Vector2(x,y))
			#totalEntropy += entropy#
			if (entropy != 1):
			
				#if list is empty (first entry) or its entry is current entropy, 
				#add to min entropys
				if (entropy == minEntropy):
					minEntropies.append(Vector2(x, y))
					
				#otherwise if its the new smallest entropy, create a new list 
				#with just it as an entry,
				# and update lowest entropy
				elif (entropy < minEntropy):
					minEntropies = [Vector2(x,y)]
					minEntropy = entropy
				
	#currentEntropy = totalEntropy/(size.x*size.y)
	#if initialEntropy == -1:
		#initialEntropy = currentEntropy
	
	#if (int(currentEntropy) % 10 == 0):
	#forground.rect_size = Vector2(50*(1-currentEntropy/initialEntropy), 10)

		
	#previousEntropy = printedEnt
	
	#reimpliment this in a weighted way if you want, but this returns random 
	#from lowest entropy
	return minEntropies[randi() % minEntropies.size()]
	
	
	
	
	
#Coroutines and Yield multithreading
func itterate():
	if activelyPropagating:
		#resumes while also grabing new yeaild info to set function pause state to
		propagate = propagate.resume()
		
	else:
		#loop over cells to find one with lowest "prototype" (assuming he means neighbours)
		#randomize for tie
		propagatingCoords = getMinEntropyCoords()
		
		#we now collapse this cell down to one by picking a tile at random from 
		#ones left over. REMOVE REST
		collapseAt(propagatingCoords)
		#print("new collapse through itterate")
		#newCollapse = true
		
		#propogate chenges to rest of wave function
		activelyPropagating = true
		#grabs function pause state
		propagate = propagate([propagatingCoords])
	
	
func firstItterate(propagatingCoords):
	activelyPropagating = true
	previous = propagatingCoords
	propagate = propagate(propagatingCoords)
	
	
	
	
func propagate(coords):
	var stack = coords.duplicate()
	
	while stack.size() > 0:
		#removes and returns the last element of the array
		var currentCoords = stack.pop_back()
		
		#itterates over each adjacent cell to this one
		#for each of the four directions, get the coord of that cell in that direction
		for i in validDirs(currentCoords):
			var otherCoords = currentCoords + i
			#gets list of tiles said cell in said direction could be
			var otherPossiblePrototypes = getPossibilities(otherCoords).duplicate()
			#gets list of neighbours of current cell could be in said direction
			#(pointing at cell with other coords)
			var possibleNeighbours = getPossibleNeighbours(currentCoords, i)
			
			if waveFunction[currentCoords.y][currentCoords.x].keys() == ["11,7"]:
				print(possibleNeighbours.size())
			
			if len(otherPossiblePrototypes) == 0:
				continue
				
			#if otherCoords in previous:
				#print("ignoring preset")
				#continue
				
			#compare two lists
			for otherPrototype in otherPossiblePrototypes:
				#any prototype in the neighbouring cell is not valid gets removed 
				#from that cell's 
				#"supper position" (from its dict)
				if not otherPrototype in possibleNeighbours:
					if constrain(otherCoords, otherPrototype):
						print("constraing ", otherPrototype, ". its not in", waveFunction[currentCoords.y][currentCoords.x].keys(), "'s possibleNeighbours")
						if waveFunction[currentCoords.y][currentCoords.x].keys() == ["11,7"]:
							print(possibleNeighbours)
						
						failSafe()
					
					
					#if one of these cells super positions were modified, we add 
					#it to the stack, 
					#making a rippling effect of edited cells
					if not otherCoords in stack:
						stack.append(otherCoords)
						
						
				if autoBuild and yieldTrue and OS.get_ticks_msec() - previousYeildTime > requestedYeildTime:
					previousYeildTime = OS.get_ticks_msec()
					yield()
					
		#pauses function so game can update visuals
		updateBar()
		if autoBuild:
			previousYeildTime = OS.get_ticks_msec()
		yield()
		
		#print("resume")
		
	activelyPropagating = false
	
	
#"11_7" or "longIllegal"
func load_data(name):
	var file = File.new()
	file.open("res://Scripts/" + name + ".json", file.READ)
	#passes text from json and converts to dict
	var text = file.get_as_text()
	var data = JSON.parse(text).result
	return data
	
	
#returns an array of vector 2's [(1,0), (-1,0), (0,1), (0,-1)], 
#but removes any direction that would take it out of the chuck (or to a chunk that
# doesnt exist)
func validDirs(coords):
	var dirs = [Vector2(1,0), Vector2(-1,0), Vector2(0,1), Vector2(0,-1)]
	var valid_dirs = []
	
	for dir in dirs:
		var next_coords = coords + dir
		if next_coords.x < 0 or next_coords.x >= size.x or (
		next_coords.y < 0) or next_coords.y >= size.y:
			continue
		valid_dirs.append(dir)
	
	return valid_dirs

	
	
	
	

func printMap():
	for y in range(size.y):
		for x in range(size.x):
			var prototypes = waveFunction[y][x]
			print(String(prototypes.keys()[0]) + " " + String(Vector2(x,y)))
		print()
	print("___")

func printDebug():
	for y in range(size.y):
		for x in range(size.x):
			var prototypes = waveFunction[y][x]
			print(String(prototypes.keys()) + " " + String(Vector2(x,y)))
		print()
	print("___")
	
func printDebugLite():
	for y in range(waveFunction.size()):
		for x in range(waveFunction[y].size()):
			var prototypes = waveFunction[y][x]
			if prototypes.keys().size() <= 1:
				print(String(prototypes.keys()) + " " + String(Vector2(x,y)))
			else:
				print("[many] " + String(Vector2(x,y)))
		print()
	print("___")
		
	
func createCorruption():
	waveFunction[1][1] = load_data("11_7")
	
func failSafe():
	if not try:
		if not collapse():
			print("FAILED: attempting illigal solution")
			redo(true)
		else:
			print("neighbours DONT contradict, short term success")
			activelyPropagating = false
			isCollapsed = true
			print("new collapse through failsafe (impropper collapse)")
			gameScript.update()
			progressBar.queue_free()
			gameScript.updateBut()
	else: 
		print("FAILED: returning with corrupt solution")
		createCorruption()
		activelyPropagating = false
		isCollapsed = true
		print("new collapse through failsafe (corrupt)")
		gameScript.update()
		progressBar.queue_free()
		gameScript.updateBut()
	
	
	
	
"""
(4, 0) (4, 1) (4, 2) (4, 3) (4, 4)
(3, 0) (3, 1) (3, 2) (3, 3) (3, 4)
(2, 0) (2, 1) (2, 2) (2, 3) (2, 4)
(1, 0) (1, 1) (1, 2) (1, 3) (1, 4)
(0, 0) (0, 1) (0, 2) (0, 3) (0, 4)
"""

			



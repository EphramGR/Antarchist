extends Node2D

var numClicks = 0
var quadrants = Vector2(4,4)

var game

var lineDirection

var minGap = 48
var minGapSqr = minGap*minGap

onready var line = get_node("Line2D")
var barbPrefab = preload("res://Scenes/Barb.tscn")

enum lines {M, X, Y, B}

const costPerPixel = 70

#Debug
var printer = false


func _ready():
	position = Vector2.ZERO


func _process(delta):
	if Input.is_action_just_pressed("left_click"):
		if numClicks == 0:
			line.set_point_position(0, roundedPosition(get_global_mouse_position()))
			numClicks = 1
			
		elif numClicks == 1:
			#try
			line.set_point_position(1, closestToFirst(get_global_mouse_position()))
			numClicks = 2
			
	elif Input.is_action_just_pressed("right_click"):
		if numClicks == 1:
			line.set_point_position(0, Vector2.ZERO)
			line.set_point_position(1, Vector2.ZERO)
			
		numClicks -= 1
	
	
	if numClicks == -1:
		queue_free()
		game.disableWallCost()
		game.changeButtonTexture()
	elif numClicks == 1:
		line.set_point_position(1, closestToFirst(get_global_mouse_position()))
		updateWall()
		updateVisualCost()
	elif numClicks == 2:
		if tryAndPlace():
			if charge():
				game.createWall()
				set_process(false) #might need to change later
				
				cleanUp()
				numClicks = -1
		else:
			numClicks = 1
			updateVisualCost()
	
func roundedPosition(pos:Vector2, bindVector = quadrants):
	var roundedPosition = Vector2(
		round(pos.x / bindVector.x) * bindVector.x,
		round(pos.y / bindVector.y) * bindVector.y
	)
	
	return roundedPosition
	
func getLength()->float:
	var dist = abs(((line.get_point_position(0)-line.get_point_position(1))/4/lineDirection).y)
	return dist
	
func updateVisualCost():
	game.updateWallCost(getCost())

func charge():
	var c = getCost()
	if game.money >= c:
		game._addMoney(-1*c)
		game.disableWallCost()
		return true
	numClicks = 1
	return false
	
func getCost()->float:
	return getLength() * costPerPixel
	
func closestToFirst(pos:Vector2, bindVector = quadrants):
	var imaginaryLines = [Vector2(2,1), Vector2(-2, 1)]
	
	var initialPos = line.get_point_position(0)
	
	var distanceToVec = []
	var intersepts = []
	
	for i in range(len(imaginaryLines)):
		var perp = Vector2(imaginaryLines[i].y, imaginaryLines[i].x)
		
		var line1 = {lines.Y: initialPos.y, lines.X: initialPos.x, lines.M: imaginaryLines[i].y/imaginaryLines[i].x}
		line1[lines.B] = line1[lines.Y] - line1[lines.M]*line1[lines.X]
		
		var line2 = {lines.Y: pos.y, lines.X: pos.x, lines.M: perp.y/perp.x}
		line2[lines.B] = line2[lines.Y] - line2[lines.M]*line2[lines.X]
		
		var intersept = Vector2(-1, -1)
		
		intersept.x = (line1[lines.B] - line2[lines.B])/(line2[lines.M]-line1[lines.M])
		
		intersept.y = line1[lines.M] * intersept.x + line1[lines.B]
		
		intersepts.append(intersept)
		
		distanceToVec.append(intersept.distance_squared_to(pos))
		
	imaginaryLines.append(Vector2(0,1))
	
	distanceToVec.append(abs(pos.x - initialPos.x)*abs(pos.x - initialPos.x))
	intersepts.append(Vector2(initialPos.x, pos.y))
		
	var Min = INF
	var smallest = null
	var I
	for i in range(len(distanceToVec)):
		#print(distanceToVec[i], intersepts[i])
		if distanceToVec[i] < Min:
			Min = distanceToVec[i]
			smallest = intersepts[i]
			I = i
	
	lineDirection = imaginaryLines[I]
		
	if I == 2:
		return roundedPosition(smallest)
	return roundedPosition2(smallest, imaginaryLines[I], pos)
	
	
func roundedPosition2(pos: Vector2, line1: Vector2, mousePress:Vector2, bindVector = quadrants):
	var roundedPosition = Vector2(
		round(pos.x / bindVector.x) * bindVector.x,
		round(pos.y / bindVector.y) * bindVector.y
	)
	
	if not isOnLine(roundedPosition, line1):		
		var pos1
		var pos2
		
		if isOnLine(roundedPosition + Vector2(4, 4), line1):
			pos1 = Vector2(-4, 0)
			pos2 = Vector2(4, 4)
		elif isOnLine(roundedPosition + Vector2(4, -4), line1):
			pos1 = Vector2(-4, 0)
			pos2 = Vector2(4, -4)
		elif isOnLine(roundedPosition + Vector2(-4, 4), line1):
			pos1 = Vector2(4, 0)
			pos2 = Vector2(-4, 4)
		elif isOnLine(roundedPosition + Vector2(-4, -4), line1):
			pos1 = Vector2(4, 0)
			pos2 = Vector2(-4, -4)
		else:
			print("none on line, oops")
		
		var dist1 = (roundedPosition + pos1).distance_squared_to(mousePress)
		var dist2 = (roundedPosition + pos2).distance_squared_to(mousePress)
		
		if dist1 > dist2:
			return roundedPosition + pos2
		return roundedPosition + pos1
		
	return roundedPosition


func isOnLine(pos, slope):
	return pos.y == slope.y/slope.x*pos.x + (line.get_point_position(0).y - (slope.y/slope.x*line.get_point_position(0).x))



func tryAndPlace():
	printer = true
	var t = updateWall()
	printer = false
	#print("___")
	return t
	
func getColorAt(coords: Vector2):
	var chunkIndex = game.getTouchingChunk(coords)
	#print(chunkIndex)
	
	if not chunkIndex in game.chunks:
		#print("doesnt exist")
		return Color.white
		
	var chunk = game.chunks[chunkIndex]
	
	var tileMap = chunk.tileMap
	var tileMapFlipped = chunk.tileMapF
	var coordsInSprite = (coords - chunk.global_position + Vector2(56, 56)) / 4
	
	if int(coordsInSprite.x) > 27:
		return Color.white
	#print(coordsInSprite)
	
	var tile = chunk.wfc.waveFunction[1][1].keys()[0]
	
	var colour = getPixelColor(tile, int(coordsInSprite.x), int(coordsInSprite.y))
	
	if printer and colour == Color.black:
		pass#print(Vector2(int(coordsInSprite.x), int(coordsInSprite.y)))
	
	return colour


func getPixelColor(tile:String, x: int, y: int) -> Color:
	var flip = false
	
	if tile[0] == "f":
		flip = true
		tile = tile.replace("f", "")
		x = abs(x - 27)

	var tile_index = Vector2(int(tile.split(",")[1]), int(tile.split(",")[0]))
	
	var tile_size = Vector2(28, 28)
				
	var crop_region = Rect2(tile_index * tile_size, tile_size)
	
	var tileMap: StreamTexture
	if not flip:
		tileMap = game.chunks[Vector2(0,0)].tileMap
	else:
		tileMap = game.chunks[Vector2(0,0)].tileMapF

	var image = tileMap.get_data()
	if image:
		image.lock()
		var pixelColor = image.get_pixel(x + crop_region.position.x, y + crop_region.position.y)
		image.unlock()
		return pixelColor
	
	return Color.white
				
				
func updateWall():
	var currentPoint = line.get_point_position(0)
	var endPoint = line.get_point_position(1)
	
	var increament = lineDirection*4
	
	var testValue = endPoint - currentPoint
	
	if testValue == Vector2.ZERO:
		line.default_color = Color.red
		return false
		
	if testValue.y < 0:
		increament = increament * -1
		
	endPoint += increament
	while currentPoint != endPoint:

		# Check if at least 1 pixel is black around it
		if checkAllSurroundingPixelsButDownRight(currentPoint):
			line.default_color = Color.red
			return false

		# Move to the next pixel based on lineDirection
		currentPoint += increament

	line.default_color = Color.green
	return true
	
func checkAllSurroundingPixels(point):
	return (getColorAt(point) != Color(0, 0, 0) and getColorAt(point + Vector2.UP*4) != Color(0, 0, 0) and getColorAt(point + Vector2.DOWN*4) != Color(0, 0, 0) and getColorAt(point + Vector2.LEFT*4) != Color(0, 0, 0) and getColorAt(point + Vector2.RIGHT*4) != Color(0, 0, 0))

func checkAllSurroundingPixelsButDownRight(point):
	return (getColorAt(point) != Color(0, 0, 0) and getColorAt(point + Vector2.UP*4) != Color(0, 0, 0) and getColorAt(point + Vector2.LEFT*4) != Color(0, 0, 0))

func getAllBlacks(point, allBlacks):
	
	if not point in allBlacks and getColorAt(point) == Color(0, 0, 0):
		allBlacks.append(point)
		
	if not point + Vector2.UP*4 in allBlacks and getColorAt(point + Vector2.UP*4) == Color(0, 0, 0):
		allBlacks.append(point + Vector2.UP*4)
		
	if not point + Vector2.DOWN*4 in allBlacks and getColorAt(point + Vector2.DOWN*4) == Color(0, 0, 0):
		allBlacks.append(point + Vector2.DOWN*4)
		
	if not point + Vector2.LEFT*4 in allBlacks and getColorAt(point + Vector2.LEFT*4) == Color(0, 0, 0):
		allBlacks.append(point + Vector2.LEFT*4)
		
	if not point + Vector2.RIGHT*4 in allBlacks and getColorAt(point + Vector2.RIGHT*4) == Color(0, 0, 0):
		allBlacks.append(point + Vector2.RIGHT*4)
		
	if not point + Vector2.LEFT*8 in allBlacks and getColorAt(point + Vector2.LEFT*8) == Color(0, 0, 0):
		allBlacks.append(point + Vector2.LEFT*8)
		
	if not point + Vector2.RIGHT*8 in allBlacks and getColorAt(point + Vector2.RIGHT*8) == Color(0, 0, 0):
		allBlacks.append(point + Vector2.RIGHT*8)
		
	if not point + Vector2.UP*4 + Vector2.RIGHT*4 in allBlacks and getColorAt(point + Vector2.UP*4 + Vector2.RIGHT*4) == Color(0, 0, 0):
		allBlacks.append(point + Vector2.UP*4 + Vector2.RIGHT*4)
		
	if not point + Vector2.UP*4 + Vector2.LEFT*4 in allBlacks and getColorAt(point + Vector2.UP*4 + Vector2.LEFT*4) == Color(0, 0, 0):
		allBlacks.append(point + Vector2.UP*4 + Vector2.LEFT*4)
	

func wrapNumber(value: int, maximum: int) -> int:
	return value % maximum

func cleanUp():
	var currentPoint = line.get_point_position(0)
	var endPoint = line.get_point_position(1)
	
	var increament = lineDirection*4
	
	var testValue = endPoint - currentPoint
		
	if testValue.y < 0:
		increament = increament * -1
		
	var allBlacks = []
		
	endPoint += increament
	while currentPoint != endPoint:

		getAllBlacks(currentPoint, allBlacks)
		# Move to the next pixel based on lineDirection
		currentPoint += increament
		
	var flagToRemove = []
	for i in range(allBlacks.size()):
		for barb in game.activeBarbs:
			if (allBlacks[i] + Vector2(2,2)).distance_squared_to(barb) < minGapSqr:
				flagToRemove.append(i)
				break
				
	for i in range(allBlacks.size()):
		if not i in flagToRemove:
			createBarbAt(allBlacks[i])
			
	
	var c:float = round((float(flagToRemove.size())/allBlacks.size())*100)/100
	
	game._addMoney(getCost()*c)
	
	if flagToRemove.size() > 0:
		game.createPopupText("Some barbed wire was too close to others.\nYou have been refunded " + String(c*100) + "%.")
		
	queue_free()
		
func createBarbAt(point:Vector2):
	var tile_index = getTileIndex(point)
	
	var tile_size = Vector2(8, 8)
				
	var crop_region = Rect2(tile_index * tile_size, tile_size)
	
	var barbInstance = barbPrefab.instance()
	
	barbInstance.lineAngle = lineDirection
	barbInstance.z_index = 3
	
	var sprite = barbInstance.get_node("Sprite")
	sprite.region_rect = crop_region

		
	var pos = point + Vector2(2,2)
	barbInstance.position = pos
	
	#this are unused, adn may be remove later
	game.barbHandle.append(pos)
	
	game.activeBarbs[pos] = barbInstance
	
	game.get_node("BarbContainer").add_child(barbInstance)
	
func getTileIndex(point:Vector2) -> Vector2:
	point = point/4
	
	point.x = wrapNumber(abs(point.x), 4)
	point.y = wrapNumber(abs(point.y), 2)
	
	return point

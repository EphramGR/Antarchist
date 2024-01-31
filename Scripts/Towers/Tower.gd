extends Area2D

class_name Tower

enum TARGET {closest, farthest, strongest, weakest, closestToDestination, farthestFromDestination}
var towerName:String = "null"

#references
var game:Object
onready var collisionRadius:float = pow(get_node("CollisionShape2D").shape.radius,2) #squared
onready var hitbox:CollisionShape2D = get_node("CollisionShape2D")

var attemptingPlaneRide = false
var planeToRide = null

#logic
var isInHand:bool = true
var selected:bool = true
var confirmDelete:bool = false
var collisionNumber:int = 0
var onBlue:bool = false

var boosters:Array = []
var change:bool = false

var maxed = false
var mint = false

var sellValue = 0

#boosters
enum BUFFS {RANGE, FIRERATE, BULLETSPEED, EXPLOSIONRADIUS, EFFECTDURATION, DAMAGE, COSTREDUCTION, SEECAMO, HITSFLYING}
var buffs:Dictionary = {BUFFS.DAMAGE:1, BUFFS.RANGE:1, BUFFS.FIRERATE:1, BUFFS.BULLETSPEED:1, BUFFS.EXPLOSIONRADIUS:1, BUFFS.EFFECTDURATION:1, BUFFS.COSTREDUCTION:1, BUFFS.SEECAMO:1,BUFFS.HITSFLYING:1}

#settings
var actualRange:float = 50
var RANGE:float = actualRange * actualRange
var targetType:int = TARGET.closest
var seesCamo = false
var unboostedSeesCamo = false
var hitsFlying = false

var stats:Dictionary = {}

#upgrade stuff
var upgrades = {
}
var descriptions = {
	
}
var upgradeSprites = {
	
}
var prices = {
	
}
var ownedUpgrades = []
var updatedUpgrades = []



func _ready():
	connect("area_entered", self, "_on_HitboxAreaEntered")
	connect("area_exited", self, "_on_HitboxAreaExited")
	if mint:
		game.updateCharge(towerName)
	
func _physics_process(delta):
	#show upgrades, range, and stuff
	if selected:
		if Input.is_action_just_pressed("right_click"):
			if not confirmDelete:
				game.createPopupText("Right click again to confirm delete, left click to cancel.")
				confirmDelete = true
			else:
				game.buttonsEnabled = true
				game.selected = null
				if planeToRide != null and is_instance_valid(planeToRide):
					planeToRide.unride(self)
				cleanUp()
				queue_free()
				game.money += calcTotalSellValue()
				if maxed and not mint:
					Perks.currentCharges[towerName] -= 1
					game.updateCharge(towerName)
				elif mint:
					Perks.currentCharges[towerName] += Perks.maxCharges[towerName]
					game.updateCharge(towerName)
				
				
		handleDeselect()
				
		update()
			
	if isInHand:
		global_position = get_global_mouse_position()
		onBlue = getCornerColors()
		
		if Input.is_action_just_pressed("left_click"):
			if confirmDelete:
				confirmDelete = false
			elif tryAndPlace():
				if attemptingPlaneRide:
					planeToRide.hitchRide(self)
					#remove collision hitbox
				isInHand = false
				selected = false
				game.buttonsEnabled = true
				disconnect("area_entered", self, "_on_HitboxAreaEntered")
				disconnect("area_exited", self, "_on_HitboxAreaExited")
				placed()
		
	#Main loop
	else:
		if Input.is_action_just_pressed("left_click") and game.buttonsEnabled and not game.extended and game.previousSelected == null:
			if not selected and get_global_mouse_position().distance_squared_to(global_position) < collisionRadius:
				selected = true
				game.buttonsEnabled = false
				game.selected = self
				toggleSelected()
				
	if change:
		applyBoosters()
		change = false

func calcTotalSellValue()->float:
	var cost = Perks.costs[towerName]
	
	if isInHand:
		return cost
	
	return round((cost+sellValue)*Perks.sellPercent)
	
func handleDeselect():
	if not isInHand and Input.is_action_just_pressed("left_click"):
		if confirmDelete:
			confirmDelete = false
		else:
			selected = false
			game.buttonsEnabled = true
			game.selected = null
			toggleSelected()
	
func getTarget():
	var ants = get_tree().get_nodes_in_group("Ants")
	var comparatorAndTarget = [null, null]
	
	for ant in ants:
		if not ant.dead and ((ant.isCamo and seesCamo) or not ant.isCamo) and ((ant.isFlying and hitsFlying) or not ant.isFlying):
			var distance = global_position.distance_squared_to(ant.global_position)
			
			if distance <= RANGE:
				compareTarget(comparatorAndTarget, distance, ant)
	
	return comparatorAndTarget[1]

func compareTarget(comparatorAndTarget:Array, distance:float, newAnt:Object):
	if comparatorAndTarget[1] == null:
		comparatorAndTarget[1] = newAnt
		if targetType == TARGET.closest or targetType == TARGET.farthest:
			comparatorAndTarget[0] = distance
			
		elif targetType == TARGET.closestToDestination or targetType == TARGET.farthestFromDestination:
			if newAnt.currentState == newAnt.State.SearchingForFood:
				comparatorAndTarget[0] = newAnt.global_position.distance_squared_to(newAnt.colony.base.global_position)
			else:
				comparatorAndTarget[0] = newAnt.global_position.distance_squared_to(newAnt.colony.global_position)
		#change if you add more targeting options!
		else:
			comparatorAndTarget[0] = newAnt.health
			
	else:
		if targetType == TARGET.closest:
			if distance < comparatorAndTarget[0]:
				comparatorAndTarget[0] = distance
				comparatorAndTarget[1] = newAnt
				
		elif targetType == TARGET.farthest:
			if distance > comparatorAndTarget[0]:
				comparatorAndTarget[0] = distance
				comparatorAndTarget[1] = newAnt
				
		elif targetType == TARGET.strongest:
			if newAnt.health > comparatorAndTarget[0]:
				comparatorAndTarget[0] = newAnt.health
				comparatorAndTarget[1] = newAnt
			
		elif targetType == TARGET.weakest:
			if newAnt.health < comparatorAndTarget[0]:
				comparatorAndTarget[0] = newAnt.health
				comparatorAndTarget[1] = newAnt
			
		#change if you add more targeting options!
		else:
			if newAnt.currentState == newAnt.State.SearchingForFood:
				distance = newAnt.global_position.distance_squared_to(newAnt.colony.base.global_position)
			else:
				distance = newAnt.global_position.distance_squared_to(newAnt.colony.global_position)
				
			if targetType == TARGET.closestToDestination:
				if distance < comparatorAndTarget[0]:
					comparatorAndTarget[0] = distance
					comparatorAndTarget[1] = newAnt
					
			else:
				if distance > comparatorAndTarget[0]:
					comparatorAndTarget[0] = distance
					comparatorAndTarget[1] = newAnt
		
func _on_HitboxAreaEntered(area: Area2D) -> void:
	if area.name != "BoostHitbox":
		if "Plane" in area.name:
			if area.checkForFree():
				attemptingPlaneRide = true
				planeToRide = area
				
		elif area.name != "Base" and area.attemptingPlaneRide and not area.isInHand:
			collisionNumber -= 1
			
		collisionNumber += 1

func _on_HitboxAreaExited(area: Area2D) -> void:
	if area.name != "BoostHitbox":
		if area == planeToRide:
			attemptingPlaneRide = false
			planeToRide = null
			
		elif area.name != "Base" and area.attemptingPlaneRide and not area.isInHand:
			collisionNumber += 1
			
		collisionNumber -= 1
		
func tryAndPlace():		
	return (collisionNumber == 0 and onBlue) or attemptingPlaneRide
	
func cleanUp():
	pass

func placed():
	pass
	
func updateBoosts():
	pass
	
func updateStats():
	pass
	
func toggleSelected():
	pass
	
func updateUpgrade(upgrade:String)->void:
	print("upgrade: ", upgrade)
	
#not used, because all just call above. use iff you wanna spawn towers with many owned
func updateUpgrades()->void:
	for upgrade in upgrades:
		if upgrade in ownedUpgrades and not upgrade in updatedUpgrades:
			updateUpgrade(upgrade)
			updatedUpgrades.append(upgrade)
	

		
func applyBoosters():
	for buff in buffs:
		buffs[buff] = 1
	
	for booster in boosters:
		for buff in buffs:
			buffs[buff] = max(buffs[buff], booster.buffsGiven[buff])
			
	if planeToRide != null and planeToRide.supremeSupport:
		buffs[BUFFS.SEECAMO] = 2
		buffs[BUFFS.HITSFLYING] = 2
	
	updateBoosts()

func updatePosition(newPos:Vector2):
	global_position = newPos
	
func getCornerColors()->bool:
	#var BLUE = Color(0.388235,0.607843,1,1)
	#var RED = Color(0.67451,0.196078,0.196078,1)
	#var YELLOW = Color(0.984314,0.94902,0.211765,1)
	
	if getColorAt(global_position).b != 1:
		return false
	
	var directions = [Vector2(4,4), Vector2(-4,4), Vector2(-4,-4), Vector2(4,-4)]
	
	for i in range(directions.size()):
		#15.13 is collisionshape radius, 
		#but 4 is tile size, so should be 1 in each corner
		if getColorAt(global_position+(directions[i])).b != 1:
			return false
			
	return true
	
	
func getColorAt(coords: Vector2)->Color:
	var chunkIndex = game.getTouchingChunk(coords)
	#print(chunkIndex)
	
	if not chunkIndex in game.chunks:
		#print("doesnt exist")
		return Color.black
		
	var chunk = game.chunks[chunkIndex]
	
	var tileMap = chunk.tileMap
	var tileMapFlipped = chunk.tileMapF
	var coordsInSprite = (coords - chunk.global_position + Vector2(56, 56)) / 4
	
	if int(coordsInSprite.x) > 27:
		return Color.black
	#print(coordsInSprite)
	
	var tile = chunk.wfc.waveFunction[1][1].keys()[0]
	
	var colour = getPixelColor(tile, int(coordsInSprite.x), int(coordsInSprite.y))
	
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
		#print(pixelColor)
		return pixelColor
	
	return Color.white

func _draw():
	if selected:
		if attemptingPlaneRide:
			draw_circle(Vector2.ZERO, actualRange, Color(0.2, 1, 0.2, 0.5))
		elif collisionNumber == 0 and onBlue:
			draw_circle(Vector2.ZERO, actualRange, Color(0.5, 0.5, 0.5, 0.5))
		else:
			draw_circle(Vector2.ZERO, actualRange, Color(1, 0.2, 0.2, 0.5))

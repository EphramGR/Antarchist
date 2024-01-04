extends Ant

const flyingSprite = preload("res://Assets/Enemy/AntFly.png")
const flyCamo = preload("res://Assets/Enemy/AntFlyCamo.png")

func _ready():
	isFlying = true
	sprite.rotation = currentForwardDir.angle() + PI/2
	if isCamo:
		sprite.texture = flyCamo
	else:
		sprite.texture = flyingSprite
		
	maxSpeed = 50
	
	
#Overrides {
#now does nothing
func HandlePheromonePlacement():
	pass

#now does nothing
func HandleRandomSteering():
	pass
	
#makes move dir directly towards food
func HandleSearchForFood():
	
	if hitFood():
		currentForwardDir *= -1
		sprite.rotation = currentForwardDir.angle() + PI/2
	
#moves directly towards home
func HandleReturnHome():
	hitColony()
	

func hitFood():
	var hitboxPosition = hitbox.global_position

	var closestX = clamp(hitboxPosition.x, rect_min.x, rect_max.x)
	var closestY = clamp(hitboxPosition.y, rect_min.y, rect_max.y)

	var distanceX = hitboxPosition.x - closestX
	var distanceY = hitboxPosition.y - closestY

	var distanceSquared = distanceX * distanceX + distanceY * distanceY
	var hitboxRadiusSquared = hitboxRadius * hitboxRadius

	if distanceSquared <= hitboxRadiusSquared:
		if isConfused:
			isConfused = false
			lastConfuseTime = TimeScaler.time()
			confuseParticles.emitting = false
			flipState()
		else:
			currentState = State.ReturningHome
			seaFood = false
			takeFood()
			leftFoodTime = TimeScaler.time()
			return true
		
	return false
	
func flipState()->void:
	if currentState == State.ReturningHome:
		currentState = State.SearchingForFood
	else:
		currentState = State.ReturningHome
		
	currentForwardDir = -currentForwardDir
	sprite.rotation = currentForwardDir.angle() + PI/2

#moves towards dir
func HandleMovement(delta:float):
	position += currentForwardDir * maxSpeed * delta * baseSpeedFactor
	print(baseSpeedFactor)
	print(maxSpeed*baseSpeedFactor)

#actually kills
func deathByTurret():
	if currentState == State.ReturningHome and spawnNum == null:
		colony.base.foodReturned(amountToSteal)

	if spawnNum != null:
		deathSpawn()
	
	if necroTime > 0:
		necroTower.spawnNecro(global_position)
		
	colony.addMoney(value)
	die()
	
#Overrides over }

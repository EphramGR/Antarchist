extends Sprite

#bugs with plane: flamethrower, iceTower

const missle = preload("res://Scenes/Rocket.tscn")
const bullet = preload("res://Scenes/CannonBall.tscn")

var myTower
var heldTower

#settings
var hasMissles:bool = false
var numBullets:int = 0
var haventUpdated = true

#Bullet:
#logic
var bulletLastShotTime = 0
var supremeSupport = false
#var distanceToTarget

#settings
const bulletSpeed = 5

const fireRate = 50 #ms, /1000 for s *2 cause time scale 0.5
const bulletDamage = 80
const despawnTime = 3

#Missle:
#logic
var lastShotTime = 0
var distanceToTarget
var reloading = false
var firedBullets = 0

#settings
var missleSpeed = 0.25 /Perks.bulletSpeedMultiplier#inverse
var RANGE = 150*150*Perks.rangeMultiplier
var shotDelay = 100/ Perks.firerateMultiplier
var reloadTime = 1000/ Perks.firerateMultiplier
const damage = 150
const explosionRadius = 20

const numMissles = 10

var sounds = [
	preload("res://Assets/Music/soundEffects/shoot/shoot.wav"),
	preload("res://Assets/Music/soundEffects/shoot/shoot1.wav"),
	preload("res://Assets/Music/soundEffects/shoot/shoot2.wav"),
	preload("res://Assets/Music/soundEffects/shoot/shoot3.wav")
]
onready var audioPlayer = get_node("AudioStreamPlayer2D")

func _ready():
	if supremeSupport:
		heldTower.unboostedSeesCamo = true
		heldTower.hitsFlying = true
		
func playSound():
	var randomIndex = randi() % sounds.size()

	audioPlayer.stream = sounds[randomIndex]
	
	audioPlayer.volume_db = linear2db(Perks.shootVolume)

	audioPlayer.play()

func _process(delta):
	if heldTower != null:
		heldTower.updatePosition(global_position)
		if supremeSupport and haventUpdated:
			heldTower.unboostedSeesCamo = true
			heldTower.hitsFlying = true
			haventUpdated = false
			heldTower.updateBoosts()
	
	
	#shooty stuff
	if hasMissles:
		if reloading:
			if TimeScaler.time() - lastShotTime > reloadTime:
				lastShotTime = 0
				reloading = false
				firedBullets = 0
				
		elif TimeScaler.time() - lastShotTime > shotDelay:
			var target = getTarget()
			if target != null:
				var targetPos = target.global_position
				distanceToTarget = global_position.distance_to(targetPos)
				
				var bulletOffset = (targetPos - global_position).normalized()
				bulletOffset = Vector2(-bulletOffset.y, bulletOffset.x) * scale.x * texture.get_height() /2
				
				shootMissle(takeAim(targetPos), targetPos, bulletOffset)
				lastShotTime = TimeScaler.time()
				
				firedBullets += 1
				if firedBullets >= numMissles:
					reloading = true
	if numBullets > 0:
		if TimeScaler.time() - bulletLastShotTime > fireRate:
			var target = getTarget()
			if target != null:
				var targetPos = target.global_position
				
				if numBullets > 1:
					var bulletOffset = (targetPos - global_position).normalized()
					bulletOffset = Vector2(-bulletOffset.y, bulletOffset.x) * scale.x * texture.get_height() /2
					shoot2(bulletOffset, targetPos)
					bulletLastShotTime = TimeScaler.time()
				else:
					shoot((targetPos - global_position).normalized())
					bulletLastShotTime = TimeScaler.time()
	
func takeAim(targetPos):
	var midpoint = Vector2()
	midpoint.x = (global_position.x + targetPos.x) / 2 + (global_position.x - targetPos.x)/2
	midpoint.y = (global_position.y + targetPos.y) / 2 - abs(global_position.x - targetPos.x)/2
	
	#print(global_position, ">", midpoint, ">", targetPos)
	return midpoint
	
func shootMissle(pointC, targetPos, bulletOffset):
	var num = 1
	for i in range(2):
		var bulletInstance = missle.instance()
		bulletInstance.global_position = global_position + bulletOffset*num
		bulletInstance.visible = false 
		bulletInstance.positionA = global_position + bulletOffset*num
		bulletInstance.positionB = targetPos
		bulletInstance.positionC = pointC
		bulletInstance.duration = distanceToTarget / 100 * missleSpeed
		bulletInstance.damage = damage
		bulletInstance.explosionRadius = explosionRadius * explosionRadius
		bulletInstance.realExplosionRadius = explosionRadius
		bulletInstance.z_index = 6
		bulletInstance.hitsFlying = myTower.hitsFlying
		bulletInstance.summonDamage = Perks.summonDamage
		myTower.game.add_child(bulletInstance)
		
		num *= -1
		
	playSound()
		
	

	
func shoot2(bulletOffset, targetPos):
	var num = 1
	for i in range(2):
		var bulletInstance = bullet.instance()
		myTower.game.add_child(bulletInstance)
		bulletInstance.global_position = global_position + bulletOffset*num
		var vector = (targetPos - bulletInstance.global_position).normalized()
		bulletInstance.vector = vector * bulletSpeed
		bulletInstance.damage = bulletDamage
		bulletInstance.duration = despawnTime
		bulletInstance.z_index = 6
		bulletInstance.hitsFlying = myTower.hitsFlying
		bulletInstance.scale *= 0.3
		bulletInstance.summonDamage = Perks.summonDamage
		
		
		num *= -1
		
	playSound()

func shoot(vector:Vector2):
	var bulletInstance = bullet.instance()
	myTower.game.add_child(bulletInstance)
	bulletInstance.vector = vector * bulletSpeed
	bulletInstance.damage = bulletDamage
	bulletInstance.duration = despawnTime
	bulletInstance.global_position = global_position
	bulletInstance.z_index = 6
	bulletInstance.hitsFlying = myTower.hitsFlying
	bulletInstance.scale *= 0.3
	bulletInstance.summonDamage = Perks.summonDamage
	
	playSound()
	
	
func getTarget():
	var ants = get_tree().get_nodes_in_group("Ants")
	var comparatorAndTarget = [null, null]
	
	for ant in ants:
		if not ant.dead and ((ant.isFlying and myTower.hitsFlying) or not ant.isFlying) and ((ant.isCamo and myTower.seesCamo) or not ant.isFlying):
			var distance = global_position.distance_squared_to(ant.global_position)
			
			if distance <= RANGE:
				compareTarget(comparatorAndTarget, distance, ant)
	
	return comparatorAndTarget[1]

func compareTarget(comparatorAndTarget:Array, distance:float, newAnt:Object):
	if comparatorAndTarget[1] == null:
		comparatorAndTarget[1] = newAnt
		if myTower.targetType == myTower.TARGET.closest or myTower.targetType == myTower.TARGET.farthest:
			comparatorAndTarget[0] = distance
			
		elif myTower.targetType == myTower.TARGET.closestToDestination or myTower.targetType == myTower.TARGET.farthestFromDestination:
			if newAnt.currentState == newAnt.State.SearchingForFood:
				comparatorAndTarget[0] = newAnt.global_position.distance_squared_to(newAnt.colony.base.global_position)
			else:
				comparatorAndTarget[0] = newAnt.global_position.distance_squared_to(newAnt.colony.global_position)
		#change if you add more targeting options!
		else:
			comparatorAndTarget[0] = newAnt.health
			
	else:
		if myTower.targetType == myTower.TARGET.closest:
			if distance < comparatorAndTarget[0]:
				comparatorAndTarget[0] = distance
				comparatorAndTarget[1] = newAnt
				
		elif myTower.targetType == myTower.TARGET.farthest:
			if distance > comparatorAndTarget[0]:
				comparatorAndTarget[0] = distance
				comparatorAndTarget[1] = newAnt
				
		elif myTower.targetType == myTower.TARGET.strongest:
			if newAnt.health > comparatorAndTarget[0]:
				comparatorAndTarget[0] = newAnt.health
				comparatorAndTarget[1] = newAnt
			
		elif myTower.targetType == myTower.TARGET.weakest:
			if newAnt.health < comparatorAndTarget[0]:
				comparatorAndTarget[0] = newAnt.health
				comparatorAndTarget[1] = newAnt
			
		#change if you add more targeting options!
		else:
			if newAnt.currentState == newAnt.State.SearchingForFood:
				distance = newAnt.global_position.distance_squared_to(newAnt.colony.base.global_position)
			else:
				distance = newAnt.global_position.distance_squared_to(newAnt.colony.global_position)
				
			if myTower.targetType == myTower.TARGET.closestToDestination:
				if distance < comparatorAndTarget[0]:
					comparatorAndTarget[0] = distance
					comparatorAndTarget[1] = newAnt
					
			else:
				if distance > comparatorAndTarget[0]:
					comparatorAndTarget[0] = distance
					comparatorAndTarget[1] = newAnt

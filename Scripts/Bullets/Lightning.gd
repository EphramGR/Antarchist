extends Sprite


var tower:Object
var game:Object
var target:Object
var parent:Object

var lastParentLoc
var lastTargetLoc

var distanceToTarget

var time:float = 0
const moveSpeed = 10

var chainRange
var damage

var chainIndex
var chainCap
var antInChain

var duration

var farChain:bool

var closeDamage = false
var farDamage = false
var conductive = false

const chainDamageInc = 50
const farDistanceConversion = 1.4
const c = 5000

const bonusFarCarryOver = 0.8
const bonusCloseCarryOver = 0.5

func _ready():
	updateSprite()
		
	var thisDamage = damage
	var bonusDamage = 0
	
	#print("Dist: ", distanceToTarget, ". c: ", max((c/(5*(distanceToTarget))-(3/c)*pow(0.5*distanceToTarget,2)+8),0), " f: ", distanceToTarget/farDistanceConversion)
	print("index: ", chainIndex, ". b: ", (pow(chainIndex,2)*chainIndex + pow(chainIndex,2))/2)
	
	if closeDamage:
		var d
		if distanceToTarget < 12:
			d = 92
		else:
			d = max((c/(5*(distanceToTarget))-(3/c)*pow(0.5*distanceToTarget,2)+8),0) * 10
		
		thisDamage += d
		bonusDamage += d * bonusCloseCarryOver
	if farDamage:
		var d = distanceToTarget/farDistanceConversion
		thisDamage += d
		bonusDamage += d * bonusFarCarryOver
	if conductive:
		var n = pow(chainIndex,2)
		thisDamage += (n*chainIndex + n)/2 * 10
	
	#print(thisDamage)
	target.takeDamage(thisDamage*Perks.elementalDamageMult)
	
	damage += bonusDamage
	
	#print("d,b:",damage, " ", bonusDamage)
	
	if chainIndex < chainCap:
		createLightning()
	
func _process(delta:float) -> void:
	time += delta
	
	if time > duration:
		queue_free()
	
	updateSprite()

func updateSprite():
	var parentPos
	var targetPos
	
	if is_instance_valid(parent):
		parentPos = parent.getParentPos()
		lastParentLoc = parentPos
	else:
		parentPos = lastParentLoc
		
	if is_instance_valid(target):
		targetPos = target.global_position
		lastTargetLoc = targetPos
	else:
		targetPos = lastTargetLoc
	
	distanceToTarget = parentPos.distance_to(targetPos)
	rotation = atan2((targetPos.y - parentPos.y), (targetPos.x -  parentPos.x))
	global_position = parentPos + (Vector2(cos(rotation), sin(rotation)).normalized() * distanceToTarget/2)
	region_rect =  Rect2(time * moveSpeed, 0, distanceToTarget, 15)
	
func getParentPos() -> Vector2:
	if farChain:
		return global_position + (Vector2(cos(rotation), sin(rotation)).normalized() * distanceToTarget/2)
	return global_position

func createLightning():
	var ants = get_tree().get_nodes_in_group("Ants")
	
	var MIN = INF
	var chainTarget = null
	
	for ant in ants:
		if not ant.dead and not ant in antInChain and ((ant.isCamo and tower.seesCamo) or not ant.isCamo) and ((ant.isFlying and tower.hitsFlying) or not ant.isFlying):
			var dist = ant.global_position.distance_squared_to(getParentPos())
			if dist <= chainRange:
				if dist <= MIN:
					MIN = dist
					chainTarget = ant
					
	if chainTarget != null:
		antInChain.append(chainTarget)
		
		var lightningInstance = tower.bullet.instance()
		lightningInstance.damage = damage
		lightningInstance.tower = tower
		lightningInstance.target = chainTarget
		lightningInstance.chainIndex = chainIndex + 1
		lightningInstance.chainCap = chainCap
		lightningInstance.antInChain = antInChain
		lightningInstance.chainRange = chainRange
		lightningInstance.global_position = global_position
		lightningInstance.z_index = 4
		lightningInstance.game = game
		lightningInstance.duration = duration
		lightningInstance.parent = self
		lightningInstance.farChain = farChain

		lightningInstance.closeDamage = closeDamage
		lightningInstance.farDamage = farDamage
		lightningInstance.conductive = conductive

		game.add_child(lightningInstance)
		






extends Sprite


var tower:Object
var target:Object

var pike = true

onready var particle = get_node("Tip/CPUParticles2D")
onready var tip = get_node("Tip")

var distanceToTarget

var pastParentPos
var pastTargetPos

var returning = false
var s

var time:float = 0
const moveSpeed = 10

var index

var damage
var poisionDuration
var duration
var sick
var splash
const splashRadius = 100
const realSplashRadius = 10


var exploding = false
const explodingStop = 0.8

func _ready():
	s = scale.x
	if not pike:
		particle.emitting = false
		tip.texture = load("res://Assets/Buildings/Needle/goldenGlove.png")
		texture = load("res://Assets/Buildings/Needle/glove.png")
	elif not splash:
		particle.emitting = false
	
func _process(delta:float) -> void:
	if returning:
		time -= delta/duration
		
		if time < 0:
			if pike:
				tower.avalibleNeedles.append(index)
				tower.activeTargets[index] = null
			queue_free()
			
		elif exploding and time < explodingStop:
			exploding = false
		
	else:
		time += delta/duration
		
		if time > 1:
			returning = true
			if is_instance_valid(target) and target != null and not target.dead:
				target.takeDamage(damage*Perks.physicalDamageMult)
				tower.playSound()
				if pike:
					target.poision(poisionDuration*Perks.poisonDurationMult)
					
					if sick:
						target.sick(poisionDuration*Perks.sickDurationMult)
						
					if splash:
						poisonRadius()
				else:
					if target.health <= 0:
						tower.game._addMoney(target.value*10)
				
		elif time > 0.9:
			particle.emitting = false
	
	updateSprite()
	
	if exploding:
		update()

func poisonRadius():
	var ants = get_tree().get_nodes_in_group("Ants")
	
	for ant in ants:
		if ant != target and not ant.dead and ((ant.isFlying and tower.hitsFlying) or not ant.isFlying) and ant.global_position.distance_squared_to(target.global_position) <= splashRadius:
			ant.poision(poisionDuration)
			
			if sick:
				ant.sick(poisionDuration)
				
	exploding = true

func updateSprite():
	var parentPos
	var targetPos
	
	if is_instance_valid(target) and target != null:
		targetPos = target.global_position
		pastTargetPos = targetPos
	else:
		targetPos = pastTargetPos
		if targetPos == null:
			if pike:
				tower.avalibleNeedles.append(index)
				tower.lastShotTime[index] = 0
				tower.activeTargets[index] = null
			queue_free()
			return
		
	if is_instance_valid(tower) and tower != null:
		parentPos = tower.global_position
		pastParentPos = parentPos
	else:
		parentPos = pastParentPos
		if parentPos == null:
			parentPos = global_position
			pastParentPos = global_position
		
	distanceToTarget = parentPos.distance_to(targetPos)
	rotation = atan2((targetPos.y - parentPos.y), (targetPos.x - parentPos.x))
	global_position = parentPos + (Vector2(cos(rotation), sin(rotation)).normalized() * (distanceToTarget/2 - 3.5) *time)
	region_rect = Rect2(time * moveSpeed, 0, (distanceToTarget - 7)*time/s, 15)

	tip.position = Vector2(1,0) * (distanceToTarget/2 - 3.5)*time/s


func _draw():
	if exploding:
		draw_circle(tip.position, realSplashRadius*2, Color(0.4, 0,0.7,0.5))


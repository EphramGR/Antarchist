extends Area2D

onready var sprite = get_node("Sprite")


var positionA
var positionB
var positionC


var target:Object = null

var t = 0.0
var duration = 5.0
var despawnTime

var damage
var exploding = false
var explosdingDuration = 0.4 #purley visual * 2 cause 0.5
var homing = false
var DoT = false
var summonDamage = 1

var hitsFlying:bool = false

const tickRate = 200
var lastTick = 0
const tickDamage = 5

const impactDamage = 1.5
const aoeDamage = 0.75

var explosionRadius
var realExplosionRadius

var sounds = [
	preload("res://Assets/Music/soundEffects/explosion/explosion.wav"),
	preload("res://Assets/Music/soundEffects/explosion/explosion (1).wav"),
	preload("res://Assets/Music/soundEffects/explosion/explosion (2).wav"),
	preload("res://Assets/Music/soundEffects/explosion/explosion (3).wav")
]
onready var audioPlayer = get_node("AudioStreamPlayer2D")

func _ready():
	pass
	
func playSound():
	var randomIndex = randi() % sounds.size()

	audioPlayer.stream = sounds[randomIndex]
	
	audioPlayer.volume_db = linear2db(Perks.shootVolume)

	audioPlayer.play()

func _process(delta):
	if exploding:
		t += delta
		update()
		
		if DoT:
			aoe()
		
		if t > explosdingDuration:
			queue_free()
	else:
		t += delta / duration
		
		if is_instance_valid(target) and not target.dead:
			positionB = target.global_position
			
		var q0 = positionA.linear_interpolate(positionC, min(t, 1.0))
		var q1 = positionC.linear_interpolate(positionB, min(t, 1.0))
		global_position = q0.linear_interpolate(q1, min(t, 1.0))
		
		
		updateDirection((q1 - q0).normalized())
		visible = true
		if t > 1:
				explode()

func aoe():
	if TimeScaler.time()-lastTick >= tickRate:
		var ants = get_tree().get_nodes_in_group("Ants")

		for ant in ants:
			if ((ant.isFlying and hitsFlying) or not ant.isFlying) and not ant.dead:
				if ant.global_position.distance_squared_to(global_position) <= explosionRadius/2:
					ant.takeDamage(tickDamage)

					
		lastTick = TimeScaler.time()
	
func updateDirection(velocity:Vector2) -> void:
	rotation = velocity.angle()
	
	
func explode(hitAnt:Object=target):
	var ants = get_tree().get_nodes_in_group("Ants")
	
	playSound()
	
	for ant in ants:
		if ((ant.isFlying and hitsFlying) or not ant.isFlying) and not ant.dead:
			if ant.global_position.distance_squared_to(global_position) <= explosionRadius/2:
				if homing:
					if ant == hitAnt:
						ant.takeDamage(damage*impactDamage*Perks.physicalDamageMult)
					else:
						ant.takeDamage(damage*aoeDamage*Perks.physicalDamageMult)
						
				else:
					ant.takeDamage(damage*Perks.physicalDamageMult*summonDamage)
				
	sprite.texture = null
	exploding = true
	t = 0

func _on_Arrow_area_entered(area):
	if not exploding:
		explode(area)
		
func _draw():
	if exploding:
		draw_circle(Vector2.ZERO, realExplosionRadius/2, Color(1, 0.7,0.2,0.5))

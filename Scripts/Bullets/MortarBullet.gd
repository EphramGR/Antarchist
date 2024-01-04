extends Sprite

const shrapnelBullet = preload("res://Scenes/CannonBall.tscn")
var barrel

var updatedBarrel = false

var positionA
var positionB
var positionC

var game = null

var t = 0.0
var duration = 5.0
var exploding = false
var explosdingDuration = 0.4 

var fire = false
var nuke = false
var shrapnel = false

var explosionRadius
var realExplosionRadius
var damage
var hitsFlying:bool = false

const tickRate = 200
var lastTick = 0
const elementalDuration = 0.3
const tickDamage = 10

const numShrapnel = 6
const shrapDamage = 25
const shrapDuration = 0.06
const shrapSpeed = 7

var sounds = [
	preload("res://Assets/Music/soundEffects/explosion/explosion.wav"),
	preload("res://Assets/Music/soundEffects/explosion/explosion (1).wav"),
	preload("res://Assets/Music/soundEffects/explosion/explosion (2).wav"),
	preload("res://Assets/Music/soundEffects/explosion/explosion (3).wav")
]
onready var audioPlayer = get_node("AudioStreamPlayer2D")

func playSound():
	var randomIndex = randi() % sounds.size()

	audioPlayer.stream = sounds[randomIndex]
	
	audioPlayer.volume_db = linear2db(Perks.shootVolume)

	audioPlayer.play()

func _process(delta):
	if exploding:
		t += delta
		update()
		
		aoe()
		
		if t > explosdingDuration:
			queue_free()
	else:
		t += delta / duration
		var q0 = positionA.linear_interpolate(positionC, min(t, 1.0))
		var q1 = positionC.linear_interpolate(positionB, min(t, 1.0))
		position = q0.linear_interpolate(q1, min(t, 1.0))
		
		if not updatedBarrel:
			barrel.rotation = positionA.angle_to_point(global_position) - PI/2
			updatedBarrel = true
		
		if t > 1:
				explode()
		
func aoe():
	if nuke or fire:
		if TimeScaler.time()-lastTick >= tickRate:
			var ants = get_tree().get_nodes_in_group("Ants")
	
			for ant in ants:
				if not ant.dead and ((ant.isFlying and hitsFlying) or not ant.isFlying) and ant.global_position.distance_squared_to(global_position) <= explosionRadius/2:
					if nuke:
						ant.takeDamage(tickDamage*Perks.elementalDamageMult)
					if fire:
						ant.burn(elementalDuration*Perks.fireDurationMult)
						
			lastTick = TimeScaler.time()
						
func spawnShrapnel():
	for i in range(numShrapnel):
		shoot()
		
func shoot():
	var bulletInstance = shrapnelBullet.instance()

	bulletInstance.global_position = global_position
	
	var vector = Vector2(rand_range(-1,1),rand_range(-1,1)).normalized() 
	
	bulletInstance.vector = vector * shrapSpeed
	bulletInstance.damage = shrapDamage
	bulletInstance.duration = shrapDuration
	bulletInstance.z_index = 6
	bulletInstance.piercing = true
	bulletInstance.scale *= 0.8
	game.add_child(bulletInstance)
		
func explode():
	playSound()
	var ants = get_tree().get_nodes_in_group("Ants")
	
	for ant in ants:
		if not ant.dead and ((ant.isFlying and hitsFlying) or not ant.isFlying):
			if ant.global_position.distance_squared_to(global_position) <= explosionRadius/2:
				ant.takeDamage(damage*Perks.physicalDamageMult)
	texture = null
	exploding = true
	t = 0
	
	if shrapnel:
		spawnShrapnel()
	if nuke:
		var radiation = get_node("Radiation")
		radiation.emitting = true
		radiation.amount = realExplosionRadius*2.8
		radiation.emission_sphere_radius = realExplosionRadius*2
		
	if fire:
		var flame = get_node("Fire")
		flame.emitting = true
		flame.amount = realExplosionRadius*4
		flame.emission_sphere_radius = realExplosionRadius*2
	
func _draw():
	if exploding:
		draw_circle(Vector2.ZERO, realExplosionRadius*2, Color(1, 0.7,0.2,0.5))

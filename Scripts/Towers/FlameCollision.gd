extends CollisionShape2D

onready var flame = get_parent().get_parent()

onready var particle = flame.particles[num]

onready var lifeTime = particle.lifetime
onready var linearAccelCurve = particle.linear_accel_curve
onready var initialVelocity = particle.initial_velocity
onready var gravity = particle.gravity
onready var direction = particle.direction

onready var scaleMultiplier = particle.spread/30

var elapsedTime = 0.05
var currentPosition
var currentVelocity

var num

const speedScale = 0.065
const lifeScale = 0.65

func _ready():
	global_position = particle.get_emission_points()[0]
	
	currentPosition = global_position
	currentVelocity = initialVelocity
	

func _process(delta):
	if elapsedTime < lifeTime * lifeScale:
		var accel = linearAccelCurve.interpolate_baked(elapsedTime / lifeTime) * delta
		currentVelocity += accel
		currentPosition += Vector2(currentVelocity,currentVelocity) * speedScale * delta

		# Increment the elapsed time
		elapsedTime += delta

		# Apply gravity to the final position
		currentPosition += gravity * elapsedTime * elapsedTime * speedScale

		# Set the final position of the sprite
		global_position = currentPosition
		
		scale = Vector2.ZERO.linear_interpolate(Vector2.ONE, (elapsedTime-0.05)/(lifeTime * lifeScale)) * scaleMultiplier
		
	else:
		destroyCollision()
		
	
func destroyCollision():
	var parent = get_parent()
	# Emit area_exited signal for all colliding areas
	for area in parent.get_overlapping_areas():
		parent.emit_signal("area_exited", area)

	# Queue the collision shape for freeing
	queue_free()


func _on_FlameCollision_area_entered(area):
	flame._on_Flame_area_entered(area)


func _on_FlameCollision_area_exited(area):
	flame._on_Flame_area_exited(area)

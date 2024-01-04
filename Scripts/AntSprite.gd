extends Spatial

var BLUE = Color(0.388235,0.607843,1,1)
var RED = Color(0.67451,0.196078,0.196078,1)
#var YELLOW = Color(0.984314,0.94902,0.211765,1)




func _ready():
	pass
	
func setRotation(currentRotation, color):
	var top = Vector3(0, -45, 0)
	var left = Vector3(45, 0, 0)
	var right = Vector3(-45, 0, 0)
	
	if color == Color.black:
		$Sprite3D.rotation_degrees = Vector3.ZERO
	elif color == RED:
		$Sprite3D.rotation_degrees = rotateVectorAroundZ(left, currentRotation)
	elif color == BLUE:
		$Sprite3D.rotation_degrees = rotateVectorAroundZ(top, currentRotation)
	else:
		$Sprite3D.rotation_degrees = rotateVectorAroundZ(right, currentRotation)

func rotateVectorAroundZ(vector: Vector3, rotation_radians: float) -> Vector3:
	var cos_angle = cos(rotation_radians)
	var sin_angle = sin(rotation_radians)
	var x = vector.x * cos_angle - vector.y * sin_angle
	var y = vector.x * sin_angle + vector.y * cos_angle
	return Vector3(x, y, 0)

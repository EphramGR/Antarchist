extends Camera2D

var _target_zoom: float = 1.0

const MIN_ZOOM: float = 0.1
const MAX_ZOOM: float = 10.0
const ZOOM_INCREMENT: float = 0.1

const ZOOM_RATE: float = 8.0

func _ready():
	limit_top = -10000
	limit_bottom = 10000
	limit_left = -10000
	limit_right = 10000
	
#func _process(delta):
	#pass#setFogPositionFromCamera()

func _unhandled_input(event: InputEvent) -> void:
	#tells how far we moved relative to last frame
	if event is InputEventMouseMotion:
		#if moved during pressing middle mouse button
		if event.button_mask == BUTTON_MASK_MIDDLE:
			var movement = event.relative*zoom
			position -= movement
			
	#if we scroll, zoom
	if event is InputEventMouseButton:
		if event.is_pressed():
			if event.button_index == BUTTON_WHEEL_UP:
				zoomIn()
			if event.button_index == BUTTON_WHEEL_DOWN:
				zoomOut()
				
func zoomIn():
	_target_zoom = max(_target_zoom - ZOOM_INCREMENT, MIN_ZOOM)
	#animates zoom towards target zoom (enables physics process so it can zoom)
	set_physics_process(true)
	
func zoomOut():
	_target_zoom = min(_target_zoom + ZOOM_INCREMENT, MAX_ZOOM)
	#animates zoom towards target zoom
	set_physics_process(true)
	
func _physics_process(delta: float) -> void:
	#makes zoom motion same on different machines
	zoom = lerp(zoom, _target_zoom * Vector2.ONE, ZOOM_RATE * delta)
	
	#disables physics process when finishing zoom
	set_physics_process(not is_equal_approx(zoom.x, _target_zoom))

	
	
#func setFogPositionFromCamera():
	#var camera_top_left = global_position - (get_viewport_rect().size * 0.5)
	#fog.region_rect = Rect2(-get_viewport_rect().size*zoom/2, get_viewport_rect().size*zoom)




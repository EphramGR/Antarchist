extends TextureButton

onready var game = get_parent()
var coords
var direction
const directions = [Vector2(0,-1), Vector2(1,0), Vector2(0,1), Vector2(-1,0), Vector2.ZERO]

func _ready():
	pass 



func _on_ChunkButton_pressed():
	if game.buttonsEnabled and game.lumens > 0:
		game.buttonsEnabled = false
		game.redoFirst = false
		game.redoCoords = coords
		game.redoDirection = direction
		game.lumens -= 1
		game.create_chunk(coords, false, direction)
		
		game.buttonsAt.erase(coords+directions[direction])
		game.buttons.erase(self)
		
		game.updateLumens()
		
		queue_free()

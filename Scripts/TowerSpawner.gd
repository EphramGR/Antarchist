extends TextureButton

enum TOWER {ARCHER, BOOST, CANNON, CASTLE, FLAIL, FLAME, ICE, INFERNO, MORTAR, NEEDLE, DRONE, SALVO, STOCK, TESLA, VORTEX}

const towerNames = {
	TOWER.ARCHER:"Archer", 
	TOWER.BOOST:"Boost", 
	TOWER.CANNON:"Cannon", 
	TOWER.CASTLE:"Castle", 
	TOWER.FLAIL:"Flail", 
	TOWER.FLAME:"Flame", 
	TOWER.ICE:"Ice", 
	TOWER.INFERNO:"Inferno", 
	TOWER.MORTAR:"Mortar", 
	TOWER.NEEDLE:"Needle", 
	TOWER.DRONE:"Drone", 
	TOWER.SALVO:"Salvo", 
	TOWER.STOCK:"Stock", 
	TOWER.TESLA:"Tesla", 
	TOWER.VORTEX:"Vortex"
	}


export(
	int, 
	"ARCHER", 
	"BOOST", 
	"CANNON", 
	"CASTLE", 
	"FLAIL", 
	"FLAME", 
	"ICE", 
	"INFERNO", 
	"MORTAR", 
	"NEEDLE", 
	"DRONE", 
	"SALVO", 
	"STOCK", 
	"TESLA", 
	"VORTEX"
) var tower

const infoScene = preload("res://Scenes/InfoBoard.tscn")

var infoInstance

func _ready():
	connect("pressed", get_parent().get_parent().get_parent().get_parent().get_parent(), "_on_anyTower_pressed", [tower, Perks.costs[towerNames[tower]]])
	
	get_parent().get_parent().get_node("Cost/" + towerNames[tower]).bbcode_text = "[center]"+ String(Perks.costs[towerNames[tower]])


func _on_mouse_entered():
	infoInstance = infoScene.instance()
	infoInstance.towerName = towerNames[tower]
	add_child(infoInstance)


func _on_mouse_exited():
	infoInstance.queue_free()

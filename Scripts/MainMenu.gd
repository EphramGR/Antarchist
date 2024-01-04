extends CanvasLayer

var inPlay:bool = false
var inPerks:bool = false
var inSettings:bool = false
var inExit:bool = false


func _ready():
	OS.window_fullscreen = true
	pass


func _input(event):
	if event is InputEventMouseButton:
		if event.is_pressed():
			if event.button_index == BUTTON_LEFT:
				if inPlay:
					startGame()
				elif inPerks:
					pass
				elif inSettings:
					pass
				elif inExit:
					get_tree().quit()
					
					
func startGame():
	var scene_tree = get_tree()
	#var game_scene = preload("res://Scenes/PerkSelection.tscn")
	
	scene_tree.change_scene("res://Scenes/PerkSelection.tscn")

func _on_Play_mouse_entered():
	get_node("Background/Play").text = "}Play"
	inPlay = true
func _on_Play_mouse_exited():
	get_node("Background/Play").text = " Play"
	inPlay = false


func _on_Perks_mouse_entered():
	get_node("Background/Perks").text = "}Perks"
	inPerks = true
func _on_Perks_mouse_exited():
	get_node("Background/Perks").text = " Perks"
	inPerks = false

func _on_Settings_mouse_entered():
	get_node("Background/Settings").text = "}Settings"
	inSettings = true
func _on_Settings_mouse_exited():
	get_node("Background/Settings").text = " Settings"
	inSettings = false


func _on_Exit_mouse_entered():
	get_node("Background/Exit").text = "}Exit"
	inExit = true
func _on_Exit_mouse_exited():
	get_node("Background/Exit").text = " Exit"
	inExit = false

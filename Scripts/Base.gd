extends Area2D

var MAXFOOD = Perks.startingHp

var foodLeft = MAXFOOD
var foodHeld = 0
var sheildHits:int = Perks.maxSheildHits

var healthbar
var actualhealthbar
var sheildBar

var game

onready var takeFood = get_node("takeFood")
onready var takeDamage = get_node("takeDamage")
onready var takeShield = get_node("takeShield")


func _ready():
	pass

func foodTaken(amount):
	if sheildHits > 0:
		sheildHits -= 1
		takeShield.play()
		updateHealthBar()
		return 0
	
	else:
		if foodLeft <= 0:
			return 0
			
		if amount > foodLeft:
			var i = foodLeft
			foodHeld += foodLeft
			foodLeft = 0
			updateHealthBar()
			return i
			
		takeFood.play()
		foodLeft -= amount
		foodHeld += amount
		updateHealthBar()
		return amount
	
	
	
func foodReturned(amount):
	foodHeld -= amount
	foodLeft += amount
	if foodLeft > MAXFOOD:
		foodLeft = MAXFOOD
		
	updateHealthBar()
		
func foodStolen(amount):
	if Perks.chanceToIgnoreDamage == -1 or rand_range(0,1) > Perks.chanceToIgnoreDamage:
		foodHeld -= amount
		takeDamage.play()
		if foodHeld <= 0 and foodLeft <= 0:
			if Perks.reincarnationPercent == 0:
				Perks.newGame()
				get_tree().change_scene("res://Scenes/MainMenu.tscn")
			else:
				foodLeft = max(round(MAXFOOD*Perks.reincarnationPercent),1)
				game.clearColony()
				game.waveIndex -= 1
				Perks.reincarnationPercent = 0
				
	else:
		foodHeld -= amount
		foodLeft += amount
	updateHealthBar()
			
func updateHealthBar()->void:
	if foodHeld < 0:
		foodHeld = 0
		print_stack()
		print("Food hald was less than 0, temp fix")
		
	healthbar.value = foodLeft+foodHeld
	actualhealthbar.value = foodLeft
	if Perks.maxSheildHits != -1:
		sheildBar.value = sheildHits
	
	
	
	
	
	
	
	
	
	
	
	
	
	

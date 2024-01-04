extends Area2D

#logic
var antsInHitbox = []

#settings
var damage
var slow:bool
var confuse:bool
var hitsFlying:bool = false

onready var audioPlayer = get_node("AudioStreamPlayer2D")

func _ready():
	pass
	
func playSound():
	audioPlayer.volume_db = linear2db(Perks.shootVolume)

	audioPlayer.play()

func _on_Spike_area_entered(area):
	if not area in antsInHitbox and ((area.isFlying and hitsFlying) or not area.isFlying) and not area.dead:
		area.takeDamage(damage*Perks.physicalDamageMult)
		
		if slow:
			area.slow(0.1*Perks.slowDurationMult)
			
		if confuse:
			area.confuse(0.1*Perks.confusionDurationMult)
		
		antsInHitbox.append(area)
		playSound()


func _on_Spike_area_exited(area):
	antsInHitbox.erase(area)

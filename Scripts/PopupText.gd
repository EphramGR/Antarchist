extends CanvasLayer

onready var tween = get_node("UI/Tween")
onready var label = get_node("UI/Label")

var text = "I forgot to add text"
var fadeDuration = 2.5

func _ready():
	
	# Set up initial properties of the Label
	label.bbcode_text = "[center]" + text

	# Call the popup animation function
	popup()

func popup():
	# Set initial alpha value of the Label to 1.0
	label.modulate.a = 1.0
	
	# Start the fade-out animation
	tween.interpolate_property(label, "modulate:a", 1.0, 0.0, fadeDuration, Tween.TRANS_LINEAR)
	tween.start()


func _on_Tween_tween_completed(object, key):
	queue_free()

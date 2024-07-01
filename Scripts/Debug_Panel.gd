extends PanelContainer

var frames_per_second
@onready var FPS_Label = $MarginContainer/VBoxContainer/FPS



# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	frames_per_second = "%.2f" % (1.0/delta)
	FPS_Label.text = FPS_Label.name + ": " + frames_per_second

extends Node
var hand : Node2D
var ship : Ship
var text : RichTextLabel

func _ready():
	hand = $Speedometer/Node2D
	text = $Speedometer/Node2D2/RichTextLabel
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta):
	var speed = ship.velocity.length() 
	hand.rotation_degrees = speed + 67
	text.text = str(floor(speed*10))

extends Node
var hand : Node2D
var ship : CharacterBody3D
var text : RichTextLabel

func _ready():
	hand = $Speedometer/Node2D
	text = $Speedometer/Node2D2/RichTextLabel
	ship = $"../../../../../Ship"
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	var speed = ship.velocity.length() 
	hand.rotation_degrees = speed + 67
	text.text = str(floor(speed))

extends Area3D

@export var PreviousNode : Node3D = null
@export var NextNode : Node3D


func _on_body_entered(body):
	if body.is_in_group("Ship"):
		body.AIPilotNode = NextNode
		

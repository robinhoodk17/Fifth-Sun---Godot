extends Area3D

@export var PreviousNode : Node3D = null
@export var NextNode : Node3D
enum RouteTypes {boost, AI}
@export var Type : RouteTypes = RouteTypes.AI


func _on_body_entered(body):
	if body.is_in_group("Ship"):
		body.AIPilotNode = NextNode
		if Type == RouteTypes.boost:
			body.forward_speed += body.boost
		

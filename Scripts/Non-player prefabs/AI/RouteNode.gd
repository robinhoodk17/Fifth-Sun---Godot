extends Area3D

@export var PreviousNode : Node3D = null
@export var NextNode : Node3D
@export var rotation_indicator : MeshInstance3D
enum RouteTypes {boost, AI}
@export var Type : RouteTypes = RouteTypes.AI
@export var child: Node3D

func _ready():
	rotation_indicator.visible = false
	if child != null:
		child.NextNode = NextNode
		print(child.NextNode)

func _on_body_entered(body):
	print("entered")
	if body.is_in_group("Ship"):
		body.AIPilotNode = NextNode
		if Type == RouteTypes.boost:
			body.forward_speed += body.boost

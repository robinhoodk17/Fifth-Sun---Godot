extends Area3D

@export var PreviousNode : Node3D = null
@export var NextNode : Node3D
@export var rotation_indicator : Node3D
enum RouteTypes {boost, AI}
@export var Type : RouteTypes = RouteTypes.AI
@export var child: Node3D
@export var hookshotTarget : Node3D

func _ready():
	rotation_indicator.visible = false
	if child != null:
		child.NextNode = NextNode
		child.hookshotTarget = hookshotTarget
		#print(str("name: ", name, "  next node: ", NextNode))
	
	

func _on_body_entered(body):
	if body.is_in_group("Ship"):
		body.AIPilotNode = NextNode
		body.get_node("Turret/Turret_body_y").autoGunnerHookTarget = hookshotTarget
		if hookshotTarget != null:
			body.get_node("Turret/Turret_body_y").acquiring_target = true
		if Type == RouteTypes.boost:
			body.boosting = true
			body.hasBeenBoostingFor = 0.0

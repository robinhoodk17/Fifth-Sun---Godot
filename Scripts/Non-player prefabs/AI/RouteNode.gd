extends Area3D

@export var PreviousNode : Node3D = null
@export var NextNode : Node3D
@export var rotation_indicator : Node3D
enum RouteTypes {boost, AI, antiGrav}
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
		body.get_node("Turret/Turret_body_y").StartSearchingForTarget(hookshotTarget)
		if Type == RouteTypes.antiGrav:
			body.transitioning = !body.antiGrav
		if Type == RouteTypes.boost:
			body.boostingFromRings = true
			body.hasBeenBoostingFor = 0.0

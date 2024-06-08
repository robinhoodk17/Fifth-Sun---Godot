extends Node3D
class_name AINavigator
var Active = true
@onready var pilotBehavior = GlobalVariables.pilotBehavior 
@onready var Pilot = GlobalVariables.Pilot 
@export var _shipBody : Ship
@onready var AIPilotNode
# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

func setTargetPosition(target):
	AIPilotNode = target

func autoPilot(delta):
	if pilotBehavior == GlobalVariables.Pilotbehaviors.straight:
		_shipBody.is_accelerating = true
	if pilotBehavior == GlobalVariables.Pilotbehaviors.normal:
		var targetPosition : Vector3 = AIPilotNode.position
		var dirToMovePosition = (position - targetPosition).normalized()
		var frontorBack : float = dirToMovePosition.dot(global_transform.basis.z)
		var leftorRight : float = dirToMovePosition.dot(global_transform.basis.x)
		var upOrDown : float = dirToMovePosition.dot(global_transform.basis.y) * (-1.0)
		var Roll : float = (AIPilotNode.basis.y.dot(global_transform.basis.y)-1)*(-1.0)
		
		_shipBody.yaw_input = lerp(_shipBody.yaw_input,clamp((leftorRight),-1.0,1.0),_shipBody.yaw_response)
		_shipBody.pitch_input = lerp(_shipBody.pitch_input,clamp((upOrDown),-1.0,1.0),_shipBody.pitch_response)
		_shipBody.roll_input = lerp(_shipBody.roll_input,Roll,_shipBody.roll_response*delta)
		
		if frontorBack <= 0 and !_shipBody.hooked:
			_shipBody.is_braking = true
			_shipBody.is_accelerating = false
		else: 
			_shipBody.is_accelerating = true
			_shipBody.is_braking = false

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if Active:
		autoPilot(delta)

extends CharacterBody3D

@export_group("Nodes for function")
@export var Camera : Marker3D
@export var Turret : Node3D
@export var AIPilotNode : Node3D
@export_group("Ship stats")
@export var max_speed : float = 50.0
@export var acceleration : float = 0.4
@export var braking : float = 1.2
@export var roll_speed : float = 1.2
@export var yaw_speed : float = 2.0
@export var pitch_speed : float = 2.0
@export_subgroup("Ship responsiveness")
@export var pitch_response : float = 1.2
@export var yaw_response : float = 1.2
@export var roll_response : float = 15.0
@export_group("Hookshot stats")
@export var hookshot_strength : float = 2.0
@export_group("Controller")
@export var Controller_Sensitivity : float = 1


@onready var Camera_offset : Vector3 = Camera.position
@onready var Pilot = GlobalVariables.Pilot 

var is_accelerating : bool = false
var is_braking : bool = false
var forward_speed : float = 0.0
var pitch_input : float = 0.0
var yaw_input : float = 0.0
var roll_input : float = 0.0
var _mouse_input : bool = false
var look_at : Vector3
var hooked : bool = false
var hookshot_length
var hookshot_landing_point


func _ready():
	if Pilot == 2:
		Input.mouse_mode = Input.MOUSE_MODE_CAPTURED

func _unhandled_input(event):
	_mouse_input = event is InputEventMouseMotion and Input.mouse_mode == Input.MOUSE_MODE_CAPTURED
	if _mouse_input and Pilot == 2:
		yaw_input = -event.relative.normalized().x * Controller_Sensitivity * .5
		yaw_input = clamp(yaw_input,-1,1)
		pitch_input = -event.relative.normalized().y * Controller_Sensitivity * .5
		pitch_input = clamp(pitch_input,-1,1)


func get_input(delta):
	if Pilot != null:
		pitch_input = lerp(pitch_input, Input.get_axis("Go_down_%s" % [Pilot],"Go_up_%s" % [Pilot]) * Controller_Sensitivity, pitch_response * delta)
		roll_input = lerp(roll_input, Input.get_axis("Roll_right_%s" % [Pilot],"Roll_left_%s" % [Pilot]) * Controller_Sensitivity, roll_response * delta)
		yaw_input = lerp(yaw_input, Input.get_axis("Go_right_%s" % [Pilot], "Go_left_%s" % [Pilot]) * Controller_Sensitivity, yaw_response * delta)
		if Input.is_action_pressed("Accelerate_%s" % [Pilot]):
			is_accelerating = true
		if Input.is_action_pressed("Brake_%s" % [Pilot]):
			is_braking = true

func move_turret_and_camera():
	Turret.position = position
	
	Camera.position = Camera.position.lerp(position,.3)
	
	var a = Quaternion(transform.basis)
	var b = Quaternion(Camera.transform.basis)
	var c = b.slerp(a, 0.1)
	Camera.transform.basis = Basis(c)

func _normal_movement(delta):
	transform.basis = transform.basis.rotated(transform.basis.z, roll_input * roll_speed * delta)
	transform.basis = transform.basis.rotated(transform.basis.x, pitch_input * pitch_speed * delta)
	transform.basis = transform.basis.rotated(transform.basis.y, yaw_input * yaw_speed * delta)
	transform.basis = transform.basis.orthonormalized()
	velocity = -transform.basis.z * forward_speed
func _hooked_movement(delta):
	transform.basis = transform.basis.rotated(transform.basis.z, roll_input * roll_speed * delta)
	transform.basis = transform.basis.rotated(transform.basis.x, pitch_input * pitch_speed * delta)
	transform.basis = transform.basis.rotated(transform.basis.y, yaw_input * yaw_speed * delta)
	transform.basis = transform.basis.orthonormalized()
	velocity = -transform.basis.z * forward_speed
	var distance_to_hook = position.distance_to(hookshot_landing_point)
	if (distance_to_hook  > hookshot_length):
		var vector_lookingat_hook : Vector3 = (hookshot_landing_point - global_position)
		vector_lookingat_hook = vector_lookingat_hook.normalized()
		vector_lookingat_hook = vector_lookingat_hook * (distance_to_hook - hookshot_length) * hookshot_strength
		velocity += vector_lookingat_hook
func setTargetPosition(target):
	AIPilotNode = target
func autoPilot(delta):
	var targetPosition : Vector3 = AIPilotNode.position
	var dirToMovePosition = (position - targetPosition).normalized()
	var frontorBack : float = dirToMovePosition.dot(global_transform.basis.z)
	var leftorRight : float = dirToMovePosition.dot(global_transform.basis.x)
	var upOrDown : float = dirToMovePosition.dot(global_transform.basis.y) * (-1.0)
	var Roll : float = AIPilotNode.basis.y.dot(global_transform.basis.y)-1
	
	yaw_input = lerp(yaw_input,clamp((leftorRight),-1.0,1.0),yaw_response)
	pitch_input = lerp(pitch_input,clamp((upOrDown),-1.0,1.0),pitch_response)
	roll_input = lerp(roll_input,Roll,roll_response*delta)
	
	if frontorBack <= 0:
		is_braking = true
		is_accelerating = false
	else: 
		is_accelerating = true
		is_braking = false
	
func _physics_process(delta):
	forward_speed = velocity.length()
	is_accelerating = false
	is_braking = false
	get_input(delta)
	if Pilot == null:
		autoPilot(delta)
	if is_braking:
		if forward_speed > 0:
			forward_speed -= braking * delta
	elif is_accelerating:
		if forward_speed < max_speed:
			forward_speed += acceleration * delta
	if not hooked:
		_normal_movement(delta)
	else:
		_hooked_movement(delta)
	move_and_slide( )
	move_turret_and_camera()
	"""
	#only rotating the camera around 2 axes to prevent dizziness
	var rocket_euler = transform.basis.get_euler()
	var camera_euler = Camera.transform.basis.get_euler()
	var target_eulerxy = Vector3(rocket_euler.x,rocket_euler.y,camera_euler.z)
	var target_quatxy = Quaternion.from_euler(target_eulerxy)
	
	var b = Quaternion(Camera.transform.basis)
	var c = b.slerp(target_quatxy, 0.1)
	Camera.transform.basis = Basis(c)
	
	#Here we rotate on the last axis
	var target_eulerz = Vector3(camera_euler.x,camera_euler.y,rocket_euler.z)
	var target_quatz = Quaternion.from_euler(target_eulerz)
	b = Quaternion(Camera.transform.basis)
	c = b.slerp(target_quatz, 0.01)
	Camera.transform.basis = Basis(c)
	
	"""
	"""
	#Here we rotate on the last axis
	camera_euler = Camera.transform.basis.get_euler()
	if(camera_euler.z - rocket_euler.z > .52 or camera_euler.z - rocket_euler.z < -.52 or rotating_on_z):
		rotating_on_z = true
		var target_eulerz = Vector3(camera_euler.x,camera_euler.y,rocket_euler.z)
		var target_quatz = Quaternion.from_euler(target_eulerz)
		b = Quaternion(Camera.transform.basis)
		c = b.slerp(target_quatz, 0.1)
		Camera.transform.basis = Basis(c)
		if(camera_euler.z - rocket_euler.z <.05 and camera_euler.z - rocket_euler.z > -.05):
			rotating_on_z = false"""
	
	

	

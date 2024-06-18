extends CharacterBody3D
class_name Ship
@export_group("Nodes for function")
##The marker3D, not the actual camera
@export var Camera : Marker3D
##The 3D node labeled "Turret"
@export var Turret : Node3D
##The node with all the colliders
@export var BodyCollider : Array[CollisionShape3D]
##The node with all the Meshes
@export var theMesh : Node3D
@export_group ("VFX and audio")
@export var motionBlur : Node3D

@export_group("Ship stats")
@export var max_speed : float = 100.0
@export var acceleration : float = 16.0
@export var boost : float = 30.0
@export var braking : float = 1.2
@export var roll_speed : float = 1.2
@export var yaw_speed : float = 2.0
@export var pitch_speed : float = 2.0
@export var strafe_speed : float = 0.5
@export var boostTime : float = 2.0
@export_subgroup("Ship responsiveness")
@export var pitch_response : float = 1.2
@export var yaw_response : float = 1.2
@export var roll_response : float = 15.0
@export var grip : float = .8
@export_group("Hookshot stats")
@export var hookshot_strength : float = .05
@export_group("Controller")
@export var Controller_Sensitivity : float = 1

@onready var AIPilotNode : Node = $"../Track_objects/Route_nodes/1"
@onready var Camera_offset : Vector3 = Camera.position
@onready var Pilot = GlobalVariables.Pilot 
@onready var pilotBehavior = GlobalVariables.pilotBehavior 

var is_accelerating : bool = false
var is_braking : bool = false
var forward_speed : float = 0.0
"""collision variables"""
var collision_suspension_time = 1.6
var collision_time = collision_suspension_time+1
var is_skidding = false
var minimum_speed_after_collision = .25
""""""

var pitch_input : float = 0.0
var yaw_input : float = 0.0
var roll_input : float = 0.0
var _mouse_input : bool = false
var lerpSpeed = .2
var hooked : bool = false
var boosting : bool = false
var hasBeenBoostingFor : float = 0.0
#we set the hookshot length from the turret, right now it is disconnected because we don't use the length here
var hookshot_length
var hookshot_landing_point
var held_Item = null
var draft : bool = true
var strafing : float = 0.0


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
		strafing = lerp(strafing, Input.get_axis("Strafe_right_%s" % [Pilot], "Strafe_left_%s" % [Pilot]) * Controller_Sensitivity, strafe_speed * delta)
		if Input.is_action_pressed("Accelerate_%s" % [Pilot]):
			is_accelerating = true
		if Input.is_action_pressed("Brake_%s" % [Pilot]):
			is_braking = true
		if Input.is_action_pressed("Secondary_%s" % [Pilot]):
			if held_Item == "boost":
				held_Item = null
				forward_speed += 10
func rotateShip(delta):
	theMesh.transform.basis = theMesh.transform.basis.rotated(theMesh.transform.basis.z, roll_input * roll_speed * delta)
	for i in BodyCollider:
		i.transform.basis = i.transform.basis.rotated(i.transform.basis.z, roll_input * roll_speed * delta)
	transform.basis = transform.basis.rotated(transform.basis.x, pitch_input * pitch_speed * delta)
	transform.basis = transform.basis.rotated(transform.basis.y, yaw_input * yaw_speed * delta)
	transform.basis = transform.basis.orthonormalized()
	velocity = -transform.basis.z * forward_speed
func move_turret_and_camera(delta):
	Turret.position = position
	if boosting:
		lerpSpeed = .2
		Camera.position = Camera.position.lerp(position,lerpSpeed)
	else:
		if lerpSpeed < .6:
			lerpSpeed = lerp(lerpSpeed,.6,.5*delta)
		Camera.position = Camera.position.lerp(position,lerpSpeed)
	var a = Quaternion(transform.basis.orthonormalized())
	var b = Quaternion(Camera.transform.basis.orthonormalized())
	var c = b.slerp(a, 0.1)
	Camera.transform.basis = Basis(c)

func _normal_movement(delta):
	if(collision_time > collision_suspension_time and !is_skidding):
		rotateShip(delta)
		velocity = -transform.basis.z * forward_speed
	else:
		if is_skidding:
			rotateShip(delta)
			if(velocity.length() < max_speed):
				velocity = velocity - transform.basis.z * acceleration*delta
		if !is_skidding:
			var aimingAt = position + velocity
			var look_atMatrix = global_transform.looking_at(aimingAt, global_transform.basis.y)
			global_transform.basis.y=lerp(global_transform.basis.y, look_atMatrix.basis.y, delta*10)
			global_transform.basis.x=lerp(global_transform.basis.x, look_atMatrix.basis.x, delta*10)
			transform.basis = transform.basis.orthonormalized()
			rotateShip(delta)
			velocity = velocity.normalized() * forward_speed
		
func _hooked_movement(delta):
	rotateShip(delta)
	velocity = -transform.basis.z * forward_speed
	#this is only useful if we want to start adding force if we are too far apart from the landing point
	#var distance_to_hook = position.distance_to(hookshot_landing_point)
	
	#Here we handle how the hookshot interacts with the ship
	#we set the hookshot length from the turret, right now it is disconnected because we don't use the length here
	"""if (distance_to_hook  > hookshot_length):
		pass"""
	var vector_lookingat_hook : Vector3 = (hookshot_landing_point - global_position).normalized() * velocity.length()	
	velocity = (velocity.normalized() + (vector_lookingat_hook * hookshot_strength/8)).normalized()*forward_speed
	var look_at_vector = transform.looking_at(position + velocity,transform.basis.y)
	transform.basis.x = look_at_vector.basis.x
	transform.basis.y = look_at_vector.basis.y
	transform.basis.z = look_at_vector.basis.z
	transform.basis.orthonormalized()


func setTargetPosition(target):
	AIPilotNode = target
func autoPilot(delta):
	if pilotBehavior == GlobalVariables.Pilotbehaviors.straight:
		is_accelerating = true
	if pilotBehavior == GlobalVariables.Pilotbehaviors.normal:
		var targetPosition : Vector3 = AIPilotNode.position
		var dirToMovePosition = (position - targetPosition).normalized()
		var frontorBack : float = dirToMovePosition.dot(global_transform.basis.z)
		var leftorRight : float = dirToMovePosition.dot(global_transform.basis.x)
		var upOrDown : float = dirToMovePosition.dot(global_transform.basis.y) * (-1.0)
		var Roll : float = (AIPilotNode.basis.y.dot(theMesh.global_transform.basis.y)-1)*(-1.0)
		
		yaw_input = lerp(yaw_input,clamp((leftorRight),-1.0,1.0),yaw_response)
		pitch_input = lerp(pitch_input,clamp((upOrDown),-1.0,1.0),pitch_response)
		roll_input = lerp(roll_input,Roll,roll_response*delta)
		
		if frontorBack <= 0 and !hooked:
			is_braking = true
			is_accelerating = false
		else: 
			is_accelerating = true
			is_braking = false
		if is_skidding:
			is_accelerating = false
"""
forward speed also gets changed by the RouteNode script on entering if it is a booster node
and by the TUrret_controller script when the hookshot gets unhooked
"""
func _physics_process(delta):
	#here we record the previous 5 speeds. We increase the speed_array_counter at the end of physiscs process
	collision_time += 1 * delta
	if draft:
		forward_speed -= 2 * delta
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
	if boosting:
		hasBeenBoostingFor+=delta
		forward_speed += boost * delta
		if hasBeenBoostingFor >= boostTime:
			boosting = false
	if not hooked:
		_normal_movement(delta)
	else:
		_hooked_movement(delta)
	
	forward_speed = velocity.length()
	global_position -= transform.basis.x*strafing
	var collisions = move_and_collide(velocity*delta)
	if collisions:
		collide_and_slide(collisions, delta)
	move_turret_and_camera(delta)
	forward_speed = velocity.length()
	if collision_time > collision_suspension_time/2:
		if !is_accelerating:
			is_skidding = false
	if collision_time > collision_suspension_time:
		is_skidding = false
	doVFX(delta)

func doVFX(_delta):
	pass
	#motionBlur._forwardSpeed = forward_speed
	#motionBlur.material.getshader_param

func find_largest_dict_key(dict):
	var max_val = -999999
	var key
	for i in dict:
		var val =  dict[i]
		if val > max_val:
			max_val = val
			key = i
	return key
func collide_and_slide(currentcollision : KinematicCollision3D, _delta):
	if collision_time > collision_suspension_time/4:
		strafing = -strafing
	collision_time = 0
	var collision_normal = currentcollision.get_normal()
	velocity = velocity.bounce(collision_normal) * .95
	is_skidding = true
	#var velocity_loss = (1 - abs(collision_normal.normalized().dot(velocity.normalized())))*.95
	#velocity_loss = clamp(velocity_loss,minimum_speed_after_collision,.95)
	#if(velocity_loss <= minimum_speed_after_collision):
	#	is_skidding = true 
	#velocity = velocity.bounce(collision_normal) * velocity_loss
	if hooked:
		hooked = false
	Turret.get_node("Turret_body_y")._retract_hookshot()

extends CharacterBody3D
class_name Ship

signal collisionSignal
enum CollisionType {Recent, Skidding, Normal}
@export_group("Nodes for function")
##The 3D node labeled "Turret"
@export var Turret : Node3D
##The node with all the colliders
@export var BodyCollider : Array[CollisionShape3D]
@export var GravSkirt : Array[RayCast3D]
##The node with all the Meshes
@export var theMesh : Node3D
@export var pitch_marker : Node3D
@export_group ("VFX and audio")
@export var motionBlur : Node3D

@export_group("Ship stats")
@export var max_speed : float = 100.0
@export var acceleration : float = 16.0
@export var boost : float = 30.0
@export var braking : float = 1.2
@export var roll_speed : float = 1.2
@export var yaw_speed : float = 2.0
@export var pitch_speed : float = 35.0
@export var strafe_speed : float = 0.5
@export var boostTime : float = 2.0
@export_subgroup("Ship responsiveness")
@export var pitch_response : float = 1.2
@export var yaw_response : float = 1.2
@export var roll_response : float = 15.0
@export var grip : float = .001
@export var pinballCollision : float = 1.25
var shipResponsiveness : float = grip
var climbResponsiveness : float = 2 * grip
@export_group("Hookshot stats")
@export var hookshot_strength : float = .05
@export_group("Controller")
@export var Controller_Sensitivity : float = 1

@onready var AIPilotNode : Node = $"../Track_objects/Route_nodes/1"
@onready var Pilot = GlobalVariables.Pilot 
@onready var pilotBehavior = GlobalVariables.pilotBehavior 

var is_accelerating : bool = false
var is_braking : bool = false
var forward_speed : float = 0.0
var direction
var velocityX_Z
var velocityY
var climb = Vector3 (0,0,0)
var levitationSpeed : float = 0.0
@export var antiGrav : bool = false
var Ydamping : Array[float]
var YdampingCounter : int = 0
var dampingFrames : int = 7

"""collision variables"""
var collision_suspension_time = 2
var collision_time = collision_suspension_time+1
var collision_cooldown = 0
var is_skidding : CollisionType = CollisionType.Normal
var minimum_speed_after_collision = .25
var stored_velocity
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


func _ready():
	Pilot = GlobalVariables.Pilot
	for i in GravSkirt:
		i.add_exception(self)
	for i in dampingFrames:
		Ydamping.append(position.y)
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
		if !antiGrav:
			roll_input = lerp(roll_input, Input.get_axis("Roll_right_%s" % [Pilot],"Roll_left_%s" % [Pilot]) * Controller_Sensitivity, roll_response * delta)
		else:
			roll_input = lerp(roll_input, Input.get_axis("Roll_right_%s" % [Pilot],"Roll_left_%s" % [Pilot]) * Controller_Sensitivity, yaw_response * delta)
		yaw_input = lerp(yaw_input, Input.get_axis("Go_right_%s" % [Pilot], "Go_left_%s" % [Pilot]) * Controller_Sensitivity, yaw_response * delta)
		if Input.is_action_pressed("Accelerate_%s" % [Pilot]):
			is_accelerating = true
		if Input.is_action_pressed("Brake_%s" % [Pilot]):
			is_braking = true
		if Input.is_action_pressed("Secondary_%s" % [Pilot]):
			if held_Item == "boost":
				held_Item = null
				forward_speed += 10
func rotateShip(delta):
	transform.basis = transform.basis.rotated(transform.basis.y, yaw_input * yaw_speed * delta)
	transform.basis = transform.basis.orthonormalized()
	if !antiGrav:
		pitch_marker.position.y = 2.5 * pitch_input
		for i in BodyCollider:
			i.reparent(theMesh)
		theMesh.global_transform.basis = theMesh.global_transform.basis.rotated(theMesh.global_transform.basis.z, roll_input * roll_speed * delta)
		theMesh.look_at(pitch_marker.global_position, theMesh.global_basis.y)
		theMesh.global_transform.basis = theMesh.global_transform.basis.orthonormalized()
		for i in BodyCollider:
			i.reparent(self)
		direction = -transform.basis.z
		#direction = -theMesh.global_transform.basis.z
		climb = pitch_speed * Vector3(0,1,0) * pitch_input
	
func move_turret(delta):
	Turret.position = position

func _normal_movement(delta):
	if !antiGrav:
		if is_skidding == CollisionType.Normal:
			rotateShip(delta)
			if shipResponsiveness <1:
				shipResponsiveness = lerp(shipResponsiveness,1.0, .05)
				climbResponsiveness = lerp(climbResponsiveness, 1.0, .75)
			if shipResponsiveness > .99:
				shipResponsiveness = 1
				climbResponsiveness = 1
			var weighedVelocity = velocity.normalized() * (1-shipResponsiveness)
			var weighedDirection = direction * shipResponsiveness
			velocity = (weighedVelocity  + weighedDirection) * forward_speed + climb * climbResponsiveness
		if is_skidding == CollisionType.Skidding:
			rotateShip(delta)
			shipResponsiveness = lerp(shipResponsiveness,0.1, .01)
			climbResponsiveness = lerp(climbResponsiveness, 0.5, .05)
			var weighedVelocity = velocity.normalized() * (1.0 - shipResponsiveness)
			var weighedDirection = direction * shipResponsiveness
			velocity = (weighedVelocity  +  weighedDirection).normalized() * forward_speed + (climb * climbResponsiveness)
		if is_skidding == CollisionType.Recent:
			rotateShip(delta)
			if collision_time > .35 and collision_cooldown > .5:
				is_skidding = CollisionType.Skidding
				getVelocityX_Z()
				if velocityX_Z.dot(stored_velocity) < 0:
					stored_velocity += velocityX_Z
				if velocity.y * stored_velocity.y < 0:
					stored_velocity.y = velocity.y + stored_velocity.y
				velocity = stored_velocity/(pinballCollision*pinballCollision)
				velocity += climb * climbResponsiveness
				collision_cooldown = 0
	else:
		pass
		if is_skidding == CollisionType.Normal:
			rotateShip(delta)
			velocityY = velocity.dot(basis.y)
			velocity = -basis.z * forward_speed + (-basis.x) * roll_input * strafe_speed + (velocityY * basis.y)
func _hooked_movement(delta):
	rotateShip(delta)
	climbResponsiveness = 1
	shipResponsiveness = 1
	var vector_lookingat_hook : Vector3 = hookshot_landing_point - global_position
	var newvectorHook = (Vector3 (vector_lookingat_hook.x, 0, vector_lookingat_hook.z)).normalized()
	var rightorLeft = transform.basis.x.dot(newvectorHook)
	var frontorBack = transform.basis.z.dot(newvectorHook) 
	var vectorHookonZ
	if frontorBack <0:
		vectorHookonZ = Vector3(0,0,0)
	else:
		vectorHookonZ = transform.basis.z * transform.basis.z.dot(newvectorHook)
	velocity = (direction + vectorHookonZ * delta*1.25) * forward_speed + climb
	
	transform.basis = transform.basis.rotated(transform.basis.y, -rightorLeft * delta).orthonormalized()

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
		var upOrDown : float = dirToMovePosition.dot(global_transform.basis.y) * (-1.0) * 2.5
		var Roll : float = (AIPilotNode.basis.y.dot(theMesh.global_transform.basis.y)-1)*(-1.0)
		
		yaw_input = lerp(yaw_input,clamp((leftorRight),-1.0,1.0),yaw_response * delta * 2)
		pitch_input = lerp(pitch_input,clamp((upOrDown),-1.0,1.0),pitch_response * delta * 2)
		roll_input = lerp(roll_input,Roll,roll_response*delta * 2)
		
		if frontorBack <= 0 and !hooked:
			is_braking = true
			is_accelerating = false
		else: 
			is_accelerating = true
			is_braking = false
		if is_skidding == CollisionType.Skidding:
			is_accelerating = false
func handleGravity(delta):
	if !antiGrav:
		var check : bool = false
		for i in GravSkirt:
			if i.is_colliding():
				check = true
		if !check:
			if velocity.y > 0:
				velocity.y = 0
				climb = Vector3 (0,0,0)
	else:
		pass
		#transform.basis = transform.basis.rotated(transform.basis.y, yaw_input * yaw_speed * delta)
		#var distanceA = GravSkirt[0].get_collision_point().distance_to(GravSkirt[0].global_position)
		#var distanceB = GravSkirt[1].get_collision_point().distance_to(GravSkirt[1].global_position)
		#var distanceC = GravSkirt[2].get_collision_point().distance_to(GravSkirt[2].global_position)
		#
		#if distanceA > 2 and distanceB > 2 and distanceC > 2:
			#pass
		#getVelocityX_Z()
		#velocity = velocityX_Z + basis.y * -3
		#if distanceA < 1:
			#var upForce = 1/distanceA
			#velocity += basis.y * upForce * upForce * upForce
			#var targetArc = (basis.z * cos(PI/8 * delta * upForce) +  basis.y * sin(PI/8*delta * upForce)).normalized()
			##var thetaAcrossX =  (PI/8 - (distanceA * PI/8))
			#var q : Quaternion = Quaternion(-basis.z, targetArc)
			#transform.basis = transform.basis.slerp(Basis(q), .01)
			#transform.basis = Basis(Quaternion(transform.basis).slerp(q,.01))
		
		
		
"""
forward speed also gets changed by the RouteNode script on entering if it is a booster node
and by the TUrret_controller script when the hookshot gets unhooked
"""

func _physics_process(delta):

	
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
	
	handleGravity(delta)
	
		
	var collisions = move_and_collide(velocity*delta)
	if collisions:
		collide_and_slide(collisions, delta)
	collision_time += delta
	collision_cooldown += delta
	if collision_time >= collision_suspension_time:
		is_skidding = CollisionType.Normal
	elif collision_time >= collision_suspension_time/2:
		if !is_accelerating:
			is_skidding = CollisionType.Normal
	if !antiGrav:
		if is_skidding != CollisionType.Recent:
			velocity -= climb * climbResponsiveness
			getVelocityX_Z()
			forward_speed = velocityX_Z.length()
	else:
		forward_speed = velocity.dot(-basis.z)
		if forward_speed < 0:
			forward_speed = 0
	move_turret(delta)

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

func getVelocityX_Z():
	velocityX_Z = Vector3(velocity.x, 0, velocity.z)
func collide_and_slide(currentcollision : KinematicCollision3D, _delta):
	collisionSignal.emit()
	print("collision")
	collision_time = 0
	shipResponsiveness = 0.0
	if !antiGrav:
		var collision_normal = currentcollision.get_normal()
		getVelocityX_Z()
		var velocityY = Vector3(0, velocity.y, 0)
		stored_velocity = velocity
		velocity = velocityX_Z.bounce(currentcollision.get_normal()) + velocityY.bounce(currentcollision.get_normal()) * pinballCollision
		is_skidding = CollisionType.Recent
	else:
		if collision_cooldown > .1:
			velocity = (velocity.bounce(currentcollision.get_normal()) * 0.25)
	if hooked:
		hooked = false
	Turret.get_node("Turret_body_y")._retract_hookshot()

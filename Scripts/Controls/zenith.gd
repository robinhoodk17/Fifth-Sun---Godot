extends CharacterBody3D

@export_group("Nodes for function")
##The marker3D, not the actual camera
@export var Camera : Marker3D
##The 3D node labeled "Turret"
@export var Turret : Node3D
##The root node
@export var BodyCollider : CollisionShape3D
@export var Wing_FrontCollider : CollisionShape3D
@export var Wing_BackCollider : CollisionShape3D


@export_group("Ship stats")
@export var max_speed : float = 100.0
@export var acceleration : float = 16.0
@export var boost : float = 30.0
@export var braking : float = 1.2
@export var roll_speed : float = 1.2
@export var yaw_speed : float = 2.0
@export var pitch_speed : float = 2.0
@export_subgroup("Ship responsiveness")
@export var pitch_response : float = 1.2
@export var yaw_response : float = 1.2
@export var roll_response : float = 15.0
@export var grip : float = .8
@export_group("Hookshot stats")
@export var hookshot_strength : float = 1.6
@export_group("Controller")
@export var Controller_Sensitivity : float = 1

@onready var AIPilotNode : Node3D = $"../Track_objects/Route_nodes/1"
@onready var Camera_offset : Vector3 = Camera.position
@onready var Pilot = GlobalVariables.Pilot 

var is_accelerating : bool = false
var is_braking : bool = false
var forward_speed : float = 0.0
"""collision variables"""
var collision_suspension_time = 40
var collision_time = collision_suspension_time+1
var is_skidding = false
var minimum_speed_after_collision = .3
""""""
var previous_speed  = [0.0,0.0,0.0,0.0,0.0,0.0,0.0,0.0,0.0,0.0,0.0,0.0,0.0,0.0,0.0,0.0,0.0,0.0,0.0,0.0]
var speed_array_counter : int = 0
var pitch_input : float = 0.0
var yaw_input : float = 0.0
var roll_input : float = 0.0
var _mouse_input : bool = false
var look_at : Vector3
var hooked : bool = false
var hookshot_length
var hookshot_landing_point
var held_Item = null
var draft : bool = true


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
		if Input.is_action_pressed("Secondary_%s" % [Pilot]):
			if held_Item == "boost":
				held_Item = null
				forward_speed += 10

func move_turret_and_camera():
	Turret.position = position
	var last_speed
	if(speed_array_counter < 19):
		last_speed = speed_array_counter+1
	else:
		last_speed = 0
	var instantaneous_acceleration = 1/(1+50*(forward_speed-previous_speed[last_speed]))
	if instantaneous_acceleration < 0:
		instantaneous_acceleration = .8
	var lerp_speed = clamp(instantaneous_acceleration,.001,.8)
	Camera.position = Camera.position.lerp(position,.2)
	var a = Quaternion(transform.basis.orthonormalized())
	var b = Quaternion(Camera.transform.basis.orthonormalized())
	var c = b.slerp(a, 0.1)
	Camera.transform.basis = Basis(c)

func _normal_movement(delta):
	if(collision_time > collision_suspension_time and !is_skidding):
		transform.basis = transform.basis.rotated(transform.basis.z, roll_input * roll_speed * delta)
		transform.basis = transform.basis.rotated(transform.basis.x, pitch_input * pitch_speed * delta)
		transform.basis = transform.basis.rotated(transform.basis.y, yaw_input * yaw_speed * delta)
		transform.basis = transform.basis.orthonormalized()
		velocity = -transform.basis.z * forward_speed
	else:
		if is_skidding:
			transform.basis = transform.basis.rotated(transform.basis.z, roll_input * roll_speed * delta)
			transform.basis = transform.basis.rotated(transform.basis.x, pitch_input * pitch_speed * delta)
			transform.basis = transform.basis.rotated(transform.basis.y, yaw_input * yaw_speed * delta)
			transform.basis = transform.basis.orthonormalized()
			if(velocity.length() < max_speed):
				velocity = velocity - transform.basis.z * acceleration*delta
		if !is_skidding:
			var aimingAt = position + velocity
			var look_atMatrix = global_transform.looking_at(aimingAt, global_transform.basis.y)
			global_transform.basis.y=lerp(global_transform.basis.y, look_atMatrix.basis.y, delta*10)
			global_transform.basis.x=lerp(global_transform.basis.x, look_atMatrix.basis.x, delta*10)
			global_transform.basis.z=lerp(global_transform.basis.z, look_atMatrix.basis.z, delta*10)
			transform.basis = transform.basis.orthonormalized()
			transform.basis = transform.basis.rotated(transform.basis.z, roll_input * roll_speed * delta)
			transform.basis = transform.basis.rotated(transform.basis.x, pitch_input * pitch_speed * delta)
			transform.basis = transform.basis.rotated(transform.basis.y, yaw_input * yaw_speed * delta)
			transform.basis = transform.basis.orthonormalized()
			velocity = velocity.normalized() * forward_speed
		


func _hooked_movement(delta):
	transform.basis = transform.basis.rotated(transform.basis.z, roll_input * roll_speed * delta)
	transform.basis = transform.basis.rotated(transform.basis.x, pitch_input * pitch_speed * delta)
	transform.basis = transform.basis.rotated(transform.basis.y, yaw_input * yaw_speed * delta)
	transform.basis = transform.basis.orthonormalized()
	velocity = -transform.basis.z * forward_speed
	var distance_to_hook = position.distance_to(hookshot_landing_point)
	
	#Here we handle how the hookshot interacts with the ship
	if (distance_to_hook  > hookshot_length):
		var vector_lookingat_hook : Vector3 = (hookshot_landing_point - global_position).normalized()
		var rightdotproduct = vector_lookingat_hook.dot(global_transform.basis.x)
		var frontdotproduct = vector_lookingat_hook.dot(global_transform.basis.z)
		var updotproduct = vector_lookingat_hook.dot(global_transform.basis.y)
		var rightdirection = global_transform.basis.x * delta * hookshot_strength * rightdotproduct
		var frontdirection : Vector3 = Vector3 (0,0,0)
		if frontdotproduct > 0:
			frontdirection = -global_transform.basis.z * delta * hookshot_strength * frontdotproduct * acceleration * 1.5
		var updirection = global_transform.basis.y * delta * hookshot_strength * updotproduct
		var  direction = (updirection + rightdirection + velocity.normalized()).normalized()
		velocity = (direction * forward_speed) - frontdirection
		var look_at_vector = transform.looking_at(transform.origin + velocity)
		transform.basis.x = look_at_vector.basis.x
		transform.basis.y = look_at_vector.basis.y
		transform.basis.z = look_at_vector.basis.z
		transform.basis.orthonormalized()
		
		#the previous way of handling the hookshot
#		var vector_lookingat_hook : Vector3 = (hookshot_landing_point - global_position)
#		vector_lookingat_hook = vector_lookingat_hook.normalized()
#		vector_lookingat_hook = vector_lookingat_hook * (distance_to_hook - hookshot_length) * hookshot_strength
#		velocity += vector_lookingat_hook
#		var targetposition = position + velocity
#		transform.looking_at(targetposition)

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
	
	if frontorBack <= 0 and !hooked:
		is_braking = true
		is_accelerating = false
	else: 
		is_accelerating = true
		is_braking = false
"""
forward speed also gets changed by the RouteNode script on entering if it is a booster node
and by the TUrret_controller script when the hookshot gets unhooked
"""
func _physics_process(delta):
	#here we record the previous 5 speeds. We increase the speed_array_counter at the end of physiscs process
	collision_time += 1
	previous_speed[speed_array_counter] = forward_speed
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
	if not hooked:
		_normal_movement(delta)
	else:
		_hooked_movement(delta)
	
	forward_speed = velocity.length()
	var collisions = move_and_collide(velocity*delta)
	if collisions:
		collide_and_slide(collisions, delta)
	move_turret_and_camera()
	forward_speed = velocity.length()
	if collision_time > collision_suspension_time/2:
		if !is_accelerating:
			is_skidding = false
	if speed_array_counter < 19:
		speed_array_counter += 1
	else:
		speed_array_counter = 0
	
func find_largest_dict_key(dict):
	var max_val = -999999
	var max_var
	var key
	for i in dict:
		var val =  dict[i]
		if val > max_val:
			max_val = val
			max_var = i
			key = i
	return key
func collide_and_slide(currentcollision : KinematicCollision3D, delta):
	collision_time = 0
	var collision_normal = currentcollision.get_normal()
	var velocity_loss = (1 - abs(collision_normal.normalized().dot(velocity.normalized())))
	velocity_loss = clamp(velocity_loss,minimum_speed_after_collision,.95)
	if(velocity_loss <= minimum_speed_after_collision):
		is_skidding = true 
	velocity = velocity.bounce(collision_normal) * velocity_loss
	hooked = false

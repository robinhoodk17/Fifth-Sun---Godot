extends CharacterBody3D

@onready var Gunner = GlobalVariables.Gunner 
@onready var screen_ratio = GlobalVariables.Screen_ratio 


@export_group("Nodes for function")
##The Camera_Pivot
@export var turret_body_y : CharacterBody3D
@export var turret_body_x : Marker3D
@export var Ship_body : CharacterBody3D
@export var AimAssist_Big : ShapeCast3D
@export var AimAssist_Small : ShapeCast3D
@export var AimAssist_Center : ShapeCast3D
@export var ray : RayCast3D
@export var aim_assist_ray : RayCast3D
##The node 3D called Grapple, which includes a mesh
@export var grappling_hook : Node3D

@export_group("Controller sensitivity")
@export var controller_sensitivity : float = 1.25
@export var aim_Assist_Strength : float = 15
@export var gravity_well_strength : float = 240
@export_group("ship Stats")
##shots per minute
@export var fire_rate : float = 65

var _mouse_input : bool = false
var _rotation_input : float
var _tilt_input : float
var aim_DistancetoTarget : float = 1
var controller_strength
var gravity_well_counter = 0
var aimAssist_Point
var current_item = null
#hookshot variables
enum Hookshot_States {ready, flying, anchored, retracting}
var _hookshot_state = Hookshot_States.ready
var hookshot_landing_point
var hookshot_length
var hookshot_distance_flown : float = 0.0
var time_hookshot_pressed : int = 0
var time_shot_pressed : int = 0
#AI variables
var autoGunner : bool = false
var autoGunnerHookTarget = null
var shootingHookshot = false
var acquiring_target = false
var AIhookshotFlying = false

func _ready():
	controller_strength = controller_sensitivity
	AimAssist_Big.add_exception(Ship_body)
	AimAssist_Big.add_exception(turret_body_y)
	AimAssist_Small.add_exception(Ship_body)
	AimAssist_Small.add_exception(turret_body_y)
	AimAssist_Center.add_exception(Ship_body)
	AimAssist_Center.add_exception(turret_body_y)
	aim_assist_ray.add_exception(turret_body_y)
	aim_assist_ray.add_exception(Ship_body)
	ray.add_exception(Ship_body)
	ray.add_exception(turret_body_y)
	
	if Gunner == null:
		autoGunner = true
	if Gunner == 2:
		Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
	
func _unhandled_input(event):
	_mouse_input = event is InputEventMouseMotion and Input.mouse_mode == Input.MOUSE_MODE_CAPTURED
	if _mouse_input and Gunner == 2:
		_rotation_input = -event.relative.normalized().x * controller_sensitivity * 2
		_tilt_input =  -event.relative.normalized().y * controller_sensitivity * 2

func _aim_assist(_delta):
	if Gunner != null:
		if aim_assist_ray.is_colliding():
			controller_strength = controller_sensitivity/(aim_Assist_Strength/10)
			gravity_well_counter = gravity_well_strength
			aimAssist_Point = aim_assist_ray.get_collision_point()
		else:
			controller_strength = controller_sensitivity
		if _rotation_input == 0 and _tilt_input == 0 and Gunner != null:
			_tilt_input = Input.get_axis("Go_down_%s" % [Gunner],"Go_up_%s" % [Gunner]) * controller_strength/screen_ratio
			_rotation_input = Input.get_axis("Go_right_%s" % [Gunner], "Go_left_%s" % [Gunner]) * controller_strength
	
		turret_body_y.rotate_y(deg_to_rad(_rotation_input * controller_strength))
		turret_body_x.rotate_x(deg_to_rad(_tilt_input * controller_strength))
		turret_body_x.transform.basis = turret_body_x.transform.basis.orthonormalized()
		turret_body_y.transform.basis = turret_body_y.transform.basis.orthonormalized()
		
func _gravity_well(delta):
	if AimAssist_Small.is_colliding() and gravity_well_counter > 0 and !aim_assist_ray.is_colliding():
		var aimingAt = aimAssist_Point
		var look_atMatrix = turret_body_x.global_transform.looking_at(aimingAt, turret_body_x.global_transform.basis.y)
		var aimStrength = delta * aim_Assist_Strength
		var y_angle = 1
		var x_angle = 1
		if(look_atMatrix.basis.tdotx(turret_body_x.global_transform.basis.z) > 0):
			y_angle = -1
		if(look_atMatrix.basis.tdoty(turret_body_x.global_transform.basis.z) < 0):
			x_angle = -1
		
		turret_body_y.rotate_y(deg_to_rad(delta * aimStrength*350*y_angle))
		turret_body_y.transform.basis = turret_body_y.transform.basis.orthonormalized()
		
		turret_body_x.rotate_x(deg_to_rad(delta * aimStrength*200*x_angle))
		turret_body_x.transform.basis = turret_body_x.transform.basis.orthonormalized()
func _shoot():
	if(time_shot_pressed >= fire_rate):
		if AimAssist_Small.is_colliding():
			var aimingAt = AimAssist_Small.get_collision_point(0)
			var look_atMatrix = turret_body_x.global_transform.looking_at(aimingAt, turret_body_x.global_transform.basis.y)
			var y_angle = 1
			var x_angle = 1
			if(look_atMatrix.basis.tdotx(turret_body_x.global_transform.basis.z) > 0):
				y_angle = -1
			if(look_atMatrix.basis.tdoty(turret_body_x.global_transform.basis.z) < 0):
				x_angle = -1
				
			turret_body_y.rotate_y(deg_to_rad(y_angle))
			turret_body_y.transform.basis = turret_body_y.transform.basis.orthonormalized()
			
			turret_body_x.rotate_x(deg_to_rad(x_angle))
			turret_body_x.transform.basis = turret_body_x.transform.basis.orthonormalized()

		if ray.is_colliding():
			pass
func StartSearchingForTarget(hookshotTarget):
	autoGunnerHookTarget = hookshotTarget
	if hookshotTarget != null:
		acquiring_target = true
		print("we should be acquiring target")
	else:
		print("we should stop acquiring")
		AIhookshotFlying = false

func _shoot_hookshot():
	if _hookshot_state == Hookshot_States.ready and time_hookshot_pressed < 15:
		#handle aim assist
		# and time_hookshot_pressed <= 20
		if AimAssist_Small.is_colliding():
			var aimingAt = AimAssist_Small.get_collision_point(0)
			var look_atMatrix = turret_body_x.global_transform.looking_at(aimingAt, turret_body_x.global_transform.basis.y)
			var y_angle = 1
			var x_angle = 1
			if(look_atMatrix.basis.tdotx(turret_body_x.global_transform.basis.z) > 0):
				y_angle = -1
			if(look_atMatrix.basis.tdoty(turret_body_x.global_transform.basis.z) < 0):
				x_angle = -1
				
			turret_body_y.rotate_y(deg_to_rad(y_angle))
			turret_body_y.transform.basis = turret_body_y.transform.basis.orthonormalized()
			
			turret_body_x.rotate_x(deg_to_rad(x_angle))
			turret_body_x.transform.basis = turret_body_x.transform.basis.orthonormalized()
		
		#handle hookshot shot
		if ray.is_colliding():
			grappling_hook.visible = true
			hookshot_distance_flown = 1
			grappling_hook.scale = Vector3 (1.0,1.0,hookshot_distance_flown)
			Ship_body.hooked = true
			hookshot_landing_point = ray.get_collision_point()
			Ship_body.hookshot_landing_point = hookshot_landing_point
			hookshot_length = Ship_body.global_position.distance_to(hookshot_landing_point)
			#Ship_body.hookshot_length = hookshot_length
			_hookshot_state = Hookshot_States.flying
		else:
			pass
func _handle_hookshot_flight():
	#animation for hookshot flying
	if _hookshot_state == Hookshot_States.flying:
		if hookshot_distance_flown >= hookshot_length:
			_hookshot_state = Hookshot_States.anchored
		else:
			hookshot_distance_flown += hookshot_length/10
			grappling_hook.look_at(hookshot_landing_point)
			grappling_hook.scale = Vector3 (1.0,1.0,hookshot_distance_flown)
	
	#keep looking at the anchor point
	if _hookshot_state == Hookshot_States.anchored:
		grappling_hook.look_at(hookshot_landing_point)
func _retract_hookshot():
	Ship_body.hooked = false
	autoGunnerHookTarget = null
	shootingHookshot = false
	AIhookshotFlying = false
	if _hookshot_state == Hookshot_States.flying:
		_hookshot_state = Hookshot_States.retracting
	if _hookshot_state == Hookshot_States.retracting:
		if hookshot_distance_flown <= 1:
			_hookshot_state = Hookshot_States.ready
			grappling_hook.visible = false
		else:
			hookshot_distance_flown -= hookshot_length/30
			grappling_hook.scale = Vector3 (1.0,1.0,hookshot_distance_flown)
	if _hookshot_state == Hookshot_States.anchored:
		Ship_body.forward_speed += (Ship_body.boost/3)
		_hookshot_state = Hookshot_States.retracting
func _AIShooter(delta):
	if acquiring_target and GlobalVariables.gunnerBehavior != GlobalVariables.Gunnerbehaviors.doNothing and autoGunnerHookTarget != null:
		var targetPosition = autoGunnerHookTarget.global_position
		if !aim_assist_ray.is_colliding():
			var look_atMatrix = turret_body_x.global_transform.looking_at(targetPosition, turret_body_x.global_transform.basis.y)
			controller_strength = 6
			var y_angle = 1
			var x_angle = 1
			if(look_atMatrix.basis.tdotx(turret_body_x.global_transform.basis.z) > 0):
				y_angle = -1
			if(look_atMatrix.basis.tdoty(turret_body_x.global_transform.basis.z) < 0):
				x_angle = -1
			
			turret_body_y.rotate_y(deg_to_rad(delta * controller_strength * y_angle * 100))
			turret_body_y.transform.basis = turret_body_y.transform.basis.orthonormalized()
			
			turret_body_x.rotate_x(deg_to_rad(delta * controller_strength * x_angle * 100))
			turret_body_x.transform.basis = turret_body_x.transform.basis.orthonormalized()
		else:
			shootingHookshot = true
			AIhookshotFlying = true
			acquiring_target = false
			time_hookshot_pressed = 0
	elif !AIhookshotFlying:
		shootingHookshot = false
		autoGunnerHookTarget = null
	
func _physics_process(delta):
	time_hookshot_pressed += 1
	time_shot_pressed += 1
	gravity_well_counter -= 1
	#Gunner is assigned in the global_variables during the character select screen and also is player 2 by default
	if Gunner != null:
		_aim_assist(delta)
		_rotation_input = 0
		_tilt_input = 0
		move_and_slide()
		_gravity_well(delta)
		if Input.is_action_just_pressed("Brake_%s" % [Gunner]):
			time_hookshot_pressed = 0
		if Input.is_action_pressed("Brake_%s" % [Gunner]):
			if(_hookshot_state == Hookshot_States.ready):
				_shoot_hookshot()
			else:
				_handle_hookshot_flight()
		if Input.is_action_just_released("Brake_%s" % [Gunner]) or _hookshot_state == Hookshot_States.retracting:
			_retract_hookshot()
		
		if Input.is_action_just_pressed("Accelerate_%s" % [Gunner]):
			time_shot_pressed = 0
		if Input.is_action_pressed("Accelerate_%s" % [Gunner]):
			_shoot()
		if _hookshot_state == Hookshot_States.anchored:
			grappling_hook.look_at(hookshot_landing_point)	
			grappling_hook.scale = Vector3 (1.0,1.0,position.distance_to(hookshot_landing_point))
	else:
		_AIShooter(delta)
		if shootingHookshot:
			if(_hookshot_state == Hookshot_States.ready):
				_shoot_hookshot()
			else:
				if _hookshot_state == Hookshot_States.retracting:
					_retract_hookshot()
				_handle_hookshot_flight()
		elif _hookshot_state != Hookshot_States.ready:
			_retract_hookshot()


func _on_ship_collision_signal():
	_retract_hookshot()
	Ship_body.hooked = false

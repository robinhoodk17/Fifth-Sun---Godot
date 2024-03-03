extends CharacterBody3D

@onready var Gunner = GlobalVariables.Gunner 
@onready var screen_ratio = GlobalVariables.Screen_ratio 


@export_group("Nodes for function")
##the turrett's camera, labeled Camera2 below the Marker3D
@export var Camera_controller : Camera3D
##The Camera_Pivot
@export var turret_body : CharacterBody3D
@export var Ship_body : CharacterBody3D
@export var AimAssist_Big : ShapeCast3D
@export var AimAssist_Small : ShapeCast3D
@export var AimAssist_Center : ShapeCast3D
@export var ray : RayCast3D
@export var aim_assist_ray : RayCast3D
##The node 3D called Grapple, which includes a mesh
@export var grappling_hook : Node3D

@export_group("Controller sensitivity")
@export var controller_sensitivity : float = 1.5
@export var aim_Assist_Strength : float = 12
@export var gravity_well_strength : float = 60
@export_group("ship Stats")
##shots per minute
@export var fire_rate : float = 65

var _mouse_input : bool = false
var _rotation_input : float
var _tilt_input : float
var aim_DistancetoTarget : float = 1
var autoGunner : bool = false
var controller_strength
var gravity_well_counter = 0
var current_item = null
enum Hookshot_States {ready, flying, anchored, retracting}
var _hookshot_state = Hookshot_States.ready
var hookshot_landing_point
var hookshot_length
var hookshot_distance_flown : float = 0.0
var time_hookshot_pressed : int = 0
var time_shot_pressed : int = 0


func _ready():
	controller_strength = controller_sensitivity
	AimAssist_Big.add_exception(Ship_body)
	AimAssist_Big.add_exception(turret_body)
	AimAssist_Small.add_exception(Ship_body)
	AimAssist_Small.add_exception(turret_body)
	AimAssist_Center.add_exception(Ship_body)
	AimAssist_Center.add_exception(turret_body)
	ray.add_exception(Ship_body)
	ray.add_exception(turret_body)
	
	if Gunner == null:
		autoGunner = true
	if Gunner == 2:
		Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
	
func _unhandled_input(event):
	_mouse_input = event is InputEventMouseMotion and Input.mouse_mode == Input.MOUSE_MODE_CAPTURED
	if _mouse_input and Gunner == 2:
		_rotation_input = -event.relative.normalized().x * controller_sensitivity * 1.5
		_tilt_input =  -event.relative.normalized().y * controller_sensitivity * 1.5

func _aim_assist(delta):
	if Gunner != null:
		if aim_assist_ray.is_colliding():
			controller_strength = controller_sensitivity/1.5
			gravity_well_counter = gravity_well_strength
	
		
func _gravity_well(delta):
	if AimAssist_Small.is_colliding() and gravity_well_counter > 0:
		var aimingAt = AimAssist_Small.get_collider(0).call("get", "global_position")
		var look_atVector = turret_body.global_transform.looking_at(aimingAt, turret_body.global_transform.basis.y)
		var aimStrength = delta * aim_Assist_Strength
		turret_body.transform.basis.y=lerp(turret_body.transform.basis.y, look_atVector.basis.y, aimStrength)
		turret_body.transform.basis.x=lerp(turret_body.transform.basis.x, look_atVector.basis.x, aimStrength)
		turret_body.transform.basis = transform.basis.orthonormalized()
func _shoot():
	if(time_shot_pressed >= fire_rate):
		AimAssist_Center.set_process(true)
		if AimAssist_Center.is_colliding():
			var aimingAt = AimAssist_Center.get_collision_point(0)
			turret_body.look_at(aimingAt)

		var space = get_world_3d().direct_space_state
		var query = PhysicsRayQueryParameters3D.create(Camera_controller.global_position,
				Camera_controller.global_position - Camera_controller.global_transform.basis.z * 500)
		var rid_array : Array[RID]
		rid_array.append(Ship_body.get_rid())
		rid_array.append(turret_body.get_rid())
		query.exclude = rid_array
		var collision = space.intersect_ray(query)

func _shoot_hookshot():
	if _hookshot_state == Hookshot_States.ready and time_hookshot_pressed <= 20:
		#handle aim assist
		if AimAssist_Center.is_colliding():
			var aimingAt = AimAssist_Center.get_collision_point(0)
			turret_body.look_at(aimingAt)
		
		#handle hookshot shot
		if ray.is_colliding():
			grappling_hook.visible = true
			hookshot_distance_flown = 1
			grappling_hook.scale = Vector3 (1.0,1.0,hookshot_distance_flown)
			Ship_body.hooked = true
			hookshot_landing_point = ray.get_collision_point()
			Ship_body.hookshot_landing_point = hookshot_landing_point
			hookshot_length = Ship_body.global_position.distance_to(hookshot_landing_point)
			Ship_body.hookshot_length = hookshot_length
			_hookshot_state = Hookshot_States.flying
		else:
			pass
func _handle_hookshot_flight():
	#animation for hookshot flying
	if _hookshot_state == Hookshot_States.flying:
		if hookshot_distance_flown >= hookshot_length:
			_hookshot_state = Hookshot_States.anchored
		else:
			hookshot_distance_flown += hookshot_length/30
			grappling_hook.look_at(hookshot_landing_point)
			grappling_hook.scale = Vector3 (1.0,1.0,hookshot_distance_flown)
	
	#keep looking at the anchor point
	if _hookshot_state == Hookshot_States.anchored:
		grappling_hook.look_at(hookshot_landing_point)
func _retract_hookshot():
	Ship_body.hooked = false
	if _hookshot_state == Hookshot_States.retracting:
		if hookshot_distance_flown <= 1:
			_hookshot_state = Hookshot_States.ready
			grappling_hook.visible = false
		else:
			hookshot_distance_flown -= hookshot_length/50
			grappling_hook.scale = Vector3 (1.0,1.0,hookshot_distance_flown)
			
		
		
	if _hookshot_state == Hookshot_States.anchored:
		Ship_body.forward_speed += (Ship_body.boost/3)
		_hookshot_state = Hookshot_States.retracting
	
	if _hookshot_state == Hookshot_States.flying:
		_hookshot_state = Hookshot_States.retracting
	
func _physics_process(delta):
	#Gunner is assigned in the global_variables during the character select screen and also is player 2 by default
	if Gunner != null:
		_aim_assist(delta)
		if _rotation_input == 0 and _tilt_input == 0 and Gunner != null:
			_tilt_input = Input.get_axis("Go_down_%s" % [Gunner],"Go_up_%s" % [Gunner]) * controller_strength/screen_ratio
			_rotation_input = Input.get_axis("Go_right_%s" % [Gunner], "Go_left_%s" % [Gunner]) * controller_strength
		turret_body.transform.basis =turret_body.transform.basis.rotated(turret_body.transform.basis.x, _tilt_input * delta)
		turret_body.transform.basis = turret_body.transform.basis.rotated(turret_body.transform.basis.y, _rotation_input * delta)
		turret_body.transform.basis = turret_body.transform.basis.orthonormalized()
		_rotation_input = 0
		_tilt_input = 0
		move_and_slide()
		_gravity_well(delta)
	
	
		time_hookshot_pressed += 1
		time_shot_pressed += 1
		gravity_well_counter -= 1
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
		


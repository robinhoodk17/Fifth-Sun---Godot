extends MeshInstance3D

var cam_pos_prev = Vector3()
var cam_rot_prev = Quaternion()
var motionBlurTarget : CharacterBody3D
@onready var cam : Camera3D = get_parent()
func _ready():
	motionBlurTarget = $"../..".get_parent()
func _process(_delta):
	
	#OS.delay_msec(30)
	
	var mat: ShaderMaterial = get_surface_override_material(0)
	assert(cam is Camera3D)
	
	# Linear velocity is just difference in positions between two frames.
	var velocity = cam.global_transform.origin - cam_pos_prev
	
	# Angular velocity is a little more complicated, as you can see.
	# See https://math.stackexchange.com/questions/160908/how-to-get-angular-velocity-from-difference-orientation-quaternion-and-time
	var cam_rot = Quaternion(cam.global_transform.basis)
	var cam_rot_diff = cam_rot - cam_rot_prev
	var cam_rot_conj = conjugate(cam_rot)
	var ang_vel = (cam_rot_diff * 2.0) * cam_rot_conj; 
	ang_vel = Vector3(ang_vel.x, ang_vel.y, ang_vel.z) # Convert Quat to Vector3
	var speed = motionBlurTarget.velocity.length()
	cam.fov = clamp(GlobalVariables.FOV +  speed/15,GlobalVariables.FOV,GlobalVariables.FOV*1.5)
	if motionBlurTarget.boosting:
		mat.set_shader_parameter("intensity",  (GlobalVariables.MotionBlurIntensity*2))
	else:
		mat.set_shader_parameter("intensity",  (GlobalVariables.MotionBlurIntensity))
	if speed > 60:
		#mat.set_shader_parameter("intensity",  (motionBlurTarget.forward_speed-60/120))
		mat.set_shader_parameter("linear_velocity", velocity)
		mat.set_shader_parameter("angular_velocity", ang_vel)
	else:
		
		mat.set_shader_parameter("linear_velocity", Vector3(0,0,0))
		mat.set_shader_parameter("angular_velocity", Vector3(0,0,0))
	cam_pos_prev = cam.global_transform.origin
	cam_rot_prev = Quaternion(cam.global_transform.basis)
	
# Calculate the conjugate of a quaternion.
func conjugate(quat):
	return Quaternion(-quat.x, -quat.y, -quat.z, quat.w)

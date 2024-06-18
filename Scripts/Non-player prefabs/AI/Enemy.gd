extends CharacterBody3D
class_name Basic_enemy

@export var acceleration : float = 5
@export_range (3, 10, 0.2) var turn_speed : float = 5.0
@export var target : Node3D
@export var maxSpeed : int = 0
@export var initialVelocity : Vector3
var speed = 0
func startup():
	visible = true
	acceleration = target.acceleration + 2
	target = target.get_child(1)
	print (target)
	

func rotateObject(delta):
	var heading = target.global_position
	var look_atMatrix = transform.looking_at(heading)
	global_transform.basis.y=lerp(global_transform.basis.y, look_atMatrix.basis.y, delta*turn_speed)
	global_transform.basis.x=lerp(global_transform.basis.x, look_atMatrix.basis.x, delta*turn_speed)
	global_transform.basis.z=lerp(global_transform.basis.z, look_atMatrix.basis.z, delta*turn_speed)
	transform.basis = transform.basis.orthonormalized()
func _physics_process(delta):
	if target != null:
		velocity = -transform.basis.z * speed
		if maxSpeed == 0 or speed < maxSpeed:
			speed += acceleration * delta
		rotateObject(delta)
		move_and_slide()

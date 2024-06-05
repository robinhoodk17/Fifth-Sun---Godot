extends CharacterBody3D

@export var acceleration : float
@export var turn_speed : float
var speed = 0
var target : Node3D
var _deviatedPrediction
func rotateObject(delta):
	var heading = _deviatedPrediction - position
	var look_atMatrix = transform.looking_at(heading)
	global_transform.basis.y=lerp(global_transform.basis.y, look_atMatrix.basis.y, delta*turn_speed)
	global_transform.basis.x=lerp(global_transform.basis.x, look_atMatrix.basis.x, delta*turn_speed)
	global_transform.basis.z=lerp(global_transform.basis.z, look_atMatrix.basis.z, delta*turn_speed)
	transform.basis = transform.basis.orthonormalized()

func _physics_process(delta):
	velocity = -transform.basis.z * speed
	rotateObject(delta)
	move_and_slide()

extends CharacterBody3D
class_name Basic_enemy

@export var acceleration : float = 5
@export_range (3, 10, 0.2) var turn_speed : float = 5.0
var target
@export var maxSpeed : int = 0
@export var damage : int = 1
@export var maxHealth : int = 5
@onready var healthbar = $Health
var health : int = maxHealth
var speed = 0
var started : bool = false

func _ready():
	startup()
	
func startup():
	healthbar.init_health(maxHealth)
	health = maxHealth
	visible = true
	if target is Node3D:
		acceleration = target.acceleration + 2
		target = target.get_child(1)
	
func takeDamage(damageTaken):
	health -= damageTaken
	healthbar.health = health
	if health <= 0:
		visible = false
		set_process(false)
		set_physics_process(false)
	
func rotateObject(delta):
	var heading
	if target is Vector3:
		heading = Vector3(target)
	else:
		heading = target.global_position
	var look_atMatrix = global_transform.looking_at(heading)
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

extends Camera3D

@export var lerp_speed = 3.0
@onready var target = $".."
@export var offset = Vector3.ZERO



func _physics_process(delta):
	var target_pos = target.global_transform.translated(offset)
	global_transform = global_transform.interpolate_with(target_pos, lerp_speed * delta)
	look_at(target.global_transform.origin, Vector3.UP)

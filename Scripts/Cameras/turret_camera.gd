extends Marker3D

var turret_body : Node3D

func initialize(turret):
	turret_body = turret
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta):
	global_transform = turret_body.global_transform

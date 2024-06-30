extends GPUParticles3D

func _process(_delta):
	if !emitting:
		get_parent().queue_free()

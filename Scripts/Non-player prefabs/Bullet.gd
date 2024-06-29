extends GPUParticles3D

func _process(delta):
	if !emitting:
		get_parent().queue_free()
